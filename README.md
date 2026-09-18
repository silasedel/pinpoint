# Pinpoint

A single-file Street View geography game — solo, as a duo, or with up to ten friends. You get dropped somewhere on Earth, drop a pin where you think you are, and score up to 5,000 points per round on GeoGuessr's distance curve. Free, no ads, no sign-up needed to play, and an account is a name and a four-digit passcode.

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
- **Duel** (duo only): head to head with 6,000 health each. Both guess the same spot; whoever is further away takes damage equal to the gap in points, times a multiplier that climbs as the duel goes on (×1 for three rounds, then half a point more every two, up to ×5), so it always ends. There's no round count — it's over at a knockout. The HUD swaps the round and score pills for two health bars. Once one player has guessed the other gets fifteen seconds. The host finds locations a few rounds ahead and hands them over as it goes.
- **Blind** (duo only): one of you sees only the street, the other sees only the map, and you talk each other to the pin — voice chat is built in. The host picks who looks and who pins before starting, and roles swap every round by default. The pin counts for both of you; the score is shared.
- **Learn**: its own bar on the home page. A normal game, your choice of time and length, where every round ends with the two or three things that give that place away and where in the country they hold: the side of the road, the colour of the lines and plates, the script on the signs, bollards, houses, land. Ninety-six countries carry hand-written tells, each one saying whether it's nationwide, a region or a city (Japan's red-and-white snow poles mean Hokkaido or the Sea of Japan coast, never the south), and only those countries come up.
- **Lives** (multiplayer only): the same, with three lives each. The farthest guess loses one; you're out at zero. The round counter in the corner becomes your three hearts. Losing one makes that heart swell, shake and drain to grey; losing your last one cracks it down the middle with the split drawing itself in. The reveal banner shows the same hearts breaking and plays a short falling tone for a life lost, a heavier one for being knocked out. Round rankings and final standings show hearts too, with a cracked one for anybody out. The round count is sized to the table so the game can finish.

All location picking asks Google for its own imagery only (`StreetViewSource.GOOGLE`), which is what makes country selection even; before that, user-uploaded photospheres were crowding out official coverage in Europe and the US.

You never get the same spot twice. Regions rotate (the last sixty are skipped), and on top of that every panorama you've been dropped at is remembered — the last 800 — and a lookup that lands on one is thrown back for another point. The daily is exempt, since it has to be identical everywhere.

## Custom maps

Anyone signed in can build a map: give it a name, click spots on a world map (each click snaps to the nearest Street View within a couple of miles and shows a thumbnail), or paste coordinates or a Google Maps link to add one exactly. Two spots minimum, three hundred maximum. Publishing makes it one retained message (`worlddrop/v1/cmap/<id>`) with a shareable link (`?m=<id>`). The **Custom maps** bar under the mode grid — on the solo setup screen and in a lobby — lists every map on the brokers with a search box, sorted by plays. Playing one is Classic scoring over a shuffle of its spots, with your choice of time and length; each map keeps its own small board of best scores rather than touching the mode boards, and the maker can delete it.

## Challenges

Any finished solo or party game (not the daily, not the crowd-only modes) has a **Share** button in the bottom-left corner of the end screen. It opens a small card with one sentence and a link. Whoever opens the link sees the challenge page — who set it, the mode, their score, who else has played — and plays the exact same rounds. After every guess the sharer's pin appears on the result map in their colour with a dashed line, alongside a running comparison, like racing a ghost. The end screen says who won, and the sharer gets a notification (*so-and-so completed your challenge · 19,800 vs your 21,400*) whose **See** button opens the page with a round-by-round table. A challenge is one retained message (`worlddrop/v1/ch/<id>`) holding the locations, the sharer's guesses and everyone's plays; one attempt per person.

## Duo

The home page has three ways in: **Solo**, **Duo** and **Multiplayer**. A duo is a room for exactly two, same code and invite link as a party, with the two duo-only modes — Duel and Blind — first in the grid and every solo mode after them. The lobby calls the other person your opponent (or partner, in Blind).

## Play with friends (anywhere)

Multiplayer has no server of its own. The host's browser runs the game; messages between players travel through public MQTT brokers over WebSockets (three of them, with automatic failover), which works on any network. Voice uses direct WebRTC links between browsers.

