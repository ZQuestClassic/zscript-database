//Main Files
#include "include/std.zh"

//D0- Screen->D register to check
//D1- Value to reach 
//D2- Whether to trigger screen secrets

ffc script Register_Check{
    void run(int perm, int value, bool secret){
		//Secrets have been triggered
		//End the script
		if(Screen->State[ST_SECRET])
			Quit();
        while(true){
			//Screen->D register is a certain value
			//Exit while loop
			if(Screen->D[perm]==value)
				break;
            Waitframe();
        }
		//You want secrets to be triggered
		if(secret){
			//Play sound effect for secrets
			Game->PlaySound(SFX_SECRET);
			//Trigger screen secrets
			Screen->TriggerSecrets();
			Screen->State[ST_SECRET] = true;
		}
    }
}

//D0- Screen->D register to reset
//    Used to prevent cheesing puzzles that use Screen->D registers

ffc script Register_Reset{
    void run(int perm){
		//Reset Screen->D register
		Screen->D[perm]=0;
    }
}

//Test if one location is between two others.
//D0- Location to test
//D1- Lower bound
//D2- Higher bound

bool Between(int loc,int greaterthan, int lessthan){
	if(loc>=greaterthan && loc<=lessthan)return true;
	return false;
}

//Oracles puzzles where you guide colored block onto switches

const int PUSH_BLOCK_COUNTER= 7;//How long to pause when pushing a block
const int STATE_RT_BF		= 0;//Set of 6 states of color cube. Red top, blue front
const int STATE_RT_YF		= 1;//Red top, yellow front
const int STATE_BT_RF		= 2;//Blue top, red front
const int STATE_BT_YF		= 3;//Blue top, yellow front
const int STATE_YT_RF		= 4;//Yellow top, red front
const int STATE_YT_BF		= 5;//Yellow top, blue front

//The order of the combos after these matters
//Place the combos in the order of the states
const int COLOR_COMBO		=632;//First of 6 combos representing the states of the cube
//Place rotating combos in the order: up, down, left, right
const int COLOR_ROTATE		=640;//First of 24 combos representing the rotating animations

//D0- Initial state of the color cube. See state list for accepted values
//D1- Sfx to play when rotating
//D2- Screen->D register to change upon reaching proper spot

