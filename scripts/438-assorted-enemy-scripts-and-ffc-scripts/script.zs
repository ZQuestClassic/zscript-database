//GhostZigZagFlyer. Flies in randomized ZigZag pattern. Every now and then, it becomes translucent, ignoring all damage.

//Use 8-dir enemy animation.
//Random rate, hunger, homing factor, step speed are used.
//Attribute 0 - Max delay between changing directions.
//Attribute 1 - Delay for between changing between ghost form and normal form, in frames. -1 for no ghost form. 

ffc script ZIgZagFlyer{
	void run(int enemyID){
		npc ghost = Ghost_InitAutoGhost(this, enemyID);
		
		int HF = ghost->Homing;
		int HR = ghost->Haltrate;
		int RR = ghost->Rate;
		int HNG = ghost->Hunger;
		int SPD = ghost->Step;
		int WPND = ghost->WeaponDamage;
		
		int delay = Ghost_GetAttribute(ghost, 0, 15);
		int ghostrh = Ghost_GetAttribute(ghost, 1, -1);		
		
		Ghost_SetFlag(GHF_NORMAL);
		Ghost_SetFlag(GHF_IGNORE_WATER);
		Ghost_SetFlag(GHF_IGNORE_PITS);
		Ghost_SetFlag(GHF_FLYING_ENEMY);
		Ghost_SetFlag(GHF_NO_FALL);
		Ghost_SetFlag(GHF_8WAY);		
		
		//int OrigTile = ghost->OriginalTile;
		int State = 0;
		int haltcounter = delay;
		int dir = Rand(7);
		int ghostcounter = ghostrh;
		int defs[18];
		Ghost_StoreDefenses(ghost,defs);
		
		while(true){
			if (State==0){
				haltcounter = Ghost_VariableWalk8(haltcounter, SPD, RR, HF, HNG, delay);
				if (ghostcounter>=0){
					if (ghostcounter==0){
						if (ghost->DrawStyle==DS_NORMAL){
							ghost->DrawStyle=DS_PHANTOM;
							Ghost_SetAllDefenses(ghost, NPCDT_IGNORE);
						}
						else{
							ghost->DrawStyle = DS_NORMAL;
							Ghost_SetDefenses(ghost, defs);
						}
						ghostcounter = ghostrh;
					}
					else {
						ghostcounter--;
					}
				}
			}
			Ghost_Waitframe(this, ghost);
		}
	}
}

//Constant Walk. Every Nth frame, he jumps. His every Mth jtmp is higher than normal.

//Random rate, hunger, homing factor, step speed are used. If Weapon Damage is >0, this enemy will create explosion after landing every jump. Also explodes on death.

ffc script TweeterSMB2{
	void run(int enemyID){
		npc ghost = Ghost_InitAutoGhost(this, enemyID);
		
		int HF = ghost->Homing;
		int HR = ghost->Haltrate;
		int RR = ghost->Rate;
		int HNG = ghost->Hunger;
		int SPD = ghost->Step;
		int WPND = ghost->WeaponDamage;
		
		int minjump = Ghost_GetAttribute(ghost, 0, 2);//Attribute 0 - normal jump height.
		int maxjump = Ghost_GetAttribute(ghost, 1, 3);//Attribute 1 - max jump height
		int jumpdelay = Ghost_GetAttribute(ghost, 2, 20);//Attribute 2 - delay between jumps, in frames, counted after landing.
		int jumpcount = Ghost_GetAttribute(ghost, 3, 3);//Attribute 3 - every X jump is big one.
		int jumpsfx = Ghost_GetAttribute(ghost, 4, 0);//Jump SFX
		
		//ghost->Extend=3;
		
		Ghost_SetFlag(GHF_NORMAL);
		
		int State = 0;
		int haltcounter = -1;
		int jumpcounter = jumpdelay;
		int jc = jumpcount;
		int OldZ=0;
		
		while(true){
			if (State==0){
				haltcounter = Ghost_ConstantWalk4(haltcounter, SPD, RR, HF, HNG);
				if (jumpcounter<=0 && Ghost_Z==0){
					Game->PlaySound(jumpsfx);
					if (jc==1) Ghost_Jump = maxjump;
					else Ghost_Jump = minjump;
					jc--;
					if (jc==0)jc = jumpcount;
					jumpcounter = jumpdelay;
				}
				else if (Ghost_Z==0){
					if (WPND>0 && OldZ>Ghost_Z){
						eweapon e = FireAimedEWeapon(EW_BOMBBLAST, Ghost_X-16, Ghost_Y+(Ghost_TileHeight-1)*8, 0, 0, WPND, -1, -1, EWF_ROTATE);
					}
					jumpcounter--;
				}
			}
			OldZ=Ghost_Z;
			if (!Ghost_Waitframe(this, ghost, false, false)){
				if (WPND>0) eweapon e = FireAimedEWeapon(EW_SBOMBBLAST, Ghost_X-16, Ghost_Y+(Ghost_TileHeight-1)*8, 0, 0, WPND, -1, -1, EWF_ROTATE);
				Quit();
			}
		}
	}
}

