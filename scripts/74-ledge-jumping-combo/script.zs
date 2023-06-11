global script LedgeJumping{
	void run(){
	bool jumping=false;
	float fallspeed=1;
		while(true){

			if(Screen->ComboT[ComboAt(Link->X+4,Link->Y+16)]==142 && Screen->ComboT[ComboAt(Link->X+12,Link->Y+16)]==142 && Link->InputDown==true && jumping==false){
				Link->Jump=1;
				fallspeed=1;
				jumping=true;
				Game->PlaySound(SFX_JUMP);
			}
			if(Screen->ComboT[ComboAt(Link->X+4,Link->Y+16)]==142 && Screen->ComboT[ComboAt(Link->X+12,Link->Y+16)]==142 && jumping==true){
				Link->Z=1;
				Link->Y+=fallspeed;
				Link->SwordJinx=2;
				Link->ItemJinx=2;
				if(fallspeed<4){ fallspeed+=0.1; }
			}
			if(Screen->ComboT[ComboAt(Link->X+4,Link->Y+9)]==142 && Screen->ComboT[ComboAt(Link->X+12,Link->Y+9)]==142 && jumping==false){
				Link->Y+=fallspeed;
			}
			if(Screen->ComboT[ComboAt(Link->X+8,Link->Y+16)]!=142){
				jumping=false;
			}

		Waitframe();
		}
	}
}