int SWORDDISTANCE = 24;
int cursoritem = 50;
const int cCSet = 7;
const int cFirstTile = 27340;
const int cSpeed = 10;
const int cFrames = 2;
const int cOpaq = 128;
const int cLayer = 7;

bool homingBrang=true;

int DeltaX;
int DeltaY;
float Deg;
int startDist;
bool wasLClick = false;
int t;
int lastScroll;

//Int to Bool
const int IB_FALSE = 64;
const int IB_TRUE = 128;

//Array Object
const int AO_ISVALID = 0;
const int AO_X = 1;
const int AO_Y = 2;
const int AO_XVEL = 3;
const int AO_YVEL = 4;
const int AO_CSET = 5;
const int AO_FTILE = 6;
const int AO_TILE = 7;
const int AO_ADELAY = 8;
const int AO_AFRAMES = 9;
const int AO_TIMER = 10;
const int AO_OPAQUE = 11;
const int AO_LAYER = 12;

int Cursor[13] = {IB_FALSE, 0, 0, 0, 0, cCSet, cFirstTile, 0, cSpeed, cFrames, 0, cOpaq, cLayer};

void HBrang(){
	int i;
	if(homingBrang && Link->InputMouseB&MB_RIGHTCLICK){
		for(i=1; i<=Screen->NumLWeapons(); i++){
			lweapon brang = Screen->LoadLWeapon(i);
			if(brang->ID==LW_BRANG && brang->DeadState!=WDS_DEAD && brang->DeadState!=WDS_BOUNCE){
				brang->Angular=true;
				brang->Angle=ArcTan(Link->InputMouseX-(brang->X+(brang->TileWidth*8-1)), Link->InputMouseY-(brang->Y+(brang->TileHeight*8-1)));
			}
		}
	}
}

void Objectify(int Object){
	if(Object[AO_ISVALID] == IB_TRUE){
		Object[AO_X]+=Object[AO_XVEL];
		Object[AO_Y]+=Object[AO_YVEL];
		if(Object[AO_TIMER] == 0){
			if(Object[AO_TILE] >= Object[AO_FTILE]+Object[AO_AFRAMES]-1 || Object[AO_TILE] < Object[AO_FTILE]){
				Object[AO_TILE] = Object[AO_FTILE];
			}
			else{
				Object[AO_TILE]++;
			}
			Object[AO_TIMER] = Object[AO_ADELAY];
		}
		else{
			Object[AO_TIMER]--;
		}
		Screen->FastTile(Object[AO_LAYER], Object[AO_X], Object[AO_Y], Object[AO_TILE], Object[AO_CSET], Object[AO_OPAQUE]);
	}
}

void setCursor(){
	if(Link->Item[cursoritem]) Cursor[AO_ISVALID]=IB_TRUE;
	else Cursor[AO_ISVALID]=IB_FALSE;
	Cursor[AO_X]=Link->InputMouseX-7;
	Cursor[AO_Y]=Link->InputMouseY-7;
}

void setControls(){
	Link->InputRight=false;
	Link->InputLeft=false;
	Link->InputUp=false;
	Link->InputDown=false;
	Link->InputR=false;
	Link->InputL=false;
	DeltaX=Link->InputMouseX-(Link->X+7);
	DeltaY=Link->InputMouseY-(Link->Y+7);
	Deg=RadtoDeg(ArcTan(DeltaX, DeltaY));
}

void Scroll(){
	if(Link->InputMouseZ>lastScroll) Link->InputL=true;
	else if(Link->InputMouseZ<lastScroll) Link->InputR=true;
	lastScroll=Link->InputMouseZ;
}

void vitalUpdates(){
	HBrang();
	setCursor();
	Objectify(Cursor);
	Scroll();
}

