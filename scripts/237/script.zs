/////////////////////////////
///  SwitchHook v0.3.9.1  ///
///     By: ZoriaRPG      ///
///     05-July-2016      ///
///   PureZC DB Edition   ///
/////////////////////////////
// Testing & Contributions://
//         Evan            //
//        TeamUDF          //
//TheBlueTophat (coolgamer)//
//         ywkls           //
/////////////////////////////
//   stdCombos Functions:  //
//        Alucard648       //   
// ------------------------//
//      ffcscript.zh:      //
//         Saffith         //
/////////////////////////////

//Import the basic header if needed.
//import "std.zh"

//and import the required header support files, if needed.

//import "ffcscript.zh"


//Constants and Settings

//Pickup Message
const int MSG_SWITCHSHOT_PICKUP = 1;

//! Boolean Toggle Settings: These control how the item works. 
//! Enable them by setting them to '1' or above, and disable them by setting them tro '0'. 

//Settings for Combos on Layers

const int SWITCHHOOK_USE_LAYER_0 = 0; //Enable to allow combos on Layer 0.
const int SWITCHHOOK_USE_LAYER_1 = 0; //Enable to allow combos on Layer 1.
const int SWITCHHOOK_USE_LAYER_2 = 1; //Enable to allow combos on Layer 2.

//These next three settings are INCOMPLETE. DO NOT use, or use AT YOUR OWN RISK. 
const int ALWAYS_USE_SPECIFIC_COMBO_LAYER_0 = 0; //Enable this to use a specific combo to replace where a switchhook target WAS on Layer 0.
const int ALWAYS_USE_SPECIFIC_COMBO_LAYER_1 = 0; //Enable this to use a specific combo to replace where a switchhook target WAS on Layer 0.
const int ALWAYS_USE_SPECIFIC_COMBO_LAYER_2 = 0; //Enable this to use a specific combo to replace where a switchhook target WAS on Layer 0.

//Enemy Handling Settings

const int SWITCHHOOK_ENEMIES_REQUIRE_SPECIAL_DEFS = 1; 	//Set this to '1' to ensure that only enemies with a specific defence 
							//setting for NPCD_HOOKSHOT will be affected by the switchshot...
							//
							//Setting this to '0' will cause all enemies to be affected by the 
							//switchshot's ability to move objects!
							
const int SWITCHHOOK_JANKED_ENEMIES = 0; //If enabled, the switchhook will not die when it hits an enemy. 
							
const int SUPPORT_GHOSTED_ENEMIES = 1; //if enabled, the ffc for a ghosted enemy will move with the enemy. 
const int __GHI_GHZH_DATA_INDEX = 15; //THe standard index use dby __GHI_GHZH_DATA is 15. Set this to the same value that you use in ghost.zh
	//!We need a constant here, in the event that the user does not use ghost.zh, as just calling its constant would cause a compilation error, in that event. 
	

//Variable Settings: These change operational factors for the item. Set their value directly. 

const int CF_SWITCHHOOK = 98; 	//The *inherent* combo flag default for SwitchHook Targets. Default is ( 98 ) ( Script 1 ).
				
const int SFX_SWITCHHOOK = 76; //The default, or fallback sound effect to play, set in Quest->Audio->SFX Data

const int CMB_SWITCHHOOK_UNDERCOMBO_D_LAYER_0 = 0;	//Set to a combo to appear where switchhook targets WERE, when moved on LAYER 0. 
const int CMB_SWITCHHOOK_UNDERCOMBO_S_LAYER_0 = 0;	//Set to the solidity for that combo.
const int CMB_SWITCHHOOK_UNDERCOMBO_C_LAYER_0 = 0;	//Set to the CSet ID for that combo. The default for ALL of these, is '0'.
							//This only works, if the option ALWAYS_USE_SPECIFIC_COMBO_* is enabled. 
						
