const int CMB_IRON_BEAM_SOLID = 1; //ID of combo used to mimic solidity. It must be fully solid and fully transparent.

const int SFX_IRON_BEAM_MOVE = 50; //Sound to play when moving a block.
const int SFX_IRON_BEAM_STUCK = 16;//Sound to play when block gets stuck.

const int SFX_MAGNET_PICK = 4;//Sound to play,when liftable combo is picked.
const int SFX_MAGNET_PLACE = 16;//Sound to play,when liftable combo is placed.
const int SFX_MAGNET_SWITCH = 16;

const int CT_MAGNET_LIFTABLE = 142;//Combo that is defined as liftable magnet
const int CT_MAGNET_SWITCH = 143;//Combo that is defined as static magnet

//Magnets and Iron Beams puzzle
//You have a couple of differently oriented horseshoe-shaped magnets. A path forward is barricaded by super-heavy iron beams, so heavy, that even Gods cannot push them.
//You can lift and place magnets. if you place a magnet in such a way, that his poles point at iron beam via straight, unobstructed line,
//the beam starts moving torwards magnet, until either hit a solid combo, or touch a magnet itself, which causes both beam and magnet to be completely stuck and immobile.
//
//Set ip 4 consecutive magnet combos: up-down-left-right. You can set up 5th one for 4-way magnet.
//Compile and assign 3 FFC scripts.
//
//IronBeam 
//EffectWidth and EffectHeight used
//D0 - >0 -disable magnet locking 
//D1 - land all iron beams with this argument set to >0 onto flags #66 to trigger secrets 
//
//PickPlaceMagnets
//Place invicible FFC anywhere in the screen.
//D0 - ID of 1st combo in sequence for magnets. 0 to use FFC`s combo
//
//StaticMagnetSwitch Attracts iron beams, when activated either by standing on and pressing EX1, or just stepped on.
//
//Place invicible FFC anywhere in the screen.
//D0 - ID of 1st combo in sequence for magnets. 0 to use FFC`s combo
//D1 - 0 - Ex1 activated, 1 - step activated. 

ffc script IronBeam{
	void run (int lockmagnet, int secrets){
		int origdata= this->Data;
		int pos = ComboAt (this->X+1, this->Y+1);
		int ucmb[16];
		int ucset[16];
		for (int i=0;i<16;i++){
			ucmb[i] = CMB_IRON_BEAM_SOLID;
			ucset[i] = this->CSet;
		}
		IBeamPushReplaceCombosUnderFFC(this, ucmb, ucset);
		this->InitD[7] = -1;
		int movecounter = 0;
		for (int i=0;i<176;i++){
			if (ComboFI(i, CF_BLOCKTRIGGER))Screen->ComboF[i] = CF_BLOCKTRIGGER;
		}
		while(true){
			if (movecounter==0){
				if (this->InitD[7]>=0){
					if (IBeamCanBePushed(this) && !EnemiesAlive()){
						Game->PlaySound(SFX_IRON_BEAM_MOVE);
						movecounter = 8;
						IBeamPushReplaceCombosUnderFFC(this, ucmb, ucset);
					}
					else this->InitD[7]=-1;;
				}
			}
			else{
				NoAction();
				movecounter--;
				if (this->InitD[7]==DIR_UP) this->Y-=2;
				if (this->InitD[7]==DIR_DOWN) this->Y+=2;
				if (this->InitD[7]==DIR_LEFT) this->X-=2;
				if (this->InitD[7]==DIR_RIGHT) this->X+=2;
				if (movecounter==0){
					if (IBeamCanBePushed(this)){
						movecounter=8;
					}
					else{
						IBeamPushReplaceCombosUnderFFC(this, ucmb, ucset);
						this->InitD[7]=-1;
						if (secrets>0)IronBeamTriggerUpdate(this);
						if (this->InitD[6]>0){
							Game->PlaySound(SFX_IRON_BEAM_STUCK);
							Quit();
						}
					}
				}
			}
			//debugValue(FFCNum(this), this->InitD[7]);
			Waitframe();
		}
	}
}

