import "std.zh"

const int COMPASS_SFX = 79; //Set this to the SFX id you want to hear when you have the compass.
const int COMPASS_VISUAL_CMB = 48; //The Combo shown when the compass beeps.
const int COMPASS_VISUAL_CSET = 7; //The CSet of the combo. 
 
ffc script CompassBeep{
	void run(int item, int specialitem){
		if(GetLevelItem(LI_COMPASS)){
			if(!Screen->State[ST_ITEM] && (item>0)){
				Game->PlaySound(COMPASS_SFX);
				for(int i = 120; i>0; i--){
					Screen->FastCombo(7,0,0, COMPASS_VISUAL_CMB,COMPASS_VISUAL_CSET,OP_OPAQUE);
					Waitframe();
				}
			}
			else if(!Screen->State[ST_SPECIALITEM] && (specialitem>0)){
				Game->PlaySound(COMPASS_SFX);
				for(int i = 120; i>0; i--){
					Screen->FastCombo(7,0,0, COMPASS_VISUAL_CMB,COMPASS_VISUAL_CSET,OP_OPAQUE);
					Waitframe();
				}
			}
		}
	}
}