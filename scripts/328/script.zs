const int CRYSTALSWITCH_CAN_WALK_ON_TOP = 1; //If 1, Link can walk on top of raised crystal switches when they raise while under him
const int CRYSTALSWITCH_RESET_ON_F6 = 1; //If 1, switch states will reset to their defaults when F6 is pressed. Else they'll only be set when the save file is first loaded.
const int CRYSTALSWITCH_USE_BLANK_TRIGGER = 1; //If 1, the switch uses color neutral tiles when there's more than two possible color states
const int CRYSTALSWITCH_USE_FFC_GRAPHICS = 0; //If 1, the switch graphics are set to the FFC instead of the combo beneath it
const int CRYSTALSWITCH_RAISELINK = 5; //If >1 Link will be pushed up that many pixels with the block

const int CRYSTALSWITCH_NUM_COLORS = 8; //How many colors of switches are enabled
const int CRYSTALSWITCH_RISINGCOMBOS = 4; //How many combos are used in the switch rising animation
const int CRYSTALSWITCH_RISINGASPEED = 4; //A.Speed for the rising animation

const int CMB_CRYSTALSWITCH_BLOCKS = 1024; //SET TO: The first of the combos for your first set of raising/lowering blocks
const int CMB_CRYSTALSWITCH_TRIGGERS = 1088; //SET TO: The first of the combos for crystal switch triggers
const int CMB_CRYSTALSWITCH_STATICBLOCKS = 1112; //SET TO: The first of the combos for static (gray) blocks that you can walk over from 

const int CRYSTALSWITCH_OFFSET = 0; //How spaced apart switch combos are in the combo table. If 0, this is calculated automatically.

const int SFX_CRYSTALSWITCH_TRIGGER = 6; //Sound when the Crystal Switch is hit

//Array indices. Don't change.
const int CRSW_FIRSTLOAD = 0;
const int CRSW_ANIM = 1;
const int CRSW_LINKONRAISED = 2;
const int CRSW_LASTDMAP = 3;
const int CRSW_LASTSCREEN = 4;
const int CRSW_JUMPOFF = 5;
const int CRSW_STATICBLOCKANIM = 6;
const int CRSW_LSTATES = 10;
const int CRSW_SCRNDAT = 522;
int CrystalSwitch[698];

void CrystalSwitch_Init(){
	CrystalSwitch[CRSW_ANIM] = 0;
	CrystalSwitch[CRSW_LINKONRAISED] = 0;
	CrystalSwitch[CRSW_JUMPOFF] = 0;
	CrystalSwitch[CRSW_STATICBLOCKANIM] = 0;
	
	int ss[512];
	for(int i=0; i<512; i++)ss[i] = 10101010b; //Crystal switches default to every other color being raised
	
	//%FINDME CrystalSwitch Init States
	//Define special starting states for the levels in your quest here.
	//True = Raised. False = Lowered.
	//                 ss, Level, Color1, Color2, Color3, Color4, Color5, Color6, Color7, Color8
	//CS_StartingState(ss, 1,     true,   false,  true,   true,   false,  true,   true,   true);
	
	//Set switch array for the first time the quest is loaded
	if(CrystalSwitch[CRSW_FIRSTLOAD]==0 || CRYSTALSWITCH_RESET_ON_F6){
		for(int i=0; i<512; i++){
			CrystalSwitch[CRSW_LSTATES+i] = ss[i];
		}
		CrystalSwitch[CRSW_FIRSTLOAD] = 1;
	}
}

