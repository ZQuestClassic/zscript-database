import "std.zh"
import "ghost.zh"
import "string.zh"

//Global Variables

int TimesContinued;//Tracks how many times you've continued.

global script Active{
	void run(){
		//Increases variable when you F6.
		//Used to prevent cheating past spinners.
	    TimesContinued++;
	}
}

global script OnContinue{
	void run(){
		//Increases variable when you load the game after saving.
		//Used to prevent cheating past spinners.
		TimesContinued++;
	}
}

global script OnExit{
	void run(){
		TimesContinued++;
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

//Floor Spinner

const int FLOOR_SPINNER_SFX = 78;//Sound made by spinner.
const int FLOOR_SPINNER_REST_COMBO = 29620;//Counterclockwise spinner at rest.
                                           //Clockwise is one more.
const int FLOOR_SPINNER_BASE_COMBO = 29622;//Base of spinner with counterclockwise lights.
                                           //Clockwise is one more.
const int SPINNER_CSET = 8;//Cset used by spinner.

//D0- True if clockwise rotation. False if not.
//D1- Screen->D register to store having already rotated. Register zero is reserved.

ffc script Floor_Spinner{
	void run(bool Clockwise,int perm){
		int SpinDestination;//Determines destination.
		float angle;//Handles rotation.
		//Controls spin phase.
		bool Spinning = false;
		bool HasSpun;//Tells the script if this spinner has already spun.
		bool TimeStored = false;//Tells script if Screen->D zero has already been altered.
		//If nothing is stored in Screen->D zero.
		if(!TimeStored && Screen->D[0]==0){
			//Alter it to match times you've continued.
			Screen->D[0]= TimesContinued;
			//Make it never do this again.
			TimeStored= true;
		}
		//Screen->D zero has a value in it.
		else{
			//Screen->D zero is not equal to the global variable.
			if(Screen->D[0]!=TimesContinued){
				//Change it to be equal to the global variable.
				Screen->D[0]= TimesContinued;
				//Reset the spinner.
				Screen->D[perm]= 0;
			}
		}
		//Based on current value of the register, determine if this spinner has already spun.
		if(Screen->D[perm]==0)HasSpun = false;
		else HasSpun= true;
		//Change appearance accordingly.
		if((Clockwise && !HasSpun)||(!Clockwise && HasSpun))
			this->Data = FLOOR_SPINNER_REST_COMBO+1;						
		else if((Clockwise && HasSpun)||(!Clockwise && !HasSpun))
			this->Data = FLOOR_SPINNER_REST_COMBO;	
		while(true){
			//First time visiting with a clockwise or already visited CCW.
			if((Clockwise && !HasSpun)||(!Clockwise && HasSpun)){
				Screen->DrawCombo(1, this->X, this->Y, FLOOR_SPINNER_BASE_COMBO+1, 3, 3, SPINNER_CSET, -1,-1, 0, 0, 0, 1, -1, true, 128);			
				///Approach from top.
				if(Between(Link->X,this->X+2,this->X+(this->TileWidth*16)-2) && 
				   Between(Link->Y+16,this->Y+2,this->Y+8) && 
				   Between(Link->X+16,this->X+2,this->X+(this->TileWidth*16)-2)){
				   //Go to right.
					SpinDestination = 1;
					//Start spin phase.
					Spinning = true;
				}
				//Approach from bottom.
				else if(Between(Link->X,this->X+2,this->X+(this->TileWidth*16)-2) && 
						Between(Link->Y,this->Y+24,this->Y+(this->TileHeight*16)-2) && 
						Between(Link->X+16,this->X+2,this->X+(this->TileWidth*16)-2)){
					//Go to left.
					SpinDestination = 3;
					Spinning = true;
				}
				//Approach from left.
				else if(Between(Link->Y,this->Y+2,this->Y+(this->TileHeight*16)-2) && 
						Between(Link->Y+16,this->Y+2,this->Y+(this->TileHeight*16)-2) && 
						Between(Link->X+16,this->X+2,this->X+(this->TileWidth*16)-2)){
					//Go to top.
					SpinDestination = 0;
					Spinning = true;
				}
				//Approach from right.
				else if(Between(Link->Y,this->Y+2,this->Y+(this->TileHeight*16)-2) && 
						Between(Link->Y+16,this->Y+2,this->Y+(this->TileHeight*16)-2) && 
						Between(Link->X,this->X+24,this->X+(this->TileWidth*16)-2)){
						//Go to bottom.
						SpinDestination = 2;
						Spinning = true;
				}
			}
			//Return to clockwise or first time visited CCW.
			else if((Clockwise && HasSpun)||(!Clockwise && !HasSpun)){
				Screen->DrawCombo(1, this->X, this->Y, FLOOR_SPINNER_BASE_COMBO, 3, 3, SPINNER_CSET, -1,-1, 0, 0, 0, 1, -1, true, 128);			
				//Approach from top.
				if(Between(Link->X,this->X+2,this->X+(this->TileWidth*16)-2) && 
				   Between(Link->Y+16,this->Y+2,this->Y+8) && 
				   Between(Link->X+16,this->X+2,this->X+(this->TileWidth*16)-2)){
				   //Go to left.
					SpinDestination = 2;
					Spinning = true;
				}
				//Approach from bottom.
				else if(Between(Link->X,this->X+2,this->X+(this->TileWidth*16)-2) && 
						Between(Link->Y,this->Y+24,this->Y+(this->TileHeight*16)-2) && 
						Between(Link->X+16,this->X+2,this->X+(this->TileWidth*16)-2)){
					//Go to right.
					SpinDestination = 1;
					Spinning = true;
				}
				//Approach from left.
				else if(Between(Link->Y,this->Y+2,this->Y+(this->TileHeight*16)-2) && 
						Between(Link->Y+16,this->Y+2,this->Y+(this->TileHeight*16)-2) && 
						Between(Link->X+16,this->X+2,this->X+(this->TileWidth*16)-2)){
					//Go to bottom
					SpinDestination = 3;
					Spinning = true;
				}
				//Approach from right.
				else if(Between(Link->Y,this->Y+2,this->Y+(this->TileHeight*16)-2) && 
						Between(Link->Y+16,this->Y+2,this->Y+(this->TileHeight*16)-2) && 
						Between(Link->X,this->X+24,this->X+(this->TileWidth*16)-2)){
						//Go to top.
						SpinDestination = 0;
						Spinning = true;
				}
			}
			//Time to spin now.
			if(Spinning){
					//First time on a clockwise spinner or return to a counterclockwise spinner.
					if((Clockwise && !HasSpun)||(!Clockwise && HasSpun)){
						//From left to top.
						if(SpinDestination ==0){
							//Set starting position.
							angle = 180;
							while(angle<270){
								//Make the ffc invisible.
								//You don't have to use the ghost.zh invisible combo, I just find it easier.
								this->Data= GH_INVISIBLE_COMBO;
								//Keep Link immobile.
								NoAction();
								//Handles rotation.
								angle= (angle+2)%360;
								//Draw combos corresponding to the spinner's appearance and rotate them.
								Screen->DrawCombo(1, this->X, this->Y, FLOOR_SPINNER_BASE_COMBO+1, 3, 3, SPINNER_CSET, -1,-1, 0, 0, 0, 1, -1, true, 128);			
								Screen->DrawCombo(2, this->X, this->Y, FLOOR_SPINNER_REST_COMBO+1, 3, 3, SPINNER_CSET, -1,-1, this->X, this->Y, angle, 1, -1, true, 128);
								//Play a sound.
								Game->PlaySound(FLOOR_SPINNER_SFX);
								//Rotate Link.
								Link->X = (this->X+16)+ 20 * Cos(angle);
								Link->Y = (this->Y+16)+ 20 * Sin(angle);
								Waitframe();
							}
							//If this spinner hadn't spun before...
							if(!HasSpun){
								//Set Screen->D register.
								Screen->D[perm]= 1;
								//Change variable.
								HasSpun = true;
							}
							//This spinner has spun before.
							else if(HasSpun){
								Screen->D[perm]= 0;
								HasSpun = false;
							}
							//Reset ffc to visible.
							this->Data = FLOOR_SPINNER_REST_COMBO;
							//Handles leaving spinner.
							SpinnerExit(DIR_UP,this,Clockwise,HasSpun);
							Spinning = false;
						}
						//From top to right.
						else if(SpinDestination ==1){
							angle = 270;
							while(angle!=0){
								this->Data= GH_INVISIBLE_COMBO;
								NoAction();
								angle= (angle+2)%360;
								Screen->DrawCombo(1, this->X, this->Y, FLOOR_SPINNER_BASE_COMBO+1, 3, 3, SPINNER_CSET, -1,-1, 0, 0, 0, 1, -1, true, 128);			
								Screen->DrawCombo(2, this->X, this->Y, FLOOR_SPINNER_REST_COMBO+1, 3, 3, SPINNER_CSET, -1,-1, this->X, this->Y, angle, 1, -1, true, 128);
								Game->PlaySound(FLOOR_SPINNER_SFX);
								Link->X = (this->X+16)+ 20 * Cos(angle);
								Link->Y = (this->Y+16)+ 20 * Sin(angle);
								Waitframe();
							}
							if(!HasSpun){
								Screen->D[perm]= 1;
								HasSpun = true;
							}
							else if(HasSpun){
								Screen->D[perm]= 0;
								HasSpun = false;
							}
							this->Data = FLOOR_SPINNER_REST_COMBO;
							SpinnerExit(DIR_RIGHT,this,Clockwise,HasSpun);
							Spinning = false;
						}
						//From right to bottom.
						else if(SpinDestination ==2){
							angle = 0;
							while(angle<90){
								this->Data= GH_INVISIBLE_COMBO;
								NoAction();
								angle= (angle+2)%360;
								Screen->DrawCombo(1, this->X, this->Y, FLOOR_SPINNER_BASE_COMBO+1, 3, 3, SPINNER_CSET, -1,-1, 0, 0, 0, 1, -1, true, 128);			
								Screen->DrawCombo(2, this->X, this->Y, FLOOR_SPINNER_REST_COMBO+1, 3, 3, SPINNER_CSET, -1,-1, this->X, this->Y, angle, 1, -1, true, 128);
								Game->PlaySound(FLOOR_SPINNER_SFX);
								Link->X = (this->X+16)+ 20 * Cos(angle);
								Link->Y = (this->Y+16)+ 20 * Sin(angle);
								Waitframe();
							}
							if(!HasSpun){
								Screen->D[perm]= 1;
								HasSpun = true;
							}
							else if(HasSpun){
								Screen->D[perm]= 0;
								HasSpun = false;
							}
							this->Data = FLOOR_SPINNER_REST_COMBO;
							SpinnerExit(DIR_DOWN,this,Clockwise,HasSpun);
							Spinning = false;
						}
						//From bottom to left.
						else if(SpinDestination ==3){
							angle = 90;
							while(angle<180){
								this->Data= GH_INVISIBLE_COMBO;
								NoAction();
								angle= (angle+2)%360;
								Screen->DrawCombo(1, this->X, this->Y, FLOOR_SPINNER_BASE_COMBO+1, 3, 3, SPINNER_CSET, -1,-1, 0, 0, 0, 1, -1, true, 128);			
								Screen->DrawCombo(2, this->X, this->Y, FLOOR_SPINNER_REST_COMBO+1, 3, 3, SPINNER_CSET, -1,-1, this->X, this->Y, angle, 1, -1, true, 128);
								Game->PlaySound(FLOOR_SPINNER_SFX);
								Link->X = (this->X+16)+ 20 * Cos(angle);
								Link->Y = (this->Y+16)+ 20 * Sin(angle);
								Waitframe();
							}
							if(!HasSpun){
								Screen->D[perm]= 1;
								HasSpun = true;
							}
							else if(HasSpun){
								Screen->D[perm]= 0;
								HasSpun = false;
							}
							this->Data = FLOOR_SPINNER_REST_COMBO;
							SpinnerExit(DIR_LEFT,this,Clockwise,HasSpun);
							Spinning = false;
						}
					}
					//Return to a clockwise spinner that has spun, or first visit to a counterclockwise spinner.
					else if((Clockwise && HasSpun)||(!Clockwise && !HasSpun)){
						//From right to top.
						if(SpinDestination ==0){
							angle = 360;
							while(angle>270){
								this->Data= GH_INVISIBLE_COMBO;
								NoAction();
								angle= (angle-2)%360;
								Screen->DrawCombo(1, this->X, this->Y, FLOOR_SPINNER_BASE_COMBO, 3, 3, SPINNER_CSET, -1,-1, 0, 0, 0, 1, -1, true, 128);			
								Screen->DrawCombo(2, this->X, this->Y, FLOOR_SPINNER_REST_COMBO, 3, 3, SPINNER_CSET, -1,-1, this->X, this->Y, angle, 1, -1, true, 128);
								Game->PlaySound(FLOOR_SPINNER_SFX);
								Link->X = (this->X+16)+ 20 * Cos(angle);
								Link->Y = (this->Y+16)+ 20 * Sin(angle);
								Waitframe();
							}
							if(!HasSpun){
								Screen->D[perm]= 1;
								HasSpun = true;
							}
							else if(HasSpun){
								Screen->D[perm]= 0;
								HasSpun = false;
							}
							this->Data = FLOOR_SPINNER_REST_COMBO+1;
							SpinnerExit(DIR_UP,this,Clockwise,HasSpun);
							Spinning = false;
						}
						//From bottom to right.
						else if(SpinDestination ==1){
							angle = 90;
							while(angle>0){
								this->Data= GH_INVISIBLE_COMBO;
								NoAction();
								angle= (angle-2)%360;
								Screen->DrawCombo(1, this->X, this->Y, FLOOR_SPINNER_BASE_COMBO, 3, 3, SPINNER_CSET, -1,-1, 0, 0, 0, 1, -1, true, 128);			
								Screen->DrawCombo(2, this->X, this->Y, FLOOR_SPINNER_REST_COMBO, 3, 3, SPINNER_CSET, -1,-1, this->X, this->Y, angle, 1, -1, true, 128);
								Game->PlaySound(FLOOR_SPINNER_SFX);
								Link->X = (this->X+16)+ 20 * Cos(angle);
								Link->Y = (this->Y+16)+ 20 * Sin(angle);
								Waitframe();
							}
							if(!HasSpun){
								Screen->D[perm]= 1;
								HasSpun = true;
							}
							else if(HasSpun){
								Screen->D[perm]= 0;
								HasSpun = false;
							}
							this->Data = FLOOR_SPINNER_REST_COMBO+1;
							SpinnerExit(DIR_RIGHT,this,Clockwise,HasSpun);
							Spinning = false;
						}
						//From top to left. 
						else if(SpinDestination ==2){
							angle = 270;
							while(angle>180){
								this->Data= GH_INVISIBLE_COMBO;
								NoAction();
								angle= (angle-2)%360;
								Screen->DrawCombo(1, this->X, this->Y, FLOOR_SPINNER_BASE_COMBO, 3, 3, SPINNER_CSET, -1,-1, 0, 0, 0, 1, -1, true, 128);			
								Screen->DrawCombo(2, this->X, this->Y, FLOOR_SPINNER_REST_COMBO, 3, 3, SPINNER_CSET, -1,-1, this->X, this->Y, angle, 1, -1, true, 128);
								Game->PlaySound(FLOOR_SPINNER_SFX);
								Link->X = (this->X+16)+ 20 * Cos(angle);
								Link->Y = (this->Y+16)+ 20 * Sin(angle);
								Waitframe();
							}
							if(!HasSpun){
								Screen->D[perm]= 1;
								HasSpun = true;
							}
							else if(HasSpun){
								Screen->D[perm]= 0;
								HasSpun = false;
							}
							this->Data = FLOOR_SPINNER_REST_COMBO+1;
							SpinnerExit(DIR_LEFT,this,Clockwise,HasSpun);
							Spinning = false;
						}
						//From left to bottom
						else if(SpinDestination ==3){
							angle = 180;
							while(angle>90){
								this->Data= GH_INVISIBLE_COMBO;
								NoAction();
								angle= (angle-2)%360;
								Screen->DrawCombo(1, this->X, this->Y, FLOOR_SPINNER_BASE_COMBO, 3, 3, SPINNER_CSET, -1,-1, 0, 0, 0, 1, -1, true, 128);			
								Screen->DrawCombo(2, this->X, this->Y, FLOOR_SPINNER_REST_COMBO, 3, 3, SPINNER_CSET, -1,-1, this->X, this->Y, angle, 1, -1, true, 128);
								Game->PlaySound(FLOOR_SPINNER_SFX);
								Link->X = (this->X+16)+ 20 * Cos(angle);
								Link->Y = (this->Y+16)+ 20 * Sin(angle);
								Waitframe();
							}
							if(!HasSpun){
								Screen->D[perm]= 1;
								HasSpun = true;
							}
							else if(HasSpun){
								Screen->D[perm]= 0;
								HasSpun = false;
							}
							this->Data = FLOOR_SPINNER_REST_COMBO+1;
							SpinnerExit(DIR_DOWN,this,Clockwise,HasSpun);
							Spinning = false;
						}
					}
				}
				Waitframe();
				if((Clockwise && !HasSpun)||(!Clockwise && HasSpun))
					Screen->DrawCombo(1, this->X, this->Y, FLOOR_SPINNER_BASE_COMBO, 3, 3, SPINNER_CSET, -1,-1, 0, 0, 0, 1, -1, true, 128);							
				else if((Clockwise && HasSpun)||(!Clockwise && !HasSpun))
					Screen->DrawCombo(1, this->X, this->Y, FLOOR_SPINNER_BASE_COMBO+1, 3, 3, SPINNER_CSET, -1,-1, 0, 0, 0, 1, -1, true, 128);							
			}
		}
		//Handles exiting spinner.
		//Based on direction, makes Link walk that way for 10 frames and be unable to do anything else.
		void SpinnerExit (int dir,ffc this, bool Clockwise, bool HasSpun){
			if (dir == DIR_UP){
				for (int i = 0; i < 10; i++){
					NoAction();
					Link->InputUp = true;
					Waitframe();
					if((Clockwise && !HasSpun)||(!Clockwise && HasSpun))
						Screen->DrawCombo(1, this->X, this->Y, FLOOR_SPINNER_BASE_COMBO, 3, 3, SPINNER_CSET, -1,-1, 0, 0, 0, 1, -1, true, 128);							
					else if((Clockwise && HasSpun)||(!Clockwise && !HasSpun))
						Screen->DrawCombo(1, this->X, this->Y, FLOOR_SPINNER_BASE_COMBO+1, 3, 3, SPINNER_CSET, -1,-1, 0, 0, 0, 1, -1, true, 128);			
				}
			}
			else if (dir == DIR_DOWN){
				for (int i = 0; i < 10; i++){
					NoAction();
					Link->InputDown = true;
					Waitframe();
					if((Clockwise && !HasSpun)||(!Clockwise && HasSpun))
						Screen->DrawCombo(1, this->X, this->Y, FLOOR_SPINNER_BASE_COMBO, 3, 3, SPINNER_CSET, -1,-1, 0, 0, 0, 1, -1, true, 128);							
					else if((Clockwise && HasSpun)||(!Clockwise && !HasSpun))
						Screen->DrawCombo(1, this->X, this->Y, FLOOR_SPINNER_BASE_COMBO+1, 3, 3, SPINNER_CSET, -1,-1, 0, 0, 0, 1, -1, true, 128);				
				}
			}
			else if (dir == DIR_LEFT){
				for (int i = 0; i < 10; i++){
					NoAction();
					Link->InputLeft = true;
					Waitframe();
					if((Clockwise && !HasSpun)||(!Clockwise && HasSpun))
						Screen->DrawCombo(1, this->X, this->Y, FLOOR_SPINNER_BASE_COMBO, 3, 3, SPINNER_CSET, -1,-1, 0, 0, 0, 1, -1, true, 128);							
					else if((Clockwise && HasSpun)||(!Clockwise && !HasSpun))
						Screen->DrawCombo(1, this->X, this->Y, FLOOR_SPINNER_BASE_COMBO+1, 3, 3, SPINNER_CSET, -1,-1, 0, 0, 0, 1, -1, true, 128);			
				}
			}
			else if (dir == DIR_RIGHT){
				for (int i = 0; i < 10; i++){
					NoAction();
					Link->InputRight = true;
					Waitframe();
					if((Clockwise && !HasSpun)||(!Clockwise && HasSpun))
						Screen->DrawCombo(1, this->X, this->Y, FLOOR_SPINNER_BASE_COMBO, 3, 3, SPINNER_CSET, -1,-1, 0, 0, 0, 1, -1, true, 128);							
					else if((Clockwise && HasSpun)||(!Clockwise && !HasSpun))
						Screen->DrawCombo(1, this->X, this->Y, FLOOR_SPINNER_BASE_COMBO+1, 3, 3, SPINNER_CSET, -1,-1, 0, 0, 0, 1, -1, true, 128);			
				}
			}
		}
}