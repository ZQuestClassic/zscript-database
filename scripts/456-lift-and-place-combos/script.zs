const int SFX_PICKPLACE_PICK = 4;//Sound to play,when liftable combo is picked.
const int SFX_PICKPLACE_PLACE = 16;//Sound to play,when liftable combo is placed.

const int CT_PICKPLACE_LIFTABLE = 142;//Combo that is defined as liftable

const int PICKPLACE_LIFT_OFFSET = 8;//Y offset for rendering lifted combos

const int LINK_MISC_COMBO_IN_HAND = 1;//Index to Link`s misc var for ID of carried combo
const int LINK_MISC_CSET_IN_HAND = 2;//Index to Link`s misc var for cset of carried combo
//Pick and place combos, like Minecraft. 
//Place anywhere in the screen. 
//D0 - bracelet power requirement. 
//D1 - >0 - allow tile swapping
ffc script PickPlaceCombos{
	void run (int weight, int allowswap){
		Link->Misc[LINK_MISC_COMBO_IN_HAND]=0;
		Link->Misc[LINK_MISC_CSET_IN_HAND]=0;
		int cmb = -1;
		int bufferd = 0;
		int bufferc = 0;
		int buffert = 0;
		while(true){
			cmb = ComboAt(CenterLinkX(), CenterLinkY());
			if (Link->PressEx1){
				if (Link->Misc[LINK_MISC_COMBO_IN_HAND]==0){ 
					if (!ComboFI(cmb, CF_NOBLOCKS)  &&  CanLift(weight) && Screen->ComboT[cmb]==CT_PICKPLACE_LIFTABLE){
						Game->PlaySound(SFX_PICKPLACE_PICK);
						Link->Misc[LINK_MISC_COMBO_IN_HAND]=Screen->ComboD[cmb];
						Link->Misc[LINK_MISC_CSET_IN_HAND] = Screen->ComboC[cmb];
						Screen->ComboD[cmb]=Screen->UnderCombo;
						Screen->ComboC[cmb]=Screen->UnderCSet;
					}
				}
				else if (!ComboFI(cmb, CF_NOBLOCKS) && (Screen->ComboT[cmb]!=CT_PICKPLACE_LIFTABLE || allowswap>0) && Link->Misc[LINK_MISC_COMBO_IN_HAND]>0){
					bufferd = Screen->ComboD[cmb];
					bufferc = Screen->ComboC[cmb];
					buffert = Screen->ComboT[cmb];
					Game->PlaySound(SFX_PICKPLACE_PLACE);
					Screen->ComboD[cmb]=Link->Misc[LINK_MISC_COMBO_IN_HAND];
					Screen->ComboC[cmb]=Link->Misc[LINK_MISC_CSET_IN_HAND];
					Link->Misc[LINK_MISC_COMBO_IN_HAND]=0;
					Link->Misc[LINK_MISC_CSET_IN_HAND]=0;
					if (allowswap>0 && buffert==CT_PICKPLACE_LIFTABLE){
						Game->PlaySound(SFX_PICKPLACE_PICK);
						Link->Misc[LINK_MISC_COMBO_IN_HAND]=bufferd;
						Link->Misc[LINK_MISC_CSET_IN_HAND] = bufferc;
					}
				}
			}
			if (Link->Misc[LINK_MISC_COMBO_IN_HAND]>0)Screen->FastCombo(4, Link->X, Link->Y-PICKPLACE_LIFT_OFFSET, Link->Misc[LINK_MISC_COMBO_IN_HAND], Link->Misc[LINK_MISC_CSET_IN_HAND], OP_OPAQUE);
			Waitframe();
		}
	}
}

// Returns Link`s pushing power
bool CanLift(int weight){
	int result = -1;
	int highestlevel = -1;
	int power =0;
	for(int i=0; i<=MAX_HIGHEST_LEVEL_ITEM_CHECK; ++i)	{
		itemdata id = Game->LoadItemData(i);
		if(id->Family == IC_BRACELET && Link->Item[i]){
			if(id->Level >= highestlevel){
				highestlevel = id->Level;
				result=i;
			}
		}
	}
	if (result<0)return weight<=0;
	itemdata it = Game->LoadItemData(result);
	return (it->Power) >=weight;
}

//const int LAYER_STACK_DROP = 4;

