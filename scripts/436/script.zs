const int CMB_TETRIS_PUSHBLOCK_SOLID = 1; //ID of blank solid combo underneath pushblock
const int CMB_TETRIS_KLOTSKI_NONSOLID = 2239;//combo used to mimic non-solid obstacle, must have CF_NOBLOCKS inherent flag (#67).

const int SFX_TETRIS_PUSHBLOCK_MOVE = 50; //Sound to play when pushblock is moved.
const int SFX_TETRIS_ROTATE_FAIL = 16;//Sound to play when pushblock movement or rotation fails.
const int SFX_TETRIS_PUSHBLOCK_STUCK = 16;//Sound to play when pushblock gets stuck and immobile
const int SFX_TETRIS_PICKPLACE_PICK = 4;//Sound to play,when liftable polyomino is picked.
const int SFX_TETRIS_PICKPLACE_PLACE = 16;//Sound to play,when liftable polyominois placed.
const int SFX_TETRIS_PICKPLACE_ROTATE = 30;//Sound to play,when liftable polyomino is rotated.

const int LAYER_TETRIS_PICKPLACE_RENDER_GHOST = 0;//Layer to render placing ghost for polyomino held by Link

const int TETRIS_PICKPLACE_LIFT_OFFSET = 8;//Y offset for rendering lifted polyominoes

const int TETRIS_DEBUG_PUSH_FAIL = 0; //Debug functions
const int TETRIS_DEBUG_ROTATION_FAIL = 1;

//Tetris-like pushable blocks, alternate variant + remote controller that can push and rotate pushblocks at distance. 
//Credit goes to Moosh for technical assistance.

//Set up solid combo with blank tile for CMB_TETRIS_PUSHBLOCK_SOLID constant.
//Build floor where blocks can be moved on background layer.
//Place FFC at block initial position. Assign TileWidth and TileHeight so it encompasses entire block.
// D0-D3 Block shape, like Moosh`s way to set up blocks.
//  [0][1][0][0] 
//  [1][1][0][0] 
// T-shaped piece, rotating at center - D0 = 100, D1 = 1100, D2=0, D3=0
//  [0][1][0][0]
//  [1][1][0][0]
//  [1][0][0][0]
// Z-shaped piece, rotating at center - D0 = 100, D1 = 1000, D2 = 100, D3=0
//As an alternative, you can build shape using combos, place FFC with the same combo and CSet at top left corner of shape, and leave D0 as 0.
//
// D4 - Weight, bracelet level needed to push block by hand. If remote controller is used, weight is treated as 0.
// D5 - Allowed push directions, both by hand and remote controller.
// D6 - add together: 1 - gets stuck after 1 push, 2 - gets stuck when landing on trigger, 4 - icy block, continue moving in direction until hitting obstacle, 8 - ignore triggers, 16 - require triggers with same CSet as FFC`s Cset, 32 - use FAST Combo automatic rendering.

