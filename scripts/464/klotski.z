const int CMB_KLOTSKI_SOLID= 1; //combo used to mimic solidity.
const int CMB_KLOTSKI_NONSOLID= 2239; //combo used to mimic non-solid obstacle, must have CF_NOBLOCKS inherent flag (#67).

const int CF_KLOTSKI_ICE_STOP = 98;//Combo flag to define non-solid catcher for ice blocks.
const int CF_KLOTSKI_ICE_STOP_PLUS_TRIGGER = 99;//Combo flag to define non-solid catcher for ice blocks and trigger in the same combo position.

const int SFX_KLOTSKI_MOVE = 50; //Sound to play when moving a block.

//Large Pushable blocks. Push it on same-colored trigger.

//Effect Width and Height used and is automatically set to be tile dimensions multiplied by 16.

//D0 - bracelet level requirement.
//D1 - allowed push directions. Add together - 1-up, 2-down, 4-left, 8-right. 0 for all directions.
//D2 - 1 - require same-colord trigger combo for trigger secrets. 
//D3 - 0 - not count for trigger
//D4 - +1 - allow pushing onto same-colored #67 flags, +2 -> Icy variant, continues moving in direction.

ffc script SolidKlotskiBlock{
	void run(int weight, int dirs, int colortrigger, int trigger , int colorblock){
		this->EffectWidth = this->TileWidth*16;
		this->EffectHeight = this->TileHeight*16;
		int pos = ComboAt (this->X+1, this->Y+1);
		if (dirs==0) dirs=15;
		int ucmb[16];
		int ucset[16];
		for (int i=0;i<16;i++){
			ucmb[i] = CMB_KLOTSKI_SOLID;
			ucset[i] = this->CSet;
		}
		KLOTSKI_ReplaceCombosUnderFFC(this, ucmb, ucset);
		int pushcounter = 0;
		this->InitD[7] = -1;
		int movecounter = 0;
		for (int i=0;i<176;i++){
			if (ComboFI(i, CF_KLOTSKI_ICE_STOP_PLUS_TRIGGER))Screen->ComboF[i] = CF_KLOTSKI_ICE_STOP_PLUS_TRIGGER;
			if (ComboFI(i, CF_BLOCKTRIGGER)){
				if (ComboFI(i, CF_KLOTSKI_ICE_STOP))Screen->ComboF[i] = CF_KLOTSKI_ICE_STOP_PLUS_TRIGGER;
				else Screen->ComboF[i] = CF_BLOCKTRIGGER;
			}
		}
		while(true){
			if (this->InitD[7]<0){
				if (KlotskiIsPushed(this,Link->Dir, 6))pushcounter++;
				else pushcounter = 0;
				if (pushcounter>=8){
					if (KlotskiCanBePushed(this, Link->Dir, weight, dirs) && !EnemiesAlive()){
						this->InitD[7] = Link->Dir;
						Game->PlaySound(SFX_KLOTSKI_MOVE);
						movecounter = 16;
						if ((this->InitD[4]&2)>0)movecounter=8;
						KLOTSKI_ReplaceCombosUnderFFC(this, ucmb, ucset);
					}
					else pushcounter = 0;
				}
			}
			else{
				NoAction();
				movecounter--;
				if (this->InitD[7]==DIR_UP){
					this->Y--;
					if ((this->InitD[4]&2)>0)this->Y--;
				}
				if (this->InitD[7]==DIR_DOWN){
					if ((this->InitD[4]&2)>0)this->Y++;
					this->Y++;
				}
				if (this->InitD[7]==DIR_LEFT){
					if ((this->InitD[4]&2)>0)this->X--;
					this->X--;
				}
				if (this->InitD[7]==DIR_RIGHT){
					if ((this->InitD[4]&2)>0)this->X++;
					this->X++;
				}
				if (movecounter==0){
					if (IceKlotskiCanContinueSlide(this)) movecounter=8;
					else{
						pos = ComboAt (this->X+1, this->Y+1);					
						this->InitD[7]=-1;
						KLOTSKI_ReplaceCombosUnderFFC(this, ucmb, ucset);
						KlotskiTriggerUpdate(this, colortrigger>0, ucset);
					}
				}
			}
			Waitframe();
		}
	}
}

