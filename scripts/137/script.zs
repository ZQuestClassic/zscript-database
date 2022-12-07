ffc script FFCRaft{
	bool CheckWater(int x, int y){
		int c = Screen->ComboT[ComboAt(x, y)];
		if(c==CT_WATER||c==CT_SWIMWARP||c==CT_DIVEWARP||(c>=CT_SWIMWARPB&&c<=CT_SWIMWARPD)||(c>=CT_DIVEWARPB&&c<=CT_DIVEWARPD))
			return true;
		else
			return false;
	}
	bool CanPlaceRaft(int X, int Y){
		for(int x=0; x<3; x++){
			for(int y=0; y<3; y++){
				if(!CheckWater(X+x*7.5, Y+y*7.5))
					return false;
			
			}
		}
		return true;
	}
	void run(){
		int SavedDMap = Game->GetCurDMap();
		int SavedScreen = Game->GetCurScreen();
		int StartX = this->X;
		int StartY = this->Y;
		int DrownX = -1;
		int DrownY = -1;
		int NewScreenCounter = -1;
		this->Flags[FFCF_PRELOAD] = true;
		while(true){
			while(!SquareCollision(Link->X+4, Link->Y+4, 8, this->X+4, this->Y+4, 8)){
				if(Link->Action==LA_DROWNING&&DrownX>-1){
					this->X = DrownX;
					this->Y = DrownY;
				}
				else if(Link->Action==LA_DROWNING){
					this->X = StartX;
					this->Y = StartY;
				}
				Waitframe();
			}
			this->Flags[FFCF_CARRYOVER] = true;
			while(true){
				if(Link->Action==LA_SWIMMING)
					Link->Action = LA_WALKING;
				if(Link->Action==LA_DROWNING&&DrownX>-1){
					this->X = DrownX;
					this->Y = DrownY;
				}
				else if(Link->Action==LA_DROWNING){
					this->X = StartX;
					this->Y = StartY;
				}
				else if(CanPlaceRaft(Link->X, Link->Y)){
					this->X = Link->X;
					this->Y = Link->Y;
				}
				else if(CanPlaceRaft(GridX(Link->X+8), Link->Y)){
					this->X = GridX(Link->X+8);
					this->Y = Link->Y;
				}
				else if(CanPlaceRaft(Link->X, GridY(Link->Y+8))){
					this->X = Link->X;
					this->Y = GridY(Link->Y+8);
				}
				if((SavedDMap!=Game->GetCurDMap()||SavedScreen!=Game->GetCurScreen())&&Link->Action!=LA_SCROLLING){
					Link->Action = LA_NONE;
					SavedDMap = Game->GetCurDMap();
					SavedScreen = Game->GetCurScreen();
					for(int i=1; i<32; i++){
						ffc f = Screen->LoadFFC(i);
						if(f->Script==this->Script&&f!=this){
							f->Data = 0;
							f->Script = 0;
						}
					}
					if((Link->X==0&&Link->Y==0)||(Link->X==240&&Link->Y==0)||(Link->X==0&&Link->Y==160)||(Link->X==240&&Link->Y==160)){
						if(Link->Dir==DIR_LEFT)
							this->X = 240;
						else if(Link->Dir==DIR_RIGHT)
							this->X = 0;
						else if(Link->Dir==DIR_UP)
							this->Y = 160;
						else if(Link->Dir==DIR_DOWN)
							this->Y = 0;
					}
					else{
						if(Link->X==0)
							this->X = 240;
						else if(Link->X==240)
							this->X = 0;
						if(Link->Y==0)
							this->Y = 160;
						else if(Link->Y==160)
							this->Y = 0;
					}
					NewScreenCounter = 1;
				}
				else if(NewScreenCounter>0)
					NewScreenCounter--;
				else if(NewScreenCounter==0){
					Link->Action = LA_NONE;
					DrownX = Link->X;
					DrownY = Link->Y;
					NewScreenCounter = -1;
				}
				if(!SquareCollision(Link->X+4, Link->Y+4, 8, this->X+4, this->Y+4, 8)&&NewScreenCounter==-1){
					break;
				}
				Waitframe();
			}
			this->Flags[FFCF_CARRYOVER] = false;
		}
	}
}