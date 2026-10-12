# 🤖 Local AI on Android (Termux)

> Run your own smart AI chat directly on your Android phone — **100% Free, Private, and completely Offline!** No internet, no subscriptions, and no coding knowledge needed.

---

## ⚡ Quick 1-Command Install

Open the **Termux** app on your phone, paste this single command, and press **Enter**:

```bash
curl -sL https://raw.githubusercontent.com/prasaddhodamani910-cell/LOCAL-Ai/main/install.sh | bash
```

That's it! The script will automatically:
1. 🔍 Check that your phone has enough free storage space.
2. 📦 Install the AI engine.
3. 🧠 Download the AI brain model (Qwen3 1.7B) with a real-time progress bar.
4. ⚡ Create simple shortcut commands (`lai` and `localai`).

---

## 💬 How to Chat with Your AI

Whenever you want to talk to your AI:

1. Open **Termux**
2. Type:
   ```bash
   lai
   ```
   *(or `localai`)*
3. Press **Enter** and start asking questions!

### 🛑 How to Exit
Press **`Ctrl` + `C`** on your keyboard (or type `/exit`) to close the AI chat.

---

## 📴 Yes, It Really Works Offline!

After the one-time setup:
1. Turn off your **Wi-Fi**
2. Turn off your **Mobile Data** (put phone on Airplane Mode if you want)
3. Type `lai` in Termux

The AI runs **100% locally** on your phone's processor. No data is sent to the internet or any server.

---

## 📋 What You Need

| Requirement | Details |
|---|---|
| **Device** | Any Android phone (Samsung, Xiaomi, OnePlus, Pixel, etc.) |
| **App** | [Termux](https://termux.dev/) (installed from F-Droid or GitHub) |
| **Storage** | At least **3 GB free storage** |
| **RAM** | **4 GB or more** (6 GB+ recommended for best speed) |
| **Internet** | Only required once during the initial setup download |

---

## ❓ Frequently Asked Questions (FAQ)

### Does this cost money?
**No.** It is completely free and open source. There are no fees, accounts, or subscriptions.

### Is my data private?
**Yes, 100% private.** Because the AI runs entirely on your phone's hardware, your questions and answers never leave your device.

### Can I ask it questions in different languages?
**Yes!** The Qwen AI model understands multiple languages including English, Hindi, Spanish, French, and many more.

### What should I do if it says "No space left on device"?
Make sure you have at least 3 GB of free internal storage on your phone before running the installer.

---

## 🛠️ Manual Alternative

If you already downloaded the repository files onto your phone:

```bash
cd local-ai-termux
chmod +x install.sh
./install.sh
```

---

## 📄 License

MIT License — Free to use, modify, and share!
