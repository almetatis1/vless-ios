# FoxyWall VPN — UX/UI Redesign Proposal

A senior UI/UX product design proposal for the Swift iOS VPN app: competitor research, feature strategy, screen layouts, fox mascot integration, visual style guide, and Swift implementation recommendations.

---

## 1. Competitor Research Summary

### Top 5 Competitors (General & Mobile-First)

| Competitor | Positioning | Speed Test | Network Tools | Connection Map | Branding / Mascot |
|------------|-------------|------------|---------------|----------------|-------------------|
| **ExpressVPN** | Premium, “instant” connections | In-app: download/upload, latency, jitter, packet loss; compare with/without VPN | Limited | Small map with connected server + IP; Profile screen redesign | Clean, trust-focused; no mascot; giant on/off button |
| **NordVPN** | Security-first, 8k+ servers | Dedicated speed test & comparison tool; &lt;5% speed impact messaging | Not prominent in app | Server list/country focus; map less central | Dark blue, shield; no character |
| **Surfshark** | Value, unlimited devices | VPN Accelerator, split-tunneling; speed as feature not dedicated screen | Not highlighted | Country list; map secondary | Shark motif in name only; budget-friendly tone |
| **Proton VPN** | Privacy, Swiss, 17k+ servers | Strong speed narrative; many servers | Not in-app | **World map** in client: tap country or use sidebar list + search | Professional, privacy; no mascot |
| **TunnelBear** | Friendly, approachable | Basic | No traceroute | Bear “tunneling” on map to location | **Cartoon bear mascot**; 232% more bears in redesign; high engagement |

### Strengths Across Competitors

- **Speed tests**: ExpressVPN leads with full metrics (download, upload, latency, jitter, packet loss) and with/without VPN comparison; NordVPN emphasizes methodology and transparency.
- **Maps**: ExpressVPN and Proton use a **small map + IP** and **interactive world map** respectively; Mullvad offers an interactive server map with filters (owned vs rented).
- **Trust**: No-logs, encryption, and clear privacy copy are table stakes; ExpressVPN’s recent mobile redesign focuses on clarity and quick access.
- **Mascots**: TunnelBear (and PotatoVPN-style characters) show that a **consistent mascot** increases retention and makes technical actions feel approachable; “tunneling” as a visual metaphor works well.

### Weaknesses / Gaps

- **Traceroute**: Rare in consumer VPN apps; Geo Trace (iOS) and IP Tools (Android) fill this as standalone tools. VPNs that offer it can differentiate.
- **Map + tools in one flow**: Most apps separate “pick server” from “see your route” or “see your location”; combining **your location → path → server** in one narrative is underexplored.
- **Personality**: Except TunnelBear, VPN UIs are serious and similar; a **fox mascot** can own “clever, fast, secure” without copying the bear.
- **Speed test UX**: Many show numbers only; few use a strong **visual gauge**, **history**, or **one-tap “test then suggest server”.**

### Implications for FoxyWall

- Lead with **in-app speed test** (you already have a gauge) and add **with/without VPN** and optional **jitter/packet loss**.
- Expose **traceroute** as a first-class feature (not buried in Settings) and tie it to the fox (“Fox traces the path”).
- Add a **connection map** that shows **user location ↔ VPN server** (and optionally traceroute hops) to match ExpressVPN/Proton expectations.
- Introduce a **fox mascot** across home, connecting, and tools to build habit and emotional connection.

---

## 2. Feature Strategy

### Core Pillars

1. **One-tap protect** — VPN tab is primary; connect/disconnect and server choice are obvious and fast.
2. **See your connection** — Speed, path (traceroute), and location (map) tell a single story: “You → internet → VPN server.”
3. **Fox as guide** — The fox appears in key moments: idle state, connecting, success, and in tools (speed, trace, map) to explain and reward.

### Feature Placement

