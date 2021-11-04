#!/bin/bash
KEYSFILE="$HOME/.ssh/authorized_keys"
KEYSTEMP="$HOME/.ssh/authorized_keys.overwrite"
while :
do
    clear
    if [ ! -w "$KEYSFILE" ]; then
        echo "Authorized keys [$KEYSFILE] file does not exist. It will be created upon save."
    else
        readarray -t KEYSDATA < "$KEYSFILE"
        echo "List of authorized keys [$KEYSFILE]:"
        echo
        COUNTER=0
        for LINE in "${KEYSDATA[@]}"; do
            ((COUNTER++))
            if (( ${#LINE} > 100 )); then
                START=${LINE:0:50}
                END=${LINE:(-50)}
                echo "$COUNTER: $START...$END"
            else
                echo "$COUNTER: $LINE"
            fi
        done
        echo
        echo "-------------------------------------"
    fi
    echo
    echo "1: Add new key"
    echo "2: Delete an existing key"
    echo "3: Exit"
    echo
    read -p "Select option: " MENU
    if [ "$MENU" == "1" ]; then
        read -s -p "Enter new public key: " NEWKEY
        echo
        echo
        echo $NEWKEY
        echo
        read -p "Are you sure you would like to add this key? [y/N]" SURE
        if [ "$SURE" == "y" ]; then
            touch "$KEYSFILE"
            echo "$NEWKEY" >> "$KEYSFILE"
            echo "Key has been added!";
            sleep 2
        fi
    elif [ "$MENU" == "2" ]; then
        read -p "Select key to delete: " DELKEY
        DELKEY=$((DELKEY - 1))
        if ((DELKEY < 0 || DELKEY >= ${#KEYSDATA[@]})); then
            echo "Invalid key number."
            sleep 2
        else
            echo
            echo ${KEYSDATA[$DELKEY]}
            echo
            read -p "Delete this key? [y/N] " CONFIRMDELETE
            if [ "$CONFIRMDELETE" == "y" ]; then
                unset KEYSDATA[$DELKEY]
                for LINE in "${KEYSDATA[@]}"; do
                    echo "$LINE" >> "$KEYSTEMP"
                done
                mv -f "$KEYSTEMP" "$KEYSFILE"
                echo "Key has been deleted!";
                sleep 2
            fi
        fi
    elif [ "$MENU" == "3" ]; then
        echo "Exiting..."
        exit
    else
        echo "Invalid option"
        sleep 2
    fi
done