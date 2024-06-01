#!/bin/bash

name=$(basename `git rev-parse --show-toplevel`)
ver=$( git describe --tags --always --abbrev=0 )
desc=$(git tag -n40 --format='%(contents)' $ver)

echo -ne "# ${name}\n\n## ${ver}\n\n${desc}" > "CHANGELOG.md"