#!/bin/bash

data="todo.txt"

# ==================================================
# MINH DUC TRAN - CORE FUNCTIONS
# ==================================================

storage() {
    if [ ! -f "$data" ]; then
        touch "$data"
    fi
}

# CREATE TASK
add_task() {
    local task="$1"

    if [ -z "$task" ]; then
        echo "[ERROR] Task content may not be empty!"
        return 1
    fi

    storage

    local created
    created=$(date "+%Y-%m-%d %H:%M")

    echo "[PENDING] $task | $created" >> "$data"
    echo "[SUCCESS] Task added: \"$task\""
    return 0
}

# UPDATE TASK
update_task() {
    local num="$1"
    storage

    if [ ! -s "$data" ]; then
        echo "[ERROR] Task list is empty, not updated"
        return 1
    fi

    local lines
    lines=$(wc -l < "$data" | tr -d ' ')

    if [ -z "$num" ] || ! [[ "$num" =~ ^[0-9]+$ ]] || \
       [ "$num" -lt 1 ] || [ "$num" -gt "$lines" ]; then
        echo "[ERROR] Invalid task number: \"$num\"!"
        return 1
    fi

    if sed -n "${num}p" "$data" | grep -q "\[DONE\]"; then
        echo "[INFO] Task #$num is already completed"
    else
        sed -i "${num}s/\[PENDING\]/\[DONE\]/" "$data"
        echo "[SUCCESS] Task #$num marked completed"
    fi
}

# DELETE TASK
delete_task() {
    local num="$1"
    storage

    if [ ! -s "$data" ]; then
        echo "[ERROR] Task list is empty, nothing to delete!"
        return 1
    fi

    local lines
    lines=$(wc -l < "$data" | tr -d ' ')

    if [ -z "$num" ] || ! [[ "$num" =~ ^[0-9]+$ ]] || \
       [ "$num" -lt 1 ] || [ "$num" -gt "$lines" ]; then
        echo "[ERROR] Invalid task number: \"$num\"!"
        return 1
    fi

    sed -i "${num}d" "$data"
    echo "[SUCCESS] Task #$num deleted successfully!"
}


# ==================================================
# HOANG ANH LY - CLI, VIEW TASKS, INPUT VALIDATION
# ==================================================

GREEN=$(tput setaf 2)
RED=$(tput setaf 1)
CYAN=$(tput setaf 6)
YELLOW=$(tput setaf 3)
RESET=$(tput sgr0)

# READ / VIEW TASKS
get_tasks() {
    storage

    echo
    echo "${CYAN}========================================${RESET}"
    echo "${CYAN}              TO-DO LIST                ${RESET}"
    echo "${CYAN}========================================${RESET}"

    if [ ! -s "$data" ]; then
        echo "${YELLOW}[INFO] No tasks in your list.${RESET}"
        return 1
    fi

    nl -w2 -s ". " "$data"

    echo "${CYAN}========================================${RESET}"
}

# INPUT VALIDATION
validate_number() {
    local input="$1"

    if [ -z "$input" ]; then
        echo "${RED}[ERROR] Input cannot be empty.${RESET}"
        return 1
    fi

    if ! [[ "$input" =~ ^[0-9]+$ ]]; then
        echo "${RED}[ERROR] Please enter a number only.${RESET}"
        return 1
    fi

    return 0
}

# CLI MENU
show_menu() {
    clear

    echo "${CYAN}========================================${RESET}"
    echo "${CYAN}       PERSONAL TO-DO LIST MANAGER      ${RESET}"
    echo "${CYAN}========================================${RESET}"
    echo "1. View Tasks"
    echo "2. Add Task"
    echo "3. Complete Task"
    echo "4. Delete Task"
    echo "5. Exit"
    echo "${CYAN}========================================${RESET}"
}

# MAIN PROGRAM
storage

while true
do
    show_menu

    printf "Enter your choice [1-5]: "
    read -r choice

    case "$choice" in
        1)
            get_tasks
            echo
            read -r -p "Press Enter to continue..."
            ;;

        2)
            echo
            read -r -p "Enter new task: " task

            if [ -z "$task" ]; then
                echo "${RED}[ERROR] Task cannot be empty.${RESET}"
            else
                add_task "$task"
            fi

            echo
            read -r -p "Press Enter to continue..."
            ;;

        3)
            get_tasks
            echo
            read -r -p "Enter task number to complete: " num

            if validate_number "$num"; then
                update_task "$num"
            fi

            echo
            read -r -p "Press Enter to continue..."
            ;;

        4)
            get_tasks
            echo
            read -r -p "Enter task number to delete: " num

            if validate_number "$num"; then
                delete_task "$num"
            fi

            echo
            read -r -p "Press Enter to continue..."
            ;;

        5)
            echo "${GREEN}Thank you for using To-Do List Manager!${RESET}"
            exit 0
            ;;

        *)
            echo "${RED}[ERROR] Invalid option. Please choose 1 to 5.${RESET}"
            sleep 2
            ;;
    esac
done