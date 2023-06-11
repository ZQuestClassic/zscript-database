const int CF_MOVING_CIRCLES_PATH = 8;//Dombo flag used for defining paths

const int CMB_MOVING_ROTCIRCLE = 956;//Combo used to render rotating circle
const int CSET_MOVING_ROTCIRCLE = 2;//CSet used to render rotating circle

const int SFX_MOVING_CIRCLES_MOVE = 50;//Sound to play, when circle starts moving
const int SFX_MOVING_CIRCLES_CANTMOVE = 16;//Sound to play, when circle tries to move off rails or onto occupied rails.
const int SFX_MOVING_CIRCLES_STOP = 16;//Sound to play, when circle stops moving

//Railroad Rotating/Moving colored circle 2*2.
//Stand on FFC, face desired direction and press EX1, to cause colored circle on rails to start it moving along it until next node (32 pixels per move).
//As circle moves, it turns 90 degrees every 32 pixels moved. Bring all circles to target positions while having them facing target directions
// to solve the puzzle.

//Build rail paths using CF_MOVING_CIRCLES_PATH flags and referring top-left corner as standpoint.

//Place FFC at operator spot.
//D0 - Combo position for starting location of colored circle.
//D1 - Starting direction facing the circle. 0 - 3
//D2 - Target position for colored circle.
//D3 - Target direction for colored circle.
//D4 - 1 - anti-clockwise rotation, 0 for clockwise rotation.
//D5 - Does not stop moving unless obstructed.


ffc script MovingEdgeMatcher{
	void run (int pos, int dir, int targetpos, int tatgetdir, int rotdir, int ice){
		int xpos = ComboX(this->InitD[0]);
		int ypos = ComboY(this->InitD[0]);
		int str[] = "MovingEdgeMatcher";
		int scr = Game->GetFFCScript(str);
		int movecounter = 0;
		int movedir=-1;
		int angle = 0;
		bool Connect = false;
		if (dir== DIR_DOWN)angle=180;
		if (dir==DIR_LEFT)angle=270;
		if (dir==DIR_RIGHT)angle=90;
		while (true){
			if (movecounter==0){
				if (RectCollision(Link->X+7, Link->Y+7, Link->X+8, Link->Y+8, this->X, this->Y, this->X+this->EffectWidth-1, this->Y+this->EffectHeight-1)){
					Screen->Rectangle(2, xpos, ypos, xpos+31, ypos+31, 1, -1, 0, 0, 0, false, OP_OPAQUE);
					if (Link->PressEx1){
						if (EdgeMatchMoverCanBeMoved(this, Link->Dir)){
							Game->PlaySound(SFX_MOVING_CIRCLES_MOVE);
							movedir=Link->Dir;
							movecounter = 16;
						}
					}
				}
			}
			else{
				NoAction();
				movecounter--;
				float consta = 5.625;
				if (movedir==DIR_UP)ypos-=2;
				if (movedir== DIR_DOWN)ypos+=2;
				if (movedir==DIR_LEFT)xpos-=2;
				if (movedir==DIR_RIGHT)xpos+=2;
				if (rotdir==1) angle -= consta;
				else angle += consta;
				if (movecounter==0){
					pos = ComboAt (xpos+1, ypos+1);
					this->InitD[0]=pos;
					if (rotdir==1)dir = RotDir(dir, -2);
					else dir = RotDir(dir, 2);
					this->InitD[1] = dir;
					if (angle>360) angle-=360;
					if (angle<0) angle+=360;
					if ((ice>0)&&(EdgeMatchMoverCanBeMoved(this, movedir))) movecounter=16;
					else{
						Game->PlaySound(SFX_MOVING_CIRCLES_STOP);
						bool secret = true;
						for (int j=1;j<=33;j++){
							if (!secret) break;
							if (j==33){
								Game->PlaySound(SFX_SECRET);
								Screen->TriggerSecrets();
								Screen->State[ST_SECRET]=true;
								break;
							}
							ffc n = Screen->LoadFFC(j);
							if (n->Script != scr) continue;
							if(n->InitD[2]!=n->InitD[0]) break;
							if(n->InitD[3]!=n->InitD[1]) break; 
						}
					}
				}
			}
			Screen->DrawCombo(2, xpos, ypos,CMB_MOVING_ROTCIRCLE, 2, 2, CSET_MOVING_ROTCIRCLE, -1, -1, xpos, ypos, angle, 0, 0,true, OP_OPAQUE);
			Waitframe();
		}
	}
}

bool EdgeMatchMoverCanBeMoved(ffc f, int dir){
	int str[] = "MovingEdgeMatcher";
	int scr = Game->GetFFCScript(str);
	int pos = f->InitD[0];
	int adj = AdjacentComboFix(pos, dir);
	if (!ComboFI(adj,CF_MOVING_CIRCLES_PATH)){
		Game->PlaySound(SFX_MOVING_CIRCLES_CANTMOVE);
		return false;
	}
	adj = AdjacentComboFix(adj, dir);
	for (int i=1;i<=33;i++){
		if (i==33) return true;
		ffc n = Screen->LoadFFC(i);
		if (n->Script!=scr) continue;
		if (n->InitD[0]==adj){
			Game->PlaySound(SFX_MOVING_CIRCLES_CANTMOVE);
			return false;
		}
	}
}

//Fixed variant of AdjacentCombo function from std_extension.zh
int AdjacentComboFix(int cmb, int dir)
{
	int combooffsets[13]={-0x10, 0x10, -1, 1, -0x11, -0x0F, 0x0F, 0x11};
	if ( cmb % 16 == 0 ) combooffsets[9] = -1;//if it's the left edge
	if ( (cmb % 16) == 15 ) combooffsets[10] = -1; //if it's the right edge
	if ( cmb < 0x10 ) combooffsets[11] = -1; //if it's the top row
	if ( cmb > 0x9F ) combooffsets[12] = -1; //if it's on the bottom row
	if ( combooffsets[9]==-1 && ( dir == DIR_LEFT || dir == DIR_LEFTUP || dir == DIR_LEFTDOWN ) ) return -1; //if the left columb
	if ( combooffsets[10]==-1 && ( dir == DIR_RIGHT || dir == DIR_RIGHTUP || dir == DIR_RIGHTDOWN ) ) return -1; //if the right column
	if ( combooffsets[11]==-1 && ( dir == DIR_UP || dir == DIR_RIGHTUP || dir == DIR_LEFTUP ) ) return -1; //if the top row
	if ( combooffsets[12]==-1 && ( dir == DIR_DOWN || dir == DIR_RIGHTDOWN || dir == DIR_LEFTDOWN ) ) return -1; //if the bottom row
	if ( cmb >= 0 && cmb < 176 ) return cmb + combooffsets[dir];
	else return -1;
}

int RotDir(int dir, int num){
	int dirs[8] = {DIR_UP, DIR_RIGHTUP, DIR_RIGHT, DIR_RIGHTDOWN, DIR_DOWN, DIR_LEFTDOWN, DIR_LEFT, DIR_LEFTUP};
	int idx=-1;
	for (int i=0; i<8; i++){
		//Trace(dirs[i]);
		if (dirs[i] == dir){
			idx=i;
			break;
		}
	}
	if (idx<0) return -1;
	idx+=num;
	while (idx<0) idx+=8;
	while (idx>=8) idx-=8;
	return dirs[idx];
}