from setuptools import setup, find_packages
setup(
    name="ckanext-sfb-facets-multi",
    version="0.0.1",
    packages=find_packages(),
    include_package_data=True,
    zip_safe=False,
    entry_points="""
        [ckan.plugins]
        sfb_facets_multi=ckanext.sfb_facets_multi.plugin:SfbFacetsMultiPlugin
    """,
)
