#!bin/bash
echo Number of unique repositories/sha combinations:
cat data/repo-data.csv | cut -d, -f2 | sort -u | wc -l 

echo Number of unique specifications represented:
cat data/violation-spec-map.csv | cut -d, -f2 | sort -u | wc -l

echo Number of truebugs:
cat data/violation-spec-map.csv | cut -d, -f7 | grep Truebug | wc -l

echo Number of falsealarms:
cat data/violation-spec-map.csv | cut -d, -f7 | grep Falsealarm | wc -l

echo Number of hardtoinspect:
cat data/violation-spec-map.csv | cut -d, -f7 | grep HardToInspect | wc -l

echo Number of violations:
cat data/violation-spec-map.csv | wc -l