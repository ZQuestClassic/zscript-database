const int BOSS_SLIME_WALL_STATE_TELEPORTING_IN = 1;
const int BOSS_SLIME_WALL_STATE_TELEPORTING_OUT = 4;
const int BOSS_SLIME_WALL_STATE_CHARGING = 2;
const int BOSS_SLIME_WALL_STATE_FIRED = 3;
const int BOSS_SLIME_WALL_STATE_NOT_IN_PLANE = 0;

const int SFX_BOSS_SLIME_WALL_NUKE = 37;//Sound to play, when SlimeWall casts nuclear flash spell.

const int BOSS_SLIME_WALL_NUKE_FLASH_COLOR = 1;//Color used for nuke flash

const int CF_CHANGEABLE_COMBO = 98;//Combo Flag to define combos that can be changed.

//Eye for Slime wall boss. A huge wall of red stuff that is really painful to touch. An eye teleports inside blob mass, firing eweapons at Link, spawning enemies. 
//When eye`s HP is low enough, the blob expands ala Demon Wall in attewmpt to fill screen completely. killing eye destroys entire Slime Wall and all summons.
//1. Compile the script. 2 FFC slots used.
//2. Set up BossSlimeWall ghosted enemy script for eye itself
////Animation - 4 sequences of frames set vertically: teleporting in, charging, firing, teleporting out.
////Attribute 1: Delay between teleporting
////Attribute 2: Enemy size, X*X square.
////Attribute 3: Attack type, add together: +1- 4 shots orthogonally, +2 - 8 shots in orthogonal and diagonal directions, +4 - summon enemies, +8 - nukes the whole screen for damage anywhere!
////Attribute 4: Eweapon sprite
////Attribute 5: Enemy count for enemy spawning attack
////Attribute 6: Berserk HP threshold
////Attribute 7: Delay between teleporting, if boss went berserk
////Attribute 8: Enemy ID for enemy spawning attack
//3. Set up 3 consecutive combos: 1 for edge of slime wall, then damaging slime innards then another slime innards combo with inherent flag #97 2nd combo must cycle into 3rd combo.
//4. Screen: place FFC with SlimeWallBody script where slime wall edge will be. And put 1 eye enemy.
//D0 - slot used by eye enemy.
//D1 - Slime wall facing direction, floor that on opposite direction must be filled with 3rd combo from step 3 (all combos above FFC, if D1 is DIR_DOWN etc.), while the rest of arena must have NO_FLYING_ENEMIES combo type to avoid eye spawning outside blob wall.
//D2 - When The Blob goes berserk once, he starts moving st that speed.
//D3 - HP threshold for blob expanding
//D4 - When HP falls below that threshold, blob expanding speed increases
//D5 - Blob expanding speed MULTIPLIER when eye HP is below D4