ffc script ColorCube{
	void run(int state, int sfx, int perm){
		//Determine which combo to display
		int combo= COLOR_COMBO+state;
		//Store initial state
		int restate= state;
		//Used to determine position on screen
		int loc;
		//Tells script what direction block is being pushed
		//If not being pushed, set to negative one
		int Pushing = -1;
		//Used to play periodic sfx
		int Sfx_Timer;
		//Keeps track of how long you've pushed the block
		int Push_Counter;
		//Stores previous X and Y position of block
		int OldX;
		int OldY;
		//Determines if the block can still be moved
		bool Movable= true;
		//Saves combo under the block
		int UnderCombo;
		//Checks flag at block position
		int flag;
		//Set the ffc to the proper appearance
		this->Data= combo;
		//Iterative variable
		int i;
		while(true){
			//The block can be moved
			while(Movable){
				//Link is too far away from the block
				while(Link->X+16< this->X
						|| Link->X> this->X+16
						|| Link->Y> this->Y+16
						|| Link->Y+16< this->Y){
					//Determine where the block is
					loc = ComboAt(this->X+8,this->Y+8);
					//The variable is empty
					if(!UnderCombo)
						//Save combo at the block's position
						UnderCombo= Screen->ComboD[loc];
					//Set combo at block position to ffc's
					//Used to fake solidity
					Screen->ComboD[loc]= this->Data;	
					Waitframe();
				}
				//You're close enough to be pushing but not long enough to move the block
				while(Pushing==-1){
					//Save the previous location of the block
					OldX= this->X;
					OldY= this->Y;
					//You're pushing right
					if(Link->X+16 >=this->X && Link->X < this->X
						&& (Link->PressRight||Link->InputRight)
						&& (Between(Link->Y+8,this->Y,this->Y+15)
							||Between(Link->Y+1,this->Y,this->Y+15)
							||Between(Link->Y+15,this->Y,this->Y+15))){
						//The combo to the right isn't solid
						if(!Screen->isSolid(this->X+17,this->Y)){
							//The combo to the right doesn't have flag 67 (No push blocks)
							if(!ComboFI(this->X +17, this->Y, CF_NOBLOCKS)){
								//You haven't pushed long enough
								if(Push_Counter<=PUSH_BLOCK_COUNTER){
									//Damp inputs
									Link->PressRight = false;
									Link->InputRight = false;
									//Increment counter
									Push_Counter++;
								}
								//You've pushed long enough
								else{
									//Play sound of pushed block
									Game->PlaySound(sfx);
									//Save what direction the block has been pushed
									Pushing = DIR_RIGHT;
								}
							}
						}
						//Damp inputs
						else{
							Link->PressRight = false;
							Link->InputRight = false;
						}
					}
					//Pushing left
					else if(Link->X <=this->X+16 && Link->X+16 > this->X+16
						&& (Link->PressLeft||Link->InputLeft)
						&& (Between(Link->Y+8,this->Y,this->Y+15)
							||Between(Link->Y+1,this->Y,this->Y+15)
							||Between(Link->Y+15,this->Y,this->Y+15))){
						if(!Screen->isSolid(this->X-1,this->Y)){
							if(!ComboFI(this->X-1, this->Y, CF_NOBLOCKS)){
								if(Push_Counter<=7){
									Link->PressLeft = false;
									Link->InputLeft = false;
									Push_Counter++;
								}
								else{
									Game->PlaySound(sfx);
									Pushing = DIR_LEFT;
								}
							}
						}
						else{
							Link->PressLeft = false;
							Link->InputLeft = false;
						}
					}
					//Pushing down
					else if(Link->Y+16 >=this->Y && Link->Y <= this->Y
						&& (Link->PressDown||Link->InputDown)
						&& (Between(Link->X+8,this->X,this->X+15)
							||Between(Link->X+1,this->X,this->X+15)
							||Between(Link->X+15,this->X,this->X+15))){
						if(!Screen->isSolid(this->X,this->Y+17)){
							if(!ComboFI(this->X, this->Y+17, CF_NOBLOCKS)){
								if(Push_Counter<=7){
									Link->PressDown = false;
									Link->InputDown = false;
									Push_Counter++;
								}
								else{
									Game->PlaySound(sfx);
									Pushing = DIR_DOWN;
								}
							}
						}
						else{
							Link->PressDown = false;
							Link->InputDown = false;
						}
					}
					//Pushing up
					else if(Link->Y <=this->Y+16&& Link->Y+16 > this->Y+16 
						&& (Link->PressUp||Link->InputUp)
						&& (Between(Link->X+8,this->X,this->X+15)
							||Between(Link->X+1,this->X,this->X+15)
							||Between(Link->X+15,this->X,this->X+15))){
						if(!Screen->isSolid(this->X,this->Y-1)){
							if(!ComboFI(this->X, this->Y-1, CF_NOBLOCKS)){
								if(Push_Counter<=7){
									Link->PressUp = false;
									Link->InputUp = false;
									Push_Counter++;
								}
								else{
									Game->PlaySound(sfx);
									Pushing = DIR_UP;
								}
							}
						}
						else{
							Link->PressUp = false;
							Link->InputUp = false;
						}	
					}
					//Remember location of the block
					loc = ComboAt(this->X+8,this->Y+8);
					//Set combo at this location to ffc data
					//Used to fake solidity
					Screen->ComboD[loc]= this->Data;
					Waitframe();
				}
				//Determine animation to use
				combo= COLOR_ROTATE+Pushing+(4*restate);
				//Set ffc data to match
				this->Data=combo;	
				WaitNoAction();
				//The block is being pushed
				while(Pushing!=-1){
					//Revert combo at ffc location to saved value
					Screen->ComboD[loc]= UnderCombo;
					//Clear variable for later use
					UnderCombo=0;
					//Pushing left
					if(Pushing==DIR_LEFT){
						//Not done moving yet
						while(this->X>=OldX-15){
							//Only do things every other frame
							i= (i+1)%2;
							//Play a sound
							if(Sfx_Timer==0)
								Game->PlaySound(sfx);
							//Increment variable for sound effect
							Sfx_Timer = (Sfx_Timer+1)%8;
							//Move the block
							if(i==1)
								this->X--;
							WaitNoAction();
						}
						//Change current block state
						//Depends on previous block state
						if(restate==STATE_RT_BF)
							restate= STATE_YT_BF;
						else if(restate==STATE_RT_YF)
							restate= STATE_BT_YF;
						else if(restate==STATE_BT_RF)
							restate= STATE_YT_RF;
						else if(restate==STATE_BT_YF)
							restate= STATE_RT_YF;
						else if(restate==STATE_YT_BF)
							restate= STATE_RT_BF;
						else if(restate==STATE_YT_RF)
							restate= STATE_BT_RF;
						//No longer pushing
						Pushing = -1;
					}
					//Pushing right
					else if(Pushing==DIR_RIGHT){	
						while(this->X<=OldX+15){
							i= (i+1)%2;
							if(Sfx_Timer==0)
								Game->PlaySound(sfx);
							Sfx_Timer = (Sfx_Timer+1)%8;
							if(i==1)
								this->X++;
							WaitNoAction();
						}
						if(restate==STATE_RT_BF)
							restate= STATE_YT_BF;
						else if(restate==STATE_RT_YF)
							restate= STATE_BT_YF;
						else if(restate==STATE_BT_RF)
							restate= STATE_YT_RF;
						else if(restate==STATE_BT_YF)
							restate= STATE_RT_YF;
						else if(restate==STATE_YT_BF)
							restate= STATE_RT_BF;
						else if(restate==STATE_YT_RF)
							restate= STATE_BT_RF;
						Pushing = -1;
					}
					//Pushing up
					else if(Pushing==DIR_UP){
						while(this->Y>=OldY-15){
							i= (i+1)%2;
							if(Sfx_Timer==0)
								Game->PlaySound(sfx);
							Sfx_Timer = (Sfx_Timer+1)%8;
							if(i==1)
								this->Y--;
							WaitNoAction();
						}
						if(restate==STATE_RT_BF)
							restate= STATE_BT_RF;
						else if(restate==STATE_RT_YF)
							restate= STATE_YT_RF;
						else if(restate==STATE_BT_RF)
							restate= STATE_RT_BF;
						else if(restate==STATE_BT_YF)
							restate= STATE_YT_BF;
						else if(restate==STATE_YT_BF)
							restate= STATE_BT_YF;
						else if(restate==STATE_YT_RF)
							restate= STATE_RT_YF;
						Pushing = -1;
					}
					//Pushing down
					else if(Pushing==DIR_DOWN){
						while(this->Y<=OldY+15){
							i= (i+1)%2;
							if(Sfx_Timer==0)
								Game->PlaySound(sfx);
							Sfx_Timer = (Sfx_Timer+1)%8;
							if(i==1)
								this->Y++;
							WaitNoAction();
						}
						if(restate==STATE_RT_BF)
							restate= STATE_BT_RF;
						else if(restate==STATE_RT_YF)
							restate= STATE_YT_RF;
						else if(restate==STATE_BT_RF)
							restate= STATE_RT_BF;
						else if(restate==STATE_BT_YF)
							restate= STATE_YT_BF;
						else if(restate==STATE_YT_BF)
							restate= STATE_BT_YF;
						else if(restate==STATE_YT_RF)
							restate= STATE_RT_YF;
						Pushing = -1;
					}
					Waitframe();
				}
				//Reset block location
				loc = ComboAt(this->X+8,this->Y+8);
				//Save combo at location
				UnderCombo= Screen->ComboD[loc];
				//Determine what combo to use for ffc
				combo= COLOR_COMBO+restate;
				//Set ffc to combo
				this->Data= combo;
				//Set combo at location to ffc's data
				Screen->ComboD[loc]= this->Data;
				//Determine what the flag at the ffc's location is
				flag= Screen->ComboF[loc];
				//Flag is Script 1
				//Used for red switches
				if(flag==CF_SCRIPT1){
					//Red is on top
					if(restate==STATE_RT_BF
						||restate==STATE_RT_YF)
						//This cube can't be moved again
						Movable= false;
				}
				//Flag is Script 2
				//Used for blue switches
				else if(flag==CF_SCRIPT2){
					//Blue is on top
					if(restate==STATE_BT_RF
						||restate==STATE_BT_YF)
						Movable= false;
				}
				//Flag is Script 3
				//Used for yellow switches
				else if(flag==CF_SCRIPT3){
					//Yellow is on top
					if(restate==STATE_YT_BF
						||restate==STATE_YT_RF)
						Movable= false;
				}
				//Save position of ffc
				OldX= this->X;
				OldY= this->Y;
				//Reset push counter
				Push_Counter = 0;
				Waitframe();
			}
			//Determine location of block
			loc = ComboAt(this->X+8,this->Y+8);
			//Set combo at location to ffc data
			Screen->ComboD[loc]= this->Data;
			//Play secret sfx
			Game->PlaySound(SFX_SECRET);
			//Increment Screen->D register
			Screen->D[perm]++;
			//This script is done
			Quit();
		}
	}
}

