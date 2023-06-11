const int SFX_TRAFFICCONE_BLOCK = 16; //Sound to play, when traffic cone enters blocking state.

//Poltergeist Traffic Cone

//Moves in 4 directions. If Link is close, it stops and becomes invincible and solid, blocking path. Speed boosts when low HP.
//Best used in cramped areas.
//Animation - 2 rows. 1 for moving and 1 directly below it for blocking. 
//Requires SolidFFC.zh and all his dependencies. 

ffc script TrafficCone{
	void run(int enemyID){
		npc ghost = Ghost_InitAutoGhost(this, enemyID);
		
		int HF = ghost->Homing;
		int HR = ghost->Haltrate;
		int RR = ghost->Rate;
		int HNG = ghost->Hunger;
		int SPD = ghost->Step;
		int WPND = ghost->WeaponDamage;
		
		int proximity = Ghost_GetAttribute(ghost, 0, 32);//Proximity Distance
		int berserkHP = Ghost_GetAttribute(ghost, 1, 0);//Berserk HP threshold
		int sizex = Ghost_GetAttribute(ghost, 2, 1);//Tile Width
		int sizey = Ghost_GetAttribute(ghost, 3, 1);//Tile Height
		int berserkspeedmodifier = Ghost_GetAttribute(ghost, 4, 50);//Speed modifier for berserk mode
		
		ghost->Extend=3;
		Ghost_SetSize(this, ghost, sizex, sizey);
		if (ghost->Damage>0){
			Ghost_SetHitOffsets(ghost, 0, 0, 0, 0);
			ghost->HitYOffset=-4;
			ghost->HitXOffset=-3;
			ghost->HitWidth = ghost->TileWidth*16+6;			
		}
		else Ghost_SetHitOffsets(ghost, 2, 5, 2, 2);
		
		Ghost_SetFlag(GHF_NORMAL);
		
		int OrigTile = ghost->OriginalTile;
		int State = 0;
		int haltcounter = -1;
		bool berserk = false;
		
		int defs[18];
		Ghost_StoreDefenses(ghost,defs);
		
		while(true){
			if (State==0){
				haltcounter = Ghost_ConstantWalk4(haltcounter, SPD, RR, HF, HNG);
				if (Distance(CenterX(ghost), CenterY(ghost), CenterLinkX(),CenterLinkY())<=proximity){
					Game->PlaySound(SFX_TRAFFICCONE_BLOCK);
					Ghost_SetAllDefenses(ghost, NPCDT_BLOCK);
					State=1;
				}
			}
			if (State==1){
				SolidObjects_Add(FFCNum(this), ghost->X+2, ghost->Y+2, Ghost_TileWidth*16-4, Ghost_TileHeight*16-3, 0, 0, 0);
				if (Distance(CenterX(ghost), CenterY(ghost), CenterLinkX(),CenterLinkY())>proximity){
					Ghost_SetDefenses(ghost, defs);
					State=0;
				}
			}
			if (!berserk && Ghost_HP<=berserkHP){
				berserk=true;
				Game->PlaySound(SFX_SUMMON);
				SPD+=berserkspeedmodifier;
			}
			TCAnimation(ghost, OrigTile, State, 2);
			Ghost_Waitframe(this, ghost);
		}		
	}
}	

void TCAnimation(npc ghost, int origtile, int State, int numframes){
	int offset = 20 * ghost->TileHeight;
	if (State==0) offset=0;
	ghost->OriginalTile = origtile + offset;
}