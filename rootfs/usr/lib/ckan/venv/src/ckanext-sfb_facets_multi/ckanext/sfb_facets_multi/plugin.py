from collections import OrderedDict
import json
import ckan.plugins as plugins
import ckan.plugins.toolkit as tk

FACETS = [
    {"src": "owner_org", "dst": "unidade_facet", "label": "Unidade", "multi": False},
    {"src": "grupo_institucional", "dst": "grupo_facet", "label": "Grupo", "multi": True},
    {"src": "sfb_grupo", "dst": "projeto_nome_facet", "label": "Projeto", "multi": True},
    {"src": "temas", "dst": "temas_facet", "label": "Temas", "multi": True},
    {"src": "ccd", "dst": "ccd_facet", "label": "CCD", "multi": False},
    {"src": "escopo", "dst": "escopo_facet", "label": "Escopo", "multi": False},
    {"src": "abrangencia", "dst": "abrangencia_facet", "label": "Abrangência", "multi": False},
    {"src": "fonte", "dst": "fonte_facet", "label": "Fonte", "multi": False},
    {"src": "sistema_relacionado", "dst": "sistema_relacionado_facet", "label": "Sistema Relacionado", "multi": True},
    {"src": "etiquetas", "dst": "etiquetas_facet", "label": "Etiquetas", "multi": True},
]

def _build_group_title_lookup():
    lookup = {}
    try:
        groups = tk.get_action("group_list")(
            {"ignore_auth": True},
            {
                "type": "group",
                "all_fields": True,
                "include_dataset_count": False,
                "include_extras": False,
                "include_groups": False,
                "include_users": False,
                "sort": "title asc",
                "limit": 1000,
                "offset": 0,
            },
        )
        for g in groups:
            name = (g.get("name") or "").strip()
            title = (g.get("title") or g.get("display_name") or name).strip()
            if name:
                lookup[name] = title
    except Exception:
        pass
    return lookup


def _build_org_title_lookup():
    lookup = {}
    try:
        orgs = tk.get_action("organization_list")(
            {"ignore_auth": True},
            {
                "all_fields": True,
                "include_dataset_count": False,
                "sort": "title asc",
                "limit": 1000,
                "offset": 0,
            },
        )
        for org in orgs:
            org_id = (org.get("id") or "").strip()
            name = (org.get("name") or "").strip()
            title = (org.get("title") or org.get("display_name") or name or org_id).strip()
            if org_id:
                lookup[org_id] = title
            if name:
                lookup[name] = title
    except Exception:
        pass
    return lookup

def _coerce_one(x):
    if isinstance(x, dict):
        for key in ("title", "display_name", "name", "label", "value"):
            val = x.get(key)
            if val is not None and str(val).strip():
                return str(val).strip()
        return None

    s = str(x).strip()
    return s or None

def _normalize(v, multi: bool):
    if v is None or v == "":
        return None

    if isinstance(v, str):
        try:
            vv = json.loads(v)
            v = vv
        except Exception:
            v = v.strip()

    if isinstance(v, list):
        items = []
        for x in v:
            val = _coerce_one(x)
            if val:
                items.append(val)
    elif isinstance(v, dict):
        val = _coerce_one(v)
        items = [val] if val else []
    else:
        s = str(v).strip()
        items = [s] if s else []

    if not items:
        return None

    dedup = []
    seen = set()
    for item in items:
        if item not in seen:
            seen.add(item)
            dedup.append(item)

    return dedup if multi else dedup[0]

class SfbFacetsMultiPlugin(plugins.SingletonPlugin):
    plugins.implements(plugins.IPackageController, inherit=True)
    plugins.implements(plugins.IFacets)

    def before_dataset_index(self, pkg_dict):
        group_title_lookup = _build_group_title_lookup()
        org_title_lookup = _build_org_title_lookup()

        for f in FACETS:
            src = f["src"]
            dst = f["dst"]
            multi = f["multi"]

            v = pkg_dict.get(src)
            if not v:
                v = pkg_dict.get(f"extras_{src}")

            nv = _normalize(v, multi)
            if nv is None:
                continue

            if src == "sfb_grupo":
                if multi:
                    nv = [group_title_lookup.get(item, item) for item in nv]
                else:
                    nv = group_title_lookup.get(nv, nv)

            if src == "owner_org":
                if multi:
                    nv = [org_title_lookup.get(item, item) for item in nv]
                else:
                    nv = org_title_lookup.get(nv, nv)

            pkg_dict[dst] = nv

        return pkg_dict

    def dataset_facets(self, facets_dict, package_type):
        new = OrderedDict()
        for f in FACETS:
            new[f["dst"]] = tk._(f["label"])
        facets_dict.clear()
        facets_dict.update(new)
        return facets_dict

    def group_facets(self, facets_dict, group_type, package_type):
        return self.dataset_facets(facets_dict, package_type)

    def organization_facets(self, facets_dict, organization_type, package_type):
        return self.dataset_facets(facets_dict, package_type)
