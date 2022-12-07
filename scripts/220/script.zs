////////////////////////////////////////////////////////////////
// Phantom Cloak
// by grayswandir
////////////////////////////////////////////////////////////////
// The Phantom Cloak is an item that allows you to dash forward several tiles
// (possibly through special blocks that would normally be solid), dealing
// damage along the way. You also leave a bait at your original location,
// drawn transparently.
//
// To setup, you need to examine everything in the following Integration
// section to make sure that it's compatible with your quest. The following
// two sections, Behavior and Default Arguments, have isolated some of the
// easier parts of the script to modify.
//
// Then, give an item the activation script Use_PhantomCloak. The arguments
// are in the same order and effect as in the Default Arguments section - any
// item argument left at 0 will instead be set to those values.
//
// You'll also need to call PhantomCloak_Update in your main active script
// loop.
//
// Note that this makes use of global variables, so adding it will invalidate
// any saves you have.

////////////////////////////////////////////////////////////////
// Integration
////////////////
// The code in this section needs to be modified on a per-quest basis.

// Set this to be a completely transparent tile. Cannot be 0.
const int PCLOAK_TILE_EMPTY = 4;
// Set this to be a completely transparent combo. Cannot be 0.
const int PCLOAK_COMBO_EMPTY = 41;

// This is the weapon id to be used for the cloak's attack. Set it to be
// something that won't interfere with any other scripts.
const int PCLOAK_WEAPON_ID = 31;

////////////////
// Cloak Animation: The cloak's graphics are set up as a sequence of
// animations. There's two parts - an animation to be drawn in place of link
// while they're dashing, and an animation to use as the bait. Each animation
// is PCLOAK_NUM_FRAMES long, and they are laid out in this order:
// - Dash Up
// - Dash Down
// - Dash Left
// - Dash Right
// - Bait Up
// - Bait Down
// - Bait Left
// - Bait Right
// Each cloak item may specify their own set of animations, but they must all
// be in this same format.

// The number of frames. Set this to match whatever animation you are using.
const int PCLOAK_NUM_FRAMES = 1;
// How many game frames each animation frame lasts.
const int PCLOAK_ASPEED = 8;

////////////////////////////////////////////////////////////////
// Behavior
////////////////
// The code in this section can be left unmodified, but is set up to be easily
// changed to allow for different behaviors.

// The number of frames to delay before dashing.
const int PCLOAK_DELAY = 2;
// The number of frames to delay after landing.
const int PCLOAK_RECOVERY = 8;

// Sound effect to play if the cloak can't be used because of range. Set to 0
// for none.
const int PCLOAK_SFX_ERROR = 58;

// The amount of pixels we'll move sideways to fit in a gap.
const int PCLOAK_TOLERANCE = 8;

////
// The following functions determine what sort of combos the phantom cloak can
// traverse.

// This function is used to determine if Link can land on a given pixel. You
// should modify this function if you want to change landing behavior.
bool PhantomCloak_CanLand_Pixel(int x, int y) {
	return !Screen->isSolid(x, y);
}

// Return true if the phantom cloak can land link at the given
// coordinates. You shouldn't need to modify this function, just the one
// above.
bool PhantomCloak_CanLand(int x, int y) {
	y += 8;
	if (!PhantomCloak_CanLand_Pixel(x, y)) {return false;}
	x += 15.9999;
	if (!PhantomCloak_CanLand_Pixel(x, y)) {return false;}
	y += 7.9999;
	if (!PhantomCloak_CanLand_Pixel(x, y)) {return false;}
	x -= 15.9999;
	if (!PhantomCloak_CanLand_Pixel(x, y)) {return false;}
	return true;
}

// Return true if the phantom cloak can pass link through the given
// coordinates. This is separated from CanLand in case you want to be able to
// go over pitfalls, or through special blocks, and such. If you only care
// about the landing point, just set this to return true directly.
bool PhantomCloak_CanPass_Pixel(int x, int y) {
	return !Screen->isSolid(x, y) || ComboFI(x, y, CF_SCRIPT2);
}

// Again, you shouldn't need to modify this function, just the above one.
bool PhantomCloak_CanPass(int x, int y) {
	y += 8;
	if (!PhantomCloak_CanPass_Pixel(x, y)) {return false;}
	x += 15.9999;
	if (!PhantomCloak_CanPass_Pixel(x, y)) {return false;}
	y += 7.9999;
	if (!PhantomCloak_CanPass_Pixel(x, y)) {return false;}
	x -= 15.9999;
	if (!PhantomCloak_CanPass_Pixel(x, y)) {return false;}
	return true;
}

