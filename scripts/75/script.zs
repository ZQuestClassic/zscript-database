const int FFCMISC_PUZZLECHECK = 0; // Holds the state of the FFC so PuzzleCheck can capture it.
const int SCREEND_PUZZLELOCK = 0; // Concurrency lock while solving puzzles

// = Puzzle Check =
// Generically checks the state of FFCs involved in puzzles
// Requires that all FFCs involved are together in the FFC list
// D0: state to check for
// D1: ffc to start on (inclusive)
// D2: ffc to stop on (inclusive)
ffc script PuzzleCheck {
	void run (int state, int start, int end) {
		if (Screen->State[ST_SECRET]) { // Puzzle has already been solved
			Secrets();
			Quit();
		}
	
		while (true) {
		
			if (Screen->D[SCREEND_PUZZLELOCK] == 0) {
				bool solved = true; // Assume the puzzle is solved until you can prove otherwise
				
				for (int i=start; i<=end; i++) {
					ffc f = Screen->LoadFFC(i);
					
					if (f->Misc[FFCMISC_PUZZLECHECK] != state) { // (At least) One is the incorrect state.
						solved = false;						 // Therefore the puzzle is unsolved
					}
				}
				
				if (solved) {
					Secrets();
					Quit();
				}
			}
			
			Waitframe();
		
		}
	}
}

void Secrets(int sound) {
	Screen->TriggerSecrets();
	if ( !ScreenFlag(SF_SECRETS, 1) ) // Secrets are permanent
		Screen->State[ST_SECRET] = true;
	if (ScreenFlag(SF_SECRETS, 0)) { // Block->Shutters
		for (int i=0; i<3; i++) {
			if (Screen->Door[i] == D_SHUTTER) {
				Screen->Door[i] = D_OPENSHUTTER;
			}
		}
	}
	Game->PlaySound(sound);
}

void Secrets() {
	Secrets(SFX_SECRET);
}