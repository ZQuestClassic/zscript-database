GraySwanDir Sideview Engine

For ZC 2.53.1 beta 55+

v 1.1

**Version History**
v1.1 - 26.11.2021

2-state switches and all kinds of switchable stuff.
Sideview Buttons.
One-way solid FFCs.
Yoshi Island Countdown Lifts.
Solid falling platforms.
Added custom Link jumping/falling animation.
Custom Link animations no longer render Link behind non-solid FFCs.
Link water splash flipping is now handled automatically. Now you only need to set up only standard upwards animation sequence.
Split Solid FFC interaction from Link and enemies into separate misc FFC settings. 
Ladder snap option, like in Megaman games. 
Bottomless pits in any screen. Place Flags #100 at the bottom of the screen. 
Fixed major bug that causes Link to disappear, if he falls off bottom of the screen while using hookshot.
Fixed drowning, if you ride a platform into water without flippers.
Underwater air bubbles.
Addressed issue with screen scrolling while swimming.
Revamped the way how Link can improve swimming as he gains better flippers. It now depends on previously unused Power attribute
 of Flippers item class. 
  1 - Can only jump higher, like in Megaman games.
  2 - Can swim while facing sideways by repeatedly pressing Jump button, like in Mario games.
  3 - 4-way swimming just by holding direction buttons.  
Added item that allows Link to negate water currents.
Added item that negates conveyor belts in sideview areas.
Conveyor belts - no longer affect mid-air Link, if flagged as Solid-Top ones.
Added 4 Pegasus-like speed boosting items that allow turning speed boost on/off by holding Run button (Ex2 by default).
      Normal, Stairs, Swimming and Ladder.
Added manually operated variant of Hover Boots. 
Pushblocks can have different pushing speeds. When stack of pushblocks with different pushspeeds is pushed, slowest push speed is used. D1.
Pushblocks can now float in water/lava. Set D2 to 1 to enable that.
Added Moosh`s LTTP Bumper script, converted to use this engine. Also Link can bounce higher on bumper by holding Jump, like in Mario Maker. Optional to set up.
Added water currents. Build them on layer 1.
Sideview walker - added option to have different dropsets and animation, when stomped.
Sideview WallBouncer - Extended direction-specific animation + support for interaction with solid FFCs.
Sideview Thwomp - Moved proximity attribute to Homing factor.
Sideview Thwomp - Can be set as solid enemy, including allowing cranium riding.
Sideview Thwomp - Can now attack and crush in any of orthogonal directions.
Sideview Thwomp - Can now turn into solid pushable block on death.
New enemy - Jumping fireball (Podoboo). Optional to set up.
New enemy - Rinka - a destructible projectile that can be blocked by shield. Optional to set up.
New extra FFC script - Timed Enemy Spawner. Optional to set up.
New enemy - Fish, has 3 diffefent behaviour, depending on his Homing Factor.
New enemy - Blooper/Air Blooper - a medusa-like enemy that swims in water/air in sawtooth pattern
 

v1.01
//Fixed Link not being hurt by touching damage combos from side while in midair.

v1.0
//OUT IN DATABASE!

v 0,94
//Fixed Vicious bug that caused Link to be kicked out of screen if he scrolls into Solid FFC while on stairs.
//Reworked slippery combos.
//Fixed opening of treasure chests and doors.
//Reworked brick generating by crumbling bridge
//and some more... 

v 0.93
//Fixed stupid bug that caused Link not to be able to trigger flipblocks.

v 0,92
//Added Sideview Link Swimming Animation and splash effect, thanks to P-Tux7.
//Added Sideview Signbord, Door and Treasure Chest scripts.

v 0,91
//Added Ladder speed modifier var
//Added option for Link to always face up when climbing ladders
//Assed Option to enable SMB-like swimming mechanics
//Fixed walking off solid FFCs underwater 

v 0.9
//Initial Release

**Usage**
This script revamps and expands upon ZC`s shitty sideview Link`s movement, jumping, stair & ladder movement & swimming,
plus solid & semisolid FFCs to boot. It also features various item properties, like Link`s speed modifying, jumping enhancements.
Most of these features can be modified on fly by various scripts. Jump button is Ex1. Uses many global variables!

