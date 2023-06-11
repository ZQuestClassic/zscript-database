const int CF_SLIDEDROP_PUZZLE_AREA = 98;//Combo flag that defines main puzzle area
const int CF_SLIDEDROP_BUTTON_LEFT = 64;//Combo Flag that defines leftwards input button
const int CF_SLIDEDROP_BUTTON_RIGHT = 65;//Combo Flag that defines righttwards input button

const int CSET_SLIDEDROP_FAIL = 11;//CSet to paint the whole puzzle on failure

const int SFX_SLIDEDROP_MOVE = 50;//Sound to play when pressing button and performing sliding move
const int SFX_SLIDEDROP_FALL = 32;//Sound to play when colored blocks start falling
const int SFX_SLIDEDROP_LAND = 3;//Sound to play when colored blocks land on solid combos or puzzle border
const int SFX_SLIDEDROP_FAIL = 14;//Sound to play when colored block lands on wrong colored trigger, failing the puzzle

//Slide and Drop block pussle
//You are given area with solid blocks, some of them, usually at the top are colored. At the bottom of the puzzle area are non-solid colored spots. 
//You can press buttons at the sides of puzzle to slide rows of blocks left and right, but none of solid blocks can leave puzzle area (no wraparound, wrong input disabled).
//After slide colored blocks fall downwards, if they can. Land all colored blocks on same colored non-solid spots/triggers to solve the puzzle.
//Stand on input buttons (arrows in the demo) and press Ex1 to perform block shifting.

//1.Build puzzle area using solid and non-solid blocks, Flag entire area with CF_SLIDEDROP_PUZZLE_AREA combo flags.
//2.Recolor gravity-affected blocks using CSets 5+;
//3.Trigger spots. Recolor trigger spots at bottom of the screen (non-solid combos) to CSets 5+
//4.Place input buttons at the sides of puzzle area, using  CF_SLIDEDROP_BUTTON_LEFT and CF_SLIDEDROP_BUTTON_RIGHT combo flags.
//5. Place invisible FFC with script anywhere in the screen. No arguments needed.

