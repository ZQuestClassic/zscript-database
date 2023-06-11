const int CF_KEYBOARD_POS1 = 37;// String combo flags sequence. 
const int CF_KEYBOARD_POS2 = 38;
const int CF_KEYBOARD_POS3 = 39;
const int CF_KEYBOARD_POS4 = 40;
const int CF_KEYBOARD_POS5 = 41;
const int CF_KEYBOARD_POS6 = 42;
const int CF_KEYBOARD_POS7 = 43;
const int CF_KEYBOARD_POS8 = 44;
const int CF_KEYBOARD_POS9 = 45;
const int CF_KEYBOARD_POS10 = 46;
const int CF_KEYBOARD_POS11 = 47;
const int CF_KEYBOARD_POS12 = 48;
const int CF_KEYBOARD_POS13 = 49;
const int CF_KEYBOARD_POS14 = 50;
const int CF_KEYBOARD_POS15 = 51;
const int CF_KEYBOARD_POS16 = 52;

const int CF_KEYBOARD_KEYS = 99;//Combo flag to define keyboard keys

const int CMB_KEYBOARD_CURSOR = 1030;//Combo used to render cursor
const int CSET_KEYBOARD_CURSOR = 7;//CSet used to render cursor

const int SFX_KEYBOARD_INPUT = 16;//Sound to play on pressing keyboard key.

//Generic floor keyboard. Stand on keys and press EX1 to input stuff. Mostly used as part of puzzle.

//1. Set up input area. Flag 1st input position with CF_KEYBOARD_POS1 combo flag, 2nd with CF_KEYBOARD_POS2 flag and so on.
//2. Build keyboard on screen - flag each key on built keyboard with CF_KEYBOARD_KEYS combo flag.
//3. Set up puzzle that reads combos from input area, like password script.
//4. Place invisible FFC with script anywhere in the screen.
// D0 - Number of characters to input, max 16.
// D1 - Keyboard pressing animation. Uses next combo in list, that must cycle back into previous combo, or key will input different combos on each press.
// D2 - >0 - If Link walks on keyboard without pressing keys, a ghosted key combo will render at cursor position to indicate what will be inputed on key press.
// D3 - >0 - Inputing combo also inputs CSet of key pressed.
// D4 - >0 - Each key can be pressed only once.
// D5 - >0 - Don`t display CMB_KEYBOARD_CURSOR combo at cursor position.

ffc script AncientKeyboard{
	void run(int maxinput, int anim, int ghost, int color, int oneuse, int hidecursor){
		int input[16] = {CF_KEYBOARD_POS1,CF_KEYBOARD_POS2,CF_KEYBOARD_POS3,CF_KEYBOARD_POS4,CF_KEYBOARD_POS5,CF_KEYBOARD_POS6,CF_KEYBOARD_POS7,CF_KEYBOARD_POS8,CF_KEYBOARD_POS9,CF_KEYBOARD_POS10,CF_KEYBOARD_POS11,CF_KEYBOARD_POS12,CF_KEYBOARD_POS13,CF_KEYBOARD_POS14,CF_KEYBOARD_POS15,CF_KEYBOARD_POS16};
		int cursor = 0;
		int cmb = -1;
		
		while(true){
			for (int i=0;i<176;i++){
				if (hidecursor>0) break;
				if (!ComboFI(i, input[cursor])) continue;
				Screen->FastCombo(0, ComboX(i), ComboY(i), CMB_KEYBOARD_CURSOR, CSET_KEYBOARD_CURSOR, OP_OPAQUE);
			}
			cmb = ComboAt (CenterLinkX(), CenterLinkY()-2);
			if (ComboFI(cmb,CF_KEYBOARD_KEYS)){
				for (int i=0;i<176;i++){
					if (ghost==0) break;
					if (!ComboFI(i, input[cursor])) continue;
					Screen->FastCombo(0, ComboX(i), ComboY(i), Screen->ComboD[cmb],Cond(color>0, Screen->ComboC[cmb], Screen->ComboC[i]), OP_TRANS);
				}
				if (Link->PressEx1){
					Game->PlaySound(SFX_KEYBOARD_INPUT);
					for (int i=0;i<176;i++){
						if (!ComboFI(i, input[cursor])) continue;
						Screen->ComboD[i] = Screen->ComboD[cmb];
						if (color>0) Screen->ComboC[i] = Screen->ComboC[cmb];
					}
					cursor++;
					if (cursor>=maxinput) Quit();
					if (oneuse>0)Screen->ComboF[cmb]=0;
					if (anim>0)Screen->ComboD[cmb]++;
				}
			}
			Waitframe();
		}
	}
}