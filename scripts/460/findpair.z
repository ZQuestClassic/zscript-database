const int TILE_PAIRLUCK_LIGHTNING = 451;//Tile used for lightning bolt rendering
const int TILE_PAIRLUCK_HUD_MULTIPLIER = 503;//Tile used for rendering doubler in HUD

const int SFX_PAIRLUCK_LIGHTNING = 37;//Sound to play, when lightning strikes
const int SFX_PAIRLUCK_WHAMMY = 14;//Sound to play, when the game ends with hitting Whammy.
const int SFX_PAIRLUCK_SHUFFLE =32;//Sound to play, when tiles are shuffled and ga,e starts

const int CF_PAIRLUCK_WHAMMY = 98;//Flag used to define whammies
const int CT_PAIRLUCK_INSTANT = 142;//Combo Type used to define instant effect cards(no card match needed to trigger).

const int SPR_PAIRLUCK_SHUFFLE = 22;//Sprite used to render magic shuffling.

const int FONT_PAIRLUCK_HUD = 0;//Font used to render game info, like cost per game and current score;
const int CMB_PAIRLUCK_RUPEE = 662;//Tile used to render rupee image in HUD
const int CMB_PAIRLUCK_BARRIER = 1004;//Combo that changes to next one, when game is started.

const int CSET_PAIRLUCK_LIGHTNING = 2;//CSet used for rendering lightning strike.

const int C_PAIRLUCK_FLASH_FAIL = 0x81;//Flash color for minigame failure.

const int PAIRLUCK_DECKSIZE = 32;//total number of different cards in the game.

//Mario-styled card minigame. Stand on FFC and press Ex1 to pay initial cost. The cards are shuffled.
//Stand on card and press EX1 to flip it over. If 2 of the same kind drawn, an effect resolves. Most cards add counters, some have special effects.
//Some cards are labeled as Whammies, which, if flipped over, end the game. 
//
//Set up PAIRLUCK_DECKSIZE combos for different card effects
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
//Assign CF_PAIRLUCK_WHAMMY inherent flag to certain combos
//Place combos from step 1, forming the grid and deck of all possible outcomes in the game
//If you use combos like pitfalls, block off play area with CMB_PAIRLUCK_BARRIER combos to prevent accident falls.
//Place FFC with card back combo and script assigned
//D0 - #####.____ - string to display at introduction.
//D0 - _____.#### - string to display when the game is started.
//D1 - game cost, in rupees.
//D2 - damage dealt by lightning (card#11)
//D3 - ID of item to reward (card#10)
//D4 - Number of enemies to spawn (card#12)
//D5 - ID of enemies to spawn(card#12)
//D6 - combo position to render HUD for minigame
//D7 - #####.____ - string to display at ending the game via max win.
//D7 - _____.#### - string to display at ending the game via Whammy.

