const int SFX_FIFTEEN_PUZZLE_MOVE = 16; //Sound to play when making move.
const int SFX_FIFTEEN_PUZZLE_SOLVED = 27;//Sound to play when puzzle is solved. 

const int FIFTEEN_PUZZLE_SHUFFLE_NUM_MOVES =180; //Number of moves when shuffling puzzle
const int FIFTEEN_PUZZLE_SHUFFLE_ASPEED =1; //Delay between shuffling moves, in frames.



//4*4 grid space, occupied by 15 numbered tiles and 1 empty space. Tiles in the same row or column of the open 
//position can be moved by sliding them horizontally or vertically, respectively. Stand on tile adjacent to empty space and press A.
//The goal of the puzzle is to arrange the tiles in numerical order.
//1. Set up 16 consecutive combos, 15 for number tiles, followed by empty space. You should end up with 4*4 block of combos depicting solved state of the puzzle.
//2. Build 4*4 block on the screen using Right click -> Draw Block-> 4*4
//3. Place FFC at top left corner of the grid
//D0 - 1-Disable secrets, like for inputing passwords.
ffc script FifteenPuzzle{
	void run(int secret){
		if (Screen->State[ST_SECRET]) Quit();
		this->EffectWidth*=4;
		this->EffectHeight*=4;
		int startpos = ComboAt(CenterX(this), CenterY(this));
		int startposx = ComboX(startpos);
		int startposy = ComboY(startpos);
		int boundx = ComboX(startpos)+63;
		int boundy = ComboY(startpos)+63;
		int pos[16] = {startpos, startpos+1, startpos+2, startpos+3, 
			startpos+16, startpos+17, startpos+18, startpos+19,
			startpos+32, startpos+33, startpos+34, startpos+35,
			startpos+48, startpos+49, startpos+50, startpos+51};
		int cmb[16];
		for (int i=0; i<16; i++){
			cmb[i] = Screen->ComboD[startpos]+i;
		}
		int movecmb = -1;
		int pushdir = -1;
		int movex = -1;
		int movey = -1;
		int movecounter = 0;
		int curpos=-1;
		//shuffle tiles
		int blankspace = pos[15];
		for (int i=1; i<=FIFTEEN_PUZZLE_SHUFFLE_NUM_MOVES;i++){
			int adjcmb = AdjacentCombo(blankspace, Rand(4));
			if ((ComboX(adjcmb))<startposx)	adjcmb=-1;
			if ((ComboY(adjcmb))<startposy) adjcmb=-1;
			if ((ComboX(adjcmb))>boundx) adjcmb=-1;
			if ((ComboY(adjcmb))>boundy) adjcmb=-1;
			if (adjcmb>=0){
				SwapCombos(blankspace, adjcmb);
				blankspace=adjcmb;
				Waitframes(FIFTEEN_PUZZLE_SHUFFLE_ASPEED);
			}
			else i--;
		}
		while(true){
			if (pushdir<0){
				if (RectCollision(ComboX(startpos), ComboY(startpos),ComboX(startpos+4)-1, ComboY(startpos+48)+15, CenterLinkX(), CenterLinkY(), (CenterLinkX()+1), (CenterLinkY())+1)){
					if (Link->PressEx1){
						curpos = ComboAt(CenterLinkX(), CenterLinkY());
						int blankpos = FindAdjacentBlankPos(curpos, cmb[15], startpos);
						if (blankpos>=0){
							Game->PlaySound(SFX_FIFTEEN_PUZZLE_MOVE);
							movex = ComboX(curpos);
							movey = ComboY(curpos);
							pushdir = blankpos;
							movecmb = Screen->ComboD[curpos];
							movecounter = 16;
							Screen->ComboD[curpos] = cmb[15];
						}				
					}
				}
			}
			else{
				NoAction();
				if (pushdir==DIR_UP)movey--;
				if (pushdir==DIR_DOWN)movey++;
				if (pushdir==DIR_LEFT)movex--;
				if (pushdir==DIR_RIGHT)movex++;
				Screen->FastCombo(1, movex, movey, movecmb, Screen->ComboC[curpos], OP_OPAQUE);
				movecounter--;
				if (movecounter==0){
					int adjcmb = AdjacentCombo(curpos, pushdir);
					pushdir=-1;
					Screen->ComboD[curpos] = cmb[15];
					Screen->ComboD[adjcmb] = movecmb;
					for (int i=0; i<16;i++){
						if (secret>0) break;
						if (Screen->ComboD[pos[i]]!=cmb[i]) break;
						else if (i==15){								
							Game->PlaySound(SFX_FIFTEEN_PUZZLE_SOLVED);
							Screen->TriggerSecrets();
							Screen->State[ST_SECRET]=true;
							Quit();
						}
					}
				}
			}
			Waitframe();
		}
	}
	
	void SwapCombos(int pos1, int pos2){
		int cmb1 = Screen->ComboD[pos1];
		int cmb2 = Screen->ComboD[pos2];
		int cset1 = Screen->ComboC[pos1];
		int cset2 = Screen->ComboC[pos2];
		Screen->ComboD[pos1] = cmb2;
		Screen->ComboD[pos2] = cmb1;
		Screen->ComboC[pos1] = cset2;
		Screen->ComboC[pos1] = cset1;
	}
	
	int FindAdjacentBlankPos(int curpos, int blankcmb, int startpos){
		int startposx = ComboX(startpos);
		int startposy = ComboY(startpos);
		int boundx = startposx+63;
		int boundy = startposx+63;
		int adjcmb[4];
		for (int i=0;i<4;i++){
			adjcmb[i]= AdjacentCombo(curpos, i);
			if ((ComboX(adjcmb[i]))<startposx) 	adjcmb[i]=-1;
			if ((ComboY(adjcmb[i]))<startposy) 	adjcmb[i]=-1;
			if ((ComboX(adjcmb[i]))>boundx) adjcmb[i]=-1;
			if ((ComboY(adjcmb[i]))>boundy) adjcmb[i]=-1;
			if (adjcmb[i]>=0){
				if ((Screen->ComboD[adjcmb[i]])==blankcmb) return i;
			}
		}
		return -1;
	}
}