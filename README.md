# Pinpoint

A single-file Street View geography game, solo or with friends. You get dropped somewhere on Earth, drop a pin where you think you are, and score up to 5,000 points per round on GeoGuessr's distance curve.

## Play

Double-click `run.command`. It starts the game server, opens a public link through a Cloudflare tunnel, and opens the game in your browser. Keep that window open while you play.

## Play with friends (anywhere)

Multiplayer has no server of its own. The host's browser runs the game and the others connect to it directly with WebRTC (PeerJS handles the introductions), so friends can be on any Wi-Fi, in any city.

1. The host double-clicks `run.command` and gets a **public link** like `https://some-words.trycloudflare.com/index.html`. (Needs `cloudflared`, which is installed: `brew install cloudflared`.) The link changes each launch, that's fine.
2. The host clicks **Create game**, then **Copy invite link** and sends it to friends. The invite link opens the game and joins the lobby automatically. Or send the public link plus the 4-letter code and they click **Join game**.
3. Everyone picks a name and a color (no two players can share a color). The host picks time and rounds and presses Start. A 30-second countdown gives people time to finish picking, or the host can start right away.
4. Every round shows the same panorama to everyone. When all guesses are in, or time runs out, the map shows every pin in its player's color with distances, points, and running totals. The host advances rounds. 2 to 10 players.

Same Wi-Fi only? The launcher also prints a `http://10.x.x.x:8791/index.html` address that works without the tunnel.

If two people are behind unusually strict networks the direct WebRTC connection can fail. That's rare on home Wi-Fi and phone data.

## How it works

- **Street View without an API key.** The keyless Google Maps JS library is used only for `StreetViewService.getPanorama`, which still answers without a key. The panorama is rendered by Google's public embed iframe using the pano ID from that lookup. The embed's place card and controls are covered so they can't leak the answer.
- **Locations** are random points inside ~65 weighted bounding boxes tagged by continent. Each game shuffles the continents and assigns one per round, so five rounds means five different continents. Points snap to the nearest official Google pano within 15 km.
- **Maps** are Leaflet with Esri basemaps (National Geographic style, or satellite with labels), which carry English place names worldwide.
- **Country reveal** uses BigDataCloud's free client reverse geocoder (OpenStreetMap Nominatim as fallback) so a far-off guess in the right country is called out as such.
- **Scoring**: `5000 * e^(-distance_km / 1492.7)`. The solo leaderboard is per mode and lives in localStorage.
- **Multiplayer** is host-authoritative: the host finds the locations, sends them to everyone at start, collects guesses, scores them, and broadcasts each reveal.