ffc script MarioCardPairGame{
	void run(int str, int cost, int dam, int val1, int val2, int val3, int draw, int endstr){
		int origcmb=this->Data;
		int arrcmb[176];
		for (int i=0;i<176;i++){
			if (Screen->ComboD[i]<origcmb)arrcmb[i]=-1;
			else if (Screen->ComboD[i]>(origcmb+PAIRLUCK_DECKSIZE-1))arrcmb[i]=-1;
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
		int multi=1;
		int pair[32];
		for (int i=0;i<32;i++){
			pair[i]=0;
		}
		Screen->Message(introstring);
		while(true){
			Screen->FastCombo(2, drawx, drawy, CMB_PAIRLUCK_RUPEE, this->CSet, OP_OPAQUE);
			cmb = ComboAt(CenterLinkX(), CenterLinkY());
			if(!started){
				Screen->DrawInteger(2, drawx+32, drawy, FONT_PAIRLUCK_HUD,1,0, -1, -1, -cost, 0, OP_OPAQUE);
				if (cmb==ComboAt (CenterX(this), CenterY(this))){
					if ((Game->Counter[CR_RUPEES]>=cost)&& Link->PressEx1 && Link->HP>16){
						Screen->Message(startstring);
						Game->PlaySound(SFX_PAIRLUCK_SHUFFLE);
						Game->DCounter[CR_RUPEES]-=cost;
						while(arrcmb[arrpos]<0) arrpos++;
						for (int i=0;i<176;i++){
							if (Screen->ComboD[i]==CMB_PAIRLUCK_BARRIER)Screen->ComboD[i]++;
							if (Screen->ComboD[i]<origcmb)continue;
							if (Screen->ComboD[i]>(origcmb+PAIRLUCK_DECKSIZE-1))continue;
							Screen->ComboD[i] = origcmb;
							if (SPR_PAIRLUCK_SHUFFLE>0){
								lweapon s = CreateLWeaponAt(LW_SPARKLE, ComboX(i), ComboY(i));
								s->UseSprite(SPR_PAIRLUCK_SHUFFLE);
								s->CollDetection=false; 
							}
						}
						started=true;
					}
				}
			}
			else{
				//Screen->DrawInteger(2, drawx+32, drawy, FONT_PAIRLUCK_HUD,1,0, -1, -1, score, 0, OP_OPAQUE);
				if (multi>1)Screen->FastTile(2, drawx+32, drawy, TILE_PAIRLUCK_HUD_MULTIPLIER, this->CSet, OP_OPAQUE);
				//Screen->Rectangle(2, ComboX(cmb), ComboY(cmb), ComboX(cmb)+15, ComboY(cmb)+15, 1, -1, 0, 0, 0, false, OP_OPAQUE);
				if (Link->PressEx1){
					if(Screen->ComboD[cmb]== origcmb){
						Game->PlaySound(16);
						Screen->ComboD[cmb] = origcmb+arrcmb[arrpos];
						int hit=arrcmb[arrpos];
						if (pair[hit]>0 || Screen->ComboT[cmb]==CT_PAIRLUCK_INSTANT){
							if(arrcmb[arrpos]==2) Game->DCounter[CR_ARROWS]+=Game->MCounter[CR_ARROWS]/2*multi;
							if(arrcmb[arrpos]==3) Game->DCounter[CR_BOMBS]+=Game->MCounter[CR_BOMBS]/2*multi; 
							if(arrcmb[arrpos]==4) Game->DCounter[CR_SBOMBS]+=multi;
							if(arrcmb[arrpos]==5) Game->DCounter[CR_LIFE] += Link->MaxHP/2*multi;
							if(arrcmb[arrpos]==6) Game->DCounter[CR_MAGIC] += Link->MaxMP/2*multi;
							if(arrcmb[arrpos]==7) multi=2;
							if(arrcmb[arrpos]==8) Game->DCounter[CR_RUPEES]+=50*multi;
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
								Game->PlaySound(SFX_PAIRLUCK_LIGHTNING);
								int ly=Link->Y;
								while(ly>=-16){
									Screen->FastTile(7, Link->X, ly, TILE_PAIRLUCK_LIGHTNING, CSET_PAIRLUCK_LIGHTNING, OP_OPAQUE);
									ly-=16;
									eweapon e = FireEWeapon(EW_SCRIPT10, Link->X+InFrontX(Link->Dir, 12), Link->Y+InFrontY(Link->Dir, 12), 0, 0, dam*multi, -1, -1, EWF_UNBLOCKABLE);
									e->Dir = Link->Dir;
									e->DrawYOffset = -1000;
									SetEWeaponLifespan(e, EWL_TIMER, 1);
									SetEWeaponDeathEffect(e, EWD_VANISH, 0);
								}
							}
							if(arrcmb[arrpos]==12){
								Game->PlaySound(56);
								for (int i=1;i<val2*multi;i++){
									npc n = SpawnNPC(val3);	
								}
								
							}
							if(arrcmb[arrpos]==16) Game->DCounter[CR_SCRIPT1]+=Game->MCounter[CR_SCRIPT1]/2*multi;
							if(arrcmb[arrpos]==17) Game->DCounter[CR_SCRIPT2]+=Game->MCounter[CR_SCRIPT2]/2*multi;
							if(arrcmb[arrpos]==18) Game->DCounter[CR_SCRIPT3]+=Game->MCounter[CR_SCRIPT3]/2*multi;
							if(arrcmb[arrpos]==19) Game->DCounter[CR_SCRIPT4]+=Game->MCounter[CR_SCRIPT4]/2*multi;
							if(arrcmb[arrpos]==20) Game->DCounter[CR_SCRIPT5]+=Game->MCounter[CR_SCRIPT5]/2*multi;
							if(arrcmb[arrpos]==21) Game->DCounter[CR_SCRIPT6]+=Game->MCounter[CR_SCRIPT6]/2*multi;
							if(arrcmb[arrpos]==22) Game->DCounter[CR_SCRIPT7]+=Game->MCounter[CR_SCRIPT7]/2*multi;
							if(arrcmb[arrpos]==23) Game->DCounter[CR_SCRIPT8]+=Game->MCounter[CR_SCRIPT8]/2*multi;
							if(arrcmb[arrpos]==24) Game->DCounter[CR_SCRIPT9]+=Game->MCounter[CR_SCRIPT9]/2*multi;
							if(arrcmb[arrpos]==25) Game->DCounter[CR_SCRIPT10]+=Game->MCounter[CR_SCRIPT10]/2*multi;
							if (Screen->ComboI[cmb]==CF_PAIRLUCK_WHAMMY){
								Waitframe();
								Screen->Rectangle(6, 0, 0, 256, 172, C_PAIRLUCK_FLASH_FAIL, -1, 0, 0, 0, true, OP_OPAQUE);
								Waitframe();
								Game->PlaySound(SFX_PAIRLUCK_WHAMMY);
								Screen->Message(whammystring);
								score=0;
								Quit();
							}
							if(arrcmb[arrpos]!=7) multi=1;
							pair[hit]=0;
						}
						else pair[hit]=1;
						arrcmb[arrpos] = -1;
												
						while(arrpos<176){
							if (arrcmb[arrpos]>=0) break;
							arrpos++;
						}
					}
					//if (cmb==ComboAt (CenterX(this), CenterY(this))){
					//	Screen->Message(winstring);
					//	Game->DCounter[CR_RUPEES]+=score;
					//	score= 0;
					//	Quit();
					//}
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
		if (Screen->ComboI[0]==CF_PAIRLUCK_WHAMMY) continue;
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