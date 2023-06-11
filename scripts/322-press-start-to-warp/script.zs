ffc script PressStartToWarp{
	void run(int InitDelay, int StartSFX, int StartDelay, int AutoWarpACombo, int DisableInput){
		for (int i = 0; i < InitDelay; i++) {
			if ( DisableInput == 1 ) NoAction();
			NoStart();
			Waitframe();
		}
		while(true){
			if ( Link->PressStart ) {
				Game->PlaySound(StartSFX);
				for (int i = 0; i < StartDelay; i++) {
					if ( DisableInput == 1 ) NoAction();
					NoStart();
					Waitframe();
				}
				NoAction(); NoStart();
				this->Data = AutoWarpACombo;
				Quit();
			}
			if ( DisableInput == 1 ) NoAction();
			NoStart();
			Waitframe();
		}
	}
	void NoStart(){
		Link->PressStart = false;
		Link->InputStart = false;
	}
}