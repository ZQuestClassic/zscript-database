const int TILE_PAIRLUCK3_LIGHTNING = 451;//Tile used for lightning bolt rendering
const int TILE_PAIRLUCK3_HUD_MULTIPLIER = 503;//Tile used for rendering doubler in HUD

const int SFX_PAIRLUCK3_LIGHTNING = 37;//Sound to play, when lightning strikes
const int SFX_PAIRLUCK3_WHAMMY = 14;//Sound to play, when the game ends with hitting Whammy.
const int SFX_PAIRLUCK3_SHUFFLE =32;//Sound to play, when tiles are shuffled and ga,e starts
const int SFX_PAIRLUCK3_MATCH=58;//Sound to play, when matching cards.

const int CF_PAIRLUCK3_WHAMMY = 98;//Flag used to define whammies

const int SPR_PAIRLUCK3_SHUFFLE = 22;//Sprite used to render magic shuffling.

const int FONT_PAIRLUCK3_HUD = 0;//Font used to render game info, like cost per game and current score;
const int CMB_PAIRLUCK3_RUPEE = 662;//Tile used to render rupee image in HUD
const int CMB_PAIRLUCK3_BARRIER = 1004;//Combo that changes to next one, when game is started.

const int CSET_PAIRLUCK3_LIGHTNING = 2;//CSet used for rendering lightning strike.

const int C_PAIRLUCK3_FLASH_FAIL = 0x81;//Flash color for minigame failure.

const int PAIRLUCK3_DECKSIZE = 32;//total number of different cards in the game.

//Mario3 - styled card minigame. Stand on FFC and press Ex1 to pay initial cost. The cards are shuffled.
//Stand on card and press EX1 to flip it over. If 2 of the same kind drawn, an effect resolves, otherwise cards flipped facedown. Most cards add counters, some have special effects.
//Some cards are labeled as Whammies, which, if matched, end the game. The game also ends, if certain count of mismatches is made.
//
//Set up PAIRLUCK3_DECKSIZE combos for different card effects
// 0 - card back
// 1 - blank
// 2 - Arrows + 50% max
// 3 - Bombs + 50% max
// 4 - Super Bomb +1
// 5 - HP + 50% max
// 6 - MP + 50% max
// 7 - Doubles next reward or penalty
// 8 - +50 rupees
// 9 - Triggers screen secrets
//10 - Awards Link item
//11 - Lightning strikes Link for damage
//12 - Enemies spawned
//13-15 - general purpose (scripts). In the demo, 14 is a pit that sends Link into instant death spikes.
//16-25 - script counters(1-10) + 50%+max
//26-31  - general purpose (scripts). In the demo, 14 is a pit that sends Link into instant death spikes.
//Assign CF_PAIRLUCK3_WHAMMY inherent flag to certain combos
//Place combos from step 1, forming the grid and deck of all possible outcomes in the game
//If you use combos like pitfalls, block off play area with CMB_PAIRLUCK3_BARRIER combos to prevent accident falls.
//Place FFC with card back combo and script assigned
//D0 - #####.____ - string to display at introduction.
//D0 - _____.#### - string to display when the game is started.
//D1 - game cost, in rupees.
//D2 - damage dealt by lightning (card#11)
//D3 - ID of item to reward (card#10)
//D4 - #####.____ - Number of enemies to spawn (card#12)
//D4 - _____.#### - ID of enemies to spawn(card#12)
//D5 - Mismatch count limit. If it expires, game ends. 0 for unlimited.
//D6 - combo position to render HUD for minigame
//D7 - #####.____ - string to display at ending the game via max win.
//D7 - _____.#### - string to display at ending the game via Whammy.

