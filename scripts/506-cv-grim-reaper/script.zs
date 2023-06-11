//CV 1/3 GrimReaper boss. Flies around, like wall bouncer, sometimes summons enemies.

ffc script WallBouncer{
	void run(int enemyID){
		npc ghost = Ghost_InitAutoGhost(this, enemyID);
		int HF = ghost->Homing;
		int HR = ghost->Haltrate;
		int RR = ghost->Rate;
		int HNG = ghost->Hunger;
		int SPD = ghost->Step;
		int WPND = ghost->WeaponDamage;		
		int WPNS = SPR_ORBITER_EWEAPON;
		
		// Initialize
		ghost->Extend=3;
		Ghost_SetFlag(GHF_NO_FALL);
		//Ghost_SetFlag(GHF_NORMAL);
		int ReaperTileWidth = Ghost_GetAttribute(ghost, 0, 2);//Tile Width & Tile Height
		int ReaperTileHeight =Ghost_GetAttribute(ghost, 1, 3);
		int summonID = Ghost_GetAttribute(ghost, 2, 137);//ID of enemies to summon
		int numen = Ghost_GetAttribute(ghost, 3, 4);//Number of enemies to summon per cast.
		int grav = Ghost_GetAttribute(ghost, 4, 0);//Gravitative movement. for sideview areas.
		int maxsummons = Ghost_GetAttribute(ghost, 5, 4);//Maximum number of summoned enemies on screen.
		
		Ghost_SetSize(this, ghost, ReaperTileWidth, ReaperTileHeight);
		if (ghost->TileWidth>2 || ghost->TileHeight>2)Ghost_SetHitOffsets(ghost, 8, 8, 8, 8);
		Ghost_SpawnAnimationPuff(this, ghost);
		int OrigTile = ghost->OriginalTile;
		int state = 0;
		int statecounter=120;
		
		// Get initial movement
		int angle=45+90*Rand(4);
		float step=ghost->Step/100;
		ghost->Step=0; // In case it's a walker
		ghost->CollDetection=false;
		float xStep=step*Cos(angle);
		float yStep=step*Sin(angle);
		
		while(true)	{
			if (state==0){
				if (IsOdd(statecounter))ghost->DrawXOffset=1000;
				else ghost->DrawXOffset=0;
				statecounter--;
				if (statecounter==0){
					state=1;
					ghost->CollDetection=true;
					ghost->DrawXOffset=0;
				}
			}
			if (state==1){
				// Bounce
				if (grav>0)yStep += 0.04;
				if (yStep>16)yStep=1.6;
				if(xStep<0)	{
					if(!Ghost_CanMove(DIR_LEFT, -xStep, 3))
					xStep*=-1;
				}
				else{
					if(!Ghost_CanMove(DIR_RIGHT, xStep, 3))
					xStep*=-1;
				}
				
				if(yStep<0)	{
					if(!Ghost_CanMove(DIR_UP, -yStep, 3))
					yStep*=-1;
				}
				else{
					if(!Ghost_CanMove(DIR_DOWN, yStep, 3)){
						yStep*=-1;
						if (NumNPCsOf(summonID)<maxsummons){
							SpawnNPC(summonID);
							Game->PlaySound(SFX_SUMMON);
						}
					}
				}
				
				// And move
				Ghost_MoveXY(xStep, yStep,2);
				//WBAnimation(ghost, OrigTile);
				// debugValue(1, Ghost_Vy, 4);
				
			}
			if (!Ghost_Waitframe(this, ghost, false, false)){
				Ghost_DeathAnimation(this, ghost, GHD_SHRINK);
				Quit();
			}
		}
	}
}

void SummonNPC(npc ghost, int numnpc, int npcid, int sfx){
	Game->PlaySound(sfx);
	for (int i=1; i<=numnpc; i++){
		npc n = SpawnNPC(npcid);
		//n->X = ghost->X;
		//n->Y = ghost->Y; 
	}
}

void WBAnimation(npc ghost, int origtile){
	int offset = 0;
	if (CenterLinkX()>(CenterX(ghost))) offset = ghost->TileWidth;
	ghost->OriginalTile = origtile + offset;
}

