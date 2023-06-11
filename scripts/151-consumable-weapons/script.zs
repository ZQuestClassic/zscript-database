// only need these imports once
import "std.zh"
import "ffcscript.zh"


// Consumable items script v2.0
// Requires: std.zh, ffcscript.zh
//
// Import and give the two items scripts, and the one ffc script each a slot.
// Attach the I_ACT_Consume_Weap script to your consumable weapon.  See below for the arguments.
// Attach the I_PU_Consume_Weap script if the consumable isn't a 1-use item.  See below for the arguments.
// Potentially reset the following constants if any other script conflicts.

const int LW_MISC_CONSUME = 0;  // index to lweapon->Misc[] array.  if any other scripts use this array, change this number accordingly.
const int E_MISC_CONSUME = 0;   // index to npc->Misc[] array.  if any other scripts use this array, change this number accordingly.

// Optional: Repair item.  Create Custom Item with Custom Item Class.
// Attach the I_ACT_Repair script to it.  See below for the arguments.
// If you want the Repait item itself consumable, attach the I_PU_Consume_Weap script to it as well.
// Note: once the item is gone, the repair item won't get it back.  And it won't work on items set as one-time use.
//
// See more notes at the bottom of the script file.
//
//
// --------------------------------------------------------------------------------------
// Action Slot Arguments - I_ACT_Consume_Weap
//
// D0 = The consumable weapon's item#.  
//      Set to -1 if item should not be removed when uses run out.  This will require a global function to intercept use if counter = 0.
//	The global function doesn't exist yet.
//
// D1 = The consumable weapon's type.  Doesn't need to be set if D3 = 0
//
//      LW_SWORD = 1, LW_BEAM = 2, LW_BRANG = 3, LW_FIRE = 9, LW_CANDLE = 12, LW_WAND = 12, LW_MAGIC = 13, LW_HAMMER = 19
//	New types:  41 = BRANG Bounce - boomerang collision makes it bounce (turn all solids into a Block Flag)
//		    42 = BRANG KILL - boomerang collision = kill lweapon
//      above values have been tested, other values are found in std_constants.zh
//
// D2 = The consumable weapon's associated script counter #.  Set to -1, if its a one-time use weapon with no counter.
//	Accepts the Script#, NOT the CR_SCRIPT# value.  I.e. if using Script1, input 1.
//	Set to 0 if its an unlimited use item, and using a special value (described below)
//
//	If for whatever reason you want to use a counter (rupees, keys, etc) other than a script counter, 
//      find the // ************ in each item script below and read the comment.
//      D2 would then require the actual CR_ counter value.  Values in std_constants.zh
//
// D3 = What criteria count as a use?  
//      Not all the values will make sense for all LW types, and might produce bizarre behavior.
//  	   		  	
//      0 = Usage only
//      1 = Enemy Only Collisions
//      2 = Enemy+Solid Collisions
//      3 = Enemy+Solid+Water Collisions
//	4 = Water Only Collisions
//	5 = Solid Only Collisions
//	6 = Enemy+Water Collisions
//	7 = Solid+Water Collisions
//      
// D4 = unused for action. Can be anything.
//
//
// 	A Note on "Special" values.
//	Certain weapons create two LW_ types, I.e. a sword with beams, candle with fire.
//	This allows you to do something to both.  Using this only makes sense for certain weapons.
//	The special values will never destroy the actual item, only the regular values can do that.
//	They are exclusively for controlling the LW.
//
//	D1, D2 and D3 accept two values.  1st before the decimal place, Special after the decimal
//	They all need a special value for it to work.
//	Note D1's special value is two decimal places.  So #.01 = LW_SWORD as the second value.
//	The D2 special value is NOT a reference to an actual counter.  Just how many collisions the LW will have.
//
//	Example usage:  Sword with Enemy and Solids collision, with penetrating Beam with 2 Enemy collisions.  
//	D1 = 1.02, D2 = script#.2, D3 = 2.1
//	Example usage:  Candle with 3 uses, with fire with 1 Enemy+Solid+Water collisions.  
//	D1 = 0.09, D2 = script#.1, D3 = 0.3
//	Example usage:  Candle with 1 use, with fire with 3 Enemy collisions.  
//	D1 = 0.09, D2 = -1.3, D3 = 0.1
//	Example usage:  Candle with unlimited use, with fire with 1 water collision.  
//	D1 = 0.09, D2 = 0.1, D3 = 0.4
//
// --------------------------------------------------------------------------------------
// Pickup Slot Arguments - I_PU_Consume_Weap
// If its a 1-time use weapon you don't need this.
//
// D0 & D1 = unused for pickup.  Can be anything.
//
// D2 = The consumable weapon's associated counter.
//	Accepts the Script#, NOT the CR_SCRIPT# value.  I.e. if using Script1, input 1.
//
//	If for whatever reason you want to use a counter (rupees, keys, etc) other than a script counter, 
//      find the // ************ in each item script below and read the comment.
//      D2 would then require the actual CR_ counter value.  Values in std_constants.zh
//
// D3 = unused for pickup. Can be anything.
//
// D4 = The amount of uses the weapon has.
//
// 
// --------------------------------------------------------------------------------------
// Action Slot Arguments - I_ACT_Repair 
//
// D0 - Consumable counter the repair improves
//	Accepts the Script#, NOT the CR_SCRIPT# value.  I.e. if using Script1, input 1.
//
//	If for whatever reason you want to use a counter (rupees, keys, etc) other than a script counter, 
//      find the // ************ in each item script below and read the comment.
//      D2 would then require the actual CR_ counter value.  Values in std_constants.zh
//
// D1 - Amount to improve
//
// D2 - If the repair item itself is consumable, put its counter here.  Else leave 0.
//	Accepts the Script#, NOT the CR_SCRIPT# value.  I.e. if using Script1, input 1.
//
//	If for whatever reason you want to use a counter (rupees, keys, etc) other than a script counter, 
//      find the // ************ in each item script below and read the comment.
//      D2 would then require the actual CR_ counter value.  Values in std_constants.zh
//
// D3 - If the repair item itself is consumable, put its item# here. Else leave 0.
//
// D4 - unused for action. Can be anything.
//
//
// --------------------------------------------------------------------------------------
// Consumable Ladder 
// Needs to be a global script.  Just add ConsumeLadder(); to before your Waitframe(); in your global slot2 loop.
// Uses the standard Ladder item#.  Replace I_LADDER1 with the item# if using something different.
// Set the following constant to the an unused counter the ladder will use.

