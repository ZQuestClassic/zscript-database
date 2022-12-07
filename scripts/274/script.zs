import "std.zh"

const int ObjectRotation_BlankCombo = 1; //combo ID of a blank combo that uses the top left combo of a 4x4 block of blank tiles as it's tile

ffc script ObjectRotation{
	void run(int DrawLayer, int RotationSpeed){
		int OriginalCombo = this->Data;
		this->Data = ObjectRotation_BlankCombo;
		int Opacity = OP_OPAQUE;
		if ( this->Flags[FFCF_TRANS] )
			Opacity = OP_TRANS;
		int Rotation;
		while(true){
			Screen->DrawTile(DrawLayer, this->X, this->Y, Game->ComboTile(OriginalCombo), this->TileWidth, this->TileHeight, this->CSet, -1, -1, this->X, this->Y, Rotation, 0, true, Opacity);
			Rotation += RotationSpeed;
			if(Rotation < -360)Rotation+=360; //Wrap if below -360. ???? i dont know
			else if(Rotation > 360)Rotation-=360; //Wrap if above 360. ???? i dont know
			Waitframe();
		}
	}
}