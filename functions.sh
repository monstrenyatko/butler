
# Load variables from file if not already set
# Usage: load_env FILE
load_env() {
	local file="$1"
	while read -r line || [ -n "$line" ]; do
		if [ -n "$line" ] && [[ ! "$line" =~ ^\s*# ]]; then
			env_name=$(echo "$line" | cut -d "=" -f 1)
			if [ -z "${!env_name}" ]; then
				export "$line"
			fi
		fi
	done < $file
}
