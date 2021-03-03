#!/bin/bash

declare -A RENAME
declare PLUGIN_NAME
declare INSTRUCTIONS

# Colors for pretty output
CYAN='\033[0;36m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

INSTRUCTIONS=0

function getName() {

	if [ "$INSTRUCTIONS" -eq 0 ]; then
		echo ''
		echo -e "${YELLOW}Please provide a name for your plugin. The name can contain letters, numbers, spaces, and dashes/underscores:${NC}"
		echo ''
		INSTRUCTIONS=1
	fi

	read PLUGIN_NAME

	# Ensure we have a string
	if [ -z "$PLUGIN_NAME" ]; then
		echo 'Please enter a name.'
		getName
	fi

	# Ensure string contains only a-z, A-Z, 0-9, spaces, dashes, underscores
	if [[ "$PLUGIN_NAME" =~ [^a-zA-Z0-9_\ \-] ]]; then
		echo 'Contains invalid characters. Name can only contain letters, numbers, spaces, and dashes or underscores.'
		getName
	fi

	# Ensure the first character is NOT a digit
	if [[ $PLUGIN_NAME == [0-9]* ]]; then
		echo 'Name cannot start with a number.'
		getName
	fi
}

# Fetch the name from the user. Repeats the request until a valid name is entered.
getName

nameTitleCase=$(echo "$PLUGIN_NAME" | sed -e 's/.*/\L&/' -e 's/[a-z]*/\u&/g')

# Using a name "My Cool PLUGIN" for example:
RENAME["plugin-name"]=$(echo "${PLUGIN_NAME,,}" | sed -e 's/[\ _]/\-/g')                          # "My Cool PLUGIN" --> "my-cool-plugin"
RENAME["plugin_name"]=$(echo "${PLUGIN_NAME,,}" | sed -e 's/[\ -]/_/g')                           # "My Cool PLUGIN" --> "my_cool_plugin"
RENAME["Plugin_Name"]=$(echo "${nameTitleCase}" | sed -e 's/[\ -]/_/g')                           # "My Cool PLUGIN" --> "My_Cool_Plugin"
RENAME["PLUGIN_NAME_"]=$(echo "${PLUGIN_NAME^^}" | sed -e 's/[\ -]/_/g')                          # "My Cool PLUGIN" --> "MY_COOL_PLUGIN_"
RENAME["wordpress-plugin-boilerplate-webpack"]=$(echo "${PLUGIN_NAME,,}" | sed -e 's/[\ _]/\-/g') # "My Cool PLUGIN" --> "my-cool-plugin"
RENAME["WordPress Plugin Boilerplate webpack"]=${PLUGIN_NAME}                                     # "My Cool PLUGIN" (no change)

echo ''
echo -e "${YELLOW}If you proceed, the following defaults will be renamed:${NC}"
echo ''

###
# Loops over RENAME array and search/replaces the key for the value
# Example: plugin-name --> example-me
for K in "${!RENAME[@]}"; do
	echo -e "${CYAN}$K${NC} to ${GREEN}${RENAME[$K]}${NC}"
done

echo ''
echo 'After renaming these strings within files, and in the filenames themselves wherever they appear, this script will:'
echo '1. Remove the .git folder'
echo '2. Remove .gitignore, CHANGELOG.md, README.md'
echo '3. Remove itself (self-deleting script)'
echo ''
echo -e "${YELLOW}Enter Y to continue, enter anything else to cancel.${NC}"

read CHOICE

if [ "${CHOICE}" == "Y" ]; then

	###
	# Loops over RENAME array and search/replaces the key for the value
	# Example: plugin-name --> example-me
	for K in "${!RENAME[@]}"; do
		echo -e "Renaming strings ${CYAN}$K${NC} to ${GREEN}${RENAME[$K]}${NC} in files."
		git grep -l "$K" | xargs sed -i "s/$K/${RENAME[$K]}/g"
	done

	# Find and rename all files with "plugin-name" in the filename to the value specificed in RENAME[plugin-name]
	echo -e "Renaming strings in filenames ${CYAN}$K${NC} to ${GREEN}${RENAME[$K]}${NC}"
	find . -maxdepth 4 -type f -name "*plugin-name*.*" | while read FNAME; do mv "$FNAME" "${FNAME//plugin-name/${RENAME["plugin-name"]}}"; done

	# Remove .git files
	echo 'Removing .git...'
	rm -R ./.git
	echo 'Removing .gitignore'
	rm ./.gitignore
	echo 'Removing CHANGELOG.md'
	rm ./CHANGELOG.md
	echo 'Removing README.md'
	rm ./README.md

	# Remove this script...
	echo 'Removing self...'
	rm -- "$0"

	echo -e "${GREEN}DONE! Happy coding.${NC}"
fi

exit
