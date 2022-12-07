const int OILBUSH_LAYER = 2; //Layer to which burning is drawn
const int OILBUSH_DAMAGE = 2; //Damage dealt by burning oil/bushes

const int OILBUSH_CANTRIGGER = 1; //Set to 1 if burning objects can trigger adjacent burn triggers
const int OILBUSH_DAMAGEENEMIES = 1; //Set to 1 if burning objects can damage enemies standing on them
const int OILBUSH_BUSHESSTILLDROPITEMS = 1; //Set to 1 if burning bushes should still drop their items

const int NPC_BUSHDROPSET = 177; //The ID of an Other type enemy with the tall grass dropset

const int OILBUSH_OIL_DURATION = 180; //Duration oil burns for in frames
const int OILBUSH_BUSH_DURATION = 60; //Duration bushes/grass burn for in frames

const int OILBUSH_OIL_SPREAD_FREQ = 2; //How frequently burning oil spreads (should be shorter than burn duration)
const int OILBUSH_BUSH_SPREAD_FREQ = 10; //How frequently burning bushes/grass spread

const int CMB_OIL_BURNING = 900; //First combo for burning oil
const int CS_OIL_BURNING = 8; //CSet for burning oil
const int OILBUSH_ENDFRAMES_OILBURN = 4; //Number of combos for oil burning out
const int OILBUSH_ENDDURATION_OILBURN = 16; //Duration of the burning out animation

const int CMB_BUSH_BURNING = 900; //First combo for burning oil
const int CS_BUSH_BURNING = 8; //CSet for burning oil
const int OILBUSH_ENDFRAMES_BUSHBURN = 4; //Number of combos for bushes/grass burning out
const int OILBUSH_ENDDURATION_BUSHBURN = 16; //Duration of the burning out animation

const int SFX_OIL_BURN = 13; //Sound when oil catches fire
const int SFX_BUSH_BURN = 13; //Sound when bushes catch fire

//EWeapon and LWeapon IDs used for burning stuff.
const int EW_OILBUSHBURN = 40; //EWeapon ID. Script 10 by default
const int LW_OILBUSHBURN = 9; //LWeapon ID. Fire by default

