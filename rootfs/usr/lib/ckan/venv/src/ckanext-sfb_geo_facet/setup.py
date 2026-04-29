from setuptools import setup, find_packages

setup(
    name="ckanext-sfb-geo-facet",
    version="0.0.1",
    packages=find_packages(),
    include_package_data=True,
    zip_safe=False,
    entry_points="""
        [ckan.plugins]
        sfb_geo_facet=ckanext.sfb_geo_facet.plugin:SfbGeoFacetPlugin
    """,
)
