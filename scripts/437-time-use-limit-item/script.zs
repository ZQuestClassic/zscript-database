const int STD_GLOBAL_RAM_CYCLETIMER = 0; //Index to global RAM array (std_vars.zh) used for cycle timer.

//Returns ID of item from itemdata pointer
int ItemID (itemdata it){
	for (int i=0; i<256; i++){
		itemdata n = Game->LoadItemData(i);
		if (it==n) return i;
	}
	return -1;
}

//Sets either time, or use count limit, after it expiring Link loses this item. Uses OnPickup item script slot.
//D0 - Global Ram Array index. Must be unique per limited item.
//D1 - Use count/Time limit, in seconds.
//D4 - pickup string.
//To set up use-limited items (like sword sharpening in Majora`s Mask), set UpdateItemDurability into OnAction script slot
//To set up time-limited item, insert UpdateItemTimer function with item ID matching it into UpdateTimeLimitItems function (global script combining)
item script SetItemLimit{
	void run(int ID, int count){
		std_zh___GlobalRAM[ID] = count;
		Screen->Message(this->InitD[4]);
	}
}

//Reduce counter per use and remove item, if it expires. Uses OnAction item script slot.
//D0 - Global Ram Array index. Must be unique per limited item.
//D1 - unused
//D2 - Sound to play, when item expires.
//D3 - Message string to display, when item expires.
item script UpdateItemDurability{
	void run(int ID, int count, int sfx, int str){
		Trace(std_zh___GlobalRAM[ID]);
		std_zh___GlobalRAM[ID] --;
		if(std_zh___GlobalRAM[ID] <= 0){
			int itemid = ItemID (this);
			Game->PlaySound(sfx);
			Screen->Message(str);
			Link->Item[itemid]=false;
		}
	}
}

global script TimeLimitItem{
	void run(){
		while(true){
			Waitdraw();
			UpdateTimeLimitItems();
			Waitframe();
		}
	}
}

void UpdateCycleTimer(){
	std_zh___GlobalRAM[STD_GLOBAL_RAM_CYCLETIMER] ++;
	if (std_zh___GlobalRAM[STD_GLOBAL_RAM_CYCLETIMER]>=60){
		std_zh___GlobalRAM[STD_GLOBAL_RAM_CYCLETIMER]=0;
	}
}

//Function for updating time-limited items. Must be called inside loop of global script.
void UpdateTimeLimitItems(){
	UpdateCycleTimer();
	
	UpdateItemTimer(1, 0, 0, 0);
}


//Reduce counter per second and remove item, if it expires. To be called inside UpdateTimeLimitItems() function 
//ID - Global Ram Array index. Must be unique per limited item.
//itemid - Item ID to affect.
//sfx - Sound to play, when item expires.
//str - Message string to display, when item expires.
void UpdateItemTimer(int ID, int itemid, int sfx, int str){
	if (std_zh___GlobalRAM[STD_GLOBAL_RAM_CYCLETIMER]==0){
		std_zh___GlobalRAM[ID] --;
		if(std_zh___GlobalRAM[ID] <= 0){
			Game->PlaySound(sfx);
			Screen->Message(str);
			Link->Item[itemid]=false;
		}
	}
}