**Setup**
1. Set up animation stuff:
	1.1.Set up 4 consecutive rows of tiles for animation of Link getting crushed between solid stuff.
	1.2.Set up table for Link swimming tiles, Rows - animation sequences for up/down/left/right directions,
	columns - no shield/small shield/magic shield/mirror shield.
	1.3 Open GSD_Sideview.z in text editor, like Notepad++.
	1.4.Set TILE_LINK_SWIM_ANIM constant to top left corner of table.
	1.5.Set LINK_SWIM_ANIM_NNMFRAMES constant to number of frames in each animation sequence (2 to 4)	
2. Set up sprite for Link getting crushed, using tiles from step 1-1, Weapons/Misc.
3. Check out other editable constants and default values of global variables at the top of script file.
4. Global script combining: 
	4.1 Put SideviewEngineInit(); line prior to main loop of global script.
	4.2 Put SideviewEngineUpdate1(); line prior to Waitdraw() in the main loop of global script.
	4.3 Put SideviewEngineUpdate2(); line after to Waitdraw() in the main loop of global script.
		- An example of Active global script combined with ghost.zh can be found inside engine`s script file.
5. Import and compile the script. It requires Classic.zh bundle library that comes with ZC 2.53+ in addition to default libraries.
6. Assign Script slots
 	- FFC -
 - GenericSolidFFC
 - RideableCrusher
 - ScreenChange
 - SideviewCrumblingBridge
 - SideviewFlipblock
 - SideviewPendulum
 - SideviewPushblock
 - SideviewSignboard
 - SideviewDoor
 - SideviewTreasureChest
 - SideviewButton
 - SideviewFallingPlatform
 - TwoStateSwitch
 - TwoStateButton
    - Ghosted Enemies -
 - Sideview_Walker
 - Sideview_Jumper
 - Sideview_Hover
 - Sideview_WallCrawl
 - Sideview_SineWave
 - Sideview_WallBounce
 - Sideview_Thwomp
 - Sideview_Leever
 - Sideview_Shooter
 - Sideview_WizzrobeFix
 - Sideview_WallHopper
 - Sideview_LazyChase
 - Sideview_Fish
 - SideviewBlooper
 - SideviewAirBlooper
    - Item -
 -AdjustLinkJump
 -AdjustLinkSpeed
7. Assign Active global script to it`s slot.

**Engine Constants, features and variables** Setup step 3.
All-Caps are constants and read-only, some lower case variables can be read/write at runtime. 

FFC_MISC_SOLIDITY - FFC misc variable to handle FFC solidity in this engine. 
Set it to avoid conflicts with other scripts.
By default, it should be compatible with stdWeapons.zh


EXTENDED_CRUSH_ANIM - Set to >1 to use extended crush animation. Otherwise it will use only 2 rows of frames, horizontal and vertical

//Ladder climbing animation
LINK_LADDER_ALWAYS_FACE_UP - Set to >0 so Link will always face up when climbing ladders, like in Megaman games.
 You also need to set up TILE_LINK_LADDER_CLIMB for  Link`s climbing animation
 and then change constants accordingly
TILE_LINK_LADDER_CLIMB
LINK_LADDER_CLIMB_NUMFRAMES
LINK_LADDER_CLIMB_ASPEED

//Link`s jumping/falling animation.
TILE_LINK_JUMP_ANIM - first tile of animation, shifted by by row depending on direction.
LINK_JUMP_NUMFRAMES - number of frames in animation
LINK_JUMP_ASPEED - delay fetween frames, in frames.
LINK_FALL_FRAME - frame used, when Link is falling at terminal velocity.

//Link swimming animation
TILE_LINK_SWIM_ANIM - Top left corner of block of tiles used for sideview Link swimming animation.
LINK_SWIM_ANIM_NNMFRAMES - Number of frames in each direction for sideview Link swimming animation.
LINK_SWIM_ANIM_ASPEED - Link Swim Anim Aspeed.

