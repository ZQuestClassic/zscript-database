//Bigger FFC script
//by Pokemonmaster64
//D0 is the desired width in tiles of the FFC
//D1 is the desired height in tiles of the FFC
//D2 is the layer to draw the FFC on
//This script will not expand Combo attributes like damage
//or flags to the expanded regions, but can be useful for
//moving visuals larger than 4x4 tiles.

ffc script Biggerer{
	void run(int bigwidth, int bigheight, int layer){
		while(true){
			for(int wi=0; wi<=bigwidth-1; wi++){
				for(int hi=0; hi<=bigheight-1; hi++){
					Screen->FastTile(layer, this->X+16*wi, this->Y+16*hi, Game->ComboTile(this->Data)+wi+20*hi, this->CSet, 128);
				}
			}
			Waitframe();
		}
	}
}