//LinkLocator
//Draws a combo one tile above Link for a short period.
//The fourth argument in FastCombo is the combo to draw, the next number is the CSet, and the last is its opacity (128 in this case for full visibility.)

const int LINKL_COMBO = 1; //Change this to the number of the combo you want to use
const int LINKL_CSET = 7; //This is the CSet to use

ffc script LinkLocator{
	void run(){
	int ArrowTimer = 120; //How long to draw the combo in frames. 120 for two seconds.
		while(ArrowTimer >> 0){
			int AboveLinkX = Link->X;
			int AboveLinkY = Link->Y-16; //If you want the combo to be drawn on top of Link instead, remove the "-16" here
			Screen->FastCombo(6, AboveLinkX, AboveLinkY, LINKL_COMBO, LINKL_CSET, 128);
			ArrowTimer--;
			Waitframe();
			}
		}
	}