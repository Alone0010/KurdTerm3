#!/data/data/com.termux/files/usr/bin/bash

# ============================================================
# KurdTerm3 v3.0 — Created by TaQaNa
# Modern Mobile Dashboard
# Terminal UI uses English / ASCII only
# ============================================================

set -u

VERSION="3.0.0"
APP_NAME="KurdTerm3"
TAGLINE="Mobile Dev Platform"

# ------------------------------------------------------------
# Directories
# ------------------------------------------------------------

APP_HOME="$HOME/.kurdterm-v3"
CONFIG_FILE="$APP_HOME/config.conf"

# Load configuration
if [ -f "$CONFIG_FILE" ]; then
    source "$CONFIG_FILE"
fi

PLUGIN_DIR="$APP_HOME/plugins"

PROJECT_DIR="$HOME/KurdTerm-Pro-v3/projects"
BACKUP_DIR="$HOME/KurdTerm-Pro-v3/backups"

# ------------------------------------------------------------
# Terminal
# ------------------------------------------------------------

ESC=$'\033'

RESET="${ESC}[0m"
BOLD="${ESC}[1m"
DIM="${ESC}[2m"

GREEN="${ESC}[32m"
BRIGHT_GREEN="${ESC}[92m"
CYAN="${ESC}[36m"
BRIGHT_CYAN="${ESC}[96m"
YELLOW="${ESC}[33m"
RED="${ESC}[31m"
WHITE="${ESC}[37m"
GRAY="${ESC}[90m"

# ------------------------------------------------------------
# Basic helpers
# ------------------------------------------------------------

clear_screen() {
    printf '\033c'
}

pause_screen() {
    echo
    read -r -p "Press ENTER to continue..." _
}

command_exists() {
    command -v "$1" >/dev/null 2>&1
}

divider() {
    printf '%*s\n' "${1:-58}" '' | tr ' ' '-'
}

print_ok() {
    echo -e "${GREEN}[OK]${RESET} $*"
}

print_warn() {
    echo -e "${YELLOW}[WARN]${RESET} $*"
}

print_error() {
    echo -e "${RED}[ERROR]${RESET} $*"
}

# ------------------------------------------------------------
# Setup
# ------------------------------------------------------------

setup_directories() {
    mkdir -p "$APP_HOME"
    mkdir -p "$PLUGIN_DIR"
    mkdir -p "$PROJECT_DIR"
    mkdir -p "$BACKUP_DIR"
}

# ------------------------------------------------------------
# Terminal width
# ------------------------------------------------------------

get_width() {
    local width

    width=$(tput cols 2>/dev/null || echo 60)

    if [ "$width" -lt 50 ]; then
        width=50
    fi

    if [ "$width" -gt 80 ]; then
        width=80
    fi

    echo "$width"
}

# ------------------------------------------------------------
# Logo
# ------------------------------------------------------------

show_logo() {
    local width
    width=$(get_width)

    echo
    echo -e "${BRIGHT_GREEN}${BOLD}"
    echo "  K U R D T E R M 3"
    echo -e "${RESET}${DIM}  Modern Mobile Dev Platform${RESET}"
    echo -e "${CYAN}  Created & Maintained by TaQaNa${RESET}"
    echo -e "${GRAY}  Version $VERSION${RESET}"
    echo -e "${GRAY}  Copyright © 2026 TaQaNa${RESET}"
    echo

    divider "$width"
}

# ------------------------------------------------------------
# Loading screen
# ------------------------------------------------------------

loading_screen() {
    clear_screen

    echo
    echo -e "${BRIGHT_GREEN}${BOLD}Starting $APP_NAME...${RESET}"
    echo

    printf "  Loading "

    for _ in 1 2 3 4 5; do
        printf "."
        sleep 0.08
    done

    echo " 100%"
    echo

    sleep 0.15

    print_ok "System ready."
    sleep 0.3
}

# ------------------------------------------------------------
# System information
# ------------------------------------------------------------

get_cpu_usage() {
    if [ -r /proc/loadavg ]; then
        awk '{print $1}' /proc/loadavg
    else
        echo "N/A"
    fi
}

get_memory_info() {
    if [ -r /proc/meminfo ]; then
        awk '
        /MemTotal/ {
            total=$2
        }

        /MemAvailable/ {
            available=$2
        }

        END {
            if (total > 0) {
                used=total-available
                printf "%.0f MB / %.0f MB", used/1024, total/1024
            } else {
                print "N/A"
            }
        }' /proc/meminfo
    else
        echo "N/A"
    fi
}

get_storage_info() {
    df -h "$HOME" 2>/dev/null |
        awk 'NR==2 {print $3 " / " $2}'
}

get_network_status() {
    if command_exists ping; then
        if ping -c 1 -W 2 1.1.1.1 >/dev/null 2>&1; then
            echo "CONNECTED"
        else
            echo "OFFLINE"
        fi
    else
        echo "UNKNOWN"
    fi
}

# ------------------------------------------------------------
# Status indicator
# ------------------------------------------------------------

status_dot() {
    local status="$1"

    case "$status" in
        "OK"|"CONNECTED")
            echo -e "${BRIGHT_GREEN}●${RESET}"
            ;;

        "WARN"|"UNKNOWN")
            echo -e "${YELLOW}●${RESET}"
            ;;

        "ERROR"|"OFFLINE")
            echo -e "${RED}●${RESET}"
            ;;

        *)
            echo -e "${GRAY}●${RESET}"
            ;;
    esac
}

# ------------------------------------------------------------
# Modern card
# ------------------------------------------------------------

card() {
    local title="$1"
    local value="$2"
    local subtitle="$3"

    echo -e "${CYAN}┌──────────────────────────────┐${RESET}"
    printf "${CYAN}│${RESET} ${BOLD}%-28s${RESET} ${CYAN}│${RESET}\n" "$title"
    printf "${CYAN}│${RESET} ${BRIGHT_GREEN}%-28s${RESET} ${CYAN}│${RESET}\n" "$value"
    printf "${CYAN}│${RESET} ${DIM}%-28s${RESET} ${CYAN}│${RESET}\n" "$subtitle"
    echo -e "${CYAN}└──────────────────────────────┘${RESET}"
}

# ------------------------------------------------------------
# Dashboard
# ------------------------------------------------------------