| Feature | Current | Proposed |
|---------|---------|----------|
| VPN connect | VPN tab | **Home / VPN tab** (keep); add fox and server chip on same screen |
| Speed test | Speed tab (gauge + map) | **Speed tab**; add “Test with VPN” vs “Test without”; optional history; fox in empty/result state |
| Traceroute | Settings → sheet | **Dedicated “Tools” tab** or **Speed tab section**; optional “Trace to current VPN server”; fox “trace” narrative |
| Connection map | Speed tab (user pin only) | **Unified map**: user pin + VPN server pin + (optional) traceroute hops; also in server selector |
| Server selection | Sheet from VPN tab | **Inline on VPN tab** (chip) + **full-screen selector** with **map** and list |

### User Flow (High Level)

1. **Open app** → Fox on home/VPN screen; status (Protected / Not protected) and one primary CTA.
2. **Connect** → Fox “running” or “burrowing” animation; then “Fox is guarding” when connected.
3. **Change server** → Tap server chip → Map + list; tap country/server → back to VPN tab with new server.
4. **Check speed** → Speed tab → Gauge + “Test speed”; optional “Compare with VPN on/off”; fox celebrates good speed or encourages retry.
5. **Inspect path** → Tools (or Speed) → Traceroute; enter host or “Trace to current server”; map of hops; fox “following the path.”
6. **See where you are** → Map on Speed or Tools showing “You” and “VPN server” (and path if traced).

---

## 3. Screen Layouts and Sketches (Text)

### 3.1 Tab Bar (Bottom Navigation)

- **Tab 1 — Home/VPN**  
  Label: “VPN” or “Protect”. Icon: shield or fox head.  
  Content: Connection status, main button, selected server chip, fox mascot.

- **Tab 2 — Speed**  
  Label: “Speed”. Icon: speedometer.  
  Content: Gauge, primary number, secondary (upload/ping), map strip, “Test speed” / “Test with VPN off”.

- **Tab 3 — Tools**  
  Label: “Tools”. Icon: point.topleft.down.to.point.bottomright.curvepath or wrench.  
  Content: Traceroute (and future tools); optional Ping; entry point to “Trace to server” and map of route.

- **Tab 4 — Settings**  
  Label: “Settings”. Icon: gear.  
  Content: Subscriptions, Privacy, Terms, Network tools link if not moved, App info.

So: **VPN | Speed | Tools | Settings** (four tabs). Alternatively, keep three tabs and put Traceroute under Speed as a section or secondary screen.

### 3.2 VPN (Home) Screen — Text Layout

```
┌─────────────────────────────────────────┐
│  [Nav: optional back]    FoxyWall       │
├─────────────────────────────────────────┤
│                                         │
│            ┌─────────────┐              │
│            │   [FOX]     │              │
│            │  mascot     │              │
│            └─────────────┘              │
│                                         │
│         Protected / Not protected      │
│         "Your connection is secure"    │
│                                         │
│    ┌─────────────────────────────┐     │
│    │  [Connect] / [Disconnect]   │     │
│    └─────────────────────────────┘     │
│                                         │
│    ┌─────────────────────────────┐     │
│    │ 🇸🇪 Stockholm  ▼  Select     │     │
│    └─────────────────────────────┘     │
│                                         │
└─────────────────────────────────────────┘
```

- Fox: idle (sitting) when disconnected; “running” or “burrow” when connecting; “guard” (e.g. sitting by shield) when connected.
- Server row: tappable; opens full-screen server selector (map + list).

### 3.3 Speed Screen — Text Layout

```
┌─────────────────────────────────────────┐
│  Speed                          [i]     │
├─────────────────────────────────────────┤
│                                         │
│     ╭──────── gauge ────────╮           │
│     │     needle / arc      │           │
│     ╰───────────────────────╯           │
│           42.5 Mbps download            │
│     Upload 12.1  ·  Ping 24 ms          │
│                                         │
│  ┌─────────────────────────────────┐   │
│  │  [Map: you + optional server]   │   │
│  └─────────────────────────────────┘   │
│                                         │
│  [  Test speed  ]  [ Test without VPN ] │
│                                         │
│  [Fox: "Ready to run" or result state]  │
└─────────────────────────────────────────┘
```

- Map: keep user pin; add VPN server pin when connected; optional “path” line later.
- Secondary CTA “Test without VPN” for comparison (if not premium-only).

### 3.4 Tools Screen (Traceroute) — Text Layout