const int CMB_SWITCHHOOK_UNDERCOMBO_D_LAYER_1 = 0;	//Set to a combo to appear where switchhook targets WERE, when moved on LAYER 1. 
const int CMB_SWITCHHOOK_UNDERCOMBO_S_LAYER_1 = 0;	//Set to the solidity for that combo. 
const int CMB_SWITCHHOOK_UNDERCOMBO_C_LAYER_1 = 0;	//Set to the CSet ID for that combo. The default for ALL of these, is '0'.
							//This only works, if the option ALWAYS_USE_SPECIFIC_COMBO_* is enabled.
							
const int CMB_SWITCHHOOK_UNDERCOMBO_D_LAYER_2 = 0;	//Set to a combo to appear where switchhook targets WERE, when moved on LAYER 2. 
const int CMB_SWITCHHOOK_UNDERCOMBO_S_LAYER_2 = 0;	//Set to the solidity for that combo. 
const int CMB_SWITCHHOOK_UNDERCOMBO_C_LAYER_2 = 0;	//Set to the CSet ID for that combo. The default for ALL of these, is '0'.
							//This only works, if the option ALWAYS_USE_SPECIFIC_COMBO_* is enabled.

const int FFC_SWITCHSHOT_QUIT_COUNTER = 360; 	//The number of frames a switchshot ffc will continue
						//to run, if there are no hookshot weapons on the screen.
						//This is a safegaurd, to keep the FFC Slot *free* when not in use. 


							
const int NPCDT_SWITCHHOOK = 13; 	//If no value is assigned to the item arg D3, we use this value to set the special defence flag
					//needed for the enemy to be affected by the switchshot. Default: 13 (NPCDT_IGNORE) (Ignore)
					//This allows us to tailor enemies so that they are affected as normal by a hookshot, or are swapped 
					//with Link, or to create switchshot-specific enemies. 
					



// This FFC Script powers the action of the item, and is run from the item script via the ffcscript.zh FFC launcher. 
// Do not apply it in use directly on an screen FFC (i.e. do not assign it as the script on an ffc) as this may cause unexpected, 
// and undesirable behaviour. 

// It runs automatically from the item.

