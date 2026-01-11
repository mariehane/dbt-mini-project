# DBT Mini-Project
A mini-project showcasing DBT + Snowflake for ELT on MIMIC-IV.

## Usage
* `dbt build` -> build and test the data in Snowflake.
* `dbt docs generate`/`dbt docs serve` -> build and view the documentation.

## Structure
```
dbt_mini_project/
├── models/
│   ├── intermediate/          # Intermediate transformations
│   │   ├── int_antibiotics.sql
│   │   ├── int_hourly_events.sql
│   │   └── int_hourly_events_by_level2.sql
│   └── staging/
│       └── mimiciv/
│           ├── core/          # Patient database staging (3 models)
│           ├── hosp/          # Hospital data staging (15 models)
│           └── icu/           # ICU data staging (7 models)
├── seeds/                     # Static CSV data files
│   ├── item_map_chartevents.csv
│   ├── item_map_dascena_epic.csv
│   └── item_map_epic.csv
├── dbt_project.yml            # Main dbt configuration
├── packages.yml               # dbt package dependencies
└── README.md
```