ffc script PickPlaceMagnets{
	void run (int origcmb){
	if (origcmb==0)origcmb=this->Data;
		int carrycmb=0;
		int carrycset=0;
		int cmb = ComboAt(CenterLinkX(), CenterLinkY());
		while(true){
			cmb = ComboAt(CenterLinkX(), CenterLinkY());
			if (Link->PressEx1){
				if (carrycmb==0 && !ComboFI(cmb, CF_NOBLOCKS)  &&  Screen->ComboT[cmb]==CT_MAGNET_LIFTABLE){
					Game->PlaySound(SFX_MAGNET_PICK);
					carrycmb=Screen->ComboD[cmb];
					carrycset = Screen->ComboC[cmb];
					Screen->ComboD[cmb]=Screen->UnderCombo;
					Screen->ComboC[cmb]=Screen->UnderCSet;
				}
				else if (!ComboFI(cmb, CF_NOBLOCKS) && Screen->ComboT[cmb]!=CT_MAGNET_LIFTABLE && carrycmb>0){
					Game->PlaySound(SFX_MAGNET_PLACE);
					Screen->ComboD[cmb]=carrycmb;
					Screen->ComboC[cmb]=carrycset;
					carrycmb=0;
					carrycset = 0;
					int dir = Screen->ComboD[cmb] - origcmb;
					if (dir==4){
						for (int i=0;i<4;i++){
							int mx = ComboX(cmb);
							int my = ComboY(cmb);
							while(true){
								if (i==DIR_UP){
									my-=16;
									if (my<0) break;
								}
								if (i==DIR_DOWN){
									my+=16;
									if (my>=176)break;
								}
								if (i==DIR_LEFT){
									mx-=16;
									if (mx<0)break;
								}
								if (i==DIR_RIGHT){
									mx+=16;
									if (mx>=256)break;
								}
								int mcmb = ComboAt(mx,my);
								if (Screen->ComboD[mcmb]==CMB_IRON_BEAM_SOLID){
									int str[] = "IronBeam";
									int scr = Game->GetFFCScript(str);
									for (int j=1;j<=32;j++){
										ffc f = Screen->LoadFFC(j);
										if (f->Script!=scr)continue;
										if (RectCollision(mx+1, my+1, mx+2, my+2, f->X, f->Y, f->X+f->EffectWidth-1, f->Y+f->EffectHeight-1)){
											f->InitD[7]=OppositeDir(i);
											while(f->Script==scr && f->InitD[7]>=0)WaitNoAction();
											break;
										}
									}
									break;
								}
								else if (Screen->ComboS[mcmb]>0)break;
							}
						}
					}
					else{
						int mx = ComboX(cmb);
						int my = ComboY(cmb);
						while(true){
							if (dir<0 || dir>3){
								break;
							}
							if (dir==DIR_UP){
								my-=16;
								if (my<0) break;
							}
							if (dir==DIR_DOWN){
								my+=16;
								if (my>=176)break;
							}
							if (dir==DIR_LEFT){
								mx-=16;
								if (mx<0)break;
							}
							if (dir==DIR_RIGHT){
								mx+=16;
								if (mx>=256)break;
							}
							int mcmb = ComboAt(mx,my);
							if (Screen->ComboD[mcmb]==CMB_IRON_BEAM_SOLID){
								int str[] = "IronBeam";
								int scr = Game->GetFFCScript(str);
								for (int i=1;i<=32;i++){
									ffc f = Screen->LoadFFC(i);
									if (f->Script!=scr)continue;
									if (RectCollision(mx+1, my+1, mx+2, my+2, f->X, f->Y, f->X+f->EffectWidth-1, f->Y+f->EffectHeight-1)){
										f->InitD[7]=OppositeDir(dir);
										break;
									}
								}
								break;
							}
							else if (Screen->ComboS[mcmb]>0)break;
						}
					}
				}
			}
			if (carrycmb>0)Screen->FastCombo(3, Link->X, Link->Y-8, carrycmb, carrycset, OP_OPAQUE);
			Waitframe();
		}
	}
}

//Stores and replaces combos under FFC to mimic solidity.
void IBeamPushReplaceCombosUnderFFC(ffc this, int ucmb, int ucset){
	int x1 = this->X+1;
	int y1 = this->Y+1;
	int x2 = x1+this->EffectWidth-2;
	int y2 = y1+this->EffectHeight-2;
	int arr=0;
	for (int i=0;i<176;i++){
		int cx1 = ComboX(i);
		int cy1 = ComboY(i);
		int cx2 = cx1+15;
		int cy2 = cy1+15;
		if (!RectCollision(x1,y1,x2,y2,cx1,cy1,cx2,cy2))continue;
		int rcmb = Screen->ComboD[i];
		int rcset = Screen->ComboC[i];
		Screen->ComboD[i] = ucmb[arr];
		Screen->ComboC[i] = ucset[arr];
		ucmb[arr] = rcmb;
		ucset[arr]=rcset;
		arr++;
	}
}

