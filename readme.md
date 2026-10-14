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
		- [ ] hand gestures
			- arm
				- lateral extension
				- forward extension
				- 90d bend
			- hand
				- finger point
				- fist
				- come/go fingers curl
		- [ ] aim/shoot weapon
		- [ ] raise shield
- tools
	- [x] hand gun
	- [x] riot shield
	- [x] big gun
- environments
	- level
		- cinder block walls
		- cement floor
		- metal railings/bridges
		- doors/windows
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
- wildcard ideas
	- flashlight
		- dark level components where use a light to send or receive signal
		- just have flashlight on gun
	- double duty ("one mechanic solves two different problems)
		- ?
	- feeling froggy
		- throw  your teammates onto roof with your shield like leapfrog?
- swap pistol to baton
- level 0
	- no backup, just one room for either a training dummy or a domestic dispute before more intense threats
	- introduce shield, demonstrate that your attack is somewhat impotent
	- encourage fast failure/reset ('press R to reset')
		- give small text hints at start of new reset
- level 1
	- introduce teammates
	- draw eye to window behind hostage
	- text hints on restart: encourage scouting perimeter; encourage watching for 'wait' locations 
- level 2
	- introduce verticality
	- instead of a window, there's a skylight to rappel through
		- allow full freedom to breach all together, or add a rail like "only one person can take a small entry" (i.e., windows and rappel sites, as opposed to doors)?
	- justify tac-signals with industrial machine whir (can't hear each other; also allows running without alerting enemies)
- josh ideas
	- third person
	- enemies shooting
	- shield (= directional damage)
- gameplay
	- 'breaching' doesn't necessarily have to be central to each encounter
		- maybe the last level is a trap and so you need to set up to defend against waves/incursions
		- for incursions, keeping signals relevant likely means contriving reasons for static teammates to be the suboptimal choice, e.g.:
			- you see the roof is collapsing over them, so you need them to cover the door from the *other* vantage point; 
			  you need covering fire from teammate-1 to let teammate-2 fall back while you're shielding the bomb the terrorists are trying to shoot
	- first level = you are distraction for the window sniper to save hostage; maybe next level has solution where you command your teammate to cause a distraction
		- similarly, while first level has the shout "Everyone Go Go Go" command, maybe for next level where hearing is impeded by the whirring machine, you can tell them to sync up a countdown and your stopwatch is inside your shield