ffc script SwitchHook{
	void run(int comboF, int affectEnemies, int sfx, int npcdt){
		
		//Initial script variables.
		
		int quitCounter; //A countwer to use to end the script prematurely. 
		int layer; //We'll need this to do collision on layers other than 0.
		
		//if ( comboF == 0 ) comboF = CF_SWITCHHOOK; //We no longer need this, but we'll retain it (commented out) for the present. 
		
		//Switchchot combo at the start of the script. 
		int cmbX; //X position.
		int cmbY; //Y position.
		int cmbD; //Combo Data
		int cmbS; //Combo Solidity
		
		//Combo where Link is standing at the start of the script.
		int cmbLX; //X position.
		int cmbLY; //Y position
		int cmbLD; //Data
		int cmbLS; //Solidity
		int cmbL; //Screen index (of 176)
		
		//Layer 1 Combos
		//int cmb1;
		int cmb1X; //X position
		int cmb1Y;
		int cmb1D;
		int cmb1S;
		int cmb1LX; //X position under Link.
		int cmb1LY; //Y position
		int cmb1LD; //Data
		int cmb1LS; //Solidity
		int cmb1L; //Screen index (of 176)
		int cmb1C; //CSet
		int cmb1LC; //Link combo CSet.
		
		//Layer 2 Combos
		int cmb2X;
		int cmb2Y;
		int cmb2D;
		int cmb2S;
		int cmb2LX; //X position.
		int cmb2LY; //Y position
		int cmb2LD; //Data
		int cmb2LS; //Solidity
		int cmb2L; //Screen index (of 176)
		int cmb2C; //CSet
		int cmb2LC; //Link combo CSet.
		
		//Link positions.
		int lx;
		int ly;
		
		//Ghjost FFC locations
		int ghost_ffc_x;
		int ghost_ffc_y;
		int ffc_id;
		
		bool switching; //Enabled if there is a matching combo.
		
		while( true ) {
			
			if ( Screen->NumLWeapons() ) { //If there are no weapons on the screen, ignore the pass. 
				//if ( NumLWeaponsOf(LW_HOOKSHOT) ) TraceS(str);
				
				for ( int q = 1; q <= Screen->NumLWeapons(); q++ ) { 	//Pass through the lweapons on the screen...
					lweapon l = Screen->LoadLWeapon(q); 		//...loading each one and...
					if ( l->ID == LW_HOOKSHOT ){			//if a hookshot lweapon is present...
				
											//Check for switchshot combos...
						
						//Parse layer 0:
						
						if ( SWITCHHOOK_USE_LAYER_0 ) {
							for ( int q = 0; q < 176; q++ ) { 	//Pass through the screen combos to find a match...
								int cmb = Screen->ComboI[q]; 	//loading them along the way...
								if ( ( comboF && cmb == comboF ) || ( !comboF && cmb == CF_SWITCHHOOK ) ) { 	
												//If D0 is assigned a value above 0, check to see if it matches
												//that combo inherent flag, otherwise check if it matches the one
												//assigned to the constant CF_SWITCHSHOT.
									
												//If it does....
									
									if ( ComboCollision(q,l) ) {	//and there is collision between that combo and the hookshot...
										
									//!We need to check every layer...too..for combos on layers higher than 0. (?)
										l->DeadState = WDS_DEAD;	//Kill the hookshot.
										
										if ( sfx ) Game->PlaySound(sfx); //Play the sound defined in the item script,
										if ( !sfx && SFX_SWITCHHOOK ) Game->PlaySound(SFX_SWITCHHOOK);  //or the constant if the item editor arg isn't set.
											
										//Store Link's starting position.
										lx = CenterLinkX();
										ly = CenterLinkY();
											
										//Store the switchshot combo to move.
										cmbX = ComboX(q);	//The combo number for the for loop pass...
										cmbY = ComboY(q);	//... X and Y
										cmbD = Screen->ComboD[q]; //The original data of the switchhook combo.
										cmbS = Screen->ComboS[q]; //The original solidity of the switchshot combo. 
										
										//Store the combo datum for the combo that Link is on. 
										
										cmbLD = Screen->ComboD[ComboAt(Link->X, Link->Y)]; //The combo under Link.
										cmbLS = Screen->ComboS[ComboAt(Link->X, Link->Y)]; //The solidity of the combo under Link.
										cmbLX = GridX(lx); //The X position
										cmbLY = GridY(ly); //The Y position
										cmbL = ComboAt(cmbLX,cmbLY); //The screen index for that combo (Nth of 176).
											
											
										//Change the combo where Link WAS, to the switchshot combo.
										Screen->ComboD[cmbL] = cmbD; //Set its data
										Screen->ComboS[cmbL] = cmbS; //and solidity.
										
										
										//Move Link to where the old switchshot combo that we moved, WAS.
										Link->X = cmbX;
										Link->Y = cmbY;
										
											
										//Change the combo where Link appears, to what he was on BEFORE moving
										
										if ( ALWAYS_USE_SPECIFIC_COMBO_LAYER_0 ) { 	//If we are using a predefined combo...
																//as set in user prefs. 
											Screen->ComboD[q] = CMB_SWITCHHOOK_UNDERCOMBO_D_LAYER_0; //Set its data
											Screen->ComboS[q] = CMB_SWITCHHOOK_UNDERCOMBO_S_LAYER_0; //and solidity.
										}
										
										else {	//Use the actual combo, from the screen (default behaviour). 
											Screen->ComboD[q] = cmbLD; //Set its data
											Screen->ComboS[q] = cmbLS; //and solidity.
										}
										
										this->Script = 0; //Free the FFC for later use.
										this->Data = 0;
										Quit();
									}
								}
							}
						}
							
						//Parse Layer 1
						
						if ( SWITCHHOOK_USE_LAYER_1 ) {
							for ( int q = 0; q < 176; q++ ) { 	//Pass through the screen combos to find a match...
								int cmb1 = GetLayerComboI(1,q); 	//loading them along the way...
								if ( ( comboF && cmb1 == comboF ) || ( !comboF && cmb1 == CF_SWITCHHOOK ) ) { 	
												//If D0 is assigned a value above 0, check to see if it matches
												//that combo inherent flag, otherwise check if it matches the one
												//assigned to the constant CF_SWITCHSHOT.
									
												//If it does....
									
									if ( ComboCollision(q,l) ) {	//and there is collision between that combo and the hookshot...
										
									//!We need to check every layer...too..for combos on layers higher than 0. (?)
										l->DeadState = WDS_DEAD;	//Kill the hookshot.
										
										if ( sfx ) Game->PlaySound(sfx); //Play the sound defined in the item script,
										if ( !sfx && SFX_SWITCHHOOK ) Game->PlaySound(SFX_SWITCHHOOK);  //or the constant if the item editor arg isn't set.
											
										//Store Link's starting position.
										lx = CenterLinkX();
										ly = CenterLinkY();
											
										//Store the switchshot combo to move.
										cmb1X = ComboX(q);	//The combo number for the for loop pass...
										cmb1Y = ComboY(q);	//... X and Y
										cmb1D = GetLayerComboD(1,q); //The original data of the switchhook combo.
										cmb1S = GetLayerComboS(1,q); //The original solidity of the switchshot combo. 
										cmb1C = GetLayerComboC(1,q); //The original CSet.
										
										//Store the combo datum for the combo that Link is on. 
										
										cmb1LD = GetLayerComboD(1,ComboAt(Link->X, Link->Y)); //The combo under Link.
										cmb1LS = GetLayerComboS(1,ComboAt(Link->X, Link->Y)); //The solidity of the combo under Link.
										cmb1LX = GridX(lx); //The X position
										cmb1LY = GridY(ly); //The Y position
										cmb1L = ComboAt(cmb1LX,cmb1LY); //The screen index for that combo (Nth of 176).
										cmb1LC = GetLayerComboC(1,ComboAt(Link->X, Link->Y));
										
											
										//Change the combo where Link WAS, to the switchshot combo.
										SetLayerComboD(1,cmb1L,cmb1D); //Set its data
										SetLayerComboS(1,cmb1L,cmb1S); //and solidity.
										SetLayerComboC(1,cmb1L,cmb1C); //and CSet.
										
										
										//Move Link to where the old switchshot combo that we moved, WAS.
										Link->X = cmb1X;
										Link->Y = cmb1Y;
										
											
										//Change the combo where Link appears, to what he was on BEFORE moving
										
										if ( ALWAYS_USE_SPECIFIC_COMBO_LAYER_1 ) { 	//If we are using a predefined combo...
																//as set in user prefs.
											
											SetLayerComboD(1,q,CMB_SWITCHHOOK_UNDERCOMBO_D_LAYER_1); //Set the combo data
											SetLayerComboS(1,q,CMB_SWITCHHOOK_UNDERCOMBO_S_LAYER_1); //and the solidity.
											SetLayerComboC(1,q,CMB_SWITCHHOOK_UNDERCOMBO_C_LAYER_1); //and CSet.
									
										}	
										
										else { 	//Use the actual combo from the screen (default behaviour)
											SetLayerComboD(1,q,cmb1LD); //Set the combo data
											SetLayerComboS(1,q,cmb1LS); //and the solidity.
											SetLayerComboC(1,q,cmb1LC); //and CSet.
										}

										
										this->Script = 0; //Free the FFC for later use.
										this->Data = 0;
										Quit();
									}
								}
							}
						}
						
						//Parse Layer 2
						
						if ( SWITCHHOOK_USE_LAYER_2 ) { //2
							for ( int q = 0; q < 176; q++ ) { 	//Pass through the screen combos to find a match...
								int cmb2 = GetLayerComboI(2,q); 	//loading them along the way...
								cmb2X = ComboX(q);	//The combo number for the for loop pass...
								cmb2Y = ComboY(q);	//... X and Y
								int loc = ComboAt(cmb2X,cmb2Y);

								if ( ( comboF && cmb2 == comboF ) || ( !comboF && cmb2 == CF_SWITCHHOOK ) ) { 	
												//If D0 is assigned a value above 0, check to see if it matches
												//that combo inherent flag, otherwise check if it matches the one
												//assigned to the constant CF_SWITCHSHOT.
									
												//If it does....
									//int cmb_under = 
									
									//if ( switching ) {
									if ( ComboCollision(loc,l) ) {	//and there is collision between that combo and the hookshot...
										
									//!We need to check every layer...too..for combos on layers higher than 0. (?)
										l->DeadState = WDS_DEAD;	//Kill the hookshot.
										
										if ( sfx ) Game->PlaySound(sfx); //Play the sound defined in the item script,
										if ( !sfx && SFX_SWITCHHOOK ) Game->PlaySound(SFX_SWITCHHOOK);  //or the constant if the item editor arg isn't set.
											
										//Store Link's starting position.
										lx = CenterLinkX();
										ly = CenterLinkY();
											
										//Store the switchshot combo to move.
										cmb2X = ComboX(q);	//The combo number for the for loop pass...
										cmb2Y = ComboY(q);	//... X and Y
										cmb2D = GetLayerComboD(2,q); //The original data of the switchhook combo.
										cmb2S = GetLayerComboS(2,q); //The original solidity of the switchshot combo. 
										cmb2C = GetLayerComboC(2,q); //The original CSet.
										
										//Store the combo datum for the combo that Link is on. 
										
										cmb2LD = GetLayerComboD(2,ComboAt(Link->X, Link->Y)); //The combo under Link.
										cmb2LS = GetLayerComboS(2,ComboAt(Link->X, Link->Y)); //The solidity of the combo under Link.
										cmb2LX = GridX(lx); //The X position
										cmb2LY = GridY(ly); //The Y position
										cmb2L = ComboAt(cmb2LX,cmb2LY); //The screen index for that combo (Nth of 276).
										cmb2LC = GetLayerComboC(2,ComboAt(Link->X, Link->Y));
										
											
										//Change the combo where Link WAS, to the switchshot combo.
										SetLayerComboD(2,cmb2L,cmb2D); //Set its data
										//SetLayerComboS(2,cmb2L,cmb2S); //and solidity.
										
										//!Setting solidity on layer 2 crashes ZC....BUT
										//!the solidity seems to be preserved anyway.
										
										SetLayerComboC(2,cmb2L,cmb2C); //and CSet.
										
										
										//Move Link to where the old switchshot combo that we moved, WAS.
										Link->X = cmb2X;
										Link->Y = cmb2Y;
										
											
										//Change the combo where Link appears, to what he was on BEFORE moving
										
										if ( ALWAYS_USE_SPECIFIC_COMBO_LAYER_2 ) { 	//If we are using a predefined combo...
																//as set in user prefs.
											
											SetLayerComboD(2,q,CMB_SWITCHHOOK_UNDERCOMBO_D_LAYER_2); //Set the combo data
											//SetLayerComboS(1,q,CMB_SWITCHHOOK_UNDERCOMBO_S_LAYER_2); //and the solidity.
											SetLayerComboC(2,q,CMB_SWITCHHOOK_UNDERCOMBO_C_LAYER_2); //and CSet.
									
										}

										else { 	//use the actual combo (default behaviour)										
											SetLayerComboD(2,q,cmb2LD); //Set the combo data
											//SetLayerComboS(2,q,cmb2LS); //and the solidity.
											SetLayerComboC(2,q,cmb2LC); //and CSet.
										}

										
										this->Script = 0; //Free the FFC for later use.
										this->Data = 0;
										Quit();
									}
								}
							}
						}
						
						//If we also switch enemies, check for those now.
			
						if ( affectEnemies && Screen->NumNPCs() ) { //If the item is allowed to switch enemies, and there are enemies on the screen...
							for ( int q = 1; q <= Screen->NumNPCs(); q++ ) {	//Parse through the enemies on the screen...
								npc n = Screen->LoadNPC(q);			//and load each...
								if ( l->ID == LW_HOOKSHOT && Collision(l,n) ) {	//...then check for collision.
									
									if ( 					//If the user option to use enemy defs to set enemies affected...
										( SWITCHHOOK_ENEMIES_REQUIRE_SPECIAL_DEFS && !npcdt && n->Defense[NPCD_HOOKSHOT] == NPCDT_SWITCHHOOK ) 
										||				//..either with a constant to define the NPCDT, or an item arg...
										( SWITCHHOOK_ENEMIES_REQUIRE_SPECIAL_DEFS && npcdt && n->Defense[NPCD_HOOKSHOT] == npcdt ) 
										||				//or all enemies are affected...
										( !SWITCHHOOK_ENEMIES_REQUIRE_SPECIAL_DEFS ) 
									) {
											//If enemies require a special NPC Defs flag, and either we're assigning one to the item via arg D3
											//or if we are using the constant NPCDT_SWITCHHOOK...
											//...or if enemies DO NOT require a special defs flag to be affected...
										
										if ( !SWITCHHOOK_JANKED_ENEMIES ) l->DeadState = WDS_DEAD;	//Kill the hookshot weapon so that the chain doesn't become a living thing...
										if ( sfx ) Game->PlaySound(sfx); //Play the sound defined in the item script,
										if ( !sfx && SFX_SWITCHHOOK ) Game->PlaySound(SFX_SWITCHHOOK);  //or the constant if the item editor arg isn't set.
										
										
										
										// Move the enemy, and Link...
										int npcX = n->X;	//Store the enemy X/Y position...	
										int npcY = n->Y;
										
										if ( SUPPORT_GHOSTED_ENEMIES ) { //If we also move the ghost ffc
											//Check for a ghost ffc where the enemy is located via collision:
											for ( int q = 1; q < 32; q++ ) {
												ffc f = Screen->LoadFFC(q);
												//if we are reasonably sure that the enemy has a ghost ffc attached to it...
												if ( Collision(n,f) && f->Script && n->Misc[__GHI_GHZH_DATA_INDEX] ) {
													ffc_id = q; //Store the ID of the ffc for this enemy. 
												}
											}
										}
										
										int lx = Link->X;	//...and Link's X/Y position.
										int ly = Link->Y;
										
										n->X = -1; 		//Move the enemy offscreen for a moment...
										n->Y = -1;		//...to prevent collision with Link.
										
										//if ghost support is enabled...
										if ( SUPPORT_GHOSTED_ENEMIES ) {
											ffc f = Screen->LoadFFC(ffc_id); //Reload the ffc
											f->X = -1; //Move the ffc offscreen to prevent collision with Link
											f->Y = -1;
										}
										
										Link->X = npcX;		//Then move Link to where the enemy WAS...
										Link->Y = npcY;
										n->X = lx; 		//and the enemy to where Link WAS.
										n->Y = ly;
										
										//if ghost support is enabled
										if ( SUPPORT_GHOSTED_ENEMIES ) { 
											ffc f = Screen->LoadFFC(ffc_id); //Find the ffc again
											f->X = lx;
											f->Y = ly;
										}
										
										
										
										this->Script = 0;	//Free the FFC by releasing the script...
										this->Data = 0;		//and combo assignment, then...
										Quit();			//terminate the FFC. 
									}
								}
							}
						}
						
					}
				}
			}
			if ( !NumLWeaponsOf(LW_HOOKSHOT) ) quitCounter++; //If there hasn;t been a hookshot on the screen this frame, bump the counter.
			if ( quitCounter >= FFC_SWITCHSHOT_QUIT_COUNTER ) break;	//and if it reaches 600, break the loop to exit the script, and free the ffc slot. 
			Waitframe();
			
			
		}
		this->Script = 0;	//If we reach this point, for any reason, free the FFC, and exit. 
		this->Data = 0;
		Quit();
	}
}