//LA Puzzle where you guide block with directional buttons

//D0- Sound to play while moving
//D1- CSet to use for under combo

ffc script DominionBlock{
	void run(int sfx, int cset){
		//Used to determine location of block
		int loc;
		//Used to determine what direction the block is moving
		//If not moving, set to negative one
		int Pushing = -1;
		//Used to play periodic sfx
		int Sfx_Timer;
		//Used to determine how long you've been pushing a block
		int Push_Counter;
		//Set variable to screen's under combo
		int UnderCombo= Screen->UnderCombo;
		//Save previous coordinates of block
		int OldX;
		int OldY;
		//Save data of ffc
		int combo= this->Data;
		//Used to hold Link in place
		int X;
		int Y;
		int i;
		//You're not close enough to push the block
		while(Link->X+16< this->X
				|| Link->X> this->X+16
				|| Link->Y> this->Y+16
				|| Link->Y+16< this->Y){
			//Determine block's location
			loc = ComboAt(this->X+8,this->Y+8);
			//If no under combo is set, use the combo where the block is
			if(!UnderCombo)
				UnderCombo= Screen->ComboD[loc];
			//Set combo at block location to ffc data
			//Used to fake solidity
			Screen->ComboD[loc]= this->Data;	
			Waitframe();
		}
		//You've started pushing but haven't moved the block yet
		while(Pushing==-1){
			//Save previous block coordinates
			OldX= this->X;
			OldY= this->Y;
			//Pushing right
			if(Link->X+16 >=this->X && Link->X < this->X
				&& (Link->PressRight||Link->InputRight)
				&& (Between(Link->Y+8,this->Y,this->Y+15)
					||Between(Link->Y+1,this->Y,this->Y+15)
					||Between(Link->Y+15,this->Y,this->Y+15))){
				//The combo to the right isn't solid
				if(!Screen->isSolid(this->X+17,this->Y)){
					//The combo to the right isn't flag 67 (No push blocks)
					if(!ComboFI(this->X +17, this->Y, CF_NOBLOCKS)){
						//You haven't pushed long enough
						if(Push_Counter<=PUSH_BLOCK_COUNTER){
							//Damp inputs
							Link->PressRight = false;
							Link->InputRight = false;
							//Increment push counter
							Push_Counter++;
						}
						//You've pushed long enough
						else{
							//Play a sound
							Game->PlaySound(sfx);
							//Set variable to indicate pushing to the right
							Pushing = DIR_RIGHT;
						}
					}
				}
				//Damp inputs
				else{
					Link->PressRight = false;
					Link->InputRight = false;
				}
			}
			//Pushing left
			else if(Link->X <=this->X+16 && Link->X+16 > this->X+16
				&& (Link->PressLeft||Link->InputLeft)
				&& (Between(Link->Y+8,this->Y,this->Y+15)
					||Between(Link->Y+1,this->Y,this->Y+15)
					||Between(Link->Y+15,this->Y,this->Y+15))){
				if(!Screen->isSolid(this->X-1,this->Y)){
					if(!ComboFI(this->X-1, this->Y, CF_NOBLOCKS)){
						if(Push_Counter<=7){
							Link->PressLeft = false;
							Link->InputLeft = false;
							Push_Counter++;
						}
						else{
							Game->PlaySound(sfx);
							Pushing = DIR_LEFT;
						}
					}
				}
				else{
					Link->PressLeft = false;
					Link->InputLeft = false;
				}
			}
			//Pushing down
			else if(Link->Y+16 >=this->Y && Link->Y <= this->Y
				&& (Link->PressDown||Link->InputDown)
				&& (Between(Link->X+8,this->X,this->X+15)
					||Between(Link->X+1,this->X,this->X+15)
					||Between(Link->X+15,this->X,this->X+15))){
				if(!Screen->isSolid(this->X,this->Y+17)){
					if(!ComboFI(this->X, this->Y+17, CF_NOBLOCKS)){
						if(Push_Counter<=7){
							Link->PressDown = false;
							Link->InputDown = false;
							Push_Counter++;
						}
						else{
							Game->PlaySound(sfx);
							Pushing = DIR_DOWN;
						}
					}
				}
				else{
					Link->PressDown = false;
					Link->InputDown = false;
				}
			}
			//Pushing up
			else if(Link->Y <=this->Y+16&& Link->Y+16 > this->Y+16 
				&& (Link->PressUp||Link->InputUp)
				&& (Between(Link->X+8,this->X,this->X+15)
					||Between(Link->X+1,this->X,this->X+15)
					||Between(Link->X+15,this->X,this->X+15))){
				if(!Screen->isSolid(this->X,this->Y-1)){
					if(!ComboFI(this->X, this->Y-1, CF_NOBLOCKS)){
						if(Push_Counter<=7){
							Link->PressUp = false;
							Link->InputUp = false;
							Push_Counter++;
						}
						else{
							Game->PlaySound(sfx);
							Pushing = DIR_UP;
						}
					}
				}
				else{
					Link->PressUp = false;
					Link->InputUp = false;
				}	
			}
			//Determine location of block
			loc = ComboAt(this->X+8,this->Y+8);
			Waitframe();
		}
		//Change appearance of ffc
		this->Data= combo+2;
		//Save Link's coordinates
		X= Link->X;
		Y= Link->Y;
		//The block is moving
		while(Pushing!=-1){
			//Change combo at block location to under combo
			Screen->ComboD[loc]= UnderCombo;
			//Change Cset of combo at block location
			Screen->ComboC[loc]= cset;
			//Hold Link in place
			Link->X= X;
			Link->Y= Y;
			//Set flag 67 at block location
			//Prevents block from crossing its own path
			Screen->ComboF[loc]= CF_NOBLOCKS;
			//Pushing left
			if(Pushing==DIR_LEFT){
				//The combo to the left isn't solid
				if(!Screen->isSolid(this->X-1,this->Y)){
					//The combo to the left isn't flag 67 (No push blocks)
					if(!ComboFI(this->X-1, this->Y, CF_NOBLOCKS)){
						//Haven't finished moving left
						while(this->X>=OldX-15){
							//Play a sound periodically
							if(Sfx_Timer==0)
								Game->PlaySound(sfx);
							//Determine when to play the sound
							Sfx_Timer = (Sfx_Timer+1)%8;
							//Move the block lect
							i= (i+1)%2;
							if(i==1)
								this->X--;
							//If you press up
							if(Link->PressUp
								||Link->InputUp){
								//If the combo above isn't solid
								if(!Screen->isSolid(this->X,this->Y-1)){
									//If the combo above doesn't have flag 67 (No push blocks)
									if(!ComboFI(this->X, this->Y-1, CF_NOBLOCKS)){
										//Damp input
										Link->PressUp = false;
										Link->InputUp = false;
										//Change direction of movement
										Pushing = DIR_UP;
									}
								}
								//Damp input
								else{
									Link->PressUp = false;
									Link->InputUp = false;
								}
							}
							//If you press down
							else if(Link->PressDown
									||Link->InputDown){
								if(!Screen->isSolid(this->X,this->Y+17)){
									if(!ComboFI(this->X, this->Y+17, CF_NOBLOCKS)){
										Link->PressDown = false;
										Link->InputDown = false;
										Pushing = DIR_DOWN;
									}
								}
								else{
									Link->PressDown = false;
									Link->InputDown = false;
								}
							}
							WaitNoAction();
						}
					}
					//Stop the block from moving
					else
						break;
				}
				//Stop the block from moving
				else
					break;
				//Save the block's coordinates for next time
				OldX= this->X;
				OldY= this->Y;
			}
			//Pushing right
			else if(Pushing==DIR_RIGHT){	
				if(!Screen->isSolid(this->X+17,this->Y)){
					if(!ComboFI(this->X +17, this->Y, CF_NOBLOCKS)){
						while(this->X<=OldX+15){
							if(Sfx_Timer==0)
								Game->PlaySound(sfx);
							Sfx_Timer = (Sfx_Timer+1)%8;
							i= (i+1)%2;
							if(i==1)
								this->X++;
							if(Link->PressUp
								||Link->InputUp){
								if(!Screen->isSolid(this->X,this->Y-1)){
									if(!ComboFI(this->X, this->Y-1, CF_NOBLOCKS)){
										Link->PressUp = false;
										Link->InputUp = false;
										Pushing = DIR_UP;
									}
								}
								else{
									Link->PressUp = false;
									Link->InputUp = false;
								}
							}
							else if(Link->PressDown
									||Link->InputDown){
								if(!Screen->isSolid(this->X,this->Y+17)){
									if(!ComboFI(this->X, this->Y+17, CF_NOBLOCKS)){
										Link->PressDown = false;
										Link->InputDown = false;
										Pushing = DIR_DOWN;
									}
								}
								else{
									Link->PressDown = false;
									Link->InputDown = false;
								}
							}
							WaitNoAction();
						}
						OldX= this->X;
						OldY= this->Y;
					}
					else
						break;
				}
				else
					break;
			}
			//Pushing up
			else if(Pushing==DIR_UP){
				if(!Screen->isSolid(this->X,this->Y-1)){
					if(!ComboFI(this->X, this->Y-1, CF_NOBLOCKS)){
						while(this->Y>=OldY-15){
							if(Sfx_Timer==0)
								Game->PlaySound(sfx);
							Sfx_Timer = (Sfx_Timer+1)%8;
							i= (i+1)%2;
							if(i==1)
								this->Y--;
							if(Link->PressLeft
								||Link->InputLeft){	
								if(!Screen->isSolid(this->X-1,this->Y)){
									if(!ComboFI(this->X-1, this->Y, CF_NOBLOCKS)){
										Link->PressLeft = false;
										Link->InputLeft = false;
										Pushing = DIR_LEFT;
									}
								}
								else{
									Link->PressLeft = false;
									Link->InputLeft = false;
								}
							}
							else if(Link->PressRight
								||Link->InputRight){	
								if(!Screen->isSolid(this->X+17,this->Y)){
									if(!ComboFI(this->X +17, this->Y, CF_NOBLOCKS)){
										if(Push_Counter<=PUSH_BLOCK_COUNTER){
											Link->PressRight = false;
											Link->InputRight = false;
											Push_Counter++;
										}
										else{
											Game->PlaySound(sfx);
											Pushing = DIR_RIGHT;
										}
									}
								}
								else{
									Link->PressRight = false;
									Link->InputRight = false;
								}
							}
							WaitNoAction();
						}
						OldX= this->X;
						OldY= this->Y;
					}
					else
						break;
				}
				else
					break;
			}
			//Pushing down
			else if(Pushing==DIR_DOWN){
				if(!Screen->isSolid(this->X,this->Y+17)){
					if(!ComboFI(this->X, this->Y+17, CF_NOBLOCKS)){
						while(this->Y<=OldY+15){
							if(Sfx_Timer==0)
								Game->PlaySound(sfx);
							Sfx_Timer = (Sfx_Timer+1)%8;
							i= (i+1)%2;
							if(i==1)
								this->Y++;
							if(Link->PressLeft
								||Link->InputLeft){	
								if(!Screen->isSolid(this->X-1,this->Y)){
									if(!ComboFI(this->X-1, this->Y, CF_NOBLOCKS)){
										Link->PressLeft = false;
										Link->InputLeft = false;
										Pushing = DIR_LEFT;
									}
								}
								else{
									Link->PressLeft = false;
									Link->InputLeft = false;
								}
							}
							else if(Link->PressRight
								||Link->InputRight){	
								if(!Screen->isSolid(this->X+17,this->Y)){
									if(!ComboFI(this->X +17, this->Y, CF_NOBLOCKS)){
										if(Push_Counter<=PUSH_BLOCK_COUNTER){
											Link->PressRight = false;
											Link->InputRight = false;
											Push_Counter++;
										}
										else{
											Game->PlaySound(sfx);
											Pushing = DIR_RIGHT;
										}
									}
								}
								else{
									Link->PressRight = false;
									Link->InputRight = false;
								}
							}
							WaitNoAction();
						}
						OldX= this->X;
						OldY= this->Y;
					}
					else
						break;
				}
				else
					break;
			}
			//Determine location of block
			loc = ComboAt(this->X+8,this->Y+8);
			Waitframe();
		}
		//Change appearance of block
		this->Data= combo+1;
		//Determine location of block
		loc = ComboAt(this->X+8,this->Y+8);
		//Set combo at location of block to ffc data
		//Used to fake solidity
		Screen->ComboD[loc]= this->Data;
		//This script is done
		Quit();
	}
}