ffc script TetrisPushBlock{
	void run (int row1, int row2, int row3, int row4, int weight, int dirs, int flags){
		if (dirs==0) dirs=15;
		int tetris[16];
		bool onepush = (flags&1)>0;
		bool triggerstuck = (flags&2)>0;
		bool icy = (flags&4)>0;
		bool notrigger = (flags&8)>0;
		bool colortrigger = (flags&16)>0;
		bool linkmove=false;
		int origdata = this->Data;
		this->InitD[6]=0;
		if (notrigger)this->InitD[6]=-1;
		if (row1==0)AutomaticTetrisMatrixSetup(this, tetris);
		else{
			TetrisMatrixSetup(tetris, row1, row2, row3, row4);
			int size = Max(this->TileHeight, this->TileWidth);
			this->TileWidth = size;
			this->TileHeight = size;
		}
		int ucmb[16];
		int ucset[16];
		for (int i=0;i<16;i++){
			ucmb[i] = CMB_TETRIS_PUSHBLOCK_SOLID;
			ucset[i] = this->CSet;
			if (tetris[i]==0) ucmb[i]=-1;
		}
		int pushdir=-1;
		int pushcounter=0;
		int movecounter=0;
		this->Data = FFCS_INVISIBLE_COMBO;
		ReplaceCombosUnderFFC(this, tetris,  ucmb, ucset);
		int rotate=0;
		this->InitD[7]=-1;
		for (int i=0;i<176;i++){
			if (ComboFI(i, CF_BLOCKTRIGGER))Screen->ComboF[i] = CF_BLOCKTRIGGER;
		}
		while(true){
			if (pushdir<0){
				if (TetrisIsPushed(this, tetris, Link->Dir))pushcounter++;
				else pushcounter=0;
				if (pushcounter>=12){
					if (TetrisCanBePushed(this, tetris, Link->Dir, weight, dirs)){
						pushdir = Link->Dir;
						Game->PlaySound(SFX_TETRIS_PUSHBLOCK_MOVE);
						movecounter = 16;
						ReplaceCombosUnderFFC(this, tetris,  ucmb, ucset);
						if (LinkBehindTetrisBlock (this, tetris))linkmove=true;
						pushcounter=0;
					}
					else pushcounter=0;
				}
			}
			else{
				if (pushdir==DIR_UP){
					this->Y--;
					if (linkmove)Link->Y--;
				}
				if (pushdir==DIR_DOWN){
					this->Y++;
					if (linkmove)Link->Y++;
				}
				if (pushdir==DIR_LEFT){
					this->X--;
					if (linkmove)Link->X--;
				}
				if (pushdir==DIR_RIGHT){
					this->X++;
					if (linkmove)Link->X++;
				}
				NoAction();
				movecounter--;
				if (movecounter==0){
					if (icy && TetrisCanBePushed(this, tetris, pushdir, 0, dirs)){
						if (LinkBehindTetrisBlock (this, tetris))linkmove=true;
						movecounter=16;
					}
					else{
						int pos = ComboAt(CenterLinkX(), CenterLinkY());
						if (pushdir==DIR_UP)Link->Y = ComboY(pos)+8;
						if (pushdir==DIR_DOWN)Link->Y= ComboY(pos);
						if (pushdir==DIR_LEFT)Link->X = ComboX(pos);
						if (pushdir==DIR_RIGHT)Link->X= ComboX(pos);
						pushdir=-1;
						linkmove=false;
						ReplaceCombosUnderFFC(this, tetris,  ucmb, ucset);
						if (onepush){
							Game->PlaySound(SFX_TETRIS_PUSHBLOCK_STUCK);
							dirs=0;
						}
						if (!notrigger)TetrisTriggerUpdate(this, tetris, colortrigger);
						if (triggerstuck && this->InitD[6]>0){
							Game->PlaySound(SFX_TETRIS_PUSHBLOCK_STUCK);
							dirs=0;
						}
					}
				}
			}
			if (this->InitD[7]>=0 && this->InitD[7]<=3){
				if (TetrisCanBePushed(this, tetris, this->InitD[7], 0, dirs)){
					Game->PlaySound(SFX_TETRIS_PUSHBLOCK_MOVE);
					ReplaceCombosUnderFFC(this, tetris,  ucmb, ucset);
					if (this->InitD[7]==DIR_UP)this->Y-=16;
					if (this->InitD[7]==DIR_DOWN)	this->Y+=16;
					if (this->InitD[7]==DIR_LEFT)	this->X-=16;
					if (this->InitD[7]==DIR_RIGHT)this->X+=16;
					ReplaceCombosUnderFFC(this, tetris,  ucmb, ucset);
					this->InitD[7]=-1;
					if (onepush){
						Game->PlaySound(SFX_TETRIS_PUSHBLOCK_STUCK);
						dirs=0;
					}
					if (!notrigger)TetrisTriggerUpdate(this, tetris,colortrigger);
					if (triggerstuck && this->InitD[6]>0){
						Game->PlaySound(SFX_TETRIS_PUSHBLOCK_STUCK);
						dirs=0;
					}
				}
				else this->InitD[7]=-1;
			}
			if (this->InitD[7]==4){
				if (TryRotateTetris(this, tetris, 1)){
					Game->PlaySound(SFX_TETRIS_PUSHBLOCK_MOVE);
					RotateTetrisBlock(this, tetris, 1, ucmb, ucset);
					rotate+=90;
					if (rotate>=360)rotate=0;
					this->InitD[7]=-1;
					if (!notrigger)TetrisTriggerUpdate(this, tetris,colortrigger);
					if (triggerstuck && this->InitD[6]>0){
						Game->PlaySound(SFX_TETRIS_PUSHBLOCK_STUCK);
						dirs=0;
					}
				}
				else this->InitD[7]=-1;
			}
			if (this->InitD[7]==5){
				if (TryRotateTetris(this, tetris, 2)){
					Game->PlaySound(SFX_TETRIS_PUSHBLOCK_MOVE);
					RotateTetrisBlock(this, tetris, 2, ucmb, ucset);
					rotate-=90;
					if (rotate<0)rotate+=360;
					this->InitD[7]=-1;
					if (!notrigger)TetrisTriggerUpdate(this, tetris, colortrigger);
					if (triggerstuck && this->InitD[6]>0){
						Game->PlaySound(SFX_TETRIS_PUSHBLOCK_STUCK);
						dirs=0;
					}
				}
				else this->InitD[7]=-1;
			}
			// for (int i=0;i<16;i++){
			// if (tetris[i]==0)continue;
			// int x = this->X+(i%4)*16;
			// int y = this->Y+Floor(i/4)*16;
			// Screen->Rectangle(3, x, y, x+15, y+15, 1, -1, 0, 0, 0, false, OP_OPAQUE);
			// }
			if (row1==0 || (flags&32)>0){
				for (int i=0;i<16;i++){
					if (tetris[i]==0)continue;
					int x = this->X+(i%4)*16;
					int y = this->Y+Floor(i/4)*16;
					int cmb = ComboAt(x+1,y+1);
					Screen->FastCombo(1, x, y, origdata, this->CSet, OP_OPAQUE);
				}
			}
			else Screen->DrawCombo(1, this->X, this->Y, origdata, this->TileWidth, this->TileHeight, this->CSet, -1, -1, this->X, this->Y, rotate, 0, 0, true, OP_OPAQUE);
			//debugValue(1,this->InitD[7]);
			//debugValue(2,Link->X);
			//debugValue(3,Link->Y);
			Waitframe();
		}
	}
}