dashboard() {
    while true; do
        clear_screen

        local width
        width=$(get_width)

        show_logo

        echo
        echo -e "${BOLD}Good day.${RESET}"
        echo -e "${DIM}Your workspace is ready.${RESET}"
        echo

        echo -e "${BRIGHT_CYAN}${BOLD}SYSTEM OVERVIEW${RESET}"
        divider "$width"

        echo

        local cpu ram storage network
        cpu=$(get_cpu_usage)
        ram=$(get_memory_info)
        storage=$(get_storage_info)
        network=$(get_network_status)

        echo -e "  CPU        : ${BOLD}${cpu}${RESET}"
        echo -e "  RAM        : ${BOLD}${ram}${RESET}"
        echo -e "  STORAGE    : ${BOLD}${storage}${RESET}"
        echo -e "  NETWORK    : ${BOLD}${network}${RESET}"

        echo

        if [ "$network" = "ONLINE" ]; then
            echo -e "  ${BRIGHT_GREEN}●${RESET} System status: ${BRIGHT_GREEN}HEALTHY${RESET}"
        else
            echo -e "  ${BRIGHT_YELLOW}●${RESET} System status: ${BRIGHT_YELLOW}OFFLINE${RESET}"
        fi

        echo
        echo -e "${BRIGHT_CYAN}${BOLD}QUICK TOOLS${RESET}"
        divider "$width"
        echo

        echo "  [1] Tools"
        echo "  [2] Files"
        echo "  [3] Developer"
        echo "  [4] AI"
        echo "  [5] Projects"
        echo "  [6] Backup"
        echo "  [7] Doctor"
        echo "  [8] Settings"
        echo "  [0] Main Menu"

        echo
        read -rp "Select: " choice

        case "$choice" in
            1)
                tool_center
                ;;
            2)
                file_center
                ;;
            4)
                clear_screen
                show_logo

                echo -e "${BRIGHT_GREEN}Listening Ports${RESET}"
                divider
                echo

                found_ports=0

                if command_exists ss; then
                    TCP_PORTS=$(ss -lntH 2>/dev/null)

                    if [ -n "$TCP_PORTS" ]; then
                        echo -e "${BRIGHT_GREEN}TCP Listening:${RESET}"
                        echo
                        printf '%s\n' "$TCP_PORTS"
                        found_ports=1
                    fi

                    UDP_PORTS=$(ss -lnuH 2>/dev/null)

                    if [ -n "$UDP_PORTS" ]; then
                        echo
                        echo -e "${BRIGHT_GREEN}UDP Listening:${RESET}"
                        echo
                        printf '%s\n' "$UDP_PORTS"
                        found_ports=1
                    fi

                elif command_exists netstat; then
                    TCP_PORTS=$(netstat -lnt 2>/dev/null | tail -n +3)

                    if [ -n "$TCP_PORTS" ]; then
                        echo -e "${BRIGHT_GREEN}TCP Listening:${RESET}"
                        echo
                        printf '%s\n' "$TCP_PORTS"
                        found_ports=1
                    fi

                    UDP_PORTS=$(netstat -lnu 2>/dev/null | tail -n +3)

                    if [ -n "$UDP_PORTS" ]; then
                        echo
                        echo -e "${BRIGHT_GREEN}UDP Listening:${RESET}"
                        echo
                        printf '%s\n' "$UDP_PORTS"
                        found_ports=1
                    fi

                else
                    echo -e "${YELLOW}ss/netstat not found.${RESET}"
                    echo -e "${DIM}Install iproute2 for better port information:${RESET}"
                    echo "pkg install iproute2"
                    echo
                fi

                if [ "$found_ports" -eq 0 ]; then
                    echo
                    echo -e "${DIM}No listening ports found.${RESET}"
                    echo
                    echo "Start a local server, for example:"
                    echo "python -m http.server 8080"
                    echo
                    echo "Then run this option again."
                fi

                echo
                divider
                pause_screen
                ;;
            8)
                clear_screen
                show_logo

                echo -e "${BRIGHT_GREEN}Cleanup Stopped Records${RESET}"
                echo "----------------------------------------------"
                echo

                cleanup_server_registry

                echo
                echo "Server registry:"
                cat "$SERVER_REGISTRY" 2>/dev/null || true

                echo
                pause_screen
                ;;
            8)
                clear_screen
                show_logo

                echo -e "${BRIGHT_GREEN}Cleanup Stopped Records${RESET}"
                echo "----------------------------------------------"
                echo

                cleanup_server_registry

                echo
                echo "Server registry:"
                cat "$SERVER_REGISTRY" 2>/dev/null || true

                echo
                pause_screen
                ;;




            0)
                return


                ;;
            *)
                echo
                echo "[ERROR] Invalid option."
                sleep 1
                ;;
        esac
    done
}

tool_center() {
    while true; do
        clear_screen
        show_logo

        echo -e "${BRIGHT_CYAN}${BOLD}TOOL CENTER${RESET}"
        divider
        echo

        echo "  [1] Check installed tools"
        echo "  [2] Install basic tools"
        echo "  [3] Install developer tools"
        echo "  [4] Search packages"
        echo "  [5] Update packages"
        echo "  [6] Show PATH"
        echo "  [0] Back"
        echo

        read -r -p "  Select: " choice

        case "$choice" in

            1)
                clear_screen
                show_logo

                echo -e "${BOLD}Installed Tools${RESET}"
                divider
                echo

                local tools=(
                    git
                    python
                    node
                    npm
                    curl
                    wget
                    zip
                    unzip
                    tar
                    ssh
                    nano
                    vim
                )

                local tool

                for tool in "${tools[@]}"; do
                    if command_exists "$tool"; then
                        echo -e "  ${BRIGHT_GREEN}●${RESET} $tool"
                    else
                        echo -e "  ${RED}○${RESET} $tool"
                    fi
                done

                pause_screen
                ;;

            2)
                clear_screen
                show_logo

                echo "Installing basic tools..."
                echo

                if command_exists pkg; then
                    pkg install -y git curl wget nano unzip zip tar
                    print_ok "Basic tools installed."
                else
                    print_error "pkg command not found."
                fi

                pause_screen
                ;;

            3)
                clear_screen
                show_logo

                echo "Installing developer tools..."
                echo

                if command_exists pkg; then
                    pkg install -y git python nodejs openssh
                    print_ok "Developer tools installed."
                else
                    print_error "pkg command not found."
                fi

                pause_screen
                ;;

            4)
                clear_screen
                show_logo

                read -r -p "Package name: " package_name

                if [ -n "$package_name" ] && command_exists pkg; then
                    pkg search "$package_name"
                else
                    print_error "Invalid package name or pkg unavailable."
                fi

                pause_screen
                ;;

            5)
                clear_screen
                show_logo

                if command_exists pkg; then
                    pkg update -y
                    pkg upgrade -y
                    print_ok "Packages updated."
                else
                    print_error "pkg command not found."
                fi

                pause_screen
                ;;

            6)
                clear_screen
                show_logo

                echo -e "${BOLD}PATH${RESET}"
                divider
                echo

                echo "$PATH" | tr ':' '\n'

                pause_screen
                ;;

            0)
                return
                ;;

            *)
                print_error "Invalid option."
                sleep 1
                ;;
        esac
    done
}

# ------------------------------------------------------------
# File Center
# ------------------------------------------------------------