const int CR_LADDER = 29; // Currently script counter 23.

bool onLadder = false;

void ConsumeLadder(){
	if(!onLadder && Link->LadderX > 0 && Link->LadderY > 0){
		onLadder = true;
	}else if(onLadder && Link->LadderX == 0 && Link->LadderY == 0){
		onLadder = false;

		Game->Counter[CR_LADDER]--;
		if(Game->Counter[CR_LADDER] <= 0) Link->Item[I_LADDER1] = false;
	}
}


item script I_ACT_Consume_Weap{
	void run(int consume_item, float fconsume_type, float fconsume_counter, float fcwc, int notused1){
		int consume_type = Floor(fconsume_type);
		int consume_counter;

		if(fconsume_counter>=0){
			consume_counter = Floor(fconsume_counter);
		}else{
			consume_counter = Ceiling(fconsume_counter);
		}			

		int consume_with_coll = Floor(fcwc);

		int type2 = (fconsume_type - consume_type) * 100;
		int counter2 = (Abs(fconsume_counter) - Abs(consume_counter)) * 10;
		int consume_with_coll2 = (fcwc - consume_with_coll) * 10;

		// ************
		// so you don't have to input the CR_SCRIPT#, just the Script#.
		// remove this if statement, if for whatever reason you are using counters other than script counters to track item uses.

		if(consume_counter > 0){
			consume_counter += 6;
		}

		// run the 2nd type collision checking
		if(type2 != 0 && counter2 != 0 && consume_with_coll2 != 0){
			RunConsumeFFC(-1,type2,counter2+100,consume_with_coll2);
		}

		if(consume_counter == 0){
			// unlimited use item
			Quit();
		}

		if(consume_with_coll > 0){
			// collision checking for first type

			RunConsumeFFC(consume_item,consume_type,consume_counter,consume_with_coll);
		}else if(consume_with_coll == 0){
			// usage only
			if(consume_item > 0){
				itemdata itm = Game->LoadItemData(consume_item);

				// Candles and Hammers take 6 frames to spawn their LW.
				// without this check, the item would be removed and nothing happen.
				// only matters for one-time use, or multiuse with only one use left.
	
				if( (itm->Family == IC_CANDLE || itm->Family == IC_HAMMER) &&
				    (consume_counter == -1 || Game->Counter[consume_counter] == 1) ){

					if(Game->Counter[consume_counter] == 1){
						Game->Counter[consume_counter] = 0;
					}
				
					RunConsumeFFC(consume_item,-1,-1,0);
			
				}else if(consume_counter == -1){    
					// a one-time use (no collision check) item
					Link->Item[consume_item] = false;
				}else{ 				    
					// a multiuse (no collision check) item
					Game->Counter[consume_counter]--;
					if(Game->Counter[consume_counter]<=0) Link->Item[consume_item] = false;  // no uses left.
				}  
			
			}else if(consume_item == -1 && consume_type > 0 && consume_counter > 0){
				// non-destroyable item, with usage counter

				if(Game->Counter[consume_counter] > 0){
					Game->Counter[consume_counter]--;
				}			

			}  // end valid consumable item check
		} // end consume_with_coll checks
	}//end run
}//end item function


