#!/bin/bash

failed=0
for exercise_directory in $(find ./* -type d); do
    tmpdir=$(mktemp -d)
    test_file="$(find "$exercise_directory" -type f -name '*.tests.ps1')"
    if [ -f "$test_file" ]; then
        solution_file="$(find "$exercise_directory" -type f -name '*.ps1' | grep -v tests)"
        echo "$solution_file"
        cp "$test_file" "$tmpdir"
        cp "$solution_file" "$tmpdir/$(basename "$solution_file")"
        results="$(pwsh -WorkingDirectory "$tmpdir" -Command 'Invoke-Pester' | tee /dev/tty)"
        rm -rf "$tmpdir"
        failures="$(grep -oP '(?<=Failed: )[[:digit:]]+' <<< "$results")"
        if [ "$failures" -ne '0' ]; then
            # echo "$(basename "$exercise_directory"): $failures failed tests."
            # exit 1
            failed="$(( failed + 1 ))"
        fi
    fi
done

echo "$failed failed exercises."
exit "$failed"
