const int SFX_CLOVER_SHUFFLE =32;//Sound to play, when tiles are shuffled and ga,e starts

const int SPR_CLOVER_SHUFFLE = 22;//Sprite used to render magic shuffling.
const int SFX_CLOVER_HARVEST = 16;//Sound to play on plucking clover
const int SFX_CLOVER_HARVEST_ERROR = 3;//Sound to play on plucking wrong clover
const int SFX_CLOVER_HARVEST_WIN = 27;//Sound to play on victory

const int TILE_CLOVER_RUPEE = 13137;//Tile used to render rupee image for cost in HUD
const int FONT_CLOVER_HUD = 0;//Font used to render game info, like cost per game and current score;
const int TILE_CLOVER_HUD_CLOVER = 365;//Tile used to render clover image in HUD
const int TILE_CLOVER_HUD_MISS = 370;//Tile used to render "X" per miss made.

//Clover Harvesting minigame
//Find and pluck all 4-leaf clovers without plucking 3-leaf ones. 3 misses or run out of time limit and it`s game over.
//Set up 4 consecutive combos, 3-leaf, hidden 4-leaf, plucked 3-leaf, plucked/revealed 4-leaf
//Build cloverfield, using only first 2 combos from previous step
//Place FFC with 1st combo and script assigned
//D0 - #####.____ - string to display at introduction.
//D0 - _____.#### - string to display when the game is started.
//D1 - game cost, in rupees.
//D2 - ID of item to reward (-1 - secret trigger)
//D3 - Miss count limit. If it expires, game ends. 0 for default 3.
//D4 - unused
//D5 - combo position to render HUD for minigame
//D6 - #####.____ - string to display at ending the game via victory.
//D6 - _____.#### - string to display at ending the game via loss.
//D7 - Time limit, in frames. 0 for no time limit

ffc script CloverHarvestGame{
	void run(int str, int cost, int reward,int hpg, int flags, int draw, int endstr, int timer){
		int origcmb=this->Data;
		int arrcmb[176];
		for (int i=0;i<176;i++){
			if (Screen->ComboD[i]<origcmb)arrcmb[i]=-1;
			else if (Screen->ComboD[i]>(origcmb+1))arrcmb[i]=-1;
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
		int num4leafclovers=0;
		int score=0;
		int nummiss = 0;
		if (hpg==0)hpg=3;
		Screen->Message(introstring);
		while(true){
			cmb = ComboAt(CenterLinkX(), CenterLinkY());
			if(!started){
				Screen->FastTile(2, drawx, drawy, TILE_CLOVER_RUPEE, this->CSet, OP_OPAQUE);
				Screen->DrawInteger(2, drawx+32, drawy, FONT_CLOVER_HUD,1,0, -1, -1, -cost, 0, OP_OPAQUE);
				if (cmb==ComboAt (CenterX(this), CenterY(this))){
					if ((Game->Counter[CR_RUPEES]>=cost)&& Link->PressEx1){
						Screen->Message(startstring);
						Game->PlaySound(SFX_CLOVER_SHUFFLE);
						Game->DCounter[CR_RUPEES]-=cost;
						while(arrcmb[arrpos]<0) arrpos++;
						for (int i=0;i<176;i++){
							if (Screen->ComboD[i]<origcmb)continue;
							if (Screen->ComboD[i]>(origcmb+1)) continue;
							Screen->ComboD[i] = origcmb+arrcmb[arrpos];
							if (arrcmb[arrpos]==1) num4leafclovers++;
							arrcmb[arrpos]=-1;
							while(arrpos<176 && arrcmb[arrpos]<0){
								if (arrpos>=176)break;
								arrpos++;
								if (arrpos>=176)break;
							}
							if (SPR_CLOVER_SHUFFLE>0){
								lweapon s = CreateLWeaponAt(LW_SPARKLE, ComboX(i), ComboY(i));
								s->UseSprite(SPR_CLOVER_SHUFFLE);
								s->CollDetection=false; 
							}
						}
						started=true;
					}
				}
			}
			else{
				Screen->FastTile(1, drawx, drawy, TILE_CLOVER_HUD_CLOVER, this->CSet, OP_OPAQUE);
				Screen->DrawInteger(1, drawx+16, drawy, FONT_CLOVER_HUD,1,0, -1, -1, score, 0, OP_OPAQUE);
				int str[]="/";
				Screen->DrawString(1, drawx+32, drawy, FONT_CLOVER_HUD, 1,0,  0, str,OP_OPAQUE);
				Screen->DrawInteger(1, drawx+40, drawy, FONT_CLOVER_HUD,1,0, -1, -1, num4leafclovers, 0, OP_OPAQUE);
				for (int i=0;i<nummiss;i++){
					Screen->FastTile(1, drawx+56+8*i, drawy, TILE_CLOVER_HUD_MISS, this->CSet, OP_OPAQUE);
				}
				//Screen->Rectangle(2, ComboX(cmb), ComboY(cmb), ComboX(cmb)+15, ComboY(cmb)+15, 1, -1, 0, 0, 0, false, OP_OPAQUE);
				if (Link->PressEx1){
					if(Screen->ComboD[cmb]== origcmb){
						Game->PlaySound(SFX_CLOVER_HARVEST);
						if (Screen->ComboD[cmb]==origcmb){
							Game->PlaySound(SFX_CLOVER_HARVEST_ERROR);
							Screen->ComboD[cmb]=origcmb+2;
							nummiss++;
							if (nummiss>=hpg){
								Waitframe();
								Screen->Message(whammystring);
								Quit();
							}
						}
					}
					if(Screen->ComboD[cmb]==origcmb+1){
						Game->PlaySound(SFX_CLOVER_HARVEST);
						Screen->ComboD[cmb]=origcmb+3;
						score++;
						if (score>=num4leafclovers){
							Waitframe();
							Game->PlaySound(SFX_CLOVER_HARVEST_WIN);
							Screen->Message(winstring);
							if (reward<0 && !Screen->State[ST_SECRET]){
								Screen->TriggerSecrets();
								Screen->State[ST_SECRET]=true;
							}
							if (reward>0 && !Screen->State[ST_SPECIALITEM]){
								item it = CreateItemAt(reward, Link->X, Link->Y);
								it->Pickup = 0x802;
							}
							Quit();
						}
					}
				}
				if (timer>0){
					Screen->DrawInteger(2, drawx+24, drawy+8, FONT_CLOVER_HUD,1,0, -1, -1, Floor(timer/60), 0, OP_OPAQUE);
					timer--;
					if (timer<=0){
						Screen->Message(whammystring);
						Quit();
					}
				}
			}
			Waitframe();
		}
	}
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