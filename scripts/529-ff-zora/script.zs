const int SFX_FFZORA_SPLASH_OUT = 26;//Sound to play when jumping out of water
const int SFX_FFZORA_SPLASH_IN = 26;//Sound to play when jumping into water

const int SPR_FFZORA_SPLASH = 22;//Sprite used for water splash

//Zora variant. Swims underwater, sometimes poke out head out of water to shoot eweapons at Link. Can jump out of water and walk on dry land and jump back into water again.

//Uses 5 rows of tiles
//1. Underwater
//2. About to shoot eweapons out of water
//3. Already shot eweapon out of water
//4. Jumping in-out of water
//5. Walking on dry land


ffc script FF_Zora{
	void run(int enemyID){
		npc ghost = Ghost_InitAutoGhost(this, enemyID);
		
		int HF = ghost->Homing;//All 6 used
		int HR = ghost->Haltrate;
		int RR = ghost->Rate;
		int HNG = ghost->Hunger;
		int SPD = ghost->Step;
		int WPND = ghost->WeaponDamage;
		
		int jumpspeed = Ghost_GetAttribute(ghost, 0, 1);//Affects jumping speed 
		int jumphoriz = Ghost_GetAttribute(ghost, 1, 0);//>0 - Can jump onto dry land
		int candive = Ghost_GetAttribute(ghost, 2, 1);//>0 -Can jump into water after walking on dry land
		int ewsprite = Ghost_GetAttribute(ghost, 3, -1);//Eweapon sprite
		int swimduration = Ghost_GetAttribute(ghost, 4, 240);//Underwater swimming duration between shooting eweapons.
		
		ghost->Extend=3;
		
		Ghost_SetFlag(GHF_NORMAL);
		Ghost_SetFlag(GHF_DEEP_WATER_ONLY);
		Ghost_SetFlag(GHF_NO_FALL);
		
		int OrigTile = ghost->OriginalTile;
		int State = 0;
		int haltcounter = -1;
		int statecounter = swimduration;
		int adjdir = -1;
		int cmb = -1;
		
		int defs[18];
		Ghost_StoreDefenses(ghost,defs);
		Ghost_SetAllDefenses(ghost, NPCDT_IGNORE);
		
		bool fired = false;
		
		while(true){
			if (State==0){
				haltcounter = Ghost_ConstantWalk4(haltcounter, SPD, RR, HF, HNG);
				statecounter--;
				if (statecounter==0){
					Ghost_SetDefenses(ghost, defs);
					statecounter=30;
					State=1;
				}
			}
			if (State==1){
				statecounter--;
				if (statecounter==0){
					
					if (jumpspeed>0){
						if (jumphoriz>0){
							adjdir = FindAdjacentDryCombo(ghost);
							if (adjdir>=0)Ghost_UnsetFlag(GHF_DEEP_WATER_ONLY);
						}
						Game->PlaySound(SFX_FFZORA_SPLASH_OUT);
						lweapon s = CreateLWeaponAt(LW_SPARKLE, Ghost_X, Ghost_Y);
						s->UseSprite(SPR_FFZORA_SPLASH);
						s->CollDetection=false;
						statecounter = 64;
						State=3;
					}
					else{
						statecounter=45;
						State=2;
					}
				}
			}
			if (State==2){
				if (!fired){
					eweapon e = FireAimedEWeapon(ghost->Weapon, Ghost_X, Ghost_Y, 0, 200, WPND, ewsprite, -1, 0);
					fired=true;
				}
				statecounter--;
				if (statecounter==0){
					Game->PlaySound(SFX_FFZORA_SPLASH_OUT);
					lweapon s = CreateLWeaponAt(LW_SPARKLE, Ghost_X, Ghost_Y);
					s->UseSprite(SPR_FFZORA_SPLASH);
					s->CollDetection=false;
					statecounter = swimduration;
					fired=false;
					State=0;
				}
			}
			if (State==3){
				if (adjdir==DIR_UP){
					Ghost_Y-=0.25;
				}
				if (adjdir==DIR_DOWN){
					Ghost_Y+=0.25;					
				}
				if (adjdir==DIR_LEFT){
					Ghost_X-=0.25;
				}
				if (adjdir==DIR_RIGHT){
					Ghost_X+=0.25;
				}
				if (adjdir>=0)Ghost_ForceDir(adjdir);
				if (statecounter>=48)Ghost_Z+=jumpspeed;
				else if (statecounter>=32)Ghost_Z+=jumpspeed/2;
				else if (statecounter>=16)Ghost_Z-=jumpspeed/2;
				else Ghost_Z-=jumpspeed;
				if (statecounter==32){
					eweapon e = FireAimedEWeapon(ghost->Weapon, Ghost_X, Ghost_Y, 0, 200, WPND, ewsprite, -1, 0);
				}
				statecounter--;
				if (statecounter==0){
					Ghost_Z=0;
					cmb = ComboAt(CenterX(ghost), CenterY(ghost));
					if (IsWater(cmb)){
						Game->PlaySound(SFX_FFZORA_SPLASH_IN);
						lweapon s = CreateLWeaponAt(LW_SPARKLE, Ghost_X, Ghost_Y);
						s->UseSprite(SPR_FFZORA_SPLASH);
						s->CollDetection=false;
						statecounter = swimduration;
						Ghost_SetFlag(GHF_DEEP_WATER_ONLY);
						Ghost_SetAllDefenses(ghost, NPCDT_IGNORE);
						fired=false;
						State=0;
					}
					else{
						statecounter = 160;
						State=4;
					}
				}
			}
			if (State==4){
				haltcounter =  Ghost_HaltingWalk4(haltcounter, SPD, RR, HF, HNG, HR, 30);
				if (haltcounter==30){
					eweapon e = FireAimedEWeapon(ghost->Weapon, Ghost_X, Ghost_Y, 0, 200, WPND, ewsprite, -1, 0);
				}
				statecounter--;
				if (statecounter==0){
					adjdir = FindAdjacentWaterCombo(ghost);
					if (adjdir>=0 && candive>0){
						statecounter = 64;
						State=3;
					}
					else statecounter = 32;
				}
			}
			if (State==5){
			}
			// debugValue(1,statecounter);
			// debugValue(2,adjdir);
			ghost->OriginalTile = OrigTile + 20*State;
			Ghost_Waitframe(this, ghost);
		}
	}
}

