const int CMB_COLOR_COLUMNS_SOLID= 1; //combo used to mimic solidity.
const int CMB_COLOR_COLUMNS_NONSOLID= 2239; //combo used to mimic non-solid obstacle, must have CF_NOBLOCKS inherent flag (#67).

const int SFX_COLOR_COLUMNS_MOVE = 50; //Sound to play when moving a block.
const int SFX_COLOR_COLUMNS_COLOR_SHIFT = 30;//Sound to play when shifting colors of multicolored block FFC

//Multocolored pushblock. Every time you push it, it shifts colors. Land it on trigger, so every block consisting FFC is on same colored trigger to solve it.

//Effect Width and Height used and is automatically set to be tile dimensions multiplied by 16. Total tiles in FFC must not exceed 4.

//D0 - bracelet level requirement.
//D1 - allowed push directions. Add together - 1-up, 2-down, 4-left, 8-right. 0 for all directions.
//D2-D5 - colors/csets consisting block
//D6 - +1 -> Icy variant, continues moving in direction, +4 - shift ccolors with each push, +8 -> Use next combo in list to render animation when moving.

ffc script SolidColorColumnsBlock{
	void run(int weight, int dirs, int color1, int color2, int color3, int color4, int flags){
		int csets[4] = {color1, color2, color3, color4};
		int origdata = this->Data;
		this->Data=FFCS_INVISIBLE_COMBO;
		this->EffectWidth = this->TileWidth*16;
		this->EffectHeight = this->TileHeight*16;
		int size = this->TileWidth * this->TileHeight;
		int pos = ComboAt (this->X+1, this->Y+1);
		if (dirs==0) dirs=15;
		int ucmb[16];
		int ucset[16];
		for (int i=0;i<16;i++){
			ucmb[i] = CMB_COLOR_COLUMNS_SOLID;
			ucset[i] = this->CSet;
		}
		bool ice = (flags&1)>0;
		bool shiftmanual = (flags&2)>0;
		bool autoshift = (flags&4)>0;
		bool animpush = (flags&8)>0;
		COLOR_COLUMNS_ReplaceCombosUnderFFC(this, ucmb, ucset);
		int pushcounter = 0;
		this->InitD[6] = 0;
		this->InitD[7] = -1;
		int movecounter = 0;
		for (int i=0;i<176;i++){
			if (ComboFI(i, CF_BLOCKTRIGGER))Screen->ComboF[i] = CF_BLOCKTRIGGER;
		}
		while(true){
			if (this->InitD[7]<0){
				if (ColorColumnsIsPushed(this,Link->Dir, 6)){
					if (Link->PressEx2 && shiftmanual){
					Game->PlaySound(SFX_COLOR_COLUMNS_COLOR_SHIFT);
					ArrayShiftRightPartial(csets, 0, size);
					}
					pushcounter++;
				}
				else pushcounter = 0;
				if (pushcounter>=12){
					if (ColorColumnsCanBePushed(this, Link->Dir, weight, dirs) && !EnemiesAlive()){
						this->InitD[7] = Link->Dir;
						Game->PlaySound(SFX_COLOR_COLUMNS_MOVE);
						movecounter = 16;
						if ((this->InitD[4]&2)>0)movecounter=8;
						COLOR_COLUMNS_ReplaceCombosUnderFFC(this, ucmb, ucset);
					}
					else pushcounter = 0;
				}
			}
			else{
				NoAction();
				movecounter--;
				if (this->InitD[7]==DIR_UP){
					this->Y--;
					if (ice)this->Y--;
				}
				if (this->InitD[7]==DIR_DOWN){
					if (ice)this->Y++;
					this->Y++;
				}
				if (this->InitD[7]==DIR_LEFT){
					if (ice)this->X--;
					this->X--;
				}
				if (this->InitD[7]==DIR_RIGHT){
					if (ice)this->X++;
					this->X++;
				}
				if (movecounter==0){
					if (autoshift)ArrayShiftRightPartial(csets, 0, size);
					if (IceColorColumnsCanContinueSlide(this)) movecounter=8;
					else{
						pos = ComboAt (this->X+1, this->Y+1);					
						this->InitD[7]=-1;
						COLOR_COLUMNS_ReplaceCombosUnderFFC(this, ucmb, ucset);
						ColorColumnsTriggerUpdate(this, csets, ucset);
					}
				}
			}
			int drawcmb = origdata;
			if (animpush && this->InitD[7]>=0) drawcmb++;
			int drawcset = 0;
			for (int i=0; i<16; i++){
				if ((i%4)>=(this->TileWidth )) continue;
				if (Floor(i/4) >=(this->TileHeight )) continue;
				int x = this->X+(i%4)*16;
				int y = this->Y+Floor(i/4)*16;
				//Screen->Rectangle(3, x, y, x+15, y+15, 1, -1, 0, 0, 0, false, OP_OPAQUE);
				Screen->FastCombo(1, x,y, drawcmb, csets[drawcset], OP_OPAQUE);
				drawcset++;
			}
			Waitframe();
		}
	}
}

