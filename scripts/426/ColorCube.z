const int COLOR_CUBE_PUSH_BLOCK_SENSIVITY	= 8;//How long to pause when pushing a block

//Set of 6 states of color cube.
const int COLOR_CUBE_STATE_RT_BF			= 0;//Red top, blue front
const int COLOR_CUBE_STATE_RT_YF			= 1;//Red top, yellow front
const int COLOR_CUBE_STATE_BT_RF			= 2;//Blue top, red front
const int COLOR_CUBE_STATE_BT_YF			= 3;//Blue top, yellow front
const int COLOR_CUBE_STATE_YT_RF			= 4;//Yellow top, red front
const int COLOR_CUBE_STATE_YT_BF			= 5;//Yellow top, blue front

const int CMB_COLOR_CUBE_ORIGCMB = 2316; //First of 6 combos representing the states of the cube
// The order of the combos matters
// Place the combos in the order of the states

//Combo flags for target landing spots and requested colors at the top
const int CF_COLOR_CUBE_TRIGGER_RED = 98;// Red
const int CF_COLOR_CUBE_TRIGGER_BLUE = 99;//Blue
const int CF_COLOR_CUBE_TRIGGER_YELLOW = 100;//Yellow

const int TILE_COLOR_CUBE_ANIMATION = 300;//Place rotating combos in the order: up, down, left, right
const int CSET_COLOR_CUBE_ANIMATION = 5;//Cset used for rendering color cubes.

const int SFX_COLOR_CUBE_PUSH = 50; //Sound to play when color cube is pushed.

//Color Cube. A cube colored red, blue and yellow on opposite sides. Your goal is to roll it so it lands 
//on trigger space same colored side up.  

