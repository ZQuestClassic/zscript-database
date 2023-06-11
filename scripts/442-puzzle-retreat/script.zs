const int CF_PUZZLERETREAT_HOLE = 66; //Flag used to define holes
const int CF_PUZZLERETREAT_BUTTON = 98; //Flag used to define launch buttons
const int CF_PUZZLERETREAT_BARRIER = 67; //Flag used to define obstacles

const int CMB_PUZZLERETREAT_ICEBLOCK = 949; //Combo used to render sliding ice block

const int CSET_PUZZLERETREAT_ICEBLOCK = 2; //CSet used to render sliding ice block

const int SFX_PUZZLERETREAT_LAUNCH = 21;//Sound to play on launching ice blocks
const int SFX_PUZZLERETREAT_BREAK = 10;//Sound to play when stack of ice blocks crashes into obstacle
const int SFX_PUZZLERETREAT_HOLE = 16;//Sound to play when ice block falls into hole

const int PUZZLE_RETREAT_ICEBLOCK_HEIGHT = 2;//Iceblock height. Used to render stack of ice blocks.

const int SPR_PUZZLERETREAT_BREAK = 23;//Sprite to display when stack of ice blocks crashes into obstacle

//Stand on button, face the chosen direction and press Ex1 to spawn a stack of ice blocks that ride chosen direction
//These blocks ride across holes, dropping 1 block at time, bounce off mirrors, change direction on conveyers and shatter on hitting NoPushblock flags.
//Fill all holes to solve puzzle.

//Set up sequence of combos with CF_PUZZLERETREAT_BUTTON inherent flag for buttons, leftmost must have missing that flag. 0,1,2,3,4 etc.
//Set up sequence of 2 combos for empty/filled holes. Assign CF_PUZZLERETREAT_HOLE flag to empty holes.
//Place FFC anywhere in the screen. Build the puzzle, surround it with CF_PUZZLERETREAT_BARRIER flags. 
//Running ice blocks ignore combo solidity at all.
// D0 - combo used as 1st in sequence of ice spawn buttons (0 ice blocks)

ffc script PuzzleRetreat{
	void run(int cmbbutton){
		int animcounter =0;
		int drawx = -1;
		int drawy = -1;
		int ice = 0;
		int dir = -1;
		int cmb = -1;
		while(true){
			if (animcounter==0){
				if (Link->PressEx1){
					cmb = ComboAt(CenterLinkX(),CenterLinkY());
					dir = Link->Dir;
					int adjcmb = AdjacentComboFix(cmb, dir);
					if (!ComboFI(adjcmb, CF_PUZZLERETREAT_BARRIER) && ComboFI(cmb, CF_PUZZLERETREAT_BUTTON)){
						Game->PlaySound(SFX_PUZZLERETREAT_LAUNCH);
						while(ComboFI(cmb,CF_PUZZLERETREAT_BUTTON)){
							Screen->ComboD[cmb]--;
							ice++;
						}
						drawx = ComboX(cmb);
						drawy = ComboY(cmb);
						animcounter=8;
					}
					//else Game->PlaySound(SFX_PUZZLERETREAT_HOLE);
				}
			}
			else{
				if (dir==DIR_UP)drawy-=2;
				if (dir==DIR_DOWN)drawy+=2;
				if (dir==DIR_LEFT)drawx-=2;
				if (dir==DIR_RIGHT)drawx+=2;
				for (int i=0; i<ice; i++){
					Screen->FastCombo(2, drawx, drawy-(i*PUZZLE_RETREAT_ICEBLOCK_HEIGHT), CMB_PUZZLERETREAT_ICEBLOCK, CSET_PUZZLERETREAT_ICEBLOCK, OP_OPAQUE);
				}
				animcounter--;
				if (animcounter<=0){
					cmb = ComboAt(drawx+1, drawy+1);
					if (ComboFI(cmb, CF_PUZZLERETREAT_BARRIER)){
						Game->PlaySound(SFX_PUZZLERETREAT_BREAK);
						lweapon s = CreateLWeaponAt(LW_SPARKLE, ComboX(cmb), ComboY(cmb));
						s->UseSprite(SPR_PUZZLERETREAT_BREAK);
						s->CollDetection=false; 
						ice=0;
						cmb=-1;
					}
					else if (ComboFI(cmb, CF_PUZZLERETREAT_HOLE)){
						Game->PlaySound(SFX_PUZZLERETREAT_HOLE);
						ice--;
						Screen->ComboF[cmb]=0;
						Screen->ComboD[cmb]++;
						for (int i=0;i<=176;i++){
							if (i==176){
								Game->PlaySound(SFX_SECRET);
								Screen->TriggerSecrets();
								Screen->State[ST_SECRET]=true;
								break;
							}
							if (ComboFI(i,CF_PUZZLERETREAT_HOLE))break;
						}
						if (ice>0)animcounter=8;
						else cmb=-1;
					}
					else if (Screen->ComboT[cmb]==CT_MIRRORSLASH){
						dir = RotDir(dir, Cond (dir>1, -2, 2));
						animcounter=8;
					}
					else if (Screen->ComboT[cmb]==CT_MIRRORBACKSLASH){
						dir = RotDir(dir, Cond (dir>1, 2, -2));
						animcounter=8;
					}
					else if (Screen->ComboT[cmb]==CT_CVUP){
						dir = DIR_UP;
						animcounter=8;
					}
					else if (Screen->ComboT[cmb]==CT_CVDOWN){
						dir = DIR_DOWN;
						animcounter=8;
					}
					else if (Screen->ComboT[cmb]==CT_CVLEFT){
						dir = DIR_LEFT;
						animcounter=8;
					}
					else if (Screen->ComboT[cmb]==CT_CVRIGHT){
						dir = DIR_RIGHT;
						animcounter=8;
					}
					else animcounter=8;
				}
			}
			//debugValue(1,animcounter);
			//debugValue(2,ice);
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


int RotDir(int dir, int num){
	int dirs[8] = {DIR_UP, DIR_RIGHTUP, DIR_RIGHT, DIR_RIGHTDOWN, DIR_DOWN, DIR_LEFTDOWN, DIR_LEFT, DIR_LEFTUP};
	int idx=-1;
	for (int i=0; i<8; i++){
		//Trace(dirs[i]);
		if (dirs[i] == dir){
			idx=i;
			break;
		}
	}
	if (idx<0) return -1;
	idx+=num;
	while (idx<0) idx+=8;
	while (idx>=8) idx-=8;
	return dirs[idx];
}