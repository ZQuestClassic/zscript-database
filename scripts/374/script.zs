//This function handles which button does the roll
bool LinkRoll_PressRoll(){
	return Link->PressL; //Replace this with whatever button you want
}
bool LinkRoll_DisableRollInput(){
	//Same as above set these to the button you want
	Link->PressL = false;
	Link->InputL = false;
}

//This function handles interaction with other scripts that will need to interrupt the roll early
bool LinkRoll_CheckInterrupt(){
	//For use with MooshPits
	//if(MooshPit[_MP_FALLSTATE]==1)return true;
	
	return Link->Action!=LA_NONE&&Link->Action!=LA_WALKING;
}

const int TIL_LINKROLL4 = 33420; //The tile for Link's roll. First of four directions: Up, Down, Left, Right
const int AFRAMES_LINKROLL4 = 3; //The number of frames per roll direction
const int ASPEED_LINKROLL4 = 4; //The animation speed of the roll

const int TIL_LINKBONK4 = 33260; //The tile for Link's wall bonk. First of four directions: Up, Down, Left, Right

const int SFX_LINKROLL = 60; //Sound to play when Link rolls
const int NUM_SFX_LINKROLL = 0; //Number of sounds to play when rolling at random

const int SFX_LINKBONK = 21; //Sound of Link bonking on a wall

const int SPR_LINKROLL_DUST = 89; //Sprite used for dust drawn behind Link
const int FREQ_LINKROLL_DUST = 2; //How frequently dust particles are emitted in frame delay

const int MPCOST_LINKROLL = 0; //MP to take when Link rolls

const int LINKROLL_STEP = 4; //Step speed of the roll
const int LINKROLL_MINSTEP = 2.5; //Minimum step speed with acceleration based rolling
const int LINKROLL_FRAMES = 8; //How many frames Link rolls for before deccelerating
const int LINKROLL_DECEL = 0.5; //Deacceleration of the roll
const int LINKROLL_IFRAMES = 8; //How many frames of the roll Link is invincible for
const int LINKROLL_IFRAMES_DELAY = 0; //Delay at the start of the roll where Link isn't invincible
const int LINKROLL_COOLDOWN = 8; //Delay before Link can roll again after coming to a stop
const int LINKROLL_TRACKINGLENGTH = 16; //If using acceleration based rolling, how many frames the script tracks Link's movement for

const int LINKROLL_BONK_STEP = 0.5; //Step speed when bonking off a wall
const int LINKROLL_BONK_JUMP = 1.2; //Jump height when bonking off a wall

const int LINKROLL_8WAY = 1; //If 1, Link can roll 8 directions. If 2, Link rolls based on acceleration allowing for more than 8 directions.
const int LINKROLL_VARIABLESPEED = 0; //If 1, Link's movement before rolling affects roll speed
const int LINKROLL_STOPWALL = 1; //If 1, stops roll momentum when hitting a wall
const int LINKROLL_CANBONK = 1; //If 1, Link can bonk against walls after rolling

int LinkRoll[256];

const int _LRI_VX = 0;
const int _LRI_VY = 1;
const int _LRI_COUNTER = 2;
const int _LRI_STEP = 3;
const int _LRI_ANGLE = 4;
const int _LRI_STATE = 5;
const int _LRI_TRACKING = 16;

void LinkRoll_Init(){
	int i;
	for(i=0; i<_LRI_TRACKING; ++i){
		LinkRoll[i] = 0;
	}
	LinkRoll_ResetTracking();
}

