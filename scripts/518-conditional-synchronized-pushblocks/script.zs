const int CMB_SYNC_COND_PUSHBLOCK_SOLID = 1; //ID of combo used to mimic solidity. It must be fully solid and fully transparent.

const int SFX_SYNC_COND_PUSHBLOCK_MOVE = 50; //Sound to play when moving a block.
const int SFX_SYNC_COND_PUSHBLOCK_STUCK = 16;//Sound to play when pushblock gets stuck.

const int SYNC_COND_ICEBLOCK_DAMAGE = 4;//BE VERY CAREFUL WITH SYNCHED ICEBLOCKS. IF ONE HITS LINK FROM BEHIND, HE WILL TAKE DAMAGE, in 1/4ths of heart!

//Synchronized + Conditional Pushable blocks. If Link pushes one, others move in the same direcction, if they can. Works only is specific Sreen D regester is set to specific value
//Set up solid combo with blank tile for CMB_SYNC_COND_PUSHBLOCK_SOLID constant.
//Effect Width and Height used. If TileHeight is greater than EffectHeight / 16, then the script calls SyncCondPush Renderer, so FFC sprite rendering is aligned to bottom edge of FFC`s hitbox.
//D0 - bracelet level requirement.
//D1 - allowed push directions. Add together - 1-up, 2-down, 4-left, 8-right. 0 for all directions.
//D2 - add together: 1 - gets stuck after 1 push, 2 - gets stuck when landing on trigger, 4 - icy block, continue moving in direction until hitting obstacle, 8 - ignore triggers, 16 - require triggers with same CSet as FFC`s Cset, 32 - animation on push (uses next combo in list)
//D3 - sync ID. Pushblocks with same ID are linked.
//D4 - Screen D register to track
//D5 - Target screen D value. 

//SyncCondPushRender
//Renderer for SyncCondPush blocks
//Place, gridsnap, and align on bottom with large pushblock.
//D0 - ID of pushblock FFC

