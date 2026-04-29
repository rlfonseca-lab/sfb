from setuptools import setup, find_packages

setup(
    name="ckanext-sfbdraftsearch",
    version="0.0.1",
    description="Mostra drafts nas buscas para sysadmins no CKAN",
    packages=find_packages(),
    include_package_data=True,
    zip_safe=False,
    install_requires=[],
    entry_points="""
    [ckan.plugins]
    sfb_drafts_search=ckanext.sfbdraftsearch.plugin:SfbDraftSearchPlugin
    """,
)
