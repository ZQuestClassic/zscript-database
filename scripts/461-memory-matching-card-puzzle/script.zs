const int SFX_MEMORY_PAIR_MATCH=58;//Sound to play, when matching cards.
const int SFX_MEMORY_PAIR_SHUFFLE =32;//Sound to play, when tiles are shuffled and ga,e starts

const int SPR_MEMORY_PAIR_SHUFFLE = 22;//Sprite used to render magic shuffling.

const int MEMORY_PAIR_DECKSIZE = 33;//total number of different cards in the game.

//Memory match card game.
//A deck of cards is shuffled and laid down forming table face down. Stand on a card and press EX1. If two flipped cards mismatch, they flipped back, otherwise stay face up. Flip all cards face up to solve the puzzle.
//Set up MEMORY_PAIR_DECKSIZE combos, starting with card back, and following rest of cards. 
//Place combos from step 1, forming the grid and deck of cards. Each card must have even number of copies.
//Place FFC with card back combo and script assigned
//D0 - delay before game starts, in frames.

ffc script MemoryPairGame{
	void run(int delay){
		if (Screen->State[ST_SECRET])Quit();
		int origcmb=this->Data;
		int arrcmb[176];
		for (int i=0;i<176;i++){
			if (Screen->ComboD[i]<origcmb)arrcmb[i]=-1;
			else if (Screen->ComboD[i]>(origcmb+MEMORY_PAIR_DECKSIZE-1))arrcmb[i]=-1;
			else arrcmb[i] = Screen->ComboD[i] - origcmb;
		}
		ShuffleArray(arrcmb);	
		Waitframes(delay);
		int cmb=-1;
		int oldpos = -1;
		int curpos = -1;
		int temp[176];
		int arrpos=0;
		Game->PlaySound(SFX_MEMORY_PAIR_SHUFFLE);
		for (int i=0; i<176;i++){
			temp[i]=arrcmb[i];
		}
		for (int i=0; i<176;i++){
			arrcmb[i]=-1;
			if (Screen->ComboD[i]<origcmb)continue;
			if (Screen->ComboD[i]>(origcmb+MEMORY_PAIR_DECKSIZE-1)) continue;
			Screen->ComboD[i] = origcmb;
			if (SPR_MEMORY_PAIR_SHUFFLE>0){
				lweapon s = CreateLWeaponAt(LW_SPARKLE, ComboX(i), ComboY(i));
				s->UseSprite(SPR_MEMORY_PAIR_SHUFFLE);
				s->CollDetection=false; 
			}
			while(temp[arrpos]<0) arrpos++;
			arrcmb[i]=temp[arrpos];
			temp[arrpos]=-1;
		}
		while(true){
			cmb = ComboAt(CenterLinkX(), CenterLinkY());
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
							
						}
						else{
							Game->PlaySound(SFX_MEMORY_PAIR_MATCH);
							curpos=-1;
							oldpos=-1;
							for (int i=0; i<176; i++){
								if (Screen->ComboD[i]== origcmb) break;
								else if (i==175){
									Game->PlaySound(SFX_SECRET);
									Screen->TriggerSecrets();
									Screen->State[ST_SECRET]=true;
									Quit();
								}
							}
						}
					}
				}
			}
			//if (Link->InputEx2)DebugCombos(arrcmb);
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