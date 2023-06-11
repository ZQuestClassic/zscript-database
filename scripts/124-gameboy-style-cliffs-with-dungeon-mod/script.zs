const int CT_CLIFF = 142; //This is the combo type used for the cliffs. Look in std_constants.zh for reference. It's Script 1 (142) by default.
const int CLIFF_PAUSE = 15; //This is the number of frames (60ths of a second) Link must walk into the cliff before jumping

ffc script GBCliff{
	bool CheckCliffDirection(int Combo){
		int Dir;
		if(Screen->ComboS[Combo]==0101b)
			Dir = DIR_UP;
		else if(Screen->ComboS[Combo]==1010b)
			Dir = DIR_DOWN;
		else if(Screen->ComboS[Combo]==0011b)
			Dir = DIR_LEFT;
		else if(Screen->ComboS[Combo]==1100b)
			Dir = DIR_RIGHT;
		else
			return false;
		if(Dir==Link->Dir)
			return true;
		return false;
	}
	void run(){
		int PushCounter = 0;
		while(true){
			if(Link->Dir==DIR_UP&&!CanWalk(Link->X, Link->Y, DIR_UP, 1, false)&&Link->InputUp&&Screen->ComboT[ComboAt(Link->X+8, Link->Y+14)]==CT_CLIFF&&CheckCliffDirection(ComboAt(Link->X+8, Link->Y+14))&&(Link->Action==LA_WALKING||Link->Action==LA_NONE)){
				PushCounter++;
				if(PushCounter>=CLIFF_PAUSE){
					Game->PlaySound(SFX_JUMP);
					Link->Jump = 2;
					int Y = Link->Y;
					for(int i=0; i<26; i++){
						Y -= 0.61;
						Link->Y = Y;
						WaitNoAction();
					}
					PushCounter = 0;
				}
			}
			else if(Link->Dir==DIR_DOWN&&!CanWalk(Link->X, Link->Y, DIR_DOWN, 1, false)&&Link->InputDown&&Screen->ComboT[ComboAt(Link->X+8, Link->Y+12)]==CT_CLIFF&&CheckCliffDirection(ComboAt(Link->X+8, Link->Y+12))&&(Link->Action==LA_WALKING||Link->Action==LA_NONE)){
				PushCounter++;
				if(PushCounter>=CLIFF_PAUSE){
					Game->PlaySound(SFX_JUMP);
					Link->Jump = 1;
					int Combo = ComboAt(Link->X+8, Link->Y+12);
					int CliffHeight = 1;
					for(int i=1; i<11; i++){
						if(Screen->isSolid(ComboX(Combo)+8, ComboY(Combo)+8+16*i))
							CliffHeight++;
						else
							break;
					}
					Link->Z = CliffHeight*16;
					Link->Y += CliffHeight*16;
					while(Link->Z>0){
						WaitNoAction();
					}
					PushCounter = 0;
				}
			}
			else if(Link->Dir==DIR_LEFT&&!CanWalk(Link->X, Link->Y, DIR_LEFT, 1, false)&&Link->InputLeft&&Screen->ComboT[ComboAt(Link->X+4, Link->Y+8)]==CT_CLIFF&&CheckCliffDirection(ComboAt(Link->X+4, Link->Y+8))&&(Link->Action==LA_WALKING||Link->Action==LA_NONE)){
				PushCounter++;
				if(PushCounter>=CLIFF_PAUSE){
					Game->PlaySound(SFX_JUMP);
					Link->Jump = 2;
					int X = Link->X;
					for(int i=0; i<26; i++){
						X -= 0.92;
						if(i==13){
							Link->Z += 16;
							Link->Y += 16;
						}
						Link->X = X;
						WaitNoAction();
					}
					while(Link->Z>0){
						WaitNoAction();
					}
					PushCounter = 0;
				}
			}
			else if(Link->Dir==DIR_RIGHT&&!CanWalk(Link->X, Link->Y, DIR_RIGHT, 1, false)&&Link->InputRight&&Screen->ComboT[ComboAt(Link->X+12, Link->Y+8)]==CT_CLIFF&&CheckCliffDirection(ComboAt(Link->X+12, Link->Y+8))&&(Link->Action==LA_WALKING||Link->Action==LA_NONE)){
				PushCounter++;
				if(PushCounter>=CLIFF_PAUSE){
					Game->PlaySound(SFX_JUMP);
					Link->Jump = 2;
					int X = Link->X;
					for(int i=0; i<26; i++){
						X += 0.92;
						if(i==13){
							Link->Z += 16;
							Link->Y += 16;
						}
						Link->X = X;
						WaitNoAction();
					}
					while(Link->Z>0){
						WaitNoAction();
					}
					PushCounter = 0;
				}
			}
			else{
				PushCounter = 0;
			}
			Waitframe();
		}
	}
}