//Constant Walk. When HP falls below specific attribute, gains new attributes.

//Random rate, hunger, homing factor, step speed are used.
//Attribute 1 - damage threshold.
//Attribute 2 - new Random Rate
//Attribute 3 - new step speed.
//Attribute 4 - new homing factor
//Attribute 5 - new weapon damage, if >0, fires eweapons, like death knight
//Attribute 6 - cset to recolor into
//Attribute 7 - sound to play on getting frenzied
//Attribute 8 - delay between shots, in frames

ffc script Frenzied{
	void run(int enemyID){
		npc ghost = Ghost_InitAutoGhost(this, enemyID);
		
		int HF = ghost->Homing;
		int HR = ghost->Haltrate;
		int RR = ghost->Rate;
		int HNG = ghost->Hunger;
		int SPD = ghost->Step;
		int WPND = ghost->WeaponDamage;
		
		int dmgthr = Ghost_GetAttribute(ghost, 0, ghost->HP);
		int newrr = Ghost_GetAttribute(ghost, 1, RR);
		int newspeed = Ghost_GetAttribute(ghost, 2, SPD);
		int newhf = Ghost_GetAttribute(ghost, 3, HF);
		int newwpnd = Ghost_GetAttribute(ghost, 4, WPND);
		int newcset = Ghost_GetAttribute(ghost, 5, ghost->CSet);
		int sound = Ghost_GetAttribute(ghost, 6, 0);
		int shootcounter = Ghost_GetAttribute(ghost, 7, 60);
				
		//ghost->Extend=3;
		
		Ghost_SetFlag(GHF_NORMAL);
		
		int State = 0;
		int haltcounter = -1;
		bool frenzy = false;
		int shc = shootcounter;
		
		while(true){
			if (State==0){
			haltcounter = Ghost_ConstantWalk4(haltcounter, SPD, RR, HF, HNG);
			if (!frenzy){
				if (Ghost_HP<dmgthr){
					Game->PlaySound(sound);
					Ghost_CSet = newcset;
					WPND = newwpnd;
					RR = newrr;
					HF = newhf;
					SPD = newspeed;
					frenzy = true;
				}
			}
			if (WPND>0){
				if (shc>0) shc--;
				if (shc<=0){
					eweapon e = FireNonAngularEWeapon(ghost->Weapon, Ghost_X, Ghost_Y, ghost->Dir, 300, WPND, -1, 0, EWF_ROTATE);
					shc = shootcounter;
				}
			}
			Ghost_Waitframe(this, ghost);
			}
		}
	}
}

const int SPR_AMBUSH_SPAWN = 22;//Sprite to display, when enemy spawn from his hiding spot on ambush.

//Ambush. Spawns an enemy, when Link is near.
//Place FFC at enemy hiding spot.
//D0 - ID of enemy
//D1 - detection radius.
//D2 & D3 - size offset for larger enemies.
//D4 - Set to -1 - replace combo underneath FFC with screen`s undercombo, or
//     positive number to replace destroyed combo with ID, using FFC`s CSet.
//D5 - Sound to play on ambush.
//D6 - Enemy jump when popping out of hiding spot on ambush. 0-3
//D7 - Number of enemies inside hiding spot, spawned all at once.

ffc script Ambush{
	void run (int enemyID, int radius, int sizex, int sizey, int undercombo, int sound, int jump, int number){
		int cmb = ComboAt(CenterX(this), CenterY(this));
		if (sizex==0) sizex=1;
		if (sizey==0) sizey=1;
		while(Distance(Link->X, Link->Y, this->X, this->Y)>radius)Waitframe();
		Game->PlaySound(sound);
		for (int i=1; i<=number; i++){
			npc en = CreateNPCAt(enemyID, this->X-8*(sizex-1), this->Y-8*(sizey-1));
			en->Jump = jump;
		}
		lweapon l = CreateLWeaponAt(LW_SPARKLE, this->X, this->Y);
		l->UseSprite(SPR_AMBUSH_SPAWN);
		l->NumFrames=3;
		l->ASpeed=30;
		l->CollDetection=false;
		if (undercombo>0){
			Screen->ComboD[cmb]= undercombo;
			Screen->ComboC[cmb] = this->CSet;
		}
		else if (undercombo==-1){
			Screen->ComboD[cmb]= Screen->UnderCombo;
			Screen->ComboC[cmb] = Screen->UnderCSet;
		}
	}
}

//Sandstorm. Reduces Link`s movement speed, if Link does not have specific item. 
//Requires LinkMovement.zh
//D0 - item ID
//D1 - speed penalty
ffc script Sandstorm{
	void run (int itemid, int slow){
		while(true){
			if (! Link->Item[itemid])LinkMovement_SetLinkSpeedBoost(-slow);
			Waitframe();
		}
	}
}

