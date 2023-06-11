const int CF_FLOWFREE_NODE = 99;//Combo flag used to define nodes.
const int CSET_FLOWFREE_DEFAULT = 2;//Default CSet used by empty spaces.

const int SFX_FLOWFREE_PATH_CONFIRM = 16;//Sound to play on building path from node to node
const int SFX_FLOWFREE_PATH_ERASE = 32;//Sound to play on erasing path

const int TILE_FLOWFREE_CURSOR=387;//Tile used to render cursor during path building.

//FlowFree path connection puzzle.
//You have a grid with pairs of different colored nodes. Your goal is to connect nodes by building paths, so no two paths intersect 
//and all empty spaces of the grid are used. Stand on node, press EX1, then walk to same-colored node to construct path. Ex1 is
//also used to cancel path construction, or erase a built path.

//Set up combos as shown in demo.
//Build puzzle of any size and shape. Nodes must be placed in pairs, each pair must have different CSet.
//Flag all nodes with CF_FLOWFREE_NODE flags, rest of the grid with CF_BLOCKTRIGGER flags.
//Place invisible FFC with script and 1st combo from step 1 anywhere in the screen. No arguments needed.

ffc script FlowFreeConnectionPuzzle{
	void run(){
		int origdata = this->Data;
		int sol[176];
		int curpos=-1;
		int curcset=-1;
		int cmb=-1;
		for (int i=0;i<176;i++){
			if (ComboFI(i,CF_FLOWFREE_NODE)) sol[i]=0;
			else if (ComboFI(i,CF_BLOCKTRIGGER)){
				Screen->ComboC[i]=CSET_FLOWFREE_DEFAULT;
				sol[i]=0;
			}
			else sol[i]=-1;
		}
		int olddir=-1;
		while(true){
			if (Link->PressEx1){
				if (curpos<0){
					cmb = ComboAt(CenterLinkX(), CenterLinkY());
					if (ComboFI(cmb,CF_FLOWFREE_NODE)){
						curpos = cmb;
						curcset = Screen->ComboC[curpos];
					}
					else{
						Game->PlaySound(SFX_FLOWFREE_PATH_ERASE);
						cmb = ComboAt(CenterLinkX(), CenterLinkY());
						int cset = Screen->ComboC[cmb];
						for (int i=0;i<176;i++){
							if (sol[i]<0)continue;							
							if (Screen->ComboC[i] != cset)continue;
							if (ComboFI(i,CF_FLOWFREE_NODE))Screen->ComboD[i]=origdata;
							else{
								Screen->ComboD[i]=origdata+1;
								Screen->ComboC[i]=2;
							}
						}
						curpos=-1;
						curcset=-1;
					}
				}
				else{
					Game->PlaySound(SFX_FLOWFREE_PATH_ERASE);
					//cmb = ComboAt(CenterLinkX(), CenterLinkY());
					//int cset = Screen->ComboC[cmb];
					for (int i=0;i<176;i++){
						if (sol[i]<0)continue;
						if (Screen->ComboC[i]!= curcset)continue;
						//Trace(i);
						if (ComboFI(i,CF_FLOWFREE_NODE))Screen->ComboD[i]=origdata;
						else{
							Screen->ComboD[i]=origdata+1;
							Screen->ComboC[i]=2;
						}
					}
					curpos=-1;
					curcset=-1;
				}
			}
			if (curpos>=0){
				Screen->FastTile(2, ComboX(curpos), ComboY(curpos), TILE_FLOWFREE_CURSOR, curcset, OP_OPAQUE);
				cmb = ComboAt(CenterLinkX(), CenterLinkY());
				if(cmb==curpos-1||cmb==curpos+1||cmb==curpos-16||cmb==curpos+16){
					if ((Screen->ComboC[cmb]==CSET_FLOWFREE_DEFAULT)&&(sol[cmb]>=0)){
						
						ConnectPathCombos(curpos, cmb, origdata, olddir);
						olddir = AdjacentComboDir(curpos, cmb);
						Screen->ComboC[cmb]=curcset;
						curpos=cmb;
						
					}
					if (ComboFI(cmb,CF_FLOWFREE_NODE)&&(curpos!=cmb)&&(Screen->ComboC[cmb]==curcset)){
						Game->PlaySound(SFX_FLOWFREE_PATH_CONFIRM);
						
						ConnectPathCombos(curpos, cmb, origdata, olddir);
						olddir = AdjacentComboDir(curpos, cmb);
						curpos=-1;
						curcset=-1;
						for (int i=0;i<=176;i++){
							if (i==176){
								Game->PlaySound(SFX_SECRET);
								Screen->TriggerSecrets();
								Screen->State[ST_SECRET]=true;
								Quit();
							}
							if (sol[i]<0)continue;
							if (Screen->ComboD[i]<(origdata+2)) break;
						}
					}
				}
				//debugValue(2, olddir);
			}
			//debugValue(1, curpos);
			Waitframe();
		}
	}
}

//Defines adjacency direction for given combos, or -1, if combos are not adjacent.
int AdjacentComboDir(int cmb1, int cmb2){
	for (int i=0;i<4;i++){
		if (AdjacentComboFix(cmb1, i)==cmb2) return i;
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

//Path connection procedure.
void ConnectPathCombos(int cmb1, int cmb2, int origdata, int olddir){
	for (int i=0; i<4;i++){
		int adjcmb = AdjacentComboFix(cmb1, i);
		if (adjcmb==cmb2){
			if (ComboFI(cmb1,CF_FLOWFREE_NODE )){
				Screen->ComboD[cmb1] = origdata+4+i;
			}
			else{
				if (i==DIR_UP){
					if (olddir==DIR_LEFT)Screen->ComboD[cmb1] = origdata+10;
					else if (olddir==DIR_RIGHT)Screen->ComboD[cmb1] = origdata+11;
					else Screen->ComboD[cmb1] = origdata+2;
				}
				if (i==DIR_DOWN){
					if (olddir==DIR_LEFT)Screen->ComboD[cmb1] = origdata+8;
					else if (olddir==DIR_RIGHT)Screen->ComboD[cmb1] = origdata+9;
					else Screen->ComboD[cmb1] = origdata+2;
				}
				if (i==DIR_LEFT){
					if (olddir==DIR_UP)Screen->ComboD[cmb1] = origdata+9;
					else if (olddir==DIR_DOWN)Screen->ComboD[cmb1] = origdata+11;
					else Screen->ComboD[cmb1] = origdata+3;
				}
				if (i==DIR_RIGHT){
					if (olddir==DIR_UP)Screen->ComboD[cmb1] = origdata+8;
					else if (olddir==DIR_DOWN)Screen->ComboD[cmb1] = origdata+10;
					else Screen->ComboD[cmb1] = origdata+3;
				}
			}
			if (ComboFI(cmb2,CF_FLOWFREE_NODE ))Screen->ComboD[cmb2] = origdata+4+OppositeDir(i);
			else if (i<2)Screen->ComboD[cmb2] = origdata+2;
			else Screen->ComboD[cmb2] = origdata+3;
		}
	}
}