ffc script GBDungeonCliff{
	void run(int CliffCombo){
		int PushCounter = 0;
		while(true){
			if(Link->Dir==DIR_UP&&!CanWalk(Link->X, Link->Y, DIR_UP, 1, false)&&Link->InputUp&&Screen->ComboD[ComboAt(Link->X+8, Link->Y+7)]==CliffCombo&&(Link->Action==LA_WALKING||Link->Action==LA_NONE)){
				PushCounter++;
				if(PushCounter>=CLIFF_PAUSE){
					Game->PlaySound(SFX_JUMP);
					Link->Jump = 2;
					int Y = Link->Y;
					for(int i=0; i<26; i++){
						Y -= 0.92;
						Link->Y = Y;
						WaitNoAction();
					}
					PushCounter = 0;
				}
			}
			else if(Link->Dir==DIR_DOWN&&!CanWalk(Link->X, Link->Y, DIR_DOWN, 1, false)&&Link->InputDown&&Screen->ComboD[ComboAt(Link->X+8, Link->Y+16)]==CliffCombo+1&&(Link->Action==LA_WALKING||Link->Action==LA_NONE)){
				PushCounter++;
				if(PushCounter>=CLIFF_PAUSE){
					Game->PlaySound(SFX_JUMP);
					Link->Jump = 1;
					int Combo = ComboAt(Link->X+8, Link->Y+12);
					int CliffHeight = 1;
					for(int i=1; i<11; i++){
						if(Screen->isSolid(ComboX(Combo)+8, ComboY(Combo)+8+16*i))
							CliffHeight++;
						else
							break;
					}
					Link->Z = CliffHeight*16-8;
					Link->Y += CliffHeight*16-8;
					while(Link->Z>0){
						WaitNoAction();
					}
					PushCounter = 0;
				}
			}
			else if(Link->Dir==DIR_LEFT&&!CanWalk(Link->X, Link->Y, DIR_LEFT, 1, false)&&Link->InputLeft&&Screen->ComboD[ComboAt(Link->X-1, Link->Y+8)]==CliffCombo+2&&(Link->Action==LA_WALKING||Link->Action==LA_NONE)){
				PushCounter++;
				if(PushCounter>=CLIFF_PAUSE){
					Game->PlaySound(SFX_JUMP);
					Link->Jump = 2;
					int X = Link->X;
					for(int i=0; i<26; i++){
						X -= 1.23;
						Link->X = X;
						WaitNoAction();
					}
					PushCounter = 0;
				}
			}
			else if(Link->Dir==DIR_RIGHT&&!CanWalk(Link->X, Link->Y, DIR_RIGHT, 1, false)&&Link->InputRight&&Link->InputRight&&Screen->ComboD[ComboAt(Link->X+16, Link->Y+8)]==CliffCombo+3&&(Link->Action==LA_WALKING||Link->Action==LA_NONE)){
				PushCounter++;
				if(PushCounter>=CLIFF_PAUSE){
					Game->PlaySound(SFX_JUMP);
					Link->Jump = 2;
					int X = Link->X;
					for(int i=0; i<26; i++){
						X += 1.23;
						Link->X = X;
						WaitNoAction();
					}
				}
			}
			else{
				PushCounter = 0;
			}
			Waitframe();
		}
	}
}

item script Frogforce{
	void run(){
		Game->End();
	}
}