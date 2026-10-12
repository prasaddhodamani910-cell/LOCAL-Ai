#!/data/data/com.termux/files/usr/bin/bash
# ==============================================================================
#  Local AI One-Command Installer for Termux (Android)
#  Made simple for everyone - No technical skills required!
# ==============================================================================

set -e

# --- Colors & Formatting ---
if [ -t 1 ]; then
  BOLD='\033[1m'
  CYAN='\033[1;36m'
  GREEN='\033[1;32m'
  YELLOW='\033[1;33m'
  RED='\033[1;31m'
  MAGENTA='\033[1;35m'
  DIM='\033[2m'
  RESET='\033[0m'
else
  BOLD=''
  CYAN=''
  GREEN=''
  YELLOW=''
  RED=''
  MAGENTA=''
  DIM=''
  RESET=''
fi

clear 2>/dev/null || true

echo -e "${CYAN}"
echo "╔══════════════════════════════════════════════════════════════╗"
echo "║                                                              ║"
echo "║          ✨  OFFLINE LOCAL AI ONE-CLICK SETUP  ✨            ║"
echo "║               Chat with AI on your phone                     ║"
echo "║               100% Free • Private • Offline                  ║"
echo "║                                                              ║"
echo "╚══════════════════════════════════════════════════════════════╝"
echo -e "${RESET}"

echo -e "${BOLD}Welcome!${RESET} This will set up an AI directly on your phone."
echo -e "You will be able to talk to it anytime, ${GREEN}even without internet or Wi-Fi${RESET}."
echo ""
echo -e "${DIM}Setup takes about 5-10 minutes depending on your internet speed.${RESET}"
echo "--------------------------------------------------------------"
echo ""

# --- STEP 1: Storage Space Check ---
echo -e "${BOLD}[Step 1 of 4]${RESET} 🔍 Checking phone storage space..."

FREE_KB=$(df "$HOME" | awk 'NR==2 {print $4}')
# Need at least 2.5 GB (2621440 KB)
if [ "$FREE_KB" -lt 2621440 ]; then
  FREE_HUMAN=$(df -h "$HOME" | awk 'NR==2 {print $4}')
  echo -e "${RED}❌ Warning: Storage is low!${RESET}"
  echo -e "You have only ${BOLD}$FREE_HUMAN${RESET} free. The AI model requires at least 3 GB of free space."
  echo -e "Please free up some space on your phone and run this command again."
  exit 1
fi

FREE_HUMAN=$(df -h "$HOME" | awk 'NR==2 {print $4}')
echo -e "   ${GREEN}✓${RESET} Storage check passed! (${FREE_HUMAN} free)"
echo ""

# --- STEP 2: Install Engine & Tools ---
echo -e "${BOLD}[Step 2 of 4]${RESET} 📦 Setting up AI engine..."
echo -e "   ${DIM}Installing llama-cpp and curl (this is quick)...${RESET}"

# Update pkg list quietly
pkg update -y >/dev/null 2>&1 || true

# Install required packages
if ! command -v llama-cli >/dev/null 2>&1; then
  echo -e "   Installing AI engine package..."
  pkg install -y llama-cpp curl >/dev/null 2>&1
else
  echo -e "   ${GREEN}✓${RESET} AI engine is already installed!"
fi

# Ensure curl is installed
if ! command -v curl >/dev/null 2>&1; then
  pkg install -y curl >/dev/null 2>&1
fi

echo -e "   ${GREEN}✓${RESET} Engine installed successfully!"
echo ""

# --- STEP 3: Download AI Model ---
echo -e "${BOLD}[Step 3 of 4]${RESET} 🧠 Downloading the AI Brain (Model)..."
echo -e "   ${DIM}Model: Qwen3 1.7B (Compact, fast & smart)${RESET}"
echo -e "   ${DIM}Size: ~1.28 GB (One-time download)${RESET}"
echo ""

