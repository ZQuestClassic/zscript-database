// Delete these import lines if you already have them in your script file.

import "std.zh"
import "ffcscript.zh"

const int SPRITE_SPARKLE = 29; // Sparkle sprite for when charge bow is finished charging. NOT FOR ARROW SPARKLES!
const int SFX_BOW_CHARGE = 36; // Sound for when charge bow is finished charging.
const int SFX_ERROR = 61; // Error sound for when Link is out of arrows. Set to 0 for no sound.

int facing_dir;
bool bow_charging[2]; // [0] is true while bow is charging, [1] is true if Link gets hit while charging

global script BowActive
{
	void run()
	{
		while (true)
		{
			Waitdraw();
			BowAnimation();
			Waitframe();
		}
	}
}

void BowAnimation()
{
	if (bow_charging[0])
	{
		// Comment out if you don't want charging interrupted by getting hit!
		// vvv
		if (BowInterrupt())
		{
			bow_charging[0] = false;
			bow_charging[1] = true;
			return;
		}
		// ^^^
		// Comment out if you don't want charging interrupted by getting hit!
		
		Link->Dir = facing_dir;
	}
	bow_charging[0] = false;
}

// The function that determines if the bow charge should be interrupted.
bool BowInterrupt()
{
	if (Link->Action > 1)
	{
		return true;
	}
	return false;
}	

// Bow and arrow tiles cannot exceed 32768!
// Your bow and arrow tiles should be in the order up, down, left, right.
// This item script should be attached to the Action Script slot of an item that has a custom item class, not an existing bow.
// The Power of the item is how much damage it does. Most weapons do two times their "Damage" stat, but not this one!
// D0: bow tile
// D1: bow CSet
// D2: arrow sprite
// D3: arrow step speed (300 for short bow, 600 for long bow are ZC defaults)
// D4: sparkle sprite number, 0 for none
item script LttPBow
{
	void run(int bow_tile, int bow_cset, int arrow_sprite, int arrow_step, int sparkle_sprite)
	{
		// Only triggers if the bow isn't already drawn.
		int script_name[] = "LttPBowFFC";
		int script_num = Game->GetFFCScript(script_name);
		int bow_family = this->Family;
		if (CountFFCsRunning(script_num) == 0)
		{
			float args[] = {bow_tile, bow_cset, arrow_sprite, this->Power, arrow_step, sparkle_sprite, bow_family};
			RunFFCScript(script_num, args);
		}
			
	}
}

