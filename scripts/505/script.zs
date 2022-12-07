const int SPR_LEMNISCATTO_EWEAPON = -1;//Sprite used by Lemniscatto`s eweapons.
//Lemniscatto
//Moves in valious shapes around it`s starting position, infinily-like by default, Firing eweapons every now and then.

ffc script Lemniscatto{
	void run(int enemyID){
		npc ghost = Ghost_InitAutoGhost(this, enemyID);
		
		int HF = ghost->Homing;
		int HR = ghost->Haltrate;
		int RR = ghost->Rate;
		int HNG = ghost->Hunger;
		int SPD = ghost->Step;
		int WPND = ghost->WeaponDamage;		
				
		int rangex = Ghost_GetAttribute(ghost, 0, 60);//Maximum range at X coordinate
		int rangey = Ghost_GetAttribute(ghost, 1, 30);//Maximum range at Y coordinate
		int speedx = Ghost_GetAttribute(ghost, 2, 1);//Angular speed for X coordinate
		int speedy = Ghost_GetAttribute(ghost, 3, 2);//Angular speed for Y coordinate
		int initanglex = Ghost_GetAttribute(ghost, 4, 45);//Starting angle for X coordinate
		int initangley = Ghost_GetAttribute(ghost, 5, 45);//Starting angle for Y coordinate
		int sizex = Ghost_GetAttribute(ghost, 6, 1);//Tile Width
		int sizey = Ghost_GetAttribute(ghost, 7, 1);//Tile Height
		int shotspeed = Ghost_GetAttribute(ghost, 8, 60);//delay between shots, in frames. Enemy won`t fire , if Weapon Damage is 0.
		int ewsizex = Ghost_GetAttribute(ghost, 9, 1);//Eweapon size 
		
		ghost->Extend=3;
		Ghost_SetSize(this, ghost, sizex, sizey);
		if (sizex>2 && sizey>2)Ghost_SetHitOffsets(ghost, 8, 8, 8, 8);
		
		Ghost_SetFlag(GHF_IGNORE_ALL_TERRAIN);
		Ghost_SetFlag(GHF_NO_FALL);
		
		int origtile = ghost->OriginalTile;
		int haltcounter = -1;
		int origx = ghost->X;
		int origy = ghost->Y;
		int anglex = initanglex;
		int angley = initangley;
		int shotcounter=shotspeed;
		int WPNS = SPR_LEMNISCATTO_EWEAPON;
		if (SPR_LEMNISCATTO_EWEAPON==0)WPNS=-1;
		
		int defs[18];
		Ghost_StoreDefenses(ghost,defs);
		//Ghost_SetAllDefenses(ghost, NPCDT_BLOCK);
		//bool open = false;
		
		while(true){
			anglex+=speedx;
			angley+=speedy;
			if (anglex>=360) anglex=0;
			if (angley>=360) angley=0;
			Ghost_X = origx + rangex*Cos(anglex);
			Ghost_Y = origy + rangey*Cos(angley);
			shotcounter--;
			if (shotcounter==0 && WPND>0){
				eweapon e =  FireBigAimedEWeapon(ghost->Weapon, CenterX(ghost)+8-ewsizex*8, CenterY(ghost)+12-ewsizex*8, 0, 300, WPND, WPNS, -1, EWF_ROTATE,ewsizex,ewsizex);
				shotcounter=shotspeed;
			}
			if (!Ghost_Waitframe(this, ghost, false, false)){
				Ghost_DeathAnimation(this, ghost, GHD_SHRINK);
				Quit();
			}
		}
	}
}

const int SPR_LEMNISCATTO_ALT_EWEAPON = -1;//Sprite used by Lemniscatto`s eweapons.
const int LEMNISCATTO_ALT_FIRE_ASPEED = 4;//delay between eye opening and closing, in frames. Enemy won`t fire bombs, if Weapon Damage is 0.

//Lemniscatto Alt
//Moves in valious shapes around it`s starting position, infinily-like by default, Has eye that opens and closes. Shoots eweapons, when eye is open. Invincible, when eye is closed. Does not move when firing.

