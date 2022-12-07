const int SPR_LINKCRUSH = 88; //Sprite of Link being crushed
const int SFX_LINKCRUSH = 11; //Sound that plays when Link gets crushed
const int SFX_ENEMYCRUSH = 11; //Sound that plays when an enemy gets crushed
const int DAMAGE_LINKCRUSH = 8; //Damage taken from being crushed

const int DELAY_CRUSH = 40; //Delay before Link respawns after being crushed
const int DELAYMAX_CRUSH = 300; //Max delay before Link respawns

const int SOLIDOBJ_MAX = 32; //Maximum number of solid objects
const int SOLIDOBJ_CRUSH_BEHAVIOR = 1; //How solid objects behave with crushing Link (0=No interaction, 1=Return to screen entrance, 2=Instant death)
const int SOLIDOBJ_CRUSH_REPOSITION = 1; //If crushing Link should move him to the room entrance
const int SOLIDOBJ_COMPLEX_CRUSH_ANIM = 1; //If crushing animation should have 6 animations or just 2
const int SOLIDOBJ_PUSH_NPC = 0; //Whether or not to push NPCs

const int SOLIDOBJ_CRUSH_SAFETY = 4; //Safety pixels before being crushed

const int SOLIDOBJ_LINKXTRIM = 3; //Amount trimmed from the sides of Link's hitbox
const int SOLIDOBJ_LINKYTRIM = 0; //Amount trimmed from the top of Link's hitbox in sideview

//Internal constants - Please don't change these

const int __SOLIDOBJ_COUNT = 0; //Array index keeping track of the number of solid objects
const int __SOLIDOBJ_STARTLINKX = 1; //Link's starting X position
const int __SOLIDOBJ_STARTLINKY = 2; //Link's starting Y position
const int __SOLIDOBJ_CRUSHCOUNTER = 3; //Array index for the timer keeping track of Link getting crushed
const int __SOLIDOBJ_LASTDMAP = 4; //Last DMap visited
const int __SOLIDOBJ_LASTSCREEN = 5; //Last screen visited
const int __SOLIDOBJ_ONPLATFORM = 6; //The current platform Link is on
const int __SOLIDOBJ_FORCERESPAWNCOUNTER = 7; //How many frames until Link is force to respawn, regardless of if a block is covering him
const int __SOLIDOBJ_FORCELINKX = 8; //X position where Link got crushed
const int __SOLIDOBJ_FORCELINKY = 9; //Y position where Link got crushed
const int __SOLIDOBJ_LINKLASTX = 10; //Link's last X position
const int __SOLIDOBJ_LINKLASTY = 11; //Link's last Y position

const int __SOLIDOBJ_STARTINDEX = 12; //Starting index for objects in the array
const int __SOLIDOBJ_NUMATTRIBINDEX = 8; //Number of indices in an object

//Array indices (__SOLIDOBJ_STARTINDEX+__SOLIDOBJ_NUMATTRIBINDEX*y+x) for various attributes of each object 
//where y is the object ID and x is the property
const int __SOLIDOBJ_OBJ_X = 0;
const int __SOLIDOBJ_OBJ_Y = 1;
const int __SOLIDOBJ_OBJ_WIDTH = 2;
const int __SOLIDOBJ_OBJ_HEIGHT = 3;
const int __SOLIDOBJ_OBJ_VX = 4;
const int __SOLIDOBJ_OBJ_VY = 5;
const int __SOLIDOBJ_OBJ_ID = 6;
const int __SOLIDOBJ_OBJ_FLAGS = 7;

const int SFFCF_TOPONLY = 00000001b; //Only the top face of the FFC is solid
const int SFFCF_PUSHNPC = 00000010b; //Can push NPCs

int SolidObjects[268]; //Buffer for the solid object. Size should be 12+SOLIDOBJ_MAX*8

void SolidObjects_Add(int ID, int x, int y, int width, int height, int vX, int vY, int flags){
	int i = __SOLIDOBJ_STARTINDEX+SolidObjects[__SOLIDOBJ_COUNT]*__SOLIDOBJ_NUMATTRIBINDEX; //Get the starting index of the object
	
	//Set all the object's attributes
	SolidObjects[i+__SOLIDOBJ_OBJ_X] = x;
	SolidObjects[i+__SOLIDOBJ_OBJ_Y] = y;
	SolidObjects[i+__SOLIDOBJ_OBJ_WIDTH] = width;
	SolidObjects[i+__SOLIDOBJ_OBJ_HEIGHT] = height;
	SolidObjects[i+__SOLIDOBJ_OBJ_VX] = vX;
	SolidObjects[i+__SOLIDOBJ_OBJ_VY] = vY;
	SolidObjects[i+__SOLIDOBJ_OBJ_ID] = ID;
	SolidObjects[i+__SOLIDOBJ_OBJ_FLAGS] = flags;
	
	//Increment the count so the script knows where to add the next object
	SolidObjects[__SOLIDOBJ_COUNT] = Min(SolidObjects[__SOLIDOBJ_COUNT]+1, SOLIDOBJ_MAX);
}

void SolidObjects_Init(){
	//Reset global variables to their default states
	SolidObjects[__SOLIDOBJ_COUNT] = 0;
	SolidObjects[__SOLIDOBJ_STARTLINKX] = Link->X;
	SolidObjects[__SOLIDOBJ_STARTLINKY] = Link->Y;
	SolidObjects[__SOLIDOBJ_CRUSHCOUNTER] = 0;
	SolidObjects[__SOLIDOBJ_LASTDMAP] = Game->GetCurDMap();
	SolidObjects[__SOLIDOBJ_LASTSCREEN] = Game->GetCurScreen();
	SolidObjects[__SOLIDOBJ_ONPLATFORM] = 0;
}