void LinkRoll_Update(){
	if(Link->Action==LA_SCROLLING){
		LinkRoll[_LRI_STATE] = 0;
		LinkRoll[_LRI_COUNTER] = 0;
		LinkRoll_DisableRollInput();
		return;
	}
	
	//Only update movement tracking if it's needed
	if(LINKROLL_8WAY==2||LINKROLL_VARIABLESPEED)
		LinkRoll_UpdateTracking();
	
	int vX; int vY;
			
	//If Link is currently rolling
	if(LinkRoll[_LRI_STATE]){
		if(LinkRoll[_LRI_STATE]==1){ //Rolling
			//Things that cancel rolling
			if(LinkRoll_CheckInterrupt()){
				LinkRoll[_LRI_STATE] = 3;
				LinkRoll[_LRI_COUNTER] = LINKROLL_COOLDOWN;
				NoAction();
				return;
			}
			
			//Make Link invincible during iframes
			if(LinkRoll[_LRI_COUNTER]>=LINKROLL_IFRAMES_DELAY&&LinkRoll[_LRI_COUNTER]<LINKROLL_IFRAMES_DELAY+LINKROLL_IFRAMES)
				TempLinkState_UnsetCollDetection();
			
			int frame;
			int frameWidth = 1;
			if(TEMPLINKSTATE_BIG_LINK==2)
				frameWidth = 2;
			//Only animate if aframes and aspeed are set
			if(AFRAMES_LINKROLL4&&ASPEED_LINKROLL4)
				frame = Floor((LinkRoll[_LRI_COUNTER]%(AFRAMES_LINKROLL4*ASPEED_LINKROLL4))/ASPEED_LINKROLL4);
			TempLinkState_SetLinkTileOverride(TIL_LINKROLL4+Link->Dir*AFRAMES_LINKROLL4+frame*frameWidth);
		
			//Create dust particles periodically
			if(SPR_LINKROLL_DUST){
				if(LinkRoll[_LRI_COUNTER]%FREQ_LINKROLL_DUST==0){
					lweapon l = CreateLWeaponAt(LW_SPARKLE, Link->X+Rand(-4, 4), Link->Y+8+Rand(-4, 4));
					l->UseSprite(SPR_LINKROLL_DUST);
					l->CollDetection = false;
				}
			}
			
			vX = VectorX(LinkRoll[_LRI_STEP], LinkRoll[_LRI_ANGLE]);
			vY = VectorY(LinkRoll[_LRI_STEP], LinkRoll[_LRI_ANGLE]);
			//If Link is rolling into a wall on X or Y axis, kill momentum on that axis
			if(LINKROLL_STOPWALL){
				if((vX<0&&LinkRoll_CheckBlocked(Link->X, Link->Y, DIR_LEFT))||(vX>0&&LinkRoll_CheckBlocked(Link->X, Link->Y, DIR_RIGHT))){
					LinkRoll[_LRI_VX] = 0;
				}
				if((vY<0&&LinkRoll_CheckBlocked(Link->X, Link->Y, DIR_UP))||(vY>0&&LinkRoll_CheckBlocked(Link->X, Link->Y, DIR_DOWN))){
					LinkRoll[_LRI_VY] = 0;
				}
			}
			
			//If Link bonks off a wall
			if(LINKROLL_CANBONK){
				if(LinkRoll_CheckBlocked(Link->X, Link->Y, Link->Dir)==1){
					Game->PlaySound(SFX_LINKBONK);
					Link->Jump = LINKROLL_BONK_JUMP;
					LinkRoll[_LRI_ANGLE] = LinkRoll_DirAngle(OppositeDir(Link->Dir));
					LinkRoll[_LRI_STEP] = LINKROLL_BONK_STEP;
					LinkRoll[_LRI_STATE] = 2;
					NoAction();
					return;
				}
			}
			
			//Actually kill temporary momentum if flagged to do so
			if(LinkRoll[_LRI_VX]==0)
				vX = 0;
			if(LinkRoll[_LRI_VY]==0)
				vY = 0;
		
			LinkMovement_Push2NoEdge(vX, vY);
		
			++LinkRoll[_LRI_COUNTER];
			if(LinkRoll[_LRI_COUNTER]>=LINKROLL_FRAMES){
				if(LINKROLL_DECEL!=0){
					LinkRoll[_LRI_STEP] -= LINKROLL_DECEL;
					if(LinkRoll[_LRI_STEP]<=0){
						LinkRoll[_LRI_STATE] = 3;
						LinkRoll[_LRI_COUNTER] = LINKROLL_COOLDOWN;
					}
				}
				else{
					LinkRoll[_LRI_STATE] = 3;
					LinkRoll[_LRI_COUNTER] = LINKROLL_COOLDOWN;
				}
			}
		
			NoAction();
		}
		else if(LinkRoll[_LRI_STATE]==2){ //Bonking
			vX = VectorX(LinkRoll[_LRI_STEP], LinkRoll[_LRI_ANGLE]);
			vY = VectorY(LinkRoll[_LRI_STEP], LinkRoll[_LRI_ANGLE]);
			
			int frameWidth = 1;
			if(TEMPLINKSTATE_BIG_LINK==2)
				frameWidth = 2;
			TempLinkState_SetLinkTileOverride(TIL_LINKBONK4+Link->Dir*frameWidth);
		
			LinkMovement_Push2NoEdge(vX, vY);
			
			if(LinkRoll_OnGround()||Link->Jump<-LINKROLL_BONK_JUMP){
				LinkRoll[_LRI_STATE] = 3;
				LinkRoll[_LRI_COUNTER] = LINKROLL_COOLDOWN;
			}
		
			NoAction();
		}
		else if(LinkRoll[_LRI_STATE]==3){ //Cooldown
			--LinkRoll[_LRI_COUNTER];
			if(LinkRoll[_LRI_COUNTER]<=0)
				LinkRoll[_LRI_STATE] = 0;
		}
	}
	else{
		//Begin roll when the button is pressed
		if(LinkRoll_OnGround()&&(Link->Action==LA_WALKING||Link->Action==LA_NONE)&&LinkRoll_PressRoll()&&Link->MP>=MPCOST_LINKROLL){
			Link->MP -= MPCOST_LINKROLL;
			
			if(NUM_SFX_LINKROLL)
				Game->PlaySound(SFX_LINKROLL+Rand(NUM_SFX_LINKROLL));
			else
				Game->PlaySound(SFX_LINKROLL);
			
			int rollDir;
			int rollDist;
			LinkRoll[_LRI_STEP] = LINKROLL_STEP;
			LinkRoll[_LRI_STATE] = 1;
			LinkRoll[_LRI_COUNTER] = 0;
			
			//360 degree rolling
			if(LINKROLL_8WAY==2){
				rollDist = LinkRoll_GetAverageStep();
				if(rollDist>0){
					LinkRoll[_LRI_ANGLE] = LinkRoll_GetAverageAngle();
					rollDir = AngleDir8(LinkRoll[_LRI_ANGLE]);
					//If Link isn't already partially facing the right direction, turn him to face it
					if(!LinkRoll_PartialDir(Link->Dir, rollDir)){
						Link->Dir = AngleDir4(LinkRoll[_LRI_ANGLE]);
					}
				}
				else{
					LinkRoll[_LRI_ANGLE] = LinkRoll_DirAngle(Link->Dir);
				}
			}
			//8-way rolling
			else if(LINKROLL_8WAY==1){
				//If a direction is being held, use the stick
				if(LinkMovement_StickX()!=0||LinkMovement_StickY()!=0){
					LinkRoll[_LRI_ANGLE] = Angle(0, 0, LinkMovement_StickX(), LinkMovement_StickY());
					rollDir = AngleDir8(LinkRoll[_LRI_ANGLE]);
					//If Link isn't already partially facing the right direction, turn him to face it
					if(!LinkRoll_PartialDir(Link->Dir, rollDir)){
						Link->Dir = AngleDir4(LinkRoll[_LRI_ANGLE]);
					}
				}
				//Else use Link's direction
				else{
					LinkRoll[_LRI_ANGLE] = LinkRoll_DirAngle(Link->Dir);
				}
			}
			//4-way rolling
			else{
				LinkRoll[_LRI_ANGLE] = LinkRoll_DirAngle(Link->Dir);
			}
			
			//If variable speed is set, change Link's roll speed based on that
			if(LINKROLL_VARIABLESPEED){
				rollDist = LinkRoll_GetAverageStep();
				LinkRoll[_LRI_STEP] = Max(LINKROLL_MINSTEP, LinkRoll[_LRI_STEP]*(rollDist/1.5));
			}
			LinkRoll[_LRI_VX] = VectorX(LinkRoll[_LRI_STEP], LinkRoll[_LRI_ANGLE]);
			LinkRoll[_LRI_VY] = VectorY(LinkRoll[_LRI_STEP], LinkRoll[_LRI_ANGLE]);
			
			NoAction();
		}
	}
	LinkRoll_DisableRollInput();
}

