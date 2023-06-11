const int SFX_EDGEMATCH_MOVE=16; //Sounв to play on rotating tile.

//3*3 rotating tiles. Match connecting pixels to open secrets.
//Place 3*3 FFCs spaced so their centers are speced apart by 2 combos. Check demo quest to see how combos are set up
//Import and compile the script. Nothing beyond default stuff is need.
//D0-D3 edge IDs, up, right, down and left. For puzzle to be solved, all IDs on adjacent FFCs must match. 
//For instance One FFC has D0 to 1 and same number on another FFCs D2.
//D4 - Set to 1 for FFC to be able to be rotated.
//D5 - Set to 1 to prevent initial rotation randomization of this FFC.
//Must set "Run Script at Screen Init" and "Only Visible to Lens of Truth" flags. 

ffc script EdgeMatcher{
	void run (int rotup, int rotright, int rotdown, int rotleft, int rot, int norando){
		int rotate[4] = {rotup, rotright, rotdown, rotleft};
		int cmb = ComboAt(CenterX(this), CenterY(this));
		this->X = ComboX(cmb);
		this->Y = ComboY(cmb);
		this->TileWidth=1;
		this->TileHeight=1;
		int origdata = this->Data;
		this->Data = FFCS_INVISIBLE_COMBO;
		int rottimer=0;
		int rotcount=0;
		int randrotate[4];
		for (int i=0;i<4;i++) randrotate[i]=rotate[i];
		if ((rot>0)&&(norando==0)){
			this->InitD[7]=1;
			while(this->InitD[7]>0){
				for (int i=0;i<4;i++) randrotate[i]=rotate[i];
				int Rnd=Rand(3);
				rotcount=Rnd;
				for (int i=0;i<Rnd;i++){
					ArrayShiftRight(randrotate);
					for (int i=0; i<4; i++){
						this->InitD[i] = randrotate[i];
					}
				}			
				for (int i=0;i<=3;i++){
					int adjcmb=-1;
					if ( i==0) adjcmb = AdjacentComboFix(cmb, DIR_UP, 2);
					if ( i==1) adjcmb = AdjacentComboFix(cmb, DIR_RIGHT, 2);
					if ( i==2) adjcmb = AdjacentComboFix(cmb, DIR_DOWN, 2);
					if ( i==3) adjcmb = AdjacentComboFix(cmb, DIR_LEFT, 2);
					//Screen->Rectangle(3, ComboX(adjcmb), ComboY(adjcmb), ComboX(adjcmb)+15, ComboY(adjcmb)+15, 1, -1, 0, 0, 0, false, OP_OPAQUE);
					if (adjcmb<0) continue;
					for (int j=1;j<=32;j++){
						ffc f = Screen->LoadFFC(j);
						if (f->Script!=this->Script) continue;
						if (f->X!= ComboX(adjcmb)) continue;
						if (f->Y!= ComboY(adjcmb)) continue;
						int checkdir = i+2;
						if (checkdir>3) checkdir-=4;
						if (f->InitD[checkdir]!=this->InitD[i]){
							this->InitD[7]=0;
							break;
						}
					}
				}
				Waitframe();
			}
		} 
		else if(rot==0) this->InitD[7]=1;
		for (int i=0; i<4; i++){
			rotate[i]=randrotate[i];
			this->InitD[i] = randrotate[i];
		}
		while(true){
			if (rottimer==0){
				if(LinkCollision(this)&&(Link->PressEx1)&&(rot>0)){
					Game->PlaySound(16);
					rottimer = 30;
					this->InitD[7]=0;
					rotcount++;
					if (rotcount>=4) rotcount=0;
				}
			}
			else {
				if (rottimer>0)rottimer--;
				if (rottimer==0){
					ArrayShiftRight(rotate);
					for (int i=0; i<4; i++){
						this->InitD[i] = rotate[i];
					}
					for (int i=0;i<=3;i++){
						int adjcmb=-1;
						if ( i==0) adjcmb = AdjacentComboFix(cmb, DIR_UP, 2);
						if ( i==1) adjcmb = AdjacentComboFix(cmb, DIR_RIGHT, 2);
						if ( i==2) adjcmb = AdjacentComboFix(cmb, DIR_DOWN, 2);
						if ( i==3) adjcmb = AdjacentComboFix(cmb, DIR_LEFT, 2);
						//Screen->Rectangle(3, ComboX(adjcmb), ComboY(adjcmb), ComboX(adjcmb)+15, ComboY(adjcmb)+15, 1, -1, 0, 0, 0, false, OP_OPAQUE);
						if (adjcmb<0) continue;
						for (int j=1;j<=32;j++){
							ffc f = Screen->LoadFFC(j);
							if (f->Script!=this->Script) continue;
							if (f->X!= ComboX(adjcmb)) continue;
							if (f->Y!= ComboY(adjcmb)) continue;
							int checkdir = i+2;
							if (checkdir>3) checkdir-=4;
							if (f->InitD[checkdir]!=this->InitD[i]){
								this->InitD[7]=0;
								break;
							}
							this->InitD[7]=1;
						}
					}
					for (int j=1;j<=33;j++){
						if (Screen->State[ST_SECRET]) break;
						else if (j==33){
							Game->PlaySound(SFX_SECRET);
							Screen->TriggerSecrets();
							Screen->State[ST_SECRET]=true;
							break;
						}
						ffc f = Screen->LoadFFC(j);
						if (f->Script!=this->Script) continue;
						if (f->InitD[7]==0)	break;
					}
				}					
			}
			if (this->InitD[7]>0)Screen->Rectangle(5, this->X, this->Y, this->X+15, this->Y+15, 0x81, -1, 0,0, 0, false, OP_OPAQUE);
			Screen->DrawCombo(2-rot, this->X-16, this->Y-16, origdata, 3, 3, this->CSet, -1, -1, this->X-16, this->Y-16, rotcount*90-rottimer*3, 0, 0,true, OP_OPAQUE);
			Waitframe();
		}
	}
}