void SolidObjects_Update1(){
	if(Link->Action != LA_SCROLLING){
		//If Link is currently being crushed
		if(SolidObjects[__SOLIDOBJ_CRUSHCOUNTER]>0){
			NoAction();
			Link->Jump = 0;
			SolidObjects[__SOLIDOBJ_CRUSHCOUNTER]--;
			Link->CollDetection = false;
			Link->Invisible = true;
			Link->X = SolidObjects[__SOLIDOBJ_FORCELINKX];
			Link->Y = SolidObjects[__SOLIDOBJ_FORCELINKY];
			//When the counter hits 0
			if(SolidObjects[__SOLIDOBJ_CRUSHCOUNTER]==0){
				if(SOLIDOBJ_CRUSH_REPOSITION){
					Link->X = SolidObjects[__SOLIDOBJ_STARTLINKX];
					Link->Y = SolidObjects[__SOLIDOBJ_STARTLINKY];
				}
				//If Link isn't colliding with a solid object
				if(!SolidObjects_CollideWithLink(Link->X, Link->Y)||SolidObjects[__SOLIDOBJ_FORCERESPAWNCOUNTER]>=DELAYMAX_CRUSH){
					SolidObjects[__SOLIDOBJ_FORCERESPAWNCOUNTER] = 0;
					Link->CollDetection = true;
					Link->Invisible = false;
					Link->HP -= DAMAGE_LINKCRUSH;
					Link->Action = LA_GOTHURTLAND;
					Link->HitDir = -1;
					Game->PlaySound(SFX_OUCH);
				}
				//Otherwise raise the crush counter so it checks again next frame
				else{
					SolidObjects[__SOLIDOBJ_CRUSHCOUNTER] = 1;
					SolidObjects[__SOLIDOBJ_FORCERESPAWNCOUNTER]++;
				}
			}
		}
	}
}

void SolidObjects_Update2(){
	if(Link->Action != LA_SCROLLING){
		//If Link has moved to a different DMap or screen, update the starting position
		if(SolidObjects[__SOLIDOBJ_LASTDMAP]!=Game->GetCurDMap()||SolidObjects[__SOLIDOBJ_LASTSCREEN]!=Game->GetCurScreen()){
			SolidObjects[__SOLIDOBJ_LASTDMAP] = Game->GetCurDMap();
			SolidObjects[__SOLIDOBJ_LASTSCREEN] = Game->GetCurScreen();
			
			SolidObjects[__SOLIDOBJ_STARTLINKX] = Link->X;
			SolidObjects[__SOLIDOBJ_STARTLINKY] = Link->Y;
		}
		
		//Only move Link around if he's not currently being crushed
		if(SolidObjects[__SOLIDOBJ_CRUSHCOUNTER]==0)
			SolidObjects_UpdateLink();
		
		//SFX: Demonic chanting as enemies twitch around awkwardly
		if(SOLIDOBJ_PUSH_NPC){
			for(int i=Screen->NumNPCs(); i>=1; i--){
				npc n = Screen->LoadNPC(i);
				if(!SolidObjects_CanPushEnemy(n))
					continue;
				SolidObjects_UpdateEnemy(n);
			}
		}
		
		//Clear solid object slots to be set by scripts again the next frame
		SolidObjects_ClearObjects();
		
		SolidObjects[__SOLIDOBJ_LINKLASTX] = Link->X;
		SolidObjects[__SOLIDOBJ_LINKLASTY] = Link->Y;
	}
}

//Returns true if an object being pushed around can move in a direction
bool SolidObjects_CanWalk(int x, int y, int dir, int width, int height, int xoff, int yoff, bool noEdge) {
    int i; int xx; int yy;
	bool offscreen;
	if(dir==DIR_UP||dir==DIR_DOWN){
		for(i=0; i<=width-1; i=Min(i+8, width-1)){
			xx = x+xoff+i;
			if(dir==DIR_UP)
				yy = y+yoff-1;
			else
				yy = y+yoff+height;
			if(xx<0||xx>255||yy<0||yy>175){
				if(noEdge)
					offscreen = true;
				else
					return false;
			}
			if(Screen->isSolid(xx, yy)&&!offscreen)
				return false;
			if(i==width-1)
				break;
		}
		return true;
	}
	else if(dir==DIR_LEFT||dir==DIR_RIGHT){
		for(i=0; i<=height-1; i=Min(i+8, height-1)){
			yy = y+yoff+i;
			if(dir==DIR_LEFT)
				xx = x+xoff-1;
			else
				xx = x+xoff+width;
			if(xx<0||xx>255||yy<0||yy>175){
				if(noEdge)
					offscreen = true;
				else
					return false;
			}
			if(Screen->isSolid(xx, yy)&&!offscreen)
				return false;
			if(i==height-1)
				break;
		}
		return true;
	}
	return false;
}