//Creates random item from given dropset at given coordinates.
void CreateRandomItem(int dropset, int x, int y){
	npc dummynpc = Screen->CreateNPC(116); //Create dummy enemy. I use 166, the trigger enemy used to execute secret carryover in older ZC versions.
	dummynpc->ItemSet=dropset; //Assign item drop set.
	dummynpc->X=x; //Place him onto candle`s position.
	dummynpc->Y=y;
	dummynpc->HP=0; //Kill the dummy so it drops his item.
}

//Dropset combos. Create random dropset item when specific combo changes into another one. Once per combo.
//D0 - Combo ID to check
//D1 - Dropset to use.
//D2 - Sound to play.
ffc script CustomizableDropsetCombos{
	void run (int potcmb, int dropset, int sound){
		int cmb[176];
		for (int i=0;i<176;i++){
			if (Screen->ComboD[i]==potcmb) cmb[i]=1;
			else cmb[i]=0;
		}
		while(true){
			for (int i=0;i<176;i++){
				if (cmb[i]==0)continue;
				if (Screen->ComboD[i]!=potcmb){
					Game->PlaySound(sound);
					CreateRandomItem(dropset, ComboX(i), ComboY(i));
					cmb[i]=0;
				}
			}
		Waitframe();
		}
	}
}

//Line Wallmaster 
//Like wallmaster, but moves in straight line.
//Step speed used.
//Attribute 0 - >0 - Can grab Link and send him to dungeon entrance.
//Walls must be on higher layer.
ffc script LineMaster{
	void run(int enemyID){
		npc ghost = Ghost_InitAutoGhost(this, enemyID);
		
		int HF = ghost->Homing;
		int HR = ghost->Haltrate;
		int RR = ghost->Rate;
		int HNG = ghost->Hunger;
		int SPD=0.25;
		int WPND = ghost->WeaponDamage;
		
		int Grab = Ghost_GetAttribute(ghost, 0, 0);
		
		ghost->Extend=3;
		
		Ghost_SetFlag(GHF_IGNORE_ALL_TERRAIN);
		Ghost_SetFlag(GHF_MOVE_OFFSCREEN);
		Ghost_SetFlag(GHF_SET_DIRECTION);
		
		int OrigTile = ghost->OriginalTile;
		int State = 0;
		int haltcounter = 60;
		int dir = Rand(3);
		int hidecmb = -1;
		ghost->CollDetection=false;
		bool grabbed=false;
		while(true){
			if (haltcounter==60){
				if (dir==DIR_UP){
					Ghost_X =Link->X;
					Ghost_X = GridX(Ghost_X);
					Ghost_Y = 160;
				}
				if (dir==DIR_DOWN){
					Ghost_X =Link->X;
					Ghost_X = GridX(Ghost_X);
					Ghost_Y = 0;
				}
				if (dir==DIR_LEFT){
					Ghost_Y =Link->Y;
					Ghost_Y = GridX(Ghost_Y);
					Ghost_X=240;
				}
				if (dir==DIR_RIGHT){
					Ghost_Y =Link->Y;
					Ghost_Y = GridX(Ghost_Y);
					Ghost_X=0;
				}
				SPD=0.25;
				Ghost_X = GridX(Ghost_X);
				Ghost_Y = GridY(Ghost_Y);
			}
			if (haltcounter>0){
				haltcounter--;
				if (haltcounter==0){
					SPD = ghost->Step/100;
					ghost->CollDetection=true;
				}
			}
			else {
				if (!grabbed){					
					if (LinkCollision(ghost) && Grab>0){
					Game->PlaySound(SFX_OUCH);
						grabbed=true;
						Link->HP-=ghost->Damage*4;
					}
				}
				else {
					Link->X = ghost->X;
					Link->Y = ghost->Y;
					ghost->CollDetection=false;
					Link->Action=LA_WALKING;
					NoAction();
				}
				bool out =false;
				if (dir==DIR_UP && Ghost_Y<0)out=true;
				if (dir==DIR_DOWN && Ghost_Y>160)out=true;
				if (dir==DIR_LEFT && Ghost_X<0)out=true;
				if (dir==DIR_RIGHT && Ghost_X>24)out=true;
				if (out){
				if (grabbed) Link->Warp(Game->LastEntranceDMap, Game->LastEntranceScreen);
					dir = Rand(3);
					haltcounter=60;
					ghost->CollDetection=false;
				}
			}
			Ghost_Move(dir, SPD, 0);
			LineMasterAnimation(ghost, OrigTile, State, 2);
			Ghost_Waitframe(this, ghost);
		}				
	}	
}


void LineMasterAnimation(npc ghost, int origtile, int state, int numframes){
	int offset = 0;
	ghost->OriginalTile = origtile + offset;
}