ffc script LttPBowFFC
{
	void run(int bow_tile, int bow_cset, int arrow_sprite, int arrow_damage, int arrow_step, int sparkle_sprite, int bow_family)
	{
		itemdata A_item;
		itemdata B_item;
		bool using_B = false;
		
		B_item = Game->LoadItemData(GetEquipmentB());
		if (B_item->Family == bow_family)
		{
			using_B = true;
		}
		
		// Comment this out to give Link's bowmanship a lot less oomph.
		Link->Action = LA_ATTACKING;
		
		// Loop to draw the bow for 15 frames before firing. Similar for loops for additional frames of animation, such as taking out the bow
		// à la Link to the Past, can be placed here.
		for (int i = 0; i < 15; i++)
		{
			A_item = Game->LoadItemData(GetEquipmentA());
			B_item = Game->LoadItemData(GetEquipmentB());
			
			Link->InputUp = false;
			Link->InputDown = false;
			Link->InputLeft = false;
			Link->InputRight = false;
			if (A_item->Family != bow_family)
			{
				Link->InputA = false;
				// Quits if you switch item.
				if (!using_B)
				{
					Quit();
				}
			}
			if (B_item->Family != bow_family)
			{
				Link->InputB = false;
				// Quits if you switch item.
				if (using_B)
				{
					Quit();
				}
			}
			// Disable other button inputs here if you want.
			
			// Quits if Link gets hit. Comment this out if you don't want arrow firing to be interrupted.
			if (Link->Action == LA_GOTHURTLAND)
			{
				Quit();
			}
			
			Screen->FastTile(4, Link->X + InFrontX(Link->Dir, 7), Link->Y + InFrontY(Link->Dir, 7), bow_tile + Link->Dir, bow_cset, OP_OPAQUE);
			
			Waitframe();
		}
		
		// Checks to see that you have arrows and that no previously fired arrows are on screen.
		if ((Game->Counter[CR_ARROWS] > 0 || Link->Item[I_QUIVER4]) && NumLWeaponsOf(LW_ARROW) == 0)
		{
			if (!Link->Item[I_QUIVER4])
			{
				Game->Counter[CR_ARROWS]--;
			}
			Game->PlaySound(SFX_ARROW);
			lweapon arrow = NextToLink(LW_ARROW, 0);
			arrow->UseSprite(arrow_sprite);
			arrow->Damage = arrow_damage;
			arrow->Step = arrow_step;
			arrow->Dir = Link->Dir;
			LWeaponFlip(arrow, arrow->Dir);
			
			//Arrow hitbox shenanigans. Modeled after ZC arrow defaults.
			if (arrow->Dir == DIR_UP || arrow->Dir == DIR_DOWN)
			{
				arrow->HitWidth = 15;
				arrow->HitHeight = 12;
				arrow->HitXOffset = 0;
				arrow->HitYOffset = 2;
				arrow->DrawXOffset = 0;
				arrow->DrawYOffset = -2;
			}
			else
			{
				arrow->HitWidth = 12;
				arrow->HitHeight = 14;
				arrow->HitXOffset = 2;
				arrow->HitYOffset = 2;
				arrow->DrawXOffset = 0;
				arrow->DrawYOffset = 1;
			}
			// Creates sparkles around arrow while it's onscreen, if sprite for them is set.
			for (int i = 0; NumLWeaponsOf(LW_ARROW) > 0 && sparkle_sprite; i = (i + 1) % 4)
			{
				if (i == 0)
				{
					arrow = LoadLWeaponOf(LW_ARROW);
					SetSparkle(arrow, sparkle_sprite);
				}
				
				Waitframe();
			}
		}
		else
		{
			if (Game->Counter[CR_ARROWS] == 0 && !Link->Item[I_QUIVER4] && SFX_ERROR)
			{
				Game->PlaySound(SFX_ERROR); // Plays the error sound, if there is one, when Link is out of arrows.
			}
			Quit();
		}
	}
}

// Bow and arrow tiles cannot exceed 32768!
// Your bow and arrow tiles should be in the order up, down, left, right.
// This item script should be attached to the Action Script slot of an item that has a custom item class, not an existing bow.
// The Power of the item is how much damage it does. Most weapons do two times their "Damage" stat, but not this one!
// D0: bow tile
// D1: bow CSet
// D2: arrow sprite
// D3: arrow step speed (300 for short bow, 600 for long bow are ZC defaults)
// D4: sparkle sprite number, 0 for none
// D5: charge time
item script LttPChargeBow
{
	void run(int bow_tile, int bow_cset, int arrow_sprite, int arrow_step, int sparkle_sprite, int charge_time)
	{
		// Only triggers if the bow isn't already drawn.
		int script_name[] = "LttPChargeBowFFC";
		int script_num = Game->GetFFCScript(script_name);
		int bow_family = this->Family;
		if (CountFFCsRunning(script_num) == 0)
		{
			float args[] = {bow_tile, bow_cset, arrow_sprite, this->Power, arrow_step, sparkle_sprite, charge_time, bow_family};
			RunFFCScript(script_num, args);
		}
			
	}
}

