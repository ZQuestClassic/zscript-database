const int CMB_TESLA_PUSHBLOCK_SOLID = 1; //ID of combo used to mimic solidity. It must be fully solid and fully transparent.

const int SFX_TESLA_PUSHBLOCK_MOVE = 50; //Sound to play when moving a block.
const int SFX_TESLA_PUSHBLOCK_STUCK = 16;//Sound to play when pushblock gets stuck.

const int SPR_TESLA_ELECTROCUTION = 89;//Sprite to display, when Link gets elecrocuted by lightning. 1 frame only

const int CF_TESLA_TRIGGER = 98;//Combo flag to defing lightning rods/receivers.
const int CF_TESLA_CONDUCTOR = 99;//Solid combo flagged with this flag will still contuct electricity.

const int TESLA_LIGHTNING_LEINENCY = 3;//Lightning collision leinency/margin.

const int I_ELECTROSTATIC_ARMOR = 17;//Item that prevents lightning damage.

//Tesla lightning puzzle.
//You are given some pushable charged multicolored emitters and multicolored static lightning rods. Emitters can be pushed like a normal pushable block. When emitter is on same horizontal or vertical line with same colored rod and there are no solid clocks in between, the emiteer discarge continious damaging lightning beam torwards ligthing rod until either emitter is moved, or path is blocked. Connect all emitters with all rods/receivers to solve the puzzle.

//Requires ghost.zh znd chess.zh

//1.Set up solid combo with blank tile for CMB_TESLA_PUSHBLOCK_SOLID constant.
//2.Set up sequence of 4 combos for FFC: horizontal lightning, vertical lightning, inactive emitter, active emitter.
//3.Set up sequence of 2 combos for rods/receivers - inactive, then active
//4.Place 1x1 FFCs at emitter`s positions
// D0 - bracelet level requirement.
// D1 - allowed push directions. Add together - 1-up, 2-down, 4-left, 8-right. 0 for all directions.
// D2 - add together: 1 - gets stuck after 1 push, 2 - gets stuck when landing on flag #66, 4 - icy block, continue moving in direction until hitting obstacle, 8 - ignore flag #66, 16 - require triggers with same CSet as FFC`s Cset)
// D3 - Lightning spark combo, 1st combo in sequence from step 2.
// D4 - damage caused by getting elecrocuted by lightning
// D5 - number of receivers/rods that FFC must charge simultaneously to trigger. 0 to turn into normal pushblock that can block and isolate.
//5.Place lightning rods/receivers with CF_TESLA_TRIGGER flag onto screen.

//TeslaBlock_Render
//Renderer for TeslaBlock_ blocks
//Place, gridsnap, and align on bottom with large pushblock.
//D0 - ID of pushblock FFC

