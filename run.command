#!/bin/bash
# Double-click to play. Starts the game server, opens a public link for friends anywhere, and opens the game.
cd "$(dirname "$0")"
PORT=8791
LOG="/tmp/pinpoint-tunnel.log"
LAN=$(ipconfig getifaddr en0 2>/dev/null || ipconfig getifaddr en1 2>/dev/null)

cleanup(){ kill $SRV $TUN 2>/dev/null; exit 0; }
trap cleanup INT TERM EXIT

python3 serve.py $PORT &
SRV=$!
sleep 1

PUBLIC=""
if command -v cloudflared >/dev/null 2>&1; then
  rm -f "$LOG"
  cloudflared tunnel --url "http://localhost:$PORT" --no-autoupdate > "$LOG" 2>&1 &
  TUN=$!
  for i in $(seq 1 30); do
    PUBLIC=$(grep -oE 'https://[a-z0-9-]+\.trycloudflare\.com' "$LOG" | head -1)
    [ -n "$PUBLIC" ] && break
    sleep 1
  done
  [ -n "$PUBLIC" ] && sleep 6   # give DNS a moment before opening it
fi

clear
echo ""
echo "  ██████╗ ██╗███╗   ██╗██████╗  ██████╗ ██╗███╗   ██╗████████╗"
echo "  ██╔══██╗██║████╗  ██║██╔══██╗██╔═══██╗██║████╗  ██║╚══██╔══╝"
echo "  ██████╔╝██║██╔██╗ ██║██████╔╝██║   ██║██║██╔██╗ ██║   ██║   "
echo "  ██╔═══╝ ██║██║╚██╗██║██╔═══╝ ██║   ██║██║██║╚██╗██║   ██║   "
echo "  ██║     ██║██║ ╚████║██║     ╚██████╔╝██║██║ ╚████║   ██║   "
echo "  ╚═╝     ╚═╝╚═╝  ╚═══╝╚═╝      ╚═════╝ ╚═╝╚═╝  ╚═══╝   ╚═╝   "
echo ""
if [ -n "$PUBLIC" ]; then
  echo "  PUBLIC LINK (send this to friends anywhere):"
  echo "  $PUBLIC/index.html"
  echo ""
  OPEN="$PUBLIC/index.html"
else
  echo "  No public tunnel (cloudflared not installed or offline)."
  echo "  To get one, run:  brew install cloudflared"
  echo ""
  OPEN="http://localhost:$PORT/index.html"
fi
[ -n "$LAN" ] && echo "  Same Wi-Fi:   http://$LAN:$PORT/index.html"
echo "  This Mac:     http://localhost:$PORT/index.html"
echo ""
echo "  Keep this window open while you play. Close it to stop."
echo ""
open "$OPEN"
wait $SRV
