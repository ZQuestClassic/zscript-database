const int CF_SIMONGAME_BUTTON = 98;//Combo flag to define playable key combos.
const int CF_SIMONGAME_BUTTON_COPYCAT = 99;//Combo flag to define unpressable "copycats" key combos. They change to next combo in list for 2 frames, toghether with CF_SIMONGAME_BUTTON on the same column;

const int SPR_SIMONGAME_INPUT = 0;//Sprite to display, when key button is highlighted.

const int CSET_SIMONGAME_FAIL = 11;//CSet to turn keyboard combos on minigame failure. 
const int CSET_SIMONGAME_WIN = 5;//CSet to turn keyboard combos on minigame victory. 

const int SFX_SIMONGAME_ARR_INPUT = 62; // ID First sound in sequence for keys. 
const int SFX_SIMONGAME_FAIL = 26; //Sound to play on hitting wrong button, thus failing the minigame.
const int SFX_SIMONGAME_SUCCESS = 61; //Sound to play, when correct pattern is inputed
const int SFX_SIMONGAME_VICTORY = 27; //Sound to play, when all patterns are correctly reproduced.

const int SFX_SIMONGAME_LIGHTNING = 37; //Sound to play, when lightning strikes
const int TILE_SIMONGAME_LIGHTNING = 451; //Tile used for lightning bolt rendering
const int CSET_SIMONGAME_LIGHTNING = 2; //CSet used for rendering lightning strike.

const int C_SIMONGAME_FLASH_FAIL = 0x81;//Flash color for minigame failure.

//const int FLAG_SIMONGAME_REVERSE_INPUT = 1;//DON`T EDIT
//const int FLAG_SIMONGAME_RANDOMIZE_ENTIRE_SEQUENCE = 2;

const int MODE_SIMONGAME_INTRO = 0;//DON`T EDIT
const int MODE_SIMONGAME_DEMO = 1;
const int MODE_SIMONGAME_REPLAY = 2;
const int MODE_SIMONGAME_PIANO = 3;

//Simon Says minigame.
//You are given a piano keyboard. After certaain time, keys start playing in a sequence. Your objective is to memorize the pattern and reproduce it by
//snanding on keyboard keys and pressing Ex1. Then process repeats with longer and faster patterns until either wrong button is pressed, which may result in deadly
//lighning strike, or certain limit is reached, which is rewarded either by item or secret trigger.

//Set up sequence of sounds for key tones, max 16.
//Set SFX_SIMONGAME_ARR_INPUT constant to ID of 1st sound in sequence.
//Set up combos for keys - Unpressed, then pressed.
//Build keyboard, place CF_SIMONGAME_BUTTON flags on keys,one per column,  max 16.
//Place invisible FFC with script anywhere in the screen.
//D0 - number of keys in staerting sequence. 0 to turn into normal piano, to be used just for fun, or in other puzzles.
//D1 - number of keys in final sequence, one step away from reward. Max 16.
//D2 - Add together: 1 - memorized sequence must be replayed in reverse, 2 - randomize entire sequence, instead of adding one note at the end.
//D3 - Delay between notes playing in demonstration, in frames.
//D4 - Reduction of delay each round, making demonstration play fater with each round.
//D5 - Reward on victory: >0 - ID if prize item, -1 - secret trigger.
//D6 - Penalty for failure, in 1/4ths of heart in damage caused by lightning strike.