ffc script LargeTeslaBlock{
	void run (int weight, int dirs, int flags, int damage, int elecsprite, int target){
		int origdata= this->Data;
		if (elecsprite==0)elecsprite = origdata-2;
		int cmb=origdata;
		int str[] = "TeslaBlock_Render";
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
		int pos = ComboAt (this->X+1, this->Y+1);
		if (dirs==0) dirs=15;
		int ucmb[16];
		int ucset[16];
		for (int i=0;i<16;i++){
			ucmb[i] = CMB_TESLA_PUSHBLOCK_SOLID;
			ucset[i] = this->CSet;
		}
		int adjcmb[4]={-1,-1,-1,-1};
		int buffer[16];
		int scount = 0;
		TeslaBlock_ReplaceCombosUnderFFC(this, ucmb, ucset);
		int pushcounter = 0;
		this->InitD[7] = -1;
		int movecounter = 0;
		int moving = 0;
		bool coll =false;
		for (int i=0;i<176;i++){
			if (ComboFI(i, CF_BLOCKTRIGGER))Screen->ComboF[i] = CF_BLOCKTRIGGER;
		}
		while(true){
			if (this->InitD[7]<0){
				if (TeslaBlock_BlockIsPushed(this,Link->Dir, 5))pushcounter++;
				else pushcounter = 0;
				if (pushcounter>=8){
					if (TeslaBlock_BlockCanBePushed(this, Link->Dir, weight, dirs) && !EnemiesAlive()){
						this->InitD[7] = Link->Dir;
						Game->PlaySound(SFX_TESLA_PUSHBLOCK_MOVE);
						movecounter = 16;
						if((flags&4)>0)movecounter = 8;
						TeslaBlock_ReplaceCombosUnderFFC(this, ucmb, ucset);
					}
					else pushcounter = 0;
				}
			}
			else{
				NoAction();
				movecounter--;
				if (this->InitD[7]==DIR_UP){
					this->Y--;
					if((flags&4)>0)this->Y--;
				}
				if (this->InitD[7]==DIR_DOWN){
					if((flags&4)>0)this->Y++;
					this->Y++;
				}
				if (this->InitD[7]==DIR_LEFT){
					this->X--;
					if((flags&4)>0)this->X--;
				}
				if (this->InitD[7]==DIR_RIGHT){
					this->X++;
					if((flags&4)>0)this->X++;
				}
				if (movecounter==0){
					if ((flags&4)>0 && TeslaBlock_BlockCanBePushed(this, this->InitD[7], 0, dirs)) movecounter=8;
					else{
						if ((flags&1)>0){
							Game->PlaySound(SFX_TESLA_PUSHBLOCK_STUCK);
							dirs=0;
						}
						pos = ComboAt (this->X+1, this->Y+1);
						TeslaBlock_ReplaceCombosUnderFFC(this, ucmb, ucset);
						this->InitD[7]=-1;
						if ((flags&8)==0)TeslaBlock_TriggerUpdate(this,ucset);
						if ((flags&2)>0 && this->InitD[6]>0){
							Game->PlaySound(SFX_TESLA_PUSHBLOCK_STUCK);
							dirs=0;
						}
					}
				}
			}
			moving=0;
			for(int i=1;i<=32;i++){
				ffc n = Screen->LoadFFC(i);
				if (n->Script!=this->Script)continue;
				if (n->InitD[7] >= 0){
					moving=1;
					break;
				}
			}
			for (int i=0;i<4;i++){
				if (movecounter>0)break;
				adjcmb[i]=0;
				if (target==0 || moving>0){
					adjcmb[i]=-1;
					break;
				}
				while(adjcmb[i]>=0){
					adjcmb[i] = TeslaAdjacentComboFix(Cond(adjcmb[i]==0,pos,adjcmb[i]), i);
					int cd = adjcmb[i];
					//Screen->DrawInteger(5, ComboX(cd), ComboY(cd),0, 1,0 , -1, -1, cd, 0, OP_OPAQUE);
					if (adjcmb[i]<0)continue;
					if (ComboFI(adjcmb[i], CF_TESLA_TRIGGER)&&((flags&16)==0 || Screen->ComboC[cd]==this->CSet)) break;
					if (Screen->ComboS[cd]>0 && !ComboFI(cd,CF_TESLA_CONDUCTOR) && !ComboFI(cd,CF_TESLA_TRIGGER))adjcmb[i]=-1;
				}
				// debugValue(i+1,adjcmb[i]);
			}
			for (int i=0;i<4;i++){
				if (target==0|| moving>0)break;
				if (movecounter>0)break;
				if (adjcmb[i]<0)continue;
				int cd = adjcmb[i];
				Screen->FastCombo(3,ComboX(cd), ComboY(cd),Screen->ComboD[cd]+1, Screen->ComboC[cd],OP_OPAQUE);
				Tesla_GetCombosInBetween (pos, adjcmb[i], buffer, false);
				
				for (int c=0;c<16;c++){
					if (buffer[c]<0)continue;
					Screen->FastCombo(3,ComboX(buffer[c]), ComboY(buffer[c]),Cond(i<2, elecsprite+1, elecsprite),this->CSet, OP_OPAQUE);
					//if (damage==0)continue;
					// Screen->Rectangle(3, ComboX(buffer[c])+TESLA_LIGHTNING_LEINENCY, ComboY(buffer[c])+TESLA_LIGHTNING_LEINENCY, ComboX(buffer[c])+16-TESLA_LIGHTNING_LEINENCY*2, ComboY(buffer[c])+16-TESLA_LIGHTNING_LEINENCY*2, 1, -1,0, 0, 0,false, OP_OPAQUE);
					if (RectCollision(Link->X, Link->Y+Cond(IsSideview(),0,8), Link->X+15, Link->Y+15, ComboX(buffer[c])+TESLA_LIGHTNING_LEINENCY, ComboY(buffer[c])+TESLA_LIGHTNING_LEINENCY, ComboX(buffer[c])+16-TESLA_LIGHTNING_LEINENCY*2, ComboY(buffer[c])+16-TESLA_LIGHTNING_LEINENCY*2)){
						eweapon e = FireEWeapon(EW_SCRIPT10, Link->X+InFrontX(Link->Dir, 12), Link->Y+InFrontY(Link->Dir, 12), 0, 0, damage, SPR_TESLA_ELECTROCUTION, -1, EWF_UNBLOCKABLE);
						e->Dir = Link->Dir;
						 e->CSet = this->CSet;
						 if (Link->Item[I_ELECTROSTATIC_ARMOR]){
							 e->CollDetection=false;
							 e->DrawXOffset=1000;
						 }
						SetEWeaponLifespan(e, EWL_TIMER, e->NumFrames*e->ASpeed);
						SetEWeaponDeathEffect(e, EWD_VANISH, 0);
					}
				}
			}
			scount=0;
			for (int i=0;i<4;i++){
				if (adjcmb[i]>=0)scount++;
			}
			if (scount>0)this->Data=origdata+1;
			else this->Data=origdata;
			
			this->InitD[6]=0;
			if (scount>=target) this->InitD[6]=1;
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
				if (n->Script!=this->Script)continue;
				if (n->InitD[6] == 0) break;
			}
			Waitframe();
		}
	}
}