1. The host opens https://silasedel.github.io/pinpoint/ and clicks **Create game**.
2. The host clicks **Copy invite link** and sends it to friends. The invite link opens the game and joins the lobby automatically. Or send the 4-letter code and they click **Join game** on the same site.
3. Everyone picks a name and a colour (no two players can share a colour). If you have a profile photo, a thirteenth tile at the front of the tray is your photo, already selected — it becomes your token in the player list, the strip, the standings and the head of your pin. The host picks time, rounds and a mode, and presses Start. The game begins immediately.
4. **Voice chat** is built in. The mic button in the bottom-left corner (or the M key) turns your microphone on; click again to mute. It's off until you turn it on, and everyone hears everyone who's live. A green ring shows who's talking. Next to it is a **room chat**: a typed feed, Twitch-style, open with the speech-bubble button or the C key. Guests send to the host, the host stamps and relays, so everyone sees the same order; joins and leaves show up in it, unread messages count on the button, and the latest one peeks out beside it for a few seconds.
5. Every round shows the same panorama to everyone. When all guesses are in, or time runs out, the map shows every pin in its player's colour with distances, points, and running totals. The host advances rounds. 2 to 10 players. The final map shows every round's real spot and every player's guess for it, each line in that player's colour — for a photo token, the colour that stands out most in the photo.

Running from the launcher instead? It prints a temporary public link (via `cloudflared`) and a same-Wi-Fi address, either of which works the same way.

Game traffic never depends on a direct connection, so joining works from any network. Voice does use direct links, so on unusually strict networks two specific people may not hear each other.

Leaving the name box empty is fine: A browser that never types a name gets its own handle, `Player 100` to `Player 1000`, generated once and kept, and the name box shows it as the placeholder so you know what you'll be called.

## Version

The footer on the home page shows the version as `v<major>.<minor>.<patch>`. Since 3.2.0 the whole app is set in Outfit, one typeface at different weights, the home page leads with the name over the live panorama (one reveal per visit, a new spot on every load), the three cards are Solo, Duo and Multiplayer with a single line each and matching buttons, and Learn and the daily sit under them above today's board. The look since 3.1.1: a pastel-green ground with a soft radial highlight, white cards with a bottom edge, and buttons, bars and tiles that lift on hover and press in on click. The home page runs 1,320px wide on a desktop so Solo, Duo and Multiplayer sit three across at full size; under 1,100px they go two-up with Solo full width, under 640px one column.

- **major** — a ground-up rework. 1 was the original build; 2 was the rebuild of the layout, system and branding; 3 is the social game: duos, challenges, custom maps, streaks and Learn.
- **minor** — a release that adds a capability: a batch of modes, the global leaderboards, the daily drop.
- **patch** — fixes and polish since the last minor.

It's bumped with every change, the build stamp lives in the tooltip, and the same footer holds the credits and the small print.

## Settings

A gear button in the top right of the home page, always reading Settings, opens Settings: your account, a light/dark theme, the map style, text size and sound. The theme is light by default, and every choice is remembered on the device.

## Accounts

Saving a score needs an account, so the leaderboard is a list of people rather than a list of strangers. There's no sign-up service and no server: an account is one retained MQTT message on the same brokers everything else uses (`worlddrop/v1/acct/<name>`), holding a display name, a random salt and a SHA-256 hash of a four-digit code. Claiming a free name publishes that record; typing a name that already exists checks the code against the hash. Signing in stores the name locally, and every score you save — solo, multiplayer or daily — goes up under it on any device you sign in on. Signing out only signs out this browser: the account, its photo and its friends stay put and you can sign back in any time. Until you do you're a numbered player, who can play everything but can't post a score. Your display name can be changed whenever you like; the @handle you sign in with stays fixed so friends and sign-ins keep working. A profile photo is optional: it's cropped square, shrunk to 96 pixels and stored in the same record, so it follows you between devices and shows up next to your name in a lobby. In a room it can be your token instead of a colour, and it sits in the head of your pin; lines take the photo's dominant colour.

**Streaks.** Finish a game on consecutive days (any game — solo, duo, party, daily; days roll at midnight in New York) and the account keeps a day streak. From two days it shows beside your name on the account card with a flame; from five days the number and flame appear next to your name on every leaderboard, for everyone. Miss a day and it's gone. It lives in the account record, so it follows you between devices.

It is deliberately not security: a four-digit code is guessable, the record is public, and the brokers accept writes from anyone. It exists so a name stays yours between devices and a sibling can't type it by accident. There is no code reset, since there's nothing to email.

