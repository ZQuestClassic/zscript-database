// uncomment this line (remove the //) if you haven't already imported std.zh in your script file
//import "std.zh"

int BetterByrna[8];
const int BETTERBYRNA_COST = 0;
const int BETTERBYRNA_MP_TRACKER = 1;
const int BETTERBYRNA_INVINCIBLE = 2;
const int BETTERBYRNA_BLOCK_PROJECTILES = 3;

global script BetterByrnaSampleGlobal
{
	void run()
	{
		while (true)
		{
			BetterByrna();
			Waitdraw();
			Waitframe();
		}
	}
}

void BetterByrna()
{
	if (NumLWeaponsOf(LW_CANEOFBYRNA) > 0)
	{
		// make player invincible
		if (Link->CollDetection && BetterByrna[BETTERBYRNA_INVINCIBLE])
		{
			Link->CollDetection = false;
		}
		
		// deduct MP cost
		if (BetterByrna[BETTERBYRNA_MP_TRACKER] >= 1)
		{
			if (Link->MP - Floor(BetterByrna[BETTERBYRNA_MP_TRACKER]) >= 0)
			{
				Link->MP -= Floor(BetterByrna[BETTERBYRNA_MP_TRACKER]);
			}
			else
			{
				Link->MP = 0;
			}
			BetterByrna[BETTERBYRNA_MP_TRACKER] -= Floor(BetterByrna[BETTERBYRNA_MP_TRACKER]);
		}
		if (Link->MP == 0)
		{
			lweapon byrna = LoadLWeaponOf(LW_CANEOFBYRNA);
			Remove(byrna);
		}
		else
		{
			BetterByrna[BETTERBYRNA_MP_TRACKER] += BetterByrna[BETTERBYRNA_COST] * (Game->Generic[GEN_MAGICDRAINRATE] * 0.5);
		}
		
		// block projectiles
		if (BetterByrna[BETTERBYRNA_BLOCK_PROJECTILES])
		{
			for (int i = Screen->NumEWeapons(); i > 0; i--)
			{
				eweapon projectile = Screen->LoadEWeapon(i);
				if (projectile->ID != EW_BOMBBLAST && projectile->ID != EW_SBOMBBLAST)
				{
					for (int j = Screen->NumLWeapons(); j > 0; j--)
					{
						lweapon byrna = Screen->LoadLWeapon(j);
						if (byrna->ID == LW_CANEOFBYRNA && Collision(projectile, byrna))
						{
							Remove(projectile);
						}
					}
				}
			}
		}
	}
	// make player vulnerable again
	else if (!Link->CollDetection)
	{
		Link->CollDetection = true;
	}
	
	if (Link->MP == 0 && (Link->InputA || Link->InputB))
	{
		itemdata a_button = Game->LoadItemData(GetEquipmentA());
		itemdata b_button = Game->LoadItemData(GetEquipmentB());
		if (Link->InputA && a_button->Family == IC_CBYRNA)
		{
			Link->InputA = false;
			Link->PressA = false;
		}
		if (Link->InputB && b_button->Family == IC_CBYRNA)
		{
			Link->InputB = false;
			Link->PressB = false;
		}
	}
}

// D0: reserved for other things, like pickup message scripts
// D1: MP cost per frame
// D2: 1 for invincible while cane is in use
// D3: 1 to block enemy projectiles
item script BetterByrnaItem
{
	void run(int foo, int cost, int invincible, int block_projectiles)
	{
		BetterByrna[BETTERBYRNA_COST] = cost;
		BetterByrna[BETTERBYRNA_INVINCIBLE] = invincible;
		BetterByrna[BETTERBYRNA_BLOCK_PROJECTILES] = block_projectiles;
	}
}