//Sprites
SPR_SIDEVIEW_SPLASH - Sprite for sideview water splash, offset by rows depending on direction of Link entering water.
SPR_LAVABURN - Sprite to display, when Link burns in lava
SPR_VARIA_LAVA_SPLASH - Sprite to display, when Link falls into lava while wearing Varia Suit
SPR_AIRBUBBLE - Air bubble sprite
SPR_LINKCRUSH- Sprite used crush animation 3*4 tiles, one for each direction.

// Stair and other scripted combo types.
CT_NEG  - "/" stairs
CT_CROSS - "X" stairs
CT_POS - "\" stairs

Stair combos can be, depending on solidity mask either:
* Non-solid - Link can only mount them only when standing/walking on other solid stuff by pressing Left/Right and Up/Down
depending on circumstances.

* Semi-solid - Link can mount them from any position.
[]_ _[]
-[] []_

* Fully solid stairs - Link can`t walk past them and mount them automatically on attempt to walk against it.
_ [] [] _
[][] [][]

CT_LADDER - Sideview Ladders
CT_SIDEVIEW_WATER - Water in sideview ares. Don`t use normal "water" combos!
This combo type has wide variety of interaction with flippers, depending on now used Power attribute:
 1 - Only walk on bottom and high jump, like in Megaman
 2 - Can swim left and right. Vertical elevation by pressing Jump, like in Mario games.
 3 - Can swim in all 4 direction dith D-pad
If you place Conveyor belt combos on layer 1, thay can overlap with water and make water currents. 
 
CT_LOW_GRAVITY_WELL - Gravity modifier combo types.
CT_HIGH_GRAVITY_WELL 

//Combo Flags
CF_SOFT - Combo Flag for semi-solid platforms, the ones that can be jumped on from below.
CF_SLIPPERY - Combo flag for slippery stuff. Does not work, if Lnk has I_NOSLIP item.  Flag only solid combos!
CF_LAVA - Very Hot lava. Also this flag can be placed on bottom row of the screen to make bottomless pits.
CF_TWOSTATE_OFF - Combo Flag to mark OFF state of combos.
Combo Flag to mark ON state of combos.

//Colors
CSET_TWOSTATE_OFF - CSET used to mark OFF state of combos.
CSET_TWOSTATE_ON - CSET used to mark ON state of combos.

//Audio
SFX_CRUSH - Sound to play when Link gets crushed.
SFX_SIDEVIEW_SPLASH - Sound to play when Link falls into water.
SFX_LAVABURN - Sound to play, when Link burns in lava
SFX_VARIA_LAVA_SPLASH - Sound to play, when Link falls into lava while wearing Varia Suit
SFX_TWOSTATE_SWITCH - Sound to play when two-state switch flicks.

//Engine specific special items
I_NOSLIP - No slipping in icy floors.
I_NOKNOCKBACK - No Knoockback on taking damage.
I_VARIASUIT - This artifact allows swimming in very hot lava.
I_NOCONVEYOR - Negates conveyor belts
I_NOWATERCURRENTS - Negates water currents.

I_SIDEVIEWPEGASUSBOOTS - These items allow Link to gain speed boost by pressing Ex2, like Pegasus Boots.
I_PEGASUSSTAIRS - Stair Pegasus
I_PEGASUSSWIM - Water Pegasus
I_PEGASUSLADDER - Ladder 

//Defenses
CRUSH_DAMAGE - Damage to Link from Crushing, in 1/16ths of heart.
DROWNING_DAMAGE - Damage to Link from drowning, in 1/16ths of heart.
LAVABURN_DAMAGE - Damage to Link from burning in lava, in 1/16ths of heart.
BOTTOMLESS_PIT_DAMAGE - Damage to Link from falling into bottomless pit, in 1/16ths of heart.

//Physics options
CRUSH_LEINENCY - Amount of time, in frames, for Link must be pinched between solid stuff before registering crushing.
SEMISOLID_FFC_CEILING_CRUSH - Set this to >0 to cause Solid-on-top FFCs to crush Link against ceiling, instead of dropping through.
SEMISOLID_LANDING_LEINENCY - Height of Semisolid FFC hitbox. Overrides FFC`s actual Y size.
  Must be greater that Link`s terminal velocity, or Link will sometimes fail to land on semi-solid FFCs.
