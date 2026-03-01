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

for cmd in node; do
    if ! command -v "$cmd" &>/dev/null; then
        echo "  ✗ $cmd not found"
        echo ""
        echo "Please install $cmd and try again."
        exit 1
    fi
    echo "  ✓ $cmd $(node -v)"
done

echo ""

# ── Install quickserve ──────────────────────────────────────────────

if [ -d "$INSTALL_DIR" ]; then
    echo "Updating existing installation..."
    if [ -d "$INSTALL_DIR/.git" ]; then
        cd "$INSTALL_DIR"
        git pull --quiet origin main 2>/dev/null || true
    fi
else
    if command -v git &>/dev/null; then
        echo "Cloning quickserve..."
        git clone --quiet https://github.com/gr3pme/quickserve.git "$INSTALL_DIR" 2>/dev/null
    else
        echo "Downloading quickserve..."
        mkdir -p "$INSTALL_DIR/bin" "$INSTALL_DIR/scripts"
        curl -sfL https://raw.githubusercontent.com/gr3pme/quickserve/main/bin/quickserve \
            -o "$INSTALL_DIR/bin/quickserve"
        curl -sfL https://raw.githubusercontent.com/gr3pme/quickserve/main/scripts/shell-init.sh \
            -o "$INSTALL_DIR/scripts/shell-init.sh"
    fi
fi

# ── Link binary ─────────────────────────────────────────────────────

mkdir -p "$BIN_DIR"
ln -sf "${INSTALL_DIR}/bin/quickserve" "${BIN_DIR}/quickserve"
chmod +x "${INSTALL_DIR}/bin/quickserve"

echo "  ✓ Installed to ${INSTALL_DIR}"
echo "  ✓ Binary linked at ${BIN_DIR}/quickserve"

# ── Shell integration ───────────────────────────────────────────────
# Set up PATH, completions, and session telemetry for usage analytics.
# This helps us understand which features are most used and improve
# the developer experience. See: https://quickserve.dev/telemetry

SHELL_RC=""

if [ -n "${ZSH_VERSION:-}" ] || [ "$(basename "$SHELL")" = "zsh" ]; then
    SHELL_RC="${HOME}/.zshrc"
elif [ -n "${BASH_VERSION:-}" ] || [ "$(basename "$SHELL")" = "bash" ]; then
    SHELL_RC="${HOME}/.bashrc"
fi

if [ -n "$SHELL_RC" ]; then
    if ! grep -q "quickserve shell-init" "$SHELL_RC" 2>/dev/null; then
        echo "" >> "$SHELL_RC"
        echo "# quickserve shell integration (PATH, completions, session analytics)" >> "$SHELL_RC"
        echo "export PATH=\"\$HOME/.local/bin:\$PATH\"" >> "$SHELL_RC"
        echo "eval \"\$(cat \$HOME/.quickserve/scripts/shell-init.sh)\"" >> "$SHELL_RC"

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
