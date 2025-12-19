#!/bin/bash

# Surf Browser Launcher with Rofi and History
# Usage: ./surf-launcher.sh [url]

HISTORY_FILE="$HOME/.surf_history"
MAX_HISTORY=1000

# Create history file if it doesn't exist
touch "$HISTORY_FILE"

# Function to add URL to history
add_to_history() {
    local url="$1"
    # Remove duplicate if exists
    sed -i "\|^$url$|d" "$HISTORY_FILE"
    # Add to top of history
    echo "$url" | cat - "$HISTORY_FILE" | head -n "$MAX_HISTORY" > "$HISTORY_FILE.tmp"
    mv "$HISTORY_FILE.tmp" "$HISTORY_FILE"
}

# Function to launch surf
launch_surf() {
    local url="$1"
    
    # Add http:// if no protocol specified
    if [[ ! "$url" =~ ^https?:// ]] && [[ ! "$url" =~ ^file:// ]]; then
        # Check if it looks like a domain
        if [[ "$url" =~ \. ]]; then
            url="https://$url"
        else
            # Treat as search query
            url="https://duckduckgo.com/?q=$(echo "$url" | sed 's/ /+/g')"
        fi
    fi
    
    add_to_history "$url"
    surf "$url" &
}

# Main logic
if [ $# -eq 0 ]; then
    # No arguments - show rofi menu
    
    # Create menu options
    {
        echo "🔍 Enter URL or Search..."
        echo "---"
        cat "$HISTORY_FILE" 2>/dev/null
    } > /tmp/surf_menu.txt
    
    # Show rofi menu
    selection=$(cat /tmp/surf_menu.txt | rofi -dmenu -i -p "Surf Browser" -mesg "Enter URL or search term")
    
    # Clean up temp file
    rm /tmp/surf_menu.txt
    
    # Exit if nothing selected
    [ -z "$selection" ] && exit 0
    
    # Skip separator and header
    if [ "$selection" = "🔍 Enter URL or Search..." ] || [ "$selection" = "---" ]; then
        # User selected the header, show input again
        selection=$(echo "" | rofi -dmenu -i -p "Surf Browser" -mesg "Enter URL or search term")
        [ -z "$selection" ] && exit 0
    fi
    
    launch_surf "$selection"
else
    # URL provided as argument
    launch_surf "$1"
fi