CONTROLS_ALLOW_VERTICAL_VELOCITY_CONTROL - If set to>0, releasing Jump button in midair, will clamp Link`s VSpeed to [-1; +infinity) range. 
LINK_LADDER_GRIDSNAP - Set to>0, and Link, upon grabbing onto ladder,will be snapped to it and unable to move sideways
SOLID_FFC_PUSH_ENEMIES - Set to >0 to allow FFC to push and crush enemies. They have no crushing leinency.
GHOST_SOLID_FFC_PUSH_GHOSTED_ENEMIES - If you use ghost.zh, set this to >0 to process interaction between solid FFCs 
 and ghosted enemies as well.
RETAIN_HORIZONTAL_VELOCITY_IN_MIDAIR - If set to 1, horizontal velocity won`t reset, when Link is in midair. Needed for bumpers.
AUTOMATIC_HOVER_BOOTS - If set to 1, Hover Boots will auto-trigger when walking off solid combo or at the top of the jump
LINK_GRAV - Link's gravity acceleration.
LINK_TERM - Link's terminal velocity.
CONVEYOR_SPEED - Conveyor belt speed.
KNOCKBACK_SPEED - Knockback sliding Speed 
 Gravity well modifiers.
LOW_GRAVITY_MODIFIER -  Low gravity
HIGH_GRAVITY_MODIFIER - High gravity


//// Custom Engine variables. //Can be edited either during quest init or by item scripts.
// Jump speeds must be negative.

walkspeed - Link's base walk speed.
stairspeedmodifier - Link`s stair movement speed modifier
swimspeedmodifier - Link`s swimming speed modifier
ladderspeedmodifier -  Link`s ladder climbing speed modifier

LinkJump - Link's jump speed.
LinkHop - Link's hop speed.
LinkFrogJump - Link`s out of water jump speed
LinkStompJump - Link`s Stomp jump speed, performed when jumping on enemy with Stomp Boots.
multijump - Link`s Midair Jump count. Adjust it to allow things, like double jump.
hoverboot - Hover Boot duration, in frames

// Link's current movement mode.  Read-Only
int LinkMode;
 
// Link's Location. 
float LinkX;
float LinkY;

float LinkVy = 0; Link's Vertical Velocity.
float LinkVx = 0; //Link`s Horizontal Velocity 
int LinkBlock = BLOCK_HARD; // What Link is standing on. Read-Only

///IMPORTANT
Don`t write to Link->X and Link->Y directly! This won`t work. Write to LinkX and LinkY global variables to move Link around


**FFC Script Functions**
  
void SetSideviewFFCSolidity(ffc f, int s)
* Sets solidity for given FFC.
* 0 - none, 1 - solid-on-top, 2 - fully solid. 

void SetSideviewFFCSolidity(ffc f, int s, bool link, bool enemy)
*  Same as above function, but can be set for either Link only or for enemy only. 
* FFC to FFC collision use FFC_MISC_SOLIDITY
* 0 - none, 1 - solid-on-top, 2 - fully solid.  

int GetSideviewFFCSolidity(ffc f)
* Gets solidity of given FFC.
* 0 - none, 1 - solid-on-top, 2 - fully solid. 

int GetSideviewFFCSolidity(ffc f, bool enemy)
* Gets solidity for given FFC.
* 0 - none, 1 - solid-on-top, 2 - fully solid.
* if "enemy" boolean is set to true, this function will return solidity for enemies, otherwise returns solidity for Link.

/IMPORTANT\
All those solid FFCs and their scripts use EffectWidth and EffectHeight, in pixels, for physics.
TileWidth And TileHeight are only for rendering onto screen.

bool WithinSolidFFC(int x, int y)
* Reurns TRUE, if point at given coordinates is within any solid FFC

bool IsRidden(ffc f)
* Returns true if Link rides this FFC.

bool IsPushed(ffc f, int dir)
* Retuens true if the given FFC is pushed in the given direction

void HardCrush(int damage, int dir)
* Crushes Link immediately. Use this, if velocity of solid FFC can exceed 5-6 to avoid clipping through solid combos.

