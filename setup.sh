#!/bin/bash
declare -A RENAME

# Rename all "example-me" below to your own plugin name.
# Be sure to leave all array key indexes named as-is!!
RENAME[plugin-name]="example-me"
RENAME[plugin_name]="example_me"
RENAME[Plugin_Name]="Example_Me"
RENAME[PLUGIN_NAME_]="EXAMPLE_ME_"
RENAME[WordPress Plugin Boilerplate webpack]="Example Me"

###
# Loops over RENAME array and search/replaces the key for the value
# Example: plugin-name --> example-me
for K in "${!RENAME[@]}"; do
    git grep -l "$K" | xargs sed -i "s/$K/${RENAME[$K]}/g"
done

# Find and rename all files with "plugin-name" in the filename to the value specificed in RENAME[plugin-name]
find . -maxdepth 4 -type f -name "*plugin-name*.*" | while read FNAME; do mv "$FNAME" "${FNAME//plugin-name/${RENAME[plugin-name]}}"; done