//returns true, if Link tries to push this block
bool KlotskiIsPushed(ffc this, int dir, int margin){
	if((Link->X == this->X - 16 && (Link->Y < this->Y+this->EffectHeight - 8+margin && Link->Y > this->Y - margin) && Link->InputRight && dir == DIR_RIGHT) || // Right
	(Link->X == this->X + this->EffectWidth && (Link->Y < this->Y+this->EffectHeight - 8+margin && Link->Y > this->Y - margin) && Link->InputLeft && dir == DIR_LEFT) || // Left
	(Link->Y == this->Y - 16 && (Link->X < (this->X + this->EffectWidth-16+margin) && Link->X > this->X - margin) && Link->InputDown && dir == DIR_DOWN) || // Down
	(Link->Y == this->Y + this->EffectHeight-8 && (Link->X < (this->X + this->EffectWidth-16+margin) && Link->X > this->X - margin) && Link->InputUp && dir == DIR_UP)) { // Up
		return true;
	}
	return false;
}

//Returns true, if block can be pushed in the given direction
bool KlotskiCanBePushed(ffc this, int dir, int weight, int dirs){
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
		if (ComboFI(i, CF_NOBLOCKS)){
			if (Screen->ComboD[i]==CMB_KLOTSKI_NONSOLID){
				if ((this->InitD[4]&6)==6 && this->InitD[7]>=0){
					for (int i=0;i<176;i++){
						int cx1 = ComboX(i);
						int cy1 = ComboY(i);
						int cx2 = cx1+15;
						int cy2 = cy1+15;
						int fx1 = this->X+1;
						int fy1 = this->Y+1;
						int fx2 = this->X+this->EffectWidth-1;
						int fy2 = this->Y+this->EffectHeight-1;
						if (!RectCollision(fx1,fy1,fx2,fy2,cx1,cy1,cx2,cy2))continue;
						if (!ComboFI(i,CF_KLOTSKI_ICE_STOP) && !ComboFI(i,CF_KLOTSKI_ICE_STOP_PLUS_TRIGGER) ) this->InitD[7]=OppositeDir(this->InitD[7]);
					}
				}
				return false;
			}
			if ((this->InitD[4]&1)==0)return false;
			if (Screen->ComboC[i]!=this->CSet)return false;
		}
		if (Screen->ComboS[i]>0)return false;
		int comboS=0;
		if(Screen->LayerMap(1)>0) comboS |= GetLayerComboS(1, i);
		if(Screen->LayerMap(2)>0) comboS |= GetLayerComboS(2, i);
		if(comboS>0)return false;
	}
	return true;
}

//Returns true if Icy klotski block can continue slide
bool IceKlotskiCanContinueSlide(ffc f){
	int dir = f->InitD[7];
	if ((f->InitD[4]&2)==0)return false;
	if (!KlotskiCanBePushed(f, dir, 0, 15)){
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
		if (!ComboFI(i,CF_KLOTSKI_ICE_STOP) && !ComboFI(i,CF_KLOTSKI_ICE_STOP_PLUS_TRIGGER) ) return true;
	}
	return false;
}