MODEL_DIR="$HOME/models"
MODEL_FILE="$MODEL_DIR/Qwen_Qwen3-1.7B-Q4_K_M.gguf"
MODEL_URL="https://huggingface.co/bartowski/Qwen_Qwen3-1.7B-GGUF/resolve/main/Qwen_Qwen3-1.7B-Q4_K_M.gguf"

mkdir -p "$MODEL_DIR"

if [ -f "$MODEL_FILE" ] && [ "$(wc -c < "$MODEL_FILE" 2>/dev/null || stat -c%s "$MODEL_FILE" 2>/dev/null || echo 0)" -gt 1000000000 ]; then
  echo -e "   ${GREEN}✓${RESET} AI model file already exists! Skipping download."
else
  echo -e "   ${YELLOW}⬇️ Downloading model now... Please keep Termux open!${RESET}"
  echo ""
  curl -L --fail --show-error --progress-bar "$MODEL_URL" -o "$MODEL_FILE"
  echo ""
  echo -e "   ${GREEN}✓${RESET} AI brain downloaded successfully!"
fi
echo ""

# --- STEP 4: Create Shortcuts ---
echo -e "${BOLD}[Step 4 of 4]${RESET} ⚡ Creating easy shortcuts..."

mkdir -p "$HOME/bin"

# Create ~/bin/localai
cat > "$HOME/bin/localai" <<'EOF'
#!/data/data/com.termux/files/usr/bin/bash
MODEL="$HOME/models/Qwen_Qwen3-1.7B-Q4_K_M.gguf"

if [ ! -f "$MODEL" ]; then
  echo ""
  echo "❌ AI model not found at $MODEL"
  echo "Please run the installer again to download it."
  echo ""
  exit 1
fi

exec llama-cli -m "$MODEL" -c 2048 -n 256 "$@"
EOF

chmod +x "$HOME/bin/localai"

# Create symlink ~/bin/lai
ln -sf "$HOME/bin/localai" "$HOME/bin/lai"

# Ensure PATH includes ~/bin
if ! grep -q 'HOME/bin' "$HOME/.bashrc" 2>/dev/null; then
  echo 'export PATH="$HOME/bin:$PATH"' >> "$HOME/.bashrc"
fi
export PATH="$HOME/bin:$PATH"

echo -e "   ${GREEN}✓${RESET} Shortcuts created: ${BOLD}lai${RESET} and ${BOLD}localai${RESET}"
echo ""

# --- Completion Screen ---
echo -e "${GREEN}"
echo "╔══════════════════════════════════════════════════════════════╗"
echo "║                                                              ║"
echo "║               🎉 SETUP COMPLETE! CONGRATS! 🎉                ║"
echo "║                                                              ║"
echo "║  Your local AI is now ready to use on your phone!            ║"
echo "║                                                              ║"
echo "╚══════════════════════════════════════════════════════════════╝"
echo -e "${RESET}"

echo -e "${BOLD}How to chat with your AI anytime:${RESET}"
echo -e "  Simply type:  ${CYAN}${BOLD}lai${RESET}   or   ${CYAN}${BOLD}localai${RESET}"
echo ""
echo -e "${BOLD}Tips:${RESET}"
echo -e "  • ${GREEN}100% Offline:${RESET} You can turn off Wi-Fi and Mobile Data now."
echo -e "  • ${YELLOW}To exit the AI:${RESET} Press ${BOLD}Ctrl+C${RESET} or type ${BOLD}/exit${RESET}."
echo -e "  • ${DIM}Private:${RESET} Nothing leaves your device. No account or key needed."
echo ""

# Optional immediate launch if running in an interactive terminal
if [ -t 0 ] || [ -e /dev/tty ]; then
  read -r -p "Would you like to start chatting with your AI right now? [Y/n] " response </dev/tty || response="n"
  case "$response" in
    [yY][eE][sS]|[yY]|"")
      echo ""
      echo -e "${CYAN}Starting AI... Have fun!${RESET}"
      exec "$HOME/bin/localai"
      ;;
    *)
      echo ""
      echo -e "No problem! Whenever you are ready, just type ${CYAN}lai${RESET} and press Enter."
      ;;
  esac
fi