void CS_StartingState(int startingStates, int levelNum, bool s1up, bool s2up, bool s3up, bool s4up, bool s5up, bool s6up, bool s7up, bool s8up){
	startingStates[levelNum] = 0;
	
	if(s1up)
		startingStates[levelNum] |= 1;
	if(s2up)
		startingStates[levelNum] |= 1<<1;
	if(s3up)
		startingStates[levelNum] |= 1<<2;
	if(s4up)
		startingStates[levelNum] |= 1<<3;
	if(s5up)
		startingStates[levelNum] |= 1<<4;
	if(s6up)
		startingStates[levelNum] |= 1<<5;
	if(s7up)
		startingStates[levelNum] |= 1<<6;
	if(s8up)
		startingStates[levelNum] |= 1<<7;
}
void CS_StartingState(int startingStates, int levelNum, bool s1up, bool s2up, bool s3up, bool s4up, bool s5up, bool s6up, bool s7up){
	startingStates[levelNum] = 0;
	
	if(s1up)
		startingStates[levelNum] |= 1;
	if(s2up)
		startingStates[levelNum] |= 1<<1;
	if(s3up)
		startingStates[levelNum] |= 1<<2;
	if(s4up)
		startingStates[levelNum] |= 1<<3;
	if(s5up)
		startingStates[levelNum] |= 1<<4;
	if(s6up)
		startingStates[levelNum] |= 1<<5;
	if(s7up)
		startingStates[levelNum] |= 1<<6;
}
void CS_StartingState(int startingStates, int levelNum, bool s1up, bool s2up, bool s3up, bool s4up, bool s5up, bool s6up){
	startingStates[levelNum] = 0;
	
	if(s1up)
		startingStates[levelNum] |= 1;
	if(s2up)
		startingStates[levelNum] |= 1<<1;
	if(s3up)
		startingStates[levelNum] |= 1<<2;
	if(s4up)
		startingStates[levelNum] |= 1<<3;
	if(s5up)
		startingStates[levelNum] |= 1<<4;
	if(s6up)
		startingStates[levelNum] |= 1<<5;
}
void CS_StartingState(int startingStates, int levelNum, bool s1up, bool s2up, bool s3up, bool s4up, bool s5up){
	startingStates[levelNum] = 0;
	
	if(s1up)
		startingStates[levelNum] |= 1;
	if(s2up)
		startingStates[levelNum] |= 1<<1;
	if(s3up)
		startingStates[levelNum] |= 1<<2;
	if(s4up)
		startingStates[levelNum] |= 1<<3;
	if(s5up)
		startingStates[levelNum] |= 1<<4;
}
void CS_StartingState(int startingStates, int levelNum, bool s1up, bool s2up, bool s3up, bool s4up){
	startingStates[levelNum] = 0;
	
	if(s1up)
		startingStates[levelNum] |= 1;
	if(s2up)
		startingStates[levelNum] |= 1<<1;
	if(s3up)
		startingStates[levelNum] |= 1<<2;
	if(s4up)
		startingStates[levelNum] |= 1<<3;
}
void CS_StartingState(int startingStates, int levelNum, bool s1up, bool s2up, bool s3up){
	startingStates[levelNum] = 0;
	
	if(s1up)
		startingStates[levelNum] |= 1;
	if(s2up)
		startingStates[levelNum] |= 1<<1;
	if(s3up)
		startingStates[levelNum] |= 1<<2;
}
void CS_StartingState(int startingStates, int levelNum, bool s1up, bool s2up){
	startingStates[levelNum] = 0;
	
	if(s1up)
		startingStates[levelNum] |= 1;
	if(s2up)
		startingStates[levelNum] |= 1<<1;
}