int GetLinkVx()
* Returns Link`s horizontal velocity in previous frame.

int GetLinkVy()
* Returns Link`s vertical velocity in previous frame.

void ProcessScriptedDamage(int damage)
* Immediately deal damage to Link, with respect to invincibility frames.

int IsPressed(ffc f, int scr)
* Returns ID of FFC that is on this FFC, or 0, if none

bool GSD_CanWalk(ffc f, int x, int y, int dir, int step, bool full_tile)
* Similar to CanWalk, but also pays attention to solid FFCs

void TransformIntoPushblock(ffc g, int weight, int pushspeed, int floating)
* Transforms FFC into pushable block, inhereting data, size and CSet with given weight (bracelet level needed to push), push speed and buoyancy. 

*Ghosted enemy functions*

bool Ghost_WithinSolidFFC(ffc g, int x, int y)
* Reurns TRUE, if point at given coordinates is within any solid FFC, except the given one.

bool GSD_CanWalk(ffc f, int x, int y, int dir, int step, bool full_tile)
*Like Can Walk, but also checks for solid FFCs.

bool Ghost_GSDOnSideviewPlatform( ffc f, npc ghost, int imprecision)
* Returns TRUE, if the ghosted enemy is currently on platform or solid/semisolid FFC. Used in sideview areas.
* Imprecision used to ignore certain amount of pixels on the edges, so Enemy can drop trough gaps that 
* are as wide as enemy itself. Imrecision is unused with Solid FFCs.

bool GhostGSDOnSideviewSolidFFC (ffc n, npc ghost)
* Same as Ghost_GSDOnSideviewPlatform, but uses solid & solid-top FFCs only.

bool Ghost_GSDCanMove(ffc this, int dir, float step, int imprecision)
* Same as Ghost_CanMove, but also handles interaction with solid FFCs.

bool Ghost_WasStomped(npc en)
* Returns true, if ghosted enemy was stomped this frame.

void Ghost_SetSolidity(ffc f, npc ghost, int solidity)
* Sets enemy solidity. 
 1. allows cranium riding. 
 2. is fully solid enemy that can push and crush anything except look-alike and incorporeal enemies.
 
void Ghost_MoveToContactPosition(ffc f, npc ghost, int dir)
* Moves ghosted NPC to contact position so it`s in pixel perfect flush contact with stuff it collided.

bool RestrictToSideviewWater(npc ghost)
* Returns True, if enemy is completely underwater.

bool RestrictToSideviewWater(npc ghost, bool reverse)
* Same as prevoius function, but can be reversed. For instance, to make enemy stay away from water.

bool Ghost_CanSwim(npc ghost, int dir)
* Returns True, if enemy can swim in given direction.

** Default FFC scripts **

ffc script GenericSolidFFC
// Default Solid FFC script. To be used mostly with changer FFCs.
// D0: 1-Solid-top, 2-fully solid.
// D1: 1-rotating.
// D2, D3, D4 are used only if D1 is set to 1.
// D2: starting angle
// D3: Rotating speed, in degrees, use negative to reverse direction.
// D4: Distance from Axis, in pixels

ffc script SideviewPendulum
//Sideview Castheania stiyled rideable pendulum swinging platform.
//1. Set up 2 default tiles, 1 for axis, 1 for chain link.
//2. Set TILE_PENDULUM_CHAINLINK and TILE_PENDULUM_AXIS constant to assign default graphics.
//3. Place FFC on the screen to defile period and starting swing
// D0 - Combo location of axis.
// D1 - 1 for or semi-solid block, 2 for fully sold block.
// D2 - Number of links in chain.
// D3 - Swinging acceleration, in degrees per frame.
// D4 - Damage by hitting by underside. Or by entire hitbox, if pendulum is non-solid.
// D5 - Tile used to render axis. If left to 0, defaults to TILE_PENDULUM_AXIS.
// D6 - Tile used to render chain links. If left to 0, defaults to TILE_PENDULUM_CHAINLINK.

ffc script RideableCrusher
//Generic rideable crusher with damaging spikes at bottom
//D0 - damage, in 1/4ths of heart

ffc script ScreenChange
//Sideview engine`s screen changing function fails to handle wariping into the same screen,
//as well as scrolling into the same screen, when scrolling is disabled by quest rule, mostly in maze paths.
//You neeâ to place FFCs with this script in those screens.