ffc script LargeSyncCondPushBlock{
	void run (int weight, int dirs, int flags, int syncID, int screend, int condstate){
		int origdata= this->Data;
		int cmb=origdata;
		if (this->InitD[1]==0) this->InitD[1]=15;
		int str[] = "SyncCondPushRender";
		int scr = Game->GetFFCScript(str);
		if (this->TileHeight>(this->EffectHeight/16)){
			int args[2] = {FFCNum(this),0};
			ffc r = RunFFCScriptOrQuit(scr, args);
			r->Data = cmb;
			r->X = this->X;
			r->TileWidth = this->TileWidth;
			r->TileHeight=this->TileHeight;
			r->CSet = this->CSet;
			r->Y = this->Y + this->EffectHeight - this->TileHeight*16;
			this->Data = FFCS_INVISIBLE_COMBO;
		}
		int origdirs = this->InitD[1];
		bool stuck=false;
		// else for (int i=1;i<=32;i++){
		// ffc f = Screen->LoadFFC(i);
		// if (f->Script!=scr)continue;
		// if (f->InitD[0]!=FFCNum(this)) continue; 
		// this->Data = FFCS_INVISIBLE_COMBO;
		// break;
		// }		
		int pos = ComboAt (this->X+1, this->Y+1);
		int ucmb[16];
		int ucset[16];
		for (int i=0;i<16;i++){
			ucmb[i] = CMB_SYNC_COND_PUSHBLOCK_SOLID;
			ucset[i] = this->CSet;
		}
		SyncCondPushReplaceCombosUnderFFC(this, ucmb, ucset);
		int pushcounter = 0;
		bool linkmove = false;
		this->InitD[7] = -1;
		this->InitD[5] = -1;
		int movecounter = 0;
		for (int i=0;i<176;i++){
			if (ComboFI(i, CF_BLOCKTRIGGER))Screen->ComboF[i] = CF_BLOCKTRIGGER;
		}
		while(true){
			if (this->InitD[7]<0){	
				if (Screen->D[screend]==condstate && !stuck) this->InitD[1] = origdirs;
				else this->InitD[1]=0;
				if (SyncCondPushBlockIsPushed(this,Link->Dir, 6)){
					pushcounter++;
				}
				else pushcounter = 0;
				if (pushcounter>=8 || this->InitD[5]>=0){
					if (SyncCondPushBlockCanBePushed(this, Cond(this->InitD[5]>=0,this->InitD[5],Link->Dir)) && !EnemiesAlive()){
						NoAction();
						this->InitD[7] = Cond(this->InitD[5]>=0,this->InitD[5],Link->Dir);
						Game->PlaySound(SFX_SYNC_COND_PUSHBLOCK_MOVE);
						movecounter = 16;
						if((flags&4)>0)movecounter = 8;
						for(int i=1;i<=32;i++){
							ffc n = Screen->LoadFFC(i);
							if (n->Script!=this->Script)continue;
							if (n==this)continue;
							if (n->InitD[3]!=this->InitD[3])continue;
							if (!SyncCondPushBlockCanBePushed(n, Link->Dir)) continue;
							if (this->InitD[5]<0)n->InitD[5]=Link->Dir;
						}
						if (this->InitD[5]<0)linkmove=true;
						SyncCondPushReplaceCombosUnderFFC(this, ucmb, ucset);
					}
					else pushcounter = 0;
				}
			}
			else{
				NoAction();
				movecounter--;
				if (this->InitD[7]==DIR_UP){
					this->Y--;
					if (linkmove)Link->Y--;
					if((flags&4)>0){
						this->Y--;
						if (linkmove)Link->Y--;
					}
				}
				if (this->InitD[7]==DIR_DOWN){
					this->Y++;
					if (linkmove)Link->Y++;
					if((flags&4)>0){
						this->Y++;
						if (linkmove)Link->Y++;
					}
				}
				if (this->InitD[7]==DIR_LEFT){
					this->X--;
					if (linkmove)Link->X--;
					if((flags&4)>0){
						this->X--;
						if (linkmove)Link->X--;
					}
				}
				if (this->InitD[7]==DIR_RIGHT){
					this->X++;
					if (linkmove)Link->X++;
					if((flags&4)>0){
						this->X++;
						if (linkmove)Link->X++;
					}
				}
				if (movecounter==0){
					if (this->InitD[5]>=0 && LinkCollision(this) && (flags&4)>0 && SYNC_COND_ICEBLOCK_DAMAGE>0){
						eweapon e = FireEWeapon(EW_SCRIPT10, Link->X+InFrontX(Link->Dir, 12), Link->Y+InFrontY(Link->Dir, 12), 0, 0, SYNC_COND_ICEBLOCK_DAMAGE, -1, -1, EWF_UNBLOCKABLE);
						e->Dir = Link->Dir;
						e->DrawYOffset = -1000;
						SetEWeaponLifespan(e, EWL_TIMER, 1);
						SetEWeaponDeathEffect(e, EWD_VANISH, 0);
					}
					if ((flags&4)>0 && SyncCondPushBlockCanBePushed(this, this->InitD[7])) movecounter=8;
					else{
						if ((flags&1)>0){
							Game->PlaySound(SFX_SYNC_COND_PUSHBLOCK_STUCK);
							stuck=true;
							this->InitD[1]=0;
						}
						SyncCondPushReplaceCombosUnderFFC(this, ucmb, ucset);
						if (linkmove){
							int pos = ComboAt(CenterLinkX(), CenterLinkY()-2);
							if (this->InitD[7]==DIR_UP)Link->Y = ComboY(pos)+8;
							if (this->InitD[7]==DIR_DOWN)Link->Y= ComboY(pos);
							if (this->InitD[7]==DIR_LEFT)Link->X = ComboX(pos);
							if (this->InitD[7]==DIR_RIGHT)Link->X= ComboX(pos);
							linkmove = false;
						}
						this->InitD[7]=-1;
						this->InitD[5]=-1;
						pushcounter = 0;
						if ((flags&8)==0)SyncCondPushTriggerUpdate(this,ucset);
						if ((flags&2)>0 && this->InitD[6]>0){
							Game->PlaySound(SFX_SYNC_COND_PUSHBLOCK_STUCK);
							stuck=true;
							this->InitD[1]=0;
						}
					}
				}
			}
			if (this->Data!=FFCS_INVISIBLE_COMBO && (flags&32)>0){
				if (this->InitD[7]>=0)this->Data=origdata+1;
				else this->Data=origdata;
			}
			Waitframe();
		}
	}
}

