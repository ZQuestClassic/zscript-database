global script Init{
	void run(){
		TestPlayInitData_Init();
	}
}

const int MAX_HEARTS = 24;
const int MAX_MAGIC = 16;

void TestPlayInitData_Init(){
	if(Debug->Testing){
		//Max out Link's HP and MP
		Link->MaxHP = MAX_HEARTS*16;
		Link->MaxMP = MAX_MAGIC*32;
		
		//Give all items
		for(int i=0; i<256; ++i){
			itemdata id = Game->LoadItemData(i);
			//Ignore ones that aren't equipment items
			if(id->EquipmentItem){
				Link->Item[i] = true;
				//If it increments a max counter, apply that increment
				if(id->MaxIncrement>Game->MCounter[id->Counter])
					Game->MCounter[id->Counter] = id->MaxIncrement;
			}
		}
		
		//Set all counters except keys to their max
		for(int i=0; i<32; ++i){
			if(i!=CR_KEYS)
				Game->Counter[i] = Game->MCounter[i];
		}
		
		//Set half magic
		Game->Generic[GEN_MAGICDRAINRATE] = 1;
		
		//Give level items
		for(int i=0; i<512; ++i){
			Game->LItems[i] = LI_MAP|LI_COMPASS|LI_TRIFORCE;
		}
	}
}