////////////////////////////////////////////////////////////////
// Default Arguments
////////////////
// These are the default item arguments. If any of an item's arguments are 0,
// these are used in their place. You can change them if it's convenient.

// The set of tiles to use. Set to the first tile in the sequence.
const int PCLOAK_DEFAULT_TILES = 30601;
// The default cset of the tiles.
const int PCLOAK_DEFAULT_CSET = 6;
// The minimum travel distance.
const int PCLOAK_DEFAULT_MIN_DISTANCE = 20;
// The maxmium travel distance.
const int PCLOAK_DEFAULT_MAX_DISTANCE = 48;
// The dashing speed in pixels per frame. For reference, normal walking speed
// is around 1.5.
const int PCLOAK_DEFAULT_SPEED = 4;
// The bait duration.
const int PCLOAK_DEFAULT_DURATION = 150;
// The default damage for the dash.
const int PCLOAK_DEFAULT_DAMAGE = 2;

////////////////////////////////////////////////////////////////
// Main Script

// Yet again, I'm writing these two functions...
int PhantomCloak_DirX(int dir) {
	if (DIR_LEFT == dir || DIR_LEFTUP == dir || DIR_LEFTDOWN == dir) {return -1;}
	if (DIR_RIGHT == dir || DIR_RIGHTUP == dir || DIR_RIGHTDOWN == dir) {return 1;}
	return 0;
}
int PhantomCloak_DirY(int dir) {
	if (DIR_UP == dir || DIR_LEFTUP == dir || DIR_RIGHTUP == dir) {return -1;}
	if (DIR_DOWN == dir || DIR_LEFTDOWN == dir || DIR_RIGHTDOWN == dir) {return 1;}
	return 0;
}

// Get the script id for the main ffc script.
int PhantomCloak_ScriptId() {
	int name[] = "PhantomCloak";
	return Game->GetFFCScript(name);
}

int PhantomCloak_Screen = -1;
bool PhantomCloak_InUse = false;

void PhantomCloak_Update() {
	int screen = Game->GetCurDMap() << 8 + Game->GetCurDMapScreen();
	if (PhantomCloak_Screen != screen || Link->HP <= 0) {
		PhantomCloak_Screen = screen;
		if (PhantomCloak_InUse) {
			PhantomCloak_InUse = false;
			Link->CollDetection = true;
			Link->Invisible = false;
		}
	}
}

bool PhantomCloak_CheckDirection(int x, int y, int dir, int min_distance, int max_distance, int dist_array) {
	int dx = PhantomCloak_DirX(dir) * 8;
	int dy = PhantomCloak_DirY(dir) * 8;
	dist_array[0] = 0;
	int land_dist = 0;

	while (dist_array[0] < min_distance) {
		dist_array[0] += 8;
		x += dx;
		y += dy;
		if (!PhantomCloak_CanPass(x, y)) {return false;}
	}
	while (dist_array[0] <= max_distance) {
		dist_array[0] += 8;
		x += dx;
		y += dy;
		// If we can land here, mark it.
		if (PhantomCloak_CanLand(x, y)) {
			land_dist = dist_array[0];
		}
		// If we can't pass, stop looking.
		else if (!PhantomCloak_CanPass(x, y)) {
			break;
		}
	}
	dist_array[0] = land_dist;
	return land_dist;
}