void SolidObjects_UpdateLink(){
	int totalUp;
	int totalDown;
	int totalLeft;
	int totalRight;
	
	int tempVx;
	int tempVy;
	
	int x; int y; int width; int height; int vX; int vY; int flags;
	
	int linkX = Link->X+SOLIDOBJ_LINKXTRIM;
	int linkY = Link->Y+8;
	int linkWidth = 16-SOLIDOBJ_LINKXTRIM*2;
	int linkHeight = 8;
	
	int platID; //A unique number given to solid objects treated as platforms, to keep track of them between frames
	int platformCandidate = -1; //The platform under Link as found when he steps on it for the first time
	int platformIndex = -1; //The platform under Link as found by its ID
	int platformY;
	int platformPushX;
	int platformPushY;
	
	bool crushDir[4];
	//Link's hitbox is different in sideview
	if(IsSideview()){
		linkX = Link->X+SOLIDOBJ_LINKXTRIM;
		linkY = Link->Y+SOLIDOBJ_LINKYTRIM;
		linkWidth = 16-SOLIDOBJ_LINKXTRIM*2;
		linkHeight = 16-SOLIDOBJ_LINKYTRIM;
	}
	
	for(int i=0; i<SOLIDOBJ_MAX; i++){ //Cycle through all possible objects
		x = SolidObjects[__SOLIDOBJ_STARTINDEX+i*__SOLIDOBJ_NUMATTRIBINDEX+__SOLIDOBJ_OBJ_X];
		y = SolidObjects[__SOLIDOBJ_STARTINDEX+i*__SOLIDOBJ_NUMATTRIBINDEX+__SOLIDOBJ_OBJ_Y];
		width = SolidObjects[__SOLIDOBJ_STARTINDEX+i*__SOLIDOBJ_NUMATTRIBINDEX+__SOLIDOBJ_OBJ_WIDTH];
		height = SolidObjects[__SOLIDOBJ_STARTINDEX+i*__SOLIDOBJ_NUMATTRIBINDEX+__SOLIDOBJ_OBJ_HEIGHT];
		platID = SolidObjects[__SOLIDOBJ_STARTINDEX+i*__SOLIDOBJ_NUMATTRIBINDEX+__SOLIDOBJ_OBJ_ID];
		vX = SolidObjects[__SOLIDOBJ_STARTINDEX+i*__SOLIDOBJ_NUMATTRIBINDEX+__SOLIDOBJ_OBJ_VX];
		vY = SolidObjects[__SOLIDOBJ_STARTINDEX+i*__SOLIDOBJ_NUMATTRIBINDEX+__SOLIDOBJ_OBJ_VY];
		flags = SolidObjects[__SOLIDOBJ_STARTINDEX+i*__SOLIDOBJ_NUMATTRIBINDEX+__SOLIDOBJ_OBJ_FLAGS];
		
		if(width>0){ //Check if there's a solid object at the current index
			if(IsSideview()){
				//If Link is standing on the same platform as his current platform ID
				//Update platform index to that object
				if(SolidObjects[__SOLIDOBJ_ONPLATFORM]==platID&&platID>0){
					platformIndex = i;
				}
			}
			
			if(RectCollision(x, y, x+width-1, y+height-1, linkX, linkY, linkX+linkWidth-1, linkY+linkHeight-1)){
				//Find Link and the object's center points
				int cx1 = x+width/2;
				int cy1 = y+height/2;
				int cx2 = linkX+linkWidth/2;
				int cy2 = linkY+linkHeight/2;
				
				if(cy2<cy1){ //Link is above the object
					tempVy = cy1-cy2-(height+linkHeight)/2;
					if(vY<0)
						crushDir[DIR_UP] = true;
				}
				else{ //Link is below the object
					tempVy = cy1-cy2+(height+linkHeight)/2;
					if(vY>0)
						crushDir[DIR_DOWN] = true;
				}
				
				if(cx2<cx1){ //Link is left of the object
					tempVx = cx1-cx2-(width+linkWidth)/2;
					if(vX<0)
						crushDir[DIR_LEFT] = true;
				}
				else{
					tempVx = cx1-cx2+(width+linkWidth)/2;
					if(vX>0)
						crushDir[DIR_RIGHT] = true;
				}
				
				//Prevent jump-through platforms pushing in any direction but up
				if(flags&SFFCF_TOPONLY){
					tempVx = 1000; //We're setting Vx/Vy to 1000 to cancel them out from calculations
					if(tempVy>0)
						tempVy = 1000;
					if(Link->Y<SolidObjects[__SOLIDOBJ_LINKLASTY])
						tempVy = 1000;
				}
				//If both vectors are cancelled, set them to 0
				if(tempVx==1000&&tempVy==1000){
					tempVx = 0;
					tempVy = 0;
				}
				if(Abs(tempVy)<Abs(tempVx)){ //Find out which push would take less effort
					if(tempVy<0){ //If it's an upwards push
						if(totalUp>tempVy){ //If it's larger than the current max
							totalUp = tempVy; //Update the current max
							//If the platform is going up and has an ID >0, update platformCandidate
							if(IsSideview()&&platID>0){
								platformCandidate = i;
							}
						}
					}
					else if(tempVy>0){ //If it's a downwards push
						if(totalDown<tempVy) //If it's larger than the current max
							totalDown = tempVy; //Update the current max
					}
				}
				else{
					if(tempVx<0){ //If it's a left push
						if(totalLeft>tempVx) //If it's larger than the current max
							totalLeft = tempVx; //Update the current max
					}
					else if(tempVx>0){ //If it's a right push
						if(totalRight<tempVx) //If it's larger than the current max
							totalRight = tempVx; //Update the current max
					}
				}
			}
			//Detect collision with FFCs while Link is standing on the ground next to them
			else if(IsSideview()&&!SolidObjects_CanWalk(Link->X, Link->Y, DIR_DOWN, 8, 16, 4, 0, true)){
				if(RectCollision(x, y, x+width-1, y+height-1, linkX, linkY, linkX+linkWidth-1, linkY+linkHeight-1+2)){
					if(platID>0)
						platformCandidate = i;
				}
			}
		}
	}
	
	if(IsSideview()){
		//If Link isn't on a platform yet
		if(SolidObjects[__SOLIDOBJ_ONPLATFORM]==0){
			//If there's a candidate available and he's going down,
			//set his current platform to that platform's ID
			if(platformCandidate>-1&&Link->Jump<=0){
				SolidObjects[__SOLIDOBJ_ONPLATFORM] = SolidObjects[__SOLIDOBJ_STARTINDEX+platformCandidate*__SOLIDOBJ_NUMATTRIBINDEX+__SOLIDOBJ_OBJ_ID];
				platformY = SolidObjects[__SOLIDOBJ_STARTINDEX+platformCandidate*__SOLIDOBJ_NUMATTRIBINDEX+__SOLIDOBJ_OBJ_Y]-16;
				Link->Jump = 0;
			}
		}
		else{
			//If the platform Link is on has been found
			if(platformIndex>-1){
				if(platformCandidate>-1){
					//If there's a platform candidate and it has a higher Y velocity
					if(SolidObjects[__SOLIDOBJ_STARTINDEX+platformCandidate*__SOLIDOBJ_NUMATTRIBINDEX+__SOLIDOBJ_OBJ_VY]<SolidObjects[__SOLIDOBJ_STARTINDEX+platformIndex*__SOLIDOBJ_NUMATTRIBINDEX+__SOLIDOBJ_OBJ_VY]){
						platformIndex = platformCandidate;
						SolidObjects[__SOLIDOBJ_ONPLATFORM] = SolidObjects[__SOLIDOBJ_STARTINDEX+platformIndex*__SOLIDOBJ_NUMATTRIBINDEX+__SOLIDOBJ_OBJ_ID];
						Link->Jump = 0;
					}
				}
				x = SolidObjects[__SOLIDOBJ_STARTINDEX+platformIndex*__SOLIDOBJ_NUMATTRIBINDEX+__SOLIDOBJ_OBJ_X];
				y = SolidObjects[__SOLIDOBJ_STARTINDEX+platformIndex*__SOLIDOBJ_NUMATTRIBINDEX+__SOLIDOBJ_OBJ_Y];
				width = SolidObjects[__SOLIDOBJ_STARTINDEX+platformIndex*__SOLIDOBJ_NUMATTRIBINDEX+__SOLIDOBJ_OBJ_WIDTH];
				height = SolidObjects[__SOLIDOBJ_STARTINDEX+platformIndex*__SOLIDOBJ_NUMATTRIBINDEX+__SOLIDOBJ_OBJ_HEIGHT];
				platformY = y-16;
				platformPushX = SolidObjects[__SOLIDOBJ_STARTINDEX+platformIndex*__SOLIDOBJ_NUMATTRIBINDEX+__SOLIDOBJ_OBJ_VX];
				platformPushY = platformY-Link->Y; //Link's Y push is based on the difference between Link's position and the position above the platform
				Link->Jump = 0;
				//If Link isn't touching the platform, detach him from it
				if(!RectCollision(x, y, x+width-1, y+height-1, linkX+platformPushX, linkY+platformPushY, linkX+linkWidth-1+platformPushX, linkY+linkHeight-1+4+platformPushY)){
					SolidObjects[__SOLIDOBJ_ONPLATFORM] = 0;
				}
			}
			//If the platform Link is on doesn't exist, detach him
			else{
				SolidObjects[__SOLIDOBJ_ONPLATFORM] = 0;
			}
		}
	}
	
	//Debug draws
	// Screen->DrawInteger(6, 8, 8, FONT_Z1, 0x01, 0x0F, -1, -1, totalUp, 0, 128);
	// Screen->DrawInteger(6, 8, 16, FONT_Z1, 0x01, 0x0F, -1, -1, totalDown, 0, 128);
	// Screen->DrawInteger(6, 8, 24, FONT_Z1, 0x01, 0x0F, -1, -1, totalLeft, 0, 128);
	// Screen->DrawInteger(6, 8, 32, FONT_Z1, 0x01, 0x0F, -1, -1, totalRight, 0, 128);
	
	//Get which directions Link can go in
	//This is based on the speed of Link being pushed out of the platform as well as its current velocity
	bool canGoUp = (totalDown==0)||!crushDir[DIR_DOWN];
	bool canGoDown = (totalUp==0)||!crushDir[DIR_UP];
	bool canGoLeft = (totalRight==0)||!crushDir[DIR_RIGHT];
	bool canGoRight = (totalLeft==0)||!crushDir[DIR_LEFT];
	
	//Add rough offsets to cancel out Link's movement
	int cancelMoveX = -LinkMovement[LM_STICKX];
	int cancelMoveY = -LinkMovement[LM_STICKY];
	if(IsSideview())
		cancelMoveY = 0;
	
	//Update the valid directions based on screen solidity in the way
	if(IsSideview()){ //Link's hitbox is different in sideview
		if(!SolidObjects_CanWalk(Link->X+cancelMoveX, Link->Y+cancelMoveY, DIR_UP, 8, 16, 4, 0, true))
			canGoUp = false;
		if(!SolidObjects_CanWalk(Link->X+cancelMoveX, Link->Y+cancelMoveY, DIR_DOWN, 8, 16, 4, 0, true)){
			canGoDown = false;
			//Detach Link from a platform if he's on the ground and not directly above the platform
			if(Abs(platformY-Link->Y)>2)
				SolidObjects[__SOLIDOBJ_ONPLATFORM] = 0;
		}
		if(!SolidObjects_CanWalk(Link->X+cancelMoveX, Link->Y+cancelMoveY, DIR_LEFT, 16, 16, 0, 0, true))
			canGoLeft = false;
		if(!SolidObjects_CanWalk(Link->X+cancelMoveX, Link->Y+cancelMoveY, DIR_RIGHT, 16, 16, 0, 0, true))
			canGoRight = false;
	}
	else{
		if(!SolidObjects_CanWalk(Link->X+cancelMoveX, Link->Y+cancelMoveY, DIR_UP, 16, 8, 0, 8, true))
			canGoUp = false;
		if(!SolidObjects_CanWalk(Link->X+cancelMoveX, Link->Y+cancelMoveY, DIR_DOWN, 16, 8, 0, 8, true))
			canGoDown = false;
		if(!SolidObjects_CanWalk(Link->X+cancelMoveX, Link->Y+cancelMoveY, DIR_LEFT, 16, 8, 0, 8, true))
			canGoLeft = false;
		if(!SolidObjects_CanWalk(Link->X+cancelMoveX, Link->Y+cancelMoveY, DIR_RIGHT, 16, 8, 0, 8, true))
			canGoRight = false;
	}
	//Set Link's jump to 0 if he's jumping up into a ceiling
	if(Link->Jump>0&&totalDown>0&&IsSideview())
		Link->Jump = 0;
	
	int crush = -1;
	if(SOLIDOBJ_CRUSH_BEHAVIOR){
		int crushStrengthX = Max(Abs(totalLeft), Abs(totalRight));
		int crushStrengthY = Max(Abs(totalUp), Abs(totalDown));
		//Detect if Link is between two walls
		if(!canGoUp&&!canGoDown){
			//Detect if he's far enough in to be crushed
			if(crushStrengthY>=SOLIDOBJ_CRUSH_SAFETY){
				crush = 4;
				//Set crush direction if Link is pushed against a wall
				if(Abs(totalUp)>0&&totalDown==0)
					crush = DIR_UP;
				else if(Abs(totalDown)>0&&totalUp==0)
					crush = DIR_DOWN;
			}
		}
		if(!canGoLeft&&!canGoRight){
			if(crushStrengthX>=SOLIDOBJ_CRUSH_SAFETY){
				//If he's being more crushed vertically than horizontally, prioritize that
				if((crush==DIR_UP||crush==DIR_DOWN||crush==4)&&crushStrengthY>crushStrengthX){
					crush = 4;
					if(Abs(totalUp)>0&&totalDown==0)
						crush = DIR_UP;
					else if(Abs(totalDown)>0&&totalUp==0)
						crush = DIR_DOWN;
				}
				else{
					crush = 5;
					if(Abs(totalLeft)>0&&totalRight==0)
						crush = DIR_LEFT;
					else if(Abs(totalRight)>0&&totalLeft==0)
						crush = DIR_RIGHT;
				}
			}
		}
	}
	
	//If Link is being crushed
	if(crush>-1&&Link->CollDetection){
		if(SOLIDOBJ_CRUSH_BEHAVIOR==2){ //Instant death crush
			Link->HP = 0;
		}
		else{ //Teleport crush
			SolidObjects[__SOLIDOBJ_FORCELINKX] = Link->X;
			SolidObjects[__SOLIDOBJ_FORCELINKY] = Link->Y;
			lweapon lcrush = CreateLWeaponAt(LW_SPARKLE, Link->X, Link->Y);
			lcrush->UseSprite(SPR_LINKCRUSH);
			lcrush->DeadState = Max(lcrush->ASpeed*lcrush->NumFrames-1, 1);
			if(SOLIDOBJ_COMPLEX_CRUSH_ANIM){
				lcrush->OriginalTile += crush*20;
				lcrush->Tile = lcrush->OriginalTile;
			}
			else{
				if(crush==DIR_LEFT||crush==DIR_RIGHT||crush==5){ //Offset tiles based on direction of the crushing
					lcrush->OriginalTile += 20;
					lcrush->Tile = lcrush->OriginalTile;
				}
			}
			Link->Invisible = true;
			Link->CollDetection = false;
			SolidObjects[__SOLIDOBJ_CRUSHCOUNTER] = lcrush->DeadState+DELAY_CRUSH;
			Game->PlaySound(SFX_LINKCRUSH);
			SolidObjects[__SOLIDOBJ_ONPLATFORM] = 0;
		}
	}
	else{ //Otherwise, move him around
		if(IsSideview()&&(totalUp+totalDown)<0&&SolidObjects[__SOLIDOBJ_ONPLATFORM]>0)
			Link->Jump = 0;
		SolidObjects_SafePush2NoEdge(totalLeft+totalRight+platformPushX, totalUp+totalDown+platformPushY); //Move Link by the combination of strongest inputs. Opposing Left/Right, Up/Down should cancel out
	}
}