ffc script BurningOilandBushes{
	void run(int noOil, int noBushes){
		int i; int j;
		int c;
		int ct;
		int burnTimers[176];
		int burnTypes[176];
		lweapon burnHitboxes[176];
		while(true){
			//Loop through all LWeapons
			for(i=Screen->NumEWeapons(); i>=1; i--){
				eweapon e = Screen->LoadEWeapon(i);
				//Only fire weapons can burn oil/bushes
				if(e->ID==EW_FIRE||e->ID==EW_FIRE2){
					c = ComboAt(CenterX(e), CenterY(e));
					//Check to make sure it isn't already burning
					if(burnTimers[c]<=0){
						//Check if oil is allowed and if the combo is a water combo
						if(!noOil&&OilBush_IsWater(c)){
							if(SFX_OIL_BURN>0)
								Game->PlaySound(SFX_OIL_BURN);
							burnTimers[c] = OILBUSH_OIL_DURATION;
							burnTypes[c] = 0; //Mark as an oil burn
						}
						//Else check if bushes are allowd and if the combo is a bush
						else if(!noBushes&&OilBush_IsBush(c)){
							if(SFX_BUSH_BURN>0)
								Game->PlaySound(SFX_BUSH_BURN);
							burnTimers[c] = OILBUSH_BUSH_DURATION;
							burnTypes[c] = 1; //Mark as a bush burn
							Screen->ComboD[c]++; //Advance to the next combo
							if(OILBUSH_BUSHESSTILLDROPITEMS){ //If item drops are allowed, create and kill a dummy enemy
								npc n = CreateNPCAt(NPC_BUSHDROPSET, ComboX(c), ComboY(c));
								n->HP = -1000;
								n->DrawYOffset = -1000;
							}	
						}
					}
				}
			}
			//Loop through all LWeapons
			for(i=Screen->NumLWeapons(); i>=1; i--){
				lweapon l = Screen->LoadLWeapon(i);
				//Only fire weapons can burn oil/bushes
				if(l->ID==LW_FIRE){
					c = ComboAt(CenterX(l), CenterY(l));
					//Check to make sure it isn't already burning
					if(burnTimers[c]<=0){
						//Check if oil is allowed and if the combo is a water combo
						if(!noOil&&OilBush_IsWater(c)){
							if(SFX_OIL_BURN>0)
								Game->PlaySound(SFX_OIL_BURN);
							burnTimers[c] = OILBUSH_OIL_DURATION;
							burnTypes[c] = 0; //Mark as an oil burn
						}
						//Else check if bushes are allowd and if the combo is a bush
						else if(!noBushes&&OilBush_IsBush(c)){
							if(SFX_BUSH_BURN>0)
								Game->PlaySound(SFX_BUSH_BURN);
							burnTimers[c] = OILBUSH_BUSH_DURATION;
							burnTypes[c] = 1; //Mark as a bush burn
							Screen->ComboD[c]++; //Advance to the next combo
							if(OILBUSH_BUSHESSTILLDROPITEMS){ //If item drops are allowed, create and kill a dummy enemy
								npc n = CreateNPCAt(NPC_BUSHDROPSET, ComboX(c), ComboY(c));
								n->HP = -1000;
								n->DrawYOffset = -1000;
							}	
						}
					}
				}
			}
			//Loop through all Combos (spread the fire around)
			for(i=0; i<176; i++){
				//If you're on fire raise your hand
				if(burnTimers[i]>0){
					int burnDuration = OILBUSH_OIL_DURATION;
					int spreadFreq = OILBUSH_OIL_SPREAD_FREQ;
					int burnEndFrames = OILBUSH_ENDFRAMES_OILBURN;
					int burnEndDuration = OILBUSH_ENDDURATION_OILBURN;
					if(burnTypes[i]==1){ //Bushes have different burning properties from oil
						burnDuration = OILBUSH_BUSH_DURATION;
						spreadFreq = OILBUSH_BUSH_SPREAD_FREQ;
						burnEndFrames = OILBUSH_ENDFRAMES_BUSHBURN;
						burnEndDuration = OILBUSH_ENDDURATION_BUSHBURN;
					}
					//If it has been spreadFreq frames since the burning started, spread to adjacent combos
					if(burnTimers[i]==burnDuration-spreadFreq){
						//Check all four adjacent combos
						for(j=0; j<4; j++){
							c = i; //Target combo is set to i and moved based on direction or j
							if(j==DIR_UP){
								c -= 16;
								if(i<16) //Prevent checking combo above along top edge
									continue;
							}
							else if(j==DIR_DOWN){
								c += 16;
								if(i>159) //Prevent checking combo below along bottom edge
									continue;
							}
							else if(j==DIR_LEFT){
								c--;
								if(i%16==0) //Prevent checking combo to the left along left edge
									continue;
							}
							else if(j==DIR_RIGHT){
								c++; //Name drop
								if(i%16==15) //Prevent checking combo to the right along right edge
									continue;
							}
							
							if(burnTimers[c]<=0){ //If the adjacent combo isn't already burning
								if(burnTypes[i]==0){ //If the burning combo at i is oil
									if(OilBush_IsWater(c)){ //If the adjacent combo is water, light it on fire
										if(SFX_OIL_BURN>0)
											Game->PlaySound(SFX_OIL_BURN);
										burnTimers[c] = OILBUSH_OIL_DURATION;
										burnTypes[c] = 0;
									}
									else if(ComboFI(c, CF_CANDLE1)&&OILBUSH_CANTRIGGER){ //If there's an adjacent fire trigger and the script is allowed to trigger them
										lweapon l = CreateLWeaponAt(LW_FIRE, ComboX(c), ComboY(c)); //Make a weapon on top of the combo to trigger it
										l->CollDetection = 0; //Turn off its collision
										l->Step = 0; //Make it stationary
										l->DrawYOffset = -1000; //Make it invisible
									}
								}
								else if(burnTypes[i]==1){ //Otherwise if it's a bush
									if(OilBush_IsBush(c)){ //If the adjancent combo is a bush, light it on fire
										if(SFX_BUSH_BURN>0)
											Game->PlaySound(SFX_BUSH_BURN);
										burnTimers[c] = OILBUSH_BUSH_DURATION;
										burnTypes[c] = 1; //Mark as a bush burn
										Screen->ComboD[c]++; //Advance to the next combo
										if(OILBUSH_BUSHESSTILLDROPITEMS){ //If item drops are allowed, create and kill a dummy enemy
											npc n = CreateNPCAt(NPC_BUSHDROPSET, ComboX(c), ComboY(c));
											n->HP = -1000;
											n->DrawYOffset = -1000;
										}	
									}
									else if(ComboFI(c, CF_CANDLE1)&&OILBUSH_CANTRIGGER){ //If there's an adjacent fire trigger and the script is allowed to trigger them
										lweapon l = CreateLWeaponAt(LW_FIRE, ComboX(c), ComboY(c)); //Make a weapon on top of the combo to trigger it
										l->CollDetection = 0; //Turn off its collision
										l->Step = 0; //Make it stationary
										l->DrawYOffset = -1000; //Make it invisible
									}
								}
							}
						}
					}
				}
			}
			//Loop through all Combos again (actually draw the fire)
			for(i=0; i<176; i++){
				if(burnTimers[i]>0){ //Check through all burning combos
					if(OILBUSH_DAMAGEENEMIES){ //Only if enemy damaging is on
						if(!burnHitboxes[i]->isValid()){ //If the hitbox for the tile isn't there, recreate it
							burnHitboxes[i] = CreateLWeaponAt(LW_SCRIPT10, ComboX(i), ComboY(i));
							burnHitboxes[i]->Step = 0; //Make it stationary
							burnHitboxes[i]->Dir = 8; //Make it pierce
							burnHitboxes[i]->DrawYOffset = -1000; //Make it invisible
							burnHitboxes[i]->Damage = OILBUSH_DAMAGE; //Make it deal damage
						}
					}
					if(Distance(ComboX(i), ComboY(i), Link->X, Link->Y)<48){ //If Link is close enough, create fire hitboxes
						eweapon e = FireEWeapon(EW_SCRIPT10, ComboX(i), ComboY(i), 0, 0, OILBUSH_DAMAGE, 0, 0, EWF_UNBLOCKABLE);
						//Make the hitbox invisible
						e->DrawYOffset = -1000;
						//Make the hitbox last for one frame
						SetEWeaponLifespan(e, EWL_TIMER, 1);
						SetEWeaponDeathEffect(e, EWD_VANISH, 0);
					}
					burnTimers[i]--; //This ain't no Bible. Bushes burn up eventually.
					int cmbBurn;
					if(burnTypes[i]==0){
						//Set animation for oil burning out
						cmbBurn = CMB_OIL_BURNING+Clamp(OILBUSH_ENDFRAMES_OILBURN-1-Floor(burnTimers[i]/(OILBUSH_ENDDURATION_OILBURN/OILBUSH_ENDFRAMES_OILBURN)), 0, OILBUSH_ENDFRAMES_OILBURN-1);
						Screen->FastCombo(OILBUSH_LAYER, ComboX(i), ComboY(i), cmbBurn, CS_OIL_BURNING, 128);
					}
					else{
						//Set animation for bush burning out
						cmbBurn = CMB_BUSH_BURNING+Clamp(OILBUSH_ENDFRAMES_BUSHBURN-1-Floor(burnTimers[i]/(OILBUSH_ENDDURATION_BUSHBURN/OILBUSH_ENDFRAMES_BUSHBURN)), 0, OILBUSH_ENDFRAMES_BUSHBURN-1);
						Screen->FastCombo(OILBUSH_LAYER, ComboX(i), ComboY(i), cmbBurn, CS_BUSH_BURNING, 128);
					}
				}
				else{
					if(burnHitboxes[i]->isValid()){ //Clean up any leftover hitboxes
						burnHitboxes[i]->DeadState = 0;
					}
				}
			}
			Waitframe();
		}
	}
	bool OilBush_IsWater(int pos){
		int combo = Screen->ComboT[pos];
		if(combo==CT_SHALLOWWATER || combo==CT_WATER || combo==CT_SWIMWARP || combo==CT_DIVEWARP || (combo>=CT_SWIMWARPB && combo<=CT_DIVEWARPD))
			return true;
		else
			return false;
	}
	bool OilBush_IsBush(int pos){
		int combo = Screen->ComboT[pos];
		if(combo==CT_BUSHNEXT||combo==CT_BUSHNEXTC||combo==CT_TALLGRASSNEXT)
			return true;
		else
			return false;
	}
}