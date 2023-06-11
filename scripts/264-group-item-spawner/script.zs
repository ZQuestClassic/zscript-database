ffc script GroupItemSpawner{
	void run(int id, int flag, int screenD){
		item itemArray[16];
		bool itemValid[16];
		if(screenD>=0&&screenD<=7){ //If a valid Screen->D is being used, spawn the items based on its state
			int count; //Keep track of how many items are spawned
			for(int i=0; i<176; i++){
				if(flag<=0){ //If the flag is negative, check for a combo instead
					if(Screen->ComboD[i]==Abs(flag)){
						if(!(Screen->D[screenD]&(1<<count))){ //Check if the item has been picked up already
						itemArray[count] = CreateItemAt(id, ComboX(i), ComboY(i)); //If it hasn't create one
						}
						itemValid[count] = true; //This is mostly just here to prevent extra Screen->D bits being set if there aren't exactly 16 items onscreen
						count++; //Increase the count regardless of if the item was created
					}
				}
				else if(ComboFI(i, flag)){ //Find every instance of the flag
					if(!(Screen->D[screenD]&(1<<count))){ //Check if the item has been picked up already
						itemArray[count] = CreateItemAt(id, ComboX(i), ComboY(i)); //If it hasn't create one
					}
					itemValid[count] = true; //This is mostly just here to prevent extra Screen->D bits being set if there aren't exactly 16 items onscreen
					count++; //Increase the count regardless of if the item was created
				}
			}
			while(true){ //This part checks when the item is picked up in order to set the Screen->D bit marking it as such
				for(int i=0; i<16; i++){
					if(!(Screen->D[screenD]&(1<<i))&&itemValid[i]){ //Check if the bit is unset and there was at one point an item in there
						if(!itemArray[i]->isValid()){
							Screen->D[screenD] |= (1<<i); //When the item is picked up, set the bit
						}
					}
				}
				Waitframe();
			}
		}
		else{ //If no Screen->D is used, items always respawn and you can place as many as you want
			for(int i=0; i<176; i++){
				if(flag<=0){
					if(Screen->ComboD[i]==Abs(flag)){
						CreateItemAt(id, ComboX(i), ComboY(i));
					}
				}
				else if(ComboFI(i, flag)){ //Find every instance of the flag and create an item
					CreateItemAt(id, ComboX(i), ComboY(i));
				}
			}
		}
	}
}