//This function prevents the script from overfilling the push counter
void SolidObjects_SafePush2NoEdge(int vX, int vY){
	if(Abs(LinkMovement[LM_PUSHX2B])>=1)
		vX = 0;
	if(Abs(LinkMovement[LM_PUSHY2B])>=1)
		vY = 0;
	LinkMovement_Push2NoEdge(vX, vY);
}

bool SolidObjects_CollideWithLink(int checkX, int checkY){
	int x; int y; int width; int height; int vX; int vY;
	int linkX = checkX+SOLIDOBJ_LINKXTRIM;
	int linkY = checkY+8;
	int linkWidth = 16-SOLIDOBJ_LINKXTRIM*2;
	int linkHeight = 8;
	if(IsSideview()){
		linkX = Link->X+SOLIDOBJ_LINKXTRIM;
		linkY = Link->Y+SOLIDOBJ_LINKYTRIM;
		linkWidth = 16-SOLIDOBJ_LINKXTRIM*2;
		linkHeight = 16-SOLIDOBJ_LINKYTRIM;
	}
	for(int i=0; i<SOLIDOBJ_MAX; i++){ //Cycle through all possible objects
		x = SolidObjects[__SOLIDOBJ_STARTINDEX+i*__SOLIDOBJ_NUMATTRIBINDEX+__SOLIDOBJ_OBJ_X];
		y = SolidObjects[__SOLIDOBJ_STARTINDEX+i*__SOLIDOBJ_NUMATTRIBINDEX+__SOLIDOBJ_OBJ_Y];
		width = SolidObjects[__SOLIDOBJ_STARTINDEX+i*__SOLIDOBJ_NUMATTRIBINDEX+__SOLIDOBJ_OBJ_WIDTH];
		height = SolidObjects[__SOLIDOBJ_STARTINDEX+i*__SOLIDOBJ_NUMATTRIBINDEX+__SOLIDOBJ_OBJ_HEIGHT];
		//If one of them collides with Link, return true
		if(RectCollision(x, y, x+width-1, y+height-1, linkX, linkY, linkX+linkWidth-1, linkY+linkHeight-1)){
			return true;
		}
	}
	return false;
}

