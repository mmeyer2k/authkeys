#!/bin/bash

KEYSFILE="$HOME/.ssh/authorized_keys"
KEYSTEMP="$HOME/.ssh/authorized_keys.overwrite"

while :
do

    if [ ! -w "$KEYSFILE" ]; then
        echo "Authorized keys [$KEYSFILE] file does not exist. It will be created upon save."
    else
        readarray -t KEYSDATA < "$KEYSFILE"

        echo "List of authorized keys [$KEYSFILE]:"

        COUNTER=0

        for LINE in "${KEYSDATA[@]}"; do
            ((COUNTER++))
            echo "$COUNTER: $LINE"
        done

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
        echo $NEWKEY
        read -p "Are you sure you would like to add this key? [y/N]" SURE
        if [ "$SURE" == "y" ]; then
            touch "$KEYSFILE"
            echo "$NEWKEY" >> "$KEYSFILE"
            echo "New key added!"
        fi
    elif [ "$MENU" == "2" ]; then
        read -p "Select key to delete: " DELKEY
        DELKEY=$((DELKEY - 1))
        echo
        echo ${KEYSDATA[$DELKEY]}
        echo
        read -p "Delete this key? [y/N] " CONFIRMDELETE
        unset KEYSDATA[$DELKEY]

        for LINE in "${KEYSDATA[@]}"; do
            echo "$LINE" >> "$KEYSTEMP"
        done

        mv -f "$KEYSTEMP" "$KEYSFILE"
        echo "Key successfully deleted!"
    elif [ "$MENU" == "3" ]; then
        echo "Exiting..."
        exit
    else
        echo "Invalid option"
    fi
done