ffc script Mario3CardPairGame{
	void run(int str, int cost, int dam, int val1, int enem, int limit, int draw, int endstr){
		int origcmb=this->Data;
		int arrcmb[176];
		for (int i=0;i<176;i++){
			if (Screen->ComboD[i]<origcmb)arrcmb[i]=-1;
			else if (Screen->ComboD[i]>(origcmb+PAIRLUCK3_DECKSIZE-1))arrcmb[i]=-1;
			else arrcmb[i] = Screen->ComboD[i] - origcmb;
		}
		if (limit==0)limit=-1;
		int introstring = GetHighFloat(str);
		int startstring = GetLowFloat(str);
		int winstring = GetHighFloat(endstr);
		int whammystring = GetLowFloat(endstr);
		int val2 = GetHighFloat(enem);
		int val3 = GetLowFloat(enem);
		int drawx = ComboX(draw);
		int drawy = ComboY(draw);
		ShuffleArray(arrcmb);
		int temp[176];
		int arrpos=0;
		for (int i=0; i<176;i++){
			temp[i]=arrcmb[i];
		}
		bool started=false;
		int cmb=-1;
		int oldpos = -1;
		int curpos = -1;
		int multi=1;
		int pair[32];
		for (int i=0;i<32;i++){
			pair[i]=0;
		}
		Screen->Message(introstring);
		while(true){
			Screen->FastCombo(2, drawx, drawy, CMB_PAIRLUCK3_RUPEE, this->CSet, OP_OPAQUE);
			cmb = ComboAt(CenterLinkX(), CenterLinkY());
			if(!started){
				Screen->DrawInteger(2, drawx+32, drawy, FONT_PAIRLUCK3_HUD,1,0, -1, -1, -cost, 0, OP_OPAQUE);
				if (cmb==ComboAt (CenterX(this), CenterY(this))){
					if ((Game->Counter[CR_RUPEES]>=cost)&& Link->PressEx1 && Link->HP>16){
						Screen->Message(startstring);
						Game->PlaySound(SFX_PAIRLUCK3_SHUFFLE);
						Game->DCounter[CR_RUPEES]-=cost;
						while(arrcmb[arrpos]<0) arrpos++;
						for (int i=0;i<176;i++){
						arrcmb[i]=-1;
							if (Screen->ComboD[i]==CMB_PAIRLUCK3_BARRIER)Screen->ComboD[i]++;
							if (Screen->ComboD[i]<origcmb)continue;
							if (Screen->ComboD[i]>(origcmb+PAIRLUCK3_DECKSIZE-1))continue;
							Screen->ComboD[i] = origcmb;
							if (SPR_PAIRLUCK3_SHUFFLE>0){
								lweapon s = CreateLWeaponAt(LW_SPARKLE, ComboX(i), ComboY(i));
								s->UseSprite(SPR_PAIRLUCK3_SHUFFLE);
								s->CollDetection=false; 
							}
							while(temp[arrpos]<0) arrpos++;
							arrcmb[i]=temp[arrpos];
							temp[arrpos]=-1;
						}
						started=true;
					}
				}
			}
			else{
				Screen->DrawInteger(2, drawx+48, drawy, FONT_PAIRLUCK3_HUD,1,0, -1, -1, limit, 0, OP_OPAQUE);
				if (multi>1)Screen->FastTile(2, drawx+16, drawy, TILE_PAIRLUCK3_HUD_MULTIPLIER, this->CSet, OP_OPAQUE);
				//Screen->Rectangle(2, ComboX(cmb), ComboY(cmb), ComboX(cmb)+15, ComboY(cmb)+15, 1, -1, 0, 0, 0, false, OP_OPAQUE);
				if (Link->PressEx1){
					if(Screen->ComboD[cmb]== origcmb){
						Game->PlaySound(16);
						Screen->ComboD[cmb] = origcmb + arrcmb[cmb];
						if (oldpos<0) oldpos = cmb;
						else{
							curpos = cmb;
							if (Screen->ComboD[oldpos]!=Screen->ComboD[curpos]){
								Waitframes(45);
								Screen->ComboD[curpos]=origcmb;
								Screen->ComboD[oldpos]=origcmb;
								oldpos=-1;
								curpos=-1;
								if (limit>0){
									limit--;
									if (limit==0){
										Game->PlaySound(SFX_PAIRLUCK3_WHAMMY);
										Screen->Message(whammystring);
										Quit();
									}
								}
							}
							else{
								Game->PlaySound(SFX_PAIRLUCK3_MATCH);
								curpos=-1;
								oldpos=-1;
								if(arrcmb[cmb]==2) Game->DCounter[CR_ARROWS]+=Game->MCounter[CR_ARROWS]/2*multi;
								if(arrcmb[cmb]==3) Game->DCounter[CR_BOMBS]+=Game->MCounter[CR_BOMBS]/2*multi; 
								if(arrcmb[cmb]==4) Game->DCounter[CR_SBOMBS]+=multi;
								if(arrcmb[cmb]==5) Game->DCounter[CR_LIFE] += Link->MaxHP/2*multi;
								if(arrcmb[cmb]==6) Game->DCounter[CR_MAGIC] += Link->MaxMP/2*multi;
								if(arrcmb[cmb]==7) multi=2;
								if(arrcmb[cmb]==8) Game->DCounter[CR_RUPEES]+=50*multi;
								if(arrcmb[cmb]==9){
									Game->PlaySound(SFX_SECRET);
									Screen->TriggerSecrets();
									Screen->State[ST_SECRET]=true;
								}
								if(arrcmb[cmb]==10){
									item it = CreateItemAt(val1, Link->X, Link->Y);
									it->Pickup=2;
								}
								if(arrcmb[cmb]==11){
									Game->PlaySound(SFX_PAIRLUCK3_LIGHTNING);
									int ly=Link->Y;
									while(ly>=-16){
										Screen->FastTile(7, Link->X, ly, TILE_PAIRLUCK3_LIGHTNING, CSET_PAIRLUCK3_LIGHTNING, OP_OPAQUE);
										ly-=16;
										eweapon e = FireEWeapon(EW_SCRIPT10, Link->X+InFrontX(Link->Dir, 12), Link->Y+InFrontY(Link->Dir, 12), 0, 0, dam*multi, -1, -1, EWF_UNBLOCKABLE);
										e->Dir = Link->Dir;
										e->DrawYOffset = -1000;
										SetEWeaponLifespan(e, EWL_TIMER, 1);
										SetEWeaponDeathEffect(e, EWD_VANISH, 0);
									}
								}
								if(arrcmb[cmb]==12){
									Game->PlaySound(56);
									for (int i=1;i<val2*multi;i++){
										npc n = SpawnNPC(val3);	
									}
									
								}
								if(arrcmb[cmb]==16) Game->DCounter[CR_SCRIPT1]+=Game->MCounter[CR_SCRIPT1]/2*multi;
								if(arrcmb[cmb]==17) Game->DCounter[CR_SCRIPT2]+=Game->MCounter[CR_SCRIPT2]/2*multi;
								if(arrcmb[cmb]==18) Game->DCounter[CR_SCRIPT3]+=Game->MCounter[CR_SCRIPT3]/2*multi;
								if(arrcmb[cmb]==19) Game->DCounter[CR_SCRIPT4]+=Game->MCounter[CR_SCRIPT4]/2*multi;
								if(arrcmb[cmb]==20) Game->DCounter[CR_SCRIPT5]+=Game->MCounter[CR_SCRIPT5]/2*multi;
								if(arrcmb[cmb]==21) Game->DCounter[CR_SCRIPT6]+=Game->MCounter[CR_SCRIPT6]/2*multi;
								if(arrcmb[cmb]==22) Game->DCounter[CR_SCRIPT7]+=Game->MCounter[CR_SCRIPT7]/2*multi;
								if(arrcmb[cmb]==23) Game->DCounter[CR_SCRIPT8]+=Game->MCounter[CR_SCRIPT8]/2*multi;
								if(arrcmb[cmb]==24) Game->DCounter[CR_SCRIPT9]+=Game->MCounter[CR_SCRIPT9]/2*multi;
								if(arrcmb[cmb]==25) Game->DCounter[CR_SCRIPT10]+=Game->MCounter[CR_SCRIPT10]/2*multi;
								if (Screen->ComboI[cmb]==CF_PAIRLUCK3_WHAMMY){
									Waitframe();
									Screen->Rectangle(6, 0, 0, 256, 172, C_PAIRLUCK3_FLASH_FAIL, -1, 0, 0, 0, true, OP_OPAQUE);
									Waitframe();
									Game->PlaySound(SFX_PAIRLUCK3_WHAMMY);
									Screen->Message(whammystring);
									Quit();
								}
								if(arrcmb[cmb]!=7) multi=1;
							}
						}
					}
					//if (cmb==ComboAt (CenterX(this), CenterY(this))){
					//	Screen->Message(winstring);
					//	Game->DCounter[CR_RUPEES]+=score;
					//	score= 0;
					//	Quit();
					//}
					if (OnlyWhammiesLeft(arrcmb, origcmb)){
						Screen->Message(winstring);
						Quit();
					}
				}
			}
			Waitframe();
		}
	}	
}

//Returns true, if all cards left face down are nothing but whammies.
bool OnlyWhammiesLeft(int arr, int origcmb){
	int temp = Screen->ComboD[0];
	for (int i=0; i<176; i++){
		if (arr[i]<0)continue;
		Screen->ComboD[0]=origcmb+arr[i];
		if (Screen->ComboI[0]==CF_PAIRLUCK3_WHAMMY) continue;
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