void SolidObjects_UpdateEnemy(npc n){
	int totalUp;
	int totalDown;
	int totalLeft;
	int totalRight;
	
	int tempVx;
	int tempVy;
	
	int x; int y; int width; int height;
	int nX = n->X+n->HitXOffset;
	int nY = n->Y+n->HitYOffset;
	int nWidth = n->HitWidth;
	int nHeight = n->HitHeight;
	for(int i=0; i<SOLIDOBJ_MAX; i++){ //Cycle through all possible objects
		x = SolidObjects[__SOLIDOBJ_STARTINDEX+i*__SOLIDOBJ_NUMATTRIBINDEX+__SOLIDOBJ_OBJ_X];
		y = SolidObjects[__SOLIDOBJ_STARTINDEX+i*__SOLIDOBJ_NUMATTRIBINDEX+__SOLIDOBJ_OBJ_Y];
		width = SolidObjects[__SOLIDOBJ_STARTINDEX+i*__SOLIDOBJ_NUMATTRIBINDEX+__SOLIDOBJ_OBJ_WIDTH];
		height = SolidObjects[__SOLIDOBJ_STARTINDEX+i*__SOLIDOBJ_NUMATTRIBINDEX+__SOLIDOBJ_OBJ_HEIGHT];
		int flags = SolidObjects[__SOLIDOBJ_STARTINDEX+i*__SOLIDOBJ_NUMATTRIBINDEX+__SOLIDOBJ_OBJ_FLAGS];
		if(width>0&&flags&SFFCF_PUSHNPC){ //Check if there's a solid object at the current index
			//Debug hitbox draw
			//Screen->Rectangle(2, x, y, x+width-1, y+height-1, 0x01, 1, 0, 0, 0, true, 64);
			if(RectCollision(x, y, x+width-1, y+height-1, nX, nY, nX+nWidth-1, nY+nHeight-1)){
				//Find NPC and the object's center points
				int cx1 = x+width/2;
				int cy1 = y+height/2;
				int cx2 = nX+nWidth/2;
				int cy2 = nY+nHeight/2;
				
				if(cy2<cy1){ //NPC is above the object
					tempVy = cy1-cy2-(height+nHeight)/2;
				}
				else{ //NPC is below the object
					tempVy = cy1-cy2+(height+nHeight)/2;
				}
				
				if(cx2<cx1){ //NPC is left of the object
					tempVx = cx1-cx2-(width+nWidth)/2;
				}
				else{
					tempVx = cx1-cx2+(width+nWidth)/2;
				}
				
				//Prevent jump-through platforms pushing in any direction but up
				if(flags&SFFCF_TOPONLY){
					tempVx = 1000; //We're setting Vx/Vy to 1000 to cancel them out from calculations
					if(tempVy>0)
						tempVy = 1000;
				}
				//If both vectors are cancelled, set them to 0
				if(tempVx==1000&&tempVy==1000){
					tempVx = 0;
					tempVy = 0;
				}
				if(Abs(tempVy)<Abs(tempVx)){ //Find out which push would take less effort
					if(tempVy<0){ //If it's an upwards push
						if(totalUp>tempVy) //If it's larger than the current max
							totalUp = tempVy; //Update the current max
					}
					else if(tempVy>0){ //If it's a downwards push
						if(totalDown<tempVy) //If it's larger than the current max
							totalDown = tempVy; //Update the current max
					}
				}
				else{
					if(tempVx<0){ //If it's a left push
						if(totalLeft>tempVx) //If it's larger than the current max
							totalLeft = tempVx; //Update the current max
					}
					else if(tempVx>0){ //If it's a right push
						if(totalRight<tempVx) //If it's larger than the current max
							totalRight = tempVx; //Update the current max
					}
				}
			}
		}
	}
	//Debug draws
	// Screen->DrawInteger(6, 8, 8, FONT_Z1, 0x01, 0x0F, -1, -1, totalUp, 0, 128);
	// Screen->DrawInteger(6, 8, 16, FONT_Z1, 0x01, 0x0F, -1, -1, totalDown, 0, 128);
	// Screen->DrawInteger(6, 8, 24, FONT_Z1, 0x01, 0x0F, -1, -1, totalLeft, 0, 128);
	// Screen->DrawInteger(6, 8, 32, FONT_Z1, 0x01, 0x0F, -1, -1, totalRight, 0, 128);
	
	bool canGoUp = (totalDown==0);
	bool canGoDown = (totalUp==0);
	bool canGoLeft = (totalRight==0);
	bool canGoRight = (totalLeft==0);
	
	if(!SolidObjects_CanWalk(n->X, n->Y, DIR_UP, n->HitWidth, n->HitHeight, n->HitXOffset, n->HitYOffset, true))
		canGoUp = false;
	if(!SolidObjects_CanWalk(n->X, n->Y, DIR_DOWN, n->HitWidth, n->HitHeight, n->HitXOffset, n->HitYOffset, true))
		canGoDown = false;
	if(!SolidObjects_CanWalk(n->X, n->Y, DIR_LEFT, n->HitWidth, n->HitHeight, n->HitXOffset, n->HitYOffset, true))
		canGoLeft = false;
	if(!SolidObjects_CanWalk(n->X, n->Y, DIR_RIGHT, n->HitWidth, n->HitHeight, n->HitXOffset, n->HitYOffset, true))
		canGoRight = false;
	
	int crush = 0;
	if(SOLIDOBJ_CRUSH_BEHAVIOR){
		int crushStrengthX = Max(Abs(totalLeft), Abs(totalRight));
		int crushStrengthY = Max(Abs(totalUp), Abs(totalDown));
		//Detect if NPC is between two walls
		if(!canGoUp&&!canGoDown){
			//Detect if it's far enough in to be crushed
			if(crushStrengthY>=SOLIDOBJ_CRUSH_SAFETY){
				crush = 1;
			}
		}
		if(!canGoLeft&&!canGoRight){
			if(crushStrengthX>=SOLIDOBJ_CRUSH_SAFETY){
				crush = 1;
			}
		}
	}
	if(crush&&n->CollDetection){
		n->HP = 0;
		Game->PlaySound(SFX_ENEMYCRUSH);
	}
	else
		SolidObjects_PushEnemy(n, totalLeft+totalRight, totalUp+totalDown);//Move NPC by the combination of strongest inputs. Opposing Left/Right, Up/Down should cancel out
}