file_center() {
    while true; do
        clear_screen
        show_logo

        echo -e "${BRIGHT_CYAN}${BOLD}FILE CENTER${RESET}"
        divider
        echo

        echo -e "  Current: ${BRIGHT_GREEN}$(pwd)${RESET}"
        echo

        echo "  [1] List files"
        echo "  [2] Search files"
        echo "  [3] File information"
        echo "  [4] Create file"
        echo "  [5] Create directory"
        echo "  [6] Copy"
        echo "  [7] Move"
        echo "  [8] Rename"
        echo "  [9] Delete"
        echo "  [10] Change directory"
        echo "  [11] Extract ZIP"
        echo "  [12] Create ZIP"
        echo "  [0] Back"
        echo

        read -r -p "  Select: " choice

        case "$choice" in

            1)
                clear_screen
                show_logo
                ls -lah
                pause_screen
                ;;

            2)
                clear_screen
                show_logo

                read -r -p "Search: " search_name

                if [ -n "$search_name" ]; then
                    find . -iname "*$search_name*" 2>/dev/null | head -100
                else
                    print_error "Search cannot be empty."
                fi

                pause_screen
                ;;

            3)
                clear_screen
                show_logo

                read -r -p "Path: " target

                if [ -e "$target" ]; then
                    echo
                    ls -ld "$target"
                    echo
                    file "$target" 2>/dev/null || true
                    echo
                    du -sh "$target" 2>/dev/null || true
                else
                    print_error "Path does not exist."
                fi

                pause_screen
                ;;

            4)
                clear_screen
                show_logo

                read -r -p "File path: " file_path

                if [ -n "$file_path" ]; then
                    mkdir -p "$(dirname "$file_path")" 2>/dev/null || true

                    if touch "$file_path"; then
                        print_ok "File created."
                    else
                        print_error "Could not create file."
                    fi
                else
                    print_error "File path cannot be empty."
                fi

                pause_screen
                ;;

            5)
                clear_screen
                show_logo

                read -r -p "Directory: " directory

                if [ -n "$directory" ]; then
                    if mkdir -p "$directory"; then
                        print_ok "Directory created."
                    else
                        print_error "Could not create directory."
                    fi
                else
                    print_error "Directory name cannot be empty."
                fi

                pause_screen
                ;;

            6)
                clear_screen
                show_logo

                read -r -p "Source: " source
                read -r -p "Destination: " destination

                if [ -e "$source" ]; then
                    if cp -r "$source" "$destination"; then
                        print_ok "Copy completed."
                    else
                        print_error "Copy failed."
                    fi
                else
                    print_error "Source does not exist."
                fi

                pause_screen
                ;;

            7)
                clear_screen
                show_logo

                read -r -p "Source: " source
                read -r -p "Destination: " destination

                if [ -e "$source" ]; then
                    if mv "$source" "$destination"; then
                        print_ok "Move completed."
                    else
                        print_error "Move failed."
                    fi
                else
                    print_error "Source does not exist."
                fi

                pause_screen
                ;;

            8)
                clear_screen
                show_logo

                read -r -p "Current name: " old_name
                read -r -p "New name: " new_name

                if [ -e "$old_name" ]; then
                    if mv "$old_name" "$new_name"; then
                        print_ok "Rename completed."
                    else
                        print_error "Rename failed."
                    fi
                else
                    print_error "Path does not exist."
                fi

                pause_screen
                ;;

            9)
                clear_screen
                show_logo

                read -r -p "Path to delete: " target

                if [ -z "$target" ]; then
                    print_error "Path cannot be empty."
                    pause_screen
                    continue
                fi

                if [ "$target" = "/" ] || [ "$target" = "$HOME" ] || [ "$target" = "." ]; then
                    print_error "Unsafe delete target."
                    pause_screen
                    continue
                fi

                if [ -e "$target" ]; then
                    echo
                    ls -ld "$target"
                    echo
                    read -r -p "Type DELETE to confirm: " confirm

                    if [ "$confirm" = "DELETE" ]; then
                        rm -rf -- "$target"
                        print_ok "Delete completed."
                    else
                        print_warn "Delete cancelled."
                    fi
                else
                    print_error "Path does not exist."
                fi

                pause_screen
                ;;

            10)
                clear_screen
                show_logo

                echo "Current directory:"
                pwd
                echo

                read -r -p "Directory: " directory

                if [ -d "$directory" ]; then
                    cd "$directory" || print_error "Could not change directory."
                else
                    print_error "Directory does not exist."
                    pause_screen
                fi
                ;;

            11)
                clear_screen
                show_logo

                read -r -p "ZIP file: " zip_file
                read -r -p "Destination: " destination

                if [ -f "$zip_file" ]; then
                    mkdir -p "$destination"

                    if unzip "$zip_file" -d "$destination"; then
                        print_ok "Extraction completed."
                    else
                        print_error "Extraction failed."
                    fi
                else
                    print_error "ZIP file not found."
                fi

                pause_screen
                ;;

            12)
                clear_screen
                show_logo

                read -r -p "Source: " source
                read -r -p "Output ZIP: " output

                if [ -e "$source" ]; then
                    if zip -r "$output" "$source"; then
                        print_ok "ZIP created."
                    else
                        print_error "ZIP creation failed."
                    fi
                else
                    print_error "Source does not exist."
                fi

                pause_screen
                ;;

            0)
                return
                ;;

            *)
                print_error "Invalid option."
                sleep 1
                ;;
        esac
    done
}

# ------------------------------------------------------------
# Developer Center
# ------------------------------------------------------------

developer_center() {
    while true; do
        clear_screen
        show_logo

        echo -e "${BRIGHT_CYAN}${BOLD}DEVELOPER CENTER${RESET}"
        divider
        echo

        echo "  [1] Git status"
        echo "  [2] Git version"
        echo "  [3] Python information"
        echo "  [4] Node.js information"
        echo "  [5] Initialize Git repository"
        echo "  [6] Start Python server"
        echo "  [7] Open project directory"
        echo "  [0] Back"
        echo

        read -r -p "  Select: " choice

        case "$choice" in

            1)
                clear_screen
                show_logo

                if command_exists git; then
                    git status 2>/dev/null || echo "Not a Git repository."
                else
                    print_error "Git is not installed."
                fi

                pause_screen
                ;;

            2)
                clear_screen
                show_logo

                if command_exists git; then
                    git --version
                else
                    print_error "Git is not installed."
                fi

                pause_screen
                ;;

            3)
                clear_screen
                show_logo

                if command_exists python; then
                    python --version
                    echo
                    python -c 'import sys; print("Executable:", sys.executable)'
                else
                    print_error "Python is not installed."
                fi

                pause_screen
                ;;

            4)
                clear_screen
                show_logo

                if command_exists node; then
                    node --version
                    echo
                    if command_exists npm; then
                        echo "NPM: $(npm --version)"
                    fi
                else
                    print_error "Node.js is not installed."
                fi

                pause_screen
                ;;

            5)
                clear_screen
                show_logo

                if command_exists git; then
                    if git init; then
                        print_ok "Git repository initialized."
                    else
                        print_error "Git initialization failed."
                    fi
                else
                    print_error "Git is not installed."
                fi

                pause_screen
                ;;

            6)
                clear_screen
                show_logo

                if ! command_exists python; then
                    print_error "Python is not installed."
                    pause_screen
                    continue
                fi

                read -r -p "Port [8080]: " port
                port="${port:-8080}"

                if [[ "$port" =~ ^[0-9]+$ ]] &&
                   [ "$port" -ge 1 ] &&
                   [ "$port" -le 65535 ]; then

                    echo
                    echo "Server:"
                    echo "http://127.0.0.1:$port"
                    echo
                    echo "Press CTRL+C to stop."

                    python -m http.server "$port"
                else
                    print_error "Invalid port."
                    pause_screen
                fi
                ;;

            7)
                clear_screen
                show_logo

                mkdir -p "$PROJECT_DIR"
                cd "$PROJECT_DIR" || true

                echo "Project directory:"
                pwd
                echo
                ls -lah

                pause_screen
                ;;

            0)
                return
                ;;

            *)
                print_error "Invalid option."
                sleep 1
                ;;
        esac
    done
}