## Notifications

A bell in the top left of the home page. Four kinds land there: a new daily mission (worked out locally from the date and whether you've played), someone following you (read straight from the follow graph), a game invite, and someone completing your challenge. Invites are the only thing anyone writes into your inbox — one retained message per account (`worlddrop/v1/inbox/<name>`), capped and expiring after a couple of hours. Each row acts: add a friend back, join a room, or play the daily. In a lobby, **Invite friends** lists your friends with their photos and sends one straight to their bell.

## Friends

Follow-based, so nobody ever writes to anybody else's record: your account publishes one retained message listing who you follow (`worlddrop/v1/soc/<name>`). Following someone is the request; when they follow you back you're mutual, which the app calls friends. The Friends screen, reached from Settings, searches a directory built from every account record on the brokers and shows three lists: people waiting for you to add them back, your friends, and requests you've sent that haven't been returned. Removing a friend or cancelling a request is one button, and all of it is just your own list being republished.

## Daily drop

One game a day, the same five locations for everyone, turning over at midnight in New York. The home page gives nothing away: a compass mark, the date, and an Open button, identical whatever the mode is. You only find out what today's mission holds by opening it. The date seeds a small deterministic generator (mulberry32 over a hash of the UTC date) that picks the mode, the time per round, and sometimes a continent or country, then drives the location search itself — every random choice in place picking takes an optional generator, so two browsers with the same date produce byte-identical panorama ids. Rounds are always five. Today's board is its own retained message keyed by the date (`worlddrop/v1/dl/<date>`), so it resets itself at midnight UTC, and a daily result never touches the all-time mode boards. One attempt per device per day: once you've played, the button reads *Already played today* and is disabled until the next drop.

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
- **Pins.** Every guess is a white pin with the player's colour — or photo — in its head. The real location is a bigger red pin with a target in it and a pulsing ring at its foot, so it's never lost among the guesses.
- **Locations** are random points inside ~65 weighted bounding boxes tagged by continent. Each game shuffles the continents and assigns one per round, so five rounds means five different continents. Points snap to the nearest official Google pano within 15 km.
- **Maps** are Leaflet with Esri basemaps (National Geographic style, or satellite with labels), which carry English place names worldwide.
- **Country reveal** uses BigDataCloud's free client reverse geocoder (OpenStreetMap Nominatim as fallback) so a far-off guess in the right country is called out as such.
- **Scoring**: `5000 * e^(-distance_km / 1492.7)`.
- **Leaderboards are global and serverless.** Each mode's board is a single *retained* MQTT message on the same public brokers multiplayer uses (`worlddrop/v1/lb/<mode>`), so a broker holds the latest board and hands it to any client that subscribes. Every client merges what it gets from all three brokers, keeps the top 50, and republishes the merged list, so the brokers converge and one going down loses nothing. Saving a score publishes it immediately and other clients see it live; if you're offline it's queued and posted on reconnect. Incoming entries are validated and capped before they're trusted. Leaving the end screen with an unsaved score asks first: a small prompt offers **Save it** or **Leave anyway**, and an empty name is caught before anything posts. There is one board and it is the public one. Every score a browser saves is also mirrored to localStorage, and on each load the client reconciles that mirror against the public board: anything missing that still qualifies for the top 50 is uploaded, so a score saved offline, interrupted mid-upload, or lost to a broker reset comes back the next time the page opens. Multiplayer scores are saved automatically when the final screen appears, under the player's name with nothing marking it as a party game, and the **View leaderboard** button is there too.
- **Voice chat** is a WebRTC audio mesh: every pair of players holds one audio call, carrying a silent track until a mic is turned on, so unmuting just swaps the track. Incoming voices are played through an EQ chain, so if that audio context is left suspended (a call can arrive with no user gesture behind it, and browsers start such contexts asleep) the client falls back to plain element playback rather than going silent, switches back to the filtered path once the context wakes, and any tap resumes it. ICE offers Google, Cloudflare and Twilio STUN plus two sets of relays, and a failed connection says so instead of failing quietly.
- **Multiplayer transport** is MQTT over WebSockets via public brokers (EMQX, HiveMQ, Mosquitto), topics keyed by the room code. Heartbeats and last-will messages handle disconnects.
- **Multiplayer** is host-authoritative: the host finds the locations, sends them to everyone at start, collects guesses, scores them, and broadcasts each reveal.