//1.Set up tiles and animations as shown in screenshot. You should end up with 6 rows of tiles. 
//2.Set TILE_COLOR_CUBE_ANIMATION to 1st tile from previous step.
//3.Setup 6 solid combos using first tile from each row, in exact the same order up->down.
//4. Import and compile the script. It requires stdExtra.zh (packaged with ZC 2.53.1) or Classic.zh. Assign 2 FFC script slots.
//5. Puzzle building: place floor on background layer, as layer 0 combo will be replaced with undercombo. Keep latter at 0.
//6. Place CF_COLOR_CUBE_TRIGGER_* combo flags at trigger spots. Color cubes must land on those positions correct side up to trigger secrets.
//7. Place snd Grid-snap FFC at cube`s initial position. Assign Color Cube  script.
// D0 - Initial state of the color cube. See state list for accepted values
// D1 - bracelet power needed to push color cubes.
// D2 - 1 - Cube will get stuck on correct landing on trigger.
ffc script ColorCube{
	void run(int state, int weight, int perm){		
		int combo= CMB_COLOR_CUBE_ORIGCMB+state; //Determine which combo to display		
		int restate= state; //Store initial state		
		int loc; //Used to determine position on screen		
		this->InitD[7] = -1;//Tells script what direction block is being pushed If not being pushed, set to -1		
		int Push_Counter=0;//Keeps track of how long you've pushed the block		
		int OldX;//Stores previous X and Y position of block
		int OldY;		
		bool Movable= true;//Determines if the block can still be moved		
		int UnderCombo = Screen->UnderCombo;//Saves combo under the block		
		int flag;//Checks flag at block position		
		this->Data= combo;//Set the ffc to the proper appearance		
		int i;//Iterative variable. Used to render cube rotation animation
		while(true){			
			while(Movable){		//The block can be moved		
				while(Link->X+16< this->X//Link is too far away from the block
				|| Link->X> this->X+16
				|| Link->Y> this->Y+16
				|| Link->Y+16< this->Y){					
					loc = ComboAt(this->X+8,this->Y+8);//Determine where the block is
					//Set combo at block position to ffc's
					//Used to fake solidity
					Screen->ComboD[loc]= this->Data;
					Waitframe();
				}				
				while(this->InitD[7]==-1){//You're close enough to be pushing but not long enough to move the block					
					OldX= this->X;//Save the previous location of the block
					OldY= this->Y;
					// Check if Link is pushing against the block
					if((Link->X == this->X - 16 && (Link->Y < this->Y + 1 && Link->Y > this->Y - 12) && Link->InputRight && Link->Dir == DIR_RIGHT) || // Right
					(Link->X == this->X + 16 && (Link->Y < this->Y + 1 && Link->Y > this->Y - 12) && Link->InputLeft && Link->Dir == DIR_LEFT) || // Left
					(Link->Y == this->Y - 16 && (Link->X < this->X + 4 && Link->X > this->X - 4) && Link->InputDown && Link->Dir == DIR_DOWN) || // Down
					(Link->Y == this->Y + 8 && (Link->X < this->X + 4 && Link->X > this->X - 4) && Link->InputUp && Link->Dir == DIR_UP)) { // Up
						Push_Counter++;
					}
					else {					
						Push_Counter = 0;// Reset the frame counter
					}
					if (Push_Counter>=COLOR_CUBE_PUSH_BLOCK_SENSIVITY){
						if (ColorCubeCanBePushed(this, Link->Dir, weight)){
							Game->PlaySound(SFX_COLOR_CUBE_PUSH);
							this->InitD[7] = Link->Dir;
							this->Data = 1;
							this->InitD[6]=0;
						}
					}					
					loc = ComboAt(this->X+8,this->Y+8);//Remember location of the block					
					Screen->ComboD[loc]= this->Data;//Set combo at this location to ffc data.Used to fake solidity
					Waitframe();
				}				
				while(this->InitD[7]>=0){//The block is being pushed					
					Screen->ComboD[loc]= UnderCombo;//Revert combo at ffc location to saved value					
					UnderCombo=0;//Clear variable for later use			
					if(this->InitD[7]==DIR_LEFT){//pushing left						
						while(this->X>=OldX-15){//Not done moving yet
							i++;
							RenderColorCubeRotation(this,restate, this->InitD[7], i);
							this->X--;
							WaitNoAction();
						}
						if(restate==COLOR_CUBE_STATE_RT_BF)//Change current block state. Depends on previous block state
						restate= COLOR_CUBE_STATE_YT_BF;
						else if(restate==COLOR_CUBE_STATE_RT_YF)
						restate= COLOR_CUBE_STATE_BT_YF;
						else if(restate==COLOR_CUBE_STATE_BT_RF)
						restate= COLOR_CUBE_STATE_YT_RF;
						else if(restate==COLOR_CUBE_STATE_BT_YF)
						restate= COLOR_CUBE_STATE_RT_YF;
						else if(restate==COLOR_CUBE_STATE_YT_BF)
						restate= COLOR_CUBE_STATE_RT_BF;
						else if(restate==COLOR_CUBE_STATE_YT_RF)
						restate= COLOR_CUBE_STATE_BT_RF;
						this->InitD[0] = restate;//No longer pushing						
						this->InitD[7] = -1;
					}					
					else if(this->InitD[7]==DIR_RIGHT){	//pushing right
						while(this->X<=OldX+15){
							i++;
							RenderColorCubeRotation(this,restate, this->InitD[7], i);
							this->X++;
							WaitNoAction();
						}
						if(restate==COLOR_CUBE_STATE_RT_BF)
						restate= COLOR_CUBE_STATE_YT_BF;
						else if(restate==COLOR_CUBE_STATE_RT_YF)
						restate= COLOR_CUBE_STATE_BT_YF;
						else if(restate==COLOR_CUBE_STATE_BT_RF)
						restate= COLOR_CUBE_STATE_YT_RF;
						else if(restate==COLOR_CUBE_STATE_BT_YF)
						restate= COLOR_CUBE_STATE_RT_YF;
						else if(restate==COLOR_CUBE_STATE_YT_BF)
						restate= COLOR_CUBE_STATE_RT_BF;
						else if(restate==COLOR_CUBE_STATE_YT_RF)
						restate= COLOR_CUBE_STATE_BT_RF;
						this->InitD[0] = restate;
						this->InitD[7] = -1;
					}					
					else if(this->InitD[7]==DIR_UP){//pushing up
						while(this->Y>=OldY-15){
							i++;
							RenderColorCubeRotation(this,restate, this->InitD[7], i);
							this->Y--;
							WaitNoAction();
						}
						if(restate==COLOR_CUBE_STATE_RT_BF)
						restate= COLOR_CUBE_STATE_BT_RF;
						else if(restate==COLOR_CUBE_STATE_RT_YF)
						restate= COLOR_CUBE_STATE_YT_RF;
						else if(restate==COLOR_CUBE_STATE_BT_RF)
						restate= COLOR_CUBE_STATE_RT_BF;
						else if(restate==COLOR_CUBE_STATE_BT_YF)
						restate= COLOR_CUBE_STATE_YT_BF;
						else if(restate==COLOR_CUBE_STATE_YT_BF)
						restate= COLOR_CUBE_STATE_BT_YF;
						else if(restate==COLOR_CUBE_STATE_YT_RF)
						restate= COLOR_CUBE_STATE_RT_YF;
						this->InitD[0] = restate;
						this->InitD[7] = -1;
					}					
					else if(this->InitD[7]==DIR_DOWN){//pushing down
						while(this->Y<=OldY+15){
							i++;
							RenderColorCubeRotation(this,restate, this->InitD[7], i);
							this->Y++;
							WaitNoAction();
						}						
						if(restate==COLOR_CUBE_STATE_RT_BF)
						restate= COLOR_CUBE_STATE_BT_RF;
						else if(restate==COLOR_CUBE_STATE_RT_YF)
						restate= COLOR_CUBE_STATE_YT_RF;
						else if(restate==COLOR_CUBE_STATE_BT_RF)
						restate= COLOR_CUBE_STATE_RT_BF;
						else if(restate==COLOR_CUBE_STATE_BT_YF)
						restate= COLOR_CUBE_STATE_YT_BF;
						else if(restate==COLOR_CUBE_STATE_YT_BF)
						restate= COLOR_CUBE_STATE_BT_YF;
						else if(restate==COLOR_CUBE_STATE_YT_RF)
						restate= COLOR_CUBE_STATE_RT_YF;
						this->InitD[0] = restate;
						this->InitD[7] = -1;
					}					
					Waitframe();
				}				
				loc = ComboAt(this->X+8,this->Y+8);//Reset block location				
				UnderCombo= Screen->ComboD[loc];//Save combo at location				
				combo= CMB_COLOR_CUBE_ORIGCMB+restate;//Determine what combo to use for ffc				
				this->Data= combo;//Set ffc to combo				
				Screen->ComboD[loc]= this->Data;//Set combo at location to ffc's data				
				flag= Screen->ComboF[loc];//Determine what the flag at the ffc's location is
				//Flag is Script 1. Used for red switches
				if(flag==CF_COLOR_CUBE_TRIGGER_RED){					
					if(restate==COLOR_CUBE_STATE_RT_BF//Red is on top
					||restate==COLOR_CUBE_STATE_RT_YF){						
						if (perm)Movable= false;//This cube can't be moved again
						this->InitD[6]=1;
						ColorCubeTriggerUpdate(this);
					}
				}
				//Flag is Script 2. Used for blue switches
				
				else if(flag==CF_COLOR_CUBE_TRIGGER_BLUE){					
					if(restate==COLOR_CUBE_STATE_BT_RF//Blue is on top
					||restate==COLOR_CUBE_STATE_BT_YF){
						if (perm)Movable= false;
						this->InitD[6]=1;
						ColorCubeTriggerUpdate(this);
					}
				}
				//Flag is Script 3. Used for yellow switches
				else if(flag==CF_COLOR_CUBE_TRIGGER_YELLOW){					
					if(restate==COLOR_CUBE_STATE_YT_BF//Yellow is on top
					||restate==COLOR_CUBE_STATE_YT_RF){
						if (perm)Movable= false;
						this->InitD[6]=1;
						ColorCubeTriggerUpdate(this);
					}
				}				
				OldX= this->X;//Save position of ffc
				OldY= this->Y;				
				Push_Counter = 0;//Reset push counter
				i=0;
				Waitframe();
			}			
			loc = ComboAt(this->X+8,this->Y+8);//Determine location of block			
			Screen->ComboD[loc]= this->Data;//Set combo at location to ffc data			
			Game->PlaySound(SFX_SECRET);//Play secret sfx			
			//Screen->D[perm]++;//Increment Screen->D register			
			Quit();//This script is done
		}
	}
}

