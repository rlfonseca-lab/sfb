# encoding: utf-8

import json
import logging
import re
import unicodedata

import click

import ckan.plugins as p
import ckan.plugins.toolkit as tk

log = logging.getLogger(__name__)


def _ascii(value):
    value = unicodedata.normalize("NFKD", value or "")
    return value.encode("ascii", "ignore").decode("ascii")


def _slugish(value):
    value = _ascii(str(value or "")).strip().lower()
    value = re.sub(r"[^a-z0-9_-]+", "-", value)
    value = re.sub(r"-{2,}", "-", value).strip("-")
    return value


def _flatten(value):
    if value is None:
        return []

    if isinstance(value, list):
        out = []
        for item in value:
            out.extend(_flatten(item))
        return out

    if isinstance(value, dict):
        out = []
        for key in ("name", "title", "value", "label"):
            if key in value and value.get(key):
                out.extend(_flatten(value.get(key)))
                return out
        return []

    text = str(value).strip()
    if not text:
        return []

    if text[:1] in ("[", "{"):
        try:
            decoded = json.loads(text)
            return _flatten(decoded)
        except Exception:
            pass

    parts = re.split(r"[|,;\n]+", text)
    return [p.strip() for p in parts if p.strip()]


class SfbGroupSyncPlugin(p.SingletonPlugin):
    p.implements(p.IPackageController, inherit=True)
    p.implements(p.IClick)

    def get_commands(self):
        @click.command("group-sync-backfill")
        @click.option("--dry-run", is_flag=True, default=False, help="Só simula, sem gravar.")
        @click.option("--limit", type=int, default=0, help="0 = todos os datasets.")
        @click.option("--only-dataset", default=None, help="Processa apenas um dataset (id ou name).")
        def group_sync_backfill(dry_run, limit, only_dataset):
            processed, changed = self._backfill_all(
                dry_run=dry_run,
                limit=limit,
                only_dataset=only_dataset,
            )
            click.echo(
                f"Backfill concluído | processed={processed} | changed={changed} | dry_run={dry_run}"
            )

        return [group_sync_backfill]

    def after_dataset_create(self, context, pkg_dict):
        dataset_id = pkg_dict.get("id")
        if dataset_id:
            self._sync_dataset_groups(dataset_id)

    def after_dataset_update(self, context, pkg_dict):
        dataset_id = pkg_dict.get("id")
        if dataset_id:
            self._sync_dataset_groups(dataset_id)

    def _field_candidates(self):
        raw = tk.config.get(
            "ckanext.sfb_group_sync.fields",
            "sfb_grupo,grupos,grupo,grupo_de_usuarios",
        )
        return [x.strip() for x in raw.split(",") if x.strip()]

    def _build_group_lookup(self):
        groups = tk.get_action("group_list")(
            {"ignore_auth": True},
            {
                "all_fields": True,
                "include_dataset_count": False,
                "include_extras": False,
                "include_users": False,
                "limit": 1000,
            },
        )

        lookup = {}
        for group in groups:
            name = (group.get("name") or "").strip()
            title = (group.get("title") or "").strip()

            if name:
                lookup[name.lower()] = name
                lookup[_slugish(name)] = name

            if title:
                lookup[title.lower()] = name
                lookup[_slugish(title)] = name

        return lookup

    def _extract_group_values(self, pkg):
        field_candidates = self._field_candidates()

        for field_name in field_candidates:
            if field_name in pkg and pkg.get(field_name):
                return _flatten(pkg.get(field_name))

        for extra in pkg.get("extras", []):
            key = extra.get("key")
            val = extra.get("value")
            if key in field_candidates and val:
                return _flatten(val)

        return []

    def _resolve_group_names(self, raw_values, lookup):
        resolved = []
        for raw in raw_values:
            raw_clean = str(raw).strip()
            if not raw_clean:
                continue

            exact = lookup.get(raw_clean.lower())
            slug = lookup.get(_slugish(raw_clean))
            group_name = exact or slug

            if group_name:
                resolved.append(group_name)
            else:
                log.warning("Grupo não encontrado para valor do campo customizado: %r", raw_clean)

        deduped = []
        seen = set()
        for item in resolved:
            if item not in seen:
                deduped.append(item)
                seen.add(item)

        return deduped

    def _sync_dataset_groups(self, dataset_id, dry_run=False, group_lookup=None):
        context = {"ignore_auth": True}

        pkg = tk.get_action("package_show")(context, {"id": dataset_id})
        raw_values = self._extract_group_values(pkg)

        lookup = group_lookup or self._build_group_lookup()
        desired_group_names = set(self._resolve_group_names(raw_values, lookup))
        current_group_names = {
            g.get("name")
            for g in pkg.get("groups", [])
            if g.get("name")
        }

        if current_group_names == desired_group_names:
            return False

        to_remove = sorted(current_group_names - desired_group_names)
        to_add = sorted(desired_group_names - current_group_names)

        if dry_run:
            log.info(
                "[DRY-RUN] dataset=%s | remove=%s | add=%s",
                dataset_id,
                to_remove,
                to_add,
            )
            return True

        for group_name in to_remove:
            tk.get_action("member_delete")(
                context,
                {
                    "id": group_name,
                    "object": dataset_id,
                    "object_type": "package",
                },
            )
            log.info("Dataset %s removido do grupo %s", dataset_id, group_name)

        for group_name in to_add:
            tk.get_action("member_create")(
                context,
                {
                    "id": group_name,
                    "object": dataset_id,
                    "object_type": "package",
                    "capacity": "public",
                },
            )
            log.info("Dataset %s associado ao grupo %s", dataset_id, group_name)

        return True

    def _backfill_all(self, dry_run=False, limit=0, only_dataset=None):
        processed = 0
        changed = 0
        lookup = self._build_group_lookup()

        if only_dataset:
            was_changed = self._sync_dataset_groups(
                only_dataset,
                dry_run=dry_run,
                group_lookup=lookup,
            )
            processed += 1
            changed += int(bool(was_changed))
            return processed, changed

        start = 0
        rows = 100

        while True:
            result = tk.get_action("package_search")(
                {"ignore_auth": True},
                {
                    "q": "*:*",
                    "rows": rows,
                    "start": start,
                    "include_private": True,
                    "sort": "metadata_created asc",
                    "fl": "id,name",
                },
            )

            datasets = result.get("results", [])
            if not datasets:
                break

            for dataset in datasets:
                dataset_id = dataset.get("id") or dataset.get("name")
                if not dataset_id:
                    continue

                was_changed = self._sync_dataset_groups(
                    dataset_id,
                    dry_run=dry_run,
                    group_lookup=lookup,
                )

                processed += 1
                changed += int(bool(was_changed))

                if processed % 50 == 0:
                    click.echo(f"Progresso: processed={processed} | changed={changed}")

                if limit and processed >= limit:
                    return processed, changed

            start += rows

        return processed, changed
