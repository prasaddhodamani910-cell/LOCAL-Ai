#!/data/data/com.termux/files/usr/bin/bash
# ==============================================================================
#  Local AI One-Command Installer for Termux (Android)
#  Made simple for everyone - No technical skills required!
# ==============================================================================

set -euo pipefail

# --- Model Configuration ---
MODEL_NAME="Qwen_Qwen3-1.7B-Q4_K_M.gguf"
MODEL_URL="https://huggingface.co/bartowski/Qwen_Qwen3-1.7B-GGUF/resolve/main/Qwen_Qwen3-1.7B-Q4_K_M.gguf"
MODEL_SHA256="72c5c3cb38fa32d5256e2fe30d03e7a64c6c79e668ad84057e3bd66e250b24fb"

# --- Parse Arguments ---
DRY_RUN=false
for arg in "$@"; do
  case "$arg" in
    --dry-run)
      DRY_RUN=true
      ;;
    -h|--help)
      echo "Usage: $0 [--dry-run]"
      exit 0
      ;;
  esac
done

# --- Colors & Formatting ---
if [ -t 1 ]; then
  BOLD='\033[1m'
  CYAN='\033[1;36m'
  GREEN='\033[1;32m'
  YELLOW='\033[1;33m'
  RED='\033[1;31m'
  DIM='\033[2m'
  RESET='\033[0m'
else
  BOLD=''
  CYAN=''
  GREEN=''
  YELLOW=''
  RED=''
  DIM=''
  RESET=''
fi

# --- Helper Functions ---
calculate_sha256() {
  local target_file="$1"
  if command -v sha256sum >/dev/null 2>&1; then
    sha256sum "$target_file" | awk '{print $1}'
  elif command -v shasum >/dev/null 2>&1; then
    shasum -a 256 "$target_file" | awk '{print $1}'
  elif command -v openssl >/dev/null 2>&1; then
    openssl dgst -sha256 "$target_file" | awk '{print $NF}'
  else
    echo -e "${RED}❌ Error: No SHA256 checksum tool (sha256sum, shasum, openssl) found.${RESET}" >&2
    return 1
  fi
}

verify_model_checksum() {
  local target_file="$1"
  local expected_hash="$2"

  if [ ! -f "$target_file" ]; then
    return 1
  fi

  local calculated_hash
  calculated_hash=$(calculate_sha256 "$target_file") || return 1

  [ "$calculated_hash" = "$expected_hash" ]
}

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

FREE_KB=$(df "$HOME" 2>/dev/null | awk 'NR==2 {print $4}' || true)
# Need at least 2.5 GB (2621440 KB)
if [ -n "$FREE_KB" ] && [ "$FREE_KB" -lt 2621440 ]; then
  FREE_HUMAN=$(df -h "$HOME" 2>/dev/null | awk 'NR==2 {print $4}' || echo "insufficient")
  echo -e "${RED}❌ Warning: Storage is low!${RESET}" >&2
  echo -e "You have only ${BOLD}$FREE_HUMAN${RESET} free. The AI model requires at least 3 GB of free space." >&2
  echo -e "Please free up some space on your phone and run this command again." >&2
  exit 1
fi

FREE_HUMAN=$(df -h "$HOME" 2>/dev/null | awk 'NR==2 {print $4}' || echo "available")
echo -e "   ${GREEN}✓${RESET} Storage check passed! (${FREE_HUMAN} free)"
echo ""

# --- STEP 2: Install Engine & Tools ---
echo -e "${BOLD}[Step 2 of 4]${RESET} 📦 Setting up AI engine..."
echo -e "   ${DIM}Installing llama-cpp and curl (this is quick)...${RESET}"

if [ "$DRY_RUN" = true ]; then
  echo -e "   ${DIM}[Dry Run] Engine (llama-cli): $(command -v llama-cli || echo "not installed")${RESET}"
  echo -e "   ${DIM}[Dry Run] Download tool (curl): $(command -v curl || echo "not installed")${RESET}"
else
  # Update pkg list if pkg is available
  if command -v pkg >/dev/null 2>&1; then
    pkg update -y >/dev/null 2>&1 || echo -e "   ${YELLOW}⚠️ Notice: Package list update had warnings, continuing...${RESET}"
  fi

  # Install required engine package
  if ! command -v llama-cli >/dev/null 2>&1; then
    if command -v pkg >/dev/null 2>&1; then
      echo -e "   Installing AI engine package..."
      if ! pkg install -y llama-cpp curl coreutils >/dev/null 2>&1; then
        echo -e "${RED}❌ Error: Failed to install llama-cpp via pkg.${RESET}" >&2
        exit 1
      fi
    else
      echo -e "${RED}❌ Error: AI engine 'llama-cli' is not installed and 'pkg' package manager was not found.${RESET}" >&2
      echo -e "This script is designed for Termux on Android. Please install 'llama-cpp' and try again." >&2
      exit 1
    fi
  else
    echo -e "   ${GREEN}✓${RESET} AI engine is already installed!"
  fi

  # Ensure curl is installed
  if ! command -v curl >/dev/null 2>&1; then
    if command -v pkg >/dev/null 2>&1; then
      echo -e "   Installing curl..."
      if ! pkg install -y curl >/dev/null 2>&1; then
        echo -e "${RED}❌ Error: Failed to install curl via pkg.${RESET}" >&2
        exit 1
      fi
    else
      echo -e "${RED}❌ Error: 'curl' is required but not installed and 'pkg' was not found.${RESET}" >&2
      echo -e "Please install 'curl' and run this installer again." >&2
      exit 1
    fi
  fi

  # Verify engine is available
  if ! command -v llama-cli >/dev/null 2>&1; then
    echo -e "${RED}❌ Error: 'llama-cli' is still not found in PATH after installation.${RESET}" >&2
    exit 1
  fi

  echo -e "   ${GREEN}✓${RESET} Engine installed successfully!"
