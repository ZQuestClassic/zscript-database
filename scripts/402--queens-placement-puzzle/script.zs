const int SFX_QUEEN_PUZZLE_MOVE = 16; //Sound to play when placing queen on board.
const int SFX_QUEENS_EATING = 32; //Sound to play when pieces attack each other on board.
const int SFX_QUEEN_PUZZLE_SOLVED = 27; //Sound to play when puzzle is solved. 
const int SFX_QUEEN_FALL = 38;//Sound to play when piece is dropped from ceiling

const int SPR_QUEEN_EATEN = 22;//Sprite used for despawning eaten pieces.

const int CMB_QUEEN_SHADOW = 910;//Shadow combo used for drop animation.
//import "chess.zh" //REQUIRED!!

//V1.2 

//8 queens placement puzzle. Place 8 queens on chess board so no two queens can attack each other.
// Stand on board and press Ex1 to place a queen. Any attacked pieces are immediately removed.
//Set up 2 consecutive combos for empty space and queen piece. Build chess board on background layer.
//Build board of any shape and size, using only 1st combo from step 1.
//Place FFC on any space of the board.
//D0 - Number of pieces to place.
//D1 - Piece type to place. Add values together. 
//   1 - horizontal rows 
//   2 - vertical columns
//   4 - diagonals
//   8 - knight move
// examples: 3-rooks, 4-bishops, 7-queens, 8-knights, 15-maharajas
ffc script QueenPlacementPuzzlev1_2{
	void run (int boardsize, int piecetype){
		if (Screen->State[ST_SECRET]) Quit();
		int origcmb = ComboAt (CenterX (this), CenterY (this));
		int emptycmb = Screen->ComboD[origcmb];
		int queencmb = emptycmb+1;
		int numqueens = 0;
		int animcounter = 0;
		int curqueen=-1;
		int drawz=0;
		while (true){
			if (animcounter==0){
				int cmb = ComboAt (CenterLinkX(), CenterLinkY());
				if (Screen->ComboD[cmb] == emptycmb){
					if (Link->PressEx1){
						curqueen = ComboAt (CenterLinkX(), CenterLinkY());
						if (Screen->ComboD[curqueen]== emptycmb){
							Game->PlaySound(SFX_QUEEN_FALL);
							animcounter=24;
						}
					}
				}
			}
			else{
				Screen->FastCombo(Cond(animcounter>4, 5,2), ComboX(curqueen), ComboY(curqueen)-8*animcounter, emptycmb+1, Screen->ComboC[curqueen], OP_OPAQUE);
				if ((CMB_QUEEN_SHADOW>0) && (animcounter>0))Screen->FastCombo(1, ComboX(curqueen), ComboY(curqueen),CMB_QUEEN_SHADOW, 7, OP_TRANS);
				animcounter--;
				if (animcounter==0){
					Game->PlaySound(SFX_QUEEN_PUZZLE_MOVE);
					Screen->Quake=8;
					Screen->ComboD[curqueen]++;
					numqueens++;
					for (int i=0; i<176; i++){
						if (curqueen==i) continue;
						if (Screen->ComboD[i]!=queencmb) continue;
						if ((OnSameRank(i, curqueen))&&((piecetype&1)>0)){
							Game->PlaySound(SFX_QUEENS_EATING);
							Screen->ComboD[i]--;
							if (SPR_QUEEN_EATEN>0){
								lweapon s = CreateLWeaponAt(LW_SPARKLE, ComboX(i), ComboY(i));
								s->UseSprite(SPR_QUEEN_EATEN);
								s->CollDetection=false; 
							}
							numqueens--;
						}
						if ((OnSameFile(i, curqueen))&&((piecetype&2)>0)){
							Screen->ComboD[i]--;
							Game->PlaySound(SFX_QUEENS_EATING);
							if (SPR_QUEEN_EATEN>0){
								lweapon s = CreateLWeaponAt(LW_SPARKLE, ComboX(i), ComboY(i));
								s->UseSprite(SPR_QUEEN_EATEN);
								s->CollDetection=false; 
							}
							numqueens--;
						}
						if ((OnSameDiagonal(i, curqueen))&&((piecetype&4)>0)){
							Screen->ComboD[i]--;
							Game->PlaySound(SFX_QUEENS_EATING);
							if (SPR_QUEEN_EATEN>0){
								lweapon s = CreateLWeaponAt(LW_SPARKLE, ComboX(i), ComboY(i));
								s->UseSprite(SPR_QUEEN_EATEN);
								s->CollDetection=false; 
							}
							numqueens--;
						}
						if ((KnightMoveAdjacent(i, curqueen))&&((piecetype&8)>0)){
							Screen->ComboD[i]--;
							Game->PlaySound(SFX_QUEENS_EATING);
							if (SPR_QUEEN_EATEN>0){
								lweapon s = CreateLWeaponAt(LW_SPARKLE, ComboX(i), ComboY(i));
								s->UseSprite(SPR_QUEEN_EATEN);
								s->CollDetection=false; 
							}
							numqueens--;
						}
				 	}
				 	if (numqueens>=boardsize){
						Game->PlaySound(SFX_SECRET);
						Screen->TriggerSecrets();
						Screen->State[ST_SECRET]=true;
						Quit();
					}
				}
			}
			Waitframe();
		}
	}
}