//Returns true, if block can be pushed in the given direction
bool IBeamCanBePushed(ffc this){
	int dir = this->InitD[7];
	int x1 = 0;
	int y1 = 0;
	int x2 = 0;
	int y2 = 0;
	int comboS=0;
	if (dir==DIR_UP){
		x1 = this->X+1;
		y1 = this->Y-15;
		x2 = this->X+this->EffectWidth-2;
		y2 = this->Y-1;
	}
	if (dir==DIR_DOWN){
		x1 = this->X+1;
		y1 = this->Y+ this->EffectHeight+1;
		x2 = this->X+this->EffectWidth-2;
		y2 = y1+14;
	}
	if (dir==DIR_LEFT){
		x1 = this->X-14;
		y1 = this->Y+1;
		x2 = this->X-1;
		y2 = y1+this->EffectHeight-3;
	}
	if (dir==DIR_RIGHT){
		x1 = this->X+this->EffectWidth+1;
		y1 = this->Y+1;
		x2 = x1+14;
		y2 = y1+this->EffectHeight-3;
	}
	for (int i=0;i<176;i++){
		int cx1 = ComboX(i);
		int cy1 = ComboY(i);
		int cx2 = cx1+15;
		int cy2 = cy1+15;
		if (!RectCollision(x1,y1,x2,y2,cx1,cy1,cx2,cy2))continue;
		if (ComboFI(i, CF_NOBLOCKS)) comboS=1;
		if (Screen->ComboT[i]==CT_MAGNET_LIFTABLE || Screen->ComboT[i]==CT_MAGNET_SWITCH){
			if (this->InitD[0]==0){
				Screen->ComboF[i]= CF_NOBLOCKS;
				this->InitD[6]=1;
			}
			int str[] = "PickPlaceMagnets";
			int scr = Game->GetFFCScript(str);
			int str1[] = "StaticMagnetSwitch";
			int scr2 = Game->GetFFCScript(str1);
			for (int r=1;r<=32;r++){
				ffc p = Screen->LoadFFC(r);
				if (p->Script!=scr && p->Script!=scr2)continue;
				int changecmb = p->InitD[0];
				if (changecmb==0)changecmb = p->Data;
				if (Screen->ComboD[i]!=changecmb+4)Screen->ComboD[i]=changecmb+OppositeDir(dir);
			}
			comboS=1;
		}
		if (Screen->ComboS[i]>0)comboS=1;
		if(Screen->LayerMap(1)>0) comboS |= GetLayerComboS(1, i);
		if(Screen->LayerMap(2)>0) comboS |= GetLayerComboS(2, i);
	}
	if(comboS>0)return false;
	return true;
}		

//Fixed variant of AdjacentCombo function from std_extension.zh
// int AdjacentComboFix(int cmb, int dir)
// {
	// int combooffsets[13]={-0x10, 0x10, -1, 1, -0x11, -0x0F, 0x0F, 0x11};
	// if ( cmb % 16 == 0 ) combooffsets[9] = -1;//if it's the left edge
	// if ( (cmb % 16) == 15 ) combooffsets[10] = -1; //if it's the right edge
	// if ( cmb < 0x10 ) combooffsets[11] = -1; //if it's the top row
	// if ( cmb > 0x9F ) combooffsets[12] = -1; //if it's on the bottom row
	// if ( combooffsets[9]==-1 && ( dir == DIR_LEFT || dir == DIR_LEFTUP || dir == DIR_LEFTDOWN ) ) return -1; //if the left columb
	// if ( combooffsets[10]==-1 && ( dir == DIR_RIGHT || dir == DIR_RIGHTUP || dir == DIR_RIGHTDOWN ) ) return -1; //if the right column
	// if ( combooffsets[11]==-1 && ( dir == DIR_UP || dir == DIR_RIGHTUP || dir == DIR_LEFTUP ) ) return -1; //if the top row
	// if ( combooffsets[12]==-1 && ( dir == DIR_DOWN || dir == DIR_RIGHTDOWN || dir == DIR_LEFTDOWN ) ) return -1; //if the bottom row
	// if ( cmb >= 0 && cmb < 176 ) return cmb + combooffsets[dir];
	// else return -1;
// }		