# ------------------------------------------------------------
# Server Registry
# ------------------------------------------------------------

SERVER_REGISTRY="$APP_HOME/servers.db"

ensure_server_registry() {
    mkdir -p "$APP_HOME"
    touch "$SERVER_REGISTRY"
}

register_server() {
    local name="$1"
    local port="$2"
    local directory="$3"
    local pid="$4"

    ensure_server_registry

    printf '%s|%s|%s|%s|%s\n' \
        "$name" "$port" "$directory" "$pid" "$(date +%s)" \
        >> "$SERVER_REGISTRY"
}

server_pid_running() {
    local pid="$1"

    kill -0 "$pid" 2>/dev/null
}

show_managed_servers() {
    ensure_server_registry

    echo
    echo -e "${BRIGHT_CYAN}${BOLD}KURDTERM3 MANAGED SERVERS${RESET}"
    divider
    echo

    if [ ! -s "$SERVER_REGISTRY" ]; then
        echo -e "${DIM}No managed servers found.${RESET}"
        return
    fi

    local found=0

    while IFS='|' read -r name port directory pid started; do
        [ -z "$pid" ] && continue

        found=1

        if server_pid_running "$pid"; then
            status="${BRIGHT_GREEN}RUNNING${RESET}"
        else
            status="${RED}STOPPED${RESET}"
        fi

        echo -e "${BOLD}$name${RESET}"
        echo "  Port      : $port"
        echo "  Directory : $directory"
        echo "  PID       : $pid"
        echo -e "  Status    : $status"
        echo
    done < "$SERVER_REGISTRY"

    [ "$found" -eq 0 ] && echo -e "${DIM}No managed servers found.${RESET}"
}

cleanup_server_registry() {
    ensure_server_registry

    local temp_file="$SERVER_REGISTRY.tmp"
    : > "$temp_file"

    while IFS='|' read -r name port directory pid started; do
        [ -z "$pid" ] && continue

        if server_pid_running "$pid"; then
            printf '%s|%s|%s|%s|%s\n' \
                "$name" "$port" "$directory" "$pid" "$started" >> "$temp_file"
        fi
    done < "$SERVER_REGISTRY"

    mv "$temp_file" "$SERVER_REGISTRY"

    print_ok "Stopped server records cleaned."
}

stop_managed_server() {
    ensure_server_registry

    echo
    read -r -p "PID to stop: " pid

    if [ -z "$pid" ]; then
        print_error "PID is required."
        return
    fi

    if server_pid_running "$pid"; then
        kill "$pid" 2>/dev/null

        sleep 1

        if server_pid_running "$pid"; then
            kill -9 "$pid" 2>/dev/null
        fi

        print_ok "Server stopped."
    else
        print_warn "Server is not running."
    fi
}

# ------------------------------------------------------------

# Server Manager - Restart
# ------------------------------------------------------------

restart_managed_server() {
    ensure_server_registry

    echo
    read -r -p "PID to restart: " pid

    if [ -z "$pid" ]; then
        print_error "PID is required."
        return
    fi

    local name=""
    local port=""
    local directory=""
    local started=""

    while IFS='|' read -r r_name r_port r_directory r_pid r_started; do
        if [ "$r_pid" = "$pid" ]; then
            name="$r_name"
            port="$r_port"
            directory="$r_directory"
            started="$r_started"
            break
        fi
    done < "$SERVER_REGISTRY"

    if [ -z "$directory" ] || [ -z "$port" ]; then
        print_error "Server record not found."
        return
    fi

    if server_pid_running "$pid"; then
        kill "$pid" 2>/dev/null
        sleep 1
    fi

    cd "$directory" || {
        print_error "Could not open server directory."
        return
    }

    python -m http.server "$port" >"$directory/.kurdterm-server-$port.log" 2>&1 &
    local new_pid=$!

    sleep 1

    if server_pid_running "$new_pid"; then
        register_server "$name" "$port" "$directory" "$new_pid"

        echo
        print_ok "Server restarted."
        echo "URL    : http://127.0.0.1:$port"
        echo "PID    : $new_pid"
        echo "Status : RUNNING"
    else
        print_error "Server failed to restart."
    fi
}


# Server Manager - Remove
# ------------------------------------------------------------

remove_stopped_server() {
    ensure_server_registry

    echo
    read -r -p "PID to remove: " pid

    if [ -z "$pid" ]; then
        print_error "PID is required."
        return
    fi

    if server_pid_running "$pid"; then
        print_error "Server is still running. Stop it first."
        return
    fi

    local temp_file="${SERVER_REGISTRY}.tmp"
    : > "$temp_file"

    while IFS='|' read -r name port directory r_pid started; do
        [ -z "$r_pid" ] && continue
        [ "$r_pid" = "$pid" ] && continue

        printf '%s|%s|%s|%s|%s\n' \
            "$name" "$port" "$directory" "$r_pid" "$started" >> "$temp_file"
    done < "$SERVER_REGISTRY"

    mv "$temp_file" "$SERVER_REGISTRY"

    print_ok "Server record removed."
}

# Web Server
# ------------------------------------------------------------