//Returns true if Link is standing on something solid
bool LinkRoll_OnGround(){
	if(IsSideview()){
		return OnSidePlatform(Link->X, Link->Y)&&Link->Jump<=0;
	}
	else{
		return Link->Z==0&&Link->Jump<=0;
	}
}

//Reset the arrays tracking Link's movement
void LinkRoll_ResetTracking(){
	for(int i=LINKROLL_TRACKINGLENGTH-1; i>=0; --i){
		LinkRoll[_LRI_TRACKING+2+i*2] = 0;
		LinkRoll[_LRI_TRACKING+2+i*2+1] = 0;
	}
	LinkRoll[_LRI_TRACKING] = Link->X;
	LinkRoll[_LRI_TRACKING+1] = Link->X;
}

//Updates the arrays tracking Link's movement
void LinkRoll_UpdateTracking(){
	for(int i=LINKROLL_TRACKINGLENGTH-1; i>=1; --i){
		LinkRoll[_LRI_TRACKING+2+i*2] = LinkRoll[_LRI_TRACKING+2+i*2-2];
		LinkRoll[_LRI_TRACKING+2+i*2+1] = LinkRoll[_LRI_TRACKING+2+i*2-2+1];
	}
	
	int vX = Link->X-LinkRoll[_LRI_TRACKING];
	int vY = Link->Y-LinkRoll[_LRI_TRACKING+1];
	
	//If something messes with Link's speed, keep it clamped to his normal step
	//This should also prevent warps from having a noticeable effect on the tracking. Janky hack m8
	if(Distance(0, 0, vX, vY)>2){
		int angle = Angle(0, 0, vX, vY);
		vX = VectorX(1.5, angle);
		vY = VectorY(1.5, angle);
	}
	
	LinkRoll[_LRI_TRACKING+2] = vX;
	LinkRoll[_LRI_TRACKING+3] = vY;
	
	LinkRoll[_LRI_TRACKING] = Link->X;
	LinkRoll[_LRI_TRACKING+1] = Link->Y;
}

