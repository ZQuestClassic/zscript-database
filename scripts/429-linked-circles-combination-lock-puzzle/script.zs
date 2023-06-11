const int SFX_LINKED_CIRCLE_LOCK = 32; //Sound to play, when wheel`s rotation count limit is expired, and wheel is locked in place
const int SFX_LINKED_CIRCLE_MOVE = 16; //Sounto play when rotating a wheel

const int LINKED_CIRCLE_SPEED_MULTIPLER = 3;// Speed multiplier for wheel rotation. 

const int CSET_LINKED_CIRCLE_LOCKED = 11;//CSet to recolor FFC when wheel is deadlocked

//Combination lock consisting multiple linked rotateable wheels. Link can press button (stand on it and press EX1) to rotate wheel. 
//Rotating a wheel cause wheels linked to it also rotate, sometimes in bizarre patterns. Some wheels can have move limit which, when expired,
//causes them to lock in lace and block rotation, both direct and linked, which also prevents other wheels to be rotated directly.
//Input correct position on each wheel to solve puzzle.

//1. Setup combos for each button and wheel. Wheel`s combo must be directly below it`s button and has assigned to top left corner of 4x4 tile sheet.
//2. Import and compile the script. Nothing beyond classic.zh is needed.
//3. Place FFCs with button combos and scripts attached.
// D0 - Combo Position of wheel to be drawn. Wheels are rendered in order of FFC IDs.
// D1 - Initial angle of the wheel, in degrees. 0 - 359
// D2 - #####.____ - Rotation amount per button press, in degrees, multipled by LINKED_CIRCLE_SPEED_MULTIPLER, counterclockwise. Negative to reverse direction.
// D2 - _____.#### - Target direction of wheel to solve the puzzle.
// D3, D4, D5
//  #####.____ - Linked FFC rotating amount, in degrees, multipled by LINKED_CIRCLE_SPEED_MULTIPLER, counterclockwise. Negative to reverse direction.
//  _____.#### - Linked FFC ID (0-32)
// D6 - Rotation count limit. When the wheel is rotated that amount of times, direct or via linked wheels. it locks in place
//      and cannot be rotated anymore and blocks other wheels that are linked to it from being rotated directly. 0 for unlimited rotations.

ffc script LinkedCircles{
	void run (int pos, int initangle, int speed, int link1, int link2, int link3, int lock){
		int str[] = "LinkedCircles";
		int xpos = ComboX(pos);
		int ypos = ComboY(pos);
		int scr = Game->GetFFCScript(str);
		speed = GetHighFloat(speed);
		int origcset = this->CSet;
		this->InitD[2] = Abs(GetLowFloat(this->InitD[2]));
		int LinkFFC[3] = {Abs(GetLowFloat(link1)), Abs(GetLowFloat(link2)), Abs(GetLowFloat(link3))};
		int LinkSpeed[3] = {GetHighFloat(link1), GetHighFloat(link2), GetHighFloat(link3)};
		if (Screen->State[ST_SECRET]) this->InitD[1] = this->InitD[2];
		while (true){
			if (this->InitD[7]!=0){
				NoAction();
				if (this->InitD[7]>0) this->InitD[1]-=LINKED_CIRCLE_SPEED_MULTIPLER;
				else if (this->InitD[7]<0) this->InitD[1]+=LINKED_CIRCLE_SPEED_MULTIPLER;				
				if (this->InitD[7]>0) this->InitD[7]--;
				else if (this->InitD[7]<0) this->InitD[7]++;
				if (this->InitD[7]==0){
					if (this->InitD[1]<0)this->InitD[1] += 360;
					if (this->InitD[1]>= 360)this->InitD[1] -= 360;
					//Trace(this->InitD[1]);
					//Trace(this->InitD[2]);
					
					if (this->InitD[6]>0){
						this->InitD[6]--;
						if (this->InitD[6]==0){
							Game->PlaySound(SFX_LINKED_CIRCLE_LOCK);
							this->InitD[6]=-1;
							this->CSet=CSET_LINKED_CIRCLE_LOCKED;
							for (int i = 1; i<= 32; i++){
								ffc f = Screen->LoadFFC(i);
								if (f->Script != scr) continue;
								if (!CanBeRotated(f)) f->CSet = CSET_LINKED_CIRCLE_LOCKED;
							}
						}
					}
					for (int i = 1; i<= 33; i++){
						if (Screen->State[ST_SECRET]) break;
						if (i==33 && !Screen->State[ST_SECRET]){
							Game->PlaySound(SFX_SECRET);
							Screen->TriggerSecrets();
							Screen->State[ST_SECRET]=true;
							break;
						}
						ffc f = Screen->LoadFFC(i);
						if (f->Script != scr) continue;
						if (f->InitD[1]!=f->InitD[2]) break;
						if (f->InitD[7]!=0) break;
					}
				}
			}
			else if (RectCollision(Link->X+7, Link->Y+7, Link->X+8, Link->Y+8, this->X, this->Y, this->X+this->EffectWidth-1, this->Y+this->EffectHeight-1)){
				if (Link->PressEx1){
					if (CanBeRotated(this)){
						Game->PlaySound(SFX_LINKED_CIRCLE_MOVE);
						this->InitD[7] = speed;
						for (int i=0; i<3; i++){
							int linka =  LinkFFC[i];
							if (linka > 0){
								ffc n = Screen->LoadFFC(linka);
								n->InitD[7] = LinkSpeed[i];
							} 
						}					
					}
				}
			}
			Screen->DrawCombo(2, xpos, ypos, this->Data+4, 4, 4, origcset, -1, -1, xpos, ypos, this->InitD[1], 0, 0,true, OP_OPAQUE);
			Waitframe();
		}
	}
}

bool CanBeRotated(ffc f){
	if (f->InitD[6]<0) return false;
	for (int i=3; i<6; i++){
		int link1 =  Abs(GetLowFloat(f->InitD[i]));
		if (link1 > 0){
			ffc n = Screen->LoadFFC(link1);
			if (n->InitD[7]!=0) return false;
			if (n->InitD[6] <0) return false;
		} 
	}
	return true;
}