//returns true, if Link tries to push this block
bool SyncCondPushBlockIsPushed(ffc this, int dir, int margin){
	if((Link->X == this->X - 16 && (Link->Y < this->Y+this->EffectHeight - 8+margin && Link->Y > this->Y - margin) && Link->InputRight && dir == DIR_RIGHT) || // Right
	(Link->X == this->X + this->EffectWidth && (Link->Y < this->Y+this->EffectHeight - 8+margin && Link->Y > this->Y - margin) && Link->InputLeft && dir == DIR_LEFT) || // Left
	(Link->Y == this->Y - 16 && (Link->X < (this->X + this->EffectWidth-16+margin) && Link->X > this->X - margin) && Link->InputDown && dir == DIR_DOWN) || // Down
	(Link->Y == this->Y + this->EffectHeight-8 && (Link->X < (this->X + this->EffectWidth-16+margin) && Link->X > this->X - margin) && Link->InputUp && dir == DIR_UP)) { // Up
		return true;
	}
	return false;
}

//Returns true, if block can be pushed in the given direction
bool SyncCondPushBlockCanBePushed(ffc this, int dir){
	int weight = this->InitD[0];
	int dirs = this->InitD[1];
	if (dir==DIR_UP){
		if ((dirs&1)==0) return false;
	}
	if (dir==DIR_DOWN){
		if ((dirs&2)==0) return false;
	}
	if (dir==DIR_LEFT){
		if ((dirs&4)==0) return false;
	}
	if (dir==DIR_RIGHT){
		if ((dirs&8)==0) return false;
	}
	int br = GetHighestLevelItemOwned(IC_BRACELET);
	int power = 0;
	if (br>=0){
		itemdata it = Game->LoadItemData(br);
		power = it->Power;
	}
	if (power<weight) return false;
	int x1 = 0;
	int y1 = 0;
	int x2 = 0;
	int y2 = 0;
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
		if (ComboFI(i, CF_NOBLOCKS)) return false;
		if (Screen->ComboS[i]>0)return false;
		int comboS=0;
		if(Screen->LayerMap(1)>0) comboS |= GetLayerComboS(1, i);
		if(Screen->LayerMap(2)>0) comboS |= GetLayerComboS(2, i);
		if(comboS>0)return false;
	}
	return true;
}

//Stores and replaces combos under FFC to mimic solidity.
void SyncCondPushReplaceCombosUnderFFC(ffc this, int ucmb, int ucset){
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

//Checks, if all pushblocks are on triggers and triggers secrets, if it`s true;
void SyncCondPushTriggerUpdate(ffc f, int ucset){
	f->InitD[6]=1;
	for (int i=0;i<16;i++){
		int x = f->X+(i%4)*16;
		if (x>(f->X+f->EffectWidth-1)) continue;
		int y = f->Y+Floor(i/4)*16;
		if (y>(f->Y+f->EffectHeight-1)) continue;
		int cmb = ComboAt(x+1,y+1);
		if (!ComboFI(cmb, CF_BLOCKTRIGGER)) f->InitD[6]=0;
		if ((f->InitD[2]&16)>0 && ucset[i]!=f->CSet)f->InitD[6]=0;
	}
	int str[] = "LargeSyncCondPushBlock";
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
		if (n->InitD[6] == 0) break;
	}
}

//Renderer for SyncCondPush blocks
//D0 - ID of pushblock FFC
ffc script SyncCondPushRender{
	void run (int ID){
		int origdata = this->Data;
		ffc f = Screen->LoadFFC(ID);
		while(true){
			if (Link->Y>=f->Y)this->Flags[FFCF_OVERLAY] =false;
			else this->Flags[FFCF_OVERLAY] =true;
			this->X = f->X;
			this->Y = f->Y + f->EffectHeight - f->TileHeight*16;
			if (((f->InitD[2])&32)>0 && f->InitD[7]>=0)this->Data = origdata+1;
			else this->Data = origdata;
			Waitframe();
		}
	}
}