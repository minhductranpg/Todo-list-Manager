data="todo.txt"
storage(){
if [ ! -f "$data"]; then
touch "$data"
fi
}
#--------------------------
# READ TASKS
#--------------------------
get_tasks(){
storage
if [! -s "$data"]; then
echo "[INFO] No tasks in your list"
return 1
fi
echo "------------------------"
nl -w2 -s ". " "$data"
echo "------------------------"
return 0
}
#-------------------------
# CREATE TASK
#-------------------------
add_task(){
local task = "$1"
if [ -z "$task"]; then
echo "[ERROR] Task content may not be empty!"
return 1
fi
storage
local created
created=$(date "+%Y-%m-%d %H:%M")
echo "[PENDING] $task | $created" >> "$data"
echo "[SUCCESS] Task added: \"task\""
return 0
}
#-------------------------
# UPDATE TASK COMPLETE
#-------------------------
update_task(){
local num="$1"
storage
if [ ! -s "$data" ]; then
echo "[ERROR] Task list is empty, not updated"
return 1
fi
local lines
lines=$(wc -l < "$data" | tr -d ' ')
# Check index number
if [ -z "$num"] || ! [[ "$num" =~ ^[0-9]+$ ]] || [ "$num" -lt -1 ] || [ "$num" -gt "$lines" ]; then
echo "[ERROR] Invalid task number: \"$num\"!"
return 1
fi
if grep -n "^" "$data" | grep -q "^${num}:.*\[DONE\]"; then
echo "[INFO] #$num is completed"
else
sed -i "${num}s/\[PENDING\]/\[DONE\]/" "$data"
echo "[SUCCESS] Task #$num marked completed"
fi
}
#------------------------
# DELETE
#------------------------
delete_task(){
local num="$1"
storage
if [ ! -s "$data" ]; then
echo "[ERROR] Task list is empty, nothing to delete!"
return 1
fi
local lines
total_lines=$(wc -l < "$data" | tr -d ' ')
if [ -z "$num" ] || ! [[ "$num" =~ ^[0-9]+$ ]] || [ "$num" -lt 1 ] || [ "$num" -gt "$lines" ]; then
echo "[ERROR] Invalid task number: \"$num\"!"
return 1
fi
# Delete line
sed -i "${num}d" "data"
echo "[SUCCESS] Task #$num deleted completed!"
return 0
}