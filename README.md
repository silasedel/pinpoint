# Pinpoint

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
- **All In**: you start with 1,000 chips and bet every round (the stake starts at 0 each round; stack chips, or use Half or All in). Payout is stake × a multiplier that slides with distance: 5 × (base score / 5000)², so a bullseye pays 5×, 100 km 4.4×, 500 km 2.6×, 1,000 km 1.3×, 2,000 km 0.3×. Break-even is about 1,200 km. Bankroll is the score; hit zero and the game ends.
- **Odd One Out**: three wide panoramic strips (150° cylindrical crops) stacked on the left, a map with two pins on the right. Pick the view that has no pin.
- **Two Truths and a Lie**: two wide strips and a map with three pins. Pick the pin that is the lie. The map and the Lock in button stay put; nothing pops up on hover.
- **Country**: no pin. The map shows country borders (Natural Earth 50m via world-atlas); hover highlights, click selects. Right country is 5,000, anything else 0. The true country is found by point-in-polygon against the same data.
- **Capitals**: Country mode, but every drop is inside a capital city (~100 capitals with official coverage, within about 2 km of the centre). Click the country.
- **Temperature**: no map. A slider at the bottom sets your guess for the spot's year-round average temperature in °F. The answer is the mean of every daily mean in a full year of ERA5 reanalysis, fetched per location from Open-Meteo's free archive API. Within 1°F is a bullseye; points fall off exponentially from there.
- **Politics**: no map, two questions per round, 2,500 points each. *Who holds power* has six structural forms (presidential, parliamentary and semi-presidential republics, constitutional monarchy, absolute monarchy, one-party state). *How the economy is run* has four (free-market, social-market and state-led capitalism, socialist economy) — a separate axis, since a country's economic system is not its form of government. Every country in the pool carries both classifications, the round is aimed at a weighted category so republics and free markets don't dominate, and the result screen names both answers with a one-line explanation of each.
- **Deported**: every round drops you in a country that borders the last one, using a land-border graph of the countries the game can reach. A failed lookup can't break the chain: the step is retried, then each neighbour is tried on its own with a wider snap, and only if nothing at all is reachable does it start a new chain — which the result screen says out loud. The result screen also shows the trail so far (Italy → Slovenia → **Austria**) and whether the next round really is a neighbour.
- **Peek** (multiplayer only): everyone's pins are visible to everyone while guessing, live.
- **Battle Royale** (multiplayer only): the farthest guess each round is knocked out. Knocked-out players keep watching but can't guess. Last one standing wins.
- **Lives** (multiplayer only): the same, with three lives each. The farthest guess loses one; you're out at zero. The round count is sized to the table so the game can finish.

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

## Version

The footer on the home page shows the version as `v<major>.<minor>`. Major goes up for a new capability, a batch of modes, or a layout, branding or architecture rework; minor goes up for a fix or a polish pass. It's bumped with every change, the build stamp is in the tooltip, and the same footer holds the credits and the small print.

## Daily drop

One game a day, the same five locations for everyone. The home page gives nothing away: a compass mark, the date, and an Open button, identical whatever the mode is. You only find out what today's mission holds by opening it. The date seeds a small deterministic generator (mulberry32 over a hash of the UTC date) that picks the mode, the time per round, and sometimes a continent or country, then drives the location search itself — every random choice in place picking takes an optional generator, so two browsers with the same date produce byte-identical panorama ids. Rounds are always five. Today's board is its own retained message keyed by the date (`worlddrop/v1/dl/<date>`), so it resets itself at midnight UTC, and a daily result never touches the all-time mode boards. One attempt per device per day: once you've played, the button reads *Already played today* and is disabled until the next drop.

## Where in the world

A picker reached from the solo setup screen and the multiplayer lobby: six continents, then the countries inside one, or anywhere. The choice narrows whatever mode you picked — region names for box-based modes, a bounding-box test for the city and island lists. Modes that already decide the world for you (Deported's border chain, Politics' system targeting, the trio modes) ignore it.

