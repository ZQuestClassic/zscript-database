//////////////////////////////////////////
/////Give Boss Key On Heart Container/////
//////////////////////////////////////////

///////////////////
////Created By/////
///Admiral Jaden///
///////////////////

//NOTE: This script MUST be placed in the "Pickup Script" Box For Your Heart Container Item.

//D0: Number of Heart Containers Until You Get The Boss Key
//D1: Message To Display On Pickup
//NOTE: If you want to get it on your 12th heart container, set D0 to 11.
//Or if you want it on heart 4, then set D0 to 3. Etc. It must be one number lower than your target.

import "std.zh" //(If you have this at the top of your scripts file, place // before the word 'import')

const int LEVEL = 0; //The Level Number (as defined in your DMap) That You Want To Get The Boss Key For. Default is Zero (0)

item script LevelZeroBKey{
	void run(int ReqHC, int m){
		if(Link->MaxHP >= 16 * ReqHC){
			Game->LItems[LEVEL] |= LI_BOSSKEY;
		}
		Screen->Message(m);
	}
}