//returns true, if Link tries to push this block
bool ColorColumnsIsPushed(ffc this, int dir, int margin){
	if((Link->X == this->X - 16 && (Link->Y < this->Y+this->EffectHeight - 8+margin && Link->Y > this->Y - margin) && Link->InputRight && dir == DIR_RIGHT) || // Right
	(Link->X == this->X + this->EffectWidth && (Link->Y < this->Y+this->EffectHeight - 8+margin && Link->Y > this->Y - margin) && Link->InputLeft && dir == DIR_LEFT) || // Left
	(Link->Y == this->Y - 16 && (Link->X < (this->X + this->EffectWidth-16+margin) && Link->X > this->X - margin) && Link->InputDown && dir == DIR_DOWN) || // Down
	(Link->Y == this->Y + this->EffectHeight-8 && (Link->X < (this->X + this->EffectWidth-16+margin) && Link->X > this->X - margin) && Link->InputUp && dir == DIR_UP)) { // Up
		return true;
	}
	return false;
}

//Returns true, if block can be pushed in the given direction
bool ColorColumnsCanBePushed(ffc this, int dir, int weight, int dirs){
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
		if (ComboFI(i, CF_NOBLOCKS))return false;
		if (Screen->ComboS[i]>0)return false;
		int comboS=0;
		if(Screen->LayerMap(1)>0) comboS |= GetLayerComboS(1, i);
		if(Screen->LayerMap(2)>0) comboS |= GetLayerComboS(2, i);
		if(comboS>0)return false;
	}
	return true;
}

//Returns true if Icy klotski block can continue slide
bool IceColorColumnsCanContinueSlide(ffc f){
	int dir = f->InitD[7];
	if ((f->InitD[4]&2)==0)return false;
	if (!ColorColumnsCanBePushed(f, dir, 0, 15)){
		if (f->InitD[7]!=dir)return true;
		else return false;
	}
	for (int i=0;i<176;i++){
		int cx1 = ComboX(i);
		int cy1 = ComboY(i);
		int cx2 = cx1+15;
		int cy2 = cy1+15;
		int fx1 = f->X+1;
		int fy1 = f->Y+1;
		int fx2 = f->X+f->EffectWidth-1;
		int fy2 = f->Y+f->EffectHeight-1;
		if (!RectCollision(fx1,fy1,fx2,fy2,cx1,cy1,cx2,cy2))continue;
	}
	return false;
}

