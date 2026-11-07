# Getting Around

## Concepts

Beatnik Controller is a remote control for a [Snapcast](https://github.com/badaix/snapcast) multi-room audio system. A few terms appear throughout the app:

| Term | Meaning |
|------|---------|
| **Server** | The Snapcast server. It receives audio from sources (streams) and distributes it to all clients. Your first Beatnik device normally becomes the server. |
| **Client** | A device that plays audio (for example a Beatnik Pi with an amplifier or soundcard). |
| **Group** | One or more clients that play the same stream in sync. In the app a group is shown as a "device" (for example "Living Room"). |
| **Stream** | An audio source on the server, such as AirPlay, Spotify Connect, Line-In or radio. A stream is assigned to a group. |
| **Preset** | A saved snapshot of volume levels or stream assignments that you can re-apply with one tap. |

---

## Connecting to your server

::: warning 📸 Screenshot needed
Settings screen with the Server Url field and the Connect to Server button.
:::

By default the app looks for a Snapcast server at `beatnik-server.local`.

- **Settings:** open **Menu > Settings**, enter the server address in **Server Url**, then tap **Connect to Server** (see [Settings](./guide-settings-help.md#settings)).
- **Network scanner (mobile app):** open **Menu > Search Devices** and tap **Set as Server** next to your server (see [Network scanner](./guide-maintenance.md#network-scanner)).
- **Setup wizard:** adding a new Beatnik device configures the connection for you (see [Adding a new Beatnik device](./guide-add-device.md)).

If no server can be reached, the dashboard shows an onboarding card with an **Add** button and a **Search for existing Device on Network** shortcut.

---

## App layout

::: warning 📸 Screenshot needed
Bottom tab bar (Dashboard, Devices, Streams, Menu) and the expanded player toolbar.
:::

A tab bar at the bottom of the screen gives access to the main areas:

| Tab | Purpose |
|-----|---------|
| **Dashboard** | Overview of your devices and streams, quick access to presets. |
| **Devices** | List of all clients and device groups. |
| **Streams** | List of all streams, active ones first. |
| **Menu** | Settings, server status, network scanner, demo mode and updates. |

A **player toolbar** with cover art, title, artist and per-group volume sliders is available while audio is playing. Tapping a tab collapses it back to its compact size.
