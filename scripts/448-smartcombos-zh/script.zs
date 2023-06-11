//Places combo and replaces adjacent combos to avoid cutoff
void SmartComboPlace(int pos, int origcmb){
	if((Screen->ComboD[pos]>=origcmb)&&(Screen->ComboD[pos]<(origcmb+16)))return;
	int dircs=0;
	for (int i=0;i<4;i++){
		int adjcmb = AdjacentComboSmart(pos, i);
		if (Screen->ComboD[adjcmb]<origcmb)continue;
		if (Screen->ComboD[adjcmb]>(origcmb+15))continue;
		int adjdirs = Screen->ComboD[adjcmb] - origcmb;
		adjdirs += (1<<(OppositeDir(i)));
		Screen->ComboD[adjcmb]=origcmb+adjdirs;
		dircs+= (1<<i);
	}
	Screen->ComboD[pos]=origcmb+dircs;
}

//Erase combo and replaces adjacent combos to avoid cutoff
void SmartComboErase(int pos, int origcmb, int ucmb){
	if (Screen->ComboD[pos]==ucmb) return;
	int dircs=0;
	for (int i=0;i<4;i++){
		int adjcmb = AdjacentComboSmart(pos, i);
		if (Screen->ComboD[adjcmb]<origcmb)continue;
		if (Screen->ComboD[adjcmb]>(origcmb+15))continue;
		int adjdirs = Screen->ComboD[adjcmb] - origcmb;
		adjdirs -= (1<<(OppositeDir(i)));
		Screen->ComboD[adjcmb]=origcmb+adjdirs;
	}
	Screen->ComboD[pos]=ucmb;
}


//Fixed variant of AdjacentCombo function from std_extension.zh
int AdjacentComboSmart(int cmb, int dir)
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

//Ex1-Place, Ex2-Erase
ffc script SmartComboTest{
	void run(){
		int origcmb=this->Data;
		int net[176];
		int node = ComboAt(CenterX(this),CenterY(this));
		while(true){
			int cmb = ComboAt (CenterLinkX(), CenterLinkY());
			if (!ComboFI(cmb,CF_NOBLOCKS)){
				if (Link->PressEx1)SmartComboPlace(cmb, origcmb);
				if (Link->PressEx2)SmartComboErase(cmb, origcmb, Screen->UnderCombo);
			}
			SmartCombos_LoadNetwork(net, node, origcmb);
			for (int i=0;i<176;i++){
				if (net[i]>0)Screen->ComboC[i]=5;
				else Screen->ComboC[i]=2;
			}
			Waitframe();
		}
	}
}

//Loads connected network of combos, starting from given position into buffer (176 minimum)
void SmartCombos_LoadNetwork(int net, int node, int origcmb){
	for (int i=0;i<176;i++){
		net[i]=0;
	}
	net[node]=1;
	int dirstate[176];	
	for (int i=0;i<176;i++){
		if (Screen->ComboD[i]<origcmb)dirstate[i]=-1;
		else if (Screen->ComboD[i]>(origcmb+15))dirstate[i]=-1;
		else dirstate[i]=Screen->ComboD[i] - origcmb;
		//Screen->DrawInteger(2, ComboX(i), ComboY(i), 0,1,0, -1, -1, dirstate[i],0 , OP_OPAQUE);
	}
	SmartCombos_RunNetwork(net, node, dirstate);
}

//Credit goes to Moosh for path checking procedure.
void SmartCombos_RunNetwork(int net, int node, int dirstate){
	int dir = -1;
	int pos = -1;	
	for (int i=0;i<4;i++){
		if ((dirstate[node]&(1<<i))>0){
			pos = AdjacentComboSmart(node, i);
			//if (net[pos]>0)continue;
			if (dirstate[pos]<0)continue;
			dir=i;
			while(true){
				if (net[pos]>0)break;
				if ((dirstate[pos]&(1<<OppositeDir(dir)))<=0) break;
				net[pos] = 1;
				//Trace(pos);
				if(dirstate[pos]==1111b||dirstate[pos]==0111b||dirstate[pos]==1011b||dirstate[pos]==1101b||dirstate[pos]==1110b){
					//You play a dangerous game there, Moosh...
					//Working with powers beyond your understanding...
					//Will ZScript break under the strain of the recursive functions?
					//Only time will tell...
					SmartCombos_RunNetwork(net, pos, dirstate);
					break;
				}
				if (dirstate[pos]==(1<<OppositeDir(dir))) break;// Capped dead end reached.
				dir = SmFindNextDir(pos, dirstate, dir);
				//if (dir<0) break;
				pos = AdjacentComboSmart(pos, dir);
				if (pos<0)break;
			}
		}
	}
}


//Finds the next direction in a node with two or less directions
int SmFindNextDir(int node, int dirState, int lastDir){
	for(int i=0; i<4; i++){
		if(i!=OppositeDir(lastDir)){
			if(dirState[node]&(1<<i)){
				return i;
			}
		}
	}
	return lastDir;
}

//Returns true, if all nodes in the given array are all connected
bool SmartCombos_NodesConnected(int nodes, int origcmb){
	int net[176];
	SmartCombos_LoadNetwork(net, nodes[0], origcmb);
	for (int i=0; i<SizeOfArray(nodes);i++){
		int n = nodes[i];
		if (net[n]==0) return false;
	}
	return true;
}

//Connects all smart combos, thus fixing cutoff. Has option for separate CSets
void ConnectDirectionalCombos(int origcmb, bool color){
	int dirstate[176];
	for (int i=1; i<176; i++){
		if (Screen->ComboD[i]<origcmb)dirstate[i]=-1;
		else if (Screen->ComboD[i]>(origcmb+15))dirstate[i]=-1;
		else{
			dirstate[i]=0;
			for (int d=0;d<4;d++){
				int adjcmb = AdjacentComboFix(i, d);
				if (Screen->ComboD[adjcmb]<origcmb)continue;
				if (Screen->ComboD[i]>(origcmb+15))continue;
				if (color){
					if (Screen->ComboC[adjcmb]!= Screen->ComboC[i]) continue;
				}
				dirstate[i]+=(1<<d);
			}
		}
	}
	for (int i=1; i<176; i++){
		if (dirstate[i]>=0) Screen->ComboD[i]=origcmb+dirstate[i];
	}
}

//Debug function that renders connections between combos.
void SmartCombos_Debug_DrawDirstate(int dirstate, int origcmb, int minuscmb, int cset){
	for (int i=1; i<176; i++){
		int state = dirstate[i];
		if (state<0) Screen->FastCombo(7, ComboX(state), ComboY(state), minuscmb, cset, OP_TRANS);
		else Screen->FastCombo(7, ComboX(state), ComboY(state), origcmb+dirstate[i], cset, OP_TRANS);
	}
}