//D0- Combo Type to check for

ffc script Type_Puzzle{
	void run(int type){
		//Iterative variable
		int i;
		//Current combo count
		int Combo_Count;
		while(true){
			//Reset combo count every frame
			Combo_Count= 0;
			//Check all combos
			for(i=0;i<=175;i++){
				//If there's a combo of the right type
				if(Screen->ComboT[i]==type)
					//Increment count of combos
					Combo_Count++;
			}
			//There are no combos of this type
			if(!Combo_Count){
				//Trigger screen secrets
				Screen->TriggerSecrets();
				Screen->State[ST_SECRET] = true;
				//Play a sound
				Game->PlaySound(SFX_SECRET);
				//End infinite loop
				break;
			}
			Waitframe();
		}
	}
}

//D0- Combo ID of trigger
//D1- Sound to be made
//D2- Number of triggers in the room.
//D3- Whether screen secrets are triggered.
//D4- Screen->D register to store secrets in.

ffc script Combo_Change{
    void run(int comboid, int sfx, int numTriggers, bool secret,int perm, bool temp){
        bool isBlock[176];
        bool SoundMade[176];
        bool playSound=false;
		int numChanged;
		bool triggered = false;
		int i;
        for(i=0; i<176; i++){
            SoundMade[i] = false;
            if(Screen->ComboD[i]==comboid)isBlock[i]= true;
        }
		if (Screen->D[perm])
			triggered = true;
        while(!triggered){
			if(temp){
				for(i=0; i<176; i++)
					SoundMade[i]=false;
				numChanged = 0;
			}
            for(i=0; i<176; i++){
                if(isBlock[i] && !SoundMade[i] && Screen->ComboD[i]!=comboid){
                    SoundMade[i]=true;
                    if(sfx>0)playSound = true;
					if(secret)numChanged++;
                }
            }
            if(playSound){
                Game->PlaySound(sfx);
                playSound=false;
            }
			if(numChanged == numTriggers && secret)
				triggered = true;
            Waitframe();
        }
		if(secret){
			Screen->TriggerSecrets();
			Screen->State[ST_SECRET] = true;
			Game->PlaySound(SFX_SECRET);
		}
		Screen->D[perm]=1;
    }
}