// Apply the item script to any hookshot item. Setting its power to '0' is best, to ensure it works with the enemy toggle options. 


// D0: The FFC SLot ID
// D1: The Combo Inherent Flag for the Switchshot combos. Defaults to CF_SWITCHSHOT if set to '0'.
// D2: The sound to play when switching. Defaults to SFX_SWITCHSHOT if set to '0'.
// D3: The NPCDT used to define switchshot specific enemies, or enemies affected by the switchshot's moving power. 
//     Default value: 12.
//     Note: This is only used if SWITCHHOOK_ENEMIES_REQUIRE_SPECIAL_DEFS is enabled. 

item script SwitchHookItem{
	void run(int msg, int comboF, int affectEnemies, int sfx, int npcdt) {
		int args[4]={comboF,affectEnemies,sfx,npcdt};
		int s[]="SwitchHook";
		RunFFCScript(Game->GetFFCScript(s), args);
	}
}


item script PickupSwitchShot{
	void run(int msg){
		if ( msg ) Screen->Message(msg);
		if ( !msg && MSG_SWITCHSHOT_PICKUP ) Screen->Message(MSG_SWITCHSHOT_PICKUP);
	}
}

/////////////////
/// Functions ///
///////////////////////////////////////////////////////////////////////////
/// The following are provided for the purposes of testing this script. ///
/// If you import stdCombos.zh, and are unable to use this script       ///
/// due to the version of stdCombos.zh that you are using, then         ///
/// use the ComboCOllision functions provided here.                     ///
///                                                                     ///
/// Likewise, ffcscript.zh is embedded here. Remove that if you are     ///
/// already using ffcscript.zh, or are importing it above.              ///
///                                                                     ///
/// The std.zh functions below, are needed if you are not using the     ///
/// 2.50.2 Update version of std.zh.                                    ///
//////////////////////////////////////////////////////////////////////////