ffc script SideviewFlipblock
//Sideview Castlevania styled Flipblock Trapdoor. Flips when Link jumps on it.
SIDEVIEW_FLIPBLOCK_WARNING_CSET - Cset used to recolor FFC, when flipblock is about to spin and become non-solid.
//1. For flipblocks with damaging undersides set up 2 combos, 1 for normal, 1 for flipped side.
//2. Place where it shoild be, assign 1st combo from step 1.
// D0 - 1 for or semi-solid block, 2 for fully sold block.
// D1 - Flipping speed for trapdoor, in degrees per frame.
// D2 - if > 0 this flipblock has spiky underside which deals assigned damage when touched, in 1/4ths of heart.
// D3 - Set to >0, and flipblock, when flipping, will detach and fall, like late-game flipblock traps in Bloodstained 1.
// D4 - Set to >0, and filpblock will flip over even just by walking on it.


ffc script SideviewPushblock
//Sideview stacking stack-pushable block that can fall off solid stuff.
//1. Check the constants:
SFX_SIDEVIEW_PUSHBLOCK_FALL - Sound to play when sideview pushable block falls off ledge.
SFX_SIDEVIEW_PUSHBLOCK_CRASH - Sound to play when sideview pushable block hits ground while falling.
I_SIDEVIEW_PUSHBLOCK_STACKPUSH - Item needed to allow pushing several blocks at once.
SIDEVIEW_PUSHBLOCK_PUSHSPEED - Link`s pushing speed, in pixels per frame. Recommended range 0 - 1.
//2. Place FFC where ypu wat block to be. Any size works here.
//D0 - weight. Used, when determining Power Bracelet level needed to push it.
//D1 - push speed. If stack of blocks with different D1 id pushed, slowest one is used.
//D2 - Set to 1, and block will be able to float in water
//Rest of D inputs must be 0.

ffc script SideviewCrumblingBridge
//Sideview Castlevania styled multi screen spanning crumbling bridge.
//1. Check out constants:
CF_SIDEVIEW_CRUMBLING_BRIDGE_END - Combo flag used to as end point of crumbling bridge.
SIDEVIEW_CRUMBLING_BRIDGE_SCREEN_QUAKE - Intansity of screen quake when bridge is crumbling.
SFX_SIDEVIEW_CRUMBLING_BRIDGE_FALLING_BRICK - Sound to play when brick falls off bridge during crumbling.
//2. Build the bridge to be crumbled - a row of solid combos across multiple screens.
//3. Place FFC at the start of bridge in 1st screen.
//4. Place FFC anywhere on the bridge in subsequent screens.
// D0 - Bridge crumbling speed, in pixels per frame
// D1 - Must be 1 in starting screen, 0 in subsequent to ensure proper respawning of crumbled bridge.
// D2 - Screen D register - to track bridge crumbling process across multiple screens.
// D3 - Delay, in frames, between Link stepping on bridge and starting crumbling. Used only id D1 is set to 1.
// D4 - Damage caused by falling bricks. Set to 0 to disable collision detection.
// D5 - Sprite used for falling bricks.

ffc script StrongmanTrashCleaningPuzzle
//Fun little puzzle, using superhuman powers granted to Link by I_SIDEVIEW_PUSHBLOCK_STACKPUSH item.
//Push all solid pushable FFCs, so they fall off bottom of the screen, and secrets will pop open.
//Place FFC with script anywhere in the screen. No arguments needed.

ffc script SideviewSignboard
//Sideview signboard. A to read.
//D0 - String to display.

ffc script SideviewDoor
//Sideview door. Press Up to enter. Can be locked by any type of lock, including secret-operated one.
//1. Set up 4 consecutive invisible Senditive Warp comboc A-D
//2. Set CMB_SIDEVIEW_DOOR_WARPSET constant to 1st combo from step 1.
//3. Import and compile the script.
//4. Place the door FFC with script assigned.
//    D0 - warp A-D
//    D1 - lock type. 
//     0 - none, 1 normal key, 2 - boss key, 3 - trigger secrets to open.  
//5. Set flag "Run script at Screen Init".

ffc script SideviewTreasureChest
//Sideview Treasure Chest. Press A to open and claim contents. Can be locked by any type of lock, including secret-operated one.
//1. Import and compile the script.
//2. Place the door FFC with script assigned.
//    D0 - ID of item inside the chest.
//    D1 - lock type. 
//     0 - none, 1 normal key, 2 - boss key, 3 - trigger secrets to open.  
//3. Set flag "Run script at Screen Init".

ffc script SideviewButton
//Sideview button. can be pressed by jumping on it and putting pushblock on it. All of them must be pressed to trigger secrets.
//Set up 2 consequtive combos, 1 for idle, 1 for pressed. make sure that bottom 4 rowa of pixels are unused
//Place FFC with 1st combo from step 1
//D0 - OR together: 1- Link can press button, 2 - Pushblocks can press button.
//D1 - IF set to >0, it stays pressed when released.
//D2 - sound to play on button press.
//D3 - solidity

ffc script SideviewFallingPlatform
//A platform that. if Link or solid block is on top of it will fall.
// D0 - add together flags.
//   1 - Link can trigger fall of elevator.
//   2 - Pushabke blocks can trigger flags.
//   4 - Once triggered, his warning countdown timer will never reset, unlike Donut Lift-like behavior, if this flag os not set.
//   8 - If you set this flag and D2 to 2 cause lift to float in water, on fall.
// D1 - Warning countdown time, in frames.
// D2 - Solidity. 1 - Solid-on-top, ignores solidity when falling. 2 - Fully solid block. Becomes pushable block when falling.
// D3 - If D2 is set to 2, this argument defines bracelet level needed to push fallen lift.
// D4 - If set to 1, uses 3-combo extended animation, normal-warning-falling.

Certain combos can be switched on and off, depending on flag placement. If switch state is ON, all combos flagged with CF_TWOSTATE_OFF 
will change to next combo in the table and flag will change to CF_TWOSTATE_ON. If switch state is OFF, all combos flagged with CF_TWOSTATE_ON 
will change to previous combo in the table and flag will change to CF_TWOSTATE_OFF. Use placed flags only. 

void UpdateTwoStateCombos()
//Main function that checks state of switch and update combos, csets and flags. Must be in main loop of active global script.

ffc script TwoStateSwitch
Hit it with lweapon to flick 2-state switch

D0 - ID of lweapon that works with this switch. 0 - any weapon
D1 - Sound to play on switch hit.

ffc script TwoStateButton
Step on it to flick 2-state switch. It stays pressed until state changes again.
D0 - State of switch it needs to be to be able to be pressed.


** Enemies **
Long ago Moosh has posted a collab script featuring a pack of ghosted enemies designed for sideview areas.
I have adapted it for using this engine so they don`t glitch out when encountering solid FFCs.
Detailed instructions on how to set them up is in icluded SideviewEnemies txt file.

** Default Item scripts **

Make sure that those items, once acquired will always stay in Link`s inventory.

item script AdjustLinkJump
//Adjusts Link`s jumping powers. Assign to Pickup script slot.
// D0 -  Link's full jump speed.
// D1 - Link's jump speed while holding down.
// D2 - Link`s out of water jump apeed
// D3 - Link`s stomping speed
// All above arguments must be negative ones.
// D4 - Number of midair jumps before having to land.
// D5 - Hover boot duration. If you use actual Hover Boots, set their Hover Duration to 0.
// D6 - String to display on item puckup.

item script AdjustLinkSpeed
//Adjusts Link`s movement speed. Assign to Pickup script slot.
// D0 - Link`s walking speed.
// D1 - Link`s stair movement speed, relative to his ground movement.
// D2 - Link`s swim speed, relative to his ground movement.
// D3 - String to display on item puckup.
// D4 - Link`s Ladder climbing speed, relative to his ground movement.

Credits:
Moosh -  for helping with solid FFCs and oranizing collab for sideview enemies.
  - And for bumper script.
P-Tux7 - for helping with sideview Link swimming tiles and other graphics for demo quest.
