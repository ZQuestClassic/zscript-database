//Render Priority Puzzle.

//You are given a set of semi-transparent and half-opaque tiles Place those tiles one on top of another, so when overlapped,they form target image.
//Individual tiles - Ex1 to switch, Ex2 to rotate. Main spot - place tiles in order. If you get target image, secrets pop open. 
//Set up a sequence of combos using the same tile sizes for transparent tiles.
//Import and compile the script. 2 FFCs used.
//
//ffc script RenderPriorityPuzzle
//Place FFC at position, where the picture should be assembled.
// D0-D5 = puzzle solution
// #####.___ combo of image.
// _____.#### rotation, multipled by 90 degrees.
// D6 - X size, negative for translucency.
// D7 - Y size, negative to just render target image, not accept solution
//
//ffc script RenderPriorityInputer
//Place FFCs to form individual tiles. 
//D0 - number of combos in sequence.
//D1 - order of tile placement, must be unique per FFCm starting from 0.
//D2 - 0 - disable rotating.
//D3 - translucent, if >0.

ffc script RenderPriorityPuzzle{
	void run(int sol1, int sol2, int sol3, int sol4, int sol5, int sol6, int sizex, int sizey){
		Waitframe();
		int solution[6] = {sol1,sol2,sol3,sol4,sol5,sol6};
		int soltile[6];
		int solrotate[6];
		for (int i=0; i<6; i++){
			if (solution[i]!=0){
				soltile[i] = GetHighFloat(solution[i]);
				solrotate[i] = GetLowFloat(solution[i]);
			}
			else{
				soltile[i] = -1;
				solrotate[i] = -1;
			}
		}
		int inputorder[6];
		int inputcombo[6];
		int inputrot[6];
		int str[] = "RenderPriorityInputer";
		int scr = Game->GetFFCScript(str);
		int input = 0;
		for (int i=0;i<6;i++){
			inputorder[i] = 250;
		}
		for (int i=1; i<=32;i++){
			ffc f = Screen->LoadFFC(i);
			if (f->Script!=scr) continue;
			inputorder[f->InitD[1]] = i;
			input++;
		}
		BSort(inputorder);
		while(true){
			if (sizey>0){
				if((CenterLinkWithinFFC(this))&&(Link->PressEx1)){
					Game->PlaySound(16);
					for (int i=0;i<6;i++){
						int num = inputorder[i];
						if (num==250)continue;
						ffc f = Screen->LoadFFC(num);
						inputcombo[i] = f->InitD[6];
						inputrot[i] = f->InitD[7];
						input=7;
					}
					for (int i=0;i<=6;i++){
						if (Screen->State[ST_SECRET]) break;
							else if (i==6){
								Game->PlaySound(SFX_SECRET);
								Screen->TriggerSecrets();
								Screen->State[ST_SECRET]=true;
								break;
							}
						if (inputorder[i]==250)continue;
						if (inputcombo[i]!=soltile[i])break;
						if (inputrot[i]!=solrotate[i])break;
					}
				}
				if (input==7){
					for (int i=0;i<6;i++){
						int opacity = OP_OPAQUE;
						if (sizex<0) opacity = OP_TRANS;
						if (inputorder[i]==250)continue;
						Screen->DrawCombo(2, this->X, this->Y, inputcombo[i], Abs(sizex), Abs(sizey), this->CSet, -1, -1, this->X, this->Y, inputrot[i]*90, 0, 0, true, opacity);
					}
				}
			}
			else{
				for (int i=0;i<6;i++){
					int opacity = OP_OPAQUE;
					if (sizex<0) opacity = OP_TRANS;
					if (inputorder[i]==250)continue;
					Screen->DrawCombo(2, this->X, this->Y, soltile[i], Abs(sizex), Abs(sizey), this->CSet, -1, -1, this->X, this->Y, solrotate[i]*90, 0, 0, true, opacity);
				}
			}
			Waitframe();
		}
	}
}

ffc script RenderPriorityInputer{
	void run (int arrcmb, int order, int rot, int trans){
		Waitframe();
		int str[] = "RenderPriorityPuzzle";
		int scr = Game->GetFFCScript(str);
		int puzzle = FindFFCRunning(scr);		
		int sizex = 0;
		int sizey = 0;
		for (int i=1; i<=32;i++){
			ffc f = Screen->LoadFFC(i);
			if (f->Script!=scr) continue;
			sizex = f->InitD[6];
			sizey = f->InitD[7];
			break;
		}
		int pos=0;
		int origdata = this->Data;
		this->InitD[5] = origdata;
		this->InitD[6] = origdata;
		this->InitD[7] = 0;
		this->Data = FFCS_INVISIBLE_COMBO;
		int rottimer=0;
		int rotcount=0;
		while(true){
			if (rottimer==0){
				if((CenterLinkWithinFFC(this))&&(Link->PressEx2)&&(rot>0)){
					Game->PlaySound(16);
					rottimer = 30;
					rotcount++;
					if (rotcount>=4) rotcount=0;
					this->InitD[7]=rotcount;
				}
				if(CenterLinkWithinFFC(this)&&(Link->PressEx1)&&(arrcmb>0)){
					Game->PlaySound(16);
					pos++;
					if (pos>=arrcmb)pos=0;
					this->InitD[6] =origdata + pos;
				}
			}
			else{
				if (rottimer>0)rottimer--;
			}
			int opacity = OP_OPAQUE;
			if (trans>0) opacity = OP_TRANS;
			Screen->DrawCombo(2, this->X, this->Y, this->InitD[6], sizex, sizey, this->CSet, -1, -1, this->X, this->Y, this->InitD[7]*90-rottimer*3, 0, 0, true, OP_OPAQUE);
			Waitframe();
		}
	}
}

void BSort(int arr){
	int e = SizeOfArray(arr)-1;
	while(e>0){
		for (int i=0; i<=e; i++){
			if (arr[i]>arr[e])SwapArray(arr, i, e);
		}
		e--;
	}
}

void SwapArray(int arr, int pos1, int pos2){
	int r = arr[pos1];
	arr[pos1]=arr[pos2];
	arr[pos2]=r;
}

bool CenterLinkWithinFFC(ffc f){
	int x = CenterLinkX();
	int y = CenterLinkY();
	if (x < f->X) return false;
	if (x> f->X + f->TileWidth*16 -1)return false;
	if (y< f->Y) return false;
	if (y> f->Y+ f->TileHeight*16 -1) return false;
	return true;
}