ffc script BossSlimeWall{
	void run(int enemyID){
		npc ghost = Ghost_InitAutoGhost(this, enemyID);
		
		int MinLinkDistance = 128 - (ghost->Homing)/2;//Minimum distance to Link when teleporting 256 - can telefrag Link.
		int WPND = ghost->WeaponDamage;//Eweapon damage
		
		int Teledelay = Ghost_GetAttribute(ghost, 0, 120);//Delay between teleporting
		int EwSize = Ghost_GetAttribute(ghost, 1, 1);//Enemy size, X*X square.
		int Wpn = Ghost_GetAttribute(ghost, 2, 15);//Attack type, add together: +1- 4 shots orthogonally, +2 - 8 shots in orthogonal and diagonal directions, +4 - summon enemies, +8 - nukes the whole screen for damage anywhere!
		int ewsprite = Ghost_GetAttribute(ghost, 3, -1);//Eweapon sprite
		int Encount = Ghost_GetAttribute(ghost, 4, 4);//Enemy count for enemy spawning attack		
		int berserkHP = Ghost_GetAttribute(ghost, 5, 4);//Berserk HP threshold
		int berserkDelay = Ghost_GetAttribute(ghost, 6, 60);//Delay between teleporting, if boss went berserk
		int EnID = Ghost_GetAttribute(ghost, 7, 167);//Enemy ID for enemy spawning attack
		int numcmbchange = Ghost_GetAttribute(ghost, 8, 5);//Unused
		int changecmb = Ghost_GetAttribute(ghost, 9, 0);//Unused
		
		int cmbs[176];
		for (int i=0;i<176;i++){
			if (ComboFI(i,CF_CHANGEABLE_COMBO))cmbs[i]=i;
			else cmbs[i]=-1;
		}
		int curcmb=0;
		int temp=0;
		
		ghost->Extend=3;
		Ghost_SetSize(this, ghost, EwSize, EwSize);
		if (EwSize>2)Ghost_SetHitOffsets(ghost, 8, 8, 8, 8);
		
		Ghost_SetFlag(GHF_NORMAL);
		Ghost_SetFlag(GHF_NO_FALL);
		Ghost_UnsetFlag(GHF_KNOCKBACK);
		Ghost_SetFlag(GHF_FLYING_ENEMY);
		
		int OrigTile = ghost->OriginalTile;
		int State = 0;
		int haltcounter = -1;
		int StateCounter =Teledelay;
		int dir = Ghost_Dir;
		int ewpn = 0;
		int combo = 0;
		bool berserk=false;
		while(true){
			if (State==BOSS_SLIME_WALL_STATE_NOT_IN_PLANE){
				ghost->DrawXOffset = 1000;
				ghost->HitXOffset = 1000;
				if (StateCounter == 0){
					ghost->DrawXOffset = 0;
					ghost->HitXOffset = 0;
					combo = FindSpawnPoint(true, false, false, false);
					if (combo>0)Ghost_X=ComboX(combo);
					if (combo>0)Ghost_Y=ComboY(combo);
					State = BOSS_SLIME_WALL_STATE_TELEPORTING_IN;
					StateCounter = 32;
					dir = SlimeWallFaceLink(ghost);
				}
			}
			if (State==BOSS_SLIME_WALL_STATE_TELEPORTING_IN){
				// if(IsOdd(StateCounter))  ghost->DrawXOffset=StateCounter/4;
				// else  ghost->DrawXOffset=-StateCounter/4;
				if (StateCounter == 0){
					State = BOSS_SLIME_WALL_STATE_CHARGING;
					StateCounter = 32;
				}
			}
			if (State==BOSS_SLIME_WALL_STATE_CHARGING){
				if (StateCounter == 0){
					State = BOSS_SLIME_WALL_STATE_FIRED;
					StateCounter = 32;
					eweapon e;
					ewpn =1<<( Rand(5));
					if ((ewpn&Wpn)==0){
						e = FireAimedEWeapon(ghost->Weapon, Ghost_X, Ghost_Y, 0, 200, WPND, ewsprite, -1, 0);
					}
					else if (ewpn == 1){
						int dirs[4]= {DIR_UP, DIR_DOWN, DIR_LEFT, DIR_RIGHT};
						// Game->PlaySound(ewSound);
						for (int i=0;i<SizeOfArray(dirs);i++){
							eweapon e = FireNonAngularEWeapon(ghost->Weapon,  Ghost_X, Ghost_Y, dirs[i], 300, WPND, ewsprite,-1, EWF_ROTATE);
						}
					}
					else if (ewpn == 2){
						int dirs[8] = {DIR_UP, DIR_RIGHTUP, DIR_RIGHT, DIR_RIGHTDOWN, DIR_DOWN, DIR_LEFTDOWN, DIR_LEFT, DIR_LEFTUP};
						// Game->PlaySound(ewSound);
						for (int i=0;i<SizeOfArray(dirs);i++){
							e = FireNonAngularEWeapon(ghost->Weapon, Ghost_X, Ghost_Y, dirs[i], 300, WPND, ewsprite,-1, EWF_ROTATE);
						}
					}
					else if (ewpn == 4){
						Game->PlaySound(SFX_SUMMON);
						for (int i=1; i<=Encount;i++){
							combo = SlimeWallFindSuitableSpot(ghost, MinLinkDistance,true, false, false, false);
							npc en = CreateNPCAt(EnID,ComboX(combo), ComboY(combo));
							en->Z=128;
							TraceNL();
						}
					}
					else if (ewpn == 8){
						eweapon e = FireEWeapon(EW_SCRIPT10, Link->X+InFrontX(Link->Dir, 12), Link->Y+InFrontY(Link->Dir, 12), 0, 0, WPND, 22, SFX_BOSS_SLIME_WALL_NUKE, EWF_UNBLOCKABLE);
						e->Dir = Link->Dir;
						e->DrawYOffset = -1000;
						SetEWeaponLifespan(e, EWL_TIMER, 1);
						SetEWeaponDeathEffect(e, EWD_VANISH, 0);
						
						for (int i=1; i<=60;i++){
							if(i % 2 == 0) Screen->Rectangle(6, 0, 0, 256, 172, BOSS_SLIME_WALL_NUKE_FLASH_COLOR, 1, 0, 0, 0, true, 64);
							Ghost_Waitframe(this, ghost);
						}
					}
					else if (ewpn == 16){
						ShuffleArray(cmbs);
						curcmb = 0;
						for (int i=1; i<=numcmbchange;i++){
							while(cmbs[curcmb]<0){
								if (cmbs[curcmb]<0)curcmb++;
								if (curcmb>=175)break;
							}
							temp = cmbs[curcmb];
							Screen->ComboD[temp]=changecmb;
							curcmb++;
						}
					}
				}
			}
			if (State==BOSS_SLIME_WALL_STATE_FIRED){
				if (StateCounter == 0){
					State = BOSS_SLIME_WALL_STATE_TELEPORTING_OUT;
					StateCounter = 32;
				}
			}
			if (State==BOSS_SLIME_WALL_STATE_TELEPORTING_OUT){
				if(IsOdd(StateCounter))  ghost->DrawXOffset=1000;
				else  ghost->DrawXOffset=0;
				if (StateCounter == 0){
					ghost->DrawXOffset = 1000;
					ghost->HitXOffset = 1000;
					State = BOSS_SLIME_WALL_STATE_NOT_IN_PLANE;
					StateCounter = Cond(berserk,berserkDelay,Teledelay);
				}
			}
			StateCounter--;
			if (!berserk){
				if (Ghost_HP<=berserkHP){
					Game->PlaySound(SFX_SUMMON);
					berserk=true;
				}
			}
			SlimeWallAnimation(ghost, OrigTile, State, 1);
			if (!Ghost_Waitframe(this, ghost, false, false)){
				ghost->DrawXOffset=0;
				Ghost_DeathAnimation(this, ghost, GHD_EXPLODE);
				Quit();
			}
		}
	}
}

