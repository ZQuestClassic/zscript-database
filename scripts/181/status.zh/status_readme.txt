status.zh


//


A header for managing status effects applied to Link.


//

Have you ever played RPG`s? Or metroidvanias? Well, one thing that can turn the tables when fighting certain enemies is status effects that affect character in various ways after certain events, being getting hit by certain enemies or using certain items. They can be negative, like poison or petrification, or positive, like invincibility or regeneration. All in all this library allows to bring status effects in ZC! By default, it features 8 negative status effects to use, but you can add more effects, insluding positive ones.
All status effects have 4 phases:
1. Has started. This phase indicates the moment the status effect has bee induced. The code here runs one time.
2. Active. Default state of effect. Runs every frame until timer expires, unless status effect is permanent.
3. Has expired. Occurs, when status effect timer has expired naturally. Code here runs once. Permanent status effects can`t have this state.
4. Has cleared. Occurs, when status effect has been cleared prematurely by any way. The best example is neutralizing poison with antidote.

//

Setup

Requires StdExtra.zh and all it`s dependencies.

1. Global script combining: put InitStatusEffects(); inside your Init global script. Put StatusEffectsUpdate1(); and UpdateStatusTimers(); BACK TO BACK inside the main loop of your 
Active global script, prior to Waitdraw();
2. Import and compile the library.
3. Assign item and FFC scripts that come with library to approriate slots, 3 FFC and 3 item scripts total.

P.S. Instructions on adding more status effects are inside library file.

//

Functions

void InitStatusEffects()
//Status timers initializing function. To be called during Init global script.

void StatusEffectsUpdate1()
//Main status effect updating function. Run in main loop of global script prior to performing game logic (Waitdraw()).

void UpdateStatusTimers()
//Updates timers for non-permanent status effects. To be executed in global script right after StatusEffectsUpdate()

void InduceStatusEffect (int status, int duration, int nullifier, bool uncurable)
//Induces given status effect with set time. Set "nullifier" to allow specific item to prevent specific status effect/s from being applied to Link. "Uncurable" boolean controls whether the status effect can be removed by various means or not. Pass STATUS_TIME_PERMANENT into "duration" for permanent status effect.
/!\ WARNING! Current Status effects and their remaining timers are recorded in player`s save file!

void RemoveStatusEffect(int status, bool uncurableforceremove)
//Removes the given status effect. "uncurableforceremove" when set to TRUE bypasses default inability to remove status //effect by default means and removes this status effect no matter what.

bool HasStarted(int status)
//Returns TRUE, if the status effect has been recently bestowed upon Link.

bool IsActive(int status)
//Returns TRUE, if the status effect is currently active.

bool HasExpired(int status)
//Returns TRUE, if the status effect has recently expired: his timer hit 0.

bool HasRemoved(int status)
//Returns TRUE, if the status effect has been recently removed, such as by using item.

bool IsPermanent (int status)
//Returns TRUE if the given status effect is permanent and therefore does not expire on it`s own.

bool IsCurable(int status)
//Returns TRUE if the given status effect cannot be cured by normal ways.



Item scripts


item script CureStatusEffect
//Item that removes specific status effect when used/picked up.
//Can be used as "On Use" item script, like various antidotes,
//or "On Pickup", for item that prevents given status effect. 
//D0: Status to remove.
//D1: Clear normally uncurable status effect. 0 - false, 1 - true

item script SetStatusEffect
//Item that applies status effect (usually positive) on activation or pickup.
//Best used on potions.
//D0: Status to apply.
//D1: Effect duration.
//D2: Sound to play on usage.

item script CureALL
//Removes ALL curable status effects when used/picked up. Like the milk in Minecraft.
//Best used as "On Use" item script, for universal "Cure All" potion.
//No arguments needed.


FFC scripts


ffc script StatusDebug
//This is a FFC script for testing and debugging status effects. Any time Link gets hurt by anything on the screen with this FFC he will instantly cursed by given status effect for the given time. Use this script to debug custom status effects.
//Controls: L/R to cycle trough status effects to apply to Link.
//Place FFC anywhere in the screen.
// D0 - Default index to status effect.
// D1 - Duration, in frames. Set D1 to 200000 to render status effect permanent.

ffc script FairyStatusRemover
//Step on FFC with this screen and all curable status effect will be removed instantly.
//Place FFC on the same place as Fairy Ring combo flags. Expand accordingly.
//D0: sound to play on curing status effects.

ffc script CursedZone
//This FFC script curses any character with given status effect as long as the script is running. FFC carryover can be enabled to expand cursed area beyond one screen.
//Place FFC anywhere in the screen.
//D0: Index to status array. Set it to define which status effect is induced.
//D1: Item that prevents this curse as long as it`s in character`s inventory.