void SolidObjects_PushEnemy(npc n, int pushX, int pushY){
	pushX = Round(pushX);
	pushY = Round(pushY);
	//Until both pushX and pushY are drained down to 0, continue to push the enemy
	while(pushX!=0||pushY!=0){
		if(pushX<0){
			//But not through solid objects
			if(SolidObjects_CanWalk(n->X, n->Y, DIR_LEFT, n->HitWidth, n->HitHeight, n->HitXOffset, n->HitYOffset, true))
				SetEnemyProperty(n, ENPROP_X, GetEnemyProperty(n, ENPROP_X)-1);
			pushX++;
		}
		else if(pushX>0){
			if(SolidObjects_CanWalk(n->X, n->Y, DIR_RIGHT, n->HitWidth, n->HitHeight, n->HitXOffset, n->HitYOffset, true))
				SetEnemyProperty(n, ENPROP_X, GetEnemyProperty(n, ENPROP_X)+1);
			pushX--;
		}
		if(pushY<0){
			if(SolidObjects_CanWalk(n->X, n->Y, DIR_UP, n->HitWidth, n->HitHeight, n->HitXOffset, n->HitYOffset, true))
				SetEnemyProperty(n, ENPROP_Y, GetEnemyProperty(n, ENPROP_Y)-1);
			pushY++;
		}
		else if(pushY>0){
			if(SolidObjects_CanWalk(n->X, n->Y, DIR_DOWN, n->HitWidth, n->HitHeight, n->HitXOffset, n->HitYOffset, true))
				SetEnemyProperty(n, ENPROP_Y, GetEnemyProperty(n, ENPROP_Y)+1);
			pushY--;
		}
	}
	//If the enemy gets pushed off the screen, kill it
	if(GetEnemyProperty(n, ENPROP_X)<-n->HitXOffset-n->HitWidth ||
		GetEnemyProperty(n, ENPROP_X)>256 ||
		GetEnemyProperty(n, ENPROP_Y)<-n->HitYOffset-n->HitHeight ||
		GetEnemyProperty(n, ENPROP_Y)>176 ){
			
		SetEnemyProperty(n, ENPROP_HP, -1000);
		n->ItemSet = -1000;
		n->DrawYOffset = -1000;
	}
}

