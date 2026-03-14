#!/bin/bash
EVENT="$1"
MESSAGE="$2"

# Play sound via PowerShell (Windows audio, bypasses WSL ALSA issue)
SOUND_FILE="C:\\Users\\miftahul.huda\\sound-notify\\${EVENT}.wav"
powershell.exe -Command "(New-Object Media.SoundPlayer '${SOUND_FILE}').PlaySync()" 2>/dev/null &

# Send notification via wsl-notify-send.exe
/usr/local/bin/wsl-notify-send.exe --appId "OpenCode" --category "${EVENT}" "${MESSAGE}"

# Send notification via Telegram
TELEGRAM_BOT_TOKEN="8618398587:AAFHmCeKs7cXl8tkuZ6DBeqMwKmBU3nxSq4"
TELEGRAM_CHAT_ID="428937808"
curl -s -X POST "https://api.telegram.org/bot${TELEGRAM_BOT_TOKEN}/sendMessage" \
  -d chat_id="${TELEGRAM_CHAT_ID}" \
  -d text="[${EVENT}] ${MESSAGE}" \
  -d parse_mode="HTML" \
  > /dev/null 2>&1 &