fi
echo ""

# --- STEP 3: Download AI Model ---
echo -e "${BOLD}[Step 3 of 4]${RESET} 🧠 Downloading the AI Brain (Model)..."
echo -e "   ${DIM}Model: Qwen3 1.7B (Compact, fast & smart)${RESET}"
echo -e "   ${DIM}Size: ~1.28 GB (One-time download)${RESET}"
echo ""

MODEL_DIR="$HOME/models"
MODEL_FILE="$MODEL_DIR/$MODEL_NAME"

mkdir -p "$MODEL_DIR"

if [ "$DRY_RUN" = true ]; then
  echo -e "   ${DIM}[Dry Run] Target file: $MODEL_FILE${RESET}"
  echo -e "   ${DIM}[Dry Run] Expected SHA256: $MODEL_SHA256${RESET}"
  if [ -f "$MODEL_FILE" ]; then
    if verify_model_checksum "$MODEL_FILE" "$MODEL_SHA256"; then
      echo -e "   ${GREEN}✓${RESET} [Dry Run] Existing model file is valid."
    else
      echo -e "   ${YELLOW}⚠️ [Dry Run] Existing model file is corrupt or incomplete.${RESET}"
    fi
  else
    echo -e "   ${DIM}[Dry Run] Model file does not exist yet.${RESET}"
  fi
else
  NEED_DOWNLOAD=1
  if [ -f "$MODEL_FILE" ]; then
    echo -e "   🔍 Checking existing model file integrity..."
    if verify_model_checksum "$MODEL_FILE" "$MODEL_SHA256"; then
      echo -e "   ${GREEN}✓${RESET} AI model file already exists and checksum verified! Skipping download."
      NEED_DOWNLOAD=0
    else
      echo -e "   ${YELLOW}⚠️ Existing model file is incomplete or corrupted (checksum mismatch). Re-downloading...${RESET}"
      rm -f "$MODEL_FILE"
    fi
  fi

  if [ "$NEED_DOWNLOAD" -eq 1 ]; then
    echo -e "   ${YELLOW}⬇️ Downloading model now... Please keep Termux open!${RESET}"
    echo ""
    PART_FILE="${MODEL_FILE}.part"
    rm -f "$PART_FILE"

    if ! curl -L --fail --show-error --progress-bar "$MODEL_URL" -o "$PART_FILE"; then
      echo -e "${RED}❌ Error: Failed to download the AI model from $MODEL_URL${RESET}" >&2
      rm -f "$PART_FILE"
      exit 1
    fi

    echo ""
    echo -e "   🔍 Verifying model integrity (SHA256 checksum)..."
    ACTUAL_SHA256=$(calculate_sha256 "$PART_FILE") || {
      echo -e "${RED}❌ Error: Failed to calculate SHA256 checksum of downloaded model.${RESET}" >&2
      rm -f "$PART_FILE"
      exit 1
    }

    if [ "$ACTUAL_SHA256" != "$MODEL_SHA256" ]; then
      echo -e "${RED}❌ Security Error: Model checksum verification failed!${RESET}" >&2
      echo -e "   Expected: $MODEL_SHA256" >&2
      echo -e "   Got:      $ACTUAL_SHA256" >&2
      echo -e "   The downloaded file may be incomplete, corrupted, or tampered with. Removing corrupted file.${RESET}" >&2
      rm -f "$PART_FILE"
      exit 1
    fi

    mv "$PART_FILE" "$MODEL_FILE"
    echo -e "   ${GREEN}✓${RESET} SHA256 checksum verified successfully!"
    echo -e "   ${GREEN}✓${RESET} AI brain downloaded successfully!"
  fi
fi
echo ""

# --- STEP 4: Create Shortcuts ---
echo -e "${BOLD}[Step 4 of 4]${RESET} ⚡ Creating easy shortcuts..."

if [ "$DRY_RUN" = true ]; then
  echo -e "   ${DIM}[Dry Run] Would create $HOME/bin/localai and $HOME/bin/lai${RESET}"
  echo ""
  echo -e "${GREEN}✓ Dry run completed successfully!${RESET}"
  exit 0
fi

mkdir -p "$HOME/bin"

# Create ~/bin/localai
cat > "$HOME/bin/localai" <<EOF
#!/data/data/com.termux/files/usr/bin/bash
MODEL="\$HOME/models/$MODEL_NAME"

if [ ! -f "\$MODEL" ]; then
  echo ""
  echo "❌ AI model not found at \$MODEL"
  echo "Please run the installer again to download it."
  echo ""
  exit 1
fi

exec llama-cli -m "\$MODEL" -c 2048 -n 256 "\$@"
EOF

chmod +x "$HOME/bin/localai" || {
  echo -e "${RED}❌ Error: Failed to set executable permissions on $HOME/bin/localai${RESET}" >&2
  exit 1
}

# Create symlink ~/bin/lai
ln -sf "$HOME/bin/localai" "$HOME/bin/lai" || {
  echo -e "${RED}❌ Error: Failed to create symlink at $HOME/bin/lai${RESET}" >&2
  exit 1
}

# Ensure PATH includes ~/bin
if [ -f "$HOME/.bashrc" ]; then
  if ! grep -q 'HOME/bin' "$HOME/.bashrc" 2>/dev/null; then
    # shellcheck disable=SC2016
    echo 'export PATH="$HOME/bin:$PATH"' >> "$HOME/.bashrc"
  fi
else
  # shellcheck disable=SC2016
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
if [ -t 0 ] && [ -e /dev/tty ]; then
  response=""
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