item script I_PU_Consume_Weap{
	void run(int notused1, int notused2, int counter, int notused3, int amount){

		// ************
		// so you don't have to input the CR_SCRIPT#, just the Script#.
		// remove this if statement, if for whatever reason you are using counters other than script counters to track item uses.

		if(counter > 0){
			counter += 6;
		}

		Game->Counter[counter] = amount;
	}
}


item script I_ACT_Repair{
	void run(int counter_being_repaired, int repair_amount, int repair_item_counter, int repair_item, int notused){

		// ************
		// so you don't have to input the CR_SCRIPT#, just the Script#.
		// remove these two if statements, if for whatever reason you are using counters other than script counters to track item uses.
		if(counter_being_repaired > 0){
			counter_being_repaired += 6;
		}
		if(repair_item_counter > 0){
			repair_item_counter += 6;
		}

		if(Game->Counter[counter_being_repaired]>0){

			Game->Counter[counter_being_repaired] += repair_amount;

			// check if repair item itself is consumable.

			if(repair_item_counter != 0 && repair_item != 0){
				Game->Counter[repair_item_counter]--;
				if(Game->Counter[repair_item_counter]<=0) Link->Item[repair_item] = false;
			}
		}
	}
}


void RunConsumeFFC(int i, int t, int c, int s){
	int ffcScriptName[] = "Consumable_FFC";
	int ffcScriptNum = Game->GetFFCScript(ffcScriptName);
	int args[] = {i,t,c,s};
	RunFFCScript(ffcScriptNum, args);
}