//Stores and replaces combos under FFC to mimic solidity.
void COLOR_COLUMNS_ReplaceCombosUnderFFC(ffc this, int ucmb, int ucset){
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

//Non-solid ColorColumns puzzle block. Stand on it, face desired direction and press EX1 to move it. 
//Land all such blocks, so every block consisting FFC is on same colored trigger to solve it.

//Effect Width and Height used and is automatically set to be tile dimensions multiplied by 16. Total tile area must not exceed 4

//D0 - bracelet level requirement.
//D1 - allowed push directions. Add together - 1-up, 2-down, 4-left, 8-right. 0 for all directions.
//D2-D5 - colors/csets consisting block
//D6 - +1 -> Icy variant, continues moving in direction, +2 - allow shift colors by standing on it and press EX2, +4 - shift ccolors with each push, +8 -> Use next combo in list to render animation when moving.

ffc script NonSolidColorColumnsBlock{
	void run(int weight, int dirs, int color1, int color2, int color3, int color4, int flags){
		int csets[4] = {color1, color2, color3, color4};
		int origdata = this->Data;
		this->Data=FFCS_INVISIBLE_COMBO;
		this->EffectWidth = this->TileWidth*16;
		this->EffectHeight = this->TileHeight*16;
		int size = this->TileWidth * this->TileHeight;
		if (dirs==0) dirs=15;
		bool ice = (flags&1)>0;
		bool shiftmanual = (flags&2)>0;
		bool autoshift = (flags&4)>0;
		bool animpush = (flags&8)>0;
		int pos = ComboAt (this->X+1, this->Y+1);
		int ucmb[16];
		int ucset[16];
		for (int i=0;i<16;i++){
			ucmb[i] = CMB_COLOR_COLUMNS_NONSOLID;
			ucset[i] = this->CSet;
		}
		for (int i=0;i<176;i++){
			if (ComboFI(i, CF_BLOCKTRIGGER))Screen->ComboF[i] = CF_BLOCKTRIGGER;
		}
		COLOR_COLUMNS_ReplaceCombosUnderFFC(this, ucmb, ucset);
		this->InitD[6] = 0;
		this->InitD[7] = -1;
		int movecounter = 0;
		while(true){
			if (this->InitD[7]<0){
				if (RectCollision(Link->X+7, Link->Y+7, Link->X+8, Link->Y+8, this->X, this->Y, this->X+this->EffectWidth-1, this->Y+this->EffectHeight-1)){
					if (Link->PressEx2 && shiftmanual){	
					Game->PlaySound(SFX_COLOR_COLUMNS_COLOR_SHIFT);
						ArrayShiftRightPartial(csets, 0, size);
						ColorColumnsTriggerUpdate(this, csets, ucset);
					}
					if (Link->PressEx1){
						if (ColorColumnsCanBePushed(this, Link->Dir, weight, dirs)){
							this->InitD[7] = Link->Dir;
							Game->PlaySound(SFX_COLOR_COLUMNS_MOVE);
							movecounter = 16;
							if ((this->InitD[4]&2)>0)movecounter=8;
							COLOR_COLUMNS_ReplaceCombosUnderFFC(this, ucmb, ucset);
						}
					}
				}
			}
			else{
				NoAction();
				movecounter--;
				if (this->InitD[7]==DIR_UP){
					this->Y--;
					if (ice)this->Y--;
				}
				if (this->InitD[7]==DIR_DOWN){
					if (ice)this->Y++;
					this->Y++;
				}
				if (this->InitD[7]==DIR_LEFT){
					if (ice)this->X--;
					this->X--;
				}
				if (this->InitD[7]==DIR_RIGHT){
					if (ice)this->X++;
					this->X++;
				}
				if (movecounter==0){
					if (autoshift)ArrayShiftRightPartial(csets, 0, size);
					if (IceColorColumnsCanContinueSlide(this)) movecounter=8;
					else{
						pos = ComboAt (this->X+1, this->Y+1);					
						this->InitD[7]=-1;
						COLOR_COLUMNS_ReplaceCombosUnderFFC(this, ucmb, ucset);
						ColorColumnsTriggerUpdate(this, csets, ucset);
					}
				}
			}
			int drawcmb = origdata;
			if (animpush && this->InitD[7]>=0) drawcmb++;
			int drawcset = 0;
			for (int i=0; i<16; i++){
				if ((i%4)>=(this->TileWidth )) continue;
				if (Floor(i/4) >=(this->TileHeight )) continue;
				int x = this->X+(i%4)*16;
				int y = this->Y+Floor(i/4)*16;
				Screen->FastCombo(1, x,y, drawcmb, csets[drawcset], OP_OPAQUE);
				drawcset++;
			}
			Waitframe();
		}
	}
}

//Checks, if all pushblocks are on triggers and triggers secrets, if it`s true;
void ColorColumnsTriggerUpdate(ffc f, int color, int ucset){
	f->InitD[6]=1;
	int chcset = 0;
	for (int i=0; i<16; i++){
		if ((i%4)>=(f->TileWidth )) continue;
		if (Floor(i/4) >=(f->TileHeight )) continue;
		int x = f->X+(i%4)*16;
		int y = f->Y+Floor(i/4)*16;
		int cmb = ComboAt(x+1,y+1);
		if (!ComboFI(cmb,66)) f->InitD[6]=0;
		if (ucset[chcset]!=color[chcset]) f->InitD[6]=0;
		chcset++;
	}
	for(int i=1;i<=33;i++){
		if (Screen->State[ST_SECRET]) break;
		if (i==33){
			Game->PlaySound(SFX_SECRET);
			Screen->TriggerSecrets();
			Screen->State[ST_SECRET]=true;
			break;
		}
		ffc n = Screen->LoadFFC(i);
		if (n->Script!=f->Script)continue;
		if (n->InitD[6]==0)break;
	}
}

//Shifts part the given array rightwards with rotation.
void ArrayShiftRightPartial(int arr, int pos, int size){
	int lasti = pos+size-1;
	int res = arr[lasti];
	for(int i = lasti; i>pos; i--){
		arr[i] = arr[i-1];
	}
	arr[pos]=res;
}

//Shifts part the given array leftwards with rotation.
void ArrayShiftLeftPartial(int arr, int pos, int size){
	int lasti = pos+size-1;
	int res = arr[pos];
	for(int i = pos; i<lasti; i++){
		arr[i] = arr[i+1];
	}
	arr[lasti]=res;
}