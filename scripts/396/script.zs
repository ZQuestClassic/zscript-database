ffc script SecretItem{
	void run(int ItemID){
		
		if(ItemID == 0) ItemID = Screen->RoomData;
		
		while(!Screen->State[ST_SECRET]){
			
			Waitframe();
		}
		
		if(!Screen->State[ST_ITEM]){
			
			item THE_ITEM = Screen->CreateItem(ItemID);
			THE_ITEM->X = this->X;
			THE_ITEM->Y = this->Y;
			THE_ITEM->Pickup = IP_ST_ITEM;
			
		}
		
	}
}