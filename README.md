# RV-Violation-DB  

### About
The rv-violation-db repo is a database of Runtime Verification violations that were found using the JavaMop tool on open-source projects. It is designed to be a replicable database that provides users an easy way to investigate a consistent set of existing violations found with JavaMop. 

### Prerequisites
Because this project is designed to be a replicable database, it is important to ensure consistency among. 

Users should have some version of Docker Desktop installed.

### How to Get Started

Below are instructions while running in a Linux Shell:

`bash repro_full.sh <options>`

If no selection options are specified, all violations will be run.


optional flags:

`--repo-slug <SLUG>` run all violations associated with repo slug `SLUG`

`--violation-id <ID>` run all violations associated with violation ID `ID`

`--prop-file <PROP>` run all violations associated with JavaMOP property `PROP`

`--all` run all violations


`--num-reruns <NUM>` maximum number of times to rerun the test associated with each violation during validation (if --no-validate is specified, 
each violation test will be run `NUM` times).

`--no-validate` disables validation step (on by default)


`--image-name <NAME>` create a Docker image with name `NAME` (default: `<SELECTION-FLAG>-<SELECTION-OPTION>`, i.e. "violation-id-4")

`--no-cache` disables caching during Docker image build (Docker environment will be completely rebuilt)


`--usage` display usage information