void SlimeWallAnimation(npc ghost, int origtile, int state, int numframes){
	int offset = state-1;
	if (offset<0)offset=0;
	ghost->OriginalTile = origtile + 20*offset*ghost->TileHeight;
}

int SlimeWallFaceLink(npc ghost){
	int cmb = ComboAt (CenterLinkX(), CenterLinkY());
	int ghostcmb = ComboAt (Ghost_X+8, Ghost_Y+8);
	if (ComboY(cmb)<ComboY(ghostcmb)) return DIR_UP;
	else if (ComboY(cmb)>ComboY(ghostcmb)) return DIR_DOWN;
	else if (ComboX(cmb)<ComboX(ghostcmb))  return DIR_LEFT;
	else  return DIR_RIGHT;	
}

int  SlimeWallFindSuitableSpot(npc ghost, int MinLinkDistance, bool landOK, bool wallsOK, bool waterOK, bool pitsOK){
	int tileRatings[176];
    int checkCombo;
    int checkX;
    int checkY;
    int bestRating;
    int bestCount;
    int counter;
    int choice;
    int tries;
    npc otherNPC;    
    // First, rate each tile for suitability. Lower is better,
    // but negative means it's strictly off-limits.      
    for(int i=Screen->NumNPCs(); i>0; i--){// Tiles too close to other enemies are undesirable
        otherNPC=Screen->LoadNPC(i);
        checkCombo=ComboAt(otherNPC->X, otherNPC->Y);
        tileRatings[checkCombo]+=100;        
        if(checkCombo>15)tileRatings[checkCombo-16]+=1;		
        if(checkCombo<160)tileRatings[checkCombo+16]+=1;		
        if(checkCombo%16>0)tileRatings[checkCombo-1]+=1;		
        if(checkCombo%16<15)tileRatings[checkCombo+1]+=1;		
	}    
    // Mark prohibited tiles
    for(int i=0; i<176; i++){       
        if((Screen->Flags[SF_ROOMTYPE]&010b)!=0 && (i<32 || i>143 || i%16<2 || i%16>13))	tileRatings[i]=-1;   // Screen edges in NES dungeon      
        else if(IsWater(i)){// Water
            if(!waterOK)tileRatings[i]=-1;			
		}        
        else if(__IsPit(i)){// Pits
            if(!pitsOK)tileRatings[i]=-1;			
		}       
        else if(Screen->ComboF[i]==CF_NOENEMY || Screen->ComboI[i]==CF_NOENEMY || Screen->ComboT[i]==CT_NOENEMY || Screen->ComboT[i]==CT_NOJUMPZONE)tileRatings[i]=-1; // "No enemy" flag and combos      
        else if(Abs(ComboX(i)-Link->X)<32 && Abs(ComboY(i)-Link->Y)<32) tileRatings[i]+=150;// Too close to Link      
        else{  // All other combos		
			if(landOK && !wallsOK){// If land is okay, but not walls (i.e. walkable only)             
				if (Screen->ComboS[i]>0) tileRatings[i]=-1;				
			}			
			else if(!landOK && wallsOK){   // If walls are okay, but not land (i.e. unwalkable only)            
				if(Screen->ComboS[i]<15) tileRatings[i]=-1;
			}		
			else if(!landOK && !wallsOK)tileRatings[i]=-1;	// Neither land nor walls are okay		
		}
		if (tileRatings[i]>=0){
			tileRatings[i]+=20;
			if (DamageComboPower(i)>0)	tileRatings[i]+=1200;
			int cmb = ComboAt (CenterLinkX(), CenterLinkY());
			if (Distance(ComboX(i), ComboY(i), ComboX(cmb), ComboY(cmb))<MinLinkDistance)tileRatings[i]+=12;
		}
	}
	
	bestRating=10000;// Find the best rating and count the number of tiles with that rating
	bestCount=0;
	for(int i=0; i<176; i++){
		if(tileRatings[i]<0)	continue;		
		if(tileRatings[i]==bestRating)	bestCount++;
		else if(tileRatings[i]<bestRating){
			bestRating=tileRatings[i];
			bestCount=1;
		}
	}	
	
	if(bestCount==0)return 0;	// The loop below might hang if every tile is unusable	
	counter=Rand(bestCount)+1;// Pick at random from the best rated tiles
	
	for(choice=0; counter>0; choice++){
		if(tileRatings[choice]==bestRating)counter--;	
	}	
	return choice-1;// Subtract 1 because the for loop overshot
}