ffc script SimonSaysMinigame{
	void run (int startseq, int endseq, int flags, int speed, int incr, int reward, int penalty){
		int seq[16];
		//int sfx[16];
		int list[16];
		int arr = 0;
		int mode=MODE_SIMONGAME_INTRO;
		if (startseq==0||endseq==0)mode=MODE_SIMONGAME_PIANO;
		for (int i=0;i<176;i++){
			if (ComboFI(i,CF_SIMONGAME_BUTTON)){
				list[arr]=i;
				//sfx[i]=arr;
				arr++;
				if (arr>=16)break;
			}
		}
		for (int i=arr;i<16;i++){
			if (i==16)break;
			//sfx[i]=0;
			list[i]=-1;
		}
		arr=0;
		for (int i=0;i<16;i++){
			seq[i]=-1;
			while(seq[i]<0){
				seq[i] = RandFromArray(list);				
			}
			//sfx[i]=ArrayMatch(list, seq[i]);
		}
		// TraceNL();
		// for (int i=0;i<16;i++){
		// Trace(seq[i]);
		// }
		arr=0;
		int animcounter=60;
		while(true){
			if (mode==MODE_SIMONGAME_INTRO){
				animcounter--;
				if (animcounter==0){
					animcounter=speed;
					mode = MODE_SIMONGAME_DEMO;
				}
			}
			if (mode==MODE_SIMONGAME_DEMO){
				animcounter--;
				if (animcounter==0){
					int cmb=seq[arr];
					if (SPR_SIMONGAME_INPUT>0){
						lweapon s = CreateLWeaponAt(LW_SPARKLE, ComboX(cmb), ComboY(cmb));
						s->UseSprite(SPR_SIMONGAME_INPUT);
						s->CollDetection=false;
						s->Y+=2;
					}
					int sound = ArrayMatch(list, seq[arr]);
					Game->PlaySound(SFX_SIMONGAME_ARR_INPUT+sound);
					arr++;
					for (int i=1; i<176; i++){
						if (ComboX(i)!=ComboX(cmb))continue;
						if (ComboFI(i, CF_SIMONGAME_BUTTON)) Screen->ComboD[i]++;
						if (ComboFI(i, CF_SIMONGAME_BUTTON_COPYCAT)) Screen->ComboD[i]++;
					}
					Waitframes(4);
					for (int i=1; i<176; i++){
						if (ComboX(i)!=ComboX(cmb))continue;
						if (ComboFI(i, CF_SIMONGAME_BUTTON)) Screen->ComboD[i]--;
						if (ComboFI(i, CF_SIMONGAME_BUTTON_COPYCAT)) Screen->ComboD[i]--;
					}
					if (arr>=startseq){
						mode = MODE_SIMONGAME_REPLAY;
						arr--;
						if ((flags&1)==0)arr=0;
					}
					else animcounter=speed;
				}
			}
			if (mode==MODE_SIMONGAME_REPLAY){
				int cmb = ComboAt (CenterLinkX(), CenterLinkY());
				if (ComboFI(cmb,CF_SIMONGAME_BUTTON) && Link->PressEx1){
					int sound = ArrayMatch(list, cmb);
					if (sound>=0) Game->PlaySound(SFX_SIMONGAME_ARR_INPUT+sound);
					if (SPR_SIMONGAME_INPUT>0){
						lweapon s = CreateLWeaponAt(LW_SPARKLE, ComboX(cmb), ComboY(cmb));
						s->UseSprite(SPR_SIMONGAME_INPUT);
						s->CollDetection=false;
						s->Y+=2;
					}
					for (int i=1; i<176; i++){
						if (ComboX(i)!=ComboX(cmb))continue;
						if (ComboFI(i, CF_SIMONGAME_BUTTON)) Screen->ComboD[i]++;
						if (ComboFI(i, CF_SIMONGAME_BUTTON_COPYCAT)) Screen->ComboD[i]++;
					}
					Waitframes(4);
					for (int i=1; i<176; i++){
						if (ComboX(i)!=ComboX(cmb))continue;
						if (ComboFI(i, CF_SIMONGAME_BUTTON)) Screen->ComboD[i]--;
						if (ComboFI(i, CF_SIMONGAME_BUTTON_COPYCAT)) Screen->ComboD[i]--;
					}
					if (cmb!=seq[arr]){
						Game->PlaySound(SFX_SIMONGAME_FAIL);
						if(penalty>0){
							Game->PlaySound(SFX_SIMONGAME_LIGHTNING);
							int ly=Link->Y;
							while(ly>=-16){
								Screen->FastTile(7, Link->X, ly, TILE_SIMONGAME_LIGHTNING, CSET_SIMONGAME_LIGHTNING, OP_OPAQUE);
								ly-=16;
							}
							eweapon e = FireEWeapon(EW_SCRIPT10, Link->X+InFrontX(Link->Dir, 12), Link->Y+InFrontY(Link->Dir, 12), 0, 0, penalty, -1, -1, EWF_UNBLOCKABLE);
							e->Dir = Link->Dir;
							e->DrawYOffset = -1000;
							SetEWeaponLifespan(e, EWL_TIMER, 1);
							SetEWeaponDeathEffect(e, EWD_VANISH, 0);
							
						}	
						for (int i=1; i<176; i++){
							if (ComboFI(i, CF_SIMONGAME_BUTTON)) Screen->ComboC[i]=CSET_SIMONGAME_FAIL;
							else if (ComboFI(i, CF_SIMONGAME_BUTTON_COPYCAT)) Screen->ComboC[i]=CSET_SIMONGAME_FAIL;
						}
						Screen->Rectangle(6, 0, 0, 256, 172, C_SIMONGAME_FLASH_FAIL, -1, 0, 0, 0, true, OP_OPAQUE);
						Quit();
					}
					else{
						if ((flags&1)>0)arr--;
						else arr++;
						int endarr = startseq;
						if ((flags&1)>0)endarr=-1;
						if (arr==endarr){
							if (startseq==endseq){
								if (reward<0 && !Screen->State[ST_SECRET]){
									Game->PlaySound(SFX_SIMONGAME_VICTORY);
									Screen->TriggerSecrets();
									Screen->State[ST_SECRET]=true;
								}
								if (reward>0 && !Screen->State[ST_SPECIALITEM]){
									Game->PlaySound(SFX_SIMONGAME_VICTORY);
									item it = CreateItemAt(reward, Link->X, Link->Y);
									it->Pickup = 0x802;
									it->Z=128;
									WaitNoAction(30);
								}
								for (int i=1; i<176; i++){
									if (ComboFI(i, CF_SIMONGAME_BUTTON)) Screen->ComboC[i]=CSET_SIMONGAME_WIN;
									else if (ComboFI(i, CF_SIMONGAME_BUTTON_COPYCAT)) Screen->ComboC[i]=CSET_SIMONGAME_WIN;
								}
								Quit();
							}
							else{
								Game->PlaySound(SFX_SIMONGAME_SUCCESS);
								startseq++;
								if ((flags&2)>0){
									for (int i=0; i<16; i++){
										seq[i]=-1;
										while(seq[i]<0){
											seq[i] = RandFromArray(list);				
										}
									}
								}
								arr=0;
								speed-=incr;
								if (speed<=0)speed=1;
								animcounter=60;
								mode=MODE_SIMONGAME_INTRO;
							}
						}
					}
				}
			}
			if (mode==MODE_SIMONGAME_PIANO){
				int cmb = ComboAt (CenterLinkX(), CenterLinkY());
				if (ComboFI(cmb,CF_SIMONGAME_BUTTON) && Link->PressEx1){
					int sound = ArrayMatch(list, cmb);
					if (sound>=0) Game->PlaySound(SFX_SIMONGAME_ARR_INPUT+sound);
					if (SPR_SIMONGAME_INPUT>0){
						lweapon s = CreateLWeaponAt(LW_SPARKLE, ComboX(cmb), ComboY(cmb));
						s->UseSprite(SPR_SIMONGAME_INPUT);
						s->CollDetection=false;
						s->Y+=2;
					}
					for (int i=1; i<176; i++){
						if (ComboX(i)!=ComboX(cmb))continue;
						if (ComboFI(i, CF_SIMONGAME_BUTTON)) Screen->ComboD[i]++;
						if (ComboFI(i, CF_SIMONGAME_BUTTON_COPYCAT)) Screen->ComboD[i]++;
					}
					Waitframes(4);
					for (int i=1; i<176; i++){
						if (ComboX(i)!=ComboX(cmb))continue;
						if (ComboFI(i, CF_SIMONGAME_BUTTON)) Screen->ComboD[i]--;
						if (ComboFI(i, CF_SIMONGAME_BUTTON_COPYCAT)) Screen->ComboD[i]--;
					}
				}
			}
			Waitframe();
		}
	}
}

//Picks random elemnemt from given array and returns it
int RandFromArray(int arr){
	int size = SizeOfArray(arr);
	int rnd = Rand(size-1);
	return arr[rnd];
}	

//Returns index of the given element that exists in the given array or -1, if it does not exist.
int ArrayMatch(int arr, int value){
	for (int i=0; i<SizeOfArray(arr); i++){
		if (arr[i] == value) return i;
	}
	return -1;
}