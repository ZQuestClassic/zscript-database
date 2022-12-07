const int SFX_FFCLOCKBLOCK = 9; //Sound that plays when the lock block is opened

//D0: The ID of the lock block (0-127). Uses screen D bits. 0-15 using bits on D[0], 1-31 on D[1], 32-47 on D[2], ect.
//D1: The combo flag marking combos that are copycat lock blocks
//D2: Type 0=Normal, 1=Boss, 2=Special Counter, 3=Item
//D3: Argument 1 based on D2. Can be Counter Type if D2 is 2 or Item ID if D2 is 3
//D4: Argument 2 based on D2. Can be Counter amount if D2 is 2 or whether to take the item if D2 is 3
ffc script FFCLockBlock{
	void run(int id, int secretFlag, int type, int arg1, int arg2){
		int x; int y; int i;
		
		if(type==2)
			arg2 = Max(1, arg2);
		
		//Uncheck flags and make the FFC invisible
		this->Flags[FFCF_CHANGER] = false;
		this->Flags[FFCF_LENSVIS] = false;
		
		this->Data = FFCS_INVISIBLE_COMBO;
		this->X = GridX(this->X+8);
		this->Y = GridY(this->Y+8);
		
		//Keep secretFlag clamped between valid values
		id = Clamp(id, 0, 127);
		int d = Floor(id/16);
		int dbit = 1<<(id%16);
		
		//If the lock is already opened
		if(Screen->D[d]&dbit){
			//Advance the combos and quit
			for(x=0; x<this->TileWidth; x++){
				for(y=0; y<this->TileHeight; y++){
					Screen->ComboD[ComboAt(this->X+8+16*x, this->Y+8+16*y)]++;
				}
			}
			if(secretFlag>0){
				for(i=0; i<176; i++){
					if(Screen->ComboF[i]==secretFlag){
						Screen->ComboD[i]++;
					}
				}
			}
			Quit();
		}
		
		int pushFrames = 7;
		//While the lock block is unopened
		while(true){
			//Check if Link has met the conditions to unlock the block
			if(LockBlock_CanUnlock(type, arg1, arg2)){
				//And is pushing against the lock block
				if(LockBlock_LinkPush(this)){
					//If he does this for 8 frames, open it and take a key
					if(pushFrames>0)
						pushFrames--;
					else{
						if(type==0){ //Regular lock
							if(Link->Item[I_MAGICKEY]){}
							else if(Game->LKeys[Game->GetCurLevel()]>0)
								Game->LKeys[Game->GetCurLevel()]--;
							else if(Game->Counter[CR_KEYS]>0)
								Game->Counter[CR_KEYS]--;
						}
						else if(type==2){ //Special counter
							Game->Counter[arg1] -= arg2;
						}
						else if(type==3){ //Item lock
							if(arg2)
								Link->Item[arg1] = false;
						}
						Game->PlaySound(SFX_FFCLOCKBLOCK);
						break;
					}
				}
				else
					pushFrames = 7;
			}
			else
				pushFrames = 7;
			Waitframe();
		}
		
		//Set Screen->D and advance the combos
		Screen->D[d] |= dbit;
		for(x=0; x<this->TileWidth; x++){
			for(y=0; y<this->TileHeight; y++){
				Screen->ComboD[ComboAt(this->X+8+16*x, this->Y+8+16*y)]++;
			}
		}
		if(secretFlag>0){
			for(i=0; i<176; i++){
				if(Screen->ComboF[i]==secretFlag){
					Screen->ComboD[i]++;
				}
			}
		}
	}
	//Function to check if Link can unlock a block based on the type
	bool LockBlock_CanUnlock(int type, int arg1, int arg2){
		if(type==0) //Regular lock
			return Game->LKeys[Game->GetCurLevel()]>0||Game->Counter[CR_KEYS]>0||Link->Item[I_MAGICKEY];
		else if(type==1) //Boss lock
			return Game->LItems[Game->GetCurLevel()]&LI_BOSSKEY;
		else if(type==2) //Special counter lock
			return Game->Counter[arg1]>=arg2;
		else if(type==3) //Item lock
			return Link->Item[arg1];
	}
	//Function to check if Link is pushing against a lock block
	bool LockBlock_LinkPush(ffc this){
		//Link can't open a lock block if it isn't solid
		if(CanWalk(Link->X, Link->Y, Link->Dir, 1, false))
			return false;
		//Check Link's position based on direction
		if(Link->Dir==DIR_UP&&Link->InputUp){
			if(Link->X>=this->X-8 && Link->X<=this->X+16*this->TileWidth-8 && Link->Y>=this->Y && Link->Y<=this->Y+16*this->TileHeight-8)
				return true;
		}
		else if(Link->Dir==DIR_DOWN&&Link->InputDown){
			if(Link->X>=this->X-8 && Link->X<=this->X+16*this->TileWidth-8 && Link->Y>=this->Y-16 && Link->Y<=this->Y+16*this->TileHeight-16)
				return true;
		}
		if(Link->Dir==DIR_LEFT&&Link->InputLeft){
			if(Link->X>=this->X && Link->X<=this->X+16*this->TileWidth && Link->Y>this->Y-8 && Link->Y<this->Y+16*this->TileHeight-8)
				return true;
		}
		if(Link->Dir==DIR_RIGHT&&Link->InputRight){
			if(Link->X>=this->X-16 && Link->X<=this->X+16*this->TileWidth-16 && Link->Y>this->Y-8 && Link->Y<this->Y+16*this->TileHeight-8)
				return true;
		}
		return false;
	}
}