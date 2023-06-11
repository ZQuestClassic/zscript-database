const int CMB_LARGE_PUSHBLOCK_SOLID = 1; //combo used to mimic solidity.

const int SFX_LARGE_PUSHBLOCK_MOVE = 50; //Sound to play when moving a block.

//Large Pushable blocks. Every time you push it. marked corner rotates. Push all FFC at target positions, so their corners face target direction.

//Effect Width and Height used and is automatically set to be tile dimensions multiplied by 16.

//D0 - starting rotation of marked corner. 0 - top-left, 1- top-right, 2-bottom-right, 3- bottom-left.
//D1 - ID of corner combo to render on FFC.
//D2 - target combo position for marked corner to land into (0 - unused)
//D3 - bracelet level requirement.
//D4 - allowed push directions. Add together - 1-up, 2-down, 4-left, 8-right. 0 for all directions.

ffc script LargeColorPushBlock{
	void run(int startdir, int cmbsquare, int targetpos, int weight, int dirs){
		this->EffectWidth = this->TileWidth*16;
		this->EffectHeight = this->TileHeight*16;
		int pos = ComboAt (this->X+1, this->Y+1);
		if (dirs==0) dirs=15;
		int ucmb[16];
		int ucset[16];
		for (int i=0;i<16;i++){
			ucmb[i] = CMB_LARGE_PUSHBLOCK_SOLID;
			ucset[i] = this->CSet;
		}
		ReplaceCombosUnderFFC(this, ucmb, ucset);
		int pushcounter = 0;
		int impulse = -1;
		int movecounter = 0;
		
		while(true){
			if (impulse<0){
				if (LargeBlockIsPushed(this,Link->Dir, 6))pushcounter++;
				else pushcounter = 0;
				if (pushcounter>=8){
					if (LargeBlockCanBePushed(this, Link->Dir, weight, dirs) && !EnemiesAlive()){
						impulse = Link->Dir;
						Game->PlaySound(SFX_LARGE_PUSHBLOCK_MOVE);
						movecounter = 16;
						ReplaceCombosUnderFFC(this, ucmb, ucset);
					}
					else pushcounter = 0;
				}
			}
			else{
				NoAction();
				movecounter--;
				if (impulse==DIR_UP) this->Y--;
				if (impulse==DIR_DOWN) this->Y++;
				if (impulse==DIR_LEFT) this->X--;
				if (impulse==DIR_RIGHT) this->X++;
				if (movecounter==0){
					pos = ComboAt (this->X+1, this->Y+1);					
					impulse=-1;
					ReplaceCombosUnderFFC(this, ucmb, ucset);
					if (startdir>=0){
						startdir++;
						if (startdir>3) startdir=0;
						int sqpos = ComboAt (this->X+1, this->Y+1);
						if (startdir>0 && startdir<3) sqpos += this->TileWidth-1;
						if ((startdir&2)>0) sqpos += (this->TileHeight-1)*16;
						this->InitD[7] = sqpos;
						this->InitD[0] = startdir;
						int str[] = "LargeColorPushBlock";
						int scr = Game->GetFFCScript(str);
						for(int i=1;i<=33;i++){
							if (Screen->State[ST_SECRET]) break;
							if (i==33){
								Game->PlaySound(SFX_SECRET);
								Screen->TriggerSecrets();
								Screen->State[ST_SECRET]=true;
								break;
							}
							ffc f = Screen->LoadFFC(i);
							if (f->Script!=scr)continue;
							if (f->InitD[7] != f->InitD[2]) break;
						}
					}
				}
			}
			int drawx = this->X;
			int drawy = this->Y;
			if (startdir>0 && startdir<3) drawx += (this->EffectWidth-16);
			if ((startdir&2)>0) drawy += (this->EffectHeight-16);
			if (cmbsquare>0)Screen->FastCombo(2, drawx, drawy, cmbsquare, this->CSet, OP_OPAQUE);
			Waitframe();
		}
	}
}

