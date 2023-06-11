const int SFX_ARMADILLO_BOSS_BOUNCE = 3; //Sound to play, when armadillo bounces off solid combos in ball form.

//Armadillo/King

//Walks around, fires eweapons from his twin hands, then rolls into invincible ball form, bouncing off walls .
//Set up 2 rows of tiles for body animation, walking then directly below it for rolling.
//Set up 3 consecutive damage combos for hands (walking state).

ffc script ArmadilloKing{
	void run(int enemyID){
		npc ghost = Ghost_InitAutoGhost(this, enemyID);
		
		int HF = ghost->Homing;
		int HR = ghost->Haltrate;
		int RR = ghost->Rate;
		int HNG = ghost->Hunger;
		int SPD = ghost->Step;
		int WPND = ghost->WeaponDamage;
		
		int walkduration = Ghost_GetAttribute(ghost, 0, 300);//Walking duration
		int shotdelay = Ghost_GetAttribute(ghost, 1, 90);//Delay between shooting eweapons
		int numbounces = Ghost_GetAttribute(ghost, 2, 20);//Number of bounces in ball form before returning to normal state.
		int rolldamage = Ghost_GetAttribute(ghost, 3, ghost->Damage+2);//Damage caused by trampling Link in ball form, in 1/4ths of heart
		int rollspeed = Ghost_GetAttribute(ghost, 4, 300);//Rolling speed in ball form.
		int ewspeed = Ghost_GetAttribute(ghost, 5, 300);//Eweapon firing speed
		int ewsprite = Ghost_GetAttribute(ghost, 6, -4);//Eweapon sprite
		int handcombo = Ghost_GetAttribute(ghost, 7, -1);//ID of combo used by hands
		int sizex = Ghost_GetAttribute(ghost, 8, 2);//Tile Width
		int sizey = Ghost_GetAttribute(ghost, 9, 2);//Tile Height
		
		ghost->Extend=3;
		Ghost_SetSize(this, ghost, sizex, sizey);
		if (sizex>2 || sizey>2)Ghost_SetHitOffsets(ghost, 8, 8, 8, 8);
		
		Ghost_SetFlag(GHF_NORMAL);
		Ghost_UnsetFlag(GHF_KNOCKBACK);
		Ghost_SetFlag(GHF_NO_FALL);
		
		int OrigTile = ghost->OriginalTile;
		int State = 0;
		int statecounter = walkduration;
		int haltcounter = -1;
		int shootcounter = shotdelay;
		int origdam = ghost->Damage;
		
		int defs[18];
		Ghost_StoreDefenses(ghost,defs);
		eweapon e ;
		if (WPND>0 && handcombo>0){
			Ghost_AddCombo(handcombo, -16, (Ghost_TileHeight-1)*8);
			Ghost_AddCombo(handcombo+1, Ghost_TileWidth*16, (Ghost_TileHeight-1)*8);
		}
		
		// Get initial movement
		int angle=0;
		float rollstep=rollspeed/100;
		float xStep=rollspeed*Cos(angle);
		float yStep=rollspeed*Sin(angle);
		
		while(true){
			if (State==0){
				haltcounter = Ghost_ConstantWalk4(haltcounter, SPD, RR, HF, HNG);
				shootcounter--;
				if (shootcounter<=0 && WPND>0){
					if (handcombo>0){
						e=FireAimedEWeapon(ghost->Weapon, Ghost_X-16, Ghost_Y+(Ghost_TileHeight-1)*8, 0, 200, WPND, ewsprite, -1, EWF_ROTATE);
						e=FireAimedEWeapon(ghost->Weapon, Ghost_X+Ghost_TileWidth*16, Ghost_Y+(Ghost_TileHeight-1)*8, 0, 200, WPND, ewsprite, -1, EWF_ROTATE);
					}
					else{
						e=FireAimedEWeapon(ghost->Weapon, CenterX(ghost), CenterY(ghost), 0, 200, WPND, ewsprite, -1, EWF_ROTATE);
					}
					shootcounter = shotdelay;
				}
				statecounter--;
				if (statecounter<=0){
					Ghost_ClearCombos();
					statecounter = numbounces;
					ghost->Damage =  rolldamage;
					Ghost_SetAllDefenses(ghost, NPCDT_BLOCK);
					angle = Angle(CenterX(ghost),CenterY(ghost), CenterLinkX(), CenterLinkY());
					xStep=rollspeed*Cos(angle)/100;
					yStep=rollspeed*Sin(angle)/100;
					State=1;
				}
			}
			else if (State==1){
				if(xStep<0)	{
					if(!Ghost_CanMove(DIR_LEFT, -xStep, 3)){
						if (sizex>1 || sizey>1)Game->PlaySound(SFX_ARMADILLO_BOSS_BOUNCE);
						statecounter--;
						xStep*=-1;
					}
				}
				else{
					if(!Ghost_CanMove(DIR_RIGHT, xStep, 3)){
						if (sizex>1 || sizey>1)Game->PlaySound(SFX_ARMADILLO_BOSS_BOUNCE);
						statecounter--;
						xStep*=-1;
					}
				}
				
				if(yStep<0)	{
					if(!Ghost_CanMove(DIR_UP, -yStep, 3)){
						if (sizex>1 || sizey>1)Game->PlaySound(SFX_ARMADILLO_BOSS_BOUNCE);
						statecounter--;
						yStep*=-1;
					}
				}
				else{
					if(!Ghost_CanMove(DIR_DOWN, yStep, 3)){
						if (sizex>1 || sizey>1)Game->PlaySound(SFX_ARMADILLO_BOSS_BOUNCE);
						statecounter--;
						yStep*=-1;
					}
				}
				if (statecounter>0){
					Ghost_MoveXY(xStep, yStep,2);
				}
				else{
					if (WPND>0 && handcombo>0){
						Ghost_AddCombo(handcombo, -16, (Ghost_TileHeight-1)*8);
						Ghost_AddCombo(handcombo+1, Ghost_TileWidth*16, (Ghost_TileHeight-1)*8);
					}
					statecounter = walkduration;
					ghost->Damage =  origdam;
					Ghost_SetDefenses(ghost, defs);
					State=0;
				}
			}
			ArmadilloAnimation(ghost, OrigTile, State, 2);
			if (!Ghost_Waitframe(this, ghost, false, false)){
				Ghost_ClearCombos();
				lweapon e;
				e=Screen->CreateLWeapon(LW_SPARKLE);
				e->X= Ghost_X-16;
				e->Y=Ghost_Y+(Ghost_TileHeight-1)*8;
				e->UseSprite(23);
				e->CollDetection=false;
				e=Screen->CreateLWeapon(LW_SPARKLE);
				e->X=Ghost_X+Ghost_TileWidth*16;
				e->Y=Ghost_Y+(Ghost_TileHeight-1)*8;
				e->UseSprite(23);
				e->CollDetection=false;
				Ghost_DeathAnimation(this, ghost, GHD_EXPLODE);
				Quit();
			}
		}
	}
}