void FFZoraAnimation(npc ghost, int OrigTile, int State){
	ghost->OriginalTile = OrigTile + 20*State;
}

int FindAdjacentDryCombo(npc ghost){
	int cmb = ComboAt(CenterX(ghost), CenterY(ghost));
	int adjcmb=-1;
	for (int i=0;i<4;i++){
		adjcmb = AdjacentComboFix(cmb, i);
		if (adjcmb<0)continue;
		if (IsWater(adjcmb)) continue;
		if (Screen->ComboS[adjcmb]>0)continue;
		if (ComboFI(adjcmb,96))continue;
		if (ComboFI(adjcmb,97))continue;
		return i;
	}
	return -1;
}

int FindAdjacentWaterCombo(npc ghost){
	int cmb = ComboAt(CenterX(ghost), CenterY(ghost));
	int adjcmb=-1;
	for (int i=0;i<4;i++){
		adjcmb = AdjacentComboFix(cmb, i);
		if (adjcmb<0)continue;
		if (!IsWater(adjcmb)) continue;
		if (Screen->ComboS[adjcmb]>0)continue;
		if (ComboFI(adjcmb,96))continue;
		if (ComboFI(adjcmb,97))continue;
	return i;
	}
	return -1;
}

//Fixed variant of AdjacentCombo function from std_extension.zh
int AdjacentComboFix(int cmb, int dir)
{
	int combooffsets[13]={-0x10, 0x10, -1, 1, -0x11, -0x0F, 0x0F, 0x11};
	if ( cmb % 16 == 0 ) combooffsets[9] = -1;//if it's the left edge
	if ( (cmb % 16) == 15 ) combooffsets[10] = -1; //if it's the right edge
	if ( cmb < 0x10 ) combooffsets[11] = -1; //if it's the top row
	if ( cmb > 0x9F ) combooffsets[12] = -1; //if it's on the bottom row
	if ( combooffsets[9]==-1 && ( dir == DIR_LEFT || dir == DIR_LEFTUP || dir == DIR_LEFTDOWN ) ) return -1; //if the left columb
	if ( combooffsets[10]==-1 && ( dir == DIR_RIGHT || dir == DIR_RIGHTUP || dir == DIR_RIGHTDOWN ) ) return -1; //if the right column
	if ( combooffsets[11]==-1 && ( dir == DIR_UP || dir == DIR_RIGHTUP || dir == DIR_LEFTUP ) ) return -1; //if the top row
	if ( combooffsets[12]==-1 && ( dir == DIR_DOWN || dir == DIR_RIGHTDOWN || dir == DIR_LEFTDOWN ) ) return -1; //if the bottom row
	if ( cmb >= 0 && cmb < 176 ) return cmb + combooffsets[dir];
	else return -1;
}

//Another Item Pickup Message.
//D0-D6 - used for Action item script
//D7 - String.
item script CompatPickupString{
	void run (int foo1, int foo2, int foo3, int foo4, int foo5, int foo6, int foo7, int str){
		Screen->Message(str);
	}
}