// The activation script for the cloak. For the item arguments, see the
// "Default Arguments" section above.
item script Use_PhantomCloak {
	void run(int tiles, int cset, int min_distance, int max_distance, int speed, int duration, int damage) {
		if (PhantomCloak_InUse) {
			// Loop through every ffc, looking for the phantom cloak ffc. If we
			// don't find any, it means we messed up somewhere and it's not actually
			// in use.
			int script_id = PhantomCloak_ScriptId();
			bool found = false;
			for (int i = 1; i <= 32; ++i) {
				ffc x = Screen->LoadFFC(i);
				if (script_id == x->Script) {
					found = true;
					break;
				}
			}
			if (found) {
				return;
			} else {
				PhantomCloak_InUse = false;
				Link->CollDetection = true;
				Link->Invisible = false;
			}
		}

		// Get diagonal possibly.
		int dir = Link->Dir;

		// Ignore for now, doesn't have proper collision detection.
		//if (DIR_UP == dir) {
		//	if (Link->InputLeft) {dir = DIR_LEFTUP;}
		//	else if (Link->InputRight) {dir = DIR_RIGHTUP;}
		//} else if (DIR_DOWN == dir) {
		//	if (Link->InputLeft) {dir = DIR_LEFTDOWN;}
		//	else if (Link->InputRight) {dir = DIR_RIGHTDOWN;}
		//}	else if (DIR_LEFT == dir) {
		//	if (Link->InputUp) {dir = DIR_LEFTUP;}
		//	else if (Link->InputDown) {dir = DIR_LEFTDOWN;}
		//}	else if (DIR_RIGHT == dir) {
		//	if (Link->InputUp) {dir = DIR_RIGHTUP;}
		//	else if (Link->InputDown) {dir = DIR_RIGHTDOWN;}
		//}

		if (!tiles) {tiles = PCLOAK_DEFAULT_TILES;}
		if (!cset) {cset = PCLOAK_DEFAULT_CSET;}
		if (!min_distance) {min_distance = PCLOAK_DEFAULT_MIN_DISTANCE;}
		if (!max_distance) {max_distance = PCLOAK_DEFAULT_MAX_DISTANCE;}
		if (!speed) {speed = PCLOAK_DEFAULT_SPEED;}
		if (!duration) {duration = PCLOAK_DEFAULT_DURATION;}
		if (!damage) {damage = PCLOAK_DEFAULT_DAMAGE;}

		bool valid = false;
		int distance[1] = {0};

		// Check to see if we have a valid path.
		valid = PhantomCloak_CheckDirection(Link->X, Link->Y, Link->Dir, min_distance, max_distance, distance);

		int x = Link->X;
		int y = Link->Y;

		// Check tolerances.
		// Up
		if (!valid && (DIR_LEFT == Link->Dir || DIR_RIGHT == Link->Dir)
				&& ((Link->Y % 8) > 0) && ((Link->Y % 8) < PCLOAK_TOLERANCE)) {
			valid = PhantomCloak_CheckDirection(
					Link->X, Link->Y & ~7, Link->Dir, min_distance, max_distance, distance);
			if (valid) {y = (Link->Y & ~7);}
		}
		// Down
		if (!valid && (DIR_LEFT == Link->Dir || DIR_RIGHT == Link->Dir)
				&& (Link->Y >> 3 != ((Link->Y + PCLOAK_TOLERANCE) >> 3))) {
			valid = PhantomCloak_CheckDirection(
					Link->X, (Link->Y & ~7) + 8, Link->Dir, min_distance, max_distance, distance);
			if (valid) {y = (Link->Y & ~7) + 8;}
		}
		// Left
		if (!valid && (DIR_UP == Link->Dir || DIR_DOWN == Link->Dir)
				&& (Link->X % 8 > 0) && (Link->X % 8 < PCLOAK_TOLERANCE)) {
			valid = PhantomCloak_CheckDirection(
					Link->X & ~7, Link->Y & ~7, Link->Dir, min_distance, max_distance, distance);
			if (valid) {x = Link->X & ~7;}
		}
		// Right
		if (!valid && (DIR_UP == Link->Dir || DIR_DOWN == Link->Dir)
				&& (Link->X >> 3 != ((Link->X + PCLOAK_TOLERANCE) >> 3))) {
			valid = PhantomCloak_CheckDirection(
					(Link->X & ~7) + 8, Link->Y, Link->Dir, min_distance, max_distance, distance);
			if (valid) {x = (Link->X & ~7) + 8;}
		}

		if (!valid) {
			if (PCLOAK_SFX_ERROR) {Game->PlaySound(PCLOAK_SFX_ERROR);}
			return;
		}

		// Setup ffc script.
		for (int i = 1; i <= 32; ++i) {
			ffc f = Screen->LoadFFC(i);
			if (!f->Data && !f->Script) {
				f->Script = PhantomCloak_ScriptId();
				f->Data = PCLOAK_TILE_EMPTY;
				f->InitD[0] = tiles;
				f->InitD[1] = cset;
				f->InitD[2] = distance[0] / speed;
				f->InitD[3] = duration;
				f->InitD[4] = damage;
				f->InitD[5] = x + PhantomCloak_DirX(dir) * distance[0];
				f->InitD[6] = y + PhantomCloak_DirY(dir) * distance[0];
				f->Data = PCLOAK_COMBO_EMPTY;
				break;;
			}
		}
	}
}

