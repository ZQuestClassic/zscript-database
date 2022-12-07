//F6 script start----

//to change colors, modify the 2 characters after the "0x". use the table under Quest->Graphics->Misc Colors for reference.
const int BetterF6_ColorBG = 0x0F; //background color (usually black)
const int BetterF6_ColorText1 = 0x01; //unselected text color
const int BetterF6_ColorText2 = 0x14; //selected text color
const int BetterF6_Font = FONT_Z1;
const int BetterF6_SFXChange = 5; //sfx for changing selection
const int BetterF6_SFXConfirm = 0; //sfx for confirming selection
const bool BetterF6_NoSubscreenDisable = false; //wether you want F6 disabled in "No Subscreen" screens. set to true or false.
const int BetterF6_ScreenFlagDisable = 0; //which number of General Use (Script) screen data flag disables F6. 0 for none of them.

global script BetterF6{
	void run(){
		//force "skip continue screen" QR
		Game->FFRules[qr_NOCONTINUE] = true;
		//conditional F6 disable on No Subscreen screens
		if ( BetterF6_NoSubscreenDisable && ScreenFlag(SF_VIEW, SFV_NOSUBSCREEN) > 1 )
			Quit();
		//conditional F6 disable with General Use (Script) screen data flag
		if ( BetterF6_ScreenFlagDisable != 0 && ScreenFlag(SF_MISC, SFM_SCRIPT1+BetterF6_ScreenFlagDisable-1) > 1 )
			Quit();
		BetterF6Active(true);
	}
}

link script onDeath{
	void run(){
		//force "onDeath runs after death anim" QR
		if ( !Game->FFRules[qr_ONDEATH_RUNS_AFTER_DEATH_ANIM] ) {
			Game->FFRules[qr_ONDEATH_RUNS_AFTER_DEATH_ANIM] = true;
			Quit();
		}
		BetterF6Active(false);
	}
}

void BetterF6Active(bool CanCancel) {
	bool Options[10];
	
	//declare list, and strings
	enum {
		Option_Continue,
		Option_SaveAndContinue,
		Option_SaveAndQuit,
		Option_Quit,
		Option_Cancel
	};
	const int String0[] = "Continue";
	const int String1[] = "Save & Continue";
	const int String2[] = "Save & Quit";
	const int String3[] = "Quit";
	const int String4[] = "Cancel";
	const int String5[] = "";
	const int String6[] = "";
	const int String7[] = "";
	const int String8[] = "";
	const int String9[] = "";
	
	//put string pointers into an array
	int str[10];
	str[0] = String0;
	str[1] = String1;
	str[2] = String2;
	str[3] = String3;
	str[4] = String4;
	str[5] = String5;
	str[6] = String6;
	str[7] = String7;
	str[8] = String8;
	str[9] = String9;
	
	//declare which options should give confirmation prompt
	bool Confirmation[10];
	Confirmation[Option_Quit] = true;
	
	//determine which options to show
	Options[Option_Continue] = true;
	if ( !Game->FFRules[qr_NOSAVE] ) {
		Options[Option_SaveAndContinue] = true;
		Options[Option_SaveAndQuit] = true;
	}
	Options[Option_Quit] = true;
	if ( CanCancel )
		Options[Option_Cancel] = true;
	
	//create the actual options array and fill it
	int ScreenOptions[10];
	int NumOptions;
	for(int i = 0; i < 10; ++i){
		if ( Options[i] ) {
			ScreenOptions[NumOptions] = i;
			NumOptions ++;
		}
	}
	
	//determine Y center
	int YCenter = 60;
	if ( ScreenFlag(SF_VIEW, SFV_NOSUBSCREEN) > 1 && ScreenFlag(SF_VIEW, SFV_NOOFFSET) == 0 )
		YCenter += 28;
	
	//calculate Y positions
	int YPositions[10];
	const int FontHeight = Text->FontHeight(BetterF6_Font);
	const int GapSize = FontHeight * 1.25;
	for(int i = 0; i < NumOptions; ++i){
		YPositions[i] = YCenter - FontHeight/2 - (NumOptions*FontHeight + (NumOptions-1)*GapSize) / 2 + i*FontHeight + i*GapSize;
	}
	
	int SelectedOption;
	int Chosen;
	bool Blinking;
	int BlinkingFrame;
	while(true){
		Screen->Rectangle(0, 0, -56, 256, 176, BetterF6_ColorBG, 1, 0, 0, 0, true, OP_OPAQUE);
		
		//change selection
		if ( NumOptions > 0 && Chosen == 0 ) {
			if ( Link->PressUp ) {
				Game->PlaySound(BetterF6_SFXChange);
				SelectedOption --;
				if ( SelectedOption < 0 )
					SelectedOption = NumOptions-1;
			}
			if ( Link->PressDown ) {
				Game->PlaySound(BetterF6_SFXChange);
				SelectedOption ++;
				if ( SelectedOption > NumOptions-1 )
					SelectedOption = 0;
			}
		}
		
		//make selection
		if ( Chosen == 0 && Link->PressStart ) {
			Game->PlaySound(BetterF6_SFXConfirm);
			Chosen = 1;
		}
		if ( Chosen > 0 ) {
			if ( Chosen > 50 ) {
				if ( Confirmation[ScreenOptions[SelectedOption]] ) {
					int strpass[1000];
					strcat(strpass, str[ScreenOptions[SelectedOption]]);
					if ( F6Confirmation(strpass) )
						break;
				}
				else
					break;
				Chosen = 0;
				Blinking = false;
				BlinkingFrame = 0;
			}
			else
				Chosen ++;
		}
		
		//draw strings
		for(int i = 0; i < NumOptions; ++i){
			int color = BetterF6_ColorText1;
			if ( SelectedOption == i )
				color = BetterF6_ColorText2;
			else if ( Chosen > 0 )
				continue;
			
			if ( Chosen > 0 ) {
				if ( BlinkingFrame > 4 ) {
					BlinkingFrame = 0;
					Blinking = !Blinking;
				}
				else
					BlinkingFrame ++;
				if ( !Blinking )
					color = BetterF6_ColorText1;
				else
					color = BetterF6_ColorText2;
			}
			
			Screen->DrawString(0, 128, YPositions[i], BetterF6_Font, color, -1, TF_CENTERED, str[ScreenOptions[i]], OP_OPAQUE);
		}
		Waitframe();
	}
	
	//force "skip continue screen" QR
	Game->FFRules[qr_NOCONTINUE] = true;
	
	//now what to do?
	if ( ScreenOptions[SelectedOption] == Option_Continue ) {
		Game->Continue();
	}
	if ( ScreenOptions[SelectedOption] == Option_SaveAndContinue ) {
		Game->SaveAndContinue();
	}
	if ( ScreenOptions[SelectedOption] == Option_SaveAndQuit ) {
		Game->SaveAndQuit();
	}
	if ( ScreenOptions[SelectedOption] == Option_Quit ) {
		Game->End();
	}
}

