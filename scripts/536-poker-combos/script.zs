const int POKER_COMBOS_DEBUG_STUFF = 0;//>0 - render debug stuff

//Poker Combos
//Use any methods to change combos in that set. Form the given poker combination on all sets to solve the puzzle.

//Requires poker.zh
//Sny combo changing methods work
//Set up sequence of combos that can form poker combination
//Place next to puzzle area
//D0 - 1st combo of poker sequence
//D1 - number of combos in poker sequence
//D2 - direction of poker line
//D3 -combintion type
// D3 = 0 - Longest set must be that long or longer
//   D4 - number of same kind, D5 - target number forming set (i.e 3 6s), if D6 is odd - target set must be exactly D4 long (i,e, 4 4s, and extra 4 is failure). If D6 is <2, any extra sets will fail the check. For instance 5 elements contain 3 of a kind and remaining 2 enemies must mismatch to solve.
// D3 = 1 - Number of sets. D4 - set size, D5 numberof sets. if D6 is even, larger set sizes are allowed. Example - 3 pairs, more pairs are allowed if D6 is even, but quads here don`t count.
// D3 = 2 - Full House - all cards are part of sets, D4- maximum set length, D5 - min set length, D6 is odd -> hand must contain one set on minimum length, if specified, and 1 set of max length, if specified.
// D3 = 3 - Straight - sequence of ranks - D4 - number of elements in sequence. if D6 is even, longer sequences also count.

ffc script PokerCombos{
	void run(int origtile, int numcmb,int dir, int combination, int miscval1, int miscval2, int flags){
		if (Screen->State[ST_SECRET])Quit();
		if (origtile==0)origtile = this->Data;
		int cmb = ComboAt(CenterX(this), CenterY(this));
		int adjcmb[8];
		for (int i=0;i<8;i++){
			if (i==0){
				adjcmb[i] = AdjacentComboFix(cmb, dir);
				continue;
			}
			if (adjcmb[i-1]<0){
				adjcmb[i] = -1;
				continue;
			}
			if (i>=numcmb)adjcmb[i]=-1;
			else adjcmb[i] = AdjacentComboFix(adjcmb[i-1],dir);
		}
		// for (int i=0;i<8;i++){
			// Trace(adjcmb[i]);
		// }
		// TraceNL();
		int temp=0;
		int curcmb[8];
		for (int i=0;i<8;i++){
			if (adjcmb[i]<0) curcmb[i] = -1;
			else {
				temp=adjcmb[i];
				curcmb[i]=Screen->ComboD[temp];
			}
		}
		// for (int i=0;i<8;i++){
			// Trace(curcmb[i]);
		// }
		// TraceNL();
		int poker[8];
		for (int i=0;i<8;i++){
			if (i>=numcmb){
				poker[i]=-1;
				continue;
			}
			if (curcmb[i]<origtile){
				poker[i]=0;
				continue;
			}
			if (curcmb[i]>(origtile+numcmb)){
				poker[i]=0;
				continue;
			}
			poker[i] = curcmb[i]-origtile + 1;
		}
		for (int i=0;i<8;i++){
			// Trace(poker[i]);
		}
		bool exact = (flags&1)>0;
		bool allowothersets = (flags&2)>0;
		bool ready = false;
		bool changed = false;
		bool fit=false;
		bool ex = (flags&1) >0;
		bool side = (flags&2) >0;
		// TraceNL();
		while(true){
			changed = false;
			ready = false;
			for (int i=0;i<numcmb;i++){
				temp=adjcmb[i];
				if (Screen->ComboD[temp]!= curcmb[i]){
					curcmb[i]=Screen->ComboD[temp];
					changed=true;
				}
			}
			if (changed){
				this->InitD[7]=0;
				for (int i=0;i<numcmb;i++){
					if (i>=numcmb){
						poker[i]=-1;
						continue;
					}
					if (curcmb[i]<origtile){
						poker[i]=0;
						continue;
					}
					if (curcmb[i]>(origtile+numcmb)){
						poker[i]=0;
						continue;
					}
					poker[i] = curcmb[i]-origtile + 1;
				}
				for (int i=0;i<numcmb;i++){
					if (poker[i]<=0)break;
					if (i==(numcmb-1))ready=true;
				}
			}
			if (ready){
				if (combination==0){
					fit = IsNoaKind(poker, miscval1, ex, side, miscval2);
				}
				if (combination==1){
					if (!side)fit = GetNumSets(poker, miscval1, Cond(ex, miscval1, 10))== miscval2;
					else fit = GetNumSets(poker, miscval1, Cond(ex, miscval1, 10))>= miscval2;
				}
				if (combination==2){
					fit = IsMultiFullHouse(poker, miscval1, miscval2,ex);
				}
				if (combination==3){
					if (ex) fit = GetBestSequence(poker)==miscval1;
					else fit = GetBestSequence(poker)>=miscval1;
				}
				if (fit){
					this->InitD[7]=1;
					for(int i=1;i<=33;i++){
						if (Screen->State[ST_SECRET]) break;
						if (i==33){
							Game->PlaySound(SFX_SECRET);
							Screen->TriggerSecrets();
							Screen->State[ST_SECRET]=true;
							Quit();
						}
						ffc n = Screen->LoadFFC(i);
						if (n->Script!=this->Script)continue;
						if (n->InitD[7] == 0) break;
					}					
				}
				else ready = false;
			}
			if (Screen->State[ST_SECRET])Quit();
			for (int i=0;i<numcmb;i++){
				if (POKER_COMBOS_DEBUG_STUFF>0)Screen->DrawInteger(2, ComboX(adjcmb[i]), ComboY(adjcmb[i]),0, Cond(this->InitD[7]>0, 6,1),0 , -1, -1, poker[i], 0, OP_OPAQUE);
			}
			// if (this->InitD[7]>0 && POKER_COMBOS_DEBUG_STUFF>0)Screen->DrawInteger(1, this->X, this->Y,0, 1,0 , -1, -1, 32, 0, OP_OPAQUE);
			Waitframe();
		}
	}
}

Fixed variant of AdjacentCombo function from std_extension.zh
int AdjacentComboFix(int cmb, int dir)
{
int combooffsets[13]={-0x10, 0x10, -1, 1, -0x11, -0x0F, 0x0F, 0x11};
if ( cmb % 16 == 0 ) combooffsets[9] = -1;//if it's the left edge
if ( (cmb % 16) == 15 ) combooffsets[10] = -1; //if it's the right edge
if ( cmb < 0x10 ) combooffsets[11] = -1; //if it's the top row
if ( cmb > 0x9F ) combooffsets[12] = -1; //if it's on the bottom row
if ( combooffsets[9]==-1 && ( dir == DIR_LEFT || dir == DIR_LEFTUP || dir == DIR_LEFTDOWN ) ) return -1; //if the left columb
if ( combooffsets[10]==-1 && ( dir == DIR_RIGHT || dir == DIR_RIGHTUP || dir == DIR_RIGHTDOWN ) ) return -1; //if the right column
if ( combooffsets[11]==-1 && ( dir == DIR_UP || dir == DIR_RIGHTUP || dir == DIR_LEFTUP ) ) return -1; //if the top row
if ( combooffsets[12]==-1 && ( dir == DIR_DOWN || dir == DIR_RIGHTDOWN || dir == DIR_LEFTDOWN ) ) return -1; //if the bottom row
if ( cmb >= 0 && cmb < 176 ) return cmb + combooffsets[dir];
else return -1;
}