import "std.zh"
import "string.zh"
import "ghost.zh"

ffc script MirrorDarknut
{
	void run(int enemyID)
	{
		npc ghost = Ghost_InitAutoGhost(this,enemyID);
		Ghost_SetFlag(GHF_NORMAL);
		int defenses[18];
		Ghost_StoreDefenses(ghost, defenses);
		ReflectWeapons(ghost);
		lweapon refweapon;

		while(Ghost_Waitframe2(this,ghost, true, true))
		{
			Ghost_SetDefenses(ghost,defenses);
			if(!GetNPCMiscFlag(ghost, 1<<9)) continue; //It's just a normal enemy without it's shield.
			ReflectWeapons(ghost);
			for(int i = Screen->NumLWeapons(); i > 0; i--)
			{
				lweapon wpn = Screen->LoadLWeapon(i);
				if(!Collision(ghost,wpn)) continue;
				if(!ghost->CollDetection) continue;
				if(!wpn->CollDetection) continue;
				if(wpn==refweapon) continue;
				if(wpn->ID != LW_MAGIC
				&& wpn->ID != LW_BEAM
				&& wpn->ID != LW_REFMAGIC
				&& wpn->ID != LW_REFBEAM) continue; 
				if(wpn->Dir != OppositeDir(ghost->Dir))
				{
					//Ghost_SetDefenses(ghost,defenses);
				}
				else
				{
					Game->PlaySound(SFX_CLINK);
					refweapon = ReflectLWeapon(wpn);
					wpn->DeadState = WDS_DEAD;
					wpn->X = -1000;
					break;
				}
			}
			for(int i = Screen->NumEWeapons(); i > 0; i--)
			{
				eweapon wpn = Screen->LoadEWeapon(i);
				if(!Collision(ghost,wpn)) continue;
				if(!ghost->CollDetection) continue;
				if(!wpn->CollDetection) continue;
				if(wpn->ID != EW_MAGIC
				&& wpn->ID != EW_BEAM) continue;
				if(wpn->Dir != OppositeDir(ghost->Dir))
				{
					//Ghost_SetDefenses(ghost,defenses);
				}
				else
				{
					Game->PlaySound(SFX_CLINK);
					refweapon = ReflectEWeapon(wpn);
					wpn->DeadState = WDS_DEAD;
					wpn->X = -1000;
					break;
				}
			}
		}
	}
	void ReflectWeapons(npc ghost)
	{
		ghost->Defense[NPCD_MAGIC] = NPCDT_IGNORE;
		ghost->Defense[NPCD_BEAM] = NPCDT_IGNORE;
		ghost->Defense[NPCD_REFMAGIC] = NPCDT_IGNORE;
		ghost->Defense[NPCD_REFBEAM] = NPCDT_IGNORE;
	}
	lweapon ReflectLWeapon(lweapon a)
	{
		int typeID;
		if(a->ID == LW_MAGIC||a->ID == LW_REFMAGIC) typeID = LW_REFMAGIC;
		else typeID = LW_REFBEAM;
		lweapon b = Screen->CreateLWeapon(typeID);
		b->X = a->X;
		b->Y = a->Y;
		b->Z = a->Z;
		b->Jump = a->Jump;
		b->Extend = a->Extend;
		b->TileWidth = a->TileWidth;
		b->TileHeight = a->TileHeight;
		b->HitWidth = a->HitWidth;
		b->HitHeight = a->HitHeight;
		b->HitZHeight = a->HitZHeight;
		b->HitXOffset = a->HitXOffset;
		b->HitYOffset = a->HitYOffset;
		b->DrawXOffset = a->DrawXOffset;
		b->DrawYOffset = a->DrawYOffset;
		b->DrawZOffset = a->DrawZOffset;
		b->Tile = a->Tile;
		b->CSet = a->CSet;
		b->DrawStyle = a->DrawStyle;
		b->Dir = OppositeDir(a->Dir);
		b->OriginalTile = a->OriginalTile;
		b->OriginalCSet = a->OriginalCSet;
		b->FlashCSet = a->FlashCSet;
		b->NumFrames = a->NumFrames;
		b->Frame = a->Frame;
		b->ASpeed = a->ASpeed;
		b->Damage = a->Damage;
		b->Step = a->Step;
		if(a->Angular)
		{
			int vecx = VectorX(a->Step, RadtoDeg(a->Angle));
			int vecy = VectorY(a->Step, RadtoDeg(a->Angle));
			if(Abs(vecx) >= Abs(vecy))
				vecx *= -1;
			if(Abs(vecx) <= Abs(vecy))
				vecy *= -1;
			b->Angle = ArcTan(vecx, vecy);
			b->Angular = true;
		}
		b->CollDetection = a->CollDetection;
 		b->DeadState = a->DeadState;
		b->Flash = a->Flash;
		b->Flip ^= 3;
		for (int i = 0; i < 16; i++)
			b->Misc[i] = a->Misc[i];
		return b;
	}
	lweapon ReflectEWeapon(eweapon a)
	{
		int typeID;
		if(a->ID == EW_MAGIC) typeID = LW_REFMAGIC;
		else typeID = LW_REFBEAM;
		lweapon b = Screen->CreateLWeapon(typeID);
		b->X = a->X;
		b->Y = a->Y;
		b->Z = a->Z;
		b->Jump = a->Jump;
		b->Extend = a->Extend;
		b->TileWidth = a->TileWidth;
		b->TileHeight = a->TileHeight;
		b->HitWidth = a->HitWidth;
		b->HitHeight = a->HitHeight;
		b->HitZHeight = a->HitZHeight;
		b->HitXOffset = a->HitXOffset;
		b->HitYOffset = a->HitYOffset;
		b->DrawXOffset = a->DrawXOffset;
		b->DrawYOffset = a->DrawYOffset;
		b->DrawZOffset = a->DrawZOffset;
		b->Tile = a->Tile;
		b->CSet = a->CSet;
		b->DrawStyle = a->DrawStyle;
		b->Dir = OppositeDir(a->Dir);
		b->OriginalTile = a->OriginalTile;
		b->OriginalCSet = a->OriginalCSet;
		b->FlashCSet = a->FlashCSet;
		b->NumFrames = a->NumFrames;
		b->Frame = a->Frame;
		b->ASpeed = a->ASpeed;
		b->Damage = a->Damage;
		b->Step = a->Step;
		if(a->Angular)
		{
			int vecx = VectorX(a->Step, RadtoDeg(a->Angle));
			int vecy = VectorY(a->Step, RadtoDeg(a->Angle));
			if(Abs(vecx) >= Abs(vecy))
				vecx *= -1;
			if(Abs(vecx) <= Abs(vecy))
				vecy *= -1;
			b->Angle = ArcTan(vecx, vecy);
			b->Angular = true;
		}
		b->CollDetection = a->CollDetection;
 		b->DeadState = a->DeadState;
		b->Flash = a->Flash;
		b->Flip ^= 3;
		for (int i = 0; i < 16; i++)
			b->Misc[i] = a->Misc[i];
		return b;
	}
}