bool F6Confirmation(int str){
	//determine Y center
	int YCenter = 60;
	if ( ScreenFlag(SF_VIEW, SFV_NOSUBSCREEN) > 1 && ScreenFlag(SF_VIEW, SFV_NOOFFSET) == 0 )
		YCenter += 28;
	
	const int FontHeight = Text->FontHeight(BetterF6_Font);
	bool SelectedYes;
	int Chosen;
	bool Blinking;
	int BlinkingFrame;
	while(true){
		Screen->Rectangle(0, 0, -56, 256, 176, BetterF6_ColorBG, 1, 0, 0, 0, true, OP_OPAQUE);
		
		//change selection
		if ( Chosen == 0 ) {
			if ( Link->PressLeft || Link->PressRight ) {
				Game->PlaySound(BetterF6_SFXChange);
				SelectedYes = !SelectedYes;
			}
		}
		
		//make selection
		if ( Chosen == 0 && Link->PressStart ) {
			Game->PlaySound(BetterF6_SFXConfirm);
			Chosen = 1;
		}
		if ( Chosen > 0 ) {
			if ( Chosen > 25 )
				break;
			Chosen ++;
		}
		
		//draw confirmation
		int Confirmation[1000];
		strcat(Confirmation, "Confirm ");
		strcat(Confirmation, str);
		strcat(Confirmation, "?");
		Screen->DrawString(0, 128, YCenter-12 - FontHeight/2, BetterF6_Font, BetterF6_ColorText1, -1, TF_CENTERED, Confirmation, OP_OPAQUE);
		
		//draw yes no
		for(int i = 0; i < 2; ++i){
			int color = BetterF6_ColorText1;
			if ( i == 0 && SelectedYes || i == 1 && !SelectedYes )
				color = BetterF6_ColorText2;
			else if ( Chosen > 0 )
				continue;
			
			if ( Chosen > 0 ) {
				if ( BlinkingFrame > 4 ) {
					BlinkingFrame = 0;
					Blinking = !Blinking;
				}
				else
					BlinkingFrame ++;
				if ( !Blinking )
					color = BetterF6_ColorText1;
				else
					color = BetterF6_ColorText2;
			}
			
			if ( i == 0 )
				Screen->DrawString(0, 128-24, YCenter+12 - FontHeight/2, BetterF6_Font, color, -1, TF_CENTERED, "Yes", OP_OPAQUE);
			else
				Screen->DrawString(0, 128+24, YCenter+12 - FontHeight/2, BetterF6_Font, color, -1, TF_CENTERED, "No", OP_OPAQUE);
		}
		Waitframe();
	}
	return SelectedYes;
}

//----F6 script end