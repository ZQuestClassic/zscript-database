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