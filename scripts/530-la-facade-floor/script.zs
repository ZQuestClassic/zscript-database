const int BOSS_FACADE_STATE_TELEPORTING_IN = 1;
const int BOSS_FACADE_STATE_TELEPORTING_OUT = 4;
const int BOSS_FACADE_STATE_CHARGING = 2;
const int BOSS_FACADE_STATE_FIRED = 3;
const int BOSS_FACADE_STATE_NOT_IN_PLANE = 0;

const int SFX_BOSS_FACADE_NUKE = 37;//Sound to play, when BossFacade casts nuclear flash spell.

const int BOSS_FACADE_NUKE_FLASH_COLOR = 1;//Color used for nuke flash

const int CF_CHANGEABLE_COMBO = 98;//Combo Flag to define combos that can be changed.

//Facade boss variant. Face-like enemy that teleports and fires stuff at Link. Use only Bombs. Goes berserk (faster teleport/attack sequence speed), when HP dropped below specific threshold.
//Animation - 4 frales set vertically: teleporting in, charging, firing, teleporting out.

ffc script BossFacadeFloor{
	void run(int enemyID){
		npc ghost = Ghost_InitAutoGhost(this, enemyID);
		
		int MinLinkDistance = 128 - (ghost->Homing)/2;//Minimum distance to Link when teleporting 256 - can telefrag Link.
		int WPND = ghost->WeaponDamage;//Eweapon damage
		
		int Teledelay = Ghost_GetAttribute(ghost, 0, 120);//Delay between teleporting
		int EwSize = Ghost_GetAttribute(ghost, 1, 3);//Enemy size, X*X square.
		int Wpn = Ghost_GetAttribute(ghost, 2, 15);//Attack type, add together: +1- 4 shots orthogonally, +2 - 8 shots in orthogonal and diagonal directions, +4 - summon enemies, +8 - nukes the whole screen for damage anywhere! +16 - change random combos to specific one The boss picks attack at random and if RNG lands on banned attack type, Facade will fire a single aimed eweapon at Link.
		int ewsprite = Ghost_GetAttribute(ghost, 3, -1);//Eweapon sprite
		int Encount = Ghost_GetAttribute(ghost, 4, 4);//Enemy count for enemy spawning attack		
		int berserkHP = Ghost_GetAttribute(ghost, 5, 4);//Berserk HP threshold
		int berserkDelay = Ghost_GetAttribute(ghost, 6, 60);//Delay between teleporting, if boss went berserk
		int EnID = Ghost_GetAttribute(ghost, 7, 167);//Enemy ID for enemy spawning attack
		int numcmbchange = Ghost_GetAttribute(ghost, 8, 5);//Number of random combos to change
		int changecmb = Ghost_GetAttribute(ghost, 9, 0);//ID of combo to replace to
		
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
		
		int OrigTile = ghost->OriginalTile;
		int State = 0;
		int haltcounter = -1;
		int StateCounter =Teledelay;
		int dir = Ghost_Dir;
		float suckx = Link->X;
		float sucky = Link->Y;
		int soundcounter=30;
		int ewpn = 0;
		bool berserk=false;
		while(true){
			if (State==BOSS_FACADE_STATE_NOT_IN_PLANE){
				ghost->DrawXOffset = 1000;
				ghost->HitXOffset = 1000;
				if (StateCounter == 0){
					ghost->DrawXOffset = 0;
					ghost->HitXOffset = 0;
					int combo = BossFacadeFindSuitableSpot(ghost, MinLinkDistance, true, false, false, false);
					if (combo>0)Ghost_X=ComboX(combo);
					if (combo>0)Ghost_Y=ComboY(combo);
					State = BOSS_FACADE_STATE_TELEPORTING_IN;
					StateCounter = 32;
					dir = BossFacadeFaceLink(ghost);
				}
			}
			if (State==BOSS_FACADE_STATE_TELEPORTING_IN){
				if(IsOdd(StateCounter))  ghost->DrawXOffset=StateCounter/4;
				else  ghost->DrawXOffset=-StateCounter/4;
				if (StateCounter == 0){
					State = BOSS_FACADE_STATE_CHARGING;
					StateCounter = 32;
				}
			}
			if (State==BOSS_FACADE_STATE_CHARGING){
				if (StateCounter == 0){
					State = BOSS_FACADE_STATE_FIRED;
					StateCounter = 32;
					eweapon e;
					ewpn =1<<( Rand(5));
					if ((ewpn&Wpn)==0){
						e = FireAimedEWeapon(ghost->Weapon, CenterX(ghost), CenterY(ghost), 0, 200, WPND, ewsprite, -1, 0);
					}
					else if (ewpn == 1){
						int dirs[4]= {DIR_UP, DIR_DOWN, DIR_LEFT, DIR_RIGHT};
						// Game->PlaySound(ewSound);
						for (int i=0;i<SizeOfArray(dirs);i++){
							eweapon e = FireNonAngularEWeapon(ghost->Weapon,  CenterX(ghost), CenterY(ghost), dirs[i], 300, WPND, ewsprite,-1, EWF_ROTATE);
						}
					}
					else if (ewpn == 2){
						int dirs[8] = {DIR_UP, DIR_RIGHTUP, DIR_RIGHT, DIR_RIGHTDOWN, DIR_DOWN, DIR_LEFTDOWN, DIR_LEFT, DIR_LEFTUP};
						// Game->PlaySound(ewSound);
						for (int i=0;i<SizeOfArray(dirs);i++){
							e = FireNonAngularEWeapon(ghost->Weapon,  CenterX(ghost), CenterY(ghost), dirs[i], 300, WPND, ewsprite,-1, EWF_ROTATE);
						}
					}
					else if (ewpn == 4){
						Game->PlaySound(SFX_SUMMON);
						for (int i=1; i<=Encount;i++){
							npc en = SpawnNPC(EnID);
						}
					}
					else if (ewpn == 8){
						eweapon e = FireEWeapon(EW_SCRIPT10, Link->X+InFrontX(Link->Dir, 12), Link->Y+InFrontY(Link->Dir, 12), 0, 0, WPND, 22, SFX_BOSS_FACADE_NUKE, EWF_UNBLOCKABLE);
						e->Dir = Link->Dir;
						e->DrawYOffset = -1000;
						SetEWeaponLifespan(e, EWL_TIMER, 1);
						SetEWeaponDeathEffect(e, EWD_VANISH, 0);
						
						for (int i=1; i<=60;i++){
							if(i % 2 == 0) Screen->Rectangle(6, 0, 0, 256, 172, BOSS_FACADE_NUKE_FLASH_COLOR, 1, 0, 0, 0, true, 64);
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
			if (State==BOSS_FACADE_STATE_FIRED){
				if (StateCounter == 0){
					State = BOSS_FACADE_STATE_TELEPORTING_OUT;
					StateCounter = 32;
				}
			}
			if (State==BOSS_FACADE_STATE_TELEPORTING_OUT){
				if(IsOdd(StateCounter))  ghost->DrawXOffset=1000;
				else  ghost->DrawXOffset=0;
				if (StateCounter == 0){
					ghost->DrawXOffset = 1000;
					ghost->HitXOffset = 1000;
					State = BOSS_FACADE_STATE_NOT_IN_PLANE;
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
			BossFacadeAnimation(ghost, OrigTile, State, 1);
			if (!Ghost_Waitframe(this, ghost, false, false)){
				ghost->DrawXOffset=0;
				Ghost_DeathAnimation(this, ghost, GHD_EXPLODE);
				Quit();
			}
		}
	}
}

void BossFacadeAnimation(npc ghost, int origtile, int state, int numframes){
	int offset = state-1;
	if (offset<0)offset=0;
	ghost->OriginalTile = origtile + 20*offset*ghost->TileHeight;
}

int BossFacadeFaceLink(npc ghost){
	int cmb = ComboAt (CenterLinkX(), CenterLinkY());
	int ghostcmb = ComboAt (Ghost_X+8, Ghost_Y+8);
	if (ComboY(cmb)<ComboY(ghostcmb)) return DIR_UP;
	else if (ComboY(cmb)>ComboY(ghostcmb)) return DIR_DOWN;
	else if (ComboX(cmb)<ComboX(ghostcmb))  return DIR_LEFT;
	else  return DIR_RIGHT;	
}

int  BossFacadeFindSuitableSpot(npc ghost, int MinLinkDistance, bool landOK, bool wallsOK, bool waterOK, bool pitsOK){
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
    
    for(int i=Screen->NumNPCs(); i>0; i--)    {// Tiles too close to other enemies are undesirable
        otherNPC=Screen->LoadNPC(i);
        checkCombo=ComboAt(otherNPC->X, otherNPC->Y);
        tileRatings[checkCombo]+=100;
        
        if(checkCombo>15)
		tileRatings[checkCombo-16]+=1;
        if(checkCombo<160)
		tileRatings[checkCombo+16]+=1;
        if(checkCombo%16>0)
		tileRatings[checkCombo-1]+=1;
        if(checkCombo%16<15)
		tileRatings[checkCombo+1]+=1;
	}    
    // Mark prohibited tiles
    for(int i=0; i<176; i++) {
        // Screen edges in NES dungeon
        if((Screen->Flags[SF_ROOMTYPE]&010b)!=0 && (i<32 || i>143 || i%16<2 || i%16>13))	tileRatings[i]=-1;        
        else if(IsWater(i)){// Water
            if(!waterOK)tileRatings[i]=-1;			
		}        
        else if(__IsPit(i)) {// Pits
            if(!pitsOK)tileRatings[i]=-1;			
		}
        // "No enemy" flag and combos
        else if(Screen->ComboF[i]==CF_NOENEMY || Screen->ComboI[i]==CF_NOENEMY ||
		Screen->ComboT[i]==CT_NOENEMY || Screen->ComboT[i]==CT_NOFLYZONE ||
		Screen->ComboT[i]==CT_NOJUMPZONE)
		tileRatings[i]=-1;
        // Too close to Link
        else if(Abs(ComboX(i)-Link->X)<32 && Abs(ComboY(i)-Link->Y)<32)
		tileRatings[i]+=150;
        // All other combos
        else        {// If land is okay, but not walls (i.e. walkable only)
		
		if(landOK && !wallsOK){
			checkX=ComboX(i);
			checkY=ComboY(i);
                
                if(Screen->isSolid(checkX, checkY) ||
				Screen->isSolid(checkX+8, checkY) ||
				Screen->isSolid(checkX, checkY+8) ||
				Screen->isSolid(checkX+8, checkY+8))
				tileRatings[i]=-1;
				}
				// If walls are okay, but not land (i.e. unwalkable only)
			else if(!landOK && wallsOK) {
			checkX=ComboX(i);
			checkY=ComboY(i);                
                if(!Screen->isSolid(checkX, checkY) ||
				!Screen->isSolid(checkX+8, checkY) ||
				!Screen->isSolid(checkX, checkY+8) ||
				!Screen->isSolid(checkX+8, checkY+8))
				tileRatings[i]=-1;
				}
				// Neither land nor walls are okay
			else if(!landOK && !wallsOK)tileRatings[i]=-1;			
			}
			if (tileRatings[i]>=0 && ghost->Homing>0){
		tileRatings[i]+=20;
		int cmb = ComboAt (CenterLinkX(), CenterLinkY());//BossFacades prefer aligning cardinally with Link
			if (ComboX(i)==ComboX(cmb))tileRatings[i]-=8;
			if (ComboY(i)==ComboY(cmb))tileRatings[i]-=8;
			if (Distance(ComboX(i), ComboY(i), ComboX(cmb), ComboY(cmb))<MinLinkDistance)tileRatings[i]+=12;
			}
			}	
		// Find the best rating and count the number of tiles with that rating
	bestRating=10000;
	bestCount=0;
	for(int i=0; i<176; i++){
	if(tileRatings[i]<0)	continue;		
	if(tileRatings[i]==bestRating)	bestCount++;
		else if(tileRatings[i]<bestRating)	{
		bestRating=tileRatings[i];
		bestCount=1;
			}
			}		
		// The loop below might hang if every tile is unusable
	if(bestCount==0)	return 0;	
	// Pick at random from the best rated tiles
	counter=Rand(bestCount)+1;
	for(choice=0; counter>0; choice++)   {
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