ffc script Consumable_FFC{
	void run(int consume_item, int consume_type, int consume_counter, int check_solid){
		bool lw_consume_exist = false;
		int unique_ID = 1;

		int brangspecial = 0;
		int solid_counter = 0;

		// this IF is a carryover from the item script that launched this.  It fixes a bug with Candles/Hammers.
		if(consume_type == -1 && consume_counter == -1){
			Waitframes(6);
			Link->Item[consume_item] = false;
		}

		// some lweapons take a few frames to spawn.
		if(consume_type == LW_WAND || (consume_type == LW_SWORD && !Game->Generic[GEN_CANSLASH]) ){
			Waitframes(4);
		}else if(consume_type == LW_BEAM || consume_type == LW_MAGIC){
			Waitframes(12);
		}else if(consume_type == LW_FIRE){
			Waitframe();
		}else if(consume_type == 41){
			consume_type = LW_BRANG;
			brangspecial = 1; // bounce
		}else if(consume_type == 42){
			consume_type = LW_BRANG;
			brangspecial = 2; // kill
		}


		// this finds our lweapon, and marks it.  so that it is possible for two of the same lw type to be on the screen at once.
		// if we don't find a matching lweapon, the script won't continue.
		// problem is that if we wait too long for our lweapon, we can't be sure it is ours.

		unique_ID = MarkOurLW(consume_type);

		if(unique_ID >= 1){
			lw_consume_exist = true;
		}else{
			// our lweapon doesn't exist, debug to figure out why?  

			lw_consume_exist = false; // should already be false, but we want to make sure nothing else runs

			// optional function for debugging why lweapon isn't being found
			// shows frame count on screen so you know it is writing to allegro.log
			// after a new line and 2000, it writes the LW_ type, and the frame it was found

			Debug_MissingLW(consume_type);
		}				
		
		
		while(lw_consume_exist){
			lw_consume_exist = false; // if our LW isn't found on screen, we stop looping.

			for (int j = 1; j <= Screen->NumLWeapons(); j++){
				lweapon consume_weap = Screen->LoadLWeapon(j);

				// check if this lweapon is our lweapon.
				if(consume_weap->Misc[LW_MISC_CONSUME] == unique_ID && consume_weap->ID == consume_type){

					lw_consume_exist = true;  // the LW is still onscreen

					// if collisions with solid objects or water count as a collision
					if(check_solid != 0){

						// if it available to check for solid/water collision
						if(solid_counter == 0){

							// if the lweapon is colliding with solid or water combo based on what we are looking for

							if( SolidCheck(check_solid, consume_weap, consume_type) ){

								if(consume_counter == -1){      // one-time use, so kill it

									SolidKillWeap(consume_weap);

									if(consume_item != -1){
										Link->Item[consume_item] = false;
									}

									Quit(); // collision destroyed weapon, so all done.
								}else if(consume_counter >= 100){
									// must be special type/counter (no item to destroy, just lweapon)
									consume_counter--;

									if(consume_counter <= 100){
										SolidKillWeap(consume_weap);

										Quit();
									}
								}else{  // multiuse, reduce counter
									Game->Counter[consume_counter]--;  
						
									if(Game->Counter[consume_counter]<=0){   // multiuse, no more uses.
										SolidKillWeap(consume_weap);

										if(consume_item != -1){
											Link->Item[consume_item] = false;
										}

										Quit(); // collision destroyed weapon, so all done.
									}
								}

								if(brangspecial	== 1){
									consume_weap->DeadState = WDS_BOUNCE;
								}else if(brangspecial == 2){
									consume_weap->DeadState = WDS_DEAD;
								}

								// weapon still exists, set cooldown timer
							
								solid_counter = SetCoolDown(consume_type);

							} // end of solid or water check

						}else if(solid_counter>0){
							// we have already collided with solid or water, so let's reduce cooldown counter
							solid_counter--;
						}
					}//end of Check_Solid code

					if(check_solid == 4 || check_solid == 5 || check_solid == 7){
						// not checking enemy collisions
						break;
					}

					// now lets check for collision with enemies.

					for (int i = 1; i <= Screen->NumNPCs(); i++ ){
						npc enem = Screen->LoadNPC(i);

						// certain lweapon types have ability to hit more than once after a "cooldown" period.
						if(enem->Misc[E_MISC_CONSUME] > 0){
							enem->Misc[E_MISC_CONSUME]--;
						}


						// check that enemy has not already been counted for collision, and if there is a collision.
						if(enem->Misc[E_MISC_CONSUME]==0 && Collision(consume_weap, enem) ){
							if(consume_counter == -1){  // one-time use, so kill it

								EnemyKillWeap(consume_weap, enem, unique_ID);

								if(consume_item != -1){
									Link->Item[consume_item] = false;
								}

								Quit(); // collision destroyed weapon, so all done.

							}else if(consume_counter >= 100){
								// must be special type/counter (no item to destroy, just lweapon)
								consume_counter--;

								if(consume_counter <= 100){

									EnemyKillWeap(consume_weap, enem, unique_ID);
					
									Quit();
								}

							}else{  // multiuse, reduce counter
								Game->Counter[consume_counter]--;  
							
								if(Game->Counter[consume_counter]<=0){  // multiuse, no more uses.

									EnemyKillWeap(consume_weap, enem, unique_ID);

									if(consume_item != -1){
										Link->Item[consume_item] = false;
									}

									Quit(); // collision destroyed weapon, so all done.
								}
							}

							if(brangspecial	== 1){
								consume_weap->DeadState = WDS_BOUNCE;
							}else if(brangspecial == 2){
								consume_weap->DeadState = WDS_DEAD;
							}

							// if LW still exists, set that this enemy has been counted for collision.
							// certain lweapon types will be possible to hit more than once.
							if(consume_type == LW_FIRE){
								// enemy can be hurt again by fire after this many frames
								enem->Misc[E_MISC_CONSUME] = 30;  
							}else if(consume_type == LW_BRANG){
								// enemy can be hurt again by boomerang (returning?) 	
								enem->Misc[E_MISC_CONSUME] = 7;
							}else{
								// not possible to hit more than once.
 								enem->Misc[E_MISC_CONSUME] = -1;
							}
					
						}//end of enemy collision if

					} // end of NPC forloop

					break; // we found our LW, so no need to search for more.
				} // end of its our LW if.

			} // end of Lweapon forloop

			Waitframe();
		}//end of while loop
	}//end of run
}//end of function Consumable_FFC