bool LinkBehindTetrisBlock (ffc f, int tetris){
	int cmb = ComboAt(CenterLinkX(),CenterLinkY());
	cmb = AdjacentComboFix(cmb, OppositeDir(Link->Dir));
	for (int i=0;i<16;i++){
		if (tetris[i]==0)continue;
		int x = f->X+(i%4)*16;
		int y = f->Y+Floor(i/4)*16;
		if (ComboAt(x,y)==cmb) return true;
	}
	return false;
}

bool TetrisIsPushed(ffc f, int tetris, int dir){
	for (int i=0;i<16;i++){
		if (tetris[i]==0)continue;
		int x = f->X+(i%4)*16;
		int y = f->Y+Floor(i/4)*16;
		if((Link->X == x - 16 && (Link->Y < y + 1 && Link->Y > y - 14) && Link->InputRight && Link->Dir == DIR_RIGHT) || // Right
		(Link->X == x + 16 && (Link->Y < y + 1 && Link->Y > y - 14) && Link->InputLeft && Link->Dir == DIR_LEFT) || // Left
		(Link->Y == y - 16 && (Link->X < x + 8 && Link->X > x - 8) && Link->InputDown && Link->Dir == DIR_DOWN) || // Down
		(Link->Y == y + 8 && (Link->X < x + 8 && Link->X > x - 8) && Link->InputUp && Link->Dir == DIR_UP)) { // Up
			return true;
		}
	}
	return false;
}

bool TetrisCanBePushed(ffc f, int tetris, int dir, int weight, int dirs){
	if (EnemiesAlive())return false;
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
	for (int i=0;i<16;i++){
		if (tetris[i]==0)continue;
		if(dir==DIR_UP){
			if (i>=4){
				if (tetris[i-4]>0) continue;
			}
		}
		if(dir==DIR_DOWN){
			if (i<=11){
				if (tetris[i+4]>0) continue;
			}
		}
		if(dir==DIR_LEFT){
			if ((i%4)>0){
				if (tetris[i-1]>0) continue;
			}
		}
		if(dir==DIR_RIGHT){
			if ((i%4)<3){
				if (tetris[i+1]>0) continue;
			}
		}
		int x = f->X+(i%4)*16;
		int y = f->Y+Floor(i/4)*16;
		int cmb = ComboAt(x,y);
		int adj = AdjacentComboFix(cmb, dir);
		bool fail = false;
		if (ComboFI(adj, CF_NOBLOCKS)) fail =true;
		if (Screen->ComboS[adj]>0)fail =true;
		int comboS=0;
		if(Screen->LayerMap(1)>0) comboS |= GetLayerComboS(1, adj);
		if(Screen->LayerMap(2)>0) comboS |= GetLayerComboS(2, adj);
		if(comboS>0)fail =true;
		if (fail){
			//Game->PlaySound(SFX_TETRIS_ROTATE_FAIL);
			for (int i=0;i<16;i++){
				if (tetris[i]==0)continue;
				int dx = f->X+(i%4)*16;
				int dy = f->Y+Floor(i/4)*16;
				int dcmb = ComboAt(dx,dy);
				int dadj = AdjacentComboFix(dcmb, dir);
				dx = ComboX(dadj);
				dy = ComboY(dadj);
				if (TETRIS_DEBUG_PUSH_FAIL>0)Screen->Rectangle(4, dx, dy, dx+15, dy+15, 1, -1, 0, 0, 0, false, OP_OPAQUE);
			}
			return false;
		}
	}
	return true;
}

