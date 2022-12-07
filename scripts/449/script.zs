const int TILE_PRESSLUCK_LIGHTNING = 451;//Tile used for lightning bolt rendering

const int SFX_PRESSLUCK_LIGHTNING = 37;//Sound to play, when lightning strikes
const int SFX_PRESSLUCK_WHAMMY = 14;//Sound to play, when the game ends with hitting Whammy.
const int SFX_PRESSLUCK_SHUFFLE =32;//Sound to play, when tiles are shuffled and ga,e starts
const int SFX_PRESSLUCK_INSTANT_BANK=58;//Sound to play, when link draws "Instant Bank" card.

const int CF_PRESSLUCK_WHAMMY = 98;//Flag used to define whammies

const int SPR_PRESSLUCK_SHUFFLE = 22;//Sprite used to render magic shuffling.

const int FONT_PRESSLUCK_HUD = 0;//Font used to render game info, like cost per game and current score;
const int CMB_PRESSLUCK_RUPEE = 662;//Tile used to render rupee image in HUD
const int CMB_PRESSLUCK_BARRIER = 966;//Combo that changes to next one, when game is started.

const int CSET_PRESSLUCK_LIGHTNING = 2;//CSet used for rendering lightning strike.

const int C_PRESSLUCK_FLASH_FAIL = 0x81;//Flash color for minigame failure.

const int PRESSLUCK_DECKSIZE = 32;//total number of different cards in the game.

//Press Your Luck
//It`s time to Press Your Luck! Stand on FFC and press Wx1 to pay initial cost. The cards are shuffled.
//Stand on card and press EX1 to flip it over. It`s effect resolves. Most cards add score, some have special effects.
//Some cards are labeled as Whammies, which, if flipped over, end the game and flushing the score.
//At any time you can end the game by standing on FFC and press Ex1 again, to take out winnings.
//
//Set up PRESSLUCK_DECKSIZE combos for different card effects
// 0 - card back
// 1 - blank
// 2 - score + 5 
// 3 - score + 10
// 4 - score + 20
// 5 - score + 50
// 6 - score + 100
// 7 - score + 200
// 8 - banks the score immediately, before ending the game, if labeled as Whammy.
// 9 - triggers screen secrets
//10 - awards Link item
//11 - lightning strikes Link for damage
//12 - enemies spawned
//13-31 general purpose (scripts). In the demo, 13 is a pit that sends Link into instant death spikes.
//Assign CF_PRESSLUCK_WHAMMY inherent flag to certain combos
//Place combos from step 1, forming the grid and deck of all possible outcomes in the game
//If you use combos like pitfalls, block off play area with CMB_PRESSLUCK_BARRIER combos to prevent accident falls.
//Place FFC with card back combo and script assigned
//D0 - #####.____ - string to display at introduction.
//D0 - _____.#### - string to display when the game is started.
//D1 - game cost, in rupees.
//D2 - damage dealt by lightning (card#11)
//D3 - ID of item to reward (card#10)
//D4 - Number of enemies to spawn (card#12)
//D5 - ID of enemies to spawn(card#12)
//D6 - combo position to render HUD for minigame
//D7 - #####.____ - string to display at ending the game via stop.
//D7 - _____.#### - string to display at ending the game via Whammy.

