#!/bin/bash

. ./vio_common.sh

# Takes in violation CSV in specified format, and outputs CSV with only
# validated entries. Entries are validated if:
# - the test successfully runs
# - the test output is deterministic for TEST_RUN runs (default: 5)
# - the test output violates the specified property in the input csv
#
# An appropriate error message will be output for every input entry that cannot 
# be validated.

#TODO: add number of test runs as a command line argument
DEFAULT_TEST_RUN=5

#csv: project, project url, prop, test directory, test file, test line number, classification, notes
# PROJECT_URL=$1
# SHA=$2
# PROP=$3
# TEST_DIRECTORY=$4
# TEST_FILE=$5
# TEST_LINE_NUMBER=$6

ENTRY_CSV=$1

# temp arg for testing
LINE_NUMBER=$2

function process_validation_entry() {
  IFS=","
  read -a entry_arr <<< $(sed -n "${LINE_NUMBER}p" $ENTRY_CSV)

  REPO="${entry_arr[1]}"
  SHA="${entry_arr[2]}"
  PROP="${entry_arr[3]}"
  TEST_DIR="${entry_arr[4]}"
  TEST="${entry_arr[5]}"
  TEST_LINE_NUMBER="${entry_arr[6]}"

  echo "$REPO,$SHA,$TEST_DIR,$TEST,$TEST_LINE_NUMBER"
  process
}

process_validation_entry