ffc script LemniscattoAlt{
	void run(int enemyID){
		npc ghost = Ghost_InitAutoGhost(this, enemyID);
		
		int HF = ghost->Homing;
		int HR = ghost->Haltrate;
		int RR = ghost->Rate;
		int HNG = ghost->Hunger;
		int SPD = ghost->Step;
		int WPND = ghost->WeaponDamage;		
		
		int rangex = Ghost_GetAttribute(ghost, 0, 60);//Maximum range at X coordinate
		int rangey = Ghost_GetAttribute(ghost, 1, 30);//Maximum range at Y coordinate
		int speedx = Ghost_GetAttribute(ghost, 2, 1);//Angular speed for X coordinate
		int speedy = Ghost_GetAttribute(ghost, 3, 2);//Angular speed for Y coordinate
		int initanglex = Ghost_GetAttribute(ghost, 4, 45);//Starting angle for X coordinate
		int initangley = Ghost_GetAttribute(ghost, 5, 45);//Starting angle for Y coordinate
		int sizex = Ghost_GetAttribute(ghost, 6, 1);//Tile Width
		int sizey = Ghost_GetAttribute(ghost, 7, 1);//Tile Height
		int shotspeed = Ghost_GetAttribute(ghost, 8, 60);//delay between eye opening/closing.
		int ewsizex = Ghost_GetAttribute(ghost, 9, 1);//Eweapon size 
		
		ghost->Extend=3;
		Ghost_SetSize(this, ghost, sizex, sizey);
		if (sizex>2 && sizey>2)Ghost_SetHitOffsets(ghost, 8, 8, 8, 8);
		
		Ghost_SetFlag(GHF_IGNORE_ALL_TERRAIN);
		Ghost_SetFlag(GHF_NO_FALL);
		
		int origtile = ghost->OriginalTile;
		int haltcounter = -1;
		int origx = ghost->X;
		int origy = ghost->Y;
		int anglex = initanglex;
		int angley = initangley;
		int shotcounter=shotspeed;
		int WPNS = SPR_LEMNISCATTO_ALT_EWEAPON;
		if (SPR_LEMNISCATTO_ALT_EWEAPON==0)WPNS=-1;
		
		int defs[18];
		Ghost_StoreDefenses(ghost,defs);
		Ghost_SetAllDefenses(ghost, NPCDT_BLOCK);
		bool open = false;
		
		while(true){
			if (!open)anglex+=speedx;
			if (!open)angley+=speedy;
			if (anglex>=360) anglex=0;
			if (angley>=360) angley=0;
			Ghost_X = origx + rangex*Cos(anglex);
			Ghost_Y = origy + rangey*Cos(angley);
			shotcounter--;
			if (shotcounter==0){
				//if (!open)eweapon e =  FireBigAimedEWeapon(EW_SBOMB, CenterX(ghost)+8-ewsizex*8, CenterY(ghost)+12-ewsizex*8, 0, 300, WPND, WPNS, -1, EWF_UNBLOCKABLE,ewsizex,ewsizex);
				shotcounter=shotspeed;
				if (open){
					ghost->OriginalTile=origtile;
					Ghost_SetAllDefenses(ghost, NPCDT_BLOCK);
					open=false;
				}
				else{
					open=true;
					ghost->OriginalTile=origtile+sizex;
					Ghost_SetDefenses(ghost, defs);
				}
			}
			if (open&&(shotcounter%LEMNISCATTO_ALT_FIRE_ASPEED)==0 && WPND>0)eweapon e =  FireBigAimedEWeapon(ghost->Weapon, CenterX(ghost)+8-ewsizex*8, CenterY(ghost)+12-ewsizex*8, 0, 300, WPND, WPNS, -1, EWF_ROTATE,ewsizex,ewsizex);
			if (!Ghost_Waitframe(this, ghost, false, false)){
				Ghost_DeathAnimation(this, ghost, GHD_SHRINK);
				Quit();
			}
		}
	}
}