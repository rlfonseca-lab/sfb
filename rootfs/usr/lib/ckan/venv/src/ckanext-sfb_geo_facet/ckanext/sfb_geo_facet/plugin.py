from collections import OrderedDict
import json
import ckan.plugins as plugins
import ckan.plugins.toolkit as tk


class SfbGeoFacetPlugin(plugins.SingletonPlugin):
    plugins.implements(plugins.IPackageController, inherit=True)
    plugins.implements(plugins.IFacets)

    def before_dataset_index(self, pkg_dict):
        v = pkg_dict.get("referencia_geo") or pkg_dict.get("extras_referencia_geo")
        if not v:
            return pkg_dict

        if isinstance(v, str):
            try:
                vv = json.loads(v)
                v = vv if isinstance(vv, list) else [v]
            except Exception:
                v = [v]
        elif not isinstance(v, list):
            v = [v]

        pkg_dict["referencia_geo_facet"] = [str(x).strip() for x in v if str(x).strip()]
        return pkg_dict

    def _add_referencia_geo_facet(self, facets_dict):
        new = OrderedDict(facets_dict)
        new["referencia_geo_facet"] = tk._("Referência geográfica")
        facets_dict.clear()
        facets_dict.update(new)
        return facets_dict

    def dataset_facets(self, facets_dict, package_type):
        return self._add_referencia_geo_facet(facets_dict)

    def group_facets(self, facets_dict, group_type, package_type):
        return self._add_referencia_geo_facet(facets_dict)

    def organization_facets(self, facets_dict, organization_type, package_type):
        return self._add_referencia_geo_facet(facets_dict)
