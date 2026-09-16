# WorldDrop

A single-file Street View geography game, solo or with friends. You get dropped somewhere on Earth, drop a pin where you think you are, and score up to 5,000 points per round on GeoGuessr's distance curve.

## Play

**https://silasedel.github.io/pinpoint/** — that's it. Works on any phone or computer, nothing to install.

Offline copy: double-click `run.command`. It serves the game locally, opens a temporary public link through a Cloudflare tunnel, and opens the game in your browser.

## Game modes

Picture tiles on the solo setup screen and in the lobby (multiplayer-only modes appear only in the lobby). Classic is selected by default; click a tile to select it, then press Play or Start.

- **Grayscale**: no color.
- **Blink**: a fixed 120° still is revealed through an eyelid for about a second. 15 seconds to guess.
- **Pixelated**: the panorama rendered to a 128-pixel-wide canvas you drag around.
- **Stranded**: remote regions only, never within 60 km of a big city.
- **Island Hopper**: a curated list of ~85 small islands.
- **Coastline**: ~80 spots on or beside the sea.
- **'Murica**: the United States only.
- **Concrete Jungle**: within about three quarters of a mile of ~45 of the densest city cores.
- **M+**: within about three miles of the center of ~120 cities over a million people.
- **Landmarks**: ~95 world-famous places. Each has a viewpoint with confirmed coverage; the pick stands within about 100 m of it and faces the landmark.
- **Time Machine**: only captures from before 2010, pulled from each spot's imagery history.
- **Snow Globe**: winter captures (Dec–Feb north, Jun–Aug south) in cold regions, and each candidate panorama is checked for actual snow: a low-res tile is sampled on the off-road sides for bright, neutral-to-cool pixels, and only white scenes pass.
- **Countdown**: 30 seconds, and points are worth less the longer you wait (full value at the start, a quarter at zero).
- **Altitude**: high regions only, each pick verified above 2,000 m via open-elevation.
- **All In**: you start with 1,000 chips and must bet every round (1 to everything). Payout is stake × multiplier from the base score: 4,900+ pays 5×, 4,500+ 3×, 3,750+ 2×, 2,500+ returns the stake, 1,250+ returns half, below that loses it. Bankroll is the score; hit zero and the game ends.
- **Odd One Out**: three still views and a map with two pins. Pick the view that has no pin.
- **Two Truths and a Lie**: two still views and a map with three pins. Pick the pin that is the lie.
- **Country**: no pin. The map shows country borders (Natural Earth 50m via world-atlas); hover highlights, click selects. Right country is 5,000, anything else 0. The true country is found by point-in-polygon against the same data.
- **Passport**: every round is in one country, which is only revealed at the end (round result maps use unlabeled imagery and the country name is hidden). Once per game you can stamp a country name; a correct stamp is worth 1,000 × rounds remaining (max 5,000), a wrong one scores nothing and uses up the try.
- **Peek** (multiplayer only): everyone's pins are visible to everyone while guessing, live.

All location picking asks Google for its own imagery only (`StreetViewSource.GOOGLE`), which is what makes country selection even; before that, user-uploaded photospheres were crowding out official coverage in Europe and the US.

## Play with friends (anywhere)

Multiplayer has no server of its own. The host's browser runs the game; messages between players travel through public MQTT brokers over WebSockets (three of them, with automatic failover), which works on any network. Voice uses direct WebRTC links between browsers.

1. The host opens https://silasedel.github.io/pinpoint/ and clicks **Create game**.
2. The host clicks **Copy invite link** and sends it to friends. The invite link opens the game and joins the lobby automatically. Or send the 4-letter code and they click **Join game** on the same site.
3. Everyone picks a name and a color (no two players can share a color). The host picks time, rounds and a mode, and presses Start. The game begins immediately.
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