//returns true, if Link tries to push this block
bool TeslaBlock_BlockIsPushed(ffc this, int dir, int margin){
	if((Link->X == this->X - 16 && (Link->Y < this->Y+this->EffectHeight - 8+margin && Link->Y > this->Y - margin) && Link->InputRight && dir == DIR_RIGHT) || // Right
	(Link->X == this->X + this->EffectWidth && (Link->Y < this->Y+this->EffectHeight - 8+margin && Link->Y > this->Y - margin) && Link->InputLeft && dir == DIR_LEFT) || // Left
	(Link->Y == this->Y - 16 && (Link->X < (this->X + this->EffectWidth-16+margin) && Link->X > this->X - margin) && Link->InputDown && dir == DIR_DOWN) || // Down
	(Link->Y == this->Y + this->EffectHeight-8 && (Link->X < (this->X + this->EffectWidth-16+margin) && Link->X > this->X - margin) && Link->InputUp && dir == DIR_UP)) { // Up
		return true;
	}
	return false;
}

//Returns true, if block can be pushed in the given direction
bool TeslaBlock_BlockCanBePushed(ffc this, int dir, int weight, int dirs){
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
void TeslaBlock_ReplaceCombosUnderFFC(ffc this, int ucmb, int ucset){
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
void TeslaBlock_TriggerUpdate(ffc f, int ucset){
	
}

//Renderer for TeslaBlock_ blocks
//D0 - ID of pushblock FFC
ffc script TeslaBlock_Render{
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

//Gets all combos between given ones, assuming they are on same orthogonal or diagonal row. Buffer must be 16+ integers long.
//If set "includeorigins" bool to TRUE, original input combos will be also written into buffer. 
void Tesla_GetCombosInBetween (int cmb1, int cmb2, int buffer, bool includeorigins){
	int str[] =  "chess.zh - Buffer Too Low";
	if (SizeOfArray(buffer)<16) TraceS(str);
	for (int i = 0; i<SizeOfArray(buffer); i++) buffer[i] = -1;
	int curpos1 = cmb1;
	int curpos2 = cmb2;
	int b = 0;
	if (includeorigins){
		buffer[b] = cmb1;
		b++;
	}
	if (OnSameRank(cmb1, cmb2)){
		curpos1 = Min(cmb1, cmb2);
		curpos2 = Max(cmb1, cmb2);
		while (curpos1<curpos2){
			curpos1++;
			if (curpos1<curpos2)buffer[b] = curpos1;
			b++;
		}
	}
	if (OnSameFile(cmb1,cmb2)){
		curpos1 = Min(cmb1, cmb2);
		curpos2 = Max(cmb1, cmb2);
		while (curpos1<curpos2){
			curpos1+=16;
			if (curpos1<curpos2)buffer[b] = curpos1;
			b++;
		}
	}
	if (OnSameDiagonal(cmb1,cmb2)){
		curpos1 = Min(cmb1, cmb2);
		curpos2 = Max(cmb1, cmb2);
		while (curpos1<curpos2){
			if (curpos1<curpos2){
				if (ComboX(cmb1)>ComboX(cmb2))curpos1+=15;
				else curpos1+=17;
			}
			buffer[b] = curpos1;
			b++;
		}
	}
	if (includeorigins) buffer[b]=cmb2;
}

//Returns TRUE, if there are no solid combos between given ones, assuming they are on same orthogonal or diagonal row.
bool Tesla_PathIsObstructed(int cmb1, int cmb2){
	int buffer[16];
	Tesla_GetCombosInBetween(cmb1, cmb2, buffer, false);
	for (int i=0; i<16; i++){
		int cmb=buffer[i];
		if (Screen->ComboS[cmb]) return true;
	}
	return false;
}

//Fixed variant of AdjacentCombo function from std_extension.zh
int TeslaAdjacentComboFix(int cmb, int dir){
	int combooffsets[13]={-0x10, 0x10, -1, 1, -0x11, -0x0F, 0x0F, 0x11};
	if ( cmb % 16 == 0 ) combooffsets[9] = -1;//if it's the left edge
	if ( (cmb % 16) == 15 ) combooffsets[10] = -1; //if it's the right edge
	if ( cmb < 0x10 ) combooffsets[11] = -1; //if it's the top row
	if ( cmb > 0x9F ) combooffsets[12] = -1; //if it's on the bottom row
	if ( combooffsets[9]==-1 && ( dir == DIR_LEFT || dir == DIR_LEFTUP || dir == DIR_LEFTDOWN ) ) return -1; //if the left columb
	if ( combooffsets[10]==-1 && ( dir == DIR_RIGHT || dir == DIR_RIGHTUP || dir == DIR_RIGHTDOWN ) ) return -1; //if the right column
	if ( combooffsets[11]==-1 && ( dir == DIR_UP || dir == DIR_RIGHTUP || dir == DIR_LEFTUP ) ) return -1; //if the top row
	if ( combooffsets[12]==-1 && ( dir == DIR_DOWN || dir == DIR_RIGHTDOWN || dir == DIR_LEFTDOWN ) ) return -1; //if the bottom row
	if ( cmb >= 0 && cmb < 176 ) return cmb + combooffsets[dir];
	else return -1;
}