// A helper script for the cloak. Created by the item script.
ffc script PhantomCloak {
	void run(int tiles, int cset, int move_duration, int bait_duration, int damage, int tx, int ty) {
		PhantomCloak_InUse = true;

		int x = Link->X;
		int y = Link->Y;
		int dx = (tx - Link->X) / move_duration;
		int dy = (ty - Link->Y) / move_duration;

		// Delay link acting, and exit if we get hurt.
		int link_timer = PCLOAK_DELAY;
		while (link_timer > 0) {
			--link_timer;
			NoAction();
			if (LA_GOTHURTLAND == Link->Action || LA_GOTHURTWATER == Link->Action) {
				this->Data = 0;
				PhantomCloak_InUse = false;
				return;
			}
			Waitframe();
		}

		// Setup the bait.
		lweapon bait = Screen->CreateLWeapon(LW_BAIT);
		bait->X = Link->X;
		bait->Y = Link->Y;
		bait->OriginalTile = PCLOAK_TILE_EMPTY;
		bait->NumFrames = 1;
		bait->CollDetection = false;
		bait->DeadState = WDS_ALIVE;
		bait->Dir = Link->Dir;

		// Setup the dash weapon.
		lweapon dash = Screen->CreateLWeapon(LW_SCRIPT1);
		dash->Damage = damage;
		dash->OriginalTile = tiles + Link->Dir * PCLOAK_NUM_FRAMES;
		dash->ASpeed = PCLOAK_ASPEED;
		dash->NumFrames = PCLOAK_NUM_FRAMES;
		dash->CSet = cset;
		dash->Dir = Link->Dir;
		dash->X = 100;
		dash->Y = 100;

		// Link is invincible!!!
		Link->CollDetection = false;
		Link->Invisible = true;

		// Loop, handling the bait, the weapon, and link. It'll only exit once all
		// three are done.
		int bait_timer = bait_duration;
		while (link_timer > 0 || dash->isValid() || bait->isValid()) {
			// Insurance
			if (!dash->isValid() && Link->Invisible) {
				Link->CollDetection = true;
				Link->Invisible = false;
			}

			// We're still moving.
			if (move_duration > 0) {
				// Kill normal movement.
				Link->InputUp = false; Link->PressUp = false;
				Link->InputDown = false; Link->PressDown = false;
				Link->InputLeft = false; Link->PressLeft = false;
				Link->InputRight = false; Link->PressRight = false;

				// Move link.
				x += dx;
				Link->X = x;
				y += dy;
				Link->Y = y;
				--move_duration;

				// Align the dash weapon.
				dash->HitXOffset = Link->X - 100;
				dash->HitYOffset = Link->Y - 100;
				dash->DrawXOffset = Link->X - 100;
				dash->DrawYOffset = Link->Y - 100;
				dash->DeadState = WDS_ALIVE;

				if (move_duration <= 0) {
					// Start the recovery phase.
					link_timer = PCLOAK_RECOVERY;
					PhantomCloak_InUse = false;
				}
			}
			// We're recovering.
			else if (link_timer >= 0) {
				--link_timer;
				// Get rid of the dash. We do it here because we don't want link to be
				// vulnerable during the last frame of movement.
				if (dash->isValid()) {
					Remove(dash);
					Link->CollDetection = true;
					Link->Invisible = false;
				}
				// Don't move during recovery.
				NoAction();
				// Exit out of recovery if you got hurt.
				if (LA_GOTHURTLAND == Link->Action || LA_GOTHURTWATER == Link->Action) {
					link_timer = 0;
					PhantomCloak_InUse = false;
				}
			}

			// Countdown the bait timer and draw it.
			if (bait_timer > 0) {
				--bait_timer;
				int tile = tiles + PCLOAK_NUM_FRAMES * (4 + bait->Dir);
				tile += (((bait_duration - bait_timer) / PCLOAK_ASPEED) % PCLOAK_NUM_FRAMES) >> 0;
				Screen->DrawTile(0, bait->X, bait->Y, tile, 1, 1, cset, -1, -1, 0, 0, 0, 0, true, OP_TRANS);
			}
			// Otherwise get rid of it.
			else if (bait->isValid()) {
				Remove(bait);
			}

			Waitframe();
		}

		this->Data = 0;
	}
}