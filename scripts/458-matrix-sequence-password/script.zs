const int MATRIX_SEQUENCE_DEFAULT_COOLDOWN = 20;//Default cooldown between switch hits.
const int CF_MATRIX_SEQUENCE_PIECE = 98;//Combo flag to define switches that are part of the puzzle.
const int CT_MATRIX_SEQUENCE_PIECE = 142;//Combo type to define switches that are part of the puzzle (alternate setup).

const int SFX_MATRIX_SEQUENCE_PRESS = 16;//Sound to play, when player hits correct switch.
const int SFX_MATRIX_SEQUENCE_ERROR = 32;//Sound to play, when player hits wrong switch.

//Matrix Sequence Password.
//Hit triggers in specific order -> secret.
//Place invisible FFC anywhere in the screen.
// - There are two ways to build switch puzzle:
//    D7 = 0 - Flag all switches with CF_MATRIX_SEQUENCE_PIECE
//
//    D7 > 0 - Use CT_MATRIX_SEQUENCE_PIECE combo type for switches.
//    Recommended you use Trigger->Self only flags for triggers, but Trigger->Self only must be inherent flag and weapon trigger flag must be a placed one.
//    And each trigger cannot be used more than once in the password. Damn flag disappearance on hit.
// 
//    Any way to change trigger combo counts as hit and is checked by script, whether it`s a correct or wrong hit, according to password.   
// D0 to D5 - Switch order password. Mouse over switch combo in ZQuest editor and read number labeled as Pos:###
//  D0 #####.____ - #1, ____.#### - #2
//  D1 #####.____ - #3, ____.#### - #4
//   And so on, Max 12 entries in password
// D6 - #####.____ - #1, Use custon cooldown, in frames, between switch hits, instead of default one.
//      ____.#### - #2, screen layer to define puzzle solution. Use layer, other then 0, if you don`t want changes to layer 0.
// D7 - 1->Flag for alternate setup process,  +2->No sound, +4 - allow changing combos by standing on them and press EX1, +8 - rotation animation

ffc script MatrixSequencePassword{
	void run(int order1, int order2, int order3, int order4, int order5, int order6, int cd, int flags){
		int sol[12];
		int s[6]={order1, order2, order3, order4, order5, order6};
		for (int i=0;i<6;i++){
			int j=2*i;
			sol[j]=GetHighFloat(s[i]);
			sol[j+1]=GetLowFloat(s[i]);
		}
		int list[16];
		int arrl = 0;
		int layer = GetLowFloat(cd);
		cd=GetHighFloat(cd);
		
		if ((flags&1)>0){
			for (int i=0;i<176;i++){
				if (Screen->ComboT[i]==CT_MATRIX_SEQUENCE_PIECE || GetLayerComboT(layer, i)==CF_MATRIX_SEQUENCE_PIECE || GetLayerComboT(layer, i)==CF_MATRIX_SEQUENCE_PIECE){
					list[arrl]=i;
					arrl++;
					if (arrl>=16) break;
				}
			}
		}
		else{
			for (int i=0;i<176;i++){
				if (ComboFI(i, CF_MATRIX_SEQUENCE_PIECE) || GetLayerComboF(layer, i)==CF_MATRIX_SEQUENCE_PIECE|| GetLayerComboI(layer, i)==CF_MATRIX_SEQUENCE_PIECE){
					list[arrl]=i;
					arrl++;
					if (arrl>=16) break;
				}
			}
		}
		if (arrl<16){
			while (arrl<16){
				list[arrl]=-1;
				arrl++;
			}
		}
		int arrcmb[16];
		for (int i=0;i<16;i++){
			arrl=list[i];
			if (arrl<0) continue;
			arrcmb[i] = Screen->ComboD[arrl];
			//race(arrcmb[i]);
		}
		int cooldown=0;
		int pos =0;
		while(true){
			if (cooldown==0){
				if (Link->PressEx1 && (flags&4)>0){//Process Auto-input
					int cmb = ComboAt(CenterLinkX(), CenterLinkY());
					if (Screen->ComboT[cmb]==CT_MATRIX_SEQUENCE_PIECE || ComboFI(cmb, CF_MATRIX_SEQUENCE_PIECE)){
						Screen->ComboD[cmb]++;
						if ((flags&8)>0){
							int origcmb = Screen->ComboD[cmb]-1;
							Screen->ComboD[cmb]=FFCS_INVISIBLE_COMBO;
							for (int i=0; i<15; i++){
								Screen->DrawCombo(1, ComboX(cmb), ComboY(cmb), origcmb, 1, 1, Screen->ComboC[cmb], -1, -1, ComboX(cmb),ComboY(cmb), 6*i, 1, 0, false, OP_OPAQUE);
								Waitframe();
							}
							Screen->ComboD[cmb]=origcmb+1;
						}
					}
				}
				int hit=-1;
				for (int i=0; i<16;i++){
					arrl=list[i];
					if (arrl<0)continue;
					if (Screen->ComboD[arrl]!=arrcmb[i]){
						hit=i;
						break;
					}
				}
				if (hit>=0){
					if (list[hit]==sol[pos]){
					if ((flags&2)==0)Game->PlaySound(SFX_MATRIX_SEQUENCE_PRESS);
						pos++;
						if (sol[pos]<=0){
							Game->PlaySound(SFX_SECRET);
							Screen->TriggerSecrets();
							Screen->State[ST_SECRET]=true;
						}
					}
					else{
						if ((flags&2)==0)Game->PlaySound(SFX_MATRIX_SEQUENCE_ERROR);
						pos=0;
					}
					if (cd==0) cooldown=MATRIX_SEQUENCE_DEFAULT_COOLDOWN;
					else cooldown=cd;
				}
			}
			else{
				cooldown--;
				if (cooldown==0){
					for (int i=0;i<16;i++){
						arrl=list[i];
						if (arrl<0) continue;
						arrcmb[i] = Screen->ComboD[arrl];
					}
				}
			}
			//Screen->Rectangle(2,ComboX(sol[pos]),ComboY(sol[pos]),ComboX(sol[pos])+15,ComboY(sol[pos])+15,1,-1,0,0,0,false,OP_OPAQUE);
			Waitframe();
		}
	}
}