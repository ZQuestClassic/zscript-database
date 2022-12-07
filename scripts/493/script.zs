const int CF_ARROW_PATH_DIR_UP = 62; //Combo flags that define direction changing arrow.
const int CF_ARROW_PATH_DIR_DOWN = 63;//Up, down, left right.
const int CF_ARROW_PATH_DIR_LEFT = 64;
const int CF_ARROW_PATH_DIR_RIGHT =65;
const int CF_ARROW_PATH_FAILURE = 98;//Pesky failure mine. If sequence of arrows points to it, puzzle is failed explosively.
const int CF_ARROW_PATH_GOAL = 66;//If sequence of arrows points to it, puzzle is solved.

const int CMB_ARROW_PATH_ACTIVE = 957;//Combo to render on top of combos that are current arrow sequence path.

//Resident Evil Arrow puzzle.
//You have grid (any shape) filled with arrows, some of them can be rotated, for instance, with a multi-state switch. A starting arrow points at another arrow, and chain goes on. If arrow points at bomb (CF_ARROW_PATH_FAILURE), puzzle is failed explosively. If arrow points at goal, (CF_ARROW_PATH_GOAL), puzzle is solved.

//Set up combos for arrows, use  CF_ARROW_PATH_DIR_* as inherent flags for defining arrow pointing direction.
//Build the puzzle area.  Surround puzzle area with NoPushBlock, also use that flag as obstacles.
//Additionally you may place bombs, flagged with CF_ARROW_PATH_FAILURE.
//Place FFC with script at start position and flag CF_ARROW_PATH_GOAL for goal point.
//D0 - starting direction. 0 - up, 1 - dpwn, 2- left, 3- right.

ffc script ArrowPathPuzzle{
	void run (int origdir){
		int origcmb = ComboAt(CenterX(this), CenterY(this));
		int cmb=origcmb;
		int dir=origdir;
		int newdir = dir;
		int active[176];
		for (int i=0;i<176;i++){
			active[i]=0;
		}
		if (Screen->State[ST_SECRET])Quit();
		while(true){
			if (this->InitD[7]==2){
				Waitframe();
				continue;
			}
			for (int i=0;i<176;i++){
				active[i]=0;
			}
			cmb=origcmb;
			dir=origdir;
			newdir = dir;
			this->InitD[7]=0;
			while (cmb>=0){
				//debugValue(1,cmb);
				cmb= AdjacentComboFix(cmb, dir);
				if (cmb<0)break;
				if (active[cmb]>0)break;
				if (ComboFI(cmb, CF_NOBLOCKS)) break;
				active[cmb]=1;
				Screen->FastCombo(3, ComboX(cmb), ComboY(cmb),CMB_ARROW_PATH_ACTIVE, this->CSet, OP_OPAQUE);
				if (ComboFI(cmb, CF_ARROW_PATH_FAILURE)){
					Screen->ComboD[origcmb]++;
					eweapon e = CreateEWeaponAt(EW_BOMBBLAST, this->X, this->Y);
					e->CollDetection=false;
					this->InitD[7]=2;
					break;
				}
				if (ComboFI(cmb, CF_ARROW_PATH_GOAL)){
					this->InitD[7]=1;
					for(int j=1;j<=33;j++){
						if (Screen->State[ST_SECRET]) break;
						if (j==33){
							Game->PlaySound(SFX_SECRET);
							Screen->TriggerSecrets();
							Screen->State[ST_SECRET]=true;
							break;
						}
						ffc n = Screen->LoadFFC(j);
						if (n->Script!=this->Script)continue;
						if (n->InitD[7] != 1) break;
					}
					break;
				}
				if (ComboFI(cmb, CF_ARROW_PATH_DIR_UP)) newdir=DIR_UP;
				if (ComboFI(cmb, CF_ARROW_PATH_DIR_DOWN)) newdir=DIR_DOWN;
				if (ComboFI(cmb, CF_ARROW_PATH_DIR_LEFT)) newdir=DIR_LEFT;
				if (ComboFI(cmb, CF_ARROW_PATH_DIR_RIGHT)) newdir=DIR_RIGHT;
				if (newdir==OppositeDir(dir)) break;
				if (dir!=newdir)dir=newdir;				
			}
			Waitframe();
		}
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