// ------------------------------------------------------------------
// Following functions are called by Consumable_FFC

// finds and marks our LW, returns the unique_ID if found.  -1 if LW not found.
int MarkOurLW(int consume_type){
	int our_lw = 0;
	int unique_ID = 1;

	for (int j = Screen->NumLWeapons(); j > 0; j--){
		lweapon consume_weap = Screen->LoadLWeapon(j);

		if(consume_weap->ID == consume_type){
			if( our_lw == 0 ){
				our_lw = j;
			}else{
				unique_ID += 1;
			}
		}
	}
	if(our_lw > 0){
		lweapon consume_weap = Screen->LoadLWeapon(our_lw);
		consume_weap->Misc[LW_MISC_CONSUME] = unique_ID;
		return unique_ID;
	}
	
	return -1;
}//end function


// function handles all collision checking with solids
bool SolidCheck(int check_solid, lweapon cweap, int ctype){
	if( (check_solid == 2 || check_solid == 3 || check_solid == 5 || check_solid == 7)
            && Screen->isSolid(cweap->X, cweap->Y) ){
		return true;
	}
	if( (check_solid == 3 || check_solid == 4 || check_solid == 6 || check_solid == 7)
            && IsWater(ComboAt(cweap->X, cweap->Y)) ){
		return true;
	}

	// LW_FIRE collision detection is a bit off.	
	if(cweap->ID == LW_FIRE){
		if(cweap->Dir == DIR_LEFT || cweap->Dir == DIR_RIGHT){
			if( (check_solid == 2 || check_solid == 3 || check_solid == 5 || check_solid == 7) && 
			    (Screen->isSolid(HitboxRight(cweap), cweap->Y) || Screen->isSolid(HitboxLeft(cweap), cweap->Y) ) ){
				return true;
			}
			if( (check_solid == 3 || check_solid == 4 || check_solid == 6 || check_solid == 7) && 
			    (IsWater(ComboAt(HitboxRight(cweap), cweap->Y)) || IsWater(ComboAt(HitboxLeft(cweap), cweap->Y)) ) ){
				return true;
			}
		}else if(cweap->Dir == DIR_UP || cweap->Dir == DIR_DOWN){ 
			if( (check_solid == 2 || check_solid == 3 || check_solid == 5 || check_solid == 7) &&
			    (Screen->isSolid(cweap->X,HitboxTop(cweap)) || Screen->isSolid(cweap->X,HitboxBottom(cweap)) ) ){
				return true;
			}
			if( (check_solid == 3 || check_solid == 4 || check_solid == 6 || check_solid == 7) &&
			    (IsWater(ComboAt(cweap->X,HitboxTop(cweap))) || IsWater(ComboAt(cweap->X,HitboxBottom(cweap))) ) ){
				return true;
			}
		}
	}

	// this is a random oddity.  Link's sword stab doesn't register collisions with solids when stabbing down or right.  this fixes it.
	if( (check_solid == 2 || check_solid == 3 || check_solid == 5 || check_solid == 7) 
            && (ctype == LW_SWORD && !Game->Generic[GEN_CANSLASH]) ){
		if(Link->Dir == DIR_DOWN && Screen->isSolid(cweap->X, HitboxBottom(cweap) ) ){
			return true;
		}
		if(Link->Dir == DIR_RIGHT && Screen->isSolid(HitboxRight(cweap), cweap->Y ) ){
			return true;
		}
	}

	return false;
}//end function