bool SolidObjects_CanPushEnemy(npc n){
	int type = n->Type;
	//If the enemy is invulnerable, don't push it
	if(Abs(n->HitXOffset)>=1000||Abs(n->HitYOffset)>=1000)
		return false;
	//If the enemy is in the air, don't push it
	if(n->Z>0)
		return false;
	//Check if the enemy is a type that can be pushed
	if(type==NPCT_WALK)
		return true;
	if(type==NPCT_TEKTITE)
		return true;
	if(type==NPCT_LEEVER)
		return true;
	if(type==NPCT_ZORA)
		return true;
	if(type==NPCT_GHINI)
		return true;
	if(type==NPCT_ARMOS)
		return true;
	if(type==NPCT_WIZZROBE)
		return true;
	if(type==NPCT_OTHERFLOAT)
		return true;
	if(type==NPCT_OTHER)
		return true;
	
	return false;
}

void SolidObjects_ClearObjects(){
	for(int i=0; i<SOLIDOBJ_MAX; i++){ //Cycle through all possible objects
		//Clear the properties
		SolidObjects[__SOLIDOBJ_STARTINDEX+i*__SOLIDOBJ_NUMATTRIBINDEX+__SOLIDOBJ_OBJ_X] = 0;
		SolidObjects[__SOLIDOBJ_STARTINDEX+i*__SOLIDOBJ_NUMATTRIBINDEX+__SOLIDOBJ_OBJ_Y] = 0;
		SolidObjects[__SOLIDOBJ_STARTINDEX+i*__SOLIDOBJ_NUMATTRIBINDEX+__SOLIDOBJ_OBJ_WIDTH] = 0;
		SolidObjects[__SOLIDOBJ_STARTINDEX+i*__SOLIDOBJ_NUMATTRIBINDEX+__SOLIDOBJ_OBJ_HEIGHT] = 0;
		SolidObjects[__SOLIDOBJ_STARTINDEX+i*__SOLIDOBJ_NUMATTRIBINDEX+__SOLIDOBJ_OBJ_FLAGS] = 0;
	}
	//Reset the count
	SolidObjects[__SOLIDOBJ_COUNT] = 0;
}

//D0: Width of the hitbox
//D1: Height of the hitbox
//D2: X offset from the FFC's position for the hitbox
//D3: Y offset from the FFC's position for the hitbox
//D4: Flags. Add these together to get the result:
//		1 - Only the top of the FFC is solid
//		2 - The FFC pushes enemies
//D5: FFC to link movement to
//D6: Combo ID that makes the FFC nonsolid when it switches to
ffc script Solid_FFC{
	void run(int width, int height, int xoff, int yoff, int flags, int refFFC, int nonSolidCMB){
		//Default width/height
		if(width==0){
			width = this->TileWidth*16;
			height = this->TileHeight*16;
		}
		
		//Set the platform ID to this FFC's number
		int ID;
		for(int i=1; i<=32; i++){
			ffc f = Screen->LoadFFC(i);
			if(f==this)
				ID = i;
		}
		int lastX = this->X;
		int lastY = this->Y;
		ffc ref;
		if(refFFC>0)
			ref = Screen->LoadFFC(refFFC);
		while(true){
			//Handle scripted FFC linking
			if(refFFC>0){
				if(ref->Delay==0){
					this->Vx = ref->Vx;
					this->Vy = ref->Vy;
				}
				else{
					this->Vx = 0;
					this->Vy = 0;
				}
			}
			//We're using difference in position instead of the FFC's Vx and Vy
			//because of float imprecision. Doing it the other way caused Link to get
			//desynced from the FFC
			int vX = this->X-lastX;
			int vY = this->Y-lastY;
			lastX = this->X;
			lastY = this->Y;
			if(this->Delay>0){
				vX = 0;
				vY = 0;
			}
			if(width>0&&this->Data!=nonSolidCMB){
				SolidObjects_Add(ID, this->X+xoff, this->Y+yoff, width, height, vX, vY, flags);
			}
			Waitframe();
		}
	}
}

