// AdvGrass.z
// A script that correctly displays tall grass combos relationally
// (Searches layer 0 for tall grass combos, and draws new combos over them
// Good for grass combos that have a "border" of sorts around them)
// By Raiu
//
// Arrange tiles like this:
// Lone, DownVertEnd, UpVertEnd, Vertical, RightHorzEnd, DownRight, UpRight, Right, LeftHorzEnd, DownLeft, UpLeft, Left, Horizonal, Down, Up, Middle
// (this script does not support inside corner graphics...)
//
// D0 = Combo Type
//		Tallgrass = 57
//		Tallgrass continuous = 136
//		Tallgrass -> next = 141
// D1 = First Tile of the above
// D2 = Cset to use
// D3 = Layer to Draw on

ffc script AdvGrass{
	void run(int inType, int inTile, int inCset, int inLayer){
		Waitframe();
		int adj=0;
		while(true){
			for(int x = 0; x<16; x++){
				for(int y = 0; y<11; y++){
					if(Screen->ComboT[CIndex(x,y)]==inType){
						if(Screen->ComboT[CIndex(x,y-1)]==inType) adj+=1;
						if(Screen->ComboT[CIndex(x,y+1)]==inType) adj+=2;
						if(Screen->ComboT[CIndex(x-1,y)]==inType) adj+=4;
						if(Screen->ComboT[CIndex(x+1,y)]==inType) adj+=8;
						if(adj!=15){
							Screen->DrawTile(inLayer, x*16, y*16, inTile+adj, 1, 1, inCset, -1,-1, 0, 0, 0, 0, 1, 128);
						}
					adj=0;
					}
				}	
			}
			Waitframe();
		}
	}
	int CIndex(int x, int y){
		if(x<0||x>15||y<0||y>10) return -1;
		return y*16 + x;
	}
}

// This work is licensed under a Creative Commons Attribution-ShareAlike 3.0 Unported License.