web_server() {
    while true; do
        clear_screen
        show_logo

        echo -e "${BRIGHT_CYAN}${BOLD}WEB SERVER${RESET}"
        divider
        echo

        echo "  [1] Start local server"
        echo "  [2] Show managed servers"
        echo "  [3] Stop server"
        echo "  [4] Restart server"
        echo "  [5] Remove stopped server"
        echo "  [6] Show IP addresses"
        echo "  [7] Managed listening ports"
        echo "  [8] Cleanup stopped records"
        echo "  [0] Back"
        echo

        read -r -p "  Select: " choice

        case "$choice" in

            1)
                clear_screen
                show_logo

                if ! command_exists python; then
                    print_error "Python is not installed."
                    pause_screen
                    continue
                fi

                read -r -p "Directory [$PROJECT_DIR]: " directory
                directory="${directory:-$PROJECT_DIR}"

                if [ ! -d "$directory" ]; then
                    print_error "Directory does not exist."
                    pause_screen
                    continue
                fi

                read -r -p "Port [8080]: " port
                port="${port:-8080}"

                if ! [[ "$port" =~ ^[0-9]+$ ]]; then
                    print_error "Invalid port."
                    pause_screen
                    continue
                fi

                cd "$directory" || {
                    print_error "Could not open directory."
                    pause_screen
                    continue
                }

                echo
                echo -e "${BRIGHT_GREEN}Starting server...${RESET}"
                echo

                ensure_server_registry

                python -m http.server "$port" \
                    >"$directory/.kurdterm-server-$port.log" 2>&1 &

                local server_pid=$!

                sleep 1

                if server_pid_running "$server_pid"; then
                    register_server \
                        "Python HTTP Server" \
                        "$port" \
                        "$directory" \
                        "$server_pid"

                    echo -e "${BRIGHT_GREEN}Server running${RESET}"
                    echo "http://127.0.0.1:$port"
                    echo
                    echo "Directory : $directory"
                    echo "Port      : $port"
                    echo "PID       : $server_pid"
                    echo "Status    : RUNNING"
                else
                    print_error "Server failed to start."
                    echo
                    echo "Check:"
                    echo "$directory/.kurdterm-server-$port.log"
                fi

                pause_screen
                ;;

            2)
                clear_screen
                show_logo
                show_managed_servers
                pause_screen
                ;;

            3)
                clear_screen
                show_logo
                stop_managed_server
                pause_screen
                ;;

            4)
                clear_screen
                show_logo
                restart_managed_server
                pause_screen
                ;;

            5)
                clear_screen
                show_logo
                remove_stopped_server
                pause_screen
                ;;

            6)
                clear_screen
                show_logo

                echo -e "${BRIGHT_GREEN}IP ADDRESSES${RESET}"
                echo "----------------------------------------------"
                echo

                if command_exists ip; then
                    ip addr show
                elif command_exists ifconfig; then
                    ifconfig
                else
                    print_error "Network tool unavailable."
                fi

                pause_screen
                ;;

            7)
                clear_screen
                show_logo

                echo -e "${BRIGHT_GREEN}MANAGED LISTENING PORTS${RESET}"
                echo "----------------------------------------------"
                echo

                ensure_server_registry

                found_managed=0

                if [ -s "$SERVER_REGISTRY" ]; then
                    while IFS='|' read -r name port directory pid started; do
                        [ -z "$pid" ] && continue

                        if server_pid_running "$pid"; then
                            found_managed=1

                            echo -e "${BRIGHT_GREEN}RUNNING${RESET}  $name"
                            echo "  Port      : $port"
                            echo "  Directory : $directory"
                            echo "  PID       : $pid"
                            echo
                        fi
                    done < "$SERVER_REGISTRY"
                fi

                if [ "$found_managed" -eq 0 ]; then
                    echo -e "${DIM}No running managed servers found.${RESET}"
                fi

                echo
                echo "----------------------------------------------"
                pause_screen
                ;;

            8)
                clear_screen
                show_logo

                echo -e "${BRIGHT_GREEN}CLEANUP STOPPED RECORDS${RESET}"
                echo "----------------------------------------------"
                echo

                cleanup_server_registry

                echo
                echo "Remaining records:"
                echo

                if [ -s "$SERVER_REGISTRY" ]; then
                    cat "$SERVER_REGISTRY"
                else
                    echo -e "${DIM}No server records found.${RESET}"
                fi

                echo
                pause_screen
                ;;

            0)
                return
                ;;

            *)
                print_error "Invalid option."
                pause_screen
                ;;
        esac
    done
}


project_builder() {
    while true; do
        clear_screen
        show_logo

        echo -e "${BRIGHT_CYAN}${BOLD}PROJECT BUILDER${RESET}"
        divider
        echo

        echo "  [1] HTML / CSS / JS"
        echo "  [2] Python"
        echo "  [3] Node.js"
        echo "  [4] Empty project"
        echo "  [0] Back"
        echo

        read -r -p "  Select: " choice

        case "$choice" in

            1)
                create_web_project
                ;;

            2)
                create_python_project
                ;;

            3)
                create_node_project
                ;;

            4)
                create_empty_project
                ;;

            0)
                return
                ;;

            *)
                print_error "Invalid option."
                sleep 1
                ;;
        esac
    done
}

# ------------------------------------------------------------
# Create Web Project
# ------------------------------------------------------------

create_web_project() {
    clear_screen
    show_logo

    read -r -p "Project name: " name

    if [ -z "$name" ]; then
        print_error "Project name cannot be empty."
        pause_screen
        return
    fi

    local project="$PROJECT_DIR/$name"

    if [ -e "$project" ]; then
        print_error "Project already exists."
        pause_screen
        return
    fi

    mkdir -p "$project"

    cat > "$project/index.html" <<'EOF'
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>KurdTerm3 — TaQaNa</title>
    <link rel="stylesheet" href="style.css">
</head>
<body>

    <main class="card">
        <h1>KurdTerm3 — TaQaNa</h1>
        <p>Your new website is ready.</p>
        <button id="helloBtn">Get Started</button>
    </main>

    <script src="app.js"></script>
</body>
</html>
EOF

    cat > "$project/style.css" <<'EOF'
* {
    box-sizing: border-box;
}

body {
    margin: 0;
    min-height: 100vh;
    display: grid;
    place-items: center;
    padding: 20px;
    font-family: Arial, sans-serif;
    background: #111827;
    color: white;
}

.card {
    width: min(100%, 600px);
    padding: 40px;
    text-align: center;
    border-radius: 24px;
    background: #1f2937;
}

button {
    padding: 12px 22px;
    border: 0;
    border-radius: 12px;
    cursor: pointer;
}
EOF

    cat > "$project/app.js" <<'EOF'
const button = document.getElementById("helloBtn");

button.addEventListener("click", () => {
    alert("KurdTerm3 — TaQaNa is working!");
});
EOF

    print_ok "Web project created."
    echo
    echo "$project"

    pause_screen
}

# ------------------------------------------------------------
# Create Python Project
# ------------------------------------------------------------

create_python_project() {
    clear_screen
    show_logo

    read -r -p "Project name: " name

    if [ -z "$name" ]; then
        print_error "Project name cannot be empty."
        pause_screen
        return
    fi

    local project="$PROJECT_DIR/$name"

    if [ -e "$project" ]; then
        print_error "Project already exists."
        pause_screen
        return
    fi

    mkdir -p "$project"

    cat > "$project/main.py" <<'EOF'
def main():
    print("KurdTerm Python Project is working!")


if __name__ == "__main__":
    main()
EOF

    print_ok "Python project created."
    echo "$project"

    pause_screen
}

# ------------------------------------------------------------
# Create Node Project
# ------------------------------------------------------------

create_node_project() {
    clear_screen
    show_logo

    read -r -p "Project name: " name

    if [ -z "$name" ]; then
        print_error "Project name cannot be empty."
        pause_screen
        return
    fi

    local project="$PROJECT_DIR/$name"

    if [ -e "$project" ]; then
        print_error "Project already exists."
        pause_screen
        return
    fi

    mkdir -p "$project"

    cat > "$project/package.json" <<EOF
{
    "name": "$name",
    "version": "1.0.0",
    "main": "index.js",
    "scripts": {
        "start": "node index.js"
    }
}
EOF

    cat > "$project/index.js" <<'EOF'
console.log("KurdTerm Node.js Project is working!");
EOF

    print_ok "Node.js project created."
    echo "$project"

    pause_screen
}

# ------------------------------------------------------------
# Create Empty Project
# ------------------------------------------------------------

create_empty_project() {
    clear_screen
    show_logo

    read -r -p "Project name: " name

    if [ -z "$name" ]; then
        print_error "Project name cannot be empty."
        pause_screen
        return
    fi

    local project="$PROJECT_DIR/$name"

    if [ -e "$project" ]; then
        print_error "Project already exists."
        pause_screen
        return
    fi

    mkdir -p "$project"

    print_ok "Empty project created."
    echo "$project"

    pause_screen
}

# ------------------------------------------------------------
# AI Center
# ------------------------------------------------------------