ffc script LttPChargeBowFFC
{
	void run(int bow_tile, int bow_cset, int arrow_sprite, int arrow_damage, int arrow_step, int sparkle_sprite, int charge_time, int bow_family)
	{
		itemdata A_item;
		itemdata B_item;
		bool using_B = false;
		bool fully_charged;
		int bow_charge;
		lweapon sparkle;
		bow_charging[1] = false;
		facing_dir = Link->Dir;
		
		B_item = Game->LoadItemData(GetEquipmentB());
		if (B_item->Family == bow_family)
		{
			using_B = true;
		}
		
		// Comment this out to give Link's bowmanship a lot less oomph.
		//Link->Action = LA_ATTACKING;
		
		// Loop to draw the bow for 15 frames before firing. Similar for loops for additional frames of animation, such as taking out the bow
		// à la Link to the Past, can be placed here.
		for (int i = 0; true; i++)
		{
			A_item = Game->LoadItemData(GetEquipmentA());
			B_item = Game->LoadItemData(GetEquipmentB());
			
			if (i % 2 == 0)
			{
				Link->InputUp = false;
				Link->InputDown = false;
				Link->InputLeft = false;
				Link->InputRight = false;
			}
			if (A_item->Family != bow_family)
			{
				Link->InputA = false;
				// Quits if you switch item.
				if (!using_B)
				{
					Quit();
				}
			}
			if (B_item->Family != bow_family)
			{
				Link->InputB = false;
				// Quits if you switch item.
				if (using_B)
				{
					Quit();
				}
			}
			if (using_B && !Link->InputB)
			{
				if (bow_charge >= charge_time)
				{
					fully_charged = true;
				}
				break;
			}
			else if (!using_B && !Link->InputA)
			{
				if (bow_charge >= charge_time)
				{
					fully_charged = true;
				}
				break;
			}
			else
			{
				bow_charge++;
			}
			// Disable other button inputs here if you want.
			
			// Quits if Link gets hit. Comment this out if you don't want arrow firing to be interrupted.
			if (Link->Action == LA_GOTHURTLAND || bow_charging[1])
			{
				bow_charging[1] = false;
				Quit();
			}
			
			bow_charging[0] = true;
			
			// Charge up sparkle animation.
			if (i == charge_time)
			{
				Game->PlaySound(SFX_BOW_CHARGE);
				sparkle = Screen->CreateLWeapon(LW_SPARKLE);
				sparkle->X = Link->X;
				sparkle->Y = Link->Y;
				sparkle->UseSprite(SPRITE_SPARKLE);
				sparkle->CollDetection = false;
				sparkle->Misc[0] = 15;
			}
			for (int j = 1; j <= Screen->NumLWeapons(); j++)
			{
				sparkle = Screen->LoadLWeapon(j);
				if (sparkle->ID == LW_SPARKLE && sparkle->Misc[0] == 15)
				{
					DrawToLayer(sparkle, 4, OP_OPAQUE);
					sparkle->X = Link->X;
					sparkle->Y = Link->Y;
				}
			}
			
			Screen->FastTile(4, Link->X + InFrontX(Link->Dir, 7), Link->Y + InFrontY(Link->Dir, 7), bow_tile + Link->Dir, bow_cset, OP_OPAQUE);
			
			Waitframe();
		}
		
		Link->Action = LA_ATTACKING;
		
		for (int i = 0; i < 10; i++)
		{
			A_item = Game->LoadItemData(GetEquipmentA());
			B_item = Game->LoadItemData(GetEquipmentB());
			
			Link->InputUp = false;
			Link->InputDown = false;
			Link->InputLeft = false;
			Link->InputRight = false;
			
			if (A_item->Family != bow_family)
			{
				Link->InputA = false;
				// Quits if you switch item.
				if (!using_B)
				{
					Quit();
				}
			}
			if (B_item->Family != bow_family)
			{
				Link->InputB = false;
				// Quits if you switch item.
				if (using_B)
				{
					Quit();
				}
			}
			
			// Quits if Link gets hit. Comment this out if you don't want arrow firing to be interrupted.
			if (Link->Action == LA_GOTHURTLAND)
			{
				Quit();
			}
			
			Screen->FastTile(4, Link->X + InFrontX(Link->Dir, 7), Link->Y + InFrontY(Link->Dir, 7), bow_tile + Link->Dir, bow_cset, OP_OPAQUE);
			
			Waitframe();
		}
		
		// Checks to see that you have arrows and that no previously fired arrows are on screen.
		if ((Game->Counter[CR_ARROWS] > 0 || Link->Item[I_QUIVER4]) && NumLWeaponsOf(LW_ARROW) == 0)
		{
			if (!Link->Item[I_QUIVER4])
			{
				Game->Counter[CR_ARROWS]--;
			}
			Game->PlaySound(SFX_ARROW);
			lweapon arrow = NextToLink(LW_ARROW, 0);
			arrow->UseSprite(arrow_sprite);
			arrow->Damage = arrow_damage;
			arrow->Step = arrow_step;
			// Multiply damage by 2 and step by 2 if bow was fully charged before releasing.
			if (fully_charged)
			{
				arrow->Damage *= 2;
				arrow->Step *= 2;
			}
			arrow->Dir = Link->Dir;
			LWeaponFlip(arrow, arrow->Dir);
			
			//Arrow hitbox shenanigans. Modeled after ZC arrow defaults.
			if (arrow->Dir == DIR_UP || arrow->Dir == DIR_DOWN)
			{
				arrow->HitWidth = 15;
				arrow->HitHeight = 12;
				arrow->HitXOffset = 0;
				arrow->HitYOffset = 2;
				arrow->DrawXOffset = 0;
				arrow->DrawYOffset = -2;
			}
			else
			{
				arrow->HitWidth = 12;
				arrow->HitHeight = 14;
				arrow->HitXOffset = 2;
				arrow->HitYOffset = 2;
				arrow->DrawXOffset = 0;
				arrow->DrawYOffset = 1;
			}
			// Creates sparkles around arrow while it's onscreen, if sprite for them is set.
			for (int i = 0; NumLWeaponsOf(LW_ARROW) > 0 && sparkle_sprite; i = (i + 1) % 4)
			{
				if (i == 0)
				{
					arrow = LoadLWeaponOf(LW_ARROW);
					SetSparkle(arrow, sparkle_sprite);
				}
				
				Waitframe();
			}
		}
		else
		{
			if (Game->Counter[CR_ARROWS] == 0 && !Link->Item[I_QUIVER4] && SFX_ERROR)
			{
				Game->PlaySound(SFX_ERROR); // Plays the error sound, if there is one, when Link is out of arrows.
			}
			Quit();
		}
	}
}