```
┌─────────────────────────────────────────┐
│  Tools                          [Done]  │
├─────────────────────────────────────────┤
│  ┌─────────────────────────────────┐    │
│  │ 🔍 Enter IP or domain      [→]  │    │
│  └─────────────────────────────────┘    │
│                                         │
│  [ Trace to current VPN server ]        │
│                                         │
│  ┌─ Hop 1 ─────────────────────────┐   │
│  │ router.local     192.168.1.1 12ms│   │
│  ├─ Hop 2 ─────────────────────────┤   │
│  │ isp.gw          10.0.0.1    24ms │   │
│  ├─ Hop 3 ─────────────────────────┤   │
│  │ ...                              │   │
│  └─────────────────────────────────┘   │
│                                         │
│  ┌─────────────────────────────────┐   │
│  │  [Map: hops as line/pins]       │   │
│  └─────────────────────────────────┘   │
│                                         │
│  [Fox: "Following the path" / done]     │
└─────────────────────────────────────────┘
```

- Top: same search bar as current sheet; “Trace to current VPN server” uses selected server’s address.
- List: keep hop number, host, IP, latency; color by latency (green / orange / red).
- Map: reuse `TracerouteMapView`; show polyline + pins; optional compact “minimap” above list.

### 3.5 Connection / Location Map Screen (Dedicated or Modal)

- **Option A**: Full-screen map from “View map” on VPN or Speed tab.
- **Option B**: Same map in server selector (Proton-style): tap region/country to filter, list below.

```
┌─────────────────────────────────────────┐
│  Connection map                 [Done]  │
├─────────────────────────────────────────┤
│                                         │
│     [World map]                         │
│       • You (blue)                      │
│       • VPN server (green)              │
│       ─── path line (optional)         │
│                                         │
│  "You're connected through Stockholm"   │
│                                         │
└─────────────────────────────────────────┘
```

- One line of copy tying “you” and “server” to the fox narrative (e.g. “Fox is guarding from Stockholm”).

### 3.6 Server Selector (Redesign) — Text Layout

```
┌─────────────────────────────────────────┐
│  Select server                   [Done] │
├─────────────────────────────────────────┤
│  ┌─────────────────────────────────┐    │
│  │ [Map: regions with pins/counts] │    │
│  └─────────────────────────────────┘    │
│  [Search countries or cities]           │
│                                         │
│  🇸🇪 Sweden · Stockholm    ● Fast      │
│  🇺🇸 United States · NYC   ● Fast      │
│  🇩🇪 Germany · Berlin      ○ Good      │
│  ...                                    │
└─────────────────────────────────────────┘
```

- Map: tappable; selecting a region filters or scrolls the list; show “You” pin if permission granted.
- List: keep flag, name, city, status; add latency or “Fast/Good” if you have ping data.

---

## 4. Visual Style Guide

### 4.1 Colors

- **Primary (brand)**  
  - Fox / accent: warm orange `#E8752B` (or `#D96B20`) for mascot and primary CTAs when “positive” (e.g. Connect).  
  - Alternative: deep amber `#C45C12` for a more “clever fox” feel.

- **Semantic**  
  - Connected / success: green `#34C759` (system green or your current green).  
  - Disconnected / neutral: gray `#8E8E93`.  
  - Warning: amber/orange.  
  - Error / disconnect CTA: red `#FF3B30`.

- **Backgrounds**  
  - Base: `Color(.systemBackground)` (dark: `#1C1C1E`).  
  - Secondary: `Color(.secondarySystemBackground)`.  
  - Cards/surfaces: `Color(.tertiarySystemFill)` or your existing `.ultraThinMaterial` glass.

- **Text**  
  - Primary: `Color.primary`.  
  - Secondary: `Color.secondary`.  
  - Muted: `Color(.tertiaryLabel)`.

- **Gradient (optional)**  
  - For hero areas (VPN status, gauge): subtle gradient from primary orange to deep orange or from green to teal for “protected.”

### 4.2 Typography

- **Large title / hero number**: SF Pro Rounded, 34–44 pt, bold (e.g. speed value, “Protected”).
- **Titles**: SF Pro, 20–22 pt, semibold; navigation titles.
- **Headlines**: 17 pt, semibold; card titles, section headers.
- **Body**: 17 pt, regular; body copy.
- **Subheadline / captions**: 15 pt / 12 pt, secondary color; labels like “Mbps download”, “Ping ms”.
- **Tab labels**: 10 pt, medium.

