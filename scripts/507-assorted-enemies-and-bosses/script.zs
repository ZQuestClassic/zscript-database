const int DRACULA2_ALT_FIRE_ASPEED = 4;//delay between Moving and shooting, in frames. Enemy won`t fire bombs, if Weapon Damage is 0.
const int CSET_DRACULA2_WARNING = 11;//CSet to render boss, when he is about to shhoot stuff at Link.
//const int CMB_DRACULA2_BODY = 1044;//Combo used to render alien body (5*5 tiles);
const int SPR_DRACULA2_FIREBALL = -1;//Sprite used for fireballs.
const int DRACULA2_BERSERK = 4;//HP threshold for boss going berserk(2x speed). 0 to disable.

//CV2 Illusionist boss
//Moves like Rotodisk, creates intangible rotating illusuions, ocassionally stops to fire stuff at Link. If it goes bersderk (low HP), it increases rotation speed
ffc script CV2Dracula{
	void run(int enemyID){
		npc ghost = Ghost_InitAutoGhost(this, enemyID);
		
		int HF = ghost->Homing;
		int HR = ghost->Haltrate;
		int RR = ghost->Rate;
		int HNG = ghost->Hunger;
		int SPD = ghost->Step;
		int WPND = ghost->WeaponDamage;		
		
		int origrange = Ghost_GetAttribute(ghost, 0, 60);//Rotation radius.
		int speed = Ghost_GetAttribute(ghost, 1, 0);//Rotation speed, in degrees per frame. if set to 0, speed rendomizes after every fireball shot.
		int initangle = Ghost_GetAttribute(ghost, 2, Rand(359));//Starting angle.  0 - random
		int sizex = Ghost_GetAttribute(ghost, 3, 1);//Tile Width
		int sizey = Ghost_GetAttribute(ghost, 4, 1);//Tile Height
		int shotspeed = Ghost_GetAttribute(ghost, 5, 60);//delay between shooting fireballs
		int NumIllusions = Ghost_GetAttribute(ghost, 6, 4);//Number of illusions to create while moving.
		
		ghost->Extend=3;
		Ghost_SetSize(this, ghost, sizex, sizey);
		if (sizex>2 || sizey>2)Ghost_SetHitOffsets(ghost, 8, 8, 8, 8);
		
		Ghost_SetFlag(GHF_IGNORE_ALL_TERRAIN);
		Ghost_SetFlag(GHF_NO_FALL);
		Ghost_SetFlag(GHF_MOVE_OFFSCREEN);
		
		int range=0;
		int origtile = ghost->OriginalTile;
		int origcset = ghost->CSet;
		int haltcounter = -1;
		int origx = ghost->X;
		int origy = ghost->Y;
		int anglex = initangle;
		Ghost_X = origx + range*Cos(anglex);
		Ghost_Y = origy + range*Sin(anglex);
		int shotcounter=shotspeed;
		
		int defs[18];
		Ghost_StoreDefenses(ghost,defs);
		// if (ThunderbirdShieldBreach>0)Ghost_SetAllDefenses(ghost, NPCDT_IGNORE);
		// int open = 0;
		int state = 0;
		// ghost->DrawXOffset=180;
		int aimx = 0;
		int aimy = 0;
		int angle = initangle;
		if (initangle >=360) angle =Rand(359);
		int berserk=0;
		if (speed==0)speed  = (Rand(4)-2) * Cond (berserk>0, 2,1);
		ghost->CollDetection = false;
		
		while(true){
			if (state==0){
				range ++;
				if (range>= origrange){
					state=1;
					ghost->CollDetection=true;
				}
			}
			if (state==1){
				if (shotcounter>45)anglex+=speed;
				if (anglex>=360) anglex=0;
				Ghost_X = origx + range*Cos(anglex);
				Ghost_Y = origy + range*Sin(anglex);
				shotcounter--;
				if (shotcounter<=45){
					if (IsOdd(shotcounter)) Ghost_CSet = CSET_DRACULA2_WARNING;
					else Ghost_CSet = origcset;
					if (shotcounter==0){
						eweapon e =  FireAimedEWeapon(ghost->Weapon, CenterX(ghost), CenterY(ghost),0, 240, WPND, SPR_DRACULA2_FIREBALL, -1, 0);
						shotcounter=shotspeed;
						if (Ghost_GetAttribute(ghost, 1, 0)==0) speed  = (Rand(4)-2) * Cond (berserk>0, 2,1);
					}
				}
			}
			
			if (DRACULA2_BERSERK>0){
				if (berserk==0 && Ghost_HP<=DRACULA2_BERSERK){
					Game->PlaySound(SFX_SUMMON);
					speed*=2;
					berserk=1;
				}
			}
			
			if ((!UsingItem(I_LENS))&&Ghost_HP>0){
				ghost->DrawXOffset=256;
				for (int i=0; i<NumIllusions; i++){
					int drawangle = anglex + 360/NumIllusions*i;
					Screen->DrawTile(1, origx + range*Cos(drawangle), origy + range*Sin(drawangle), ghost->Tile, sizex, sizey,Ghost_CSet, -1, -1,0, 0, 0,0,true, OP_TRANS);
				}
			}			
			else ghost->DrawXOffset=0;
			
			if (!Ghost_Waitframe(this, ghost, false, false)){
				ghost->DrawXOffset=0;
				Ghost_DeathAnimation(this, ghost, GHD_SHRINK);
				Quit();
			}
		}
	}
}