// This function flips the arrow sprite in the proper way based on direction.
void LWeaponFlip(lweapon lwpn, int dir)
{
	int flip;
	
	if (dir == DIR_UP)
	{
		flip = 0;
	}
	else if (dir == DIR_DOWN)
	{
		flip = 3;
	}
	else if (dir == DIR_LEFT)
	{
		flip = 7;
	}
	else if (dir == DIR_RIGHT)
	{
		flip = 4;
	}
	else if (dir == DIR_LEFTUP)
	{
		flip = 0;
	}
	else if (dir == DIR_RIGHTUP)
	{
		flip = 0;
	}
	else if (dir == DIR_LEFTDOWN)
	{
		flip = 3;
	}
	else if (dir == DIR_RIGHTDOWN)
	{
		flip = 3;
	}
	
	lwpn->Flip = flip;
}

// This function generates sparkles for flying arrows.
//
// UP
// Sparkles oscillate between 0 to 3 pixels greater than arrow X. 4 to 7 pixels greater than arrow Y. OffsetY is -2.
//
// DOWN
// Sparkles oscillate between 0 to 3 pixels greater than arrow X. 1 to 4 pixels less than arrow Y. OffsetY is -2.
//
// LEFT
// Sparkles oscillate between 4 to 7 pixels greater than arrow X. 0 to 3 pixels greater than arrow Y. OffsetY is -2.
//
// RIGHT
// Sparkles oscillate between 1 to 4 pixels less than arrow X. 0 to 3 pixels greater than arrow Y. OffsetY is -2.
//
void SetSparkle(lweapon arrow, int sparkle_sprite)
{
	lweapon sparkle = CreateLWeaponAt(LW_SPARKLE, arrow->X, arrow->Y);
	sparkle->UseSprite(sparkle_sprite);
	if (arrow->Dir == DIR_UP)
	{
		sparkle->X = arrow->X + Rand(0, 3);
		sparkle->Y = arrow->Y + Rand(4, 7);
	}
	if (arrow->Dir == DIR_DOWN)
	{
		sparkle->X = arrow->X + Rand(0, 3);
		sparkle->Y = arrow->Y - Rand(1, 4);
	}
	if (arrow->Dir == DIR_LEFT)
	{
		sparkle->X = arrow->X + Rand(4, 7);
		sparkle->Y = arrow->Y + Rand(0, 3);
	}
	if (arrow->Dir == DIR_RIGHT)
	{
		sparkle->X = arrow->X - Rand(1, 4);
		sparkle->Y = arrow->Y + Rand(0, 3);
	}
	sparkle->DrawYOffset = -2;
	sparkle->CollDetection = false;
}