// special function for LW_FIRE to prevent a bug where the collision registers before
// damage is done when fire moving up or left towards enemy.
void WaitForDamageThenDeadState(int wait_hp, int unique_ID){
	while(true){
		for (int i = 1; i <= Screen->NumNPCs(); i++ ){
			npc enem = Screen->LoadNPC(i);

			// look for the marked enemy that it has registered a collision with
			// wait for the hp to drop before killing lweapon
			if(enem->Misc[E_MISC_CONSUME] == -100){
				if(enem->HP < wait_hp){
					for (int j = 1; j <= Screen->NumLWeapons(); j++){
						lweapon consume_weap = Screen->LoadLWeapon(j);

						// check if this lweapon is our lweapon.
						if(consume_weap->Misc[LW_MISC_CONSUME] == unique_ID && consume_weap->ID == LW_FIRE){
							consume_weap->DeadState = WDS_DEAD;
							Quit();
						}
					}//end lweapon for

					// our enemy hp went down, but our lweapon was already gone
					Quit();
				}//end hp check
			}//end check for marked enemy
		}//end enem for loop

		Waitframe();
	}//end while loop
}//end function

// function handles some of the unique properties of various lweapons
void EnemyKillWeap(lweapon consume_weap, npc enem, int unique_ID){

	if(consume_weap->ID == LW_HAMMER){
		Waitframes(6);
	}else if(consume_weap->ID == LW_BEAM){
		consume_weap->DeadState = WDS_BEAMSHARDS;
	}else if(consume_weap->ID == LW_FIRE && 
		(consume_weap->Dir == DIR_UP || consume_weap->Dir == DIR_LEFT) ){

		enem->Misc[E_MISC_CONSUME] = -100; // mark our enemy for the next function
		WaitForDamageThenDeadState(enem->HP, unique_ID);						
	}else{
		consume_weap->DeadState = WDS_DEAD;
	}
}//end function


// function handles some of the unique properties of various lweapons
void SolidKillWeap(lweapon consume_weap){

	if(consume_weap->ID == LW_HAMMER){
		Waitframes(6);
	}else if(consume_weap->ID == LW_BEAM){
		consume_weap->DeadState = WDS_BEAMSHARDS;
	}else{
		consume_weap->DeadState = WDS_DEAD;
	}
}//end function

// function sets cooldown timer for next solid collision
int SetCoolDown(int consume_type){
	if(consume_type == LW_FIRE){
		return 30;
	}else if(consume_type == LW_BRANG){
		return 7;
	}else if(consume_type == LW_BEAM){
		return 10; // test
	}else if(consume_type == LW_MAGIC){
		return 10; // test
	}

	return 100; // high number will prevent other lweapons from registering another solid collision
}//end function

// optional function for debugging why lweapon isn't being found
// shows frame count on screen so you know it is writing to allegro.log
// after a new line and 2000, it writes the LW_ type, and the frame it was found
void Debug_MissingLW(int consume_type){
	TraceNL();
	Trace(2000);

	for (int idebug = 0; idebug < 600; idebug++){
		Quick_Debug(idebug);
				
		for (int j = Screen->NumLWeapons(); j > 0; j--){
			lweapon consume_weap = Screen->LoadLWeapon(j);
	
			if(consume_weap->ID == consume_type){
				Trace(consume_type);
				Trace(idebug);
				Quit();
			}
		}//end for

		Waitframe();	
	}//end for
}//end function

void Quick_Debug(int num){
	Screen->DrawInteger(6, ComboX(80), ComboY(80), FONT_Z1, 0x01, 0x00, 0, 0, num, 0, OP_OPAQUE);
}

// end functions called by Consumable_FFC
// ------------------------------------------------------------------



// Notes on various curiosities with the script:
//
// Swords - Beams aren't counted as a collison when using LW_SWORD type.
//	    You can set LW_BEAMS as the 2nd type.
//          stab and slash both work.  
//          
// Bow&Arrow - if you want to have the weapon itself consumable, you need to set the Action script
//             on the Arrow item (not arrow ammunition).  Setting it on bow item doesn't do anything.
//
// Candle - probably works best as a use item
//          however collisions have been tested with LW_FIRE type. the same enemy can be hit more than once by one fire after a brief rest period. 
//          untested collisions with LW_CANDLE type, because who swings a candle?
//
// Wand - works.  If you set LW_MAGIC as the type you might not be able to trigger Wand Fire with certain setups.
// Whistle - seems to work without issue?  Only tried whirlwinds, not drying lakes and secrets.
//
// Bait - seems to work without issue?
// Hammer - seems to work without issue?
// Boomerang - seems to work without issue?
//
// Ladder - no issue?
//
// didn't test anything else.  Let me know.
//