//returns true, if Link tries to push this block
bool LargeBlockIsPushed(ffc this, int dir, int margin){
	if((Link->X == this->X - 16 && (Link->Y < this->Y+this->EffectHeight - 8+margin && Link->Y > this->Y - margin) && Link->InputRight && dir == DIR_RIGHT) || // Right
	(Link->X == this->X + this->EffectWidth && (Link->Y < this->Y+this->EffectHeight - 8+margin && Link->Y > this->Y - margin) && Link->InputLeft && dir == DIR_LEFT) || // Left
	(Link->Y == this->Y - 16 && (Link->X < (this->X + this->EffectWidth-16+margin) && Link->X > this->X - margin) && Link->InputDown && dir == DIR_DOWN) || // Down
	(Link->Y == this->Y + this->EffectHeight-8 && (Link->X < (this->X + this->EffectWidth-16+margin) && Link->X > this->X - margin) && Link->InputUp && dir == DIR_UP)) { // Up
		return true;
	}
	return false;
}

//Returns true, if block can be pushed in the given direction
bool LargeBlockCanBePushed(ffc this, int dir, int weight, int dirs){
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
void ReplaceCombosUnderFFC(ffc this, int ucmb, int ucset){
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

//Glassy rotating/moving panel. Stand on it, face desired direction and press EX1 to move it. Every time you push it. marked corner rotates.
//Land the mark on target combo for all squares to solve the puzzle.

//Effect Width and Height used and is automatically set to be tile dimensions multiplied by 16.

//D0 - starting rotation of marked corner. 0 - top-left, 1- top-right, 2-bottom-right, 3- bottom-left.
//D1 - ID of corner combo for marked marked corner to render on FFC.
//D2 - target combo position of marked corner to land into
//D3 - bracelet level requirement.
//D4 - allowed push directions. Add together - 1-up, 2-down, 4-left, 8-right. 0 for all directions.

ffc script GlassySquarePanel{
	void run(int startdir, int cmbsquare, int targetpos, int weight, int dirs){
		this->EffectWidth = this->TileWidth*16;
		this->EffectHeight = this->TileHeight*16;
		if (dirs==0) dirs=15;
		int pos = ComboAt (this->X+1, this->Y+1);
		int sqpos = ComboAt (this->X+1, this->Y+1);
		if (startdir>0 && startdir<3) sqpos += this->TileWidth-1;
		if ((startdir&2)>0) sqpos += (this->TileHeight-1)*16;
		this->InitD[7] = sqpos;
		int impulse = -1;
		int movecounter = 0;
		while(true){
			if (impulse<0){
				if (RectCollision(Link->X+7, Link->Y+7, Link->X+8, Link->Y+8, this->X, this->Y, this->X+this->EffectWidth-1, this->Y+this->EffectHeight-1)){
					if (Link->PressEx1){
						if (LargeBlockCanBePushed(this, Link->Dir, weight, dirs)){
							impulse = Link->Dir;
							Game->PlaySound(SFX_LARGE_PUSHBLOCK_MOVE);
							movecounter = 16;
						}
					}
				}
			}
			else{
				NoAction();
				movecounter--;
				if (impulse==DIR_UP) this->Y--;
				if (impulse==DIR_DOWN) this->Y++;
				if (impulse==DIR_LEFT) this->X--;
				if (impulse==DIR_RIGHT) this->X++;
				if (movecounter==0){
					pos = ComboAt (this->X+1, this->Y+1);					
					impulse=-1;
					if (startdir>=0){
						startdir++;
						if (startdir>3) startdir=0;
						this->InitD[0] = startdir;
						sqpos = ComboAt (this->X+1, this->Y+1);
						if (startdir>0 && startdir<3) sqpos += this->TileWidth-1;
						if ((startdir&2)>0) sqpos += (this->TileHeight-1)*16;
						this->InitD[7] = sqpos;
						//Trace(sqpos);
						int str[] = "GlassySquarePanel";
						int scr = Game->GetFFCScript(str);
						for(int i=1;i<=33;i++){
							if (Screen->State[ST_SECRET]) break;
							if (i==33){
								Game->PlaySound(SFX_SECRET);
								Screen->TriggerSecrets();
								Screen->State[ST_SECRET]=true;
								break;
							}
							ffc f = Screen->LoadFFC(i);
							if (f->Script!=scr)continue;
							if (f->InitD[7] != f->InitD[2]) break;
						}
					}
				}
			}
			int drawx = this->X;
			int drawy = this->Y;
			if (startdir>0 && startdir<3) drawx += (this->EffectWidth-16);
			if ((startdir&2)>0) drawy += (this->EffectHeight-16);
			if (cmbsquare>0)Screen->FastCombo(1, drawx, drawy, cmbsquare, this->CSet, OP_OPAQUE);
			Waitframe();
		}
	}
}