const int SFX_PUSH_SOMARIA 	= 50;
const int SFX_SWITCH_PUSH	= 66;

//D0- Whether this push block will only set off triggers of a certain flag or type
//	  0- No flag needed. Sets off triggers with flag 66
//	  1- Flag needed. If type is not set, this is placed or inherent flag
//
//D1- If you want the push block to set off a trigger when it rests on a specific combo type
//    Can only be set if D0 is greater than 1.
//
//D2- Screen->D register to store puzzle completion
//    Activated by setting D0 or D1 to something other than zero
//    Set to a value between 0-7
//    All parts of a puzzle should use the same value
//    Use in connection with Register_Check script
//
//D3- Something must be done before you can push this block
//    0- No requirement
//    1- Kill all enemies
//    2- Level 1 bracelet
//    3- Level 2 bracelet
//	  4- Level 3 bracelet
//
//D4- This block can only be pushed in one direction
//    0- All 4 directions
//    -1- Up
//	  1- Down
//    2- Left
//	  3- Right
//	  4- Horizontal
//    5- Vertical

ffc script PushBlock{
	void run(int flag, int type, int perm, int req, int dir){
		int Pushing = -1;
		int PushCooldown;
		int i;
		int ComboArray[176];
		int loc;
		int Sfx_Timer;
		int Push_Counter;
		int OldX;
		int OldY;
		bool Movable= true;
		int UnderCombo;
		if(req==1){
			while(EnemyCount())
				Waitframe();
		}
		else if(req==2){
			while(!Link->Item[I_BRACELET1])
				Waitframe();
		}
		else if(req==3){
			while(!Link->Item[I_BRACELET2])
				Waitframe();
		}
		else if(req==4){
			while(!Link->Item[I_BRACELET3])
				Waitframe();
		}
		while(true){
			while(Movable){
				while(Link->X+16< this->X
						|| Link->X> this->X+16
						|| Link->Y> this->Y+16
						|| Link->Y+16< this->Y){
					loc = ComboAt(this->X+8,this->Y+8);
					if(!UnderCombo)
						UnderCombo= Screen->ComboD[loc];
					if(IsSideview()){
						if(!OnSidePlatform(this->X,this->Y)){
							Screen->ComboD[loc]= UnderCombo;
							this->Y++;
						}
						else
							Screen->ComboD[loc]= this->Data;
					}
					else
						Screen->ComboD[loc]= this->Data;
					if(Is_Switch(loc)){
						Game->PlaySound(SFX_SWITCH_PUSH);
						Movable= false;
					}
					if(flag){
						if(!type){
							if(ComboFI(loc,flag)){
								Game->PlaySound(SFX_SWITCH_PUSH);
								Movable= false;
							}
						}
						else{
							if(Screen->ComboT[loc]==type){
								Game->PlaySound(SFX_SWITCH_PUSH);
								Movable= false;
							}
						}
					}
					Waitframe();
				}
				if(!Movable)
					break;
				while(Pushing==-1){
					OldX= this->X;
					OldY= this->Y;
					if(!dir){
						if(Link->X+16 >=this->X && Link->X < this->X
							&& (Link->PressRight||Link->InputRight)
							&& (Between(Link->Y+8,this->Y,this->Y+15)
								||Between(Link->Y+1,this->Y,this->Y+15)
								||Between(Link->Y+15,this->Y,this->Y+15))){
							if(!Screen->isSolid(this->X+17,this->Y)){
								if(!ComboFI(this->X +17, this->Y, CF_NOBLOCKS)){
									if(Push_Counter<=PUSH_BLOCK_COUNTER){
										Link->PressRight = false;
										Link->InputRight = false;
										Push_Counter++;
									}
									else{
										Game->PlaySound(SFX_PUSH_SOMARIA);
										Pushing = DIR_RIGHT;
									}
								}
							}
							else{
								Link->PressRight = false;
								Link->InputRight = false;
							}
						}
						else if(Link->X <=this->X+16 && Link->X+16 > this->X+16
							&& (Link->PressLeft||Link->InputLeft)
							&& (Between(Link->Y+8,this->Y,this->Y+15)
								||Between(Link->Y+1,this->Y,this->Y+15)
								||Between(Link->Y+15,this->Y,this->Y+15))){
							if(!Screen->isSolid(this->X-1,this->Y)){
								if(!ComboFI(this->X-1, this->Y, CF_NOBLOCKS)){
									if(Push_Counter<=7){
										Link->PressLeft = false;
										Link->InputLeft = false;
										Push_Counter++;
									}
									else{
										Game->PlaySound(SFX_PUSH_SOMARIA);
										Pushing = DIR_LEFT;
									}
								}
							}
							else{
								Link->PressLeft = false;
								Link->InputLeft = false;
							}
						}
						else if(Link->Y+16 >=this->Y && Link->Y <= this->Y
							&& (Link->PressDown||Link->InputDown)
							&& (Between(Link->X+8,this->X,this->X+15)
								||Between(Link->X+1,this->X,this->X+15)
								||Between(Link->X+15,this->X,this->X+15))){
							if(!Screen->isSolid(this->X,this->Y+17)){
								if(!ComboFI(this->X, this->Y+17, CF_NOBLOCKS)){
									if(Push_Counter<=7){
										Link->PressDown = false;
										Link->InputDown = false;
										Push_Counter++;
									}
									else{
										Game->PlaySound(SFX_PUSH_SOMARIA);
										Pushing = DIR_DOWN;
									}
								}
							}
							else{
								Link->PressDown = false;
								Link->InputDown = false;
							}
						}
						else if(Link->Y <=this->Y+16&& Link->Y+16 > this->Y+16 
							&& (Link->PressUp||Link->InputUp)
							&& (Between(Link->X+8,this->X,this->X+15)
								||Between(Link->X+1,this->X,this->X+15)
								||Between(Link->X+15,this->X,this->X+15))){
							if(!Screen->isSolid(this->X,this->Y-1)){
								if(!ComboFI(this->X, this->Y-1, CF_NOBLOCKS)){
									if(Push_Counter<=7){
										Link->PressUp = false;
										Link->InputUp = false;
										Push_Counter++;
									}
									else{
										Game->PlaySound(SFX_PUSH_SOMARIA);
										Pushing = DIR_UP;
									}
								}
							}
							else{
								Link->PressUp = false;
								Link->InputUp = false;
							}	
						}
						loc = ComboAt(this->X+8,this->Y+8);
						if(IsSideview()){
							if(!OnSidePlatform(this->X,this->Y)){
								Screen->ComboD[loc]= UnderCombo;
								this->Y++;
							}
							else
								Screen->ComboD[loc]= this->Data;
						}
						if(Is_Switch(loc)){
							Screen->ComboD[loc]= this->Data;
							Game->PlaySound(SFX_SWITCH_PUSH);
							Movable= false;
						}
						if(flag){
							if(!type){
								if(ComboFI(loc,flag)){
									Game->PlaySound(SFX_SWITCH_PUSH);
									Movable= false;
								}
							}
							else{
								if(Screen->ComboT[loc]==type){
									Game->PlaySound(SFX_SWITCH_PUSH);
									Movable= false;
								}
							}
						}
					}
					else{
						if(dir==-1){
							if(Link->Y <=this->Y+16&& Link->Y+16 > this->Y+16 
								&& (Link->PressUp||Link->InputUp)
								&& (Between(Link->X+8,this->X,this->X+15)
									||Between(Link->X+1,this->X,this->X+15)
									||Between(Link->X+15,this->X,this->X+15))){
								if(!Screen->isSolid(this->X,this->Y-1)){
									if(!ComboFI(this->X, this->Y-1, CF_NOBLOCKS)){
										if(Push_Counter<=7){
											Link->PressUp = false;
											Link->InputUp = false;
											Push_Counter++;
										}
										else{
											Game->PlaySound(SFX_PUSH_SOMARIA);
											Pushing = DIR_UP;
										}
									}
								}
								else{
									Link->PressUp = false;
									Link->InputUp = false;
								}	
							}
						}
						else if(dir==1){
							if(Link->Y+16 >=this->Y && Link->Y <= this->Y
								&& (Link->PressDown||Link->InputDown)
								&& (Between(Link->X+8,this->X,this->X+15)
									||Between(Link->X+1,this->X,this->X+15)
									||Between(Link->X+15,this->X,this->X+15))){
								if(!Screen->isSolid(this->X,this->Y+17)){
									if(!ComboFI(this->X, this->Y+17, CF_NOBLOCKS)){
										if(Push_Counter<=7){
											Link->PressDown = false;
											Link->InputDown = false;
											Push_Counter++;
										}
										else{
											Game->PlaySound(SFX_PUSH_SOMARIA);
											Pushing = DIR_DOWN;
										}
									}
								}
								else{
									Link->PressDown = false;
									Link->InputDown = false;
								}
							}
						}
						else if(dir==2){
							if(Link->X <=this->X+16 && Link->X+16 > this->X+16
								&& (Link->PressLeft||Link->InputLeft)
								&& (Between(Link->Y+8,this->Y,this->Y+15)
									||Between(Link->Y+1,this->Y,this->Y+15)
									||Between(Link->Y+15,this->Y,this->Y+15))){
								if(!Screen->isSolid(this->X-1,this->Y)){
									if(!ComboFI(this->X-1, this->Y, CF_NOBLOCKS)){
										if(Push_Counter<=7){
											Link->PressLeft = false;
											Link->InputLeft = false;
											Push_Counter++;
										}
										else{
											Game->PlaySound(SFX_PUSH_SOMARIA);
											Pushing = DIR_LEFT;
										}
									}
								}
								else{
									Link->PressLeft = false;
									Link->InputLeft = false;
								}
							}
						}
						else if(dir==3){
							if(Link->X+16 >=this->X && Link->X < this->X
								&& (Link->PressRight||Link->InputRight)
								&& (Between(Link->Y+8,this->Y,this->Y+15)
									||Between(Link->Y+1,this->Y,this->Y+15)
									||Between(Link->Y+15,this->Y,this->Y+15))){
								if(!Screen->isSolid(this->X+17,this->Y)){
									if(!ComboFI(this->X +17, this->Y, CF_NOBLOCKS)){
										if(Push_Counter<=PUSH_BLOCK_COUNTER){
											Link->PressRight = false;
											Link->InputRight = false;
											Push_Counter++;
										}
										else{
											Game->PlaySound(SFX_PUSH_SOMARIA);
											Pushing = DIR_RIGHT;
										}
									}
								}
								else{
									Link->PressRight = false;
									Link->InputRight = false;
								}
							}
						}
						else if(dir==4){
							if(Link->X+16 >=this->X && Link->X < this->X
								&& (Link->PressRight||Link->InputRight)
								&& (Between(Link->Y+8,this->Y,this->Y+15)
									||Between(Link->Y+1,this->Y,this->Y+15)
									||Between(Link->Y+15,this->Y,this->Y+15))){
								if(!Screen->isSolid(this->X+17,this->Y)){
									if(!ComboFI(this->X +17, this->Y, CF_NOBLOCKS)){
										if(Push_Counter<=PUSH_BLOCK_COUNTER){
											Link->PressRight = false;
											Link->InputRight = false;
											Push_Counter++;
										}
										else{
											Game->PlaySound(SFX_PUSH_SOMARIA);
											Pushing = DIR_RIGHT;
										}
									}
								}
								else{
									Link->PressRight = false;
									Link->InputRight = false;
								}
							}
							else if(Link->X <=this->X+16 && Link->X+16 > this->X+16
								&& (Link->PressLeft||Link->InputLeft)
								&& (Between(Link->Y+8,this->Y,this->Y+15)
									||Between(Link->Y+1,this->Y,this->Y+15)
									||Between(Link->Y+15,this->Y,this->Y+15))){
								if(!Screen->isSolid(this->X-1,this->Y)){
									if(!ComboFI(this->X-1, this->Y, CF_NOBLOCKS)){
										if(Push_Counter<=7){
											Link->PressLeft = false;
											Link->InputLeft = false;
											Push_Counter++;
										}
										else{
											Game->PlaySound(SFX_PUSH_SOMARIA);
											Pushing = DIR_LEFT;
										}
									}
								}
								else{
									Link->PressLeft = false;
									Link->InputLeft = false;
								}
							}
						}
						else if(dir==5){
							if(Link->Y <=this->Y+16&& Link->Y+16 > this->Y+16 
								&& (Link->PressUp||Link->InputUp)
								&& (Between(Link->X+8,this->X,this->X+15)
									||Between(Link->X+1,this->X,this->X+15)
									||Between(Link->X+15,this->X,this->X+15))){
								if(!Screen->isSolid(this->X,this->Y-1)){
									if(!ComboFI(this->X, this->Y-1, CF_NOBLOCKS)){
										if(Push_Counter<=7){
											Link->PressUp = false;
											Link->InputUp = false;
											Push_Counter++;
										}
										else{
											Game->PlaySound(SFX_PUSH_SOMARIA);
											Pushing = DIR_UP;
										}
									}
								}
								else{
									Link->PressUp = false;
									Link->InputUp = false;
								}	
							}
							else if(Link->Y+16 >=this->Y && Link->Y <= this->Y
								&& (Link->PressDown||Link->InputDown)
								&& (Between(Link->X+8,this->X,this->X+15)
									||Between(Link->X+1,this->X,this->X+15)
									||Between(Link->X+15,this->X,this->X+15))){
								if(!Screen->isSolid(this->X,this->Y+17)){
									if(!ComboFI(this->X, this->Y+17, CF_NOBLOCKS)){
										if(Push_Counter<=7){
											Link->PressDown = false;
											Link->InputDown = false;
											Push_Counter++;
										}
										else{
											Game->PlaySound(SFX_PUSH_SOMARIA);
											Pushing = DIR_DOWN;
										}
									}
								}
								else{
									Link->PressDown = false;
									Link->InputDown = false;
								}
							}
						}
					}
					Waitframe();
				}	
				if(!Movable)
					break;
				while(Pushing!=-1){
					Screen->ComboD[loc]= UnderCombo;
					UnderCombo=0;
					if(Pushing==DIR_LEFT){
						while(this->X>=OldX-15){
							if(Sfx_Timer==0)
								Game->PlaySound(SFX_PUSH_SOMARIA);
							Sfx_Timer = (Sfx_Timer+1)%8;
							this->X--;
							WaitNoAction();
						}
						Pushing = -1;
					}
					else if(Pushing==DIR_RIGHT){
						while(this->X<=OldX+15){
							if(Sfx_Timer==0)
								Game->PlaySound(SFX_PUSH_SOMARIA);
							Sfx_Timer = (Sfx_Timer+1)%8;
							this->X++;
							WaitNoAction();
						}
						Pushing = -1;
					}
					else if(Pushing==DIR_UP){
						while(this->Y>=OldY-15){
							if(Sfx_Timer==0)
								Game->PlaySound(SFX_PUSH_SOMARIA);
							Sfx_Timer = (Sfx_Timer+1)%8;
							this->Y--;
							WaitNoAction();
						}
						Pushing = -1;
					}
					else if(Pushing==DIR_DOWN){
						while(this->Y<=OldY+15){
							if(Sfx_Timer==0)
								Game->PlaySound(SFX_PUSH_SOMARIA);
							Sfx_Timer = (Sfx_Timer+1)%8;
							this->Y++;
							WaitNoAction();
						}
						Pushing = -1;
					}
					loc = ComboAt(this->X+8,this->Y+8);
					UnderCombo= Screen->ComboD[loc];
					if(IsSideview()){
						if(!OnSidePlatform(this->X,this->Y))
							Screen->ComboD[loc]= UnderCombo;
						while(!OnSidePlatform(this->X,this->Y)){	
							this->Y++;
							Waitframe();
						}
						loc = ComboAt(this->X+8,this->Y+8);
						Screen->ComboD[loc]= this->Data;
					}
					if(Is_Switch(loc)){
						Screen->ComboD[loc]= this->Data;
						Game->PlaySound(SFX_SWITCH_PUSH);
						Movable= false;
					}
					if(flag){
						if(!type){
							if(ComboFI(loc,flag)){
								Game->PlaySound(SFX_SWITCH_PUSH);
								Movable= false;
							}
						}
						else{
							if(Screen->ComboT[loc]==type){
								Game->PlaySound(SFX_SWITCH_PUSH);
								Movable= false;
							}
						}
					}
					Waitframe();
				}
				OldX= this->X;
				OldY= this->Y;
				Push_Counter = 0;
				Waitframe();
			}
			if(flag)
				Screen->D[perm]++;
			loc = ComboAt(this->X+8,this->Y+8);
			Screen->ComboD[loc]= this->Data;
			Quit();
		}
	}
}

