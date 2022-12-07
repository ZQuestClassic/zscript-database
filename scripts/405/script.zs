const int MADAGASCAR_PUZZLE_MOVE = 16; //Sound to play when making move.
const int MADAGASCAR_PUZZLE_SOLVED = 27;//Sound to play when puzzle is solved.

const int SPR_MADAGASCAR_MARBLE_EATEN = 89;//Sprite/animation to display when marble is eaten during puzzle solving.
const int CMB_MADAGASCAR_JUMP_SHADOW = 1012;//Combo used to render shadow animation beneath jumping marble.

//import "chess.zh" //REQUIRED

//Madagascar Peg Solitaire puzzle
//A number of pegs are placed in holes on a board. You can remove a peg by jumping an adjacent peg over it 
//(horizontally or vertically) to a vacant hole on the other side. 
//Your goal is to remove all but one of the pegs initially present. 
// Stand on peg, press A, then stand on valid hole and press A to Make the move.

//1. Set up 4 adjacent combos. 1 for empty space, 1 for space occupied by peg, 1 for selected peg for jumping and 1 for jumping peg animation.
//2. Build board using first 2 combos from step 1
//3. Place FFC where you want the only peg to be upon reentering the screen with already solved puzzle.
// D0 - ID of the empty space combo.
ffc script MadagascarSolitaire{
	void run (int cmbempty){
		int cmbpeg = cmbempty+1;
		if (Screen->State[ST_SECRET]){
			int newcombo = ComboAt (CenterX(this), CenterY(this));
			for (int i=1; i<176 ;i++){
				if (Screen->ComboD[i] == cmbpeg) Screen->ComboD[i] = cmbempty;
			}
			Screen->ComboD[newcombo] = cmbpeg;
			Quit();
		}
		int curpos = -1;
		int newcombo = -1;
		int jumppos = -1;
		int dir = -1;
		int movecounter = 0;
		int jumpz = 0;
		int movex = -1;
		int movey = -1;
		while (true){
			if (dir<0){
				if (Link->PressEx1){
					if (curpos<0){
						newcombo = ComboAt (CenterLinkX(), CenterLinkY());
						if (Screen->ComboD[newcombo] == cmbpeg) curpos = ComboAt (CenterLinkX(), CenterLinkY());
						if (curpos>=0)Screen->ComboD[curpos] = cmbpeg+1;
					}
					else{ 
						newcombo = ComboAt (CenterLinkX(), CenterLinkY());
						if (newcombo == curpos){
							Screen->ComboD[curpos] = cmbpeg;
							curpos = -1;
						}
						if (LeaperMoveAdjacent(curpos, newcombo, 2, 0)){
							jumppos = ComboInBetween(curpos, newcombo);
							if ((Screen->ComboD[jumppos] == cmbpeg)&&(Screen->ComboD[newcombo]== cmbempty)){
								Game->PlaySound(MADAGASCAR_PUZZLE_MOVE);
								for (int i=0; i<4; i++){
									if (jumppos == AdjacentCombo(curpos, i)) dir=i;
								}
								movex = ComboX(curpos);
								movey = ComboY(curpos);
								jumpz=0;
								Screen->ComboD[curpos] = cmbempty;
								movecounter=16;
							}
						}
					}
				}
			}
			else{
				if (movecounter>12) jumpz+=2;
				else if (movecounter>8) jumpz+=1;
				else if (movecounter>4) jumpz-=1;
				else jumpz-=2;
				if (dir==DIR_UP)movey-=2;
				if (dir==DIR_DOWN)movey+=2;
				if (dir==DIR_LEFT)movex-=2;
				if (dir==DIR_RIGHT)movex+=2;
				Screen->FastCombo(4, movex, movey-jumpz, cmbpeg+2, Screen->ComboC[curpos], OP_OPAQUE);
				if (CMB_MADAGASCAR_JUMP_SHADOW>0)Screen->FastCombo(1, movex, movey, cmbpeg+2, CMB_MADAGASCAR_JUMP_SHADOW, OP_TRANS);								
				movecounter--;
				if (movecounter==0){
					Screen->ComboD[jumppos] = cmbempty;
					Screen->ComboD[newcombo] = cmbpeg;
					curpos = -1;
					dir=-1;
					if (SPR_MADAGASCAR_MARBLE_EATEN>0){
						lweapon s = CreateLWeaponAt(LW_SPARKLE, ComboX(jumppos), ComboY(jumppos));
						s->UseSprite(SPR_MADAGASCAR_MARBLE_EATEN);
						s->CollDetection=false; 
					}
					int numpegs = 0;
					for (int i = 1; i<176; i++){
						if (Screen->ComboD[i] == cmbpeg) numpegs++;
					} 
					if (numpegs==1){
						Game->PlaySound(MADAGASCAR_PUZZLE_SOLVED);
						Screen->TriggerSecrets();
						Screen->State[ST_SECRET]=true;
						Quit();
					}
				}
			}
			//if (curpos>0) Screen->Rectangle(0, ComboX(curpos), ComboY(curpos), ComboX(curpos)+16, ComboY(curpos)+16, 3, 1, 0, 0, 0, false, OP_OPAQUE);
			Waitframe();
		}
	}
	
	//Returns ID of a combo between chosen ones
	int ComboInBetween(int loc1, int loc2){
		if (!LeaperMoveAdjacent(loc1, loc2, 2, 0)){
			Game->PlaySound(SFX_WAND);
			return -1;
		}
		for (int i=0; i<4; i++){
			if ((AdjacentCombo(loc1, i))
			==(AdjacentCombo(loc2, OppositeDir(i)))) return AdjacentCombo(loc1, i);
		}
	}
}