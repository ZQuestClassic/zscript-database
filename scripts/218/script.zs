const int PASSWORD_STRING_ALLOW_INPUT_WITH_A_BUTTON = 1; //Set to anything > 0 to allow Link to input password by standing on combos and pressing A. 
//Uses combo type of first digit in password lock.

//Place FFC at 1st digit combo of string
//D0 - D7 Solution offsets for combos in combo table. 

ffc script PasswordComboString{
	void run(int digit1, int digit2,int digit3,int digit4,int digit5,int digit6,int digit7,int digit8){
		int solution[9] = {digit1,digit2,digit3,digit4,digit5,digit6,digit7,digit8,-1};//Arrange solution array
		int InitCombo = ComboAt(CenterX(this), CenterY(this));// Get position of password lock
		int digit0 = Screen->ComboD[InitCombo]; //Get first element in sequence of digits
		if (Screen->State[ST_SECRET]==true){//Input password if already unlocked.
			for (int i=0; i<9; i++){
				if (solution[i]>=0)	Screen->ComboD[InitCombo+i]=digit0+solution[i];
				else break;
			}
			Quit();
		}
		while (Screen->State[ST_SECRET]==false){
			if (PASSWORD_STRING_ALLOW_INPUT_WITH_A_BUTTON>0)PasswordInput(Screen->ComboT[InitCombo]);
			for (int i=0; i<=8; i++){
				if (solution[i]<0){//Correct password entered
					Game->PlaySound(SFX_SECRET);
					Screen->TriggerSecrets();
					Screen->State[ST_SECRET]=true;
					Quit();
				}
				if (Screen->ComboD[InitCombo+i]!=digit0+solution[i])break;//Access Denied!
				
			}
			Waitframe();
		}
	}
}

// Function used by script to handle password input.
void PasswordInput(int ct){
	int cmb = ComboAt(CenterLinkX(), CenterLinkY());
		if (Screen->ComboT[cmb]==ct){
			if (Link->PressA || Link->PressEx1){
				Game->PlaySound(SFX_HAMMER);
				Screen->ComboD[cmb]++;
			}
		}
	}