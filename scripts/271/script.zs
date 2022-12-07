import "std.zh"

//Better Stone of Agony
const int BetterAgony_ID = 123; //item ID
const int BetterAgony_DetectionRadius = 32; //the secret detection radius in pixels
const int BetterAgony_DetectionFlag = 98; //script flag number to use for secret detection
const int BetterAgony_Vibrate = 1; //wether or not it makes link vibrate. 0 = no, 1 = yes
const int BetterAgony_SFX = 61; //sound effect to play. leave as 0 if unneeded
const int BetterAgony_SFXRepeatRate = 30; //how fast to repeat the sound effect, in frames
const int BetterAgony_ComboID = 8; //combo to draw above links head as an indicator. leave as 0 if unneeded.
const int BetterAgony_ComboCSet = 7; //cset to use for the combo

global script Active{
	void run(){
		int BetterAgony_LastDMap = Game->GetCurDMap();
		int BetterAgony_LastScreen = Game->GetCurDMapScreen();
		while(true){
			if ( Game->GetCurDMap() != BetterAgony_LastDMap || Game->GetCurDMapScreen() != BetterAgony_LastScreen )
				Link->DrawYOffset = 0; //fix better stone of agony link draw offset
			BetterAgony_LastDMap = Game->GetCurDMap();
			BetterAgony_LastScreen = Game->GetCurDMapScreen();
			Waitframe();
		}
	}
}

//D0: How to detect secrets
//0 = Detect trigger flags
//1 = Detect the script flag
//2 = Detect both trigger flags and the script flag
//D1: Condition for detecting secrets
//0 = Always detect
//1 = Don't detect if permanent secrets are activated
ffc script BetterStoneOfAgony{
	void run(int type, int condition){
		bool SecretDetected;
		bool OtherFrame;
		int LinkVibration;
		bool LinkOffset;
		int SFXRepeat;
		while(true){
			while( !Link->Item[BetterAgony_ID] || (condition == 1 && Screen->State[ST_SECRET]) ) { //halt the script
				LinkVibration = 0;
				if ( LinkOffset )
					Link->DrawYOffset ++; //revert drawoffset
				LinkOffset = false;
				SFXRepeat = 0;
				Waitframe();
			}
			if ( OtherFrame ) { //only check every other frame to prevent slowdown
				SecretDetected = false;
				for(int i = 0; i <= 6; i++) { //for all layers
					if ( i == 0 || Screen->LayerMap(i) != -1 ) { //dont check unvalid layers
						for(int j = 0; j <= 175; j++) { //all combos
							if ( Distance(Link->X, Link->Y, ComboX(j), ComboY(j)) <= BetterAgony_DetectionRadius ) //check distance
								if ( (IsATriggerFlag(GetLayerComboF(i, j)) && type != 1)
								|| (GetLayerComboF(i, j) == BetterAgony_DetectionFlag && type != 0) ) //check flag
									SecretDetected = true;
						}
					}
				}
			}
			if ( OtherFrame )
				OtherFrame = false;
			else
				OtherFrame = true;
			if ( SecretDetected ) {
				if ( BetterAgony_Vibrate == 1 ) { //link vibrates using drawoffset
					if ( LinkVibration == 0 ) {
						Link->DrawYOffset --;
						LinkOffset = true;
					}
					if ( LinkVibration == 3 ) {
						Link->DrawYOffset ++;
						LinkOffset = false;
					}
					LinkVibration ++;
					if ( LinkVibration > 5 )
						LinkVibration = 0;
				}
				if ( BetterAgony_SFX != 0 ) { //repeatedly played sfx
					if ( SFXRepeat == 0 )
						Game->PlaySound(BetterAgony_SFX);
					SFXRepeat ++;
					if ( SFXRepeat > BetterAgony_SFXRepeatRate )
						SFXRepeat = 0;
				}
				if ( BetterAgony_ComboID != 0 ) //indicator combo drawn on layer 7 above link
					Screen->FastCombo(7, Link->X, Link->Y-16, BetterAgony_ComboID, BetterAgony_ComboCSet, OP_OPAQUE);
			}
			else { //secrets not detected
				LinkVibration = 0;
				if ( LinkOffset )
					Link->DrawYOffset ++; //revert drawoffset
				LinkOffset = false;
				SFXRepeat = 0;
			}
			Waitframe();
		}
	}
}

bool IsATriggerFlag(int f) {
	if ( (f >= 3 && f <= 6) || f == 11 || (f >= 68 && f <= 90) ) //trigger flags
		return true;
	else
		return false;
}