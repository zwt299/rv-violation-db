#!bin/bash
function usage() {
    cat <<USAGE
    Usage: $0 --violation-id [id]

    Options:
        --repo-id [id]:            find all violations of a given repo ID [id]
        --violation-id [id]:       find a given violation ID [id]
        --prop-file [prop-file]:   find all violations for a given prop-file

USAGE
    exit 1
}

