const int CMB_TIMED_PUSHBLOCK_SOLID = 1; //ID of combo used to mimic solidity. It must be fully solid and fully transparent.

const int SFX_TIMED_PUSHBLOCK_MOVE = 50; //Sound to play when moving a block.
const int SFX_TIMED_PUSHBLOCK_STUCK = 16;//Sound to play when pushblock gets stuck.
const int SFX_TIMED_PUSHBLOCK_DEFUSE = 58;//Sound to play when pushblock is defused by landing on trigger

const int SPR_TIMED_PUSHBLOCK_VANISH = 22;//Sprite to display on harmless vanish.
const int SPR_TIMED_PUSHBLOCK_DEFUSE = 22;//Sprite to display on defusing bomd pushblock.

//Time limited pushblocks. Push them all on triggers before they go boom. Straight from Goof Troop (SNES).
//Set up solid combo with blank tile for CMB_TIMED_PUSHBLOCK_SOLID constant.
//Effect Width and Height used. 
//D0 - bracelet level requirement.
//D1 - allowed push directions. Add together - 1-up, 2-down, 4-left, 8-right. 0 for all directions.
//D2 - add together: 1 - gets stuck after 1 push, 2 - gets stuck when landing on trigger (disarms timer), 4 - icy block, continue moving in direction until hitting obstacle, 8 - ignore triggers, 16 - require triggers with same CSet as FFC`s Cset. 32 - Start timer at screen init, 64 - defuse bomb by landing on trigger, 128 - superbomb explosion
//D3 - delay between frames, in frames,
//D4 - Number of frames
//D5 - Damage by explosion. 0 for simple vanish.

