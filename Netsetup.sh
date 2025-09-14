#!/bin/bash
# AntisOS Network Connector
# Requires: iwd, dialog

tmpfile=$(mktemp)

# Scan for networks
iwctl station wlan0 scan
sleep 2
networks=$(iwctl station wlan0 get-networks | awk 'NR>4 {print $1}')

if [ -z "$networks" ]; then
    dialog --msgbox "No Wi-Fi networks found!" 8 40
    exit 1
fi

# Menu of networks
dialog --menu "Select a Wi-Fi network:" 20 60 10 $(
    for net in $networks; do echo "$net" "$net"; done
) 2>"$tmpfile"

choice=$(cat "$tmpfile")

if [ -n "$choice" ]; then
    dialog --insecure --passwordbox "Enter Wi-Fi password for $choice:" 10 50 2>"$tmpfile"
    pass=$(cat "$tmpfile")
    iwctl station wlan0 connect "$choice" -P "$pass" && \
        dialog --msgbox "Connected to $choice!" 8 40 || \
        dialog --msgbox "Failed to connect to $choice." 8 40
fi