const int SPR_SHELL_FIREBALL = -1;//Sprite used for fireballs

//Hides inside his invicible shell for ambush.

ffc script ShelledTurret{
	void run(int enemyID){
		npc ghost = Ghost_InitAutoGhost(this, enemyID);
		
		int HF = ghost->Homing;
		int HR = ghost->Haltrate;
		int RR = ghost->Rate;
		int HNG = ghost->Hunger;
		int SPD = ghost->Step;
		int WPND = ghost->WeaponDamage;//Weapon Damage->Additional damage cauded by getting stunned by tremors
		
		int proximity = Ghost_GetAttribute(ghost, 0, 32);//Proximity radius.
		int behaviour = Ghost_GetAttribute(ghost, 1, 0);//Baehaviour after shooting. 0 - hide back, 1 - rapid fire, 2 - run around
		int sizex = Ghost_GetAttribute(ghost, 2, 4);//Tile Width
		int sizey = Ghost_GetAttribute(ghost, 3, 4);//Tile Height
		int delay  = Ghost_GetAttribute(ghost, 4, 30);//Delay fetween firing, in frames
		int walkduration  = Ghost_GetAttribute(ghost, 5, 0);//Walking duration, if attrubute 2 is set to 2. 0 for infinite.
		
		ghost->Extend=3;
		Ghost_SetSize(this, ghost, sizex, sizey);
		if (sizex>2 && sizey>2)Ghost_SetHitOffsets(ghost, 8, 8, 8, 8);
		
		Ghost_SetFlag(GHF_NORMAL);
		
		int OrigTile = ghost->OriginalTile;
		int State = 0;
		int haltcounter = -1;
		int statecounter = delay;
		
		int defs[18];
		Ghost_StoreDefenses(ghost,defs);
		Ghost_SetAllDefenses(ghost, NPCDT_BLOCK);
		
		while(true){
			if (State==0){
				Ghost_ForceDir(Ghost_FaceLink(ghost));
				if (statecounter>0) statecounter--;
				if ((statecounter==0)&&(Distance(Link->X, Link->Y, this->X, this->Y)<=proximity)){
					statecounter = delay;
					Ghost_SetDefenses(ghost, defs);
					State=1;
				}
			}
			if (State==1){
				if (statecounter == delay)eweapon e =  FireAimedEWeapon(ghost->Weapon, Ghost_X, Ghost_Y, 0, 200, WPND, SPR_SHELL_FIREBALL, -1, 0);
				if (statecounter>0) statecounter--;
				if (statecounter==0){
					statecounter = delay;
					State=behaviour;
					if (State==0)Ghost_SetAllDefenses(ghost, NPCDT_BLOCK);
					if (State==2)statecounter=walkduration;
				}
			}
			if (State==2){
				haltcounter = Ghost_ConstantWalk4(haltcounter, SPD, RR, HF, HNG);
				if (walkduration>0){
					if (statecounter>0) statecounter--;
					if (statecounter==0){
						statecounter = delay;
						State=0;
						Ghost_SetAllDefenses(ghost, NPCDT_BLOCK);
					}
				}
			}
			
			Animation(ghost, OrigTile, State, 2);
			Ghost_Waitframe(this, ghost);
		}
	}
}

