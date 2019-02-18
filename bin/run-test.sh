#!/bin/bash

exercise="$1"
results="$(pwsh -WorkingDirectory "$exercise" -Command 'Invoke-Pester' | tee /dev/tty)"
failures="$(grep -oP '(?<=Failed: )[[:digit:]]+' <<< "$results")"
exit "$failures"
