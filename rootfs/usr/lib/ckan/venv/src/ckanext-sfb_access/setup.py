from setuptools import setup, find_packages

setup(
    name="ckanext-sfb-access",
    version="0.0.1",
    description="SFB dataset visibility by GRUPO + ACESSO (IPermissionLabels)",
    packages=find_packages(),
    include_package_data=True,
    zip_safe=False,
    entry_points="""
        [ckan.plugins]
        sfb_access=ckanext.sfb_access.plugin:SfbAccess
    """,
)
