const int CF_MAPPAINT_PUZZLE = 98;// Combo flag to define repaintable areas of puzzle map
const int CF_MAPPAINT_PUZZLE_LOCKED = 99;// Combo flag to define non-repaintable areas of puzzle map

const int CSET_MAPPAINT_COLOR1 = 5;//CSets to define the 4 paints to colour puzzle map
const int CSET_MAPPAINT_COLOR2 = 7;
const int CSET_MAPPAINT_COLOR3 = 8;
const int CSET_MAPPAINT_COLOR4 = 10;

const int SFX_MAPPAINT_MOVE=16;//Sound to play on repainting area
const int SFX_MAPPAINT_LOCKED=6;//Sound to play on attempt to repaint locked region

//Map painting puzzle. Based on four color theorem
//You are given a political map of fantasy kingdom, divided into regions, some of then share borders. Also you are given 4 colored paints
//To solve the puzzle, you need to colour all regions, so no two regions that share a border (touching just corners don`t count), have the same color.
//Some of the regions cannot be repainted, besides being accounted for solution.
//Stand on map region and press Ex1 to cycle between 4 possible colors.

//Build the puzzle: place combos so the same combos being orthogonally adjacent form map regions. 
//Paint those placed combos with CSET_MAPPAINT_COLOR* CSets.
//Make sure that all combos in each region will have the same CSet. 
//Make sure that at least two adjacent regions have the same CSet, or secrets will pop open, as puzzle is already solved.
//Flag all combos in the map with CF_MAPPAINT_PUZZLE. You may also lock color of certain regions by placing CF_MAPPAINT_PUZZLE_LOCKED flag on all combos of that region.
//Place invisible FFC with the script anywhere in thw screen. No arguments needed.

ffc script MapPaintPuzzle{
	void run(){
		int csets[4] = { CSET_MAPPAINT_COLOR1, CSET_MAPPAINT_COLOR2, CSET_MAPPAINT_COLOR3, CSET_MAPPAINT_COLOR4};
		int cmb=-1;
		int cs=0;
		bool fail=false;
		while(true){
			cmb = ComboAt(CenterLinkX(), CenterLinkY());
			if (ComboFI(cmb, CF_MAPPAINT_PUZZLE_LOCKED) && Link->PressEx1)Game->PlaySound(SFX_MAPPAINT_LOCKED);
			else if (ComboFI(cmb, CF_MAPPAINT_PUZZLE) && Link->PressEx1){
				Game->PlaySound(SFX_MAPPAINT_MOVE);
				cs = ArrayMatch(csets, Screen->ComboC[cmb]);
				if (cs<0)cs=0;
				cs++;
				if (cs>3)cs=0;
				Screen->ComboC[cmb]=csets[cs];
				for (int i=0;i<32;i++){
					FloodFillCSETReplace(Screen->ComboD[cmb], csets[cs]);
				}
				for (int i=0; i<176; i++){
					if (!ComboFI(i,CF_MAPPAINT_PUZZLE)&&!ComboFI(i,CF_MAPPAINT_PUZZLE_LOCKED)) continue;
					for (int d=0; d<4; d++){
						int pos = AdjacentComboFix(i, d);
						if (pos==-1) continue;
						if (Screen->ComboD[pos]==Screen->ComboD[i]) continue;
						if (Screen->ComboC[pos]==Screen->ComboC[i]) fail=true;
					}
				}
				if (!fail){
					Game->PlaySound(SFX_SECRET);
					Screen->TriggerSecrets();
					Screen->State[ST_SECRET]=true;
					Quit();
				}
				fail=false;
			}
			Waitframe();
		}
	}
}

//Replace any cmb1 combo that is adjacent to cmb2 with cmb2, like flood fill in Paint.net 
void FloodFillCSETReplace(int cmb, int newcset){
	for (int i=0; i<176; i++){
		if (Screen->ComboD[i]!=cmb)continue;
		//Trace(newcset);
		if (Screen->ComboC[i]!=newcset)continue;
		//Trace(i);
		for (int d=0; d<4; d++){
			int pos = AdjacentComboFix(i, d);
			if (pos==-1) continue;
			if (Screen->ComboD[pos]!=cmb) continue;
			if (Screen->ComboC[pos]==newcset)continue;
			Screen->ComboC[pos] = newcset;
			//break;
		}
	}
}

//Returns index of the given element that exists in the given array or -1, if it does not exist.
int ArrayMatch(int arr, int value){
	for (int i=0; i<SizeOfArray(arr); i++){
		if (arr[i] == value) return i;
	}
	return -1;
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