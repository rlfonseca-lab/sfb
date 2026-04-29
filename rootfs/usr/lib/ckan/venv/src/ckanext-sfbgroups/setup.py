from setuptools import setup, find_packages

setup(
    name="ckanext-sfbgroups",
    version="0.1.0",
    description="Choices helper para listar grupos CKAN no campo Projeto",
    packages=find_packages(),
    include_package_data=True,
    zip_safe=False,
    entry_points="""
        [ckan.plugins]
        sfbgroups=ckanext.sfbgroups.plugin:SfbGroupsPlugin
    """,
)
