//D0: # of NPC's already on screen. Before this ffc. Include other FireArm FFC's. 
//(<Parts(D4)> * <# of arms(D2)>)
//D1: # of the spinner. Start at 1.
//D2: # of arms to give the trap. (1-4).
//D3: Speed at which it circles, in degrees. Negative # will result in a Counter Clockwise spin.
//D4: Parts to the Arm. Larger # will give a bigger spinner.


const int FireBall = 177; //Sprite to use.
const int Spacer = 8; //Spacing between each Sprite.

ffc script FireArm{
	void run(int CurNPC, int Wait, int Arms, float speed, int Parts){
		
		int Center_X = this->X;
		int Center_Y = this->Y;
		int RealNPC;
		int radius;
		float angle;
		bool first = true;
		
		//Create npc
		npc tempNPC;
		
		Waitframes(Wait);
		
		for(int a = 0; a < (Arms * Parts); a++){
			tempNPC = Screen->CreateNPC(FireBall);
			if(a <= (Parts - 1)){
				tempNPC->X = Center_X;
				tempNPC->Y = Center_Y - (Spacer * ((a%Parts)+1) + Spacer);
			}//end if
			else if(a <= (Parts * 2 - 1)){
				tempNPC->X = Center_X;
				tempNPC->Y = Center_Y + (Spacer * ((a%Parts)+1) + Spacer);
			}//end else if
			else if(a <= (Parts * 3 - 1)){
				tempNPC->X = Center_X + (Spacer * ((a%Parts)+1) + Spacer);
				tempNPC->Y = Center_Y;
			}//end else if
			else{
				tempNPC->X = Center_X - (Spacer * ((a%Parts)+1) + Spacer);
				tempNPC->Y = Center_Y;
			}//end else
		}//end if
		
		while(true){
		
			for(int b = 1; b < Screen->NumNPCs(); b++){
				tempNPC = Screen->LoadNPC(b);
				if(tempNPC->ID == FireBall){
					RealNPC = b + CurNPC;
					break;
				}//end if
			}//end for
		
			for (int a = 0; a < (Arms * Parts); a++){
				tempNPC = Screen->LoadNPC(a + RealNPC);
				angle = tempNPC->Misc[0];
				tempNPC->HitWidth = 8;
				tempNPC->HitHeight = 8;
				tempNPC->HitXOffset = 4;
				tempNPC->HitYOffset = 4;
				
				if(first){
					//Find Radius
					if(a <= (Parts * 2 - 1)) radius = Center_Y - tempNPC->Y;
					else radius = Center_X - tempNPC->X;
				
					//Change Radius to positive
					if(radius < 0) radius *= -1;
				
					//Save Radius
					tempNPC->Misc[1] = radius;
				}//end if
				else radius = tempNPC->Misc[1];
				
				//Find start angle
				if(first){
					if(a <= (Parts - 1)) angle = 0;
					else if(a <= (Parts * 2 - 1)) angle = 180;
					else if(a <= (Parts * 3 - 1)) angle = 90;
					else angle = 270;
				}//end if
				
				angle += speed;
				if(angle < -360) angle += 360;
				else if(angle > 360) angle -= 360;
				tempNPC->X = Center_X + radius * Cos(angle);
				tempNPC->Y = Center_Y + radius * Sin(angle);
				tempNPC->Misc[0] = angle;
			}//end for
		
			first = false;
			Waitframe();
		}//end while
		
	}//end run
}//end ffc