//Armadillo/King, Coward variant

//Walks around, fires eweapons from his twin hands.  When hit, rolls into invincible ball form, bouncing off walls.
//Set up 2 rows of tiles for body animation, walking then directly below it for rolling.
//Set up 3 consecutive damage combos for hands (walking state).

ffc script ArmadilloCorward{
	void run(int enemyID){
		npc ghost = Ghost_InitAutoGhost(this, enemyID);
		
		int HF = ghost->Homing;
		int HR = ghost->Haltrate;
		int RR = ghost->Rate;
		int HNG = ghost->Hunger;
		int SPD = ghost->Step;
		int WPND = ghost->WeaponDamage;
		
		int walkduration = Ghost_GetAttribute(ghost, 0, 300);//unused
		int shotdelay = Ghost_GetAttribute(ghost, 1, 90);//Delay between shooting eweapons
		int numbounces = Ghost_GetAttribute(ghost, 2, 20);//Number of bounces in ball form before returning to normal state.
		int rolldamage = Ghost_GetAttribute(ghost, 3, ghost->Damage+2);//Damage caused by trampling Link in ball form, in 1/4ths of heart
		int rollspeed = Ghost_GetAttribute(ghost, 4, 300);//Rolling speed in ball form.
		int ewspeed = Ghost_GetAttribute(ghost, 5, 300);//Eweapon firing speed
		int ewsprite = Ghost_GetAttribute(ghost, 6, -4);//Eweapon sprite
		int handcombo = Ghost_GetAttribute(ghost, 7, -1);//ID of combo used by hands
		int sizex = Ghost_GetAttribute(ghost, 8, 2);//Tile Width
		int sizey = Ghost_GetAttribute(ghost, 9, 2);//Tile Height
		
		ghost->Extend=3;
		Ghost_SetSize(this, ghost, sizex, sizey);
		if (sizex>2 || sizey>2)Ghost_SetHitOffsets(ghost, 8, 8, 8, 8);
		
		Ghost_SetFlag(GHF_NORMAL);
		Ghost_UnsetFlag(GHF_KNOCKBACK);
		Ghost_SetFlag(GHF_NO_FALL);
		
		int OrigTile = ghost->OriginalTile;
		int State = 0;
		int statecounter = walkduration;
		int haltcounter = -1;
		int shootcounter = shotdelay;
		int origdam = ghost->Damage;
		
		int defs[18];
		Ghost_StoreDefenses(ghost,defs);
		eweapon e ;
		if (WPND>0 && handcombo>0){
			Ghost_AddCombo(handcombo, -16, (Ghost_TileHeight-1)*8);
			Ghost_AddCombo(handcombo+1, Ghost_TileWidth*16, (Ghost_TileHeight-1)*8);
		}
		
		// Get initial movement
		int angle=0;
		float rollstep=rollspeed/100;
		float xStep=rollspeed*Cos(angle);
		float yStep=rollspeed*Sin(angle);
		
		while(true){
			if (State==0){
				haltcounter = Ghost_ConstantWalk4(haltcounter, SPD, RR, HF, HNG);
				shootcounter--;
				if (shootcounter<=0 && WPND>0){
					if (handcombo>0){
						e=FireAimedEWeapon(ghost->Weapon, Ghost_X-16, Ghost_Y+(Ghost_TileHeight-1)*8, 0, 200, WPND, ewsprite, -1, EWF_ROTATE);
						e=FireAimedEWeapon(ghost->Weapon, Ghost_X+Ghost_TileWidth*16, Ghost_Y+(Ghost_TileHeight-1)*8, 0, 200, WPND, ewsprite, -1, EWF_ROTATE);
					}
					else{
						e=FireAimedEWeapon(ghost->Weapon, CenterX(ghost), CenterY(ghost), 0, 200, WPND, ewsprite, -1, EWF_ROTATE);
					}
					shootcounter = shotdelay;
				}
				// statecounter--;
				if (Ghost_GotHit()){
					Ghost_ClearCombos();
					statecounter = numbounces;
					ghost->Damage =  rolldamage;
					Ghost_SetAllDefenses(ghost, NPCDT_BLOCK);
					angle = Angle(CenterX(ghost),CenterY(ghost), CenterLinkX(), CenterLinkY())+ 180;
					xStep=rollspeed*Cos(angle)/100;
					yStep=rollspeed*Sin(angle)/100;
					State=1;
				}
			}
			else if (State==1){
				if(xStep<0)	{
					if(!Ghost_CanMove(DIR_LEFT, -xStep, 3)){
						if (sizex>1 || sizey>1)Game->PlaySound(SFX_ARMADILLO_BOSS_BOUNCE);
						statecounter--;
						xStep*=-1;
					}
				}
				else{
					if(!Ghost_CanMove(DIR_RIGHT, xStep, 3)){
						if (sizex>1 || sizey>1)Game->PlaySound(SFX_ARMADILLO_BOSS_BOUNCE);
						statecounter--;
						xStep*=-1;
					}
				}
				
				if(yStep<0)	{
					if(!Ghost_CanMove(DIR_UP, -yStep, 3)){
						if (sizex>1 || sizey>1)Game->PlaySound(SFX_ARMADILLO_BOSS_BOUNCE);
						statecounter--;
						yStep*=-1;
					}
				}
				else{
					if(!Ghost_CanMove(DIR_DOWN, yStep, 3)){
						if (sizex>1 || sizey>1)Game->PlaySound(SFX_ARMADILLO_BOSS_BOUNCE);
						statecounter--;
						yStep*=-1;
					}
				}
				if (statecounter>0){
					Ghost_MoveXY(xStep, yStep,2);
				}
				else{
					if (WPND>0 && handcombo>0){
						Ghost_AddCombo(handcombo, -16, (Ghost_TileHeight-1)*8);
						Ghost_AddCombo(handcombo+1, Ghost_TileWidth*16, (Ghost_TileHeight-1)*8);
					}
					statecounter = walkduration;
					ghost->Damage =  origdam;
					Ghost_SetDefenses(ghost, defs);
					State=0;
				}
			}
			ArmadilloAnimation(ghost, OrigTile, State, 2);
			if (!Ghost_Waitframe(this, ghost, false, false)){
				Ghost_ClearCombos();
				lweapon e;
				e=Screen->CreateLWeapon(LW_SPARKLE);
				e->X= Ghost_X-16;
				e->Y=Ghost_Y+(Ghost_TileHeight-1)*8;
				e->UseSprite(23);
				e->CollDetection=false;
				e=Screen->CreateLWeapon(LW_SPARKLE);
				e->X=Ghost_X+Ghost_TileWidth*16;
				e->Y=Ghost_Y+(Ghost_TileHeight-1)*8;
				e->UseSprite(23);
				e->CollDetection=false;
				Ghost_DeathAnimation(this, ghost, GHD_EXPLODE);
				Quit();
			}
		}
	}
}

void ArmadilloAnimation(npc ghost, int origtile, int state, int numframes){
	int offset = 0;
	if (state==1)offset = ghost->TileHeight*20;
	ghost->OriginalTile = origtile + offset;
}