Use `Design.rounded` for speed numbers and key metrics to align with your current `SpeedometerGaugeView`.

### 4.3 Iconography

- **System symbols**: Prefer SF Symbols (e.g. `shield.fill`, `speedometer`, `globe`, `point.topleft.down.to.point.bottomright.curvepath.fill`) for consistency.
- **Tab bar**: Outline when unselected, fill when selected; single color or gradient for selected state (match `GlassTabBar`).
- **Mascot**: Custom fox asset set: idle, connecting (running/burrow), connected (guard), and optional states for Speed/Tools (e.g. “running”, “pointing at path”). Provide @1x, @2x, @3x and, if needed, LTR/RTL or animation frames.

### 4.4 Fox Mascot Integration

- **Personality**: Clever, fast, friendly guardian; short copy in first person (“I’m guarding your connection”) or second person (“Fox is guarding you”).
- **Placement**:  
  - VPN tab: next to or above status; state-dependent animation.  
  - Speed tab: below gauge or next to “Test speed”; different pose for “ready” vs “great result” vs “try again.”  
  - Tools tab: above or below traceroute list; “trace” or “path” pose.  
  - Empty states: “Select a server”, “Enter a host to trace” with fox illustration.
- **Motion**: Prefer subtle loop (idle breath, tail) and one clear “success” animation (e.g. fox waves or sits by shield) to avoid distraction.
- **Accessibility**: Ensure decorative images have `accessibilityHidden = true` or a single combined label for the section; never put critical info only in the mascot.

### 4.5 Components (Recap)

- **Cards**: Rounded (12–20 pt), `.ultraThinMaterial` + light border (your `GlassCard`); shadow for elevation.
- **Buttons**:  
  - Primary: full-width, 14–16 pt corner radius, gradient or solid (green connect, red disconnect, orange for neutral primary).  
  - Secondary: bordered or tertiary fill (e.g. “Test speed”, “Trace to server”).
- **Chips**: Server selector chip with flag + name + chevron; same radius as cards.
- **Maps**: Rounded (14 pt); standard or muted map style; annotations for You (blue), Server (green), hops (small dots); optional polyline for path.

---

## 5. Recommendations for Swift Implementation

### 5.1 Architecture and State

- **Single source of truth for VPN**: Keep `NetworkView` (or a dedicated `VPNState` object) holding `isConnected`, `isLoading`, `selectedServer`; pass into child views via `@Binding` or `@ObservableObject` so the fox, server chip, and map stay in sync.
- **Services**: Keep `SpeedTestService`, `TracerouteService`, `LocationManager` as `ObservableObject`s; consider a small `ConnectionMapState` that holds user coordinate + selected server coordinate + optional traceroute hops for one shared map model.

### 5.2 Tab Structure

- Current: `TabView(selection:)` with “Speed”, “VPN”, “Settings”.  
- Proposed: Add “Tools” or fold Traceroute into Speed.  
  - Use the same `TabView` with an enum (e.g. `AppTab`) and `tag`; optionally replace default tab bar with your `GlassTabBar` for style.  
  - If you add a fourth tab, ensure tab bar labels remain readable (short: “VPN”, “Speed”, “Tools”, “Settings”).

### 5.3 Views to Add or Refactor

- **FoxMascotView**: New SwiftUI view that takes a state enum (e.g. `.idle`, `.connecting`, `.connected`, `.speedReady`, `.traceDone`) and shows the right asset or Lottie. Use `Image("fox_idle")` etc. and optional `Animation` for looping.
- **VPNHomeView**: Extract current VPN tab content into a dedicated view; add `FoxMascotView` and server chip; pass `selectedServer`, `isConnected`, `isLoading`, and connect/disconnect actions.
- **SpeedTabView**: Already mostly in place; add “Test without VPN” only when VPN is connected (or always and show comparison); add optional “With VPN” / “Without VPN” result comparison; integrate fox below gauge.
- **ToolsView**: New view containing traceroute search bar, “Trace to current VPN server” button, list of hops, and `TracerouteMapView`; reuse `TracerouteService` and existing `TracerouteSheetView` content; optionally present as a tab instead of a sheet.
- **ConnectionMapView**: New view with `Map` and annotations: user location, selected server (from `VPNServer.coordinate`), optional polyline from traceroute hops; reusable from Speed, VPN, or Tools.
- **ServerSelectorView**: Evolve `SupabaseServerSelectorView`: add optional map at top (region/country pins), search, and same `SupabaseServerRow` list; keep `onRefresh` and `selectedServer` binding.