//Renders color cube rotation animation.
void RenderColorCubeRotation(ffc f,int state, int dir, int i){
	int origtile = TILE_COLOR_CUBE_ANIMATION+1;
	int anim = 0;
	if (i>10) anim = 2;
	else if (i>=5) anim=1;
	int offset = 20*state;
	offset+=3*dir;
	Screen->FastTile(1, f->X, f->Y, origtile+offset+anim, CSET_COLOR_CUBE_ANIMATION, OP_OPAQUE);
}

//Returns true, if block can be pushed.
bool ColorCubeCanBePushed(ffc f, int dir, int weight){
	int power = 0;
	int itm = GetCurrentItem(IC_BRACELET);
	if (itm>0){
		itemdata it = Game->LoadItemData(itm);
		power = it->Power;
	}
	if (power<weight) return false;	
	int cmb=ComboAt (CenterX (f), CenterY (f));
	int adj = AdjacentComboFix(cmb, dir);
	if (adj<0) return false;	
	if (ComboFI(adj, CF_NOBLOCKS))return false;	
	if (Screen->ComboS[adj]>0) return false;
	return true;
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

//Checks triggers and trigger secrets if all color cubes moved onto correct positions with correct facing
void ColorCubeTriggerUpdate(ffc this){
	for (int i=1;i<=33;i++){
		if (i==33){
			Game->PlaySound(SFX_SECRET);
			Screen->TriggerSecrets();
			Screen->State[ST_SECRET] =true;
			Quit();
		}
		else {
			ffc f = Screen->LoadFFC(i);
			if (f->Script!=this->Script) continue;
			if (f->InitD[7]>=0)break;
			if (f->InitD[6]==0)break;
		}
	}
}