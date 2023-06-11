const int FFCMISC_LIGHTSOUT_TOGGLE = 1;

// = Lights Out =
// Works just like the oft-cloned puzzle game. Triggering one item triggers the adjacent as well.
// D0: initial state (1 = on, 0 = off)
// D1: combo to switch to when hit
// D2: cset to switch to when hit
// D3-6: adjacent ffc ids (0 to ignore)
// D7: state switched to when solved.
ffc script LightsOut {
	void run (bool state, int alt_combo, int alt_cset, int adj1, int adj2, int adj3, int adj4, int solved_state) {
		ffc a1; ffc a2; ffc a3; ffc a4;
		if(adj1 > 0) a1 = Screen->LoadFFC(adj1);
		if(adj2 > 0) a2 = Screen->LoadFFC(adj2);
		if(adj3 > 0) a3 = Screen->LoadFFC(adj3);
		if(adj4 > 0) a4 = Screen->LoadFFC(adj4);
		
		int on_combo; int off_combo; int on_cset; int off_cset;
		if (state) { // ON
			this->Misc[FFCMISC_PUZZLECHECK] = 1;
			
			on_combo = this->Data;
			off_combo = alt_combo;
			
			on_cset = this->CSet;
			off_cset = alt_cset;
		}
		else { // off
			this->Misc[FFCMISC_PUZZLECHECK] = 0;
			
			off_combo = this->Data;
			on_combo = alt_combo;
			
			off_cset = this->CSet;
			on_cset = alt_cset;
		}
		
		if (Screen->State[ST_SECRET]) {
			state = solved_state;
				
			if (state) {
				this->Data = on_combo;
				this->CSet = on_cset;
			}
			else {
				this->Data = off_combo;
				this->CSet = off_cset;
			}
			
			Quit();
		}
		
		while (true) {
			
			if (Screen->D[SCREEND_PUZZLELOCK] == 0) {
				for (int i=1; i<=Screen->NumLWeapons(); i++) {
					lweapon wpn = Screen->LoadLWeapon(i);
					if (wpn->ID == LW_SWORD) {
						if ( Distance(wpn->X, wpn->Y, this->X, this->Y) < 8 ) {
							this->Misc[FFCMISC_LIGHTSOUT_TOGGLE] = 1;
							if(adj1 > 0) a1->Misc[FFCMISC_LIGHTSOUT_TOGGLE] = 1;
							if(adj2 > 0) a2->Misc[FFCMISC_LIGHTSOUT_TOGGLE] = 1;
							if(adj3 > 0) a3->Misc[FFCMISC_LIGHTSOUT_TOGGLE] = 1;
							if(adj4 > 0) a4->Misc[FFCMISC_LIGHTSOUT_TOGGLE] = 1;
							Screen->D[SCREEND_PUZZLELOCK] = 1;
							Waitframe();
						}
					}
				}
			}
			
			if (this->Misc[FFCMISC_LIGHTSOUT_TOGGLE] == 1) {
				this->Misc[FFCMISC_LIGHTSOUT_TOGGLE] = 0;
				state = !state;
				
				if (state) {
					this->Misc[FFCMISC_PUZZLECHECK] = 1;
					this->Data = on_combo;
					this->CSet = on_cset;
				}
				else {
					this->Misc[FFCMISC_PUZZLECHECK] = 0;
					this->Data = off_combo;
					this->CSet = off_cset;
				}
				
				Waitframes(20);
				Screen->D[SCREEND_PUZZLELOCK] = 0;
			}
			
			// Stop working when solved
			if (Screen->State[ST_SECRET]) Quit();
			
			Waitframe();
		
		}
	}
}