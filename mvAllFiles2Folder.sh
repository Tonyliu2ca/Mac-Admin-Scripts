#!/bin/bash

append="copy-"
overwrite=false
deleteFolder=false
verboaseMode=false

ScriptName="$(basename "$0")"
showHELP()
{
    /bin/cat << EOF
Move all files in folder A and its subfolder(s) to another folder B

Usage:  $ScriptName [-h] [-o|-d|-v] -a <folder> -b <folder> [-p <string>]
    -h               Show this help
    -o               Overwrite existing file
    -a <folder A>    FQP (Fully Qualified Path or absolute path) of source folder A
    -b <folder B>    FOP (fully qualified path or absolute path) of target folder B
    -p <string>      Appendix adding to duplicate/existing filename
                     default is "copy-"
    -d               Delete Fodler A after moved, default is No
    -v               Verbose mode
EOF
exit 0
}

moveFile()
{
    local sourFile="$1"
    local destFolder="$2"

    filename="$(basename "$sourFile")"
    [ "$filename" = "." ] && return
    [ "$filename" = ".." ] && return
    fName="${filename%.*}"
    eName="${filename##*.}"
    [ "$filename" = "$fName" ] && eName=""
    [ -z "$fName" ] && [ -z "$eName" ] && return
    if [ -z "$fName" ]; then fName=".$eName"; eName=""; fi
    [ -n "$eName" ] && eName=".${eName}"
    [ "${filename:0-1}" = "." ] && eName="."
    local dupName=""
    # [ ! $overwrite ] && echo "Yes =$overwrite" || echo "No =$overwrite"
    if ! $overwrite; then 
#    echo " ---- [$filename] = [$fName] [$eName]"
        if [ -e "${destFolder}/${fName}${eName}" ]; then
            local i=0
            while true; do
                dupName="(${append}${i})"
                [ -e "${destFolder}/${fName}${dupName}${eName}" ] || break
                (( i++ ))
            done
        fi
    fi
    [ $verboaseMode ] && echo "moving [$sourFile] to [${destFolder}/${fName}${dupName}${eName}]"
    mv -f "$sourFile" "${destFolder}/${fName}${dupName}${eName}"
}

while getopts "ha:A:b:B:p:odv" opt; do
    case $opt in
        h)
            showHELP
            ;;
        a|A)
            sourFolder="$OPTARG"
            ;;
        b|B)
            destFolder="$OPTARG"
            ;;
        p)
            append="$OPTARG"
            ;;
        o)
            overwrite=true
            ;;
        d)
            deleteFolder=true
            ;;
        v)
            verboaseMode=true
            ;;
        *)
            showHELP
            ;;
    esac
done

[ -z "$destFolder" ] && showHELP
[ -z "$sourFolder" ] && showHELP
[ -d "$sourFolder" ] || showHELP
[ -d "$destFolder" ] || mkdir "$destFolder"

find "$sourFolder" -type f -print0 | while read -r -d '' eachFile; do
    moveFile "$eachFile" "$destFolder"
done
if $deleteFolder; then
    echo "deleting folder A: [$sourFolder]"
    rm -fr "$sourFolder"
fi