//Returns the angle of the average of Link's last 16 frames
int LinkRoll_GetAverageAngle(){
	int vX; int vY;
	for(int i=0; i<LINKROLL_TRACKINGLENGTH; ++i){
		vX += LinkRoll[_LRI_TRACKING+2+i*2];
		vY += LinkRoll[_LRI_TRACKING+2+i*2+1];
	}
	vX /= LINKROLL_TRACKINGLENGTH;
	vY /= LINKROLL_TRACKINGLENGTH;
	
	return Angle(0, 0, vX, vY);
}

//Returns the step of the average of Link's last 16 frames
int LinkRoll_GetAverageStep(){
	int vX; int vY;
	for(int i=0; i<LINKROLL_TRACKINGLENGTH; ++i){
		vX += LinkRoll[_LRI_TRACKING+2+i*2];
		vY += LinkRoll[_LRI_TRACKING+2+i*2+1];
	}
	vX /= LINKROLL_TRACKINGLENGTH;
	vY /= LINKROLL_TRACKINGLENGTH;
	
	return Distance(0, 0, vX, vY);
}

//Returns true if a 4-way direction is part of an 8-way direction
bool LinkRoll_PartialDir(int dir4, int dir8){
	if(dir4==DIR_UP)
		return dir8==DIR_UP||dir8==DIR_LEFTUP||dir8==DIR_RIGHTUP;
	else if(dir4==DIR_DOWN)
		return dir8==DIR_DOWN||dir8==DIR_LEFTDOWN||dir8==DIR_RIGHTDOWN;
	else if(dir4==DIR_LEFT)
		return dir8==DIR_LEFT||dir8==DIR_LEFTUP||dir8==DIR_LEFTDOWN;
	else
		return dir8==DIR_RIGHT||dir8==DIR_RIGHTUP||dir8==DIR_RIGHTDOWN;
}