//Returns the combo ID of a combo based on a location, in a givem direction, N combos away.
int AdjacentComboFix(int cmb, int dir, int dist)
{
	int combooffsets[13]={-0x10, 0x10, -1, 1, -0x11, -0x0F, 0x0F, 0x11};
	if ( cmb % 16 == 0 ) combooffsets[9] = -1;
	if ( (cmb % 16) == 15 ) combooffsets[10] = -1; 
	if ( cmb < 0x10 ) combooffsets[11] = -1; //if it's the top row
	if ( cmb > 0x9F ) combooffsets[12] = -1; //if it's on the bottom row
	if ( combooffsets[9] && ( dir == DIR_LEFT || dir == DIR_LEFTUP || dir == DIR_LEFTDOWN || dir == DIR_LEFTUP ) ) return -1; //if the left columb
	if ( combooffsets[10] && ( dir == DIR_RIGHT || dir == DIR_RIGHTUP || dir == DIR_RIGHTDOWN ) ) return -1; //if the right column
	if ( combooffsets[11] && ( dir == DIR_UP || dir == DIR_RIGHTUP || dir == DIR_LEFTUP || dir == DIR_LEFTUP ) ) return -1; //if the top row
	if ( combooffsets[12] && ( dir == DIR_DOWN || dir == DIR_RIGHTDOWN || dir == DIR_LEFTDOWN ) ) return -1; //if the bottom row
	else if ( cmb >= 0 && cmb < 176 ) 
	{
		int cmbs[2];//needs a for loop to ensure that t returns the most valid combo
	    
		for ( cmbs[1] = 0; cmbs[1] < dist; cmbs[1]++ ) 
		{
			cmbs[0] = cmb;
			cmb += (combooffsets[dir]);
			if ( cmb < 0 || cmb > 175 ) return -1;
			if ( cmb % 16 == 0 ) combooffsets[9] = -1;
			if ( (cmb % 16) == 15 ) combooffsets[10] = -1;  
			if ( cmb < 0x10 ) combooffsets[11] = -1; //if it's the top row
			if ( cmb > 0x9F ) combooffsets[12] = -1; //if it's on the bottom row
			if ( combooffsets[9] && ( dir == DIR_LEFT || dir == DIR_LEFTUP || dir == DIR_LEFTDOWN || dir == DIR_LEFTUP ) ) return -1; //if the left columb
			if ( combooffsets[10] && ( dir == DIR_RIGHT || dir == DIR_RIGHTUP || dir == DIR_RIGHTDOWN ) ) return -1; //if the right column
			if ( combooffsets[11] && ( dir == DIR_UP || dir == DIR_RIGHTUP || dir == DIR_LEFTUP || dir == DIR_LEFTUP ) ) return -1; //if the top row
			if ( combooffsets[12] && ( dir == DIR_DOWN || dir == DIR_RIGHTDOWN || dir == DIR_LEFTDOWN ) ) return -1; //if the bottom row
			
		}
		return cmb;
	}
	else return -1;
} 

void ArrayShiftRight(int arr){
	int lasti = SizeOfArray(arr)-1;
	int res = arr[lasti];
	for(int i = lasti; i>0; i--){
		arr[i] = arr[i-1];
	}
	arr[0]=res;
}

void ArrayShiftLeft(int arr){
	int lasti = SizeOfArray(arr)-1;
	int res = arr[0];
	for(int i = 0; i<lasti; i++){
		arr[i] = arr[i+1];
	}
	arr[lasti]=res;
}