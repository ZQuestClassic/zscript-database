// Necessary headers, uncomment (remove "//") if you haven't already imported these.
//import "std.zh"
//import "string.zh"
//import "ghost.zh"

const int SPRITE_NULL = 88; // A sprite with a blank tile. Tile 0 is NOT a blank tile.
const int TILE_SPINNUT_SWORD = 28636; // The tile of the Spinnut's sword. Only a single tile is needed, a sword with its blade pointing right.
const int CSET_SPINNUT_SWORD = 11; // Default CSet of Spinnut's sword. Flashes through CSets 7 through 9 while charging spin attack.
const int SFX_SPINNUT_READY = 65; // SFX played when starting charge for spin attack.
const int SFX_SPINNUT_GO = 66; // SFX played when starting spin attack.

// ENEMY MISC. ATTRIBUTES
// Misc. Attribute 1: How long Spinnut stops before it begins charging its sword.
// Misc. Attribute 2: How long Spinnut charges its sword before spinning.
// Misc. Attribute 3: How long Spinnut spins.
ffc script Spinnut
{
	void run(int enemyID)
	{
		npc ghost = Ghost_InitAutoGhost(this, enemyID);
		Ghost_SetFlag(GHF_SET_DIRECTION);
		
		int counter = -1;
		float angle;
		int sword_tile_x;
		int sword_tile_y;
		int sword_flash = 7;
		int halt_time = ghost->Attributes[0]; // Set to 60 for demo purposes.
		int charge_time = ghost->Attributes[1]; // Set to 120 for demo purposes.
		int spin_time = ghost->Attributes[2]; // Set to 240 for demo purposes.
		
		while (true)
		{
			// Arbitrarily large number used for halt time argument, since Spinnut does something else after halt_time frames anyway.
			counter = Ghost_HaltingWalk4(counter, ghost->Step, ghost->Rate, ghost->Homing, ghost->Hunger, ghost->Haltrate, 65535);
			
			if (counter == 65535 - halt_time)
			{
				counter = 15;
				Game->PlaySound(SFX_SPINNUT_READY);
				if (Ghost_Dir == DIR_UP)
				{
					angle = 270;
				}
				if (Ghost_Dir == DIR_DOWN)
				{
					angle = 90;
				}
				if (Ghost_Dir == DIR_LEFT)
				{
					angle = 180;
				}
				if (Ghost_Dir == DIR_RIGHT)
				{
					angle = 0;
				}
				sword_tile_x = Ghost_X + (12 * Cos(angle));
				sword_tile_y = Ghost_Y + (12 * Sin(angle));
				for (int i = 0; i < charge_time; i++)
				{
					Screen->DrawTile(2, sword_tile_x, sword_tile_y, TILE_SPINNUT_SWORD, 1, 1, sword_flash, -1, -1, sword_tile_x, sword_tile_y, angle, 0, true, OP_OPAQUE);
					if (i % 3 == 0)
					{
						sword_flash = (((sword_flash - 7) + 1) % 3) + 7;
					}
					Spinnut_Sword(sword_tile_x, sword_tile_y, ghost->WeaponDamage, angle);
					Ghost_Waitframe(this, ghost);
				}
				Game->PlaySound(SFX_SPINNUT_GO);
				
				for (int i = 0; i < spin_time; i++)
				{
					Ghost_MoveTowardLink(ghost->Step * 0.01, 2);
					Ghost_Dir = AngleDir4(WrapDegrees(angle));
					
					sword_tile_x = Ghost_X + (12 * Cos(angle));
					sword_tile_y = Ghost_Y + (12 * Sin(angle));
					
					Spinnut_Sword(sword_tile_x, sword_tile_y, ghost->WeaponDamage, angle);
					
					Screen->DrawTile(2, sword_tile_x, sword_tile_y, TILE_SPINNUT_SWORD, 1, 1, CSET_SPINNUT_SWORD, -1, -1, sword_tile_x, sword_tile_y, angle, 0, true, OP_OPAQUE);
					angle = (angle + 24) % 360;
					if (i % 15 == 0)
					{
						Game->PlaySound(SFX_SPINATTACK);
					}
					Ghost_Waitframe(this, ghost);
				}
			}
			
			Ghost_Waitframe(this, ghost);
		}
	}
}

// The Spinnut's big sword.
void Spinnut_Sword(int sword_tile_x, int sword_tile_y, int damage, int angle)
{
	eweapon sword = FireNonAngularEWeapon(EW_SCRIPT1, sword_tile_x, sword_tile_y, Ghost_Dir, 0, damage, SPRITE_NULL, 0, EWF_UNBLOCKABLE);
	SetEWeaponLifespan(sword, EWL_TIMER, 1);
	SetEWeaponDeathEffect(sword, EWD_VANISH, 0);
	sword->Dir = AngleDir8(WrapDegrees(angle));
}