//Swaps two elements in the given array
void SwapArray(int arr, int pos1, int pos2){
	int r = arr[pos1];
	arr[pos1]=arr[pos2];
	arr[pos2]=r;
}

//Shuffles the given array like deck of playing cards
void ShuffleArray(int arr){
	int size = SizeOfArray(arr)-1;
	for (int i=0; i<=size*size; i++){
		int r1 = Rand(size);
		int r2 = Rand(size);
		SwapArray(arr, r1, r2);
	}
}

const int SFX_SLIMEWALL_DEATH = 3;
const int SPR_SLIMEWALL_DEATH = 92;

ffc script SlimeWallBody{
	void run(int npcslot, int dir, int speed, int threshold1, int threshold2, int speed2){
		for(int i=0;i<4;i++){
			Screen->FastCombo(0, this->X, this->Y, this->Data, this->CSet, OP_OPAQUE);
			if (dir==DIR_UP){Screen->FastCombo(0, this->X, this->Y+16, this->Data+2, this->CSet, OP_OPAQUE);}
			if (dir==DIR_DOWN){Screen->FastCombo(0, this->X, this->Y-16, this->Data+2, this->CSet, OP_OPAQUE);}
			if (dir==DIR_LEFT){Screen->FastCombo(0, this->X-16, this->Y, this->Data+2, this->CSet, OP_OPAQUE);}
			if (dir==DIR_RIGHT){Screen->FastCombo(0, this->X+16, this->Y, this->Data+2, this->CSet, OP_OPAQUE);}
			if (dir>1){
				for (int i=1; i<16; i++){					
					if (!Screen->isSolid(this->X, this->Y-16*i))Screen->FastCombo(0, this->X, this->Y-16*i, this->Data, this->CSet, OP_OPAQUE);
					if (!Screen->isSolid(this->X, this->Y+16*i))Screen->FastCombo(0, this->X, this->Y+16*i, this->Data, this->CSet, OP_OPAQUE);
					if (!Screen->isSolid(this->X, this->Y-16*i))Screen->FastCombo(0, this->X+Cond(dir==DIR_LEFT,16,-16), this->Y-16*i, this->Data+2, this->CSet, OP_OPAQUE);
					if (!Screen->isSolid(this->X, this->Y+16*i))Screen->FastCombo(0, this->X+Cond(dir==DIR_LEFT,16,-16), this->Y+16*i, this->Data+2, this->CSet, OP_OPAQUE);
				}
			}
			else{
				for (int i=1; i<16; i++){
					if (!Screen->isSolid(this->X-16*i, this->Y))Screen->FastCombo(0, this->X-16*i, this->Y, this->Data, this->CSet, OP_OPAQUE);
					if (!Screen->isSolid(this->X+16*i, this->Y))Screen->FastCombo(0, this->X+16*i, this->Y, this->Data, this->CSet, OP_OPAQUE);
					if (!Screen->isSolid(this->X-16*i, this->Y))Screen->FastCombo(0, this->X-16*i, this->Y+Cond(dir==DIR_UP,16,-16), this->Data+2, this->CSet, OP_OPAQUE);
					if (!Screen->isSolid(this->X+16*i, this->Y))Screen->FastCombo(0, this->X+16*i, this->Y+Cond(dir==DIR_UP,16,-16), this->Data+2, this->CSet, OP_OPAQUE);
				}
			}
			Waitframe();
		}
		npc en = Screen->LoadNPC(npcslot);
		int drawx = 0;
		int drawy = 0;
		if (!en->isValid()){
			Game->PlaySound(SFX_GANON);
			Quit();
		}
		int moving = 0;
		lweapon explosion;
		while(true){
			if (en->HP<=0){
				this->Vx=0;
				this->Vy=0;
				for (int i=0;i<176;i++){
					if (Screen->ComboD[i]!=this->Data+1 && Screen->ComboD[i]!=this->Data+2)continue;
					Screen->ComboD[i]=Screen->UnderCombo;
					Screen->ComboC[i]=Screen->UnderCSet;
					explosion=Screen->CreateLWeapon(LW_SPARKLE);
					explosion->X=ComboX(i);
					explosion->Y=ComboY(i);
					explosion->UseSprite(SPR_SLIMEWALL_DEATH);
					explosion->CollDetection=false;
				}
				Game->PlaySound(SFX_SLIMEWALL_DEATH);
				this->Data=0;
				Quit();
			}
			if (moving==0){
				if (en->HP<=threshold1){
					if (dir==DIR_UP){
						this->Vy = -speed;
					}
					if (dir==DIR_DOWN){
						this->Vy = speed;
					}
					if (dir==DIR_LEFT){
						this->Vx = -speed;
					}
					if (dir==DIR_RIGHT){
						this->Vy = -speed;
					}
					moving=1;
				}
			}
			else if (moving==1){
				if (en->HP<=threshold2){
					if (dir==DIR_UP){
						this->Vy *= speed2;
					}
					if (dir==DIR_DOWN){
						this->Vy *= speed2;
					}
					if (dir==DIR_LEFT){
						this->Vx *= -speed2;
					}
					if (dir==DIR_RIGHT){
						this->Vy *= -speed2;
					}
					for (int i=1;i<=32;i++){
						ffc f =Screen->LoadFFC(i);
						if (!f->Flags[FFCF_CHANGER])continue;
						if (f->Data!=this->Data)continue;
						f->Vx*=speed2;
						f->Vy*=speed2;
					}
					moving=2;
				}
			}
			for (int i=0;i<176;i++){
				if (Screen->ComboS[i]>0) continue;
				// if (Screen->ComboD[i]==this->Data+1 || Screen->ComboD[i]==this->Data+2) continue;
				if (dir==DIR_UP){
					if (ComboY(i)>=this->Y+16){
						if (Screen->ComboD[i]!=this->Data+1 && Screen->ComboD[i]!=this->Data+2){
							Screen->ComboD[i]=(this->Data)+1;
							Screen->ComboC[i]=this->CSet;
						}
					}
					else{
						if (Screen->ComboD[i]==this->Data+1 || Screen->ComboD[i]==this->Data+2){
							Screen->ComboD[i]=Screen->UnderCombo;
							Screen->ComboC[i]=Screen->UnderCSet;
						}
					}
				}
				if (dir==DIR_DOWN){
					if (ComboY(i)<=this->Y-16){
						if (Screen->ComboD[i]!=this->Data+1 && Screen->ComboD[i]!=this->Data+2){
							Screen->ComboD[i]=(this->Data)+1;
							Screen->ComboC[i]=this->CSet;
						}
					}
					else{
						if (Screen->ComboD[i]==this->Data+1 || Screen->ComboD[i]==this->Data+2){
							Screen->ComboD[i]=Screen->UnderCombo;
							Screen->ComboC[i]=Screen->UnderCSet;
						}
					}
				}
				if (dir==DIR_LEFT){
					if (ComboX(i)>=this->X+16){
						if (Screen->ComboD[i]!=this->Data+1 && Screen->ComboD[i]!=this->Data+2){
							Screen->ComboD[i]=(this->Data)+1;
							Screen->ComboC[i]=this->CSet;
						}
					}
					else{
						if (Screen->ComboD[i]==this->Data+1 || Screen->ComboD[i]==this->Data+2){
							Screen->ComboD[i]=Screen->UnderCombo;
							Screen->ComboC[i]=Screen->UnderCSet;
						}
					}
				}
				if (dir==DIR_RIGHT){
					if (ComboX(i)<=this->X-16){
						if (Screen->ComboD[i]!=this->Data+1 && Screen->ComboD[i]!=this->Data+2){
							Screen->ComboD[i]=(this->Data)+1;
							Screen->ComboC[i]=this->CSet;
						}
					}
					else{
						if (Screen->ComboD[i]==this->Data+1 || Screen->ComboD[i]==this->Data+2){
							Screen->ComboD[i]=Screen->UnderCombo;
							Screen->ComboC[i]=Screen->UnderCSet;
						}
					}
				}
			}
			Screen->FastCombo(0, this->X, this->Y, this->Data, this->CSet, OP_OPAQUE);
			if (dir==DIR_UP){Screen->FastCombo(0, this->X, this->Y+16, this->Data+2, this->CSet, OP_OPAQUE);
			}
			if (dir==DIR_DOWN){Screen->FastCombo(0, this->X, this->Y-16, this->Data+2, this->CSet, OP_OPAQUE);
			}
			if (dir==DIR_LEFT){Screen->FastCombo(0, this->X-16, this->Y, this->Data+2, this->CSet, OP_OPAQUE);
			}
			if (dir==DIR_RIGHT){Screen->FastCombo(0, this->X+16, this->Y, this->Data+2, this->CSet, OP_OPAQUE);
			}
			if (dir>1){
				for (int i=1; i<16; i++){					
					if (!Screen->isSolid(this->X, this->Y-16*i))Screen->FastCombo(0, this->X, this->Y-16*i, this->Data, this->CSet, OP_OPAQUE);
					if (!Screen->isSolid(this->X, this->Y+16*i))Screen->FastCombo(0, this->X, this->Y+16*i, this->Data, this->CSet, OP_OPAQUE);
					if (!Screen->isSolid(this->X, this->Y-16*i))Screen->FastCombo(0, this->X+Cond(dir==DIR_LEFT,16,-16), this->Y-16*i, this->Data+2, this->CSet, OP_OPAQUE);
					if (!Screen->isSolid(this->X, this->Y+16*i))Screen->FastCombo(0, this->X+Cond(dir==DIR_LEFT,16,-16), this->Y+16*i, this->Data+2, this->CSet, OP_OPAQUE);
				}
			}
			else{
				for (int i=1; i<16; i++){
					if (!Screen->isSolid(this->X-16*i, this->Y))Screen->FastCombo(0, this->X-16*i, this->Y, this->Data, this->CSet, OP_OPAQUE);
					if (!Screen->isSolid(this->X+16*i, this->Y))Screen->FastCombo(0, this->X+16*i, this->Y, this->Data, this->CSet, OP_OPAQUE);
					if (!Screen->isSolid(this->X-16*i, this->Y))Screen->FastCombo(0, this->X-16*i, this->Y+Cond(dir==DIR_UP,16,-16), this->Data+2, this->CSet, OP_OPAQUE);
					if (!Screen->isSolid(this->X+16*i, this->Y))Screen->FastCombo(0, this->X+16*i, this->Y+Cond(dir==DIR_UP,16,-16), this->Data+2, this->CSet, OP_OPAQUE);
				}
			}
			// debugValue(1, this->Data+1);
			Waitframe();
		}
	}
}

//Returns power of damage combo at given coordinates, or 0, it`s not a damage combo.
int DamageComboPower(int cmb){
	if (Screen->ComboT[cmb] == CT_DAMAGE1) return 2;
	else if (Screen->ComboT[cmb] == CT_DAMAGE2) return 4;
	else if (Screen->ComboT[cmb] == CT_DAMAGE3) return 8;
	else if (Screen->ComboT[cmb] == CT_DAMAGE4) return 16;
	else if (Screen->ComboT[cmb] == CT_DAMAGE5) return 32;
	else if (Screen->ComboT[cmb] == CT_DAMAGE6) return 64;
	else if (Screen->ComboT[cmb] == CT_DAMAGE7) return 128;
	else	return 0;
}