from setuptools import setup, find_packages

with open("README.md", encoding="utf-8") as f:
    long_description = f.read()

setup(
    name="lab_core",
    version="0.0.1",
    description="LabProject core Frappe app",
    author="Montek Devs",
    author_email="dev@montek.dev",
    packages=find_packages(),
    zip_safe=False,
    include_package_data=True,
    install_requires=[],
)
