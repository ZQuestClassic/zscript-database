const int LI_STONEBEAK = 0x20;// Test expanded level item

//Sets the state of level specific item. Litem ID must be a power of 2, or you will work with multiple items at once.
void SetLevelSpecificItem(int level, int litem, bool remove){
	if (!remove) Game->LItems[level] += litem;
	else Game->LItems[level] -= litem;
}
//Returns true, if Link has all of the level items, Ored together in litem. 
//For instance, if litem is 14, the function will return true only if Link has map, compass and boss key of the given level.
bool GetLevelSpecificItem(int level, int litem){
	return (Game->LItems[level]&litem) >0;
}

//Grants Link Level specific item/s (ORed together) for all levels.
void SetMagicLevelSpecificItem(int level, int litem){
	for(int i=0; i<512;i++){
		Game->LItems[level]&=litem;
	}
}

//Item script that grants level specific items.
//D0 - Litem ID. Must be a power of 2, or you will give Link multiple items at once.
//D1 - Message string ID.
item script LevelItem{
	void run(int id, int msg){
		Screen->Message(msg);
		int level = Game->GetCurLevel();
		SetLevelSpecificItem(level, id, false);
	}
}

//Link`s Awakening bird statue. If Link inserts stone beak from the same level, it displays message.
//Place at bird statue`s location.
//D0 - Message ID.
ffc script LAHintBirdStatue{
	void run(int msg){
		int level = Game->GetCurLevel();
		while(true){
			if (LinkCollision(this)&&(Link->PressA)){
				if (GetLevelSpecificItem(level, LI_STONEBEAK))
				 Screen->Message(msg);
			}
			Waitframe();
		}
	}	
}