ai_center() {
    while true; do
        clear_screen
        show_logo

        echo -e "${BRIGHT_CYAN}${BOLD}AI CENTER${RESET}"
        divider
        echo

        echo "  [1] AI configuration"
        echo "  [2] Explain command"
        echo "  [3] AI environment"
        echo "  [0] Back"
        echo

        read -r -p "  Select: " choice

        case "$choice" in

            1)
                clear_screen
                show_logo

                echo -e "${BOLD}AI Configuration${RESET}"
                divider
                echo

                if [ -n "${OPENAI_API_KEY:-}" ]; then
                    echo -e "  ${BRIGHT_GREEN}●${RESET} OpenAI configured"
                else
                    echo -e "  ${GRAY}○${RESET} OpenAI not configured"
                fi

                if [ -n "${ANTHROPIC_API_KEY:-}" ]; then
                    echo -e "  ${BRIGHT_GREEN}●${RESET} Anthropic configured"
                else
                    echo -e "  ${GRAY}○${RESET} Anthropic not configured"
                fi

                if [ -n "${GEMINI_API_KEY:-}" ]; then
                    echo -e "  ${BRIGHT_GREEN}●${RESET} Gemini configured"
                else
                    echo -e "  ${GRAY}○${RESET} Gemini not configured"
                fi

                pause_screen
                ;;

            2)
                clear_screen
                show_logo

                read -r -p "Command: " command_text

                echo
                echo "Command:"
                echo "$command_text"
                echo
                echo "AI command explanation module is ready for provider integration."

                pause_screen
                ;;

            3)
                clear_screen
                show_logo

                echo "Supported environment variables:"
                echo
                echo "OPENAI_API_KEY"
                echo "ANTHROPIC_API_KEY"
                echo "GEMINI_API_KEY"

                pause_screen
                ;;

            0)
                return
                ;;

            *)
                print_error "Invalid option."
                sleep 1
                ;;
        esac
    done
}

# ------------------------------------------------------------
# Automation Center
# ------------------------------------------------------------

automation_center() {
    while true; do
        clear_screen
        show_logo

        echo -e "${BRIGHT_CYAN}${BOLD}AUTOMATION CENTER${RESET}"
        divider
        echo

        echo "  [1] Create Bash script"
        echo "  [2] List scripts"
        echo "  [3] Make script executable"
        echo "  [0] Back"
        echo

        read -r -p "  Select: " choice

        case "$choice" in

            1)
                clear_screen
                show_logo

                read -r -p "Script name: " name

                if [ -z "$name" ]; then
                    print_error "Script name cannot be empty."
                    pause_screen
                    continue
                fi

                local script="$PROJECT_DIR/$name.sh"

                if [ -e "$script" ]; then
                    print_error "Script already exists."
                else
                    cat > "$script" <<'EOF'
#!/data/data/com.termux/files/usr/bin/bash

echo "Automation started."

# Add your commands here.

echo "Automation finished."
EOF

                    chmod 700 "$script"

                    print_ok "Script created."
                    echo "$script"
                fi

                pause_screen
                ;;

            2)
                clear_screen
                show_logo

                find "$PROJECT_DIR" -type f -name "*.sh" 2>/dev/null

                pause_screen
                ;;

            3)
                clear_screen
                show_logo

                read -r -p "Script path: " script

                if [ -f "$script" ]; then
                    chmod 700 "$script"
                    print_ok "Script is executable."
                else
                    print_error "Script not found."
                fi

                pause_screen
                ;;

            0)
                return
                ;;

            *)
                print_error "Invalid option."
                sleep 1
                ;;
        esac
    done
}

# ------------------------------------------------------------
# Backup Center
# ------------------------------------------------------------

backup_center() {
    while true; do
        clear_screen
        show_logo

        echo -e "${BRIGHT_CYAN}${BOLD}BACKUP CENTER${RESET}"
        divider
        echo

        echo "  [1] Backup KurdTerm"
        echo "  [2] Backup projects"
        echo "  [3] List backups"
        echo "  [0] Back"
        echo

        read -r -p "  Select: " choice

        case "$choice" in

            1)
                clear_screen
                show_logo

                local timestamp
                local output

                timestamp=$(date +%Y%m%d_%H%M%S)
                output="$BACKUP_DIR/kurdterm-v3-$timestamp.tar.gz"

                if tar -czf "$output" "$APP_HOME" 2>/dev/null; then
                    print_ok "KurdTerm backup created."
                    echo "$output"
                else
                    print_error "Backup failed."
                fi

                pause_screen
                ;;

            2)
                clear_screen
                show_logo

                timestamp=$(date +%Y%m%d_%H%M%S)
                output="$BACKUP_DIR/projects-$timestamp.tar.gz"

                if tar -czf "$output" "$PROJECT_DIR" 2>/dev/null; then
                    print_ok "Project backup created."
                    echo "$output"
                else
                    print_error "Backup failed."
                fi

                pause_screen
                ;;

            3)
                clear_screen
                show_logo

                ls -lah "$BACKUP_DIR" 2>/dev/null || true

                pause_screen
                ;;

            0)
                return
                ;;

            *)
                print_error "Invalid option."
                sleep 1
                ;;
        esac
    done
}

# ------------------------------------------------------------
# Plugin Center
# ------------------------------------------------------------

plugin_center() {
    while true; do
        clear_screen
        show_logo

        echo -e "${BRIGHT_CYAN}${BOLD}PLUGIN CENTER${RESET}"
        divider
        echo

        echo "  [1] List plugins"
        echo "  [2] Create plugin"
        echo "  [3] Run plugin"
        echo "  [0] Back"
        echo

        read -r -p "  Select: " choice

        case "$choice" in

            1)
                clear_screen
                show_logo

                echo "Installed plugins:"
                echo

                find "$PLUGIN_DIR" -maxdepth 1 -type f -name "*.sh" \
                    -printf "%f\n" 2>/dev/null

                pause_screen
                ;;

            2)
                clear_screen
                show_logo

                read -r -p "Plugin name: " name

                if [ -z "$name" ]; then
                    print_error "Plugin name cannot be empty."
                    pause_screen
                    continue
                fi

                local plugin="$PLUGIN_DIR/$name.sh"

                if [ -e "$plugin" ]; then
                    print_error "Plugin already exists."
                else
                    cat > "$plugin" <<'EOF'
#!/data/data/com.termux/files/usr/bin/bash

echo "KurdTerm Plugin"
echo "Plugin executed successfully."

# Add your plugin commands here.
EOF

                    chmod 700 "$plugin"

                    print_ok "Plugin created."
                    echo "$plugin"
                fi

                pause_screen
                ;;

            3)
                clear_screen
                show_logo

                read -r -p "Plugin name: " name

                local plugin="$PLUGIN_DIR/$name.sh"

                if [ -f "$plugin" ]; then
                    bash "$plugin"
                else
                    print_error "Plugin not found."
                fi

                pause_screen
                ;;

            0)
                return
                ;;

            *)
                print_error "Invalid option."
                sleep 1
                ;;
        esac
    done
}

# ------------------------------------------------------------
# Security Diagnostics
# ------------------------------------------------------------

