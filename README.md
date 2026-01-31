# 🎵 SpotDL Auto-Installer for Termux

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Platform](https://img.shields.io/badge/Platform-Android%20(Termux)-green)]()
[![Bash](https://img.shields.io/badge/Language-Bash-blue)]()

**The fastest and easiest way to install [SpotDL](https://github.com/spotDL/spotify-downloader) on Android.**

Installing SpotDL on Termux usually requires compiling Rust, which is slow (15+ minutes), heavy, and error-prone on mobile devices. **This installer fixes that.**

It uses pre-compiled `pydantic-core` wheels from [android-pydantic-core](https://github.com/Eutalix/android-pydantic-core) to install SpotDL in **seconds** instead of minutes.

## ✨ Features

- 🚀 **Fast Install:** Skips Rust compilation completely.
- 📦 **All-in-One:** Automatically installs Python, FFmpeg, and dependencies.
- ⚙️ **Auto-Config:** Sets up downloads to `/sdcard/Music` automatically.
- 📱 **Widget Support:** Can download and set up **Termux:Widget** for one-tap access.
- 🌐 **Web UI Ready:** Pre-configured for SpotDL Web interface.

---

## 🚀 Installation

Open Termux and run this single command:

```bash
curl -sL https://raw.githubusercontent.com/Eutalix/termux-spotdl-installer/main/install_spotdl.sh | bash
```

### What the script does:
1. Grants storage permissions (to save music).
2. Installs Python & FFmpeg.
3. Installs SpotDL using optimized Android wheels.
4. Generates a configuration file optimized for Android.
5. Creates a shortcut script for Termux:Widget.

---

## 🎧 How to Use

### Option 1: Web Interface (Recommended)
This is the easiest way to download music.

1. Run `spotdl web` in Termux.
2. Open your browser to `http://localhost:8800`.
3. Paste a Spotify link and download.

### Option 2: Termux Widget (One-Tap)
If you accepted the Widget installation during setup:

1. Add the **Termux:Widget** to your Android home screen.
2. Select **SpotDL-Web**.
3. It will automatically launch the server and open your browser.

### Option 3: Command Line
You can use standard SpotDL commands:

```bash
spotdl [url]
```

---

## ⚙️ Configuration

The configuration file is automatically created at:
`~/.config/spotdl/config.json`

**Default Settings:**
- **Output:** `/sdcard/Music/{artists}/{album}/{artist} - {title}.mp3`
- **Quality:** 320kbps (MP3)
- **Providers:** YouTube Music, YouTube
- **Lyrics:** Genius, Musixmatch

To edit settings manually:
```bash
nano ~/.config/spotdl/config.json
```

---

## ❓ FAQ / Troubleshooting

**Q: Why do I need this script?**
A: Running `pip install spotdl` on Termux tries to compile Rust code, which often crashes on phones due to memory limits or takes a very long time. This script uses pre-built binaries to bypass that.

**Q: "Address already in use" error?**
A: If `spotdl web` says the port is busy, the Widget script automatically kills old processes (`pkill`) before starting a new one. Just tap the widget again.

**Q: Widget installation failed?**
A: If you installed Termux from **F-Droid**, you must also install Termux:Widget from **F-Droid**. The script tries to download the GitHub APK, which is only compatible if your Termux is also from GitHub.

---

## 🤝 Credits

- **Installer & Wheels:** [Eutalix](https://github.com/Eutalix)
- **SpotDL:** [spotDL Team](https://github.com/spotDL/spotify-downloader)

License: MIT