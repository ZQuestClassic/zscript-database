//Combo, cset for the save points
const int CMB_SAVEPROMPT = 992;
const int CS_SAVEPROMPT = 7;

combodata script SaveCombo{
	void run(){
		while(true){
			if(Abs(Link->X-this->X)<=8&&Link->Y>=this->Y&&Link->Y<=this->Y+8&&Link->Dir==DIR_UP){
				Screen->FastCombo(6, this->X, this->Y-16, CMB_SAVEPROMPT, CS_SAVEPROMPT, 128);
				if(Link->PressA){
					if(Game->ShowSaveScreen()){
						Game->ContinueDMap = Game->GetCurDMap();
						Game->ContinueScreen = Game->GetCurScreen();
						Game->LastEntranceDMap = Game->GetCurDMap();
						Game->LastEntranceScreen = Game->GetCurScreen();
					}
				}
			}
			Waitframe();
		}
	}
}