security_center() {
    while true; do
        clear_screen
        show_logo

        echo -e "${BRIGHT_CYAN}${BOLD}SECURITY DIAGNOSTICS${RESET}"
        divider
        echo

        echo "  [1] Listening ports"
        echo "  [2] Network interfaces"
        echo "  [3] Routing table"
        echo "  [4] Local addresses"
        echo "  [5] HTTPS headers"
        echo "  [0] Back"
        echo

        read -r -p "  Select: " choice

        case "$choice" in

            1)
                clear_screen
                show_logo

                if command_exists ss; then
                    ss -lntup 2>/dev/null
                elif command_exists netstat; then
                    netstat -lntup 2>/dev/null
                else
                    echo "Install iproute2 or net-tools."
                fi

                pause_screen
                ;;

            2)
                clear_screen
                show_logo
                show_managed_servers
                pause_screen
                ;;

            3)
                clear_screen
                show_logo

                if command_exists ip; then
                    ip addr
                elif command_exists ifconfig; then
                    ifconfig
                else
                    print_error "Network interface tool unavailable."
                fi

                pause_screen
                ;;

            3)
                clear_screen
                show_logo

                if command_exists ip; then
                    ip route
                elif command_exists route; then
                    route -n
                else
                    print_error "Routing tool unavailable."
                fi

                pause_screen
                ;;

            4)
                clear_screen
                show_logo

                if command_exists ip; then
                    ip addr show | grep -E 'inet |inet6 ' || true
                elif command_exists ifconfig; then
                    ifconfig
                else
                    print_error "Address tool unavailable."
                fi

                pause_screen
                ;;

            5)
                clear_screen
                show_logo

                read -r -p "HTTPS URL: " url

                if [[ "$url" == https://* ]]; then
                    if command_exists curl; then
                        curl -I -L --max-time 10 "$url"
                    else
                        print_error "curl is not installed."
                    fi
                else
                    print_error "Only HTTPS URLs are allowed."
                fi

                pause_screen
                ;;

            0)
                return
                ;;

            *)
                print_error "Invalid option."
                sleep 1
                ;;
        esac
    done
}

# ------------------------------------------------------------
# Smart Doctor
# ------------------------------------------------------------

smart_doctor() {
    clear_screen
    show_logo

    echo -e "${BRIGHT_CYAN}${BOLD}SMART DOCTOR${RESET}"
    divider
    echo

    echo "Running system checks..."
    echo

    echo -n "  Bash        "
    if command_exists bash; then
        print_ok "Available."
    else
        print_error "Missing."
    fi

    echo -n "  pkg         "
    if command_exists pkg; then
        print_ok "Available."
    else
        print_error "Missing."
    fi

    echo -n "  Python      "
    if command_exists python; then
        print_ok "Available."
    else
        print_warn "Not installed."
    fi

    echo -n "  Git         "
    if command_exists git; then
        print_ok "Available."
    else
        print_warn "Not installed."
    fi

    echo -n "  Node.js     "
    if command_exists node; then
        print_ok "Available."
    else
        print_warn "Not installed."
    fi

    echo
    echo "  Project directory:"
    echo "  $PROJECT_DIR"

    if [ -d "$PROJECT_DIR" ]; then
        print_ok "Available."
    else
        mkdir -p "$PROJECT_DIR"
        print_ok "Created."
    fi

    echo
    echo "  Plugin directory:"
    echo "  $PLUGIN_DIR"

    if [ -d "$PLUGIN_DIR" ]; then
        print_ok "Available."
    else
        mkdir -p "$PLUGIN_DIR"
        print_ok "Created."
    fi

    echo
    echo "  Backup directory:"
    echo "  $BACKUP_DIR"

    if [ -d "$BACKUP_DIR" ]; then
        print_ok "Available."
    else
        mkdir -p "$BACKUP_DIR"
        print_ok "Created."
    fi

    echo
    divider
    echo
    print_ok "Doctor scan completed."

    pause_screen
}

# ------------------------------------------------------------
# Settings
# ------------------------------------------------------------

settings() {
    while true; do
        clear_screen
        show_logo

        echo
        echo "SETTINGS CENTER"
        echo "---------------"
        echo
        echo "1. View configuration"
        echo "2. Change server port"
        echo "3. Change network timeout"
        echo "4. Toggle loading screen"
        echo "5. Toggle plugins"
        echo "6. Toggle delete confirmation"
        echo "7. Reset configuration"
        echo "0. Back"
        echo

        read -rp "Select: " choice

        case "$choice" in

            1)
                clear
                echo "CURRENT CONFIGURATION"
                echo "---------------------"
                echo
                [ -f "$CONFIG_FILE" ] && cat "$CONFIG_FILE" || echo "[ERROR] Configuration file not found."
                echo
                read -rp "Press Enter to continue..."
                ;;

            2)
                echo
                read -rp "Enter server port (1-65535): " new_port

                if [[ "$new_port" =~ ^[0-9]+$ ]] &&
                   [ "$new_port" -ge 1 ] &&
                   [ "$new_port" -le 65535 ]; then

                    sed -i "s/^DEFAULT_SERVER_PORT=.*/DEFAULT_SERVER_PORT=\"$new_port\"/" "$CONFIG_FILE"
                    DEFAULT_SERVER_PORT="$new_port"

                    echo
                    echo "[OK] Server port updated."
                else
                    echo
                    echo "[ERROR] Invalid port."
                fi

                sleep 1
                ;;

            3)
                echo
                read -rp "Enter network timeout in seconds: " new_timeout

                if [[ "$new_timeout" =~ ^[0-9]+$ ]] &&
                   [ "$new_timeout" -ge 1 ]; then

                    sed -i "s/^NETWORK_TIMEOUT=.*/NETWORK_TIMEOUT=\"$new_timeout\"/" "$CONFIG_FILE"
                    NETWORK_TIMEOUT="$new_timeout"

                    echo
                    echo "[OK] Network timeout updated."
                else
                    echo
                    echo "[ERROR] Invalid timeout."
                fi

                sleep 1
                ;;

            4)
                if [ "${SHOW_LOADING_SCREEN:-true}" = "true" ]; then
                    new_value="false"
                else
                    new_value="true"
                fi

                sed -i "s/^SHOW_LOADING_SCREEN=.*/SHOW_LOADING_SCREEN=\"$new_value\"/" "$CONFIG_FILE"
                SHOW_LOADING_SCREEN="$new_value"

                echo
                echo "[OK] Loading screen: $new_value"
                sleep 1
                ;;

            5)
                if [ "${PLUGINS_ENABLED:-true}" = "true" ]; then
                    new_value="false"
                else
                    new_value="true"
                fi

                sed -i "s/^PLUGINS_ENABLED=.*/PLUGINS_ENABLED=\"$new_value\"/" "$CONFIG_FILE"
                PLUGINS_ENABLED="$new_value"

                echo
                echo "[OK] Plugins: $new_value"
                sleep 1
                ;;

            6)
                if [ "${REQUIRE_DELETE_CONFIRM:-true}" = "true" ]; then
                    new_value="false"
                else
                    new_value="true"
                fi

                sed -i "s/^REQUIRE_DELETE_CONFIRM=.*/REQUIRE_DELETE_CONFIRM=\"$new_value\"/" "$CONFIG_FILE"
                REQUIRE_DELETE_CONFIRM="$new_value"

                echo
                echo "[OK] Delete confirmation: $new_value"
                sleep 1
                ;;

            7)
                echo
                echo "WARNING: This will restore default settings."
                read -rp "Type RESET to continue: " confirm

                if [ "$confirm" = "RESET" ]; then
                    cat > "$CONFIG_FILE" <<EOF
