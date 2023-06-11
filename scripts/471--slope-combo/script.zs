const bool SLOPE_FIX_MISALIGNS = true; //Setting for correcting SCREEN CRIMES if you're having slopes cross a screen border

//InitD[0] - Horizontal steepness of the slope. If it's a left facing slope, this number is negative
//InitD[1] - Vertical steepness of the slope
combodata script Slope{
	bool SlopeCanPlaceLink(int linkX, int linkY){
		for(int i=0; i<4; ++i){
			int x = linkX+(i%2)*15;
			int y = linkY+8+Floor(i/2)*7;
			if(Screen->isSolid(x, y))
				return false;
		}
		return true;
	}
	void run(int vY){
		mapdata lyr = Game->LoadTempScreen(this->Layer);
		
		//Only the first instance of the script keeps running
		for(int i=0; i<176; ++i){
			combodata cd = Game->LoadComboData(lyr->ComboD[i]);
			if(cd->Script==this->Script){
				if(i!=this->Pos)
					Quit();
				else
					break;
			}
		}
		
		if(SLOPE_FIX_MISALIGNS){
			if(!SlopeCanPlaceLink(Link->X, Link->Y)){
				int gridY = Round(Link->Y/8)*8;
				int yOffs[] = {0, -8, 8, -16, 16};
				for(int i=0; i<5; ++i){
					if(SlopeCanPlaceLink(Link->X, gridY+yOffs[i])){
						Link->Y = gridY+yOffs[i];
						break;
					}
				}
			}
		}
		
		while(true){
			if(Link->Action==LA_NONE||Link->Action==LA_WALKING){
				int vY;
				int vY2;
				//Check two combo positions to find the slope Link is standing on
				//Since Link's center is between two pixels, this is necessary so he can walk against the edge of half tile solids and still be pushed upward
				for(int i=0; i<2; ++i){
					combodata cd = Game->LoadComboData(lyr->ComboD[ComboAt(Link->X+7+i, Link->Y+12)]);
					if(cd->Script==this->Script){
						int slope = cd->InitD[0];
						if(vY==0||Sign(vY)==Sign(slope)){
							if(Abs(slope)>Abs(vY))
								vY = slope;
						}
						else
							vY = 0;
						
						int slope2 = cd->InitD[1];
						if(vY2==0||Sign(vY2)==Sign(slope2)){
							if(Abs(slope2)>Abs(vY2))
								vY2 = slope2;
						}
						else
							vY2 = 0;
					}
				}
				
				//Change vY based on Link's step speed. Link moves slower on each axis when moving at a diagonal
				vY *= Link->Step/100;
				if(LinkMovement_StickX()!=0&&LinkMovement_StickY()!=0)
					vY *= 0.7071;
				
				vY2 *= Link->Step/100;
				if(LinkMovement_StickX()!=0&&LinkMovement_StickY()!=0)
					vY2 *= 0.7071;
				
				LinkMovement_Push(0, vY*LinkMovement_StickX()+vY2*Abs(LinkMovement_StickY()));
			}
			
			Waitframe();
		}
	}
}