const int CF_TILE_DISPLACE_PIECE = 98;//Combo flag to define puzzle area
const int SFX_TILE_DISPLACE_MOVE = 16;//Sound to play on puzzle shift

//Tile row/column shifting puzzle. Shift tiles in rows and columns to asssemble pattern. Stand on row/column, face the given direction and press EX1 to move.

//Requires chess.z and matrixpassword 4,0+
//1.build puzzle in it`s initial state. Use only fully opaque combos. Flag all combos consisting it with CF_TILE_DISPLACE_PIECE
//2. Define solution by putting it on background layer. Setup Matrix Password script and set it`s D3 to layer with solution
//3. Place invisible FFC with this script. No arguments needed.

ffc script TileDisplacePuzle{
	void run(){
		int cmb=-1;
		int disp[16];
		for (int i=0;i<16;i++){
			disp[i]=-1;
		}
		int sel=0;
		while(true){
			cmb = ComboAt(CenterLinkX(), CenterLinkY());
			if (ComboFI(cmb, CF_TILE_DISPLACE_PIECE) && (Link->PressEx1)){
				Game->PlaySound(SFX_TILE_DISPLACE_MOVE);
				sel=0;
				for (int i=0;i<16;i++){
					disp[i]=-1;
				}
				if (Link->Dir<2){
					for (int i=0; i<176; i++){
						if (OnSameFile(i, cmb) && ComboFI(i,CF_TILE_DISPLACE_PIECE)){
							disp[sel]=Screen->ComboD[i];
							sel++;
						}							
					}					
					if (Link->Dir==DIR_UP)ArrayShiftLeft(disp);
					if (Link->Dir==DIR_DOWN){
						ArrayShiftRight(disp);
						disp[0]=disp[sel];
					}
					Trace(sel);
					sel=0;
					while(disp[sel]<0){
						sel++;
						if (sel>=16)break;
					}					
					for (int i=0; i<176; i++){
						if (OnSameFile(i, cmb) && ComboFI(i,CF_TILE_DISPLACE_PIECE)){
							Screen->ComboD[i]=disp[sel];
							disp[sel]=-1;
							while(disp[sel]<0){
								sel++;
								if (sel>=16)break;
							}
						}	
					}
					sel=0;
					for (int i=0;i<16;i++){
						disp[i]=-1;
					}
				}
				else{
					for (int i=0; i<176; i++){
						if (OnSameRank(i, cmb) && ComboFI(i,CF_TILE_DISPLACE_PIECE)){
							disp[sel]=Screen->ComboD[i];
							sel++;
						}							
					}					
					if (Link->Dir==DIR_LEFT)ArrayShiftLeft(disp);
					if (Link->Dir==DIR_RIGHT){
						ArrayShiftRight(disp);
						disp[0]=disp[sel];
					}
					Trace(sel);
					sel=0;
					while(disp[sel]<0){
						sel++;
						if (sel>=16)break;
					}
					for (int i=0; i<176; i++){
						if (OnSameRank(i, cmb) && ComboFI(i,CF_TILE_DISPLACE_PIECE)){
							Screen->ComboD[i]=disp[sel];
							disp[sel]=-1;
							while(disp[sel]<0){
								sel++;
								if (sel>=16)break;
							}
						}	
					}
					sel=0;
					for (int i=0;i<16;i++){
						disp[i]=-1;
					}
				}
			}
			Waitframe();
		}		
	}
}

//Shifts the given array rightwards with rotation.
void ArrayShiftRight(int arr){
	int lasti = SizeOfArray(arr)-1;
	int res = arr[lasti];
	for(int i = lasti; i>0; i--){
		arr[i] = arr[i-1];
	}
	arr[0]=res;
}

//Shifts the given array leftwards with rotation.
void ArrayShiftLeft(int arr){
	int lasti = SizeOfArray(arr)-1;
	int res = arr[0];
	for(int i = 0; i<lasti; i++){
		arr[i] = arr[i+1];
	}
	arr[lasti]=res;
}