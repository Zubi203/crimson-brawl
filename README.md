<img width="1898" height="1021" alt="Screenshot 2026-10-26 135011" src="https://github.com/user-attachments/assets/64558e93-ad84-473a-afb6-846e0fcfdcd7" />

# Shades of Crimson
Shades of Crimson is a 1v1 Fighting game featuring a varied state machine based moveset and a tight and responsive input handling system. The game has 3 modes: Local PvP where two players can fight each other on the same keyboard, a PvE mode where you can fight a CPU controller character, and an Online PvP mode where you can fight another player over the internet by sharing a Room ID with them.

### Key Features
- An extensive input system using input packets (a resource) to store all inputs pressed in a single frame, an input handler that is responsible for generating these packets based on player/CPU input, and an input buffer that stores input packets in an array, effectively remembering all inputs pressed during the past 20 frames as well as their sequence
- A complex and expandable State Machine system which deals with animating and moving the fighter based on inputs and actions. A StateMachine class is responsible for transitioning between states and for acting as a bridge between the states and the parent Fighter node to make it easier for the states to reference data on the Fighter node. The Fighter has 14 different States currently, all extending from the same base State class
- Used Godot's AnimationTree Node to smoothly blend and transition between different animations based on the state machine's current state
- Implemented a Service Locator and a Global Event Bus to decouple game systems and allow for easier communication between parts of the game
- Implemented an audio pooling systems as a service that can be registered to the service locator. This dynamically creates and caches audio stream players when needed, and re-uses cached players if available
- Implemented online multiplayer using Godot's high-level multiplayer API
- Used MultiplayerSpawner and MultiplayerSynchronizer nodes to sync player spawning, transform, and inputs between server and client
- Used Remote Procedure Calls to call methods on all running instances of the game in order to sync animations, effects, scene transitions, and game state changes
- Implemented a "Bootstrap" scene architecture to allow certain nodes to persist between scenes without using Autoloads/Singletons
- Used the Node Tunnel plugin to bypass the need for port forwarding when connecting to peers in different regions by using a relay server


### Engine and Tools
- This project was made using the Godot Engine and coded almost entirely in GDScript
- The Node Tunnel plugin by AndrooDev was used to bypass the need for port forwarding when connecting to players in different regions in multiplayer
- The GPUTrail plugin by celyk was used to add a trail vfx to the sword attacks


### How to Run Project
- This project can be downloaded and played from itch.io at this link: https://zubi-dev.itch.io/shades-of-crimson
- If you're interested in running the project on the Godot Engine, simply download the project files from this repository and import them into the engine


### Credits
- All the code for this project was done by me
- Models: https://quaternius.itch.io/modular-character-outfits-fantasy and https://quaternius.itch.io/universal-base-characters
- Animations: https://quaternius.itch.io/universal-animation-library and https://quaternius.itch.io/universal-animation-library-2
- Skybox: https://freestylized.com/
- Music: https://opengameart.org/content/battle-theme-a and https://opengameart.org/content/free-music-pack
- Sound Effects: https://leohpaz.itch.io/minifantasy-dungeon-sfx-pack
- UI sounds: https://jdsherbert.itch.io/ultimate-ui-sfx-pack
- Node Tunnel plugin: https://github.com/curtjs/nodetunnel
- GPUTrail plugin: https://github.com/celyk/GPUTrail


### Contact
- Discord: @zubi_dev
- Work email: zubairhittam@gmail.com
