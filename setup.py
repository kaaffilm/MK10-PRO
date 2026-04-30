# Minimal setup.py for backwards compatibility
# All configuration is in pyproject.toml
from setuptools import setup

setup(
    include_package_data=True,
    package_data={
        "mtb": ["schema/*.json"],
        "engine": ["policy/*.yaml", "formats/dcp/*.yaml"],
    },
)