void CrystalSwitch_Update(){
	int i; int j; int k;
	if(Link->Action==LA_SCROLLING){
		//Wipe static block data when scrolling
		for(int i=0; i<176; i++){
			CrystalSwitch[CRSW_SCRNDAT+i] = 0;
		}
	}
	int swCMBOffset;
	if(CRYSTALSWITCH_OFFSET)
		swCMBOffset = CRYSTALSWITCH_OFFSET;
	else
		swCMBOffset = Ceiling((2+CRYSTALSWITCH_RISINGCOMBOS)*0.25)*4;
	int lv = Game->GetCurLevel();
	//TraceBint(6, 0, 0, CrystalSwitch[CRSW_LSTATES+lv]);
	int linkColl = CrystalSwitch_OnRaised(true);
	for(i=0; i<176; i++){
		int cd = Screen->ComboD[i];
		for(j=0; j<CRYSTALSWITCH_NUM_COLORS; j++){
			//Check if each combo is one of the switch combos
			if(cd>=CMB_CRYSTALSWITCH_BLOCKS+swCMBOffset*j&&cd<CMB_CRYSTALSWITCH_BLOCKS+swCMBOffset*j+2+CRYSTALSWITCH_RISINGCOMBOS){
				//Up/Down state of blocks
				int swst = ((CrystalSwitch[CRSW_LSTATES+lv]&(1<<j)))>>j;
				bool animating;
				//Whether blocks are animating
				if(CrystalSwitch[CRSW_ANIM]>0&&CrystalSwitch[CRSW_LSTATES+lv]&(1<<(j+8)))
					animating = true;
				
				//Place the combo based on raising/lowering animation
				if(animating){
					int aframe = Clamp(Floor(CrystalSwitch[CRSW_ANIM]/CRYSTALSWITCH_RISINGASPEED), 0, CRYSTALSWITCH_RISINGCOMBOS-1);
					if(swst){
						aframe = CRYSTALSWITCH_RISINGCOMBOS-1-aframe;
					}
					Screen->ComboD[i] = CMB_CRYSTALSWITCH_BLOCKS+j*swCMBOffset+1+aframe;
				}
				else{
					//Place the raised combo
					if(swst){
						Screen->ComboD[i] = CMB_CRYSTALSWITCH_BLOCKS+j*swCMBOffset+1+CRYSTALSWITCH_RISINGCOMBOS;
					}
					//Place the lowered combo
					else{
						Screen->ComboD[i] = CMB_CRYSTALSWITCH_BLOCKS+j*swCMBOffset;
					}
				}
				
				//If Link can walk on combos, alter the solidity based on that
				if(CRYSTALSWITCH_CAN_WALK_ON_TOP){
					if((!swst&&!animating)||CrystalSwitch[CRSW_LINKONRAISED])
						Screen->ComboS[i] = 0000b;
					else
						Screen->ComboS[i] = 1111b;
				}
			}
		}
		if(cd>=CMB_CRYSTALSWITCH_STATICBLOCKS&&cd<CMB_CRYSTALSWITCH_STATICBLOCKS+2+CRYSTALSWITCH_RISINGCOMBOS){
			int cd2 = cd-CMB_CRYSTALSWITCH_STATICBLOCKS;
			k = (CrystalSwitch[CRSW_SCRNDAT+i]&(0xFF<<8))>>8; //Left 8 bits: Timer. 
			
			if(CRYSTALSWITCH_CAN_WALK_ON_TOP){
				if(linkColl&(1<<9))
					CrystalSwitch[CRSW_LINKONRAISED] = 1;
			}
			
			if(k>0){
				k--;
				if(k==0){
					//Moving Down
					if(CrystalSwitch[CRSW_SCRNDAT+i]&1){
						Screen->ComboD[i] = Clamp(Screen->ComboD[i]-1, CMB_CRYSTALSWITCH_STATICBLOCKS, CMB_CRYSTALSWITCH_STATICBLOCKS+2+CRYSTALSWITCH_RISINGCOMBOS-1);
						if(Screen->ComboD[i]==CMB_CRYSTALSWITCH_STATICBLOCKS){
							k = -1; //Done animating
						}
					}
					//Moving Up
					else{
						Screen->ComboD[i] = Clamp(Screen->ComboD[i]+1, CMB_CRYSTALSWITCH_STATICBLOCKS, CMB_CRYSTALSWITCH_STATICBLOCKS+2+CRYSTALSWITCH_RISINGCOMBOS-1);
						if(Screen->ComboD[i]==CMB_CRYSTALSWITCH_STATICBLOCKS+2+CRYSTALSWITCH_RISINGCOMBOS-1){
							k = -1; //Done animating
						}
					}
					
					if(k==-1){
						k = 0;
					}
					else{
						k = CRYSTALSWITCH_RISINGASPEED;
					}
				}
				CrystalSwitch[CRSW_SCRNDAT+i] &= 0xFF;
				CrystalSwitch[CRSW_SCRNDAT+i] |= k<<8;
			}
			else{
				if(cd2==0){
					CrystalSwitch[CRSW_SCRNDAT+i] &= ~1;
				}
				else if(cd2==2+CRYSTALSWITCH_RISINGCOMBOS-1){
					CrystalSwitch[CRSW_SCRNDAT+i] |= 1;
				}
				else{
					//Moving Down
					if(CrystalSwitch[CRSW_SCRNDAT+i]&1){
						CrystalSwitch[CRSW_SCRNDAT+i] = 1;
						CrystalSwitch[CRSW_SCRNDAT+i] |= CRYSTALSWITCH_RISINGASPEED<<8;
					}
					//Moving Up
					else{
						CrystalSwitch[CRSW_SCRNDAT+i] = 0;
						CrystalSwitch[CRSW_SCRNDAT+i] |= CRYSTALSWITCH_RISINGASPEED<<8;
					}
				}
			}
			
			//If Link can walk on combos, alter the solidity based on that
			if(CRYSTALSWITCH_CAN_WALK_ON_TOP){
				if(linkColl&(1<<9))
					CrystalSwitch[CRSW_LINKONRAISED] = 1;
				if(cd2==0||CrystalSwitch[CRSW_LINKONRAISED])
					Screen->ComboS[i] = 0000b;
				else
					Screen->ComboS[i] = 1111b;
			}
		}
	}
	
	if(CRYSTALSWITCH_CAN_WALK_ON_TOP){
		if(Link->Action!=LA_SCROLLING&&!IsSideview()){
			//When entering a screen on a raised block
			if(Game->GetCurDMap()!=CrystalSwitch[CRSW_LASTDMAP]||Game->GetCurDMapScreen()!=CrystalSwitch[CRSW_LASTSCREEN]){
				if(CrystalSwitch_OnRaised(true)){
					CrystalSwitch[CRSW_LINKONRAISED] = 1;
				}
				CrystalSwitch[CRSW_LASTDMAP] = Game->GetCurDMap();
				CrystalSwitch[CRSW_LASTSCREEN] = Game->GetCurDMapScreen();
			}
			//Else detect Link stepping off a block
			else if(CrystalSwitch[CRSW_LINKONRAISED]){
				if(Link->Z==0&&Link->Action!=LA_FROZEN&&!CrystalSwitch_OnRaised(true)){
					Game->PlaySound(SFX_JUMP);
					Link->Jump = 1;
					Link->Z = 4;
					CrystalSwitch[CRSW_JUMPOFF] = 1;
					CrystalSwitch[CRSW_LINKONRAISED] = 0;
				}
				//If he's not stepping off but the block is animating, move him with it
				else if(CRYSTALSWITCH_RAISELINK){
					if(CrystalSwitch[CRSW_ANIM]>0&&!IsSideview()){
						linkColl = CrystalSwitch_OnRaised(false);
						int movement = -1;
						//Find the sum of movement up/down of the blocks Link is standing on
						for(j=0; j<CRYSTALSWITCH_NUM_COLORS; j++){
							//Check if Link is touching the block
							if(linkColl&(1<<j)){
								//Raised block
								if(CrystalSwitch[CRSW_LSTATES+Game->GetCurLevel()]&(1<<j)){
									//Is it currently animating?
									if(CrystalSwitch[CRSW_LSTATES+Game->GetCurLevel()]&(1<<(j+8))){
										if(movement==-1)
											movement = 2;
										//Cancel out conflicting movements
										else if(movement==1)
											movement = 0;
									}
									//Link is on an unmoving raised block and cannot be affected by others
									else{
										movement = 0;
									}
								}
								//Lowered block
								else{
									//Is it currently animating?
									if(CrystalSwitch[CRSW_LSTATES+Game->GetCurLevel()]&(1<<(j+8))){
										if(movement==-1)
											movement = 1;
										//Cancel out conflicting movements
										else if(movement==2)
											movement = 0;
									}
								}
							}
						}
						if(movement==-1)
							movement = 0;
						if(movement>0){
							j = CrystalSwitch[CRSW_ANIM]/(CRYSTALSWITCH_RISINGASPEED*CRYSTALSWITCH_RISINGCOMBOS)*CRYSTALSWITCH_RAISELINK;
							k = Min(CrystalSwitch[CRSW_ANIM]+1, (CRYSTALSWITCH_RISINGASPEED*CRYSTALSWITCH_RISINGCOMBOS))/(CRYSTALSWITCH_RISINGASPEED*CRYSTALSWITCH_RISINGCOMBOS)*CRYSTALSWITCH_RAISELINK;
							
							j = Abs(Round(j)-Round(k));
							for(i=0; i<j; i++){
								if(movement==2){
									if(CanWalk(Link->X, Link->Y, DIR_UP, 1, false)){
										Link->Y--;
										if(!CrystalSwitch_OnRaised(true))
											Link->Y++;
									}
								}
								else{
									if(CanWalk(Link->X, Link->Y, DIR_DOWN, 1, false)){
										Link->Y++;
										if(!CrystalSwitch_OnRaised(true))
											Link->Y--;
									}
								}
							}
						}
					}
				}
			}
		}
		else
			CrystalSwitch[CRSW_LINKONRAISED] = 0;
	}
	
	//Prevent movement while jumping off a block
	if(CrystalSwitch[CRSW_JUMPOFF]){
		if(Link->Z>0)
			NoAction();
		else
			CrystalSwitch[CRSW_JUMPOFF] = 0;
	}
	
	if(CrystalSwitch[CRSW_ANIM]>0)
		CrystalSwitch[CRSW_ANIM]--;
	else{
		CrystalSwitch[CRSW_LSTATES+Game->GetCurLevel()] &= 0xFF;
	}
}

