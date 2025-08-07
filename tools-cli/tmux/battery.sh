#!/usr/bin/env bash

# Cross-platform battery status script for tmux
# Returns battery percentage with color coding based on Tokyo Night theme

get_battery_percentage() {
    local battery_percentage
    
    # macOS
    if command -v pmset >/dev/null 2>&1; then
        battery_percentage=$(pmset -g batt | grep -Eo "[0-9]+" | head -1)
    # Linux with acpi
    elif command -v acpi >/dev/null 2>&1; then
        battery_percentage=$(acpi -b | grep -Eo "[0-9]+" | head -1)
    # Linux with sys filesystem
    elif [ -f /sys/class/power_supply/BAT0/capacity ]; then
        battery_percentage=$(cat /sys/class/power_supply/BAT0/capacity)
    # Linux alternative battery paths
    elif [ -f /sys/class/power_supply/BAT1/capacity ]; then
        battery_percentage=$(cat /sys/class/power_supply/BAT1/capacity)
    else
        # No battery found or not supported
        echo ""
        exit 0
    fi
    
    echo "$battery_percentage"
}

get_battery_color() {
    local percentage=$1
    
    # Tokyo Night color scheme based on battery level
    if [ "$percentage" -lt 20 ]; then
        echo "#db4b4b"  # Red for critical (< 20%)
    elif [ "$percentage" -lt 40 ]; then
        echo "#e0af68"  # Yellow for low (20-39%)
    elif [ "$percentage" -lt 60 ]; then
        echo "#41a6b5"  # Cyan for medium (40-59%)
    else
        echo "#9ece6a"  # Green for good (60%+)
    fi
}

get_battery_icon() {
    local percentage=$1
    
    # Try to use battery glyphs, fall back to simple text if not supported
    if [ "$percentage" -lt 20 ]; then
        echo "🔋"  # Critical battery (or  if available)
    elif [ "$percentage" -lt 40 ]; then
        echo "🔋"  # Low battery
    elif [ "$percentage" -lt 60 ]; then
        echo "🔋"  # Medium battery  
    elif [ "$percentage" -lt 80 ]; then
        echo "🔋"  # High battery
    else
        echo "🔋"  # Full battery
    fi
}

main() {
    local percentage
    percentage=$(get_battery_percentage)
    
    # Exit if no battery found
    if [ -z "$percentage" ]; then
        exit 0
    fi
    
    local color
    color=$(get_battery_color "$percentage")
    
    local icon
    icon=$(get_battery_icon "$percentage")
    
    # Output formatted battery info for tmux
    printf "#[fg=%s]%s %s%%" "$color" "$icon" "$percentage"
}

main "$@"
