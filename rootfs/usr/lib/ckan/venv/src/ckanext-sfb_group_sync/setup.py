from setuptools import setup, find_packages

setup(
    name="ckanext-sfb-group-sync",
    version="0.0.1",
    description="Sincroniza campo customizado de grupos com grupos nativos do CKAN",
    packages=find_packages(),
    namespace_packages=["ckanext"],
    zip_safe=False,
    include_package_data=True,
    install_requires=[],
    entry_points="""
    [ckan.plugins]
    sfb_group_sync=ckanext.sfb_group_sync.plugin:SfbGroupSyncPlugin
    """,
)
