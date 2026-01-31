#!/usr/bin/env bash
# install_spotdl.sh
# One-click installer for SpotDL on Termux (Android).
# Uses pre-compiled wheels to skip Rust compilation.

set -e

# --- COLORS ---
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

echo -e "${CYAN}>>> SpotDL Auto-Installer (Optimized) <<<${NC}"
echo -e "${CYAN}>>> Powered by android-pydantic-core <<<${NC}"
echo ""

# 1. Setup Storage
echo -e "${YELLOW}[1/6] Setting up storage permissions...${NC}"
if [ ! -d "/sdcard/Download" ]; then
    echo "Requesting storage access..."
    termux-setup-storage
    echo -e "${RED}Please accept the storage permission in the popup!${NC}"
    echo "Waiting 5 seconds..."
    sleep 5
fi

# 2. System Dependencies
echo -e "${YELLOW}[2/6] Installing system dependencies...${NC}"
echo "Updating packages..."
pkg update -y

# Explicitly installing FFmpeg and Python
PACKAGES="python ffmpeg"
echo "Installing: $PACKAGES"
pkg install $PACKAGES -y

# 3. Install SpotDL (No Rust needed!)
echo -e "${YELLOW}[3/6] Installing SpotDL...${NC}"
echo -e "${CYAN}Using pre-built wheels from Eutalix/android-pydantic-core...${NC}"
pip install spotdl --extra-index-url https://eutalix.github.io/android-pydantic-core/ --no-cache-dir

# 4. Configure SpotDL (Generate & Patch)
echo -e "${YELLOW}[4/6] Configuring SpotDL...${NC}"

CONFIG_DIR="$HOME/.config/spotdl"
CONFIG_FILE="$CONFIG_DIR/config.json"
mkdir -p "$CONFIG_DIR"

# Step A: Remove old config to prevent interactive prompt "Overwrite? (y/n)"
rm -f "$CONFIG_FILE"

# Step B: Generate fresh default config
echo "Generating default configuration..."
spotdl --generate-config

# Step C: Patch JSON using Python (Safe & Robust)
echo "Applying Android-specific settings..."
python3 -c "
import json
import os

config_path = '$CONFIG_FILE'

try:
    with open(config_path, 'r') as f:
        data = json.load(f)
        
    # --- Android Patches ---
    data['output'] = '/sdcard/Music/{artists}/{album}/{artist} - {title}.{output-ext}'
    data['save_file'] = '/sdcard/Music/spotdl.spotdl'
    data['web_use_output_dir'] = True
    data['preload'] = True
    data['bitrate'] = '320k'
    data['format'] = 'mp3'
    
    # Ensure providers list is robust
    data['audio_providers'] = ['youtube-music', 'youtube']
    data['lyrics_providers'] = ['genius', 'musixmatch', 'azlyrics']

    with open(config_path, 'w') as f:
        json.dump(data, f, indent=2)
    print('✅ Configuration patched successfully.')
except Exception as e:
    print(f'❌ Error patching config: {e}')
    exit(1)
"

echo "Config saved to $CONFIG_FILE"

# 5. Termux:Widget Shortcut Creation
echo -e "${YELLOW}[5/6] Creating Widget Shortcut...${NC}"
SHORTCUT_DIR=~/.shortcuts
mkdir -p "$SHORTCUT_DIR"

SCRIPT_PATH="$SHORTCUT_DIR/SpotDL-Web"

cat > "$SCRIPT_PATH" << 'EOF'
#!/data/data/com.termux/files/usr/bin/bash
# Kill previous instances to avoid port errors
pkill -f "spotdl web"
echo "Starting SpotDL Web..."
spotdl web &
PID=$!
sleep 4
echo "Opening Browser..."
am start -a android.intent.action.VIEW -d "http://localhost:8800"
wait $PID
EOF

chmod +x "$SCRIPT_PATH"
echo "Shortcut created at $SCRIPT_PATH"

# 6. Install Termux:Widget App (Robust API Fetch)
echo -e "${YELLOW}[6/6] Termux:Widget App${NC}"
echo -e "Do you want to download and install the ${CYAN}Termux:Widget${NC} app now?"
echo -e "This allows you to launch SpotDL directly from your home screen."
echo -e "${RED}Note: If you installed Termux via F-Droid, you should install the Widget via F-Droid too.${NC}"
echo ""
read -p "Download Widget APK from GitHub? [y/N] " -n 1 -r
echo ""

if [[ $REPLY =~ ^[Yy]$ ]]; then
    echo "Fetching latest APK URL from GitHub API..."
    
    API_URL="https://api.github.com/repos/termux/termux-widget/releases/latest"
    
    JSON_RESPONSE=$(curl -sL -H "User-Agent: TermuxInstaller" "$API_URL")

    # Python parser to find the correct APK
    GET_APK_URL="
import sys, json
try:
    data = json.load(sys.stdin)
    assets = data.get('assets', [])
    best_url = ''
    
    for asset in assets:
        name = asset['name']
        url = asset['browser_download_url']
        
        if name.endswith('.apk'):
            # Prefer debug/github version
            if 'github' in name or 'debug' in name:
                print(url)
                sys.exit(0)
            best_url = url 
            
    if best_url:
        print(best_url)
        sys.exit(0)
        
    sys.exit(1)
except Exception as e:
    sys.exit(1)
"
    WIDGET_URL=$(echo "$JSON_RESPONSE" | python3 -c "$GET_APK_URL")

    if [ -z "$WIDGET_URL" ]; then
        echo -e "${RED}Error: Could not find APK URL in API response.${NC}"
        echo "Try downloading manually from: https://github.com/termux/termux-widget/releases/latest"
    else
        echo "Downloading from: $WIDGET_URL"
        WIDGET_FILE="termux-widget.apk"
        
        if curl -L -H "User-Agent: TermuxInstaller" -o "$WIDGET_FILE" "$WIDGET_URL" --progress-bar; then
            echo "Launching installer..."
            termux-open "$WIDGET_FILE"
            echo -e "${GREEN}Please confirm the installation on your screen.${NC}"
        else
            echo -e "${RED}Failed to download APK.${NC}"
        fi
    fi
else
    echo "Skipping Widget installation."
fi

# Final Summary
echo ""
echo -e "${GREEN}✅ Installation Complete!${NC}"
echo ""
echo -e "To use SpotDL Web:"
echo -e "1. Run command: ${CYAN}spotdl web${NC}"
echo -e "2. OR add the ${CYAN}Termux:Widget${NC} to your home screen and tap 'SpotDL-Web'."
echo ""
echo -e "Music will be saved to: ${YELLOW}/sdcard/Music/${NC}"