KURDTERM_VERSION="3.0.0"
KURDTERM_NAME="KurdTerm3"

KURDTERM_HOME="\$HOME/.kurdterm-v3"
PLUGIN_DIR="\$KURDTERM_HOME/plugins"
PROJECT_DIR="\$HOME/KurdTerm-Pro-v3/projects"
BACKUP_DIR="\$HOME/KurdTerm-Pro-v3/backups"

UI_MODE="modern"
UI_LANGUAGE="en"
UI_ASCII_ONLY="true"

NETWORK_TIMEOUT="10"
DEFAULT_SERVER_PORT="8080"

REQUIRE_DELETE_CONFIRM="true"
REQUIRE_RESET_CONFIRM="true"

BACKUP_COMPRESSION="gzip"
DEFAULT_PROJECT_DIR="\$PROJECT_DIR"

OPENAI_KEY_NAME="OPENAI_API_KEY"
ANTHROPIC_KEY_NAME="ANTHROPIC_API_KEY"
GEMINI_KEY_NAME="GEMINI_API_KEY"

PLUGINS_ENABLED="true"
DOCTOR_ENABLED="true"

AUTO_CREATE_DIRECTORIES="true"
SHOW_LOADING_SCREEN="true"
EOF

                    echo
                    echo "[OK] Configuration reset successfully."
                else
                    echo
                    echo "[CANCELLED] Configuration was not changed."
                fi

                sleep 1
                ;;

            0)
                return
                ;;

            *)
                echo
                echo "[ERROR] Invalid option."
                sleep 1
                ;;
        esac
    done
}

main_menu() {
    while true; do
        clear_screen

        local width
        width=$(get_width)

        show_logo

        echo
        echo -e "${BOLD}Welcome back.${RESET}"
        echo -e "${DIM}Everything you need, in one place.${RESET}"
        echo

        echo -e "${BRIGHT_CYAN}${BOLD}SYSTEM${RESET}"
        divider "$width"
        echo

        local network
        network=$(get_network_status)

        echo -e "  Network    $(status_dot "$network") ${BRIGHT_GREEN}$network${RESET}"
        echo -e "  CPU Load   ${BRIGHT_GREEN}$(get_cpu_usage)${RESET}"
        echo -e "  Memory     ${BRIGHT_GREEN}$(get_memory_info)${RESET}"
        echo -e "  Storage    ${BRIGHT_GREEN}$(get_storage_info)${RESET}"

        echo
        echo -e "${BRIGHT_CYAN}${BOLD}QUICK ACCESS${RESET}"
        divider "$width"
        echo

        echo "  [1]  Tools              [2]  Files"
        echo "  [3]  Developer          [4]  Web Server"
        echo "  [5]  Project Builder    [6]  AI Center"
        echo "  [7]  Automation         [8]  Backup"
        echo "  [9]  Plugins            [10] Security"
        echo "  [11] Smart Doctor       [12] Settings"

        echo
        echo -e "${GRAY}──────────────────────────────────────────────────────────${RESET}"
        echo
        echo -e "  ${BRIGHT_GREEN}[D]${RESET} Dashboard"
        echo -e "  ${RED}[0]${RESET} Exit"
        echo

        read -r -p "  Select: " choice

        case "$choice" in
            1) tool_center ;;
            2) file_center ;;
            3) developer_center ;;
            4) web_server ;;
            5) project_builder ;;
            6) ai_center ;;
            7) automation_center ;;
            8) backup_center ;;
            9) plugin_center ;;
            10) security_center ;;
            11) smart_doctor ;;
            12) settings ;;
            d|D) dashboard ;;
            0) exit_program ;;
            *)
                print_error "Invalid option."
                sleep 1
                ;;
        esac
    done
}

# ------------------------------------------------------------
# Exit
# ------------------------------------------------------------

exit_program() {
    clear_screen

    echo
    echo -e "${BRIGHT_GREEN}${BOLD}KurdTerm3${RESET}"; echo -e "${CYAN}Created by TaQaNa${RESET}"; echo -e "${DIM}Copyright © 2026 TaQaNa${RESET}"
    echo -e "${DIM}Session closed.${RESET}"
    echo

    exit 0
}

# ------------------------------------------------------------
# Start
# ------------------------------------------------------------

setup_directories

loading_screen

tool_search() {
    clear
    show_logo

    echo
    echo "Tool Search"
    echo "-----------"
    read -rp "Package name: " package

    if [ -z "$package" ]; then
        echo
        echo "[ERROR] Package name is required."
        read -rp "Press Enter to continue..."
        return
    fi

    echo
    echo "Searching for: $package"
    echo

    pkg search "$package"

    echo
    read -rp "Press Enter to continue..."
}


tool_install() {
    clear
    show_logo

    echo
    echo "Install Tool"
    echo "------------"
    read -rp "Package name: " package

    if [ -z "$package" ]; then
        echo
        echo "[ERROR] Package name is required."
        read -rp "Press Enter to continue..."
        return
    fi

    echo
    echo "Installing: $package"
    echo

    pkg install "$package" -y

    echo
    echo "[DONE] Installation process finished."
    read -rp "Press Enter to continue..."
}


tool_update() {
    clear
    show_logo

    echo
    echo "Package Update"
    echo "--------------"
    echo

    pkg update -y
    pkg upgrade -y

    echo
    echo "[DONE] Termux packages are updated."
    read -rp "Press Enter to continue..."
}


tool_info() {
    clear
    show_logo

    echo
    echo "Tool Information"
    echo "----------------"
    read -rp "Command name: " command

    if [ -z "$command" ]; then
        echo
        echo "[ERROR] Command name is required."
        read -rp "Press Enter to continue..."
        return
    fi

    echo

    if command -v "$command" >/dev/null 2>&1; then
        echo "[FOUND] $command"
        echo
        echo "Path:"
        command -v "$command"

        echo
        echo "Version:"
        "$command" --version 2>/dev/null || \
        "$command" -V 2>/dev/null || \
        echo "Version information is not available."
    else
        echo "[NOT FOUND] $command"
    fi

    echo
    read -rp "Press Enter to continue..."
}


tool_center() {
    while true; do
        clear
        show_logo

        echo
        echo "TOOL CENTER"
        echo "-----------"
        echo
        echo "1. Search package"
        echo "2. Install package"
        echo "3. Update packages"
        echo "4. Tool information"
        echo "5. Check common tools"
        echo "0. Back"
        echo

        read -rp "Select: " choice

        case "$choice" in
            1)
                tool_search
                ;;
            2)
                tool_install
                ;;
            3)
                tool_update
                ;;
            4)
                tool_info
                ;;
            5)
                clear
                show_logo

                echo
                echo "COMMON TOOLS"
                echo "------------"
                echo

                for tool in git python python3 node npm curl wget nano vim unzip zip tar; do
                    if command -v "$tool" >/dev/null 2>&1; then
                        echo "[OK]      $tool"
                    else
                        echo "[MISSING] $tool"
                    fi
                done

                echo
                read -rp "Press Enter to continue..."
                ;;
            0)
                return
                ;;
            *)
                echo
                echo "[ERROR] Invalid option."
                sleep 1
                ;;
        esac
    done
}











main_menu
