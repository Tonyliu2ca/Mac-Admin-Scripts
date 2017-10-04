# ------------------------------------------------
# Version Compare:
#   compare two version strings, version numbers divided by period.
#   format: major.minor.modification.???...
#
# Input:
#   $1 (string): version 1
#   $2 (string): version 2
#
# Return:
#   0 = $1 = $2
#   1 = $1 > $2
#   2 = $1 < $2
# ------------------------------------------------
verComp()
{
	[[ "$1" == "$2" ]] && { echo "="; return 0; }
	local IFS=.; local i m v1=($1) v2=($2)
	[ "${#v1[@]}" -gt "${#v2[@]}" ] \
 && { for ((i=${#v2[@]}; i<${#v1[@]}; i++)); do v2[i]=0; done; m=${#v1[@]}; }\
 || { for ((i=${#v1[@]}; i<${#v2[@]}; i++)); do v1[i]=0; done; m=${#v2[@]}; }
	for ((i=0; i<m; i++)); do
		[ "${v1[i]}" -gt "${v2[i]}" ] && { echo ">"; return 1; }
		[ "${v1[i]}" -lt "${v2[i]}" ] && { echo "<"; return 2; }
	done
	echo "="; return 0
}