//Large skull, the second form of CV3 Grim Reaper boss. Flies around in swirly pattern, wrapping around screen edges. Spawns one enemy from mouth oftentimes.
ffc script CV3Skull{
	void run(int enemyID){
		npc ghost = Ghost_InitAutoGhost(this, enemyID);
		int HF = ghost->Homing;
		int HR = ghost->Haltrate;
		int RR = ghost->Rate;
		int HNG = ghost->Hunger;
		int SPD = ghost->Step;
		int WPND = ghost->WeaponDamage;		
		int WPNS = SPR_ORBITER_EWEAPON;
		// Initialize
		ghost->Extend=3;
		Ghost_SetFlag(GHF_NO_FALL);
		Ghost_SetFlag(GHF_MOVE_OFFSCREEN);
		//Ghost_SetFlag(GHF_NORMAL);
		int SkullTileWidth = Ghost_GetAttribute(ghost, 0, 4);//Tile Width & Tile Height
		int SkullTileHeight =Ghost_GetAttribute(ghost, 1, 4);
		int summonID = Ghost_GetAttribute(ghost, 2, 137);//ID of enemies to summon
		int numen = Ghost_GetAttribute(ghost, 3, 4);//Number of enemies to summon per cast.
		int ang = Ghost_GetAttribute(ghost, 4, 90);//Initial swirling angle.
		int angspeed = Ghost_GetAttribute(ghost, 5, SPD/50);//Swirling speed. Negatinve for reverse direction.
		int offset = Ghost_GetAttribute(ghost, 6, 32);//Swirling radius.
		int shotspeed = Ghost_GetAttribute(ghost, 7, 300);//Delay between summining, in frames.
		
		int origX = ghost->X;
		int origY = ghost->Y;
		int shotcounter=shotspeed;
		Ghost_SetSize(this, ghost, SkullTileWidth, SkullTileHeight);
		if (ghost->TileWidth>2 || ghost->TileHeight>2)Ghost_SetHitOffsets(ghost, 8, 8, 8, 8);
		Ghost_SpawnAnimationPuff(this, ghost);
		int OrigTile = ghost->OriginalTile;
		int state = 0;
		int statecounter=120;
		ghost->CollDetection=false;
		npc n[4];
		while(true)	{
			if (state==0){
				if (IsOdd(statecounter))ghost->DrawXOffset=1000;
				else ghost->DrawXOffset=0;
				statecounter--;
				if (statecounter==0){
					Screen->Rectangle(6, 0, 0, 256, 172, 0x81, 1, 0, 0, 0, true, 64);//Replace 0x81 with ID of color to colorize boss intro flash
					state=1;
					ghost->CollDetection=true;
					ghost->DrawXOffset=0;
				}
			}
			if (state==1){
				origX-=SPD/100;
				if (origX<Ghost_TileWidth*-16) origX+=256;
				ang += angspeed;
				Ghost_X = origX + offset*Cos(ang);
				Ghost_Y = origY + offset*Sin(ang);
				Ghost_WrapAround(this, ghost, origX + offset*Cos(ang), origY + offset*Sin(ang));
				shotcounter--;
				if (shotcounter==0 && summonID>0){
					Game->PlaySound(SFX_SUMMON);
					
					for (int i=0;i<numen;i++){
						n[i] = SpawnNPC(summonID);
						if (numen==1){
							//n->X = CenterX(ghost)-8;
							//n->Y = CenterY(ghost);
						}
					}					
					shotcounter=shotspeed;
				}
			}
			if (!Ghost_Waitframe(this, ghost, false, false)){
				Ghost_DeathAnimation(this, ghost, GHD_EXPLODE);
				Quit();
			}
		}
	}
}

void Ghost_WrapAround(ffc this, npc ghost, int x, int y){
	Ghost_SetFlag(GHF_MOVE_OFFSCREEN);
	if (x<0)Screen->DrawTile(2, x +256, y, ghost->Tile,ghost->TileWidth , ghost->TileHeight, ghost->CSet, -1, -1,0, 0, 0,0,true,128);
	if (x>256 - ghost->TileWidth*16)Screen->DrawTile(2, x-256, y, ghost->Tile,ghost->TileWidth , ghost->TileHeight, ghost->CSet, -1, -1,0, 0, 0,0,true,128);
	if (y<0)Screen->DrawTile(2, x, y+176, ghost->Tile,ghost->TileWidth , ghost->TileHeight, ghost->CSet, -1, -1,0, 0, 0,0,true,128);
	if (y>176 - ghost->TileHeight*16)Screen->DrawTile(2, x, y-176, ghost->Tile,ghost->TileWidth , ghost->TileHeight, ghost->CSet, -1, -1,0, 0, 0,0,true,128);
}

//Sickle. Usually summoned by Grim Reaper. Moves torwards Link, then stops, then after wait re-aims at Link, rinse and repeat until re-aim limit expires, afterwards just flies off screen. Uses 2*2 frame animation.
ffc script Sickle{
	void run(int enemyID){
		npc ghost = Ghost_InitAutoGhost(this, enemyID);
		int HF = ghost->Homing;
		int HR = ghost->Haltrate;
		int RR = ghost->Rate;
		int HNG = ghost->Hunger;
		int SPD = ghost->Step;
		int WPND = ghost->WeaponDamage;		
		int WPNS = SPR_ORBITER_EWEAPON;
		// Initialize
		ghost->Extend=3;
		Ghost_SetFlag(GHF_NO_FALL);
		Ghost_SetFlag(GHF_NORMAL);
		Ghost_SetFlag(GHF_IGNORE_ALL_TERRAIN);
		Ghost_SetFlag(GHF_MOVE_OFFSCREEN);
		int SkullTileWidth = Ghost_GetAttribute(ghost, 0, 1);//Tile Width & Tile Height
		int SkullTileHeight =Ghost_GetAttribute(ghost, 1, 1);
		int waitdelay = Ghost_GetAttribute(ghost, 2, 60);//Waiting duration, in frames
		int attacktime = Ghost_GetAttribute(ghost, 3, 45);//Movement duratiion, in frames.
		int numturns = Ghost_GetAttribute(ghost, 4, 1);//Re-aim count limit.
		
		Ghost_SetSize(this, ghost, SkullTileWidth, SkullTileHeight);
		if (ghost->TileWidth>2 || ghost->TileHeight>2)Ghost_SetHitOffsets(ghost, 8, 8, 8, 8);
		
		Ghost_SpawnAnimationPuff(this, ghost);
		int origtile = ghost->OriginalTile;
		
		int state = 0;
		int statetimer = waitdelay;
		int ang = 0;
		
		while(true)	{
			if (state==0){
				statetimer--;
				if (statetimer==0){
					ang = Angle(Ghost_X, Ghost_Y, Link->X, Link->Y);
					state=1;
					statetimer=attacktime;
				}
			}
			if (state==1){
				Ghost_MoveAtAngle(ang, SPD/100, 0);
				if (numturns>0)statetimer--;
				if (statetimer==0){
					numturns--;
					state=0;
					statetimer=waitdelay;
				}
			}
			int offset = 0;
			if (state==0) offset = ghost->TileHeight*20;
			ghost->OriginalTile = origtile + offset;
			Ghost_Waitframe(this, ghost);
		}
	}
}