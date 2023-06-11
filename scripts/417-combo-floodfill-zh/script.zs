//Replace any cmb1 combo that is adjacent to cmb2 with cmb2, like flood fill in Paint.net 
void FloodFillComboReplace(int cmb, int cmb2){
	for (int i=0; i<176; i++){
		if (Screen->ComboD[i]!=cmb2)continue;
		for (int d=0; d<4; d++){
			int pos = AdjacentComboFix(i, d);
			if (pos==-1) continue;
			if (Screen->ComboD[pos]!=cmb) continue;
			Screen->ComboD[pos]=cmb2;
			Screen->ComboC[pos] = Screen->ComboC[i];
			//break;
		}
	}
}

//Causes any combo of ID, which is adjacent to a combo with next ID in list to be replaced with that ID.
void FloodFillComboNext(int cmb){
	FloodFillComboReplace(cmb, cmb+1);
}

//Fixed variant of AdjacentCombo function from std_extension.zh
int AdjacentComboFix(int cmb, int dir)
{
	int combooffsets[13]={-0x10, 0x10, -1, 1, -0x11, -0x0F, 0x0F, 0x11};
	if ( cmb % 16 == 0 ) combooffsets[9] = -1;
	if ( (cmb % 16) == 15 ) combooffsets[10] = -1; 
	if ( cmb < 0x10 ) combooffsets[11] = -1; //if it's the top row
	if ( cmb > 0x9F ) combooffsets[12] = -1; //if it's on the bottom row
	if ( combooffsets[9]==-1 && ( dir == DIR_LEFT || dir == DIR_LEFTUP || dir == DIR_LEFTDOWN ) ) return -1; //if the left columb
	if ( combooffsets[10]==-1 && ( dir == DIR_RIGHT || dir == DIR_RIGHTUP || dir == DIR_RIGHTDOWN ) ) return -1; //if the right column
	if ( combooffsets[11]==-1 && ( dir == DIR_UP || dir == DIR_RIGHTUP || dir == DIR_LEFTUP ) ) return -1; //if the top row
	if ( combooffsets[12]==-1 && ( dir == DIR_DOWN || dir == DIR_RIGHTDOWN || dir == DIR_LEFTDOWN ) ) return -1; //if the bottom row
	if ( cmb >= 0 && cmb < 176 ) return cmb + combooffsets[dir];
	else return -1;
}

//Test script. One fiery spark - And it`s forest fire!!
//Set up 2 combos, a normal tree, and then fire that cycles into burnt tree.
//D0 - tree combo.
ffc script BurningTrees{
	void run (int cmb){
		while(true){
			for (int i=1; i<= Screen->NumLWeapons();i++){
				lweapon l= Screen->LoadLWeapon(i);
				if (l->ID!=LW_FIRE)continue;
				for (int i=0; i<176; i++){
					if (Screen->ComboD[i]!=cmb)continue;
					if (RectCollision(ComboX(i),ComboY(i),ComboX(i)+15,ComboY(i)+15,l->X, l->Y, l->X+15, l->Y+15)){
						Screen->ComboD[i]++;
						Screen->ComboC[i]=8;
					}
				}
			}
			FloodFillComboNext(cmb);
			Waitframe();
		}
	}
}