void Animation(npc ghost, int origtile, int State, int numframes){
	int offset = 20*State;
	ghost->OriginalTile = origtile + offset;
}

int Ghost_FaceLink(npc ghost){
	int cmb = ComboAt (CenterLinkX(), CenterLinkY());
	int ghostcmb = ComboAt (Ghost_X+8, Ghost_Y+8);
	if (ComboY(cmb)<ComboY(ghostcmb)) return DIR_UP;
	else if (ComboY(cmb)>ComboY(ghostcmb)) return DIR_DOWN;
	else if (ComboX(cmb)<ComboX(ghostcmb))  return DIR_LEFT;
	else  return DIR_RIGHT;	
}

//Chorus of Mysteries Beholder

//Moves like medusa head, bouncing off screen edges and solid terrain. Sometimes stops to spawn enemies. Invincible, while moving.

ffc script BeholderCV{
	void run(int enemyID){
		npc ghost = Ghost_InitAutoGhost(this, enemyID);
		
		int HF = ghost->Homing;
		int HR = ghost->Haltrate;
		int RR = ghost->Rate;
		int HNG = ghost->Hunger;
		int SPD = ghost->Step;
		int WPND = ghost->WeaponDamage;
		
		int Amplitude = Ghost_GetAttribute(ghost, 0, 24); //Y-scale of sine wave period. Set to negative for cosine wave motion.
		int Period = Ghost_GetAttribute(ghost, 1, 96); //X-scale of sine wave period.
		int sizex = Ghost_GetAttribute(ghost, 2, 1);//Tile Width
		int sizey = Ghost_GetAttribute(ghost, 3, 1);//Tile Height
		int delay  = Ghost_GetAttribute(ghost, 4, 180);//Delay between spawning, in frames
		int enemyspawn = Ghost_GetAttribute(ghost, 5, 42);//Id of enemy to spawn
		
		ghost->Extend=3;
		Ghost_SetSize(this, ghost, sizex, sizey);
		if (sizex>2 && sizey>2)Ghost_SetHitOffsets(ghost, 8, 8, 8, 8);
		
		Ghost_SetFlag(GHF_NORMAL);
		
		int OrigTile = ghost->OriginalTile;
		int State = 0;
		int haltcounter = -1;
		int statecounter = delay;
		int direction = 1;
		if (Ghost_X>=128) direction=2;
		int AxisY = Ghost_Y; //Axis of sine wave. 
		int CurAngle = Rand(360);//Current angular position used for calculating sine wave position.
		int anglestep = 360/Period; //Used for calculating 
		
		int defs[18];
		Ghost_StoreDefenses(ghost,defs);
		Ghost_SetAllDefenses(ghost, NPCDT_BLOCK);
		
		while(true){
			if (State==0){
				if (direction == 1){
					Ghost_ForceDir(DIR_RIGHT);
					Ghost_X += SPD/100;
					if (!(Ghost_CanMove(DIR_RIGHT, 1, 1, true))) direction=2;
				}
				else if (direction == 2){
					Ghost_ForceDir(DIR_LEFT);
					Ghost_X -= SPD/100;
					if (!(Ghost_CanMove(DIR_LEFT, 1, 1, true)))	direction=1;
				}
				CurAngle += anglestep;
				Ghost_Y = AxisY+ Amplitude*Sin(CurAngle);
				statecounter--;
				if (statecounter<=60){
					Ghost_SetDefenses(ghost, defs);
					State=1;
				}
			}
			if (State==1){
				statecounter--;
				if (statecounter<=0){
					Ghost_SetAllDefenses(ghost, NPCDT_BLOCK);
					State=0;
					statecounter = delay;
					Game->PlaySound(SFX_SUMMON);
					npc r = SpawnNPC(enemyspawn);
					r->X=Ghost_X;
					r->Y=Ghost_Y;
				}
			}
			BeholderAnimation(ghost, OrigTile, State, 2);
			Ghost_Waitframe(this, ghost);
		}
	}	
}

void BeholderAnimation(npc ghost, int origtile, int State, int numframes){
	int offset = 20 * ghost->TileHeight;
	if (State==0) offset=0;
	ghost->OriginalTile = origtile + offset;
}