//! stdCombos.zh functions

// Returns INT if FFC collides with a combo which has specific placed flag
int ComboFlagCollision (int flag, lweapon l){
	for (int i = 0; i<176; i++){
		if (Screen->ComboF[i]==flag){
			if (ComboCollision(i, l)) return i;
		}
	}
	return -1;
}

// Returns TRUE if there is a collision between the combo and an arbitrary rectangle.
bool ComboCollision (int loc, int x1, int y1, int x2, int y2){
	return RectCollision( ComboX(loc), ComboY(loc), (ComboX(loc)+16), (ComboY(loc)+16), x1, y1, x2, y2);
}


// Returns TRUE if there is a collision between Lweapon and the combo on screen.
bool ComboCollision (int loc, lweapon f){
	if (!(f->CollDetection)) return false;
	int ax = (f->X)+f->HitXOffset;
	int ay = (f->Y)+f->HitYOffset;
	int bx = ax+f->HitWidth;
	int by = ay+f->HitHeight;
	int cx = ComboX(loc);
	int cy = ComboY(loc);
	int dx = ComboX(loc)+16;
	int dy = ComboY(loc)+16;
	return RectCollision( cx, cy, dx, dy, ax, ay, bx, by);
}


//! std.zh 2.50.2 Update Functions

//A shorthand way to get a combo inherent flag on the current layer.
//Layer 0 is the screen itself.
int __GetLayerComboI(int layer, int pos) {
  if (layer==0)
    return Screen->ComboI[pos];
  else
    return Game->GetComboInherentFlag(Screen->LayerMap(layer), Screen->LayerScreen(layer), pos);
}

//A shorthand way to set a combo inherent flag on the current layer.
//Layer 0 is the screen itself.
void __SetLayerComboI(int layer, int pos, int flag) {
  if (layer == 0)
    Screen->ComboI[pos] = flag;
  else
    Game->SetComboInherentFlag(Screen->LayerMap(layer), Screen->LayerScreen(layer), pos, flag);
}


//A shorthand way to get a combo CSet on the current layer.
//Layer 0 is the screen itself.
int __GetLayerComboC(int layer, int pos) {
  if (layer==0)
    return Screen->ComboC[pos];
  else
    return Game->GetComboCSet(Screen->LayerMap(layer), Screen->LayerScreen(layer), pos);
}

//A shorthand way to set a combo CSet on the current layer.
//Layer 0 is the screen itself.
void __SetLayerComboC(int layer, int pos, int cset) {
  if (layer == 0)
    Screen->ComboC[pos] = cset;
  else
    Game->SetComboCSet(Screen->LayerMap(layer), Screen->LayerScreen(layer), pos, cset);
}