#!/bin/bash
set -u
FINGERPRINTMODE=false
KEYSFILE="$HOME/.ssh/authorized_keys"
KEYSTEMP="$KEYSFILE.overwrite"
KEYSHISTDIR="$KEYSFILE.history"
HORIZONTALSEPARATOR="--------------------------------------------------------------------------------"
while :
do
    clear
    KEYSHIST="$KEYSHISTDIR/$(date +%s)"
    if [ ! -w "$KEYSFILE" ]; then
        echo "Authorized keys [$KEYSFILE] file does not exist. It will be created upon save."
    else
        readarray -t KEYSDATA < "$KEYSFILE"
        echo "List of authorized keys [$KEYSFILE]:"
        echo $HORIZONTALSEPARATOR
        COUNTER=0
        for LINE in "${KEYSDATA[@]}"; do
            ((COUNTER++))
            if [ $FINGERPRINTMODE == true ]; then
                LINE=$(echo $LINE | ssh-keygen -lf - 2>&1)
            fi
            LINE="$COUNTER: $LINE"
            if (( ${#LINE} > 80 )); then
                START=${LINE:0:17}
                END=${LINE:(-60)}
                echo "$START...$END"
            else
                echo $LINE
            fi
        done
    fi
    echo $HORIZONTALSEPARATOR
    tput smul
    echo "Options menu:"
    tput sgr0
    echo "a: Add new key"
    echo "d: Delete an existing key"
    echo "f: Toggle fingerprint display"
    if [ -d $KEYSHISTDIR ]; then
        echo "p: Purge key history directory [$KEYSHISTDIR]"
    fi
    echo "q: Exit"
    echo
    read -p "Select option: " MENU
    if [ "$MENU" == "a" ]; then
        read -s -p "Enter new public key: " NEWKEY
        if ! (echo $NEWKEY | ssh-keygen -lf - 2>/dev/null 1>/dev/null); then
            echo
            echo "Not a valid public key!";
            sleep 2
            continue
        fi
        echo
        echo
        echo "$NEWKEY"
        echo
        echo "Fingerprint:"
        echo "$NEWKEY" | ssh-keygen -lf -
        echo
        read -p "Are you sure you would like to add this key? [y/N] " SURE
        if [ "$SURE" == "y" ]; then
            mkdir -p "$KEYSHISTDIR"
            cp "$KEYSFILE" "$KEYSHIST"
            echo "$NEWKEY" >> "$KEYSFILE"
            echo "Key has been added!";
            sleep 2
        fi
    elif [ "$MENU" == "d" ]; then
        read -p "Select key to delete: " DELKEY
        DELKEY=$((DELKEY - 1))
        if ((DELKEY < 0 || DELKEY >= ${#KEYSDATA[@]})); then
            echo "Invalid key number."
            sleep 2
            continue
        fi
        echo
        echo ${KEYSDATA[$DELKEY]}
        echo
        echo "Fingerprint:"
        echo "${KEYSDATA[$DELKEY]}" | ssh-keygen -lf -
        echo
        read -p "Delete this key? [y/N] " CONFIRMDELETE
        if [ "$CONFIRMDELETE" == "y" ]; then
            mkdir -p "$KEYSHISTDIR"
            cp "$KEYSFILE" "$KEYSHIST"
            unset KEYSDATA[$DELKEY]
            touch "$KEYSTEMP"
            for LINE in "${KEYSDATA[@]}"; do
                echo "$LINE" >> "$KEYSTEMP"
            done
            mv -f "$KEYSTEMP" "$KEYSFILE"
            echo "Key has been deleted!";
            sleep 2
        fi
    elif [ "$MENU" == "q" ]; then
        echo "Exiting..."
        exit
    elif [ "$MENU" == "p" ]; then
        read -p "Are you sure you want to purge the change history? [y/N] " CONFIRMDELETEHISTORY
        if [ "$CONFIRMDELETEHISTORY" == "y" ]; then
            rm -rf "$KEYSHISTDIR"
            echo "Key history cleared!"
            sleep 2
        fi
    elif [ "$MENU" == "f" ]; then
        if ( $FINGERPRINTMODE == true ); then
            FINGERPRINTMODE=false
        else
            FINGERPRINTMODE=true
        fi
    else
        echo "Invalid option!"
        sleep 2
    fi
done