//Processes secret triggers
void TetrisTriggerUpdate(ffc f, int tetris, bool color){
	f->InitD[6]=1;
	for (int i=0;i<16;i++){
		if (tetris[i]==0)continue;
		int x = f->X+(i%4)*16;
		int y = f->Y+Floor(i/4)*16;
		int cmb = ComboAt(x+1,y+1);
		if (!ComboFI(cmb, CF_BLOCKTRIGGER)) f->InitD[6]=0;
		if (color && Screen->ComboC[cmb]!=f->CSet)f->InitD[6]=0;
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
		if (n->InitD[6] < 0) continue;
		if (n->InitD[6] == 0) break;
	}
}

//Stores and replaces combos under FFC to mimic solidity.
void ReplaceCombosUnderFFC(ffc this, int tetris,  int ucmb, int ucset){
	for (int i=0;i<16;i++){
		if (tetris[i]==0)continue;
		int x = this->X+(i%4)*16;
		int y = this->Y+Floor(i/4)*16;
		int cmb = ComboAt(x,y);
		int rcmb = Screen->ComboD[cmb];
		int rcset = Screen->ComboC[cmb];
		Screen->ComboD[cmb] = ucmb[i];
		Screen->ComboC[cmb] = ucset[i];
		ucmb[i] = rcmb;
		ucset[i]= rcset;
	}
}

void AutomaticTetrisMatrixSetup(ffc f, int tetris){
	int size=1;
	for (int i=0;i<16;i++){
		int x = f->X+(i%4)*16;
		int y = f->Y+Floor(i/4)*16;
		int cmb = ComboAt(x,y);
		if (Screen->ComboD[cmb]!=f->Data){
			tetris[i]=0;
			continue;
		}
		if (Screen->ComboC[cmb]!=f->CSet){
			tetris[i]=0;
			continue;
		}
		tetris[i]=1;
		Screen->ComboD[cmb]=Screen->UnderCombo;
		Screen->ComboC[cmb]=Screen->UnderCSet;
		x= (i%4)+1;
		y=Floor(i/4)+1;
		size=Max(size,x);
		size=Max(size,y);
		
	}
	f->TileWidth=size;
	f->TileHeight=size;
}

void TetrisMatrixSetup(int arr, int row1, int row2, int row3, int row4){
	int rows[4] = {row1,row2,row3,row4};
	for (int i=0;i<4;i++){
		arr[i*4+0] = Floor((rows[i]%10000)/1000);
		arr[i*4+1] = Floor((rows[i]%1000)/100);
		arr[i*4+2] = Floor((rows[i]%100)/10);
		arr[i*4+3] = (rows[i]%10);
	}
}

bool TryRotateTetris(ffc f, int tetris, int rot){
	int new[16];
	for (int i=0;i<16;i++){
		new[i] = tetris[i];
	}
	if (rot==2) TetrisRotateCCW (f,new);
	else if (rot==1) TetrisRotateCW (f,new);
	else return false;
	bool fail =false;
	for (int i=0;i<16;i++){
		if (new[i]==0)continue;
		if (tetris[i]>0)continue;
		int x = f->X+(i%4)*16;
		int y = f->Y+Floor(i/4)*16;
		int cmb = ComboAt(x,y);
		if (ComboFI(cmb, CF_NOBLOCKS)) fail =true;
		if (Screen->ComboS[cmb]>0)fail =true;
		int comboS=0;
		if(Screen->LayerMap(1)>0) comboS |= GetLayerComboS(1, cmb);
		if(Screen->LayerMap(2)>0) comboS |= GetLayerComboS(2, cmb);
		if(comboS>0)fail =true;
	}
	if (fail){
		Game->PlaySound(SFX_TETRIS_ROTATE_FAIL);
		for (int i=0;i<16;i++){
			if (new[i]==0)continue;
			int x = f->X+(i%4)*16;
			int y = f->Y+Floor(i/4)*16;
			if (TETRIS_DEBUG_ROTATION_FAIL>0)Screen->Rectangle(4, x, y, x+15, y+15, 1, -1, 0, 0, 0, false, OP_OPAQUE);
		}
		return false;
	}
	return true;
}

void RotateTetrisBlock(ffc f, int tetris, int rot, int ucmb, int ucset){
	ReplaceCombosUnderFFC(f, tetris,  ucmb, ucset);
	if (rot==2){
		TetrisRotateCCW (f,tetris);
		TetrisRotateCCW (f,ucmb);
		TetrisRotateCCW (f,ucset);
	}
	else if (rot==1){
		TetrisRotateCW (f,tetris);
		TetrisRotateCW (f,ucmb);
		TetrisRotateCW (f,ucset);
	}
	ReplaceCombosUnderFFC(f, tetris,  ucmb, ucset);
}

