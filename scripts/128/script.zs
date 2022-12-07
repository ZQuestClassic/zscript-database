import "std.zh"
import "stdExtra.zh"
import "string.zh"
import "ffcscript.zh"

// D0: Index of the Screen->D variable to store donation amount
	// Can be shared between multiple tiles of different amounts
// D1: The amount to donate
// D2: The total amount of money before getting the reward
// D3: Reward item
// D4: Message to play when donating
// D5: Message to play when you get the item
ffc script donationTile{
	void run(int d, int amount, int total, int reward, int successMessage, int itemGetMessage){
		// Find out how much has been donated so far
		int startingAmount = Screen->D[d];
		
		// Until all the money has been donated,
		// or money has been donated since entering the screen
		while(Screen->D[d] < total && Screen->D[d] == startingAmount){
			
			// If Link touches FFC and has enough money
			if(DistanceLink(this) < 8 && Game->Counter[CR_RUPEES] >= amount){
				Screen->Message(successMessage);
				
				Game->Counter[CR_RUPEES] -= amount;
				Screen->D[d] += amount;
				
				// If the money exceeds the total
				if(Screen->D[d] >= total){
					WaitNoAction(60);
					holdUpItem(reward, true, true, true);
					Screen->Message(itemGetMessage);
				}
			}
			
			// Draw amount below FFC
			Screen->DrawInteger(0, this->X, this->Y + 24, FONT_Z1, COLOR_WHITE, -1, 16, 16, amount, 0, OP_OPAQUE);
			
			Waitframe();
		}
		this->Data = 0;
	}
}