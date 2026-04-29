from __future__ import annotations

import ckan.plugins as p
import ckan.plugins.toolkit as tk


def sfbgroups_group_choices(field=None):
    """
    Retorna choices dinâmicas a partir dos grupos do CKAN.
    value = slug/name do grupo
    label = título do grupo
    """
    out = []
    limit = 1000
    offset = 0

    while True:
        batch = tk.get_action("group_list")(
            {},
            {
                "type": "group",
                "all_fields": True,
                "include_dataset_count": False,
                "include_extras": False,
                "include_groups": False,
                "include_users": False,
                "sort": "title asc",
                "limit": limit,
                "offset": offset,
            },
        )

        if not batch:
            break

        for g in batch:
            value = g.get("name")
            label = g.get("title") or g.get("display_name") or value
            if value:
                out.append({"value": value, "label": label})

        if len(batch) < limit:
            break

        offset += limit

    seen = set()
    dedup = []
    for item in out:
        if item["value"] not in seen:
            seen.add(item["value"])
            dedup.append(item)

    return dedup


class SfbGroupsPlugin(p.SingletonPlugin):
    p.implements(p.ITemplateHelpers)

    def get_helpers(self):
        return {"sfbgroups_group_choices": sfbgroups_group_choices}