//Stackable pick/place comb pillsr.
//Place FFC with solid combo at base
//D0 - bracelet level requirement.
//D1 - number of combos in column at start.
//D2 - maximum number of elements in pillar
ffc script StackDropLift{
	void run (int weight, int initcount, int cap){
		int cmb = ComboAt(CenterX(this), CenterY(this));
		int numcmb=initcount;
		int curpos = cmb-16*initcount-16;
		while(true){			
			if (Link->PressEx1 && Link->Y == this->Y + 8 && (Link->X < this->X + 8 && Link->X > this->X - 8) && Link->Dir == DIR_UP){
				if (Link->Misc[LINK_MISC_COMBO_IN_HAND]==0){
					if (numcmb>0 && CanLift(weight)){	
						Game->PlaySound(SFX_PICKPLACE_PICK);
						Link->Misc[LINK_MISC_COMBO_IN_HAND]=Screen->ComboD[curpos+16];
						Link->Misc[LINK_MISC_CSET_IN_HAND]=Screen->ComboC[curpos+16];
						Screen->ComboD[curpos+16] = Screen->UnderCombo;
						Screen->ComboC[curpos+16] =Screen->UnderCSet;
						curpos+=16;
						numcmb--;
					}
				}
				else{
					if (numcmb<cap){
						Game->PlaySound(SFX_PICKPLACE_PLACE);
						Screen->ComboD[curpos] = Link->Misc[LINK_MISC_COMBO_IN_HAND];
						Screen->ComboC[curpos] = Link->Misc[LINK_MISC_CSET_IN_HAND];
						Link->Misc[LINK_MISC_COMBO_IN_HAND]=0;
						Link->Misc[LINK_MISC_CSET_IN_HAND]=0;
						curpos-=16;
						numcmb++;
					}
				}
			}
			Waitframe();
		}
	}
}		

const int  SFX_TIMEDROP_SUCCESS = 27;//Sound to play on succeful filling of the hole
const int  SFX_TIMEDROP_FAIL = 32;//Sound to play on incorrect combo drop
const int  SFX_TIMEDROP_FAIL2 = 38;//Sound to play on mistimed combo drop

//Timed colored hole.
//Animated hole that must be filled by dropping correct combo within specific timing to solve the puzzle.

//Effect width and height used
//Set up sequence of combos for animation
//D0 - ID of correct combo to drop
//D1 - CSet of correct combo to drop
//D2 - delay between frame changing in animation, in frames.
//D3 - D2 - target animation frame for timed combo drop, starting from 0. -1 = no timing needed.
//D4 - number of frames in animation
ffc script TimedColorDropper{
	void run (int cdrop, int csdrop, int cyclespeed, int frame, int numframes){
		int timer=0;
		int origdata = this->Data;
		int curframe=0;
		bool wild = (frame<0);
		while(true){
			if (this->InitD[7] == 0){
				timer++;
				if (timer>=cyclespeed){
					curframe++;
					timer=0;
				}
				if (curframe>=numframes)curframe=0;
				if (wild) frame=curframe;
			}
			if (Link->PressEx1 && RectCollision(Link->X+7, Link->Y+7, Link->X+8, Link->Y+8, this->X, this->Y, this->X+this->EffectWidth-1, this->Y+this->EffectHeight-1)){
				if (Link->Misc[LINK_MISC_COMBO_IN_HAND]>0 && this->InitD[7]==0){
					if (curframe==frame && Link->Misc[LINK_MISC_COMBO_IN_HAND]==cdrop && Link->Misc[LINK_MISC_CSET_IN_HAND]==csdrop){
						Game->PlaySound(SFX_TIMEDROP_SUCCESS);
						this->InitD[7]=1;
						for(int i=1;i<=33;i++){
							if (Screen->State[ST_SECRET]) break;
							if (i==33){
								Game->PlaySound(SFX_SECRET);
								Screen->TriggerSecrets();
								Screen->State[ST_SECRET]=true;
								break;
							}
							ffc n = Screen->LoadFFC(i);
							if (n->Script!=this->Script)continue;
							if (n->InitD[7] == 0) break;
						}
					}
					else{
						if (curframe!=frame) Game->PlaySound(SFX_TIMEDROP_FAIL2);
						if(Link->Misc[LINK_MISC_COMBO_IN_HAND]!=cdrop || Link->Misc[LINK_MISC_CSET_IN_HAND]!=csdrop) Game->PlaySound(SFX_TIMEDROP_FAIL);
					}
					Link->Misc[LINK_MISC_COMBO_IN_HAND]=0;
					Link->Misc[LINK_MISC_CSET_IN_HAND]=0;
				}
			}
			this->Data=origdata+curframe;
			if (this->InitD[7]==1)Screen->FastCombo(2, CenterX(this)-8, CenterY(this)-8, cdrop, csdrop, OP_OPAQUE);
			//if (curframe==frame)Screen->Rectangle(3, this->X, this->Y, this->X+47, this->Y+47, 1, -1, 0, 0, 0, false, OP_OPAQUE);
			Waitframe();
		}		
	}
}