ffc script PressYourLuck{
	void run(int str, int cost, int dam, int val1, int val2, int val3, int draw, int endstr){
		int origcmb=this->Data;
		int arrcmb[176];
		for (int i=0;i<176;i++){
			if (Screen->ComboD[i]<origcmb)arrcmb[i]=-1;
			else if (Screen->ComboD[i]>(origcmb+PRESSLUCK_DECKSIZE-1))arrcmb[i]=-1;
			else arrcmb[i] = Screen->ComboD[i] - origcmb;
		}
		int introstring = GetHighFloat(str);
		int startstring = GetLowFloat(str);
		int winstring = GetHighFloat(endstr);
		int whammystring = GetLowFloat(endstr);
		int drawx = ComboX(draw);
		int drawy = ComboY(draw);
		ShuffleArray(arrcmb);
		int arrpos=0;
		bool started=false;
		int cmb=-1;
		int score=0;
		Screen->Message(introstring);
		while(true){
			Screen->FastCombo(2, drawx, drawy, CMB_PRESSLUCK_RUPEE, this->CSet, OP_OPAQUE);
			cmb = ComboAt(CenterLinkX(), CenterLinkY());
			if(!started){
				Screen->DrawInteger(2, drawx+32, drawy, FONT_PRESSLUCK_HUD,1,0, -1, -1, -cost, 0, OP_OPAQUE);
				if (cmb==ComboAt (CenterX(this), CenterY(this))){
					if ((Game->Counter[CR_RUPEES]>=cost)&& Link->PressEx1){
						Screen->Message(startstring);
						Game->PlaySound(SFX_PRESSLUCK_SHUFFLE);
						Game->DCounter[CR_RUPEES]-=cost;
						while(arrcmb[arrpos]<0) arrpos++;
						for (int i=0;i<176;i++){
							if (Screen->ComboD[i]==CMB_PRESSLUCK_BARRIER)Screen->ComboD[i]++;
							if (Screen->ComboD[i]<origcmb)continue;
							if (Screen->ComboD[i]>(origcmb+PRESSLUCK_DECKSIZE-1))continue;
							Screen->ComboD[i] = origcmb;
							if (SPR_PRESSLUCK_SHUFFLE>0){
								lweapon s = CreateLWeaponAt(LW_SPARKLE, ComboX(i), ComboY(i));
								s->UseSprite(SPR_PRESSLUCK_SHUFFLE);
								s->CollDetection=false; 
							}
						}
						started=true;
					}
				}
			}
			else{
				Screen->DrawInteger(2, drawx+32, drawy, FONT_PRESSLUCK_HUD,1,0, -1, -1, score, 0, OP_OPAQUE);
				//Screen->Rectangle(2, ComboX(cmb), ComboY(cmb), ComboX(cmb)+15, ComboY(cmb)+15, 1, -1, 0, 0, 0, false, OP_OPAQUE);
				if (Link->PressEx1){
					if(Screen->ComboD[cmb]== origcmb){
						Game->PlaySound(16);
						Screen->ComboD[cmb] = origcmb+arrcmb[arrpos];
						if(arrcmb[arrpos]==2) score+=5;
						if(arrcmb[arrpos]==3) score+=10; 
						if(arrcmb[arrpos]==4) score+=20;
						if(arrcmb[arrpos]==5) score+=50;
						if(arrcmb[arrpos]==6) score+=100;
						if(arrcmb[arrpos]==7) score+=200;
						if(arrcmb[arrpos]==8) {
							Game->PlaySound(SFX_PRESSLUCK_INSTANT_BANK);
							Game->DCounter[CR_RUPEES]+=score;
							score= 0;
						}
						if(arrcmb[arrpos]==9){
							Game->PlaySound(SFX_SECRET);
							Screen->TriggerSecrets();
							Screen->State[ST_SECRET]=true;
						}
						if(arrcmb[arrpos]==10){
							item it = CreateItemAt(val1, Link->X, Link->Y);
							it->Pickup=2;
						}
						if(arrcmb[arrpos]==11){
							Game->PlaySound(SFX_PRESSLUCK_LIGHTNING);
							int ly=Link->Y;
							while(ly>=-16){
								Screen->FastTile(7, Link->X, ly, TILE_PRESSLUCK_LIGHTNING, CSET_PRESSLUCK_LIGHTNING, OP_OPAQUE);
								ly-=16;
								eweapon e = FireEWeapon(EW_SCRIPT10, Link->X+InFrontX(Link->Dir, 12), Link->Y+InFrontY(Link->Dir, 12), 0, 0, dam, -1, -1, EWF_UNBLOCKABLE);
								e->Dir = Link->Dir;
								e->DrawYOffset = -1000;
								SetEWeaponLifespan(e, EWL_TIMER, 1);
								SetEWeaponDeathEffect(e, EWD_VANISH, 0);
							}
						}
						if(arrcmb[arrpos]==12){
							Game->PlaySound(56);
							for (int i=1;i<val2;i++){
								npc n = SpawnNPC(val3);	
							}
							
						}
						if (Screen->ComboI[cmb]==CF_PRESSLUCK_WHAMMY){
							Waitframe();
							Screen->Rectangle(6, 0, 0, 256, 172, C_PRESSLUCK_FLASH_FAIL, -1, 0, 0, 0, true, OP_OPAQUE);
							Waitframe();
							Game->PlaySound(SFX_PRESSLUCK_WHAMMY);
							Screen->Message(whammystring);
							score=0;
							Quit();
						}
						arrcmb[arrpos] = -1;
												
						while(arrpos<176){
							if (arrcmb[arrpos]>=0) break;
							arrpos++;
						}
					}
					if (cmb==ComboAt (CenterX(this), CenterY(this))){
						Screen->Message(winstring);
						Game->DCounter[CR_RUPEES]+=score;
						score= 0;
						Quit();
					}
					if (OnlyWhammiesLeft(arrcmb, arrpos, origcmb)){
						Screen->Message(winstring);
						Game->DCounter[CR_RUPEES]+=score;
						score= 0;
						Quit();
					}
				}
			}
			Waitframe();
		}
	}	
}

//Returns true, if all cards left face down are nothing but whammies.
bool OnlyWhammiesLeft(int arr, int arrpos, int origcmb){
	int temp = Screen->ComboD[0];
	if (arrpos==176)return true;
	for (int i=arrpos; i<176; i++){
		if (arr[i]<0)continue;
		Screen->ComboD[0]=origcmb+arr[i];
		if (Screen->ComboI[0]==CF_PRESSLUCK_WHAMMY) continue;
		else{
			Screen->ComboD[0]=temp;
			return false;
		}
	}
	Screen->ComboD[0]=temp;
	return true;
}

//Swaps two elements in the given array
void SwapArray(int arr, int pos1, int pos2){
	int r = arr[pos1];
	arr[pos1]=arr[pos2];
	arr[pos2]=r;
}

//Shuffles the givel array like deck of playing cards
void ShuffleArray(int arr){
	int size = SizeOfArray(arr)-1;
	for (int i=0; i<=size*size; i++){
		int r1 = Rand(size);
		int r2 = Rand(size);
		SwapArray(arr, r1, r2);
	}
}