ffc script SlideDroppingStonePuzzle{
	void run(){
		int dropx[64];
		int dropy[64];
		int dropcmb[64];
		int dropcset[64];
		for (int i=0;i<64;i++){
			dropx[i]=-1;
			dropy[i]=-1;
			dropcmb[i]=-1;
			dropcset[i]=-1;
		}
		int arrcounter=0;
		int cmb = -1;
		int fallcmb=-1;
		int State = 0;
		int statecounter=0;
		while(true){
			if (State==0){//Waiting for input
				cmb = ComboAt (CenterLinkX(), CenterLinkY());
				if (ComboFI(cmb,CF_SLIDEDROP_BUTTON_LEFT)){
					if (Link->PressEx1){
						for (int i=0;i<176;i++){
							if (ComboY(i)!=ComboY(cmb)) continue;
							if (!ComboFI(i,CF_SLIDEDROP_PUZZLE_AREA))continue;
							if (Screen->ComboS[i]==0) continue;
							if (!ComboFI(i-1,CF_SLIDEDROP_PUZZLE_AREA)) break;
							dropx[arrcounter] = ComboX(i);
							dropy[arrcounter]=ComboY(i);
							dropcmb[arrcounter] = Screen->ComboD[i];
							dropcset[arrcounter] = Screen->ComboC[i];
							Screen->ComboD[i]=Screen->UnderCombo;
							Screen->ComboC[i]=Screen->UnderCSet;
							
							Screen->FastCombo(0, dropx[arrcounter], dropy[arrcounter], dropcmb[arrcounter], dropcset[arrcounter], OP_OPAQUE);
							arrcounter++;
						}
						if (arrcounter>0){
							Game->PlaySound(SFX_SLIDEDROP_MOVE);
							statecounter=16;
							State=1;
						}
					}
				}
				if (ComboFI(cmb,CF_SLIDEDROP_BUTTON_RIGHT)){
					if (Link->PressEx1){
						for (int i=175;i>=0;i--){
							if (ComboY(i)!=ComboY(cmb)) continue;
							if (!ComboFI(i,CF_SLIDEDROP_PUZZLE_AREA))continue;
							if (Screen->ComboS[i]==0) continue;
							if (!ComboFI(i+1,CF_SLIDEDROP_PUZZLE_AREA)) break;
							dropx[arrcounter] = ComboX(i);
							dropy[arrcounter]=ComboY(i);
							dropcmb[arrcounter] = Screen->ComboD[i];
							dropcset[arrcounter] = Screen->ComboC[i];
							Screen->ComboD[i]=Screen->UnderCombo;
							Screen->ComboC[i]=Screen->UnderCSet;							
							
							Screen->FastCombo(0, dropx[arrcounter], dropy[arrcounter], dropcmb[arrcounter], dropcset[arrcounter], OP_OPAQUE);
							arrcounter++;
						}
						if (arrcounter>0){
							Game->PlaySound(SFX_SLIDEDROP_MOVE);
							statecounter=16;
							State=2;
						}
					}
				}
			}
			
			else if (State==1){//Bricks move left
				for (int i=0;i<arrcounter;i++){
					dropx[i]--;
					Screen->FastCombo(0, dropx[i], dropy[i], dropcmb[i], dropcset[i], OP_OPAQUE);
				}
				statecounter--;
				if (statecounter==0){
					for (int i=0;i<arrcounter;i++){
						fallcmb = ComboAt(dropx[i],dropy[i]);
						if (Screen->ComboC[fallcmb]!=dropcset[i] && dropcset[i]>=5 && Screen->ComboC[fallcmb]>=5){
							Game->PlaySound(SFX_SLIDEDROP_FAIL);
							eweapon x = CreateEWeaponAt(EW_BOMBBLAST, ComboX(fallcmb), ComboY(fallcmb));
							x->CollDetection=false;
							for (int i=175;i>=0;i--){
								if (!ComboFI(i,CF_SLIDEDROP_PUZZLE_AREA))continue;
								Screen->ComboC[i]=CSET_SLIDEDROP_FAIL;
							}
							Quit();
						}
						Screen->ComboD[fallcmb]=dropcmb[i];
						Screen->ComboC[fallcmb]=dropcset[i];
						dropx[i]=-1;
						dropy[i]=-1;
						dropcmb[i]=-1;
						dropcset[i]=-1;
					}
					arrcounter=0;
					for (int i=175;i>=0;i--){
						if (!ComboFI(i,CF_SLIDEDROP_PUZZLE_AREA))continue;
						// if (ComboY(i)!=ComboY(cmb))continue;
						if (Screen->ComboC[i]<5)continue;
						if (Screen->ComboS[i+16]>0)continue;
						if (!ComboFI(i+16,CF_SLIDEDROP_PUZZLE_AREA))continue;
						dropx[arrcounter] = ComboX(i);
						dropy[arrcounter]=ComboY(i);
						dropcmb[arrcounter] = Screen->ComboD[i];
						dropcset[arrcounter] = Screen->ComboC[i];
						Screen->ComboD[i]=Screen->UnderCombo;
						Screen->ComboC[i]=Screen->UnderCSet;						
						
						Screen->FastCombo(0, dropx[arrcounter], dropy[arrcounter], dropcmb[arrcounter], dropcset[arrcounter], OP_OPAQUE);
						arrcounter++;
					}
					if (arrcounter>0){
						Game->PlaySound(SFX_SLIDEDROP_FALL);
						statecounter=8;
						State=3;
					}
					else{
						SlideDropTriggerUpdate();
						arrcounter=0;
						State=0;
					}
				}				
			}
			
			else if (State==2){//Bricks move right
				for (int i=0;i<arrcounter;i++){
					dropx[i]++;
					Screen->FastCombo(0, dropx[i], dropy[i], dropcmb[i], dropcset[i], OP_OPAQUE);
				}
				statecounter--;
				if (statecounter==0){
					for (int i=0;i<arrcounter;i++){
						fallcmb = ComboAt(dropx[i],dropy[i]);
						if (Screen->ComboC[fallcmb]!=dropcset[i] && dropcset[i]>=5 && Screen->ComboC[fallcmb]>=5){
							Game->PlaySound(SFX_SLIDEDROP_FAIL);
							eweapon x = CreateEWeaponAt(EW_BOMBBLAST, ComboX(fallcmb), ComboY(fallcmb));
							x->CollDetection=false;
							for (int i=175;i>=0;i--){
								if (!ComboFI(i,CF_SLIDEDROP_PUZZLE_AREA))continue;
								Screen->ComboC[i]=CSET_SLIDEDROP_FAIL;
							}
							Quit();
						}
						Screen->ComboD[fallcmb]=dropcmb[i];
						Screen->ComboC[fallcmb]=dropcset[i];
						dropx[i]=-1;
						dropy[i]=-1;
						dropcmb[i]=-1;
						dropcset[i]=-1;
					}
					arrcounter=0;
					for (int i=175;i>=0;i--){
						if (!ComboFI(i,CF_SLIDEDROP_PUZZLE_AREA))continue;
						if (Screen->ComboC[i]<5)continue;
						if (Screen->ComboS[i+16]>0)continue;
						if (!ComboFI(i+16,CF_SLIDEDROP_PUZZLE_AREA))continue;
						dropx[arrcounter] = ComboX(i);
						dropy[arrcounter]=ComboY(i);
						dropcmb[arrcounter] = Screen->ComboD[i];
						dropcset[arrcounter] = Screen->ComboC[i];
						Screen->ComboD[i]=Screen->UnderCombo;
						Screen->ComboC[i]=Screen->UnderCSet;
						
						Screen->FastCombo(0, dropx[arrcounter], dropy[arrcounter], dropcmb[arrcounter], dropcset[arrcounter], OP_OPAQUE);
						arrcounter++;
					}
					if (arrcounter>0){
						Game->PlaySound(SFX_SLIDEDROP_FALL);
						statecounter=8;
						State=3;
					}
					else{
						SlideDropTriggerUpdate();
						arrcounter=0;
						State=0;
					}
				}
			}
			
			else if (State==3){//Colored bricks fall
				for (int i=0;i<arrcounter;i++){
					if (dropy[i]<0)continue;
					dropy[i]+=2;
					Screen->FastCombo(0, dropx[i], dropy[i], dropcmb[i], dropcset[i], OP_OPAQUE);
				}
				
				statecounter--;
				if (statecounter<=0){
					for (int i=0;i<64;i++){
						if (dropy[i]<0)continue;
						fallcmb = ComboAt(dropx[i]+1, dropy[i]+1);
						int belowcmb = fallcmb+16;
						if (Screen->ComboS[belowcmb]>0 || !ComboFI(belowcmb,CF_SLIDEDROP_PUZZLE_AREA)){
							if (Screen->ComboC[fallcmb]!=dropcset[i] && dropcset[i]>=5 && Screen->ComboC[fallcmb]>=5){
								Game->PlaySound(SFX_SLIDEDROP_FAIL);
								eweapon x = CreateEWeaponAt(EW_BOMBBLAST, ComboX(fallcmb), ComboY(fallcmb));
								x->CollDetection=false;
								for (int i=175;i>=0;i--){
									if (!ComboFI(i,CF_SLIDEDROP_PUZZLE_AREA))continue;
									Screen->ComboC[i]=CSET_SLIDEDROP_FAIL;
								}
								Quit();
							}
							Screen->ComboD[fallcmb]=dropcmb[i];
							Screen->ComboC[fallcmb]=dropcset[i];
							dropx[i]=-1;
							dropy[i]=-1;
							dropcmb[i]=-1;
							dropcset[i]=-1;
							Game->PlaySound(SFX_SLIDEDROP_LAND);
						}
					}
					
					for (int i=0;i<64;i++){
						if (dropy[i]>=0){
							statecounter=8;
							State=3;
							break;
						}
						else if (i==63){
							SlideDropTriggerUpdate();
							arrcounter=0;
							State=0;
						}
					}
				}
			}
			if (State>0)NoAction();
			Waitframe();
		}
	}
}

void SlideDropTriggerUpdate(){
	for (int i=175;i>=0;i--){
		if (i==0){
			Game->PlaySound(SFX_SECRET);
			Screen->TriggerSecrets();
			Screen->State[ST_SECRET]=true;
			Quit();
		}
		if (!ComboFI(i,CF_SLIDEDROP_PUZZLE_AREA)) continue;
		if (Screen->ComboC[i]<5)continue;
		if (Screen->ComboS[i]==0)break;
	}
}