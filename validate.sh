# Takes in violation CSV in specified format, and outputs CSV with only
# validated entries. Entries are validated if:
# - the test successfully runs
# - the test output is deterministic for TEST_RUN runs (current: 5)
# - the test output violates the specified property in the input csv
#
# An appropriate error message will be output for every input entry that cannot 
# be validated.

TEST_RUN=5

#csv: project, project url, prop, test directory, test file, classification, notes
INPUT_VIOS=$1

NAME="validate"
bash make_dockerfile_full.sh ${NAME}

