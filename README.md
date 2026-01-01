# Zero Gravity Chamber

A Roblox Proof of Concept demonstrating a zero gravity mechanic using the modern `VectorForce` API and Rojo workflow.

## 🚀 Quick Start

### Prerequisites

- [Rojo](https://rojo.space/) installed (`aftman install` or `cargo install rojo`)
- Roblox Studio with Rojo plugin

### Sync to Studio

```bash
# Start the Rojo server
rojo serve

# In Roblox Studio: Plugins → Rojo → Connect
```

### Test Setup

1. In Roblox Studio, create a Part in Workspace
2. Name it `ZeroG_Zone`
3. Set properties:
   - `Anchored = true`
   - `CanCollide = false`
   - `Transparency = 0.5` (optional, for visibility)
4. Play the game and walk into the zone

## 📁 Project Structure

```
├── default.project.json     # Rojo configuration
└── src/
    ├── Shared/
    │   └── PhysicsUtils.lua # Zero gravity toggle logic
    ├── Server/
    │   └── GravityController.server.lua # Zone detection
    └── Client/              # (Reserved for future use)
```

## ⚙️ How It Works

- **PhysicsUtils** creates a `VectorForce` that counteracts gravity: `Force = workspace.Gravity × AssemblyMass`
- **GravityController** detects `ZeroG_Zone` parts using `Touched`/`TouchEnded` events
- Players float when inside zones, fall normally when outside

## 📜 License

MIT