## Copy image

The Copy image button renders the spot as four 90° views in one PNG. The export takes on the mode's look: Grayscale copies come out grey, Pixelated copies come out blocky at the same scale as the round you're playing.

## Feel and rules

- **Sound** is synthesised in the browser with WebAudio, so there are no audio files. Every cue is a warm tone through one soft low-pass bus with slow attacks, so nothing clicks and nothing uses noise: a soft drop when you place a pin, a two-note confirm when you lock in, a low pad on the reveal, a single quiet tone that glides up while the score counts, a chord for a great guess and a fuller one with a high shimmer for a near-perfect. The speaker button in the bottom-left corner mutes it and the choice is remembered.
- **No move** and **Camera lock** are toggles that apply to any mode, on the solo setup screen and in the lobby. No move swaps the Street View embed for an in-page canvas viewer built from the panorama tiles: you can drag to look around and scroll to zoom, but you can't travel. Camera lock goes further and pins one fixed view. The viewer renders at half resolution while you drag and sharpens on release.
- **Percentiles** come from two histograms per mode, kept as one retained MQTT message per mode (`worlddrop/v1/st/<mode>`): single-round scores in 100-point buckets and finished games as a percentage of the maximum. Each client adds only its own samples to whatever it last received, and a percentile stays hidden until a mode has at least 20 samples.
- **On a phone** the guess map has a grab bar: drag it up or down to size the map anywhere between a third and most of the screen, and it snaps to the nearest stop. Tapping the bar cycles through the stops.

## How it works

- **Street View without an API key.** The keyless Google Maps JS library is used only for `StreetViewService.getPanorama`, which still answers without a key. The panorama is rendered by Google's public embed iframe using the pano ID from that lookup. The embed's place card and controls are covered so they can't leak the answer.
- **Locations** are random points inside ~65 weighted bounding boxes tagged by continent. Each game shuffles the continents and assigns one per round, so five rounds means five different continents. Points snap to the nearest official Google pano within 15 km.
- **Maps** are Leaflet with Esri basemaps (National Geographic style, or satellite with labels), which carry English place names worldwide.
- **Country reveal** uses BigDataCloud's free client reverse geocoder (OpenStreetMap Nominatim as fallback) so a far-off guess in the right country is called out as such.
- **Scoring**: `5000 * e^(-distance_km / 1492.7)`.
- **Leaderboards are global and serverless.** Each mode's board is a single *retained* MQTT message on the same public brokers multiplayer uses (`worlddrop/v1/lb/<mode>`), so a broker holds the latest board and hands it to any client that subscribes. Every client merges what it gets from all three brokers, keeps the top 50, and republishes the merged list, so the brokers converge and one going down loses nothing. Saving a score publishes it immediately and other clients see it live; if you're offline it's queued and posted on reconnect. Incoming entries are validated and capped before they're trusted. Leaving the end screen with an unsaved score asks first: a small prompt offers **Save it** or **Leave anyway**, and an empty name is caught before anything posts. There is one board and it is the public one. Every score a browser saves is also mirrored to localStorage, and on each load the client reconciles that mirror against the public board: anything missing that still qualifies for the top 50 is uploaded, so a score saved offline, interrupted mid-upload, or lost to a broker reset comes back the next time the page opens. Multiplayer scores are saved automatically when the final screen appears, under the player's name with nothing marking it as a party game, and the **View leaderboard** button is there too.
- **Voice chat** is a WebRTC audio mesh: every pair of players holds one audio call, carrying a silent track until a mic is turned on, so unmuting just swaps the track.
- **Multiplayer transport** is MQTT over WebSockets via public brokers (EMQX, HiveMQ, Mosquitto), topics keyed by the room code. Heartbeats and last-will messages handle disconnects.
- **Multiplayer** is host-authoritative: the host finds the locations, sends them to everyone at start, collects guesses, scores them, and broadcasts each reveal.