### 5.4 Navigation

- **Sheets**: Keep server selector and traceroute as sheets if they stay secondary; if Traceroute becomes a tab, make it the main content of the Tools tab and remove the sheet from Settings.
- **Full-screen map**: Present `ConnectionMapView` as a fullScreenCover or push from VPN/Speed when “View map” or “Connection map” is tapped.
- **NavigationStack**: Use `NavigationStack` in each tab’s root so each tab has its own stack; avoid nesting TabView inside a single stack for clearer back behavior.

### 5.5 Reusable Components

- **MetricCard**: Small card for “X Mbps”, “Y ms”, with icon and label; use on Speed and in comparison.
- **ServerChipView**: Flag + displayName + chevron; tappable; use on VPN tab and anywhere “current server” is shown.
- **HopRowView**: Hop number, host, IP, latency with color; use in both sheet and Tools tab.
- **MapSnapshotView** (optional): If you need a small map in a list (e.g. server row), consider a static snapshot or a compact `Map` with fixed region.

### 5.6 Performance and UX

- **Speed test**: Run on background queue; update UI on main thread (you already do); consider a short haptic on “Test complete” and when VPN connects/disconnects.
- **Traceroute**: Already async; show hops incrementally in the list and update the map as hops resolve so the path “draws” over time.
- **Maps**: Use `Map` with stable `initialPosition` or `position`; avoid recreating annotations every frame; use `Annotation` with lightweight views (e.g. Circle + text) rather than heavy overlays.
- **Assets**: Provide fox images in Asset Catalog with @1x/@2x/@3x; for animation, consider Lottie (if you add the dependency) or a small number of UIImage frames with `UIImage.animatedImage`.

### 5.7 Accessibility

- **Tab bar**: Ensure each tab has a clear `accessibilityLabel` and `accessibilityHint` (e.g. “VPN, current tab”).
- **Connect button**: Label “Connect to VPN” / “Disconnect VPN”; hint “Double tap to connect”.
- **Speed value**: Expose live value to VoiceOver (e.g. “42.5 Mbps download”); consider `accessibilityValue` on the gauge.
- **Traceroute list**: Each hop as a single element with “Hop N, host, IP, latency”; list should be in a logical order for rotor.
- **Fox**: Mark decorative or provide one summary label (e.g. “Fox mascot, connected”) so the experience stays focused.

### 5.8 Theming

- Keep `preferredColorScheme(.dark)` if the app is dark-only; if you add light mode later, define `Color` extensions or an `AppTheme` with light/dark variants for primary, success, and card colors so the fox and glass style adapt.

---

## Summary

- **Competitors**: ExpressVPN and Proton lead on speed test and map; TunnelBear leads on mascot-driven engagement; traceroute is a differentiator for FoxyWall.
- **Strategy**: One-tap protect, “see your connection” (speed + path + map), and fox as guide across VPN, Speed, and Tools.
- **Screens**: VPN (fox + status + connect + server chip), Speed (gauge + map + test ± comparison), Tools (traceroute + map + “trace to server”), Settings; server selector with optional map; optional full-screen connection map.
- **Visual**: Orange/amber fox accent, system semantic colors, SF Pro (Rounded for numbers), glass cards, fox mascot in multiple states.
- **Swift**: Extract VPN/Speed/Tools views, add `FoxMascotView` and `ConnectionMapView`, reuse services and state; keep tabs and sheets; optimize map and traceroute updates and accessibility.

This structure gives you a clear path to implement the redesign incrementally (e.g. fox first, then map, then Tools tab) while keeping the existing VPN and speed logic intact.
