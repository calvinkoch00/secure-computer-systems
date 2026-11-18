#!/bin/bash

# Ensure we use unbuffered python output (-u) so prints appear immediately before the pause
if command -v python3 &>/dev/null; then
    PY_CMD="python3 -u"
else
    PY_CMD="python -u"
fi

TARGET_DIR="tocttou"
TARGET_FILE="$TARGET_DIR/temp_file.txt"
PY_SCRIPT="tocttou_app.py"

# Helper function to print file content
print_file_content() {
    echo "[After] Reading file content:"
    echo "---"
    if [ -f "$TARGET_FILE" ]; then
        cat "$TARGET_FILE"
    else
        echo "File does not exist or cannot be read."
    fi
    echo "---"
}

cat << 'EOF' > "$PY_SCRIPT"
import sys

filepath = sys.argv[1]

# ANSI color codes for better terminal output
G = "\033[92m"   # Light Green
RED = "\033[91m" # Light Red
R = "\033[0m"    # Reset back to default

try:
    print(f"{G}[*] Python: Opening '{filepath}' for writing...{R}")
    fd = open(filepath, "w")
    
    print(f"{G}[!] Python: Paused. (Bash is performing TOCTTOU modifications...) Press Enter...{R}")
    input()
    
    print(f"{G}[*] Python: Writing to file descriptor...{R}")
    fd.write("This Data was written during the TOCTTOU test.\n")
    fd.close()
    print(f"{G}[+] Python: File closed successfully.\n{R}")
except Exception as e:
    print(f"{RED}[-] Python Error: {e}\n{R}")
EOF

mkdir -p "$TARGET_DIR"

echo "========================================================"
echo "Test 1: Normal execution (Write permissions allowed) "
echo "========================================================"
touch "$TARGET_FILE"
chmod u+w "$TARGET_FILE"
echo "[Before] Permissions:"
ls -l "$TARGET_FILE"
(
    sleep 1
    # >&2 redirects Bash prints to the terminal so they don't get sent to Python's input
    echo ">>> [Bash Action] No modifications made during pause." >&2
    echo "Sending enter key..." >&2
    echo ""
) | $PY_CMD "$PY_SCRIPT" "$TARGET_FILE"
print_file_content


echo -e "\n========================================================"
echo " Test 2: Revoke write permissions during TOCTTOU pause "
echo "========================================================"
# Recreate/clear file for a fresh test and ensure write permissions are granted
echo -n > "$TARGET_FILE"
chmod u+w "$TARGET_FILE"
echo "[Before] Permissions:"
ls -l "$TARGET_FILE"
(
    sleep 1
    echo ">>> [Bash Action] Revoking write permissions (chmod u-w)..." >&2
    chmod u-w "$TARGET_FILE"
    ls -l "$TARGET_FILE" >&2
    echo "Sending enter key..." >&2
    echo ""
) | $PY_CMD "$PY_SCRIPT" "$TARGET_FILE"
print_file_content


echo -e "\n========================================================"
echo " Test 3a: Run without write permissions from the start "
echo "========================================================"
echo "[Before] Permissions (Should still be revoked from Test 2):"
ls -l "$TARGET_FILE"
(
    sleep 1
    echo ">>> [Bash Action] Sending enter key..." >&2
    echo "" 
) | $PY_CMD "$PY_SCRIPT" "$TARGET_FILE"
print_file_content


echo -e "\n========================================================"
echo " Test 3b: Delete the file during TOCTTOU pause         "
echo "========================================================"
# Give write permissions back before starting
chmod u+w "$TARGET_FILE"
echo "[Before] Permissions:"
ls -l "$TARGET_FILE"
(
    sleep 1
    echo ">>> [Bash Action] Deleting the file (rm)..." >&2
    rm "$TARGET_FILE" 2>/dev/null || echo ">>> [Bash Action] Failed to delete file (OS Locked File)" >&2
    ls -l "$TARGET_FILE" 2>&1 >&2
    echo "Sending enter key..." >&2
    echo ""
) | $PY_CMD "$PY_SCRIPT" "$TARGET_FILE"
print_file_content


# Cleanup
echo -e "\n[*] Cleaning up environment..."
rm -f "$PY_SCRIPT"
rm -rf "$TARGET_DIR"