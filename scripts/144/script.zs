// import "std.zh"  // Only need this once.

// Passive Subscreen A/B Counter Fix
// A fix to display the proper counter for the A and B buttons on the passive subscreen when the quest rule "Can Select A-Button Weapon on Subscreen" is on.
//
// In your Slot2 (or Active) global script, put SetCountersAB(); before the waitframe.
// A sample global script is commented out at the bottom.
// 
// See notes below about the constants used ESPECIALLY if your quest makes use of the Script1-25 item counters.  If you're not sure, you'll likely be safe with the defaults.
//
// On your passive subscreen, place a Counter object with each Button Item display.  Edit the properties. 
// On the Attributes Tab, change Item 1 to the corresponding Script counter - default is A Button = Script 24, B Button = Script 25
// Leave "Show Zero" and "Only Selected" UNCHECKED.
//
// Note:  make sure that your item has its Counter Reference declared.  Edit the item, Pickup tab.  
// For instance, Arrows are hardcoded to use either rupees or arrows.  Unless the Counter Reference is set, the counter won't show.
// This should point to the item's counter NOT the script counters used by this script.
//


// Set these constants to unused Script counters. Valid numbers would be 7-31.
// By default they are set to the highest values to hopefully avoid interfering with any other scripts.
// The counter values and associated references are all in std_constants.zh
// You'll need to know the counter reference number NOT the value.  So for the defaults, you'll need to use Script Counters 24 & 25.
const int CR_ABUTTON = 30;  // Script 24 counter reference
const int CR_BBUTTON = 31;  // Script 25 counter reference


void SetCountersAB(){
	itemdata itemA = Game->LoadItemData(GetEquipmentA());
	itemdata itemB = Game->LoadItemData(GetEquipmentB());
	
	if(GetEquipmentA()==0){
		Game->Counter[CR_ABUTTON]=0;
	}else if(Game->Counter[CR_ABUTTON]!=Game->Counter[itemA->Counter]){
		Game->Counter[CR_ABUTTON]=Game->Counter[itemA->Counter];
	}

	if(GetEquipmentB()==0){
		Game->Counter[CR_BBUTTON]=0;
	}else if(Game->Counter[CR_BBUTTON]!=Game->Counter[itemB->Counter]){
		Game->Counter[CR_BBUTTON]=Game->Counter[itemB->Counter];
	}
}



// global script active{
//    void run(){
//	  while(true){
//              Might have other stuff here...
//
//		SetCountersAB();
//
//	        Waitframe();
//	  }
//    }
//}