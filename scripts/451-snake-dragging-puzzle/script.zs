const int TILE_SNAKEDRAG_CURSOR=365;//Tile used to render cursor during snake dragging.

const int LAYER_SNAKEDRAG_TRIGGER = 2;//Layer used to define the CSet for trigger combos

const int SFX_SNAKEDRAG_MOVE = 16;//Sound to play, when dragging the snake.

//Snake dragging puzzle from Machinarium. You have a maze containing different colored snakes made of combos.
//You can move the snakes in the maze by dragging their heads and tails (Ex1). Occupy all colored spots with same colored snakes to solve the puzzle.
//
//Set up combos as shown in demo.
//Build the puzzle: use 1st combo and different CSets. Make sure that each snake part combo have no more than 2 adjacent combos of the same CSet.
//Triggers: Place combos with target Cset on  LAYER_SNAKEDRAG_TRIGGER layer. In the demo, it`s different colored rails. Flag those spaces with flag 66 on layer 0.
//Place invisible FFC with script and 1st combo from step 1 anywhere in the screen. No arguments needed.
ffc script SnakeDragPuzzle{
	void run(){
		int origcmb=this->Data;
		int dirstate[176];
		int curpos=-1;
		int curcset=-1;
		int cmb=-1;
		SnakeConnectDirectionalCombos(dirstate,origcmb, true);
		while(true){
			cmb = ComboAt (CenterLinkX(), CenterLinkY());
			if (curpos<0){
				if ((IsSnakeHead(cmb, dirstate)>=0) && Link->PressEx1){
					curpos = cmb;
					curcset = Screen->ComboC[cmb];
				}
			}
			else{
				Screen->FastTile(2, ComboX(curpos), ComboY(curpos), TILE_SNAKEDRAG_CURSOR, curcset, OP_OPAQUE);
				if(cmb==curpos-1||cmb==curpos+1||cmb==curpos-16||cmb==curpos+16){
					if (dirstate[cmb]<0 && !ComboFI(cmb,CF_NOBLOCKS)){
						Game->PlaySound(SFX_SNAKEDRAG_MOVE);
						//move head
						int dr = AdjacentComboDir(curpos, cmb);
						dirstate[cmb]=1<<OppositeDir(dr);
						dirstate[curpos]|=(1<<dr);
						Screen->ComboD[cmb]=origcmb+dirstate[cmb];
						Screen->ComboD[curpos]=origcmb+dirstate[curpos];
						Screen->ComboC[cmb]= curcset;
						//move tail
						for (int i=0;i<176;i++){
							if (Screen->ComboC[i]!=curcset)continue;
							
							if (cmb==i)continue;
							int dir = IsSnakeHead(i, dirstate);
							if (dir<0)continue;
							int adjcmb = AdjacentComboFix(i, dir);
							if (adjcmb<0)continue;
							dirstate[i]=-1;
							dirstate[adjcmb]&= ~(1<<OppositeDir(dir));
							Screen->ComboD[i]= Screen->UnderCombo;
							Screen->ComboC[i]= Screen->UnderCSet;
							Screen->ComboD[adjcmb]=origcmb+dirstate[adjcmb];
							break;
						}
						curpos=cmb;
						for (int i=0;i<=176;i++){
							if (i==176){
								Game->PlaySound(SFX_SECRET);
								Screen->TriggerSecrets();
								Screen->State[ST_SECRET]=true;
								break;
							}
							if (!ComboFI(i,CF_BLOCKTRIGGER))continue;
							if (dirstate[i]<0)break;
							int trcset = GetLayerComboC(LAYER_SNAKEDRAG_TRIGGER, i);
							if (Screen->ComboC[i]!=trcset)break;
						}
					}
				}
				if (Link->PressEx1){
					curpos=-1;
					curcset=-1;
				}
			}
			//debugValue(1, dirstate[cmb]);
			if (Link->InputEx2)SmartCombos_Debug_DrawDirstate(dirstate, 976, 972, 5);
			Waitframe();
		}
	}
}

void DefineDirstate(int dirstate, int origcmb){
	for (int i=0; i<176; i++){
		if (Screen->ComboD[i]<origcmb)dirstate[i]=-1;
		else if (Screen->ComboD[i]>(origcmb+15))dirstate[i]=-1;
		else dirstate[i]= Screen->ComboD[i]-origcmb;
	}
}

void SnakeConnectDirectionalCombos(int dirstate, int origcmb, bool color){
	for (int i=0; i<176; i++){
		if (Screen->ComboD[i]<origcmb)dirstate[i]=-1;
		else if (Screen->ComboD[i]>(origcmb+15))dirstate[i]=-1;
		else{
			dirstate[i]=0;
			for (int d=0;d<4;d++){
				int adjcmb = AdjacentComboFix(i, d);
				if (adjcmb<0)continue;
				if (Screen->ComboD[adjcmb]<origcmb)continue;
				if (Screen->ComboD[i]>(origcmb+15))continue;
				if (color){
					if (Screen->ComboC[adjcmb]!= Screen->ComboC[i]) continue;
				}
				dirstate[i]+=(1<<d);
			}
		}
	}
	for (int i=0; i<176; i++){
		if (dirstate[i]>=0) Screen->ComboD[i]=origcmb+dirstate[i];
	}
}

//Fixed variant of AdjacentCombo function from std_extension.zh
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

int IsSnakeHead(int cmb, int dirstate){
	if (dirstate[cmb]==1) return DIR_UP;
	if (dirstate[cmb]==2) return DIR_DOWN;
	if (dirstate[cmb]==4) return DIR_LEFT;
	if (dirstate[cmb]==8) return DIR_RIGHT;
	return -1;
}

//Defines adjacency direction for given combos, or -1, if combos are not adjacent.
int AdjacentComboDir(int cmb1, int cmb2){
	for (int i=0;i<4;i++){
		if (AdjacentComboFix(cmb1, i)==cmb2) return i;
	}
	return -1;
}


void SmartCombos_Debug_DrawDirstate(int dirstate, int origcmb, int minuscmb, int cset){
	for (int i=0; i<176; i++){
		int state = dirstate[i];
		if (state<0) Screen->FastCombo(7, ComboX(i), ComboY(i), minuscmb, cset, OP_OPAQUE);
		else Screen->FastCombo(7, ComboX(i), ComboY(i), origcmb+dirstate[i], cset, OP_OPAQUE);
	}
}