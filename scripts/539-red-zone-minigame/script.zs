const int TILE_REDZONE_FRAME = 20052;//Top left corner of 3*3 tile setup used to render gauge frame
const int CSET_REDZONE_FRAME = 7;//CSet used to render gauge frame

const int TILE_REDZONE_TARGET = 20075;//Tile used to render red zone target boundaries.
const int TILE_REDZONE_MARK = 20055;//Tile used to render red zone moving marker.
const int CSET_REDZONE_TARGET = 8;//CSet used to render red zone target boundaries.
const int CSET_REDZONE_MARK = 5;//CSet used to render red zone moving marker.
const int CSET_REDZONE_FAIL = 11;//CSet used to turn combo above FFC whel Link fails to hit Red Zone.
const int CSET_REDZONE_HIT = 5;//CSet used to turn combo above FFC whel Link hits the Red Zone.

const int FONT_REDZONE_TIMELIMIT = 0;//Font used to render timer, if minigame has time limit.

//Red Zone
//A family of timing minigames. Stand on FFC and press Ex1. A gauge appears with 2 stationary red markers and blue one that moves back and forth. Press Ex1, when blue marker is between red ones to win the game.

//1. Place FFC below a solid combo.
// D0 - Gauge size. Must be a multiple of 16.
// D1 - Blue marker moving speed, in pixels per frame.
// D2 - lower Red marker posiion.
// D3 - higher Red marker posiion.
// D4 - >0 - turns the game into one similar to Might Test minigame from Mortal Kombat 1. Accumulate blue marker height by rapidly pressing Ex2, then land it into the Red Zone via Ex1. Higher D4 value, the fewer Ex2 presses will be needed to maximize marker height.
// D5 - add together:
//    1 - Fail the minigame, if marker hits maximum possible position (overshoot).
//    2 - If time limit expires, when marker in in Red Zone, the minigame counts as won.
// D6 - Time limit, in frames. 0 for no time limit.

ffc script RedZone{
	void run(int max, int speed, int targetmin, int targetmax, int rapidpress, int flags, int timelimit){
		int mark = 0;
		int state = 0;
		int timer = 0;
		int cmb = 0;
		bool failure = false;
		bool failmax = flags&1;
		bool lastchancetimeout = flags&2;
		this->InitD[7]=0;
		int pos = ComboAt(CenterX(this),CenterY(this));
		while(true){
			if (state==0){
				cmb = ComboAt (CenterLinkX(), CenterLinkY()-2);
				if (cmb==pos){
					if (Link->PressEx1 && this->InitD[7]==0){
						Link->PressEx1=false;
						state=1;
					}
				}
			}
			else if (state==1){
				if (rapidpress>0){
					if (Link->PressEx2) mark+=rapidpress*speed;
					else mark-= speed;
				}
				else mark+=speed;
				if (mark>=max){
					if(failmax&& (mark>max || rapidpress==0)) failure=true;
					else if (rapidpress>0) mark=max;
					else speed*=-1;
				}
				if (mark<=0){
					if (rapidpress>0) mark=0;
					else speed*=-1;
				}
				if (timelimit>0){
					timelimit--;
					if (timelimit==0){
						if (lastchancetimeout) Link->PressEx1 = true;
						else failure = true;
					}
				}
				if (Link->PressEx1 && !failure){
					if (mark>=targetmin && mark<= targetmax){
						this->InitD[7]=1;
						if ((pos-16)>=0)Screen->ComboC[pos-16] = CSET_REDZONE_HIT;
						speed=0;
						for(int i=1;i<=33;i++){
							if (Screen->State[ST_SECRET]) break;
							if (i==33){
								Game->PlaySound(SFX_SECRET);
								Screen->TriggerSecrets();
								Screen->State[ST_SECRET]=true;
								break;
							}
							ffc n = Screen->LoadFFC(i);
							if (n->Script!=this->Script)continue;
							if (n->InitD[7] == 0) break;
						}
						timelimit = this->InitD[6];
						mark=0;
						state=0;
					}
					else failure= true;
				}
				DrawFrame(3, TILE_REDZONE_FRAME, Link->X, Link->Y-max-32, 2, 2+(max/16), CSET_REDZONE_FRAME, OP_OPAQUE);
				Screen->FastTile(3, Link->X+8, Link->Y-16-mark, TILE_REDZONE_MARK, CSET_REDZONE_MARK, OP_OPAQUE);
				Screen->FastTile(3, Link->X+8, Link->Y-16-targetmin, TILE_REDZONE_TARGET, CSET_REDZONE_TARGET, OP_OPAQUE);
				Screen->FastTile(3, Link->X+8, Link->Y-16-targetmax, TILE_REDZONE_TARGET, CSET_REDZONE_TARGET, OP_OPAQUE);
				if (timelimit>0)Screen->DrawInteger(3, Link->X, Link->Y-max-32, FONT_REDZONE_TIMELIMIT,1,0, -1, -1, Ceiling(timelimit/60), 0, OP_OPAQUE);
				NoAction();
			}
			if (failure){
				eweapon e = CreateEWeaponAt(EW_BOMBBLAST, Link->X, Link->Y-16-mark);
				e->CollDetection=false;
				if ((pos-16)>=0)Screen->ComboC[pos-16] = CSET_REDZONE_FAIL;
				Quit();
			}
			// debugValue(1,cmb);
			// debugValue(2,mark);
			Waitframe();
		}
	}
}


void DrawFrame(int layer, int tile, int posx, int posy, int sizex, int sizey, int CSet, int opacity){
	int drawx = posx;
	int drawy = posy;
	int xoffset=0;
	int yoffset=0;
	for (int w=0; w<sizex; w++){
		drawx = posx+16*w;
		xoffset=0;
		if (w>0)xoffset=1;
		if (w==sizex-1) xoffset=2;
		for (int h=0; h<sizey; h++){
			drawy = posy+16*h;
			yoffset=0;
			if (h>0)yoffset=1;
			if (h==sizey-1) yoffset=2;
			Screen->FastTile(layer, drawx, drawy, tile +xoffset+20*yoffset, CSet, opacity);
		}
	}
}