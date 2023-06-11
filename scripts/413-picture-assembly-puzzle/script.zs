//Picture assembly puzzle. Assemble picture by pushing combos to solve it.

//1. Set up solid combos to form 2*2 to 4*4 picture 
//2. Place FFC where you want fully assembled picture to be.
//3. Assign FFC`s combo to top left corner of picture.
//4. Set up Tile Width and Tile Height to determine picture dimensions.
//5. Set "Run at Screen Init" FFC flag.
//6. No arguments needed. Scatter picture parts (combos from step 1) anywhere in the screen and flag them as pushable.

ffc script PicturePuzzle{
	void run(){
		int origdata = this->Data;
		this->Data=FFCS_INVISIBLE_COMBO;
		int origpos = ComboAt(this->X, this->Y);
		int arrcmb[16];
		int arrpos[16];
		for (int i=0; i<16; i++){
			if (((i)%4) >= this->TileWidth){
				arrcmb[i] = -1;
				arrpos[i] = -1;
				continue;
			}
			else if ((Div(i, 4)+1)> this->TileHeight){
				arrcmb[i] = -1;
				arrpos[i] = -1;
				continue;
			}
			else{
				arrcmb[i] = origdata + i ;
				arrpos[i] = origpos + (Div(i, 4) * 16) + i%4;
				continue;
			}
		}
		if (Screen->State[ST_SECRET]){
			for (int i=0; i<16; i++){
				int cmb = arrpos[i];
				if (arrpos[i]>=0)Screen->ComboD[cmb] = arrcmb[i];				
			}
			Quit();
		}
		while(true){
			for (int i=0; i<=16; i++){
				if (i==16){
					Game->PlaySound(27);
					Screen->TriggerSecrets();
					Screen->State[ST_SECRET]=true;
					Quit();
				}
				if (arrpos[i]<0) continue;
				int cmb = arrpos[i];
				if (Screen->ComboD[cmb] != arrcmb[i]) break;
			}
			Waitframe();
		}
	}
}