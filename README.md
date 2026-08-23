# CPRay Gaming 🎮🚀

**CPRay Gaming** is a high-performance, low-latency VPN and gaming tunnel client for Windows. Built with **Flutter Desktop** and powered by the **Sing-box** engine with **Wintun (TUN Mode)**, it routes 100% of game UDP/TCP traffic with minimal ping and zero packet loss.

---

## ✨ Features

- 🎯 **Gaming TUN Mode (Wintun):** Full system UDP/TCP tunneling specifically optimized for online games, Steam, Discord, and anti-cheat clients.
- ⚡ **Multi-Protocol Support:** Native support for **VLESS (Reality / TLS)**, **VMess**, **Trojan**, **Hysteria 2 (QUIC)**, **TUIC (BBR)**, **WireGuard**, and **Shadowsocks**.
- 📡 **Universal Subscription Support:** Import subscription links and configs from **Pasarguard**, **Marzban**, **3X-UI**, or any standard V2Ray/Sing-box panel.
- ⏱️ **Real-Time Latency (Ping) Meter:** Concurrent TCP latency testing to quickly identify the fastest gaming nodes.
- 🛡️ **Domestic Traffic Bypass:** Automatically bypasses local/domestic IP ranges and websites for maximum bandwidth.
- 🎨 **Futuristic Neon Cyberpunk UI:** Dark-mode glowing aesthetics with live speed counters and session metrics.
- 🔄 **Automated Cloud CI/CD & Updates:** GitHub Actions builds installers (`CPRay-Gaming-Setup.exe`) and portable packages on every version tag.

---

## 🛠️ Tech Stack

- **Frontend / UI:** Flutter Desktop for Windows (Dart)
- **Core Engine:** Sing-box Core + WireGuard Wintun Driver
- **State Management:** Provider pattern
- **CI/CD & Packaging:** GitHub Actions + Inno Setup

---

## 🚀 Automated Builds with GitHub Actions

Every time a release tag is pushed to GitHub (e.g. `v1.0.0`), GitHub Actions will automatically:
1. Compile the Flutter Windows `.exe`.
2. Bundle the official Sing-box core binary.
3. Generate the installer setup (`CPRay-Gaming-Setup.exe`).
4. Publish a new Release on your GitHub repository.

To trigger a release manually:
- Go to your GitHub repository -> **Actions** -> **Build and Release CPRay Gaming** -> **Run workflow**.

---

## 📄 License
Open source and built with modern memory-safe standards.
