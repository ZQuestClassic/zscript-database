const int TILE_PAINTSIGNBOARD_BUTTON_PROMPT = 12459;//Tile to use for rendering buton prompt for reading signboards

const int CSET_PAINTSIGNBOARD_BUTTON_PROMPT = 11;//CSet to use for rendering buton prompt for reading signboards

//Painting placed on wall or sign board. Stand near it and press either Ex1, A or B to display image.
//Place FFC on the signboard or painting
//D0 - Top Left corner of image
//D1 - Image width, in tiles.
//D2 - Image height, in tiles.
//D3 - Cset used for drawing.
//D4 - X offset of image drawn
//D5 - Y offset of image drawn
//D6 - 0 - black background, 1- use transparency
ffc script PaintingSignboard{
	void run(int tile, int xsize, int ysize, int cset, int Xoffset, int Yoffset, int trans){
		while(true){
			if (LinkCollision(this)){				
				Screen->FastTile(4, Link->X, Link->Y-12-(Link->Z), TILE_PAINTSIGNBOARD_BUTTON_PROMPT, CSET_PAINTSIGNBOARD_BUTTON_PROMPT, OP_OPAQUE);		
				if  ( Link->PressA || Link->PressB || Link->PressEx1){
					NoAction();
					Waitframe();
					while (LinkCollision(this)){// Stop rendering painting, when Link walks away from it. 
						if (Link->PressA) break;// Stop rendering painting, when button is pressed.
						if (Link->PressB) break;
						if (Link->PressEx1) break;
						Screen->DrawTile(5, (128-8*xsize)+Xoffset, (88-8*ysize)+Yoffset, tile, xsize, ysize, cset, -1, -1, 0, 0, 0, 0, trans>0, OP_OPAQUE);
						Waitframe();
					}
				}
			}
			Waitframe();
		}
		
	}
}

//Stand near signboard and press EX1 to read it.
//D0 - string
ffc script TextSignboard{
	void run (int str){
		while(true){
			if (LinkCollision(this)){
				Screen->FastTile(4, Link->X, Link->Y-12-(Link->Z), TILE_PAINTSIGNBOARD_BUTTON_PROMPT, CSET_PAINTSIGNBOARD_BUTTON_PROMPT, OP_OPAQUE);	
				if  ( Link->PressA || Link->PressB || Link->PressEx1){
					NoAction();
					Waitframe();
					Screen->Message(str);
				}
			}
			Waitframe();
		}
	}
}

//A speaker that plays specific sound, when pressing EX1 while near it.
//D0 - sound ID
ffc script SoundSignboard{
	void run (int snd){
		while(true){
			if (LinkCollision(this)){
				Screen->FastTile(4, Link->X, Link->Y-12-(Link->Z), TILE_PAINTSIGNBOARD_BUTTON_PROMPT, CSET_PAINTSIGNBOARD_BUTTON_PROMPT, OP_OPAQUE);	
				if  ( Link->PressA || Link->PressB || Link->PressEx1){
					NoAction();
					Waitframe();
					Game->PlaySound(snd);
				}
			}
			Waitframe();
		}
	}
}	

const int CF_SWITCHABLE_OFF = 98;//Combo flag to define switchable combo in off state
const int CF_SWITCHABLE_ON = 99;//Combo flag to define switchable combo in on state

const int SFX_SWITCH = 16;//Sound to play on activating sewitch

//Simple 2-state switch

//Place FFC st switch location
//D0 - combo to turn flagged combos in off state
//D1 - combo to turn flagged combos in on state
//D2 - Switch type
// 0 - step -> permanent (until leaving screen)
// 1 - step - on, release - off.
// 2 - Toggle state with EX1.
// 3 - Hold EX1 on switch FFC to keep switch on, otherwise off.
//D3 - Switch only combos with came CSet, as FFC.

ffc script Switch{
	void run (int cmboff, int cmbon, int type, int color){
		int cmb=-1;
		int origcmb = ComboAt (CenterX(this), CenterY(this));
		int origdata = this->Data;
		bool sw = false;
		while(true){
			cmb = ComboAt (CenterLinkX(), CenterLinkY());
			if (cmb==origcmb){
				if (type==0 || type==1){
					Game->PlaySound(SFX_SWITCH);
					sw = true;
				}
				else if (type==2){
					if (Link->PressEx1){
						Game->PlaySound(SFX_SWITCH);
						if (sw)sw=false;
						else sw=true;
					}
				}
				else if (type==3){
					if (Link->InputEx1){
						if (!sw)Game->PlaySound(SFX_SWITCH);
						sw=true;
					}
					else sw=false;
				}
			}
			else{
				if (type==1 || type==3) sw=false;
			}
			if (sw){
				this->Data=origdata+1;
				for (int i=0;i<176;i++){
					if (ComboFI(i, CF_SWITCHABLE_OFF) && (color==0 ||Screen->ComboC[i]==this->CSet)){
						Screen->ComboD[i]=cmbon;
						Screen->ComboF[i]=CF_SWITCHABLE_ON;
					}
				}
			}
			else{
				this->Data=origdata;
				for (int i=0;i<176;i++){
					if (ComboFI(i, CF_SWITCHABLE_ON)&& (color==0 ||Screen->ComboC[i]==this->CSet)){
						Screen->ComboD[i]=cmboff;
						Screen->ComboF[i]=CF_SWITCHABLE_OFF;
					}
				}
			}
			Waitframe();
		}
	}
}

//Triggers earthquake when secrets pop open.
//Place FFC anywhere on the screen.
//D0 - Earthquake duration, in frames.
//D1 - If >0 -> additionally stops MIDI
ffc script SecretEarthquake{
	void run(int power, int stopmusic){
		if (Screen->State[ST_SECRET])Quit();
		while (!Screen->State[ST_SECRET]) Waitframe();
		Screen->Quake=power;
		if (stopmusic) Game->PlayMIDI(0);
	}
}