//Return sum of all bits for blocks Link is standing on
int CrystalSwitch_OnRaised(bool onlyRaised){
	int swCMBOffset;
	if(CRYSTALSWITCH_OFFSET)
		swCMBOffset = CRYSTALSWITCH_OFFSET;
	else
		swCMBOffset = Ceiling((2+CRYSTALSWITCH_RISINGCOMBOS)*0.25)*4;
	int ret;
	bool blockLowering;
	for(int x=0; x<2; x++){
		for(int y=0; y<2; y++){
			int cd = Screen->ComboD[ComboAt(Link->X+2+x*12, Link->Y+10+y*4)];
			//Check if Link is on colored blocks
			for(int j=0; j<CRYSTALSWITCH_NUM_COLORS; j++){
				if(cd>=CMB_CRYSTALSWITCH_BLOCKS+swCMBOffset*j&&cd<CMB_CRYSTALSWITCH_BLOCKS+swCMBOffset*j+2+CRYSTALSWITCH_RISINGCOMBOS){
					if(onlyRaised){
						int lstate = CrystalSwitch[CRSW_LSTATES+Game->GetCurLevel()];
						//Animated combos
						if(lstate&(1<<(j+8))){
							//Lowered, raising
							if(lstate&(1<<j)){
								ret |= (1<<j);
							}
							//Raised, lowering, last frame
							else if(CrystalSwitch[CRSW_LINKONRAISED]&&CrystalSwitch[CRSW_ANIM]==1){
								blockLowering = true;
							}
							else{
								ret |= (1<<j);
							}
								
						}
						else if(lstate&(1<<j)){
							ret |= (1<<j);
						}
					}
					else{
						ret |= (1<<j);
					}
				}
			}
			//Check if Link is on gray blocks
			if(cd>=CMB_CRYSTALSWITCH_STATICBLOCKS&&cd<CMB_CRYSTALSWITCH_STATICBLOCKS+2+CRYSTALSWITCH_RISINGCOMBOS){
				int cd2 = cd-CMB_CRYSTALSWITCH_STATICBLOCKS;
				if(onlyRaised){
					if(cd2==0){
						//blockLowering = true;
					}
					else{
						ret |= 1<<9;
					}
				}
				else{
					ret |= (1<<9);
				}
			}
		}
	}
	
	//Unset on block variable if Link is standing on a block during its last lowering frame
	if(ret==0&&blockLowering){
		CrystalSwitch[CRSW_LINKONRAISED] = 0;
		return 1<<15; //Return a value just to prevent the hopping code from running. 
	}
	return ret;
}

