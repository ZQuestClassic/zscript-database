//This script requires a bit of setup, but not to much. Thanks to Avataro and Dimentio for their help on this small project.
//You must make one sword itemclass item.
//The Pickup Script needs to be attached to the Pickup slot, while the Action Script should be attached to the action slot.
//This setup only needs to be done once. See the Example Quest for more information.

import "std.zh"

const int SWORD_ITEM_ID       = 0;  //The Item ID of the Razor Sword.
const int SWORD_USEABLE_TIMES = 0;  //The times you want the sword to be useable before it breaks.
const int PICKUP_STRING       = 0;  //The Pickup String that shows upon getting the sword.
const int LOSE_SWORD_STRING   = 0;  //The String that notifies you when your sword breaks.
const int ERROR_SFX           = 0;  //The SFX that is heard when the weapon breaks.

int sword_counter = 0;                          //Declare a counter that keeps track of your sword swings.

global script slot_2{                           //Global script.
	void run(){                             //The void run.
		while(true){                    //While(true) loop.
			check_sword();          //Calls the check_sword function.
			Waitframe();            //Add Waitframe or ZC freezes! D:
		}                               //End of While(true) loop.
	}                                       //End of void run().
}                                               //End of Global Script.


void check_sword(){                                   //Initialize check_sword function.
	if(sword_counter == SWORD_USEABLE_TIMES){     //If the sword counter is equal to the value of the sword's                                                                        useable times...
		Link->Item[SWORD_ITEM_ID] = false;    //Take the Razor Sword from Link's Inventory.
		sword_counter = 0;                    //Reset the sword counter.
		Game->PlaySound(ERROR_SFX);           //Play an error sound or whatever for fun!
		Screen->Message(LOSE_SWORD_STRING);   //Show a string that notifies you that your sword broke.
	}                                             //End of the If statement.
}                                                     //End of the check_sword function.

 
item script Razor_Sword_Pickup{                       //Initialize the item script for the item's pickup action.
	void run(){                                   //Yet again, another void run.
		sword_counter = 0;                    //Upon getting the item, this resets the sword counter.
		Screen->Message(PICKUP_STRING);       //The game shows a message about "You got a million dollars!".
	}                                             //End of void run().
}                                                     //End of the item script.


item script Razor_Sword_Action{                       //Initialize the item script for the Razor Sword.
	void run(){                                   //EGAD! Another void run()!
		sword_counter++;                      //Each time you use the sword, the counter goes up by one.
	}                                             //End of void run().
}                                                     //End of the item script.