//Returns an angle given a direction
int LinkRoll_DirAngle(int dir){
	if(dir==DIR_UP)
		return -90;
	else if(dir==DIR_DOWN)
		return 90;
	else if(dir==DIR_LEFT)
		return 180;
	else if(dir==DIR_RIGHT)
		return 0;
	else if(dir==DIR_LEFTUP)
		return -135;
	else if(dir==DIR_RIGHTUP)
		return -45;
	else if(dir==DIR_LEFTDOWN)
		return 135;
	else if(dir==DIR_RIGHTDOWN)
		return 45;
	return 0;
}

//Modified CanWalk() used to allow walking offscreen
bool LinkRoll_CanWalkNoEdge(int x, int y, int dir, int step, bool full_tile) {
    int c=8;
    int xx = x+15;
    int yy = y+15;
    if(full_tile) c=0;
    if(dir==0) return !(Screen->isSolid(x,y+c-step)||Screen->isSolid(x+8,y+c-step)||Screen->isSolid(xx,y+c-step));
    else if(dir==1) return !(Screen->isSolid(x,yy+step)||Screen->isSolid(x+8,yy+step)||Screen->isSolid(xx,yy+step));
    else if(dir==2) return !(Screen->isSolid(x-step,y+c)||Screen->isSolid(x-step,y+c+7)||Screen->isSolid(x-step,yy));
    else if(dir==3) return !(Screen->isSolid(xx+step,y+c)||Screen->isSolid(xx+step,y+c+7)||Screen->isSolid(xx+step,yy));
    return false; //invalid direction
}

//Returns if Link can roll in a direction
//0 - Can walk
//1 - Bonked on wall
//2 - Can't roll
int LinkRoll_CheckBlocked(int x, int y, int dir){
	if(Screen->MovingBlockX!=-1&&Screen->MovingBlockY!=-1){
		if(RectCollision(Link->X-1, Link->Y-1, Link->X+16, Link->Y+16, Screen->MovingBlockX, Screen->MovingBlockY, Screen->MovingBlockX+15, Screen->MovingBlockY+15)){
			if(AngleDir4(Angle(Link->X, Link->Y, Screen->MovingBlockX, Screen->MovingBlockY))==dir){
				return 1;
			}
		}
	}
	if(IsSideview()){
		if(dir==DIR_LEFT||dir==DIR_RIGHT){
			if(!LinkRoll_CanWalkNoEdge(Link->X, Link->Y, dir, 1, true))
				return 1;
			return 0;
		}
		return 2;
	}
	if(!LinkRoll_CanWalkNoEdge(Link->X, Link->Y, dir, 1, false))
		return 1;
	return 0;
}

global script RollExample{
	void run(){
		LinkRoll_Init();
		ScrollingDraws_Init();
		LinkMovement_Init();
		TempLinkState_Init();
		while(true){
			LinkRoll_Update();
			ScrollingDraws_Update();
			LinkMovement_Update1();
			TempLinkState_Update1();
			
			Waitdraw();
			
			LinkMovement_Update2();
			TempLinkState_Update2();
			
			Waitframe();
		}
	}
}