//D0-D3: Switch colors (1-8) to toggle. 0 for none.
//D6: If >0, forces the switch to use a custom pair of combos. Based on the state of D0. Raised combo, followed by lowered.
//D7: Special behaviors
//		0 - Standard operations. D0-D4 toggle between lowered and raised.
//		1 - Lower D0, raise all others
//		2 - Cycle between lowered color, raise all others
ffc script CrystalSwitch_Trigger{
	void run(int toggleA, int toggleB, int toggleC, int toggleD, int d4, int d5, int forceCombo, int specialBehavior){
		if(toggleA==toggleB){
			if(toggleA==0&&toggleB==0){
				toggleA = 1;
				toggleB = 2;
			}
			else
				toggleB = toggleA+1;
		}
		if(toggleA>0)
			toggleA = Clamp(toggleA-1, 0, CRYSTALSWITCH_NUM_COLORS-1);
		else
			toggleA = -1;
		if(toggleB>0)
			toggleB = Clamp(toggleB-1, 0, CRYSTALSWITCH_NUM_COLORS-1);
		else
			toggleB = -1;
		if(toggleC>0)
			toggleC = Clamp(toggleC-1, 0, CRYSTALSWITCH_NUM_COLORS-1);
		else
			toggleC = -1;
		if(toggleD>0)
			toggleD = Clamp(toggleD-1, 0, CRYSTALSWITCH_NUM_COLORS-1);
		else
			toggleD = -1;
		
		int toggleCount;
		if(toggleA>-1)
			toggleCount++;
		if(toggleB>-1)
			toggleCount++;
		if(toggleC>-1)
			toggleCount++;
		if(toggleD>-1)
			toggleCount++;
		
		
		int pos = ComboAt(this->X+8, this->Y+8);
		this->X = ComboX(pos);
		this->Y = ComboY(pos);
		
		lweapon lastTrigger[1];
		this->Data = 0;
		
		int strikeCooldown;
		while(true){
			int lstate = CrystalSwitch[CRSW_LSTATES+Game->GetCurLevel()];
			
			int loweredState = -1;
			//Find the first state that's lowered
			if(loweredState==-1){
				if(!(lstate&(1<<toggleA)))
					loweredState = toggleA;
			}
			if(loweredState==-1){
				if(!(lstate&(1<<toggleB)))
					loweredState = toggleB;
			}
			if(loweredState==-1){
				if(!(lstate&(1<<toggleC)))
					loweredState = toggleC;
			}
			if(loweredState==-1){
				if(!(lstate&(1<<toggleD)))
					loweredState = toggleD;
			}
			
			bool canHit = true;
			//In Special Behavior 1: The switch cannot be hit if A is already lowered
			if(specialBehavior==1&&!(lstate&(1<<toggleA)))
				canHit = false;
			if(CrystalSwitch_CheckCollision(this, lastTrigger)){
				if(strikeCooldown==0&&canHit&&CrystalSwitch[CRSW_ANIM]==0){
					Game->PlaySound(SFX_CRYSTALSWITCH_TRIGGER);
					
					int linkColl = CrystalSwitch_OnRaised(false)&0xFF; //Function returns sum of all bits for blocks Link is on
					
					int newState = 0; //Flag which block states are being changed
					int newStateMask = 0; //Mask used for combining new states with the existing level states
					
					//Raise all, lower A
					if(specialBehavior==1){
						newStateMask |= 1<<toggleA;
						if(toggleB>-1){
							newState |= 1<<toggleB;
							newStateMask |= 1<<toggleB;
						}
						if(toggleC>-1){
							newState |= 1<<toggleC;
							newStateMask |= 1<<toggleC;
						}
						if(toggleD>-1){
							newState |= 1<<toggleD;
							newStateMask |= 1<<toggleD;
						}
					}
					//Alternate A-D lowered
					else if(specialBehavior==2){
						int nextState = toggleA;
						if(loweredState==toggleA){
							if(toggleB>-1)
								nextState = toggleB;
							else if(toggleC>-1)
								nextState = toggleC;
							else if(toggleD>-1)
								nextState = toggleD;
						}
						if(loweredState==toggleB){
							if(toggleC>-1)
								nextState = toggleC;
							else if(toggleD>-1)
								nextState = toggleD;
							else if(toggleA>-1)
								nextState = toggleA;
						}
						if(loweredState==toggleC){
							if(toggleD>-1)
								nextState = toggleD;
							else if(toggleA>-1)
								nextState = toggleA;
							else if(toggleB>-1)
								nextState = toggleB;
						}
						if(loweredState==toggleD){
							if(toggleA>-1)
								nextState = toggleA;
							else if(toggleB>-1)
								nextState = toggleB;
							else if(toggleC>-1)
								nextState = toggleC;
						}
						
						if(toggleA>-1){
							newState |= 1<<toggleA;
							newStateMask |= 1<<toggleA;
						}
						if(toggleB>-1){
							newState |= 1<<toggleB;
							newStateMask |= 1<<toggleB;
						}
						if(toggleC>-1){
							newState |= 1<<toggleC;
							newStateMask |= 1<<toggleC;
						}
						if(toggleD>-1){
							newState |= 1<<toggleD;
							newStateMask |= 1<<toggleD;
						}
						
						newState &= ~(1<<nextState);
					}
					//Toggle all
					else{
						if(toggleA>-1){
							if(!(lstate&(1<<toggleA)))
								newState |= 1<<toggleA;
							newStateMask |= 1<<toggleA;
						}
						if(toggleB>-1){
							if(!(lstate&(1<<toggleB)))
								newState |= 1<<toggleB;
							newStateMask |= 1<<toggleB;
						}
						if(toggleC>-1){
							if(!(lstate&(1<<toggleC)))
								newState |= 1<<toggleC;
							newStateMask |= 1<<toggleC;
						}
						if(toggleD>-1){
							if(!(lstate&(1<<toggleD)))
								newState |= 1<<toggleD;
							newStateMask |= 1<<toggleD;
						}
					}
					
					if(CRYSTALSWITCH_CAN_WALK_ON_TOP){
						if(!IsSideview()&&(linkColl&newState)){
							CrystalSwitch[CRSW_LINKONRAISED] = 1;
						}
					}
					
					int astate = (((lstate&0xFF)^newState)&newStateMask)<<8; //Find bits that have changed to determine which combos should animate
					
					lstate &= ~newStateMask; //Unset bits affected by new state
					lstate |= newState; //Combine new state with the current one
					
					lstate &= 0xFF; //Clear old animation data
					lstate |= astate; //Set new animation bits
					
					CrystalSwitch[CRSW_LSTATES+Game->GetCurLevel()] = lstate;
					
					CrystalSwitch[CRSW_ANIM] = CRYSTALSWITCH_RISINGCOMBOS*CRYSTALSWITCH_RISINGASPEED;
					strikeCooldown = 20;
				}
			}
			
			int switchColor = 0;
			if(loweredState>-1)
				switchColor = 4+loweredState*2;
			if(specialBehavior==1){
				if(lstate&(1<<toggleA))
					switchColor = 4+toggleA*2;
				else
					switchColor = 4+toggleA*2+1;
			}
			if(toggleCount>2){
				if(specialBehavior==0&&CRYSTALSWITCH_USE_BLANK_TRIGGER){
					if(lstate&(1<<toggleA))
						switchColor = 1;
					else
						switchColor = 0;
				} 
			}
			
			int switchCMB = CMB_CRYSTALSWITCH_TRIGGERS+switchColor;
			if(forceCombo){
				if(lstate&(1<<toggleA))
					switchCMB = forceCombo+1;
				else
					switchCMB = forceCombo;
			}
			
			if(CRYSTALSWITCH_USE_FFC_GRAPHICS)
				this->Data = switchCMB;
			else
				Screen->ComboD[pos] = switchCMB;
			
			if(strikeCooldown>0)
				strikeCooldown--;
			Waitframe();
		}
	}
	bool CrystalSwitch_CheckCollision(ffc this, lweapon lastTrigger){
		bool excludedTypes[41];
		//Define all weapon types that can't hit the switch here
		excludedTypes[LW_CANEOFBYRNA] = true;
		excludedTypes[LW_BOMB] = true;
		excludedTypes[LW_SBOMB] = true;
		excludedTypes[LW_FIRE] = true;
		excludedTypes[LW_WHISTLE] = true;
		excludedTypes[LW_BAIT] = true;
		excludedTypes[LW_MAGIC] = true;
		excludedTypes[LW_WIND] = true;
		excludedTypes[LW_REFMAGIC] = true;
		excludedTypes[LW_REFFIREBALL] = true;
		excludedTypes[LW_SPARKLE] = true;
		excludedTypes[LW_FIRESPARKLE] = true;
		
		for(int i=Screen->NumLWeapons(); i>=1; i--){
			lweapon l = Screen->LoadLWeapon(i);
			if(l!=lastTrigger[0]){
				if(!excludedTypes[l->ID]&&l->CollDetection&&l->DeadState==WDS_ALIVE){
					if(Collision(this, l)){
						lastTrigger[0] = l;
						if(l->ID==LW_BRANG||l->ID==LW_HOOKSHOT)
							l->DeadState = WDS_BOUNCE;
						else if(l->ID==LW_ARROW)
							l->DeadState = WDS_ARROW;
						else if(l->ID==LW_BEAM)
							l->DeadState = WDS_BEAMSHARDS;
						else if(l->ID==LW_MAGIC||l->ID==LW_REFMAGIC||l->ID==LW_REFROCK||l->ID==LW_REFFIREBALL)
							l->DeadState = 0;
						return true;
					}
				}
			}
		}
	}
}

global script CrystalSwitch_Example{
	void run(){
		CrystalSwitch_Init();
		while(true){
			CrystalSwitch_Update();
			Waitdraw();
			Waitframe();
		}
	}
}