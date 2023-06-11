global script slot_2{
	void run(){

		int reqItem = 129; //Item that makes the FFC follower follow you
		int ffcNumber = 32; //The number of the FFC used.  This script will "hijack" this one, so don't use it for anything else on screens when you expect the player to have a follower.
		int firstFollowerCombo = 23568; //combo of the first combo.  In order, the concecutive combos must be "still up", "still down", "still left", "still right", "moving up", "moving down", "moving left", "moving right".
		int csetOfFollower = 3;
		bool firstCheck = false; //leave this alone
		ffc follower;

		int pastX;
		int currentX;
		int followerX[13];

		int pastY;
		int currentY;
		int followerY[13];

		int index;

		while(true){

			if(Link->Item[reqItem] == true){
				if(Link->Action != LA_SCROLLING && firstCheck == false){
					follower = Screen->LoadFFC(ffcNumber);
					follower->Data = firstFollowerCombo;
					follower->CSet = csetOfFollower;

					pastX = Link->X;
					follower->X = Link->X;
					pastY = Link->Y;
					follower->Y = Link->Y;

					for ( int i = 0; i < 13; i++ ){
						followerX[i] = Link->X;
						followerY[i] = Link->Y;
					}

					firstCheck = true;
				}
				if(Link->Action != LA_SCROLLING){
					if((Link->InputUp || Link->InputDown || Link->InputRight || Link->InputLeft)&&(!(Link->InputA || Link->InputB))){
						pastX = follower->X;
						follower->X = followerX[0];
						for(index=0; index<12; index++){
							followerX[index] = followerX[index + 1];
						}
						followerX[12] = Link->X;

						pastY = follower->Y;
						follower->Y = followerY[0];
						for(index=0; index<12; index++){
							followerY[index] = followerY[index + 1];
						}
						followerY[12] = Link->Y;
					}

					if(follower->Y > pastY){
						follower->Data = firstFollowerCombo + 5;
					}
					else if(follower->Y < pastY){
						follower->Data = firstFollowerCombo + 4;
					}
					else if(follower->X > pastX){
						follower->Data = firstFollowerCombo + 7;
					}
					else if(follower->X < pastX){
						follower->Data = firstFollowerCombo + 6;
					}
					if(!(Link->InputUp || Link->InputDown || Link->InputRight || Link->InputLeft)){
						if((follower->Data == (firstFollowerCombo + 4))||(follower->Data == (firstFollowerCombo + 5))||(follower->Data == (firstFollowerCombo + 6))||(follower->Data == (firstFollowerCombo + 7))){
							follower->Data = follower->Data - 4;
						}
						else if((follower->Data == (firstFollowerCombo + 3))||(follower->Data == (firstFollowerCombo + 2))||(follower->Data == (firstFollowerCombo + 1))||(follower->Data == (firstFollowerCombo))){
							
						}
						else{
							follower->Data = firstFollowerCombo;
						}
					}
				}
				if(Link->Action == LA_SCROLLING){
					firstCheck = false;
				}
			}

			Waitframe();

		}
	}
}