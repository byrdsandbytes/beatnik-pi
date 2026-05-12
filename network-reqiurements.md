# Network and Infrastructure Requirements: Beatnik Pi & Snapcast Audio System

**Note: These guidelines are primarily for complex, high-traffic commercial or enterprise environments. Typical standard home Wi-Fi setups usually support these protocols out of the box without requiring advanced network configurations.**

This document outlines the network requirements necessary to support a multi-room, synchronized audio environment using **Beatnik Pi** & **Snapcast**.

## 1. Network Topology & IP Management

| Requirement | Specification |
| --- | --- |
| **VLAN / Network** | Dedicated VLAN or separate IoT SSID. |
| **IP Allocation** | Static IPs or permanent DHCP reservations (by MAC Address). |
| **DHCP Lease Time** | Minimum of 7 days (if static IPs are absolutely not possible). |

## 2. Required Wi-Fi & Access Point (AP) Configurations

| Setting | Required State | Impact if Misconfigured |
| --- | --- | --- |
| **Client / AP Isolation** | **DISABLED** | Blocks local communication between clients, server, and controllers. |
| **Airtime Fairness** | **DISABLED** | Causes buffer underruns and audio stuttering. |
| **Multicast / mDNS (Bonjour)** | **ENABLED** | Prevents `.local` domain discovery and Avahi server connection. |
| **Auto-Optimize / AI Tuning** | **DISABLED** | May cause random channel shifts and dropped connections. |
| **IGMP Snooping** | **DISABLED*** | Blocks discovery packets *(unless proper IGMP querier is active and verified)*. |

## 3. Port and Protocol Allowlist

| Port(s) | Protocol | Direction / Scope | Usage |
| --- | --- | --- | --- |
| **123** | UDP | Outbound WAN | **NTP (Time Sync)** - Critical for Snapcast audio synchronization. |
| **5353** | UDP | Internal VLAN | **mDNS (Multicast DNS)** - Device discovery and `.local` hostnames. |
| **1704, 1705** | TCP | Internal VLAN | **Snapcast** - Audio Stream & Control. |
| **5000, 7000** | TCP/UDP | Internal VLAN | **Shairport-Sync** - AirPlay 1 & 2 streams. |
| **80, 443, 3000, 8181** | TCP | Internal VLAN | **Beatnik UI & Hardware API** - Web interface, configuration, and WebSockets. |
| **1234,1235 5005** | TCP | Internal VLAN | **CamillaDSP** - DSP configuration and control over WebSocket/TCP. |
| **1780, 1788** | TCP | Internal VLAN | **Snapweb Client** - Web-based interface and control for Snapcast. |
| **4070, 80, 443** | TCP | In/Outbound WAN | **Spotify Connect** - Local inbound (4070) and Outbound WAN (80, 443) for Spotify streaming. |

