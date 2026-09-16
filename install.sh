#!/data/data/com.termux/files/usr/bin/bash

set -e

PROJECT_DIR="$HOME/KurdTerm-Pro-v3"
INSTALL_DIR="$HOME/.kurdterm-v3"
BIN_DIR="$PREFIX/bin"

echo
echo "======================================"
echo "       KURDTERM PRO v3.0"
echo "          INSTALLER"
echo "======================================"
echo

if [ ! -f "$PROJECT_DIR/kurdterm.sh" ]; then
    echo "[ERROR] kurdterm.sh not found."
    echo "Expected:"
    echo "$PROJECT_DIR/kurdterm.sh"
    exit 1
fi

if [ ! -f "$PROJECT_DIR/config.conf" ]; then
    echo "[ERROR] config.conf not found."
    echo "Expected:"
    echo "$PROJECT_DIR/config.conf"
    exit 1
fi

echo "[1/5] Creating directories..."

mkdir -p "$INSTALL_DIR"
mkdir -p "$INSTALL_DIR/plugins"
mkdir -p "$PROJECT_DIR/projects"
mkdir -p "$PROJECT_DIR/backups"

echo "[2/5] Installing application files..."

cp -f "$PROJECT_DIR/kurdterm.sh" "$INSTALL_DIR/kurdterm.sh"
cp -f "$PROJECT_DIR/config.conf" "$INSTALL_DIR/config.conf"

echo "[3/5] Setting permissions..."

chmod 700 "$INSTALL_DIR/kurdterm.sh"
chmod 600 "$INSTALL_DIR/config.conf"

echo "[4/5] Creating launcher..."

cat > "$BIN_DIR/kurdterm3" <<'EOF'
#!/data/data/com.termux/files/usr/bin/bash

exec bash "$HOME/.kurdterm-v3/kurdterm.sh" "$@"
EOF

chmod 755 "$BIN_DIR/kurdterm3"

echo "[5/5] Verifying installation..."

if [ -x "$INSTALL_DIR/kurdterm.sh" ] && [ -x "$BIN_DIR/kurdterm3" ]; then
    echo
    echo "======================================"
    echo "   INSTALLATION SUCCESSFUL"
    echo "======================================"
    echo
    echo "Version : 3.0.0"
    echo "Install : $INSTALL_DIR"
    echo "Launcher: kurdterm3"
    echo
    echo "Run the application with:"
    echo
    echo "    kurdterm3"
    echo
else
    echo
    echo "[ERROR] Installation verification failed."
    exit 1
fi
