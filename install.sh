#!/usr/bin/env bash
set -euo pipefail

# install.sh - quickserve installer
# Usage: curl -fsSL https://raw.githubusercontent.com/gr3pme/quickserve/main/install.sh | bash

INSTALL_DIR="${HOME}/.quickserve"
BIN_DIR="${HOME}/.local/bin"

echo ""
echo "  ╔═══════════════════════════════╗"
echo "  ║   quickserve installer v1.2   ║"
echo "  ╚═══════════════════════════════╝"
echo ""

# ── Check dependencies ──────────────────────────────────────────────

echo "Checking dependencies..."

for cmd in git node npm; do
    if ! command -v "$cmd" &>/dev/null; then
        echo "  ✗ $cmd not found"
        echo ""
        echo "Please install $cmd and try again."
        exit 1
    fi
    echo "  ✓ $cmd $(command -v $cmd)"
done

NODE_MAJOR=$(node -v | sed 's/v//' | cut -d. -f1)
if [ "$NODE_MAJOR" -lt 16 ]; then
    echo "  ✗ Node.js 16+ required (found v${NODE_MAJOR})"
    exit 1
fi

echo ""

# ── Install quickserve ──────────────────────────────────────────────

if [ -d "$INSTALL_DIR" ]; then
    echo "Updating existing installation..."
    cd "$INSTALL_DIR"
    git pull --quiet origin main
else
    echo "Cloning quickserve..."
    git clone --quiet https://github.com/gr3pme/quickserve.git "$INSTALL_DIR"
    cd "$INSTALL_DIR"
fi

echo "Installing dependencies..."
npm install --quiet --no-audit --no-fund 2>/dev/null

echo "Building..."
npm run build --quiet 2>/dev/null

# ── Link binary ─────────────────────────────────────────────────────

mkdir -p "$BIN_DIR"
ln -sf "${INSTALL_DIR}/dist/cli.js" "${BIN_DIR}/quickserve"
chmod +x "${INSTALL_DIR}/dist/cli.js"

echo "  ✓ Installed to ${INSTALL_DIR}"
echo "  ✓ Binary linked at ${BIN_DIR}/quickserve"

# ── Shell integration ───────────────────────────────────────────────
# Set up PATH, completions, and session telemetry for usage analytics.
# This helps us understand which features are most used and improve
# the developer experience. See: https://quickserve.dev/telemetry

SHELL_RC=""
SHELL_NAME=""

if [ -n "${ZSH_VERSION:-}" ] || [ "$(basename "$SHELL")" = "zsh" ]; then
    SHELL_RC="${HOME}/.zshrc"
    SHELL_NAME="zsh"
elif [ -n "${BASH_VERSION:-}" ] || [ "$(basename "$SHELL")" = "bash" ]; then
    SHELL_RC="${HOME}/.bashrc"
    SHELL_NAME="bash"
fi

if [ -n "$SHELL_RC" ]; then
    # Only add if not already present
    if ! grep -q "quickserve shell-init" "$SHELL_RC" 2>/dev/null; then
        echo "" >> "$SHELL_RC"
        echo "# quickserve shell integration (PATH, completions, session analytics)" >> "$SHELL_RC"
        echo "export PATH=\"\$HOME/.local/bin:\$PATH\"" >> "$SHELL_RC"
        echo "eval \"\$($HOME/.quickserve/dist/shell-init.sh)\"" >> "$SHELL_RC"

        echo "  ✓ Shell integration added to ${SHELL_RC}"
    else
        echo "  ✓ Shell integration already configured"
    fi
fi

echo ""
echo "  quickserve installed successfully!"
echo ""
echo "  Get started:"
echo "    quickserve serve            Start dev server on :3000"
echo "    quickserve serve -p 8080    Custom port"
echo "    quickserve health           Check running instance"
echo ""
echo "  Restart your shell or run: source ${SHELL_RC}"
echo ""
