/////////////////////////////////
/// Z3 Style Chest Minigame   ///
/// v0.5 - 04-Jul-2022        ///
/// By: ZoriaRPG & Alucard648 ///
/////////////////////////////////
/// Final Release             ///
/////////////////////////////////

//Combos
const int CMB_CHEST_GAME_CLOSED = 948; //The 'closed' chest combo.
//! This should be combo type 'none', and solid.
const int CF_CHEST_GAME_PRIZE_DATA_MAIN_PRIZE = 10;

//Strings
const int STR_CHEST_GAME_RULES = 37; //Screen->Message string that explains the game rules to the player.
const int STR_CHEST_GAME_OVER = 39; //Screen->Message string for the end of a game round.

//Sounds
const int SFX_OPEN_CHEST = 9; //The sound that will play when Link opens a chest, and an item is awarded.
const int SFX_CHEST_GAME_SPECIAL_PRIZE_FANFARE = 27; //The sound to play when the player finds the special item in a chest.
const int SFX_CHEST_GAME_START = 35; //The sound to play when the player starts the game.

//Other Settings and Options
const int CHEST_GAME_ALLOW_REPLAY = 0; //Set to '1' to allow the player to play again without leaving the screen.

const int FONT_CHEST_GAME = 0;//Font used to render various info in this minigame.

//Lttp-style Treasure Chest minigame
//Pay up cost, then open 3 chests and clain found contents. Good luck!

//1.Set up 2 sequences of combos, 2 combos each:
// Chest - Closed, then open. Both combos must have "none" type and fully solid. Set CMB_CHEST_GAME_CLOSED to closed chest combo.
// Rupee then blank - for FFC itself to charge cost.
//2. --Prize table building--
// Set aside 1 unused screeen. Fill that screen with combos, whose ID`s (order in table, not combo type) are equal to ID`s of prize items, use the same combo multiple times to increase the chance of winning practicular item. 
// Flag "special item" combos (like heart piece ID) with CF_CHEST_GAME_PRIZE_DATA_MAIN_PRIZE flag, so upon winning this item, Screen`s Special Item flag will set on and any furtner such win cases will reward backup item. Use screen`s undercombo (the screen, where the game is located) to define backup prize ID.
//--
//3.Place chests in the game screen, using only CMB_CHEST_GAME_CLOSED combos.
//4.Place FFC with Rupee combo at location, where Link could pay up cost to start minigame.
// D0 - number of chests to open per game
// D1 - Map for locating prize table. (step 2)
// D2 - Screen used to define prize table. (step 2)
// D3 - 1 - turn the game into classic Money making game - Combo ID`s define amout of rupees to gain/lose. CF_CHEST_GAME_PRIZE_DATA_MAIN_PRIZE sets negative number.
// D4 - Cost per play, in rupees.
// D5 - String to display at screen entrance, usually to render game rules.
// D6 - String to display when the game is over
// D7 - 1 - alloy replaying the game without exiting/reentring screen.


ffc script LTTPItemChestMiniGame{	
	void run(int max_chests_Link_can_open, int prizedatamap, int prizedatascreen, int moneygame, int costPerPlay, int msgRules, int msgEnd, int allowReplay){		
		int ChestPrizes[176];
		for (int i=0;i<176;i++){
			ChestPrizes[i]=Game->GetComboData(prizedatamap, prizedatascreen, i);
			if (Game->GetComboFlag(prizedatamap, prizedatascreen, i)==CF_CHEST_GAME_PRIZE_DATA_MAIN_PRIZE) ChestPrizes[i]*=-1;
		}
		int initialData = this->Data; //Store the initial combo, to revert, if replay is enabled. 
		int check=-1;
		int cmb=-1;
		int adjcmb =-1;
		int has_opened_number_of_chests=0;
		bool gameRunning = false;
		bool gameOver = false;
		bool giveprize = false;		
		item it;
		
		if ( msgRules >0) Screen->Message(msgRules);
		else Screen->Message(STR_CHEST_GAME_RULES);	//Show the string for the chest game rules. 
		
		while(true) {
			if ( max_chests_Link_can_open == has_opened_number_of_chests ) gameOver = true;		
			if ( gameOver && ( CHEST_GAME_ALLOW_REPLAY || allowReplay > 0 ) ) {
				gameOver = false;
				gameRunning = false;
				this->Data = initialData;
				for ( int q = 0; q < 176; q++ ) {
					if ( Screen->ComboD[q] == CMB_CHEST_GAME_CLOSED+1 ) Screen->ComboD[q] = CMB_CHEST_GAME_CLOSED;
				}
				has_opened_number_of_chests = 0;
			}
			if (!gameRunning)Screen->DrawInteger(2, this->X, this->Y+16, FONT_CHEST_GAME,1,0, -1, -1, -costPerPlay, 0, OP_OPAQUE);
			if ( LinkCollision(this) && Game->Counter[CR_RUPEES] >= costPerPlay && (Link->PressA||Link->PressB||Link->PressEx1) && !gameRunning ) {	
				//If Link collides with the ffc, which should show the cost, and presses a button, start the game. 
				if ( SFX_CHEST_GAME_START ) Game->PlaySound(SFX_CHEST_GAME_START);
				gameRunning = true;
				Game->DCounter[CR_RUPEES] -= costPerPlay;
				this->Data++; //increase to the next combo, removing the cost icon. 
			}			
			if ( gameRunning ) {				
				//Check to see if Link can open chest				
				cmb = ComboAt(CenterLinkX(), CenterLinkY());
				adjcmb = AdjacentComboFix(cmb, Link->Dir);
				if (Screen->ComboD[adjcmb]==CMB_CHEST_GAME_CLOSED){
					if (Link->PressA||Link->PressB||Link->PressEx1){
						has_opened_number_of_chests++; 
						Game->PlaySound(SFX_OPEN_CHEST);
						Screen->ComboD[adjcmb]++;
						giveprize=true;
					}
				}
				if ( giveprize ) {
					if (moneygame>0){
						check = Rand(176);
						check = ChestPrizes[check];
						Game->DCounter[CR_RUPEES]+= check;
						for (int i=0; i<60; i++){
							Screen->DrawInteger(1, ComboX(adjcmb)-Cond((check<0||check>100), 4,0), ComboY(adjcmb), FONT_CHEST_GAME,1,-1, -1, -1, check, 0, OP_OPAQUE);
							Waitframe();
						}
					}
					else{
						check = Rand(176);
						Trace(check);
						int itemID = Abs(ChestPrizes[check]);
						if (ChestPrizes[check]<0 && Screen->State[ST_SPECIALITEM]) itemID = Screen->UnderCombo;
						it = CreateItemAt(itemID, Link->X, Link->Y);
						it->Pickup +=IP_HOLDUP;
						if (ChestPrizes[check]<0 && !Screen->State[ST_SPECIALITEM]){
							it->Pickup |= IP_ST_SPECIALITEM;
							Game->PlaySound(SFX_CHEST_GAME_SPECIAL_PRIZE_FANFARE);
						}
					}
					giveprize=false;
				}
				
				if ( has_opened_number_of_chests >= max_chests_Link_can_open ) {
					gameOver = true;
					gameRunning = false;
					if ( msgEnd ) Screen->Message(msgEnd);
					else Screen->Message(STR_CHEST_GAME_OVER);
					if (!CHEST_GAME_ALLOW_REPLAY && !allowReplay )Quit();
				}
			}		
			Waitframe();
		}
	}	
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