int EnemyCount(){
	int count;
	for(int i=Screen->NumNPCs(); i>0; i--){
		npc n = Screen->LoadNPC(i);
		if(n->MiscFlags&(1<<3)) //Doesn't count as a beatable enemy flag
			continue;
		if(n->Type==NPCT_GUY||n->Type==NPCT_TRAP
			||n->Type==NPCT_PROJECTILE||n->Type==NPCT_NONE
			||n->Type==NPCT_FAIRY)
			continue;
		if(n->Type==NPCT_ZORA) //Borderline if this should be a skippable enemy. I believe most ZC behaviors skip it, so I've put it 
                                       //here
			continue;
		if(n->HP>0)	
			count++;
	}
	return count;
}

bool Is_Switch(int loc){
    return ComboFIT(loc,CF_BLOCKTRIGGER,CT_NONE);
}

//Checks for matching combo flag and type.

//D0- On scren location.
//D1- Combo Flag to check.
//D2- Combo Type to check.

bool ComboFIT(int loc,int flag,int type){
	if(ComboFI(loc,flag)&& Screen->ComboT[loc]==type)
		return true;
	return false;
}

ffc script OneTimeMessage{
	void run(int message, int perm){
		if(Screen->D[perm])
			Quit();
		Screen->Message(message);
		Screen->D[perm]=1;
	}
}