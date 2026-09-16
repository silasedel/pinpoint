# Pinpoint

A single-file Street View geography game, solo or with friends. You get dropped somewhere on Earth, drop a pin where you think you are, and score up to 5,000 points per round on GeoGuessr's distance curve.

## Play

**https://silasedel.github.io/pinpoint/** — that's it. Works on any phone or computer, nothing to install.

Offline copy: double-click `run.command`. It serves the game locally, opens a temporary public link through a Cloudflare tunnel, and opens the game in your browser.

## Game modes

Under the main card there are six modes besides Classic. Each has its own Play button, and a host can pick one for a lobby.

- **Blink**: the panorama is revealed through an eyelid that opens for about a second and shuts. 15 seconds to guess from the glimpse.
- **Pixelated**: the panorama is rendered to a 128-pixel-wide canvas you drag around. Shapes and colors only.
- **Stranded**: remote regions only, and any spot inside a town or city is rejected.
- **Island Hopper**: islands only.
- **'Murica**: the United States only.
- **Concrete Jungle**: a random spot within a couple of miles of the center of one of ~100 big cities.

## Play with friends (anywhere)

Multiplayer has no server of its own. The host's browser runs the game; messages between players travel through public MQTT brokers over WebSockets (three of them, with automatic failover), which works on any network. Voice uses direct WebRTC links between browsers.

1. The host opens https://silasedel.github.io/pinpoint/ and clicks **Create game**.
2. The host clicks **Copy invite link** and sends it to friends. The invite link opens the game and joins the lobby automatically. Or send the 4-letter code and they click **Join game** on the same site.
3. Everyone picks a name and a color (no two players can share a color). The host picks time and rounds and presses Start. A 30-second countdown gives people time to finish picking, or the host can start right away.
4. **Voice chat** is built in. The mic button in the bottom-left corner (or the M key) turns your microphone on; click again to mute. It's off until you turn it on, and everyone hears everyone who's live. A green ring shows who's talking.
5. Every round shows the same panorama to everyone. When all guesses are in, or time runs out, the map shows every pin in its player's color with distances, points, and running totals. The host advances rounds. 2 to 10 players.

Running from the launcher instead? It prints a temporary public link (via `cloudflared`) and a same-Wi-Fi address, either of which works the same way.

Game traffic never depends on a direct connection, so joining works from any network. Voice does use direct links, so on unusually strict networks two specific people may not hear each other.

## How it works

- **Street View without an API key.** The keyless Google Maps JS library is used only for `StreetViewService.getPanorama`, which still answers without a key. The panorama is rendered by Google's public embed iframe using the pano ID from that lookup. The embed's place card and controls are covered so they can't leak the answer.
- **Locations** are random points inside ~65 weighted bounding boxes tagged by continent. Each game shuffles the continents and assigns one per round, so five rounds means five different continents. Points snap to the nearest official Google pano within 15 km.
- **Maps** are Leaflet with Esri basemaps (National Geographic style, or satellite with labels), which carry English place names worldwide.
- **Country reveal** uses BigDataCloud's free client reverse geocoder (OpenStreetMap Nominatim as fallback) so a far-off guess in the right country is called out as such.
- **Scoring**: `5000 * e^(-distance_km / 1492.7)`. The solo leaderboard is per mode and lives in localStorage.
- **Voice chat** is a WebRTC audio mesh: every pair of players holds one audio call, carrying a silent track until a mic is turned on, so unmuting just swaps the track.
- **Multiplayer transport** is MQTT over WebSockets via public brokers (EMQX, HiveMQ, Mosquitto), topics keyed by the room code. Heartbeats and last-will messages handle disconnects.
- **Multiplayer** is host-authoritative: the host finds the locations, sends them to everyone at start, collects guesses, scores them, and broadcasts each reveal.
