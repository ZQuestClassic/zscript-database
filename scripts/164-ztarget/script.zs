import "std.zh"

	const int TARGET_COMBO_ON = 4699;
	const int TARGET_COMBO_OFF = 0;
	const int TARGET_COMBO_CSET = 6;
	const int ARROW_TILE = 481;
	const int hurt = 4;
	const int speed = 300;
	
global script ZTarget{
	void run(){
		ffc Target = Screen->LoadFFC(32);
                Target->Flags[FFCF_OVERLAY] = true;
		Target->CSet = TARGET_COMBO_CSET;
		int Enemy = 0;
		bool Aim = false;
		int i = 1;
		while(true){
			npc enem = Screen->LoadNPC(Enemy);
			if (i > Screen->NumLWeapons()){
			i = 0;
			}
			if (Link->PressL){
				Enemy++;
			}
			if (Enemy > Screen->NumNPCs()){
				Enemy = 0;
			}
			if (Enemy <= Screen->NumNPCs()){
				Target->Data = TARGET_COMBO_ON;
				Target->X = enem->X;
				Target->Y = enem->Y;
				Aim = true;			}
			if (Enemy == 0){
				Target->Data = TARGET_COMBO_OFF;
				Aim = false;
			}
			if (i <= Screen->NumLWeapons() && Aim == true){
				lweapon h_arrow = Screen->LoadLWeapon(i); // Load the next weapon.
				if (h_arrow->ID == LW_ARROW) {
					int h_angle = RadianAngle(Link->X, Link->Y, enem->X, enem->Y);
					h_arrow->X = Link->X;
					h_arrow->Y = Link->Y;
			
					h_arrow->DeadState = -1;
					h_arrow->Damage = hurt;
					h_arrow->Step = speed;		//Regular arrow is around 300
					if(enem->ID == -1)
					{
						h_arrow->Dir = Link->Dir;
						if(h_arrow->Dir == 1) h_arrow->Flip = 2;
						if(h_arrow->Dir == 2) {h_arrow->Tile ++; h_arrow->Flip = 3;}
						if(h_arrow->Dir == 3) h_arrow->Tile ++;
					}
					else
					{
						h_arrow->Angular = true;
						
						h_arrow->Angle = h_angle;
						if(RadianAngleDir4(h_angle) == 1) h_arrow->Flip = 2;
						if(RadianAngleDir4(h_angle) == 2) {h_arrow->Tile ++; h_arrow->Flip = 3;}
						if(RadianAngleDir4(h_angle) == 3) h_arrow->Tile ++;
					}
					while (h_arrow->DeadState != 0){
						Target->X = enem->X;
						Target->Y = enem->Y;
						Waitframe();
					}
				}
				i++;
				
			}
			Waitframe();
		}
	}	
}