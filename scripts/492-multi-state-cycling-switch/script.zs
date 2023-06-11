//Multi-state sequence switch. 
//When activated, change specific combos from given range to next in list, with cycling back to 1st, in case it goes beyond sequence.
//Stand on it and press EX1 to activate.
//Set up sequence of switchable combos.
//D0 - 1st combo in sequence
//D1 - number of combos in sequence
//D2 - add together: 1 - cwitch only combos with same CSet, as FFC itself. +2 - record switch state into screen D register
//D3 - Screen D register to track switch state.
//D4 - sound to play on activating switch.

ffc script MultistateCycleSwitch{
	void run(int origcmb, int numstates, int flags, int permD, int sound){
		int cmb=-1;
		int origpos = ComboAt (CenterX(this), CenterY(this));
		if ((flags&2)>0){
			for (int j=0;j<Screen->D[permD];j++){
				for (int i=0; i<176;i++){
					if (Screen->ComboD[i]<origcmb) continue;
					if (Screen->ComboD[i]>=origcmb+numstates) continue;
					if (Screen->ComboC[i]!=this->CSet && (flags&1)>0) continue;
					Screen->ComboD[i]++;
					if (Screen->ComboD[i]>=origcmb+numstates) Screen->ComboD[i]=origcmb;
					
				}
			}
		}
		while(true){
			cmb = ComboAt (CenterLinkX(), CenterLinkY());
			if (cmb==origpos){
				if (Link->PressEx1){
					Game->PlaySound(sound);
					for (int i=0; i<176;i++){
						if (Screen->ComboD[i]<origcmb) continue;
						if (Screen->ComboD[i]>=origcmb+numstates) continue;
						if (Screen->ComboC[i]!=this->CSet && (flags&1)>0) continue;
						Screen->ComboD[i]++;
						if (Screen->ComboD[i]>=origcmb+numstates) Screen->ComboD[i]=origcmb;
						
					}
					if ((flags&2)>0){
						Screen->D[permD]++;
						if (Screen->D[permD]>=numstates)Screen->D[permD]=0;
					}
				}
			}
			Waitframe();
		}
	}
}

const int CSET_COLORCYCLE_COLOR1 = 5;//CSets to define the 5 possible csets 
const int CSET_COLORCYCLE_COLOR2 = 7;
const int CSET_COLORCYCLE_COLOR3 = 8;
const int CSET_COLORCYCLE_COLOR4 = 10;
const int CSET_COLORCYCLE_COLOR5 = 11;
//Multi-state sequence CSet switch. 
//When activated, change CSets specific combos from given range to next in array (default to 5,7,8,10,11,), with cycling back to 1st in given sequence, in case it goes beyond sequence.
//Stand on it and press EX1 to activate.
//Place invisible FFC at switch location, assign CSet to 1st Cset in sequence. Default is CSET_COLORCYCLE_COLOR1 
//D0 - combo flag to define switchable combos
//D1 - number of csets in sequence (3 - 5)
//D2 - add together: 2 - record switch state into screen D register
//D3 - Screen D register to track switch state.
//D4 - sound to play on activating switch.
ffc script MultistateCycleColrSwitch{
	void run(int cflag, int numstates, int flags, int permD, int sound){
		int cmb=-1;
		int scet = -1;
		int csets[5] = { CSET_COLORCYCLE_COLOR1, CSET_COLORCYCLE_COLOR2, CSET_COLORCYCLE_COLOR3, CSET_COLORCYCLE_COLOR4, CSET_COLORCYCLE_COLOR5};
		int origpos = ComboAt (CenterX(this), CenterY(this));
		int origscet = 0;
		for (int c=0; c<5; c++){
			if (csets[c] == this->CSet)origscet=c;
		}
		if ((flags&2)>0){
			for (int i=0; i<176;i++){
				scet = -1;
				if (!ComboFI(i, cflag)) continue;
				for (int c=0; c<5; c++){
					if (csets[c] == Screen->ComboC[i])scet=c;
				}
				if (scet<0)continue;
				scet+=Screen->D[permD];
				if ((scet-origscet)>=numstates)scet-=numstates;
				if (scet>=5)scet=0;
				Screen->ComboC[i]=csets[scet];					
			}
		}
		while(true){
			cmb = ComboAt (CenterLinkX(), CenterLinkY());
			if (cmb==origpos){
				if (Link->PressEx1){
					Game->PlaySound(sound);				
					for (int i=0; i<176;i++){
						scet = -1;
						if (!ComboFI(i, cflag)) continue;
						for (int c=0; c<5; c++){
							if (csets[c] == Screen->ComboC[i])scet=c;
						}
						if (scet<0)continue;
						scet++;
						if ((scet-origscet)>=numstates)scet-=numstates;
						if (scet<0)scet+=5;
						if (scet>=5)scet=0;
						Screen->ComboC[i]=csets[scet];					
					}
					if ((flags&2)>0){
						Screen->D[permD]++;
						if (Screen->D[permD]>=numstates)Screen->D[permD]=0;
					}
				}
			}
			Waitframe();
		}
	}
}

int ArrayMatch(int arr, int value){
	for (int i=0; i<SizeOfArray(arr); i++){
		if (arr[i] == value) return i;
	}
	return -1;
}