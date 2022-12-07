import "std.zh"

////////////////////////////////////////////
/// Bow, Arrow, and Quiver Bundle Pickup ///
/// v0.2.1 - 9th July, 2015              ///
/// By: ZoriaRPG                         ///
////////////////////////////////////////////
	
// Script Arguments	
// D0: Number of starting arrows to give with this bow.
// D1: Quiver to Give: Small Quiver ( 74 ), medium Quiver ( 75 ), Large Quiver ( 76 ), Magic Quiver ( 105 ) , or custom.
// D2: Type of arrow to give with bow: Wooden ( 13 ), Silver ( 14 ), Gold ( 57 ), or custom.
// D3: Sound Effect to play: Special Item ( 20 ), or custom.
// D4: Message String ID to display (if any). None ( 0 ), or custom. 
// D5: Hold-Up Animation to use: None ( 0 ) , 1-Hand ( 1 ), 2-Hand ( 2 ) , 1-Hand-Water ( 3 ), 2-Hand-Water ( 4 ).
// D6: Bow to give: Bow ( 15 ) , Longbow ( 68 ), or custom. This should match the item ID to which you attach this script!

item script BowPickup{
	void run(int giveArrows, int quiver, int arrowType, int playSFX, int showMessage, int holdUp, int bowID){
		int arrowsMax;
		if ( quiver && !Link->Item[quiver] ) {
			Link->Item[quiver] = true;
			itemdata quiverIT = Game->LoadItemData(quiver);
			arrowsMax = quiverIT->Max;
		}
		if ( Game->MCounter[CR_ARROWS] < arrowsMax ) Game->MCounter[CR_ARROWS] = arrowsMax;
		if ( arrowType && !Link->Item[arrowType] ) Link->Item[arrowType] = true;
		if ( giveArrows ) Game->Counter[CR_ARROWS] += giveArrows;
		if ( giveArrows < 0 ) Game->Counter[CR_RUPEES] -= giveArrows;
		if ( playSFX ) Game->PlaySound(playSFX);
		if ( holdUp && bowID ) _Bow_HoldUpItem(bowID,holdUp);
		if ( showMessage ) Screen->Message(showMessage);
	}
}

//Global Constants and Functions

//Item Hold-Up Constants
const int ITM_HOLD1LAND = 1;
const int ITM_HOLD2LAND = 2;
const int ITM_HOLD1WATER = 3;
const int ITM_HOLD2WATER = 4;

//Global Function to force Link to hold up any item specified as itm, using animation specified by holdType.
void _Bow_HoldUpItem(int itm, int holdType){
	if ( holdType == ITM_HOLD1LAND ) {
		Link->Action = LA_HOLD1LAND;
		Link->HeldItem = itm;
	}
	if ( holdType == ITM_HOLD2LAND ) {
		Link->Action = LA_HOLD2LAND;
		Link->HeldItem = itm;
	}
	if ( holdType == ITM_HOLD1WATER ) {
		Link->Action = LA_HOLD1WATER;
		Link->HeldItem = itm;
	}
	if ( holdType == ITM_HOLD2WATER ) {
		Link->Action = LA_HOLD2WATER;
		Link->HeldItem = itm;
	}
}