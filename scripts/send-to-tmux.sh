#!/usr/bin/env bash
# Zed-SLIME: Send clipboard content to tmux pane
# Similar to vim-slime's tmux target

set -euo pipefail

# Configuration (can be overridden by environment variables)
TMUX_SOCKET="${SLIME_TMUX_SOCKET:-default}"
TMUX_PANE="${SLIME_TMUX_PANE:-}"  # Required, empty default to check later
AUTO_ENTER="${SLIME_AUTO_ENTER:-1}"
DEBUG="${SLIME_DEBUG:-0}"

# Color codes for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

log_debug() {
    if [ "$DEBUG" = "1" ]; then
        echo -e "${YELLOW}[DEBUG]${NC} $1" >&2
    fi
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1" >&2
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1" >&2
}

# Check if tmux pane is configured
if [ -z "${TMUX_PANE:-}" ]; then
    log_error "SLIME_TMUX_PANE not set"
    echo "Usage: Set SLIME_TMUX_PANE environment variable"
    echo "Example: export SLIME_TMUX_PANE=':.1'"
    echo ""
    echo "Available panes:"
    tmux -L "$TMUX_SOCKET" list-panes -a -F '#{pane_id} #{session_name}:#{window_index}.#{pane_index} #{pane_title}' 2>/dev/null || echo "  (no tmux session found)"
    exit 1
fi

log_debug "Socket: $TMUX_SOCKET, Pane: $TMUX_PANE"

# Check if tmux is running
if ! tmux -L "$TMUX_SOCKET" info &> /dev/null; then
    log_error "tmux session not found (socket: $TMUX_SOCKET)"
    exit 1
fi

# Check if target pane exists
if ! tmux -L "$TMUX_SOCKET" list-panes -a -F '#{pane_id}' | grep -q "${TMUX_PANE#*:}"; then
    log_error "Target pane '$TMUX_PANE' not found"
    echo ""
    echo "Available panes:"
    tmux -L "$TMUX_SOCKET" list-panes -a -F '  #{pane_id} #{session_name}:#{window_index}.#{pane_index} #{pane_title}'
    exit 1
fi

# Get clipboard content based on OS
log_debug "Reading clipboard..."
if [[ "$OSTYPE" == "darwin"* ]]; then
    # macOS
    CONTENT=$(pbpaste)
elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
    # Linux - try multiple clipboard utilities
    if command -v xclip &> /dev/null; then
        CONTENT=$(xclip -selection clipboard -o)
    elif command -v xsel &> /dev/null; then
        CONTENT=$(xsel --clipboard --output)
    elif command -v wl-paste &> /dev/null; then
        # Wayland
        CONTENT=$(wl-paste)
    else
        log_error "No clipboard utility found (install xclip, xsel, or wl-clipboard)"
        exit 1
    fi
else
    log_error "Unsupported OS: $OSTYPE"
    exit 1
fi

# Check if content is empty
if [ -z "$CONTENT" ]; then
    log_error "Clipboard is empty"
    exit 1
fi

log_debug "Clipboard content (${#CONTENT} chars):"
if [ "$DEBUG" = "1" ]; then
    echo "$CONTENT" | head -c 200 >&2
    [ ${#CONTENT} -gt 200 ] && echo "..." >&2
fi

# Send to tmux using load-buffer + paste-buffer
# This mimics vim-slime's approach
log_debug "Loading into tmux buffer..."
echo "$CONTENT" | tmux -L "$TMUX_SOCKET" load-buffer -

log_debug "Pasting to pane $TMUX_PANE..."
tmux -L "$TMUX_SOCKET" paste-buffer -d -t "$TMUX_PANE"

# Send Enter key to execute
if [ "$AUTO_ENTER" = "1" ]; then
    log_debug "Sending Enter key..."
    tmux -L "$TMUX_SOCKET" send-keys -t "$TMUX_PANE" Enter
fi

log_success "Sent $(echo "$CONTENT" | wc -l | tr -d ' ') line(s) to pane $TMUX_PANE"
