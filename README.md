# RV-Violation-DB  

### About
The rv-violation-db repo is a database of Runtime Verification violations that were found using the JavaMop tool on open-source projects. It is designed to be a replicable database that provides users an easy way to investigate a consistent set of existing violations found with JavaMop. 

### Prerequisites
Because this project is designed to be a replicable database, it is important to ensure consistency among. 

Users should have some version of Docker Desktop installed.

### How to Get Started
To setup your environment for inspecting projects there are a few steps required on the user's end.

Below are instructions while running in a Linux Shell.

Run the following commands to start the docker environment: 
1. Start the docker service (`service docker start`)
2. `docker build -t rv-db:latest -< javamopEnv`
3. `docker run -it rv-db:latest`

To get started inspecting data:
1. Run: `bash install-repos.sh` which will get the existing repos that our database curates.



