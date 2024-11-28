#!/usr/bin/env bash
#----------------------------------------------------------
# syno_archive_extractor.sh by 007revad
# https://github.com/007revad/Synology_Archive_Extractor
#----------------------------------------------------------
# Requires sae.py 1.0 by K4L0
# https://github.com/K4L0dev/Synology_Archive_Extractor
#----------------------------------------------------------
# SYSTEM= 0,             # System
# NANO= 1,               # Nano
# JSON= 2,               # SecurityJson
# SPK= 3,                # SPK
# SYNOMIBCOLLECTOR= 4,   # Syno MIB Collector
# SSDB= 5,               # Security Scan DB
# AUTOUPDATE= 6,         # Auto Update
# FIRMWARE= 7,           # Drive Firmware
# DEV= 8,                # /var/packages/syno_dev_token
# WEDJAT= 9,             # Wedjat  https://xpenology.com/forum/topic/68080-synology-backdoor/
# DSM_SUPPORT_PATCH= 10, # DSM Support Patch
# SMALL= 11              # Small Patch
#----------------------------------------------------------

# Edit these 3 variables to suit your folder locations

# Location of the folder containing the files to extract
inpath="/volume1/temp/in"

# Location of the folder extract to
outpath="/volume1/temp/out"

# Location of the sae.py script
#pyscript="/bin/sae.py"
pyscript="/volume1/scripts/sae/sae.py"

#----------------------------------------------------------

# Check script is running as root
if [[ $( whoami ) != "root" ]]; then
    echo "This script must be run as root or sudo."
    exit
fi

# Check sae.py exists
if [[ -f "$pyscript" ]]; then
    # Make sure sae.py script is executable
    if ! chmod a+x "$pyscript"; then
        echo "Failed to set sae.py as executable!"
        exit
    fi
else
    echo "$pyscript not found!"
    exit
fi

# Check inpath and outpath directories exist
if [[ ! -d "${inpath}" ]]; then
    echo "Directory not found! ${inpath}"
    exit
fi
if [[ ! -d "${outpath}" ]]; then
    echo "Directory not found! ${outpath}"
    echo "Do you want to create it? [y/n]"
    read -r answer
    if [[ ${answer,,} == y ]]; then
        mkdir "${outpath}"
    else
        exit
    fi
fi


errtype(){ 
    case "$1" in
        1) echo "Error $1": ERR_OPEN_ARCHIVE_FAILED >&2 ;;
        2) echo "Error $1": ERR_READ_VERSION >&2 ;;
        3) echo "Error $1": ERR_READ_HEADER_LEN >&2 ;;
        4) echo "Error $1": ERR_READ_HEADER >&2 ;;
        5) echo "Error $1": ERR_SODIUM_INIT_FAILED >&2 ;;
        6) echo "Error $1": ERR_INVALID_FORMAT >&2 ;;
        7) echo "Error $1": ERR_INVALID_VERSION >&2 ;;
        8) echo "Error $1": ERR_INVALID_HEADER >&2 ;;
        9) echo "Error $1": ERR_INVALID_HEADER_MSGUNPACK >&2 ;;
        10) echo "Error $1": ERR_INVALID_HEADER_OBJECT_TYPE >&2 ;;
        11) echo "Error $1": ERR_INVALID_HEADER_UUID_TYPE >&2 ;;
        12) echo "Error $1": ERR_INVALID_HEADER_UUID_SIZE >&2 ;;
        13) echo "Error $1": ERR_CREATE_ENTRY_KEY >&2 ;;
        14) echo "Error $1": ERR_INVALID_SIGNATURE >&2 ;;
        15) echo "Error $1": ERR_READ_NEW_FAILED >&2 ;;
        16) echo "Error $1": ERR_WRITE_DISK_NEW_FAILED >&2 ;;
        17) echo "Error $1": ERR_FILEPATH >&2 ;;
        18) echo "Error $1": ERR_FILE_NOT_FOUND >&2 ;;
        19) echo "Error $1": ERR_HEADER_EXCEED_MAX >&2 ;;
        20) echo "Error $1": ERR_UNKNOWN_KEY_TYPE >&2 ;;
        21) echo "Error $1": ERR_EXPIRED >&2 ;;
        22) echo "Error $1": ERR_SERIALNUM_MISMATCH >&2 ;;
        23) echo "Error $1": ERR_OPEN_FILE >&2 ;;
        *) return ;;
    esac
}


extract(){ 
    # $1 is archive type
    # $2 is archive /path/file
    echo -e "\n$file" >&2

    if [[ ! -d "${outpath}/$filename" ]]; then
        mkdir "${outpath}/$filename"
    fi

    if [[ -d "${outpath}/$filename" ]]; then
        if [[ "$(ls -A "${outpath}/$filename")" ]]; then
            #echo -e "Skipping non-empty directory: \n${outpath}/$filename"
            echo "Skipping non-empty directory: ${outpath}/$filename" >&2
        else
            # Run sae.py and capture it's stdout
            echo "---------------------------------------"
            returned="$(python3 "$pyscript" -k "$1" -a "$2" -d "${outpath}/$filename")"

            # Show sae.py's stdout (without True or False)
            echo "$returned" | sed -E '/False|True/d'

            retcode="$(echo "$returned" | grep errno | awk '{print $(NF-0)}' | cut -d")" -f1)"
            if [[ $retcode -gt "0" ]]; then
                # Show error type if there was an error
                errtype "$retcode"
            else
                echo "Extracted ok" >&2
            fi
        fi
    else
        echo "Directory not found! ${outpath}/$filename" >&2
    fi
}


for archive in "${inpath}"/*; do
    if [[ -f "$archive" ]]; then
        file="$(basename -- "$archive")"
        filename="${file%.*}"
        extension="${archive##*.}"
        prefix="${filename%%_*}"

        if [[ $extension == "pat" ]]; then
            case ${prefix,,} in
                dsm)
                    extract SYSTEM "$archive" ;;
                dsmuc)
                    extract SYSTEM "$archive" ;;
                bsm)
                    extract SYSTEM "$archive" ;;
                synology)
                    extract NANO "$archive" ;;
    #            vs*hd)                            # test
    #                extract SYSTEM "$archive" ;;  # test
                *)
                    continue ;;
            esac
        elif [[ $extension == "spk" ]]; then
            if [[ $archive =~ [Ww]edjat.*\.sa\.spk ]]; then
                # Wedjat-geminilake-1.0.3-00031.sa.spk
                extract WEDJAT "$archive"
            else
                extract SPK "$archive"
            fi
        elif [[ $extension == "sa" ]]; then
            extract FIRMWARE "$archive"
        elif [[ $extension == "json" ]]; then
            extract JSON "$archive"
        elif [[ $archive == "syno_dev_token" ]]; then
            extract DEV "$archive"
        fi
    fi
done