//Stores and replaces combos under FFC to mimic solidity.
void KLOTSKI_ReplaceCombosUnderFFC(ffc this, int ucmb, int ucset){
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

//Non-solid Klotski puzzle block. Stand on it, face desired direction and press EX1 to move it. 
//Land all colored blocks on the same-colored triggers to solve the puzzle.

//Effect Width and Height used and is automatically set to be tile dimensions multiplied by 16.

//D0 - bracelet level requirement.
//D1 - allowed push directions. Add together - 1-up, 2-down, 4-left, 8-right. 0 for all directions.
//D2 - 1 - require same-colord trigger combo for trigger secrets. 
//D3 - 0 - not count for trigger
//D4 - +1 - allow pushing onto same-colored #67 flags, +2 -> Icy variant, continues moving in direction, +4 - bounce off another ice block.

ffc script NonSolidKlotskiBlock{
	void run(int weight, int dirs, int colortrigger, int trigger, int colorblock){
		this->EffectWidth = this->TileWidth*16;
		this->EffectHeight = this->TileHeight*16;
		if (dirs==0) dirs=15;
		int pos = ComboAt (this->X+1, this->Y+1);
		int ucmb[16];
		int ucset[16];
		for (int i=0;i<16;i++){
			ucmb[i] = CMB_KLOTSKI_NONSOLID;
			ucset[i] = this->CSet;
		}
		for (int i=0;i<176;i++){
			if (ComboFI(i, CF_BLOCKTRIGGER)){
				if (ComboFI(i, CF_KLOTSKI_ICE_STOP_PLUS_TRIGGER))Screen->ComboF[i] = CF_KLOTSKI_ICE_STOP_PLUS_TRIGGER;
				if (ComboFI(i, CF_KLOTSKI_ICE_STOP))Screen->ComboF[i] = CF_KLOTSKI_ICE_STOP_PLUS_TRIGGER;
				else Screen->ComboF[i] = CF_BLOCKTRIGGER;
			}
		}
		KLOTSKI_ReplaceCombosUnderFFC(this, ucmb, ucset);
		this->InitD[7] = -1;
		int movecounter = 0;
		while(true){
			if (this->InitD[7]<0){
				if (RectCollision(Link->X+7, Link->Y+7, Link->X+8, Link->Y+8, this->X, this->Y, this->X+this->EffectWidth-1, this->Y+this->EffectHeight-1)){
					if (Link->PressEx1){
						if (KlotskiCanBePushed(this, Link->Dir, weight, dirs)){
							this->InitD[7] = Link->Dir;
							Game->PlaySound(SFX_KLOTSKI_MOVE);
							movecounter = 16;
							if ((this->InitD[4]&2)>0)movecounter=8;
							KLOTSKI_ReplaceCombosUnderFFC(this, ucmb, ucset);
						}
					}
				}
			}
			else{
				NoAction();
				movecounter--;
				if (this->InitD[7]==DIR_UP){
					this->Y--;
					if ((this->InitD[4]&2)>0)this->Y--;
				}
				if (this->InitD[7]==DIR_DOWN){
					if ((this->InitD[4]&2)>0)this->Y++;
					this->Y++;
				}
				if (this->InitD[7]==DIR_LEFT){
					if ((this->InitD[4]&2)>0)this->X--;
					this->X--;
				}
				if (this->InitD[7]==DIR_RIGHT){
					if ((this->InitD[4]&2)>0)this->X++;
					this->X++;
				}
				if (movecounter==0){
					if (IceKlotskiCanContinueSlide(this)) movecounter=8;
					else{
						pos = ComboAt (this->X+1, this->Y+1);					
						this->InitD[7]=-1;
						KLOTSKI_ReplaceCombosUnderFFC(this, ucmb, ucset);
						KlotskiTriggerUpdate(this, colortrigger>0, ucset);
					}
				}
			}
			Waitframe();
		}
	}
}

//Checks, if all pushblocks are on triggers and triggers secrets, if it`s true;
void KlotskiTriggerUpdate(ffc f, bool color, int ucset){
	f->InitD[6]=1;
	for (int i=0;i<16;i++){
		int x = f->X+(i%4)*16;
		if (x>(f->X+f->EffectWidth-1)) continue;
		int y = f->Y+Floor(i/4)*16;
		if (y>(f->Y+f->EffectHeight-1)) continue;
		int cmb = ComboAt(x+1,y+1);
		if (!ComboFI(cmb, CF_BLOCKTRIGGER) && !ComboFI(cmb, CF_KLOTSKI_ICE_STOP_PLUS_TRIGGER)) f->InitD[6]=0;
		//if (f->InitD[6]>0) Trace(ucset[i]);
		if (color && ucset[i]!=f->CSet)f->InitD[6]=0;
		//Trace(ucset[i]);
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
		if (n->InitD[3]==0)continue;
		if (n->InitD[6]==0)break;
	}
}