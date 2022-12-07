///////////////////////////////
/// Z3 Style Chest Minigame ///
/// v0.4.4 - 27-Nov-2016    ///
/// By: ZoriaRPG            ///
///////////////////////////////
/// Final Release           ///
///////////////////////////////



//! The initial combo used for this ffc (on the screen) should be a rupee icon with a numeric cost. 
//! The next combo in the list, should be blank. 


//Combos
const int CMB_CHEST_GAME_CLOSED = 896; //The 'closed' chest combo.
			//! This should be combo type 'none', and solid.
const int CMB_CHEST_GAME_OPEN = 897; //The closed chest combo.
			//! This should be the combo immediately after CMB_CHEST_GAME_CLOSED', with a type of 'none'. 


//Strings
const int MSG_CHEST_GAME_RULES = 3; //Screen->Message string that explains the game rules to the player.
const int MSG_CHEST_GAME_OVER = 2; //Screen->Message string for the end of a game round.

//Sounds
const int SFX_OPEN_CHEST = 20; //The sound that will play when Link opens a chest, and an item is awarded.
const int SFX_CHEST_GAME_SPECIAL_PRIZE_FANFARE = 27; //The sound to play when the player finds the special item in a chest.
const int SFX_CHEST_GAME_START = 35; //The sound to play when the player starts the game.

//Other Settings and Options
const int CHEST_GAME_SCREEN_D_REGISTER = 5; //The Screen->D[index] used to store if the main prize has been awarded. 
const int CHEST_GAME_HOLDUP_TYPE = 4; // The type of item hold-up tp use.  4 = LA_HOLD1LAND(one hand); 5 = LA_HOLD2LAND(two hands)
const int CHEST_GAME_ALLOW_REPLAY = 0; //Set to '1' to allow the player to play again without leaving the screen.
const int TIME_INPUT_UP_OPEN_CHEST = 50; //The number of frames of inputting up will open a closed chest. 
const int OPEN_CHESTS_FROM_SIDES_OR_ABOVE = 1; //Set to '0' to only permit opening them from the bottom. 



// Chest Game FFC

//~ //D0: Number of chests to allow the player to open, per play.
//~ //D1: ID of special prize to award.
//~ //D2: Percentage chance of awarding special prize.
//~ //D3: Backup prize, if special prize already awarded (e.g. 100 rupees, instead of a heart piece). Set to '0' to not offer a backup prize. 
//~ //D4: Cost per play.
//~ //D5: String for game rules.
//~ //D6: String to play at end of game. 
//~ //D7: Set to '1' to allow replaying without leaving the screen.


