### Theme
- Signal ([itch jam page link](https://itch.io/jam/godot-wild-jam-98))

### Wildcards:
- Flashlight
- Double Duty
- Feeling Froggy

### Ideas
- Flag semaphore
- Outer Wilds
- Traffic
- Swat hand signals

### SWAT hand signals
- you are SWAT team leader
- you have a shield and shitty pistol (stun gun? rubber bullet? baton?)
- you mostly give silent directions to your two AI teammates

### starter project tasks
- getting project in shared version control
- characters
	- three SWAT capsules (you and two AI)
	- one terrorist capsule
- environment
	- outside a room with two entrances
- UI/controls
	- right click/drag for pie menu to select hand signal corresponding to person/task
	- start with just printing the task to console, ultimately will translate to move/action AI commands with restrained scope
	- minimap (or some way to convey non-obvious positional information...maybe a camera-pull to a "drone view" with heat signatures or something)

### next tasks
- AI
	- navmesh / go-to / take shot
	- {flesh out commands --> tailor to puzzles; keep realistic/in-scope}

### modeling
- characters
	- [x] player (simple policewoman?)
	- [x] swat teammates (GIGN)
	- [x] enemies ✅ 2026-10-13
- animations
	- lower/whole body
		- [x] idle (crouch, stand)
		- [x] walk (crouch, stand)
		- [x] run (crouch, stand)
	- torso/arm split
		- [x] hand gestures ✅ 2026-10-15
		- [x] aim/shoot weapon ✅ 2026-10-15
		- [x] raise shield ✅ 2026-10-15
		- [ ] surrender/scared
	- [ ] pass animations to all four character models
- tools
	- [x] hand gun
	- [x] riot shield
	- [x] big gun
- environments
	- level
		- [x] cinder block walls
		- [x] cement floor
		- [x] metal railings/bridges
		- [ ] doors/windows
	- props
		- barrel
		- box
		- sandbag stack
	- level ideas
		- prioritize considering vantage points and ground-level stealth / LOS props
		- industrial setting --> factory / power plant / etc.
		- office building
		- convenience store

### SWAT notes ([video 1](https://youtu.be/ZTZFGVL5fs4))
- roles (usually 4-8 man teams)
	- entry team
		- ground team leader
		- breacher (battering ram, hydraulic devices)
	- observation/overwatch team: sniper/recon specialists
	- misc.: crisis negotiators, medics, intelligence coordinators, perimeter team
- created as special police unit in LA after mass shootings in 60s, e.g. bell tower at UT
- main response roles - riots, sniper attacks, political assassinations, urban guerrilla warfare (also counter-terrorism since 9/11)
	- where specialized weapons and tactics are necessary
- weapons
	- early - M1 Carbines (mass produced in WWII)
	- then - MP5 submachine gun (9mm rounds -> low stopping power)
	- later
		- SMG - CAR-15 and M4 carbines (56 mm rounds)
		- shotgun - Benelli M1
		- pistol - Colt I9II, M9 Beretta, Sig Sauer P226, FN Five-Seven
		- non-lethal
			- tasers
			- tear gas
			- pepper spray cannisters
			- pepper ball guns
			- shotguns with beanbag rounds
			- stun grenades

### Tactical Hand Signals notes ([video 2](https://youtu.be/uEfLh75wh3Q))
- 2:42 - loud machine whirring
- 5:19 - ok/acknowledge symbol
- 11:44 - suspect; hostage

### 10/14 thoughts
- consider leaning into stealth to open quiet signal options
	- footsteps/machine whirring from tac hand signals video
	- levels open with players default crouch/stealth walking
- conveying enemy's intentions, like when they're going to kill the hostage or begin incursion
	- text
		- bottom-screen closed caption style
		- overhead, RS thought bubble style
	- voice acting
- wildcard ideas
	- flashlight
		- dark level components where use a light to send or receive signal
		- just have flashlight on gun
	- double duty ("one mechanic solves two different problems)
		- ?
	- feeling froggy
		- throw  your teammates onto roof with your shield like leapfrog?
- swap pistol to baton
- level 0: local domestic dispute
	- no teammates, just one room for either a training dummy or a domestic dispute before more intense threats to introduce most basic elements:
		- introduce shield
		- demonstrate that your attack is somewhat impotent (perhaps role is just shielding/backing out the victim)
		- encourage fast failure/reset ('press R to reset')
			- give small text hints at start of new reset
- level 1: house hostage
	- introduce teammate(s)
	- draw eye to window behind hostage where correct solution involves a teammate taking the shot while the terrorist's back is turned from them (towards you)
	- text hints on restart: encourage scouting perimeter; encourage watching for 'wait' locations 
- level 2: industrial terrorist cell takedown
	- introduce verticality
	- instead of a window, there's a skylight to rappel through
		- allow full freedom to breach all together, or add a rail like "only one person can take a small entry" (i.e., windows and rappel sites, as opposed to doors)?
	- justify tac-signals with industrial machine whir (can't hear each other; also allows running without alerting enemies)
- josh ideas
	- third person
	- enemies shooting
	- shield (= directional damage)
- gameplay
	- need more direct theme relevance in the moment-to-moment
	- need commands to be generalizable to puzzles rather than each command feeling like a point-and-click adventure game lock-and-key situation
	- first level = you are distraction for the window sniper to save hostage; maybe next level has solution where you command your teammate to cause a distraction
		- similarly, while first level has the shout "Everyone Go Go Go" command, maybe for next level where hearing is impeded by the whirring machine, you can tell them to sync up a countdown and your stopwatch is inside your shield
	- 'breaching' doesn't necessarily have to be central to each encounter
		- ...maybe the last level is a trap and so you need to set up to defend against waves/incursions
		- for incursions, keeping signals relevant likely means contriving reasons for static teammates to be suboptimal, e.g.:
			- you see the roof is collapsing over them, so you need them to cover the door from the *other* vantage point
			- you need covering fire from teammate-1 to let teammate-2 fall back while you're completing some contrived primary objective (e.g., shielding the bomb the terrorists are trying to shoot or whatever)
	


### misc.
- Josh showing off some cool debug camera utilities

### 10/15 notes
- make level 0 a ~ 'playable title screen', where you're dropped into a training ground to showcase/play with mechanics and return after each mission, accepting the next whenever you're ready by interacting with some object (e.g., SWAT van)
	- shielding a target from projectiles
	- blocking enemy movement
	- signaling/ordering NPC to 'escape'
- directions -> person (squadmate 1 or 2), action (follow me, go here, take the shot), timing (now, on my signal, after 30s)
	- clarify "on my signal" or "after 30s" in the level 0 room
- enemies don't move and aggro on closest revealed character with LOS
- level 1:
	- one teammate, one terrorist in main room holding hostage facing door --> 
		- if you try to enter from the front with your squad mate, the hostage is killed if you approach, try to shoot (no clear shot), or wait too long
		- if you try to shoot from the window without distracting the terrorist, a notification says there's no valid line of sight
		- need to have teammate wait at window while you enter so the terrorist moves to the correct location, then make the hand signal to take the shot
	- stretch: more terrorists come from the side door and you have to back the hostage out by blocking their shots
- level 2:
	- one mechanic will be moving horizontally with your teammate to keep them shielded from a sniper but having them stop at crusher spots (just red lights on ground)

### 11/17 notes
- don't forget!:
	- incorporate wildcard: probably just give player a flashlight
	- audio (bgm/sfx)
	- link animations to code (movement and gestures)
- level 2 signal mechanics breakdown:
	- only one terrorist at first --> trap --> incursion (several rounds of 3-5 enemies entering from the only exits)
		- can we hide their radar pings until the trap is sprung?
	- commands
		- move-to/defend location
			- positional advantages over incoming enemies...perhaps a stat shows like a "cover rating", like an armor class/hit chance or attack advantage?  Maybe each placement marker on the ground has like a quadrant directional icon around it revealing which directions it is strong against
			- attack advantages of certain entryways...perhaps the placement markers have both a defensive quadrant and an FOV/LOS marker
		- take cover
			- when enemies are focusing a certain teammate and that teammate is on a positional marker with a cover prop, tell the teammate to just behind their prop, raising their evasion from the covered direction to 100%.  After a few moments, aggro will shift, and you can tell your teammate to resume fire while you soak the bullets with your shield
	- direct player role
		- player defends the bomb
			- on-screen health bar for bomb's health before lose condition
			- win condition = survive while taking out all the terrorists
			- defuse?  maybe the player can defuse the bomb passively while they hold the shield and give commands?  Maybe they have to drop the shield to defuse, so they have to wait for lapses in incursion waves
		- cover an NPC while they take a path
			- maybe this is how the incursions start...the enemies want to swarm the team all at once, but you shield your computer expert to the door controls to try to keep them out
			- need to signal NPC to stop shy of hazards the player can see 
	- too few possible positions minimizes choice, but too many is overwhelming to take in under pressure...maybe the stairway on the side of the building is there to give the player a chance to weigh their options before the fight starts (ideally, a raycast from the player's reticle would reveal the graphical positional advantage info for a given command move-to location)
- level design for incursion room
	- 3-4 doors, at least one on a second level
	- all doors open to an area with both a weakness to a possible squadmate position as well as LOS to the bomb
- modeling
	- walls
	- animated whirring machines
	- factory set dressing
- misc thoughts
	- crazy stretch: choose the loadout for your squadmates, balancing offensive/defensive capabilities, so you can choose to e.g., have another shield person blocking a path for some missions
- josh next
	- level_1 comments
		- commands confusing (will probably be fine once third person + reticle + radial menu)
		- hostage situation should time out either because he kills the hostage after like 10s or  the enemies in the other room come out and overwhelm you 
		- one bullet to kill terrorist
		- I wouldn't continue to poll for commands while the last one is still pressed down (probably activate once on either downpress or release so you don't accidentally sweep a command across various options, past the intended one)
		- on loss --> freeze game + "{reason why you lost}\n R to restart"
		- on win --> either freeze + congratulations message, or have hostage run out the door
	- third person controller with real models in the character scenes (I'll add the animation logic later)
	- reticle, radial menu
	- implement level 0 (starting level, truck trigger box -> starts level 1)
	- pause game (time frozen) on cursor game window not being active (or just esc or tab)


### sfx checklist
- ambience
	- [x] whirring/windy background (deskfan, air conditioner, boiling water, tv, radio, police scanner?)
- player
	- [ ] command given (go, follow etc.)
	- [x] UI interact
	- [ ] victory
	- [ ] loss
	- [ ] footsteps
- NPCs
	- [x] bullet fired
	- [x] hit/death
	- [x] enemy alert
	- [ ] enemy talking