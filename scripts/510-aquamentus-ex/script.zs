//FFAquamentus

//Moves like normal enemy, or in circle, faces specific direction, Fires triple fireballs. At low HP speed increases and he fires rays of fire at random positions.
//Uses 2 rows of animation
ffc script FFAquamentus{
	void run(int enemyID){
		npc ghost = Ghost_InitAutoGhost(this, enemyID);
		
		int HF = ghost->Homing;
		int HR = ghost->Haltrate;
		int RR = ghost->Rate;
		int HNG = ghost->Hunger;
		int SPD = ghost->Step;
		int WPND = ghost->WeaponDamage;
		
		int dir = Ghost_GetAttribute(ghost, 0, DIR_LEFT);//Facing direction
		int berserkHP = Ghost_GetAttribute(ghost, 1, 0);//Berserk HP threshold
		int sizex = Ghost_GetAttribute(ghost, 2, 2);//Tile Width
		int sizey = Ghost_GetAttribute(ghost, 3, 2);//Tile Height
		int delay  = Ghost_GetAttribute(ghost, 4, 180);//Delay between shooting, in frames
		int ewsprite = Ghost_GetAttribute(ghost, 5, -1);//Sprite to use for eweapons
		int radius = Ghost_GetAttribute(ghost, 6, 0);//Movement radius, 0 for ConstantWalk4
		int berserkWPN = Ghost_GetAttribute(ghost, 7, EW_FIRE2);//Weapon type used for berserk mode
		int berserkspeedmodifier = Ghost_GetAttribute(ghost, 8, 50);//Speed modifier for berserk mode
		int berserkfirespeed = Ghost_GetAttribute(ghost, 9, 200);//Berserk eweapon fire speed.
		
		ghost->Extend=3;
		Ghost_SetSize(this, ghost, sizex, sizey);
		if (sizex>2 && sizey>2)Ghost_SetHitOffsets(ghost, 2, 2, 2, 2);
		
		Ghost_SetFlag(GHF_NORMAL);
		Ghost_UnsetFlag(GHF_KNOCKBACK);
		
		int OrigTile = ghost->OriginalTile;
		int State = 0;
		int haltcounter = -1;
		int statecounter = delay;
		int origX = Ghost_X;
		int origY = Ghost_Y;
		int CurAngle = Rand(360);//Current angular position used for calculating sine wave position.
		int anglestep = SPD/100; //Used for calculating 
		int shootcounter = 0;
		int FireposX[4]={0,0,240,0};
		int FireposY[4]={160,0,0,0};
		FireposX[0] = 32+Rand(192);
		FireposX[1] = 32+Rand(192);
		FireposY[2] = 32+Rand(102);
		FireposY[3] = 32+Rand(102);
		bool berserk = false;
		
		int defs[18];
		Ghost_StoreDefenses(ghost,defs);
		
		while(true){
			if (State==0){
				if (radius>0){
					CurAngle+=anglestep;
					Ghost_X=origX +radius*Cos(CurAngle);
					Ghost_Y=origY +radius*Sin(CurAngle);
				}
				else{
					haltcounter = Ghost_ConstantWalk4(haltcounter, SPD, RR, HF, HNG);
				}
				statecounter--;
				if (statecounter==0){
					statecounter=45;
					State=1;
				}
			}
			if (State==1){
				if (statecounter>0)statecounter--;
				if (statecounter==0){
					if (berserk){
						if (shootcounter==0){
							shootcounter=60;
							Screen->Rectangle(6, 0, 0, 256, 172, 0x81, 1, 0, 0, 0, true, 128);
						}
						shootcounter--;
						if ((shootcounter%3)==0){
							eweapon e =  FireNonAngularEWeapon(berserkWPN, FireposX[dir], FireposY[dir], dir, berserkfirespeed, WPND, -1, -1, 0);
						}
					}
					if (shootcounter==0){
						eweapon e;
						e = FireAimedEWeapon(ghost->Weapon, Cond(dir==DIR_RIGHT, Ghost_X+Ghost_TileWidth*16-16, Ghost_X), Ghost_Y, 0, 100, WPND, ewsprite, -1, EWF_ROTATE);
						e = FireAimedEWeapon(ghost->Weapon, Cond(dir==DIR_RIGHT, Ghost_X+Ghost_TileWidth*16-16, Ghost_X), Ghost_Y, 0.2, 100, WPND, ewsprite, 0, EWF_ROTATE);
						e = FireAimedEWeapon(ghost->Weapon, Cond(dir==DIR_RIGHT, Ghost_X+Ghost_TileWidth*16-16, Ghost_X), Ghost_Y, -0.2, 100, WPND, ewsprite, 0, EWF_ROTATE);
					}
					if (!berserk||shootcounter==0){
						statecounter=delay;
						if (dir<2)FireposX[dir] = 32+Rand(192);
						else FireposY[dir] = 32+Rand(102);
						State=0;
					}
				}
			}
			if (!berserk && Ghost_HP<=berserkHP){
				berserk=true;
				Game->PlaySound(SFX_SUMMON);
				SPD+=berserkspeedmodifier;
				delay/=2;
				anglestep*=2;
			}
			AquamentusAnimation(ghost, OrigTile, State, 2);
			if (!Ghost_Waitframe(this, ghost, false, false)){
				Ghost_DeathAnimation(this, ghost, GHD_EXPLODE);
				Quit();
			}
		}		
	}
}	

void AquamentusAnimation(npc ghost, int origtile, int State, int numframes){
	int offset = 20 * ghost->TileHeight;
	if (State==0) offset=0;
	ghost->OriginalTile = origtile + offset;
}