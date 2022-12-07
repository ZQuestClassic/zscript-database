const int FFWIZZROBE_STATE_TELEPORTING_IN = 1;
const int FFWIZZROBE_STATE_TELEPORTING_OUT = 4;
const int FFWIZZROBE_STATE_CHARGING = 2;
const int FFWIZZROBE_STATE_FIRED = 3;
const int FFWIZZROBE_STATE_NOT_IN_PLANE = 0;

const int SFX_ENEMY_HEAL = 25;//Sound to play, when Wizzrobe`s healing spell hits enemy for healing.
const int SFX_BLACKHOLE_WIZZROBE=13;//Sound to play, when Wizrobe activates black-hole-like suction.

const int SPR_ENEMY_HEAL = 96;//Ssprite to display, when Wizzrobe`s healing spell hits enemy for healing.

const int FFWIZZROBE_COUNTER_DRAIN_DELAY = 10;//Delay between counter draining cycles, in frames.
const int SFX_FFWIZZROBE_COUNTER_DRAIN=12;//Sound to play during counter draining.

//Freeform teleporting Wizzrobe.
//!\ REQUIRES LinkMovement.zh !!

global script FFWizzrobeActive{
	void run(){
		StartGhostZH();
		Tango_Start();
		__classic_zh_InitScreenUpdating();
	    LinkMovement_Init();
		while(true)	{
			LinkMovement_Update1();
			UpdateGhostZH1();
			__classic_zh_UpdateScreenChange1();
			Tango_Update1();
			__classic_zh_do_z2_lantern();
			if ( __classic_zc_internal[__classic_zh_SCREENCHANGED] )
			{
				__classic_zh_CompassBeep();
				__classic_zh_ResetScreenChange();
			}
			Waitdraw();
			LinkMovement_Update2();
			UpdateGhostZH2();
			Tango_Update2();
			Waitframe();
		}
	}
}