global script Control{
	void run(){
	while (true){
		Link->InputA=false;
		Link->InputB=false;
		setControls();
		if(Link->InputMouseB & MB_LEFTCLICK){
			if(!wasLClick) startDist=Distance(Link->InputMouseX, Link->InputMouseY, Link->X+7, Link->Y+7);
			if (startDist>=SWORDDISTANCE && (DeltaX!=0 || DeltaY!=0)) {
				if(Deg <= -157.5){
					Link->InputRight=false;
					Link->InputLeft=true;
					Link->InputUp=false;
					Link->InputDown=false;
				}
				else if(Deg < -112.5){
					Link->InputRight=false;
					Link->InputLeft=true;
					Link->InputUp=true;
					Link->InputDown=false;
				}
				else if(Deg <= -67.5){
					Link->InputRight=false;
					Link->InputLeft=false;
					Link->InputUp=true;
					Link->InputDown=false;
				}
				else if(Deg < -22.5){
					Link->InputRight=true;
					Link->InputLeft=false;
					Link->InputUp=true;
					Link->InputDown=false;
				}
				else if(Deg <= 22.5){
					Link->InputRight=true;
					Link->InputLeft=false;
					Link->InputUp=false;
					Link->InputDown=false;
				}
				else if(Deg < 67.5){
					Link->InputRight=true;
					Link->InputLeft=false;
					Link->InputUp=false;
					Link->InputDown=true;
				}
				else if(Deg <= 112.5){
					Link->InputRight=false;
					Link->InputLeft=false;
					Link->InputUp=false;
					Link->InputDown=true;
				}
				else if(Deg < 157.5){
					Link->InputRight=false;
					Link->InputLeft=true;
					Link->InputUp=false;
					Link->InputDown=true;
				}
				else {
					Link->InputRight=false;
					Link->InputLeft=true;
					Link->InputUp=false;
					Link->InputDown=false;
				}
			}
			else if(startDist<SWORDDISTANCE && !wasLClick) {
				if(Deg <= -157.5){
					Link->Dir=DIR_LEFT;
				}
				else if(Deg < -112.5){
					Link->Dir=DIR_LEFT;
				}
				else if(Deg <= -67.5){
					Link->Dir=DIR_UP;
				}
				else if(Deg < -22.5){
					Link->Dir=DIR_UP;
				}
				else if(Deg <= 22.5){
					Link->Dir=DIR_RIGHT;
				}
				else if(Deg < 67.5){
					Link->Dir=DIR_RIGHT;
				}
				else if(Deg <= 112.5){
					Link->Dir=DIR_DOWN;
				}
				else if(Deg < 157.5){
					Link->Dir=DIR_DOWN;
				}
				else {
					Link->Dir=DIR_LEFT;
				}
				Link->InputA=true;
				for(t=30; t>0; t--){
					setControls();
					Link->InputB=false;
					vitalUpdates();
					Waitframe();
				}
			}
			wasLClick=true;
		}
		else wasLClick=false;
		if(Link->InputMouseB & MB_RIGHTCLICK){
			if(Deg <= -135){
				Link->Dir=DIR_LEFT;
			}
			else if(Deg <= -45){
				Link->Dir=DIR_UP;
			}
			else if(Deg <= 45){
				Link->Dir=DIR_RIGHT;
			}
			else if(Deg <= 135){
				Link->Dir=DIR_DOWN;
			}
			else {
				Link->Dir=DIR_LEFT;
			}
			Link->InputB=true;
			for(t=30; t>0; t--){
				setControls();
				Link->InputA=false;
				vitalUpdates();
				Waitframe();
			}
		}
		vitalUpdates();
		Waitframe();
	}
	}
}

ffc script setControlSys{
	void run(int newdist, int newitem, int newcset, int newtile, int newspeed, int newframes, int newopaq, int newlayer){
		if(newdist!=-1) SWORDDISTANCE=newdist;
		if(newitem!=-1) cursoritem=newitem;
		if(newcset!=-1) Cursor[AO_CSET]=newcset;
		if(newtile!=-1) Cursor[AO_FTILE]=newtile;
		if(newspeed!=-1) Cursor[AO_ADELAY]=newspeed;
		if(newframes!=-1) Cursor[AO_AFRAMES]=newframes;
		if(newopaq!=-1) Cursor[AO_OPAQUE]=newopaq;
		if(newlayer!=-1) Cursor[AO_LAYER]=newlayer;
	}
}