//Checks, if all pushblocks are on triggers and triggers secrets, if it`s true;
void IronBeamTriggerUpdate(ffc f){
	f->InitD[5]=1;
	for (int i=0;i<16;i++){
		int x = f->X+(i%4)*16;
		if (x>(f->X+f->EffectWidth-1)) continue;
		int y = f->Y+Floor(i/4)*16;
		if (y>(f->Y+f->EffectHeight-1)) continue;
		int cmb = ComboAt(x+1,y+1);
		if (!ComboFI(cmb, CF_BLOCKTRIGGER)) f->InitD[5]=0;
	}
	int str[] = "IronBeam";
	int scr = Game->GetFFCScript(str);
	for(int i=1;i<=33;i++){
		if (Screen->State[ST_SECRET]) break;
		if (i==33){
			Game->PlaySound(SFX_SECRET);
			Screen->TriggerSecrets();
			Screen->State[ST_SECRET]=true;
			break;
		}
		ffc n = Screen->LoadFFC(i);
		if (n->Script!=scr)continue;
		if (n->InitD[1]==0)continue;
		if (n->InitD[5] == 0) break;
	}
}

//Static Magnets. Cannot be moved, only activated by stepping on, and, if needed, press Ex1.

ffc script StaticMagnetSwitch{
	void run (int origcmb, int step){
	if (origcmb==0)origcmb=this->Data;
		int cmb = ComboAt(CenterLinkX(), CenterLinkY());
		while(true){
			int cmb = ComboAt(CenterLinkX(), CenterLinkY());
			if (Screen->ComboT[cmb]==CT_MAGNET_SWITCH &&(step>0 || Link->PressEx1)&& !MagnetActive()){
				int dir = Screen->ComboD[cmb] - origcmb;
				if (dir==4){
					for (int i=0;i<4;i++){
						int mx = ComboX(cmb);
						int my = ComboY(cmb);
						while(true){
							if (i==DIR_UP){
								my-=16;
								if (my<0) break;
							}
							if (i==DIR_DOWN){
								my+=16;
								if (my>=176)break;
							}
							if (i==DIR_LEFT){
								mx-=16;
								if (mx<0)break;
							}
							if (i==DIR_RIGHT){
								mx+=16;
								if (mx>=256)break;
							}
							int mcmb = ComboAt(mx,my);
							if (Screen->ComboD[mcmb]==CMB_IRON_BEAM_SOLID){
								int str[] = "IronBeam";
								int scr = Game->GetFFCScript(str);
								for (int j=1;j<=32;j++){
									ffc f = Screen->LoadFFC(j);
									if (f->Script!=scr)continue;
									if (RectCollision(mx+1, my+1, mx+2, my+2, f->X, f->Y, f->X+f->EffectWidth-1, f->Y+f->EffectHeight-1)){
										f->InitD[7]=OppositeDir(i);
										while(f->Script==scr && f->InitD[7]>=0)WaitNoAction();
										break;
									}
								}
								break;
							}
							else if (Screen->ComboS[mcmb]>0)break;
						}
					}
				}
				else{
					int mx = ComboX(cmb);
					int my = ComboY(cmb);
					while(true){
						if (dir<0 || dir>3){
							break;
						}
						if (dir==DIR_UP){
							my-=16;
							if (my<0) break;
						}
						if (dir==DIR_DOWN){
							my+=16;
							if (my>=176)break;
						}
						if (dir==DIR_LEFT){
							mx-=16;
							if (mx<0)break;
						}
						if (dir==DIR_RIGHT){
							mx+=16;
							if (mx>=256)break;
						}
						int mcmb = ComboAt(mx,my);
						if (Screen->ComboD[mcmb]==CMB_IRON_BEAM_SOLID){
							int str[] = "IronBeam";
							int scr = Game->GetFFCScript(str);
							for (int i=1;i<=32;i++){
								ffc f = Screen->LoadFFC(i);
								if (f->Script!=scr)continue;
								if (RectCollision(mx+1, my+1, mx+2, my+2, f->X, f->Y, f->X+f->EffectWidth-1, f->Y+f->EffectHeight-1)){
									f->InitD[7]=OppositeDir(dir);
									break;
								}
							}
							break;
						}
						else if (Screen->ComboS[mcmb]>0)break;
					}
				}
			}
			Waitframe();
		}
	}
}

bool MagnetActive(){
	int str[] = "IronBeam";
	int scr = Game->GetFFCScript(str);
	for (int i=1;i<=32;i++){
		ffc f = Screen->LoadFFC(i);
		if (f->Script!=scr)continue;
		if (f->InitD[7]>=0) return true;
	}
	return false;
}