ffc script ChestMiniGame{	
	void run(int max_chests_Link_can_open, int specialPrize, int percentMainPrize, int backupPrize, int costPerPlay, int msgRules, int msgEnd, int allowReplay){

		
		//Populate with the IDs of prizes to award. Each index is a 1% chance. 
		int chestPrizes[]= { 	72,	0,	30,	0,	39,	0,	39,	0,	2,	29,
					0,	0,	23,	72,	0,	72,	72,	79,	80,	30,
					0,	2,	39,	38,	71,	60,	0,	40,	0,	87,
					87,	0,	86,	80,	0,	0,	2,	29,	60,	29,
					0,	71,	73,	0,	87,	73,	0,	79,	38,	0,
					17,	80,	40,	23,	0,	0,	38,	0,	0,	0,
					0,	38,	24,	0,	60,	71,	2,	1,	73,	81,
					1,	70,	0,	29,	0,	0,	0,	80,	0,	86,
					79,	0,	70,	0,	70,	0,	0,	0,	23,	0,
					0,	2,	0,	10,	0,	38,	2,	70,	70,	86	};

		int initialData = this->Data; //Store the initial combo, to revert, if replay is enabled. 
		int chestComboSpots[176];
		int check;
		int cmb;
		int mainprize;
		int timer = TIME_INPUT_UP_OPEN_CHEST; 
		bool openchest;
		int has_opened_number_of_chests;
		bool award_main_prize;
		bool gameRunning;
		bool gameOver;
		item i;
		bool giveprize;
		bool awardnormalprize;
		
		if ( msgRules ) Screen->Message(msgRules);
		else Screen->Message(MSG_CHEST_GAME_RULES);	//Show the string for the chest game rules. 
		
		while(true) {
			if ( max_chests_Link_can_open == has_opened_number_of_chests ) gameOver = true;
			if ( gameOver && ( !CHEST_GAME_ALLOW_REPLAY && !allowReplay ) || allowReplay < 0 ) break;
			
			if ( gameOver && ( CHEST_GAME_ALLOW_REPLAY || allowReplay > 0 ) ) {
				gameOver = false;
				gameRunning = false;
				this->Data = initialData;
				for ( int q = 0; q < 176; q++ ) {
					if ( Screen->ComboD[q] == CMB_CHEST_GAME_OPEN ) Screen->ComboD[q] = CMB_CHEST_GAME_CLOSED;
				}
				has_opened_number_of_chests = 0;
			}
			
			if ( LinkCollision(this) && Game->Counter[CR_RUPEES] > costPerPlay && ____Xor(Link->PressA,Link->PressB) && !gameRunning ) {	
					//If Link collides with the ffc, which should show the cost, and presses a button, start the game. 
				if ( SFX_CHEST_GAME_START ) Game->PlaySound(SFX_CHEST_GAME_START);
				gameRunning = true;
				Game->DCounter[CR_RUPEES] -= costPerPlay;
				this->Data++; //increase to the next combo, removing the cost icon. 
			}
				
			
			
			if ( gameRunning ) {
			
				//Check to see if the combo above Link is a chest.
				
				
				if ( Link->Dir == DIR_UP ){
					cmb = Screen->ComboD[ ___AdjacentCombo(ComboAt(Link->X+8, Link->Y+8),Link->Dir) ];
					
					if ( cmb == CMB_CHEST_GAME_CLOSED ) {
						if ( timer && Link->InputUp ) timer--;
						if ( timer <= 0 ||  ____Xor(Link->PressA,Link->PressB)) { 
							has_opened_number_of_chests++; 
							if ( SFX_OPEN_CHEST ) Game->PlaySound(SFX_OPEN_CHEST); 
							Screen->ComboD[ ___AdjacentCombo(ComboAt(Link->X+8, Link->Y+8),Link->Dir) ]++; 
							
							timer = TIME_INPUT_UP_OPEN_CHEST; 
							giveprize = true;
							Link->InputUp = false; 
						}
					}
					else timer = TIME_INPUT_UP_OPEN_CHEST;
				}
				else if ( Link->Dir == DIR_DOWN && OPEN_CHESTS_FROM_SIDES_OR_ABOVE ){
					cmb = Screen->ComboD[ ___AdjacentCombo(ComboAt(Link->X+8, Link->Y+8),Link->Dir) ];
					
					if ( cmb == CMB_CHEST_GAME_CLOSED ) {
						if ( timer > 0 && Link->InputDown ) timer--;
						if ( timer <= 0 ||  ____Xor(Link->PressA,Link->PressB) ) { 
							has_opened_number_of_chests++; 
							if ( SFX_OPEN_CHEST ) Game->PlaySound(SFX_OPEN_CHEST);
							Screen->ComboD[ ___AdjacentCombo(ComboAt(Link->X+8, Link->Y+8),Link->Dir) ]++; 
							timer = TIME_INPUT_UP_OPEN_CHEST; 
							giveprize = true;
							Link->InputUp = false; 
						}
					}
					else timer = TIME_INPUT_UP_OPEN_CHEST; 
				}
				else if ( Link->Dir == DIR_LEFT && OPEN_CHESTS_FROM_SIDES_OR_ABOVE ) {
					cmb = Screen->ComboD[ ___AdjacentCombo(ComboAt(Link->X+8, Link->Y+8),Link->Dir) ];
					if ( cmb == CMB_CHEST_GAME_CLOSED ) {
						if ( timer > 0 && Link->InputLeft ) timer--;
						if ( timer <= 0 ||  ____Xor(Link->PressA,Link->PressB) ) { 
							has_opened_number_of_chests++; 
							if ( SFX_OPEN_CHEST ) Game->PlaySound(SFX_OPEN_CHEST);
							Screen->ComboD[ ___AdjacentCombo(ComboAt(Link->X+8, Link->Y+8),Link->Dir) ]++; 
							timer = TIME_INPUT_UP_OPEN_CHEST; 
							giveprize = true;
							Link->InputUp = false; 
						}
					}
					else timer = TIME_INPUT_UP_OPEN_CHEST; 
				}
				else if ( Link->Dir == DIR_RIGHT && OPEN_CHESTS_FROM_SIDES_OR_ABOVE ) {
					cmb = Screen->ComboD[ ___AdjacentCombo(ComboAt(Link->X+8, Link->Y+8),Link->Dir)];
					if ( cmb == CMB_CHEST_GAME_CLOSED ) {
						if ( timer > 0 && Link->InputRight ) timer--;
						if ( timer <= 0 ||  ____Xor(Link->PressA,Link->PressB) ) { 
							has_opened_number_of_chests++; 
							if ( SFX_OPEN_CHEST ) Game->PlaySound(SFX_OPEN_CHEST); 
							Screen->ComboD[ ___AdjacentCombo(ComboAt(Link->X+8, Link->Y+8),Link->Dir) ]++; 
							timer = TIME_INPUT_UP_OPEN_CHEST; 
							giveprize = true;
							Link->InputUp = false; 
						}
					}
					else timer = TIME_INPUT_UP_OPEN_CHEST; 
					
				}
				
			
			
				if ( giveprize ) {
					
					check = Rand(1,100);  //Make a check, to use for determining if the main prize should e awarded.
					
					if ( check <= percentMainPrize ) award_main_prize = true; //If that check passes, then we will award the main prize.
					
					if ( check > percentMainPrize ) { awardnormalprize = true; check = Rand(0,SizeOfArray(chestPrizes)); }//Otherwise, reuse that var, and make a new check to determine
														//the prize to award from the table. 
					int itm;
		
					if ( !awardnormalprize && award_main_prize && !Screen->D[CHEST_GAME_SCREEN_D_REGISTER] ) { //The main prize has not been awarded, and has been randomly chosen. 
						Game->PlaySound(SFX_CHEST_GAME_SPECIAL_PRIZE_FANFARE); //Play the fanfare...
						i = Screen->CreateItem(specialPrize);	//Assign the pointer, and make the item.
						itm = specialPrize;	//Set the value of the item ID to a var so that we can use it for holding it up. 
					}
					if ( !awardnormalprize && award_main_prize && Screen->D[CHEST_GAME_SCREEN_D_REGISTER] && backupPrize ) { 	//The main prize has already been awarded, so recheck. 
						Game->PlaySound(SFX_CHEST_GAME_SPECIAL_PRIZE_FANFARE);	//Play the special award fanfare...
						i = Screen->CreateItem(backupPrize);	//Assign the pointer, and make the item.
						itm = backupPrize;	//Set the value of the item ID to a var so that we can use it for holding it up. 
					}
					if ( awardnormalprize && check ) { 	//Otherwise, if the check to award a special prize did not pass..
						Game->PlaySound(SFX_OPEN_CHEST); //otherwise, play the default.
						i = Screen->CreateItem(chestPrizes[check]); //Award a normal prize, from the list. 
						itm = chestPrizes[check]; //Set the value of the item ID to a var so that we can use it for holding it up. 
					
					}
					if ( check ) {	//if we're awarding a prize...
						i -> X = Link->X;
						i -> Y = Link->Y;
						if ( CHEST_GAME_HOLDUP_TYPE ) {  //If the setting to hold the item overhead is enabled...
							Link->Action = CHEST_GAME_HOLDUP_TYPE; //Hold the item overhead, using the value of that setting. 
							Link->HeldItem =  itm;
						}
						
						if ( award_main_prize ) { Screen->D[CHEST_GAME_SCREEN_D_REGISTER] = 1; award_main_prize = false; }	//Set the register so that Link cannot collect the special prize again. 
						
						giveprize = false;
						while( Link->Action == LA_HOLD1LAND ) Waitframe();
					}
					else Remove(i);	//if check is zero, remove the item pointer. 
							//This allows chances of getting nothing at all. 
				}
				
				if ( has_opened_number_of_chests >= max_chests_Link_can_open ) {
					gameOver = true;
					gameRunning = false;
					if ( msgEnd ) Screen->Message(msgEnd);
					else Screen->Message(MSG_CHEST_GAME_OVER);
					
				}

			}
		
			Waitframe();
		}
		//If we reach here, then the chest game is over. 
		this->Data = 0;
		this->Script = 0;
		Quit();
	}
	
	//Constants for AdjacentCombo()
	//This now uses DIR_* constants, so you can do AdjacentCombo(cmb,Link->Dir)
	//Returns the Nth combo index of a combo based on a central point, and a direction.
	//For example, combo 22 + COMBO_UPRIGHT returns '7', 
	//as combo 7 is to the upper-right of combo 22.
	int ___AdjacentCombo(int cmb, int dir){
	    int combooffsets[13]={-0x10, 0x10, -1, 1, -0x11, -0x0F, 0x0F, 0x11};
	    if ( cmb % 16 == 0 ) combooffsets[9] = 1;
	    if ( (cmb & 15) == 1 ) combooffsets[10] = 1; 
	    if ( cmb < 0x10 ) combooffsets[11] = 1; //if it's the top row
	    if ( cmb > 0x9F ) combooffsets[12] = 1; //if it's on the bottom row
	    if ( combooffsets[9] && ( dir == CMB_LEFT || dir == CMB_UPLEFT || dir == CMB_DOWNLEFT || dir == CMB_LEFTUP ) ) return 0; //if the left columb
	    if ( combooffsets[10] && ( dir == CMB_RIGHT || dir == CMB_UPRIGHT || dir == CMB_DOWNRIGHT ) ) return 0; //if the right column
	    if ( combooffsets[11] && ( dir == CMB_UP || dir == CMB_UPRIGHT || dir == CMB_UPLEFT || dir == CMB_LEFTUP ) ) return 0; //if the top row
	    if ( combooffsets[12] && ( dir == CMB_DOWN || dir == CMB_DOWNRIGHT || dir == CMB_DOWNLEFT ) ) return 0; //if the bottom row
	    else if ( cmb >= 0 && cmb <= 176 ) return cmb + combooffsets[dir];
	    else return -1;
	}   
	//Xor comparison of two boolean values. 
	bool ____Xor(bool valA, bool valB){
		if ( !valA && valB ) return true;
		else if ( valA && !valB ) return true;
		return false;
	}


}