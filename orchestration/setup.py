from setuptools import find_packages, setup

setup(
    name="orchestration",
    packages=find_packages(exclude=["orchestration_tests"]),
    install_requires=[
        "dagster",
        "dagster-cloud",
        "dagster-postgres",
        "dagster-dbt",
        "dbt-postgres",
        "geopandas",
        "kaleido",
        "pandas[parquet]",
        "pandas",
        "plotly",
        "shapely",
        "smart_open[s3]",
        "s3fs",
        "smart_open",
        "boto3",
        "pyarrow",
        "confluent_kafka",
        "faker",
        "dotenv"
    ],
    extras_require={"dev": ["dagster-webserver", "pytest"]},
)
