from setuptools import setup, find_packages

with open("README.md", "r", encoding="utf-8") as fh:
    long_description = fh.read()

with open("VERSION", "r", encoding="utf-8") as fh:
    version = fh.read().strip()

setup(
    name="mk10-pro",
    version=version,
    author="MK10-PRO",
    description="Deterministic Pre-Delivery Truth Infrastructure",
    long_description=long_description,
    long_description_content_type="text/markdown",
    packages=find_packages(),
    classifiers=[
        "Development Status :: 4 - Beta",
        "Intended Audience :: Developers",
        "License :: OSI Approved :: MIT License",
        "Programming Language :: Python :: 3",
        "Programming Language :: Python :: 3.9",
        "Programming Language :: Python :: 3.10",
        "Programming Language :: Python :: 3.11",
    ],
    python_requires=">=3.9",
    install_requires=[
        "pyyaml>=6.0",
        "click>=8.0",
        "jsonschema>=4.0",
        "cryptography>=41.0",
        "pycryptodome>=3.19.0",
        "lxml>=4.9.0",
        "xmlschema>=2.0.0",
        "python-dateutil>=2.8.0",
        "pytz>=2023.3",
    ],
    entry_points={
        "console_scripts": [
            "mk10=cli.mk10:main",
        ],
    },
)