ffc script FreeformWizzrobe{
	void run(int enemyID){
		npc ghost = Ghost_InitAutoGhost(this, enemyID);
		
		int MinLinkDistance = 128 - (ghost->Homing)/2;//Minimum distance to Link when teleporting
		int WPND = ghost->WeaponDamage;//Magic damage
		
		int Teledelay = Ghost_GetAttribute(ghost, 0, 120);//Delay between teleporting
		int MagicHealEnemies = Ghost_GetAttribute(ghost, 1, 0);//If magic hits enemy it heals that value
		int Wpn = Ghost_GetAttribute(ghost, 2, 0);//Attack type: 0 - 1 shot, 1- 4 shots orthogonally, 2-8 shots in orthogonal and diagonal directions, 3 - summon enemies, 4 - nukes the whole screen for damage anywhere!
		int EWType = Ghost_GetAttribute(ghost, 3, EW_MAGIC);//Weapon type / Enemy ID / nuke flash color
		int ewSound = Ghost_GetAttribute(ghost, 4, 32);// Weapon fire sound / enemy count		
		int BlackHoleRange = Ghost_GetAttribute(ghost, 5, 0);//Black hole-like suction range, in pixels
		int BlackHoleSpeed = Ghost_GetAttribute(ghost, 6, 0);//Black hole-like suction speed, in 1/100ths of pixel per speed
		int BlackHoleCounter = Ghost_GetAttribute(ghost, 7, 1);//counter to drain within 1/2 of suction range
		int BlackHoleDrainPower = Ghost_GetAttribute(ghost, 8, 0);//Counter drain amount
		int BlackHoleCounterTile = Ghost_GetAttribute(ghost, 9, 0);//Tile to render tilefor counter drainage, using enemy`s CSet.
		
		ghost->Extend=3;
		
		Ghost_SetFlag(GHF_NORMAL);
		Ghost_SetFlag(GHF_NO_FALL);
		
		int OrigTile = ghost->OriginalTile;
		int State = 0;
		int haltcounter = -1;
		int StateCounter =Teledelay;
		int dir = Ghost_Dir;
		float suckx = Link->X;
		float sucky = Link->Y;
		int soundcounter=30;
		while(true){
			if (State==FFWIZZROBE_STATE_NOT_IN_PLANE){
				ghost->DrawXOffset = 1000;
				ghost->HitXOffset = 1000;
				if (StateCounter == 0){
					ghost->DrawXOffset = 0;
					ghost->HitXOffset = 0;
					int combo = WizzrobeFindSuitableSpot(ghost, MinLinkDistance, true, false, false, false);
					if (combo>0)Ghost_X=ComboX(combo);
					if (combo>0)Ghost_Y=ComboY(combo);
					State = FFWIZZROBE_STATE_TELEPORTING_IN;
					StateCounter = 32;
					dir = WizzrobeFaceLink(ghost);
				}
			}
			if (State==FFWIZZROBE_STATE_TELEPORTING_IN){
				if(IsOdd(StateCounter))  ghost->DrawXOffset=1000;
				else  ghost->DrawXOffset=0;
				if (StateCounter == 0){
					State = FFWIZZROBE_STATE_CHARGING;
					StateCounter = 32;
				}
			}
			if (State==FFWIZZROBE_STATE_CHARGING){
				if (BlackHoleRange>0){
					soundcounter--;
					if (soundcounter<=0)soundcounter=30;			
					float dist = Distance(Ghost_X, Ghost_Y, Link->X, Link->Y);
					if (dist<=BlackHoleRange){
						if (soundcounter==this->InitD[4])Game->PlaySound(SFX_BLACKHOLE_WIZZROBE);
						float angle = Angle(this->X, this->Y, Link->X, Link->Y);
						suckx = -BlackHoleSpeed/100*Cos(angle);
						sucky = -BlackHoleSpeed/100*Sin(angle);
						LinkMovement_Push2(suckx, sucky);
						dist = Distance(Ghost_X, Ghost_Y, Link->X, Link->Y);
						if (dist< (BlackHoleRange/2)&& BlackHoleDrainPower>0){
							int drawlerp = Randf(1);
							int drawx = Lerp(Ghost_X, Link->X, drawlerp); 
							int drawy = Lerp(Ghost_Y, Link->Y, drawlerp);
							if (BlackHoleCounterTile>0) Screen->FastTile(2, drawx, drawy, BlackHoleCounterTile, ghost->CSet, OP_OPAQUE);
							if ((StateCounter%FFWIZZROBE_COUNTER_DRAIN_DELAY)==0){
								Game->PlaySound(SFX_FFWIZZROBE_COUNTER_DRAIN);
								Game->DCounter[BlackHoleCounter] -= BlackHoleDrainPower;
							}
						}
					}
				}
				if (StateCounter == 0){
					State = FFWIZZROBE_STATE_FIRED;
					StateCounter = 32;
					eweapon e;
					if (Wpn == 0){
						e = FireNonAngularEWeapon(EWType, Ghost_X, Ghost_Y, ghost->Dir, 300, WPND, -1,ewSound, EWF_ROTATE);
					}
					if (MagicHealEnemies>0){
						while(e->isValid()){
							for (int i=1; i<=Screen->NumNPCs(); i++){
								npc h = Screen->LoadNPC(i);
								if (h==ghost) continue;
								if (Collision(h,e)){
									h->HP+=MagicHealEnemies;
									Remove(e);
									Game->PlaySound(SFX_ENEMY_HEAL);
									lweapon s = CreateLWeaponAt(LW_SPARKLE, h->X, h->Y);
									s->UseSprite(SPR_ENEMY_HEAL);
									s->CollDetection=false; 
								}
							}
							Ghost_Waitframe(this, ghost);
						}
						
					}
					else if (Wpn == 1){
						int dirs[4]= {DIR_UP, DIR_DOWN, DIR_LEFT, DIR_RIGHT};
						Game->PlaySound(ewSound);
						for (int i=0;i<SizeOfArray(dirs);i++){
							eweapon e = FireNonAngularEWeapon(EWType, Ghost_X, Ghost_Y, dirs[i], 300, WPND, -1,0, EWF_ROTATE);
						}
					}
					else if (Wpn == 2){
						int dirs[8] = {DIR_UP, DIR_RIGHTUP, DIR_RIGHT, DIR_RIGHTDOWN, DIR_DOWN, DIR_LEFTDOWN, DIR_LEFT, DIR_LEFTUP};
						Game->PlaySound(ewSound);
						for (int i=0;i<SizeOfArray(dirs);i++){
							e = FireNonAngularEWeapon(EWType, Ghost_X, Ghost_Y, dirs[i], 300, WPND, -1,0, EWF_ROTATE);
						}
					}
					else if (Wpn == 3){
						Game->PlaySound(SFX_SUMMON);
						for (int i=1; i<=ewSound;i++){
							npc en = CreateNPCAt(EWType, Ghost_X,Ghost_Y);
						}
					}
					else if (Wpn == 4){
						eweapon e = FireEWeapon(EW_SCRIPT10, Link->X+InFrontX(Link->Dir, 12), Link->Y+InFrontY(Link->Dir, 12), 0, 0, WPND, 22, ewSound, EWF_UNBLOCKABLE);
						e->Dir = Link->Dir;
						e->DrawYOffset = -1000;
						SetEWeaponLifespan(e, EWL_TIMER, 1);
						SetEWeaponDeathEffect(e, EWD_VANISH, 0);
						
						for (int i=1; i<=60;i++){
							if(i % 2 == 0) Screen->Rectangle(6, 0, 0, 256, 172, EWType, 1, 0, 0, 0, true, 64);
							Ghost_Waitframe(this, ghost);
						}
					}
				}
			}
			if (State==FFWIZZROBE_STATE_FIRED){
				if (StateCounter == 0){
					State = FFWIZZROBE_STATE_TELEPORTING_OUT;
					StateCounter = 32;
				}
			}
			if (State==FFWIZZROBE_STATE_TELEPORTING_OUT){
				if(IsOdd(StateCounter))  ghost->DrawXOffset=1000;
				else  ghost->DrawXOffset=0;
				if (StateCounter == 0){
					ghost->DrawXOffset = 1000;
					ghost->HitXOffset = 1000;
					State = FFWIZZROBE_STATE_NOT_IN_PLANE;
					StateCounter = Teledelay;
				}
			}
			StateCounter--;
			Ghost_ForceDir(dir);
			Ghost_Waitframe(this, ghost);
		}
	}
}

void WizzrobeAnimation(npc ghost, int origtile, int state, int numframes){
	int offset = 0;
	ghost->OriginalTile = origtile + offset;
}

int WizzrobeFaceLink(npc ghost){
	int cmb = ComboAt (CenterLinkX(), CenterLinkY());
	int ghostcmb = ComboAt (Ghost_X+8, Ghost_Y+8);
	if (ComboY(cmb)<ComboY(ghostcmb)) return DIR_UP;
	else if (ComboY(cmb)>ComboY(ghostcmb)) return DIR_DOWN;
	else if (ComboX(cmb)<ComboX(ghostcmb))  return DIR_LEFT;
	else  return DIR_RIGHT;	
}

int  WizzrobeFindSuitableSpot(npc ghost, int MinLinkDistance, bool landOK, bool wallsOK, bool waterOK, bool pitsOK){
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
		int cmb = ComboAt (CenterLinkX(), CenterLinkY());//Wizzrobes prefer aligning cardinally with Link
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