//D0: Radius to put the platform at
//D1: Starting angle for the platform
//D2: Rotation speed of the platform
//D3: Flags. Add these together to get the result:
//		1 - Only the top of the FFC is solid
//		2 - The FFC pushes enemies
ffc script Moving_Platform_Circular{
	void run(int r, int ang, int rot, int flags){
		//Set the platform ID to this FFC's number
		int ID;
		for(int i=1; i<=32; i++){
			ffc f = Screen->LoadFFC(i);
			if(f==this)
				ID = i;
		}
		int startX = this->X;
		int startY = this->Y;
		int lastX = this->X;
		int lastY = this->Y;
		while(true){
			int x = startX+VectorX(r, ang);
			int y = startY+VectorY(r, ang);
			this->X = x;
			this->Y = y;
			//We're using difference in position instead of the FFC's Vx and Vy
			//because of float imprecision. Doing it the other way caused Link to get
			//desynced from the FFC
			int vX = this->X-lastX;
			int vY = this->Y-lastY;
			lastX = this->X;
			lastY = this->Y;
			ang = WrapDegrees(ang+rot);
			SolidObjects_Add(ID, this->X, this->Y, this->EffectWidth, this->EffectHeight, vX, vY, flags);
			Waitframe();
		}
	}
}

//D0: How many frames to shake for
//D1: Flags. Add these together to get the result:
//		1 - Only the top of the FFC is solid
//		2 - The FFC pushes enemies
ffc script Moving_Platform_StepActivate{
	void run(int shakeFrames, int flags){
		//Set the platform ID to this FFC's number
		int ID;
		for(int i=1; i<=32; i++){
			ffc f = Screen->LoadFFC(i);
			if(f==this)
				ID = i;
		}
		//Store the FFC's starting state
		int startX = this->X;
		int startY = this->Y;
		int savedVX = this->Vx;
		int savedVY = this->Vy;
		int savedAX = this->Ax;
		int savedAY = this->Ay;
		int savedDelay = this->Delay;
		//Clear the FFC's state
		this->Vx = 0;
		this->Vy = 0;
		this->Ax = 0;
		this->Ay = 0;
		this->Delay = 0;
		//If __SOLIDOBJ_ONPLATFORM doesn't equal this FFC's number, Link hasn't stepped on the platform yet
		while(SolidObjects[__SOLIDOBJ_ONPLATFORM]!=ID){
			SolidObjects_Add(ID, this->X, this->Y, this->EffectWidth, this->EffectHeight, 0, 0, flags);
			Waitframe();
		}
		int lastX = this->X;
		int lastY = this->Y;
		int vX; int vY;
		//Play a shake animation for the specified number of frames before "falling"
		if(shakeFrames>0){
			for(int i=0; i<shakeFrames; i++){
				if(i%8<2){
					this->X = startX-1;
				}
				else if(i%8>=4&&i%8<6){
					this->X = startX+1;
				}
				else{
					this->X = startX;
				}
				
				vX = this->X-lastX;
				vY = this->Y-lastY;
				lastX = this->X;
				lastY = this->Y;
				
				SolidObjects_Add(ID, this->X, this->Y, this->EffectWidth, this->EffectHeight, vX, vY, flags);
				Waitframe();
			}
			this->X = startX;
			this->Y = startY;
		}
		//Restore the FFC to the starting state when it "falls"
		this->Vx = savedVX;
		this->Vy = savedVY;
		this->Ax = savedAX;
		this->Ay = savedAY;
		this->Delay = savedDelay;
		while(true){
			//We're using difference in position instead of the FFC's Vx and Vy
			//because of float imprecision. Doing it the other way caused Link to get
			//desynced from the FFC
			vX = this->X-lastX;
			vY = this->Y-lastY;
			lastX = this->X;
			lastY = this->Y;
			
			SolidObjects_Add(ID, this->X, this->Y, this->EffectWidth, this->EffectHeight, vX, vY, flags);
			Waitframe();
		}
	}
}


item script FeatherAction{
	void run(){
		//This script makes Link able to jump with Roc's feather when on a sideview platform
		if(SolidObjects[__SOLIDOBJ_ONPLATFORM]){
			Game->PlaySound(SFX_JUMP);
			Link->Jump = (this->Power+2)*0.8;
			SolidObjects[__SOLIDOBJ_ONPLATFORM] = 0;
		}
	}
}

//Example global script combined with ghost and LinkMovement
global script SolidObject_Example_Combined{
	void run(){
		StartGhostZH();
		LinkMovement_Init();
		SolidObjects_Init();
		while(true){
			UpdateGhostZH1();
			SolidObjects_Update1();
			LinkMovement_Update1();
			Waitdraw();
			UpdateGhostZH2();
			SolidObjects_Update2();
			LinkMovement_Update2();
			Waitframe();
		}
	}
}

//Example global script with just this script's functions
global script SolidObject_Example{
	void run(){
		SolidObjects_Init();
		while(true){
			SolidObjects_Update1();
			Waitdraw();
			SolidObjects_Update2();
			Waitframe();
		}
	}
}