ffc script TimeLimitedPushBlock{
	void run (int weight, int dirs, int flags, int time, int numframes, int damage){
		int origdata= this->Data;
		int timer = -1;		
		int pos = ComboAt (this->X+1, this->Y+1);
		if (dirs==0) dirs=15;
		int ucmb[16];
		int ucset[16];
		for (int i=0;i<16;i++){
			ucmb[i] = CMB_TIMED_PUSHBLOCK_SOLID;
			ucset[i] = this->CSet;
		}
		TimedPushReplaceCombosUnderFFC(this, ucmb, ucset);
		int pushcounter = 0;
		int impulse = -1;
		int movecounter = 0;
		for (int i=0;i<176;i++){
			if (ComboFI(i, CF_BLOCKTRIGGER))Screen->ComboF[i] = CF_BLOCKTRIGGER;
		}
		if ((flags&32)>0)timer=Abs(time);
		while(true){
			if (impulse<0){
				if (TimedPushBlockIsPushed(this,Link->Dir, 6))pushcounter++;
				else pushcounter = 0;
				if (pushcounter>=8){
					if (TimedPushBlockCanBePushed(this, Link->Dir, weight, dirs) && !EnemiesAlive()){
						impulse = Link->Dir;
						Game->PlaySound(SFX_TIMED_PUSHBLOCK_MOVE);
						movecounter = 16;
						if((flags&4)>0)movecounter = 8;
						TimedPushReplaceCombosUnderFFC(this, ucmb, ucset);
						if (timer<0)timer=Abs(time);
					}
					else pushcounter = 0;
				}
			}
			else{
				NoAction();
				movecounter--;
				if (impulse==DIR_UP){
					this->Y--;
					if((flags&4)>0)this->Y--;
				}
				if (impulse==DIR_DOWN){
					if((flags&4)>0)this->Y++;
					this->Y++;
				}
				if (impulse==DIR_LEFT){
					this->X--;
					if((flags&4)>0)this->X--;
				}
				if (impulse==DIR_RIGHT){
					this->X++;
					if((flags&4)>0)this->X++;
				}
				if (movecounter==0){
					if ((flags&4)>0 && TimedPushBlockCanBePushed(this, impulse, 0, dirs)) movecounter=8;
					else{
						pos = ComboAt (this->X+1, this->Y+1);
						if ((flags&1)>0){
							Game->PlaySound(SFX_TIMED_PUSHBLOCK_STUCK);
							dirs=0;
						}
						TimedPushReplaceCombosUnderFFC(this, ucmb, ucset);
						impulse=-1;
						if ((flags&8)==0)TimedPushTriggerUpdate(this, ucset);
						if ((flags&2)>0 && this->InitD[6]>0){
							Game->PlaySound(SFX_TIMED_PUSHBLOCK_STUCK);
							dirs=0;
						}
						if (((flags&64)>0) && (this->InitD[6]>0) ){
							Game->PlaySound(SFX_TIMED_PUSHBLOCK_DEFUSE);
							lweapon s = CreateLWeaponAt(LW_SPARKLE, ComboX(pos), ComboY(pos));
							s->UseSprite(SPR_TIMED_PUSHBLOCK_DEFUSE);
							s->CollDetection=false;
							timer=-1;
						}
					}
				}
			}
			if (timer>0){
				timer--;
				if (timer==0){
					numframes--;
					if (numframes>0){
						this->Data++;
						timer = Abs(time);
					}
					else{
						if (impulse<0){
							TimedPushReplaceCombosUnderFFC(this, ucmb, ucset);
						}
						impulse=-1;
						movecounter=0;
						if ((flags&64)==0) this->InitD[6]=0;
						if (damage>0){
							Game->PlaySound(3);
							lweapon l;
							eweapon e;
							if ((flags&128)>0){
								l = CreateLWeaponAt(LW_SBOMBBLAST,this->X, this->Y);
								e = CreateEWeaponAt(EW_SBOMBBLAST,this->X, this->Y);
							}
							else{
								l = CreateLWeaponAt(LW_BOMBBLAST,this->X, this->Y);
								e = CreateEWeaponAt(EW_BOMBBLAST,this->X, this->Y);
							}
							l->Damage=damage;
							e->Damage=damage;
						}
						else{
							lweapon s = CreateLWeaponAt(LW_SPARKLE, ComboX(pos), ComboY(pos));
							s->UseSprite(SPR_TIMED_PUSHBLOCK_VANISH);
							s->CollDetection=false; 
						}
						this->Data = FFCS_INVISIBLE_COMBO;
					}
				}
			}
			int drawx = this->X;
			int drawy = this->Y + this->EffectHeight - this->TileHeight*16;
			Waitframe();
		}
	}
}

//returns true, if Link tries to push this block
bool TimedPushBlockIsPushed(ffc this, int dir, int margin){
	if((Link->X == this->X - 16 && (Link->Y < this->Y+this->EffectHeight - 8+margin && Link->Y > this->Y - margin) && Link->InputRight && dir == DIR_RIGHT) || // Right
	(Link->X == this->X + this->EffectWidth && (Link->Y < this->Y+this->EffectHeight - 8+margin && Link->Y > this->Y - margin) && Link->InputLeft && dir == DIR_LEFT) || // Left
	(Link->Y == this->Y - 16 && (Link->X < (this->X + this->EffectWidth-16+margin) && Link->X > this->X - margin) && Link->InputDown && dir == DIR_DOWN) || // Down
	(Link->Y == this->Y + this->EffectHeight-8 && (Link->X < (this->X + this->EffectWidth-16+margin) && Link->X > this->X - margin) && Link->InputUp && dir == DIR_UP)) { // Up
		return true;
	}
	return false;
}

//Returns true, if block can be pushed in the given direction
bool TimedPushBlockCanBePushed(ffc this, int dir, int weight, int dirs){
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
void TimedPushReplaceCombosUnderFFC(ffc this, int ucmb, int ucset){
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
void TimedPushTriggerUpdate(ffc f, int ucset){
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
	int str[] = "TimeLimitedPushBlock";
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
		if (n->InitD[6] <= 0) break;
	}
}