void TetrisRotateCCW (ffc f, int old){
	int size = Max(f->TileHeight, f->TileWidth);
	int new[16];
	for (int i=0;i<16;i++){
		new[i]=old[i];
	}
	if(size==2){
		new[0]=old[1];
		new[1]=old[5];
		new[4]=old[0];
		new[5]=old[4];
	}
	if(size==3){
		new[0] = old[2];
		new[1] = old[6];
		new[2] = old[10];
		new[4] = old[1];
		new[5] = old[5];
		new[6] = old[9];
		new[8] = old[0];
		new[9] = old[4];
		new[10] = old[8];
	}
	if (size==4){
		new[0] = old[3];
		new[1] = old[7];
		new[2] = old[11];
		new[3] = old[15];
		new[4] = old[2];
		new[5] = old[6];
		new[6] = old[10];
		new[7] = old[14];
		new[8] = old[1];
		new[9] = old[5];
		new[10] = old[9];
		new[11] = old[13];
		new[12] = old[0];
		new[13] = old[4];
		new[14] = old[8];
		new[15] = old[12];
	}
	for(int i=0;i<16; i++){
		old[i]=new[i];
	}
}

void TetrisRotateCW (ffc f, int old){
	int size = Max(f->TileHeight, f->TileWidth);
	int new[16];
	for (int i=0;i<16;i++){
		new[i]=old[i];
	}
	if(size==2){
		new[0]=old[4];
		new[1]=old[0];
		new[4]=old[5];
		new[5]=old[1];
	}
	if(size==3){
		new[0] = old[8];
		new[1] = old[4];
		new[2] = old[0];
		new[4] = old[9];
		new[5] = old[5];
		new[6] = old[1];
		new[8] = old[10];
		new[9] = old[6];
		new[10] = old[2];
	}
	if (size==4){
		new[0] = old[12];
		new[1] = old[8];
		new[2] = old[4];
		new[3] = old[0];
		new[4] = old[13];
		new[5] = old[9];
		new[6] = old[5];
		new[7] = old[1];
		new[8] = old[14];
		new[9] = old[10];
		new[10] = old[6];
		new[11] = old[2];
		new[12] = old[15];
		new[13] = old[11];
		new[14] = old[7];
		new[15] = old[3];
	}
	for(int i=0;i<16; i++){
		old[i]=new[i];
	}
}


//Fixed variant of AdjacentCombo function from std_extension.zh
int AdjacentComboFix(int cmb, int dir)
{
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


//Tetris pushblock remote controller.
//Effect Width and EffectHeight are used.

//D0 - ID of FFC. It must run TetrisPushBlock script, of you will get error message into allegro.log
ffc script TetrisRemoteController{
	void run(int id){
		ffc t = Screen->LoadFFC(id);
		int str[] = "TetrisPushBlock";
		int scr = Game->GetFFCScript(str);
		if (t->Script != scr){
			int err[] = "This FFC is not a TETRIS PUSH BLOCK";
			TraceS(err);
			Quit();
		}
		while (true){
			if (RectCollision(Link->X+7, Link->Y+7, Link->X+8, Link->Y+8, this->X, this->Y, this->X+this->EffectWidth-1, this->Y+this->EffectHeight-1)){
				if (Link->PressEx1)t->InitD[7] = Link->Dir;
				if (Link->PressEx2)t->InitD[7] = 4;
			}
			Waitframe();
		}
	}
}	

//Non-solid klotski-like tetromino. Stand on it, face desired direction and press EX1 to move it.

//Set up combo with blank tile and NoPushBlocks inherent flag for CMB_TETRIS_KLOTSKI_NONSOLID constant.
//Build floor where blocks can be moved on background layer.
//Place FFC at block initial position. Assign TileWidth and TileHeight so it encompasses entire block.
// D0-D3 Block shape, like Moosh`s way to set up blocks.
//  [0][1][0][0] 
//  [1][1][0][0] 
// T-shaped piece, rotating at center - D0 = 100, D1 = 1100, D2=0, D3=0
//  [0][1][0][0]
//  [1][1][0][0]
//  [1][0][0][0]
// Z-shaped piece, rotating at center - D0 = 100, D1 = 1000, D2 = 100, D3=0
//As an alternative, you can build shape using combos, place FFC with the same combo and CSet at top left corner of shape, and leave D0 as 0.
//
// D4 - Weight, bracelet level needed to push block.
// D5 - Allowed push directions.
// D6 - add together: 1 - gets stuck after 1 push, 2 - gets stuck when landing on trigger, 4 - icy block, continue moving in direction until hitting obstacle, 8 - ignore triggers, 16 - require triggers with same CSet as FFC`s Cset, 32 - use FAST Combo automatic rendering.
ffc script NonSolidTetrisKlotskiBlock{
	void run (int row1, int row2, int row3, int row4, int weight, int dirs, int flags){
		if (dirs==0) dirs=15;
		int tetris[16];
		bool onepush = (flags&1)>0;
		bool triggerstuck = (flags&2)>0;
		bool icy = (flags&4)>0;
		bool notrigger = (flags&8)>0;
		bool colortrigger = (flags&16)>0;
		bool linkmove=false;
		int origdata = this->Data;
		this->InitD[6]=0;
		if (notrigger)this->InitD[6]=-1;
		if (row1==0)AutomaticTetrisMatrixSetup(this, tetris);
		else{
			TetrisMatrixSetup(tetris, row1, row2, row3, row4);
			int size = Max(this->TileHeight, this->TileWidth);
			this->TileWidth = size;
			this->TileHeight = size;
		}
		int ucmb[16];
		int ucset[16];
		for (int i=0;i<16;i++){
			ucmb[i] = CMB_TETRIS_KLOTSKI_NONSOLID;
			ucset[i] = this->CSet;
			if (tetris[i]==0) ucmb[i]=-1;
		}
		int pushdir=-1;
		int pushcounter=0;
		int movecounter=0;
		this->Data = FFCS_INVISIBLE_COMBO;
		ReplaceCombosUnderFFC(this, tetris,  ucmb, ucset);
		int rotate=0;
		this->InitD[7]=-1;
		for (int i=0;i<176;i++){
			if (ComboFI(i, CF_BLOCKTRIGGER))Screen->ComboF[i] = CF_BLOCKTRIGGER;
		}
		while(true){
			if (pushdir<0){
				if (LinkOnNonSolidKlotskiBlock(this, tetris)){
					if (Link->PressEx1){
						if (TetrisCanBePushed(this, tetris, Link->Dir, weight, dirs)){
							pushdir = Link->Dir;
							Game->PlaySound(SFX_TETRIS_PUSHBLOCK_MOVE);
							movecounter = 16;
							ReplaceCombosUnderFFC(this, tetris,  ucmb, ucset);
						}
					}
				}
			}
			else{
				if (pushdir==DIR_UP){
					this->Y--;
					if (linkmove)Link->Y--;
				}
				if (pushdir==DIR_DOWN){
					this->Y++;
					if (linkmove)Link->Y++;
				}
				if (pushdir==DIR_LEFT){
					this->X--;
					if (linkmove)Link->X--;
				}
				if (pushdir==DIR_RIGHT){
					this->X++;
					if (linkmove)Link->X++;
				}
				NoAction();
				movecounter--;
				if (movecounter==0){
					if (icy && TetrisCanBePushed(this, tetris, pushdir, 0, dirs)){
						movecounter=16;
					}
					else{
						int pos = ComboAt(CenterLinkX(), CenterLinkY());
						pushdir=-1;
						linkmove=false;
						ReplaceCombosUnderFFC(this, tetris,  ucmb, ucset);
						if (onepush){
							Game->PlaySound(SFX_TETRIS_PUSHBLOCK_STUCK);
							dirs=0;
						}
						if (!notrigger)TetrisTriggerUpdate(this, tetris, colortrigger);
						if (triggerstuck && this->InitD[6]>0){
							Game->PlaySound(SFX_TETRIS_PUSHBLOCK_STUCK);
							dirs=0;
						}
					}
				}
			}
			if (this->InitD[7]>=0 && this->InitD[7]<=3){
				if (TetrisCanBePushed(this, tetris, this->InitD[7], 0, dirs)){
					Game->PlaySound(SFX_TETRIS_PUSHBLOCK_MOVE);
					ReplaceCombosUnderFFC(this, tetris,  ucmb, ucset);
					if (this->InitD[7]==DIR_UP)this->Y-=16;
					if (this->InitD[7]==DIR_DOWN)	this->Y+=16;
					if (this->InitD[7]==DIR_LEFT)	this->X-=16;
					if (this->InitD[7]==DIR_RIGHT)this->X+=16;
					ReplaceCombosUnderFFC(this, tetris,  ucmb, ucset);
					this->InitD[7]=-1;
					if (onepush){
						Game->PlaySound(SFX_TETRIS_PUSHBLOCK_STUCK);
						dirs=0;
					}
					if (!notrigger)TetrisTriggerUpdate(this, tetris,colortrigger);
					if (triggerstuck && this->InitD[6]>0){
						Game->PlaySound(SFX_TETRIS_PUSHBLOCK_STUCK);
						dirs=0;
					}
				}
				else this->InitD[7]=-1;
			}
			if (this->InitD[7]==4){
				if (TryRotateTetris(this, tetris, 1)){
					Game->PlaySound(SFX_TETRIS_PUSHBLOCK_MOVE);
					RotateTetrisBlock(this, tetris, 1, ucmb, ucset);
					rotate+=90;
					if (rotate>=360)rotate=0;
					this->InitD[7]=-1;
					if (!notrigger)TetrisTriggerUpdate(this, tetris,colortrigger);
					if (triggerstuck && this->InitD[6]>0){
						Game->PlaySound(SFX_TETRIS_PUSHBLOCK_STUCK);
						dirs=0;
					}
				}
				else this->InitD[7]=-1;
			}
			if (this->InitD[7]==5){
				if (TryRotateTetris(this, tetris, 2)){
					Game->PlaySound(SFX_TETRIS_PUSHBLOCK_MOVE);
					RotateTetrisBlock(this, tetris, 2, ucmb, ucset);
					rotate-=90;
					if (rotate<0)rotate+=360;
					this->InitD[7]=-1;
					if (!notrigger)TetrisTriggerUpdate(this, tetris, colortrigger);
					if (triggerstuck && this->InitD[6]>0){
						Game->PlaySound(SFX_TETRIS_PUSHBLOCK_STUCK);
						dirs=0;
					}
				}
				else this->InitD[7]=-1;
			}
			// for (int i=0;i<16;i++){
			// if (tetris[i]==0)continue;
			// int x = this->X+(i%4)*16;
			// int y = this->Y+Floor(i/4)*16;
			// Screen->Rectangle(3, x, y, x+15, y+15, 1, -1, 0, 0, 0, false, OP_OPAQUE);
			// }
			if (row1==0 || (flags&32)>0){
				for (int i=0;i<16;i++){
					if (tetris[i]==0)continue;
					int x = this->X+(i%4)*16;
					int y = this->Y+Floor(i/4)*16;
					int cmb = ComboAt(x+1,y+1);
					Screen->FastCombo(1, x, y, origdata, this->CSet, OP_OPAQUE);
				}
			}
			else Screen->DrawCombo(1, this->X, this->Y, origdata, this->TileWidth, this->TileHeight, this->CSet, -1, -1, this->X, this->Y, rotate, 0, 0, true, OP_OPAQUE);
			//debugValue(1,this->InitD[7]);
			//debugValue(2,Link->X);
			//debugValue(3,Link->Y);
			Waitframe();
		}
	}
}

bool LinkOnNonSolidKlotskiBlock(ffc this, int tetris){
	int cmb = ComboAt (CenterLinkX(), CenterLinkY());
	for (int i=0;i<16;i++){
		if (tetris[i]==0)continue;
		int x = this->X+(i%4)*16;
		int y = this->Y+Floor(i/4)*16;
		int tetcmb = ComboAt(x+1,y+1);
		if (tetcmb==cmb)return true;
	}
	return false;
}

//Lift and place polyominoes. Ex1 to lift and place, EX2 to rotate,if held.

//Set up combo with blank tile and NoPushBlocks inherent flag for CMB_TETRIS_KLOTSKI_NONSOLID constant.
//Build floor where blocks can be moved on background layer.
//Place FFC at block initial position. Assign TileWidth and TileHeight so it encompasses entire block.
// D0-D3 Block shape, like Moosh`s way to set up blocks.
//  [0][1][0][0] 
//  [1][1][0][0] 
// T-shaped piece, rotating at center - D0 = 100, D1 = 1100, D2=0, D3=0
//  [0][1][0][0]
//  [1][1][0][0]
//  [1][0][0][0]
// Z-shaped piece, rotating at center - D0 = 100, D1 = 1000, D2 = 100, D3=0
//As an alternative, you can build shape using combos, place FFC with the same combo and CSet at top left corner of shape, and leave D0 as 0.
//
// D4 - Weight, bracelet level needed to push block by hand. If remote controller is used, weight is treated as 0.
// D5 - unused
// D6 - add together: 1 - allow rotating with EX2, 8 - ignore triggers, 16 - require triggers with same CSet as FFC`s Cset.
ffc script PickPlaceTetris{
	void run (int row1, int row2, int row3, int row4, int weight, int unused, int flags){
		int tetris[16];
		int origdata = this->Data;
		this->InitD[6]=0;
		this->InitD[7]=0;
		int rotate=0;
		bool canrotate = (flags&1)>0;
		bool notrigger = (flags&8)>0;
		bool colortrigger = (flags&16)>0;
		if (notrigger)this->InitD[6]=-1;
		if (row1==0)AutomaticTetrisMatrixSetup(this, tetris);
		else{
			TetrisMatrixSetup(tetris, row1, row2, row3, row4);
			int size = Max(this->TileHeight, this->TileWidth);
			this->TileWidth = size;
			this->TileHeight = size;
		}
		int ucmb[16];
		int ucset[16];
		for (int i=0;i<16;i++){
			ucmb[i] = CMB_TETRIS_KLOTSKI_NONSOLID;
			ucset[i] = this->CSet;
			if (tetris[i]==0) ucmb[i]=-1;
		}
		int pushdir=-1;
		int pushcounter=0;
		int movecounter=0;
		this->Data = FFCS_INVISIBLE_COMBO;
		ReplaceCombosUnderFFC(this, tetris,  ucmb, ucset);
		while(true){
			if (this->InitD[7]==0){
				if (LinkOnNonSolidKlotskiBlock(this, tetris) && Link->PressEx1){
					if (TetrisCanLift(this, weight)){
						Game->PlaySound(SFX_TETRIS_PICKPLACE_PICK);
						this->InitD[7]=1;
						ReplaceCombosUnderFFC(this, tetris,  ucmb, ucset);
					}
				}
			}
			else{
				this->X=Link->X - this->TileWidth*8+8;
				this->Y=Link->Y - this->TileHeight*8+8;
				if (LAYER_TETRIS_PICKPLACE_RENDER_GHOST>=0){
					for (int i=0;i<16;i++){
						if (tetris[i]==0)continue;
						int x = GridX(this->X)+(i%4)*16;
						int y = GridY(this->Y)+Floor(i/4)*16;
						Screen->Rectangle(LAYER_TETRIS_PICKPLACE_RENDER_GHOST, x, y, x+15, y+15, 0x81, -1, 0, 0, 0, true, OP_TRANS);
					}
					if (Link->PressEx2){
						if (canrotate){
						Game->PlaySound(SFX_TETRIS_PICKPLACE_ROTATE);
							TetrisRotateCCW (this,tetris);
							TetrisRotateCCW (this,ucmb);
							TetrisRotateCCW (this,ucset);
							rotate+=90;
							if (rotate>=360)rotate=0;
						}
					}
					if (Link->PressEx1){
						if (TetrisCanPlace(this, tetris)){
							Game->PlaySound(SFX_TETRIS_PICKPLACE_PLACE);
							this->X=GridX(this->X);
							this->Y=GridY(this->Y);
							ReplaceCombosUnderFFC(this, tetris,  ucmb, ucset);
							if (!notrigger)TetrisTriggerUpdate(this, tetris,colortrigger);
							this->InitD[7]=0;
						}
					}
					// debugValue(1,this->TileWidth);
					// debugValue(2,this->TileHeight);
				}
			}
			int offset = 0;
			if (this->InitD[7]>0) offset = TETRIS_PICKPLACE_LIFT_OFFSET;
			if (row1==0){
				for (int i=0;i<16;i++){
					if (tetris[i]==0)continue;
					int x = this->X+(i%4)*16;
					int y = this->Y+Floor(i/4)*16;
					int cmb = ComboAt(x+1,y+1);
					Screen->FastCombo(Cond(this->InitD[7]>0, 3,1), x, y-offset, origdata, this->CSet, OP_OPAQUE);
				}
			}
			else Screen->DrawCombo(Cond(this->InitD[7]>0, 3,1), this->X, this->Y-offset, origdata, this->TileWidth, this->TileHeight, this->CSet, -1, -1, this->X, this->Y, rotate, 0, 0, true, OP_OPAQUE);
			Waitframe();
		}		
	}
}


// Returns Link`s pushing power. Also prohibits lifting more than 1 polyomino at time. 
bool TetrisCanLift(ffc f, int weight){
	for(int i=1;i<=32;i++){
		if (Screen->State[ST_SECRET]) break;
		if (i==33){
			Game->PlaySound(SFX_SECRET);
			Screen->TriggerSecrets();
			Screen->State[ST_SECRET]=true;
			break;
		}
		ffc n = Screen->LoadFFC(i);
		if (n->Script!=f->Script)continue;
		if (n->InitD[7] > 0) return false;
	}
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

bool TetrisCanPlace(ffc this, int tetris){
	for (int i=0;i<16;i++){
		if (tetris[i]==0)continue;
		int x = GridX(this->X)+(i%4)*16;
		int y = GridY(this->Y)+Floor(i/4)*16;
		int cmb = ComboAt(x+1,y+1);
		if (Screen->ComboS[cmb]>0) return false;
		if (ComboFI(cmb, CF_NOBLOCKS)) return false;
	}
	return true;
}