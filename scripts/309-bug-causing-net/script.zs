const int TIL_BUGCAUSINGNET = 19; //Tile used for the next (Facing right)
const int CS_BUGCAUSINGNET = 5; //CSet used for the net

item script BugCausingNet{
	void run(){
		int bcn[] = "BugCausingNetFFC";
		// if(CountFFCsRunning(Game->GetFFCScript(bcn))==0){
		RunFFCScript(Game->GetFFCScript(bcn), 0);
		// }
	}
}

const int NO_ZELDA_FLAG = 1; //Prevent the script from changing to the Zelda (Win Game) flag (because it's boring)

const int BCN_TILE_REPLACEMENTS = 50; //Number of tiles to change
const int BCN_TILE_VARIANCE = 10; //Random chance for extra tiles to be changed
const int BCN_MAX_TILE = 65519; //Highest tile it can randomize
const int BCN_COMBO_REPLACEMENTS = 4; //How many combos to change
const int BCN_CSET_REPLACEMENTS = 4; //How many csets to change
const int BCN_FLAG_REPLACEMENTS = 2; //How many flags to change
const int BCN_COMBO_VARIANCE = 2; //Random chance for extra combos to change
const int BCN_FLAG_VARIANCE = 2; //Random chance for extra flags to change
const int BCN_SCRIPT_VARIANCE = 4; //How much to offset scripts at max
const int BCN_SCREEND_VARIANCE = 8; //How much to offset Screen->D[] at max
const int BCN_WARP_DMAP_VARIANCE = 8; //How much to offset DMaps in warps

const int BCN_CHANCE_BREAK_ARRAYS = 8; //Chance of screwing up global arrays. Can cause crashes. Set to -1 to disable
const int BCN_CHANCE_SCRIPT_SCREWUP = 4; //Chance of offsetting all FFC scripts
const int BCN_CHANCE_REPLACE_NPC = 8; //Chance of killing all NPCs and replacing them with new ones
const int BCN_CHANCE_CSET_OFFSET = 3; //Chance of offsetting all csets
const int BCN_CHANCE_WEAPON_SCREWUP = 3; //Chance of screwing up all onscreen weapons
const int BCN_CHANCE_NPC_SCREWUP = 4; //Chance of screwing up all onscreen NPCS
const int BCN_CHANCE_WARP_SCREWUP = 4; //Chance of screwing up warps
const int BCN_CHANCE_POSITION_SCREWUP = 4; //Chance of screwing up Link's position

ffc script BugCausingNetFFC{
	void run(){
		int i; int j; int k; int m;
		int baconArray[8];
		Break_Everything(this, baconArray);
		int angle = 0;
		if(Link->Dir==DIR_UP)
			angle = -90;
		else if(Link->Dir==DIR_DOWN)
			angle = 90;
		else if(Link->Dir==DIR_LEFT)
			angle = 180;
		Game->PlaySound(SFX_SPINATTACK);
		for(i=0; i<360; i+=18){
			angle = WrapDegrees(angle+18);
			Link->Action = LA_ATTACKING;
			Link->Dir = AngleDir4(angle);
			int x = Link->X+VectorX(16, angle);
			int y = Link->Y+VectorY(16, angle);
			Screen->DrawTile(4, x, y, TIL_BUGCAUSINGNET, 1, 1, CS_BUGCAUSINGNET, -1, -1, x, y, angle, 0, true, 128);
			Continue_To_Break_Everything(baconArray);
			WaitNoAction();
		}
		if(!Is_It_Time_To_Stop(baconArray)){
			for(i=0; i<300; i++){
				Continue_To_Break_Everything(baconArray);
				Waitframe();
			}
		}
	}
	void DoTheZoria(){
		for ( int q = 0; q < 1892; q++ ) {
			int x = SizeOfArray(q); 
			for ( x; x >= 0; x-- ){
				q[x] += Choose(-Rand(1, 8), Rand(1, 8));
			}
		}
	}
	void Break_Everything(ffc this, int baconArray){
		int i;  int j; int k; int m; int o; int p; 
		if(BCN_TILE_REPLACEMENTS>0){
			p = Floor((BCN_MAX_TILE+1)/2);
			//Scramble at least one tile onscreen
			i = Screen->ComboD[Rand(176)];
			SwapTile(Game->ComboTile(i), Rand(p)+Rand(p));
			//Scramble tiles
			o = Rand(BCN_TILE_VARIANCE);
			for(i=0; i<BCN_TILE_REPLACEMENTS+o; i++){
				j = Rand(p)+Rand(p);
				k = Rand(p)+Rand(p);
				SwapTile(j, k);
			}
		}
		//Scramble combos onscreen
		if(BCN_COMBO_REPLACEMENTS>0){
			i = ComboAt(Clamp(Link->X+8+InFrontX(Link->Dir, 0), 0, 255), Clamp(Link->Y+8+InFrontY(Link->Dir, 0), 0, 175));
			j = Rand(176);
			m = Screen->ComboD[i];
			Screen->ComboD[i] = Screen->ComboD[j];
			Screen->ComboD[j] = Screen->ComboD[i];
			o = Rand(BCN_COMBO_VARIANCE);
			for(i=0; i<BCN_COMBO_REPLACEMENTS+o; i++){
				i = Rand(176);
				j = Rand(176);
				m = Game->GetComboData(Game->GetCurMap(), Game->GetCurScreen(), i);
				Game->SetComboData(Game->GetCurMap(), Game->GetCurScreen(), i, Game->GetComboData(Game->GetCurMap(), Game->GetCurScreen(), j));
				Game->SetComboData(Game->GetCurMap(), Game->GetCurScreen(), j, m);
			}
			for(p=1; p<=6; p++){
				if(Screen->LayerScreen(p)>-1){
					o = Rand(BCN_COMBO_VARIANCE);
					for(i=0; i<BCN_COMBO_REPLACEMENTS+o; i++){
						i = Rand(176);
						j = Rand(176);
						m = Game->GetComboData(Screen->LayerMap(p), Screen->LayerScreen(p), i);
						Game->SetComboData(Screen->LayerMap(p), Screen->LayerScreen(p), i, Game->GetComboData(Screen->LayerMap(p), Screen->LayerScreen(p), j));
						Game->SetComboData(Screen->LayerMap(p), Screen->LayerScreen(p), j, m);
					}
				}
			}
		}
		//Scramble csets onscreen
		o = Rand(BCN_COMBO_VARIANCE);
		if(BCN_CSET_REPLACEMENTS>0){
			for(i=0; i<BCN_CSET_REPLACEMENTS+o; i++){
				i = Rand(176);
				j = Rand(176);
				m = Game->GetComboCSet(Game->GetCurMap(), Game->GetCurScreen(), i);
				Game->SetComboCSet(Game->GetCurMap(), Game->GetCurScreen(), i, Game->GetComboCSet(Game->GetCurMap(), Game->GetCurScreen(), j));
				Game->SetComboCSet(Game->GetCurMap(), Game->GetCurScreen(), j, m);
			}
			for(p=1; p<=6; p++){
				if(Screen->LayerScreen(p)>-1){
					o = Rand(BCN_COMBO_VARIANCE);
					for(i=0; i<BCN_CSET_REPLACEMENTS+o; i++){
						i = Rand(176);
						j = Rand(176);
						m = Game->GetComboCSet(Screen->LayerMap(p), Screen->LayerScreen(p), i);
						Game->SetComboCSet(Screen->LayerMap(p), Screen->LayerScreen(p), i, Game->GetComboCSet(Screen->LayerMap(p), Screen->LayerScreen(p), j));
						Game->SetComboCSet(Screen->LayerMap(p), Screen->LayerScreen(p), j, m);
					}
				}
			}
		}
		//Scramble screen flags
		o = Rand(BCN_FLAG_VARIANCE);
		if(BCN_FLAG_REPLACEMENTS>0){
			for(i=0; i<BCN_FLAG_REPLACEMENTS+o; i++){
				i = Rand(176);
				j = Rand(103);
				if(NO_ZELDA_FLAG&&j==15) //Prevent Zelda flag
					j = 0;
				Screen->ComboF[i] = j;
			}
		}
		//Scramble Screen->D[]
		for(i=0; i<8; i++){
			if(Rand(2)==0)
				Screen->D[i] -= Rand(1, BCN_SCREEND_VARIANCE);
			else
				Screen->D[i] += Rand(1, BCN_SCREEND_VARIANCE);
		}
		
		//Chance of screwing up global arrays
		if(BCN_CHANCE_BREAK_ARRAYS>-1){
			if(Rand(0, BCN_CHANCE_BREAK_ARRAYS)==1){
				DoTheZoria();
			}
		}
		//Chance of offset all scripts onscreen
		if(Rand(0, BCN_CHANCE_SCRIPT_SCREWUP)==1){
			for(i=1; i<=32; i++){
				ffc f = Screen->LoadFFC(i);
				if(f->Script>0&&f->Script!=this->Script){
					o = 1+Rand(BCN_SCRIPT_VARIANCE);
					j = Max(f->Script+Choose(-o, o), 0);
					//Randomize D registers
					for(k=0; k<8; k++){
						f->InitD[k] = Rand(256);
					}
					//Randomly offset combo and CSet
					f->Script = j;
					j = Max(f->Data+Choose(-1, 1), 1);
					f->Data = j;
					f->CSet = Rand(12);
				}
			}
		}
		//Chance of replacing all NPCs
		if(Rand(0, BCN_CHANCE_REPLACE_NPC)==1){
			int ids[256];
			int xpos[256];
			int ypos[256];
			int count;
			for(i=0; i<=Screen->NumNPCs(); i++){
				npc n = Screen->LoadNPC(i);
				j = Max(n->ID+Choose(-1, 1), 1);
				n->DrawYOffset = -1000;
				SetEnemyProperty(n, ENPROP_HP, -1000);
				ids[count] = j;
				xpos[count] = CenterX(n)-8;
				ypos[count] = CenterY(n)-8;
				count++;
			}
			for(i=0; i<count; i++){
				npc n = CreateNPCAt(ids[i], xpos[i], ypos[i]);
			}
		}
		//Chance of offsetting all csets
		if(Rand(0, BCN_CHANCE_CSET_OFFSET)==1){
			j = Rand(1, 10);
			for(i=0; i<176; i++){
				k = Screen->ComboC[i]+j;
				if(k>11)
					k -= 11;
				Screen->ComboC[i] = j;
			}
		}
		//Chance of screwing up weapons
		if(Rand(0, BCN_CHANCE_WEAPON_SCREWUP)==1){
			baconArray[0] = 1;
		}
		//Chance of screwing up npcs
		if(Rand(0, BCN_CHANCE_NPC_SCREWUP)==1){
			baconArray[1] = 1;
		}
		//Chance of screwing up warps
		if(Rand(0, BCN_CHANCE_WARP_SCREWUP)==1){
			for(i=0; i<4; i++){
				j = Screen->GetSideWarpDMap(i);
				if(Rand(2)==0)
					j = Max(j+Rand(BCN_WARP_DMAP_VARIANCE), 0);
				else
					j = Max(j-Rand(BCN_WARP_DMAP_VARIANCE), 0);
				Screen->SetSideWarp(i, Rand(0x7F), j, Screen->GetSideWarpType(i));
				
				j = Screen->GetTileWarpDMap(i);
				if(Rand(2)==0)
					j = Max(j+Rand(BCN_WARP_DMAP_VARIANCE), 0);
				else
					j = Max(j-Rand(BCN_WARP_DMAP_VARIANCE), 0);
				Screen->SetTileWarp(i, Rand(0x7F), j, Screen->GetTileWarpType(i));
			}
		}
		if(Rand(0, BCN_CHANCE_POSITION_SCREWUP)==1){
			for(i=0; i<176; i++){
				o = Rand(176);
				if(!Screen->isSolid(ComboX(o)+4, ComboY(o)+4) &&
					!Screen->isSolid(ComboX(o)+12, ComboY(o)+4) &&
					!Screen->isSolid(ComboX(o)+4, ComboY(o)+12) &&
					!Screen->isSolid(ComboX(o)+12, ComboY(o)+12) &&
					Screen->ComboT[ComboAt(ComboX(o)+8, ComboY(o)+8)]!=CT_WATER){
					break;
				}
			}
			Link->X = ComboX(o);
			Link->Y = ComboY(o);
		}
	}
	void Continue_To_Break_Everything(int baconArray){
		int i; int j; int k;
		if(baconArray[0]>0){
			for(i=1; i<=Screen->NumEWeapons(); i++){
				eweapon e = Screen->LoadEWeapon(i);
				e->DrawXOffset += Rand(-2, 2);
				e->DrawYOffset += Rand(-2, 2);
				e->HitXOffset += Rand(-2, 2);
				e->HitYOffset += Rand(-2, 2);
				e->Angle = DegtoRad(RadtoDeg(e->Angle)+Rand(-20, 20));
				e->Dir = Rand(8);
				e->Step += Rand(-4, 4);
				e->Tile += Rand(-1, 1);
				e->CSet = Rand(12);
				e->X += Rand(-1, 1);
				e->Y += Rand(-1, 1);
			}
			for(i=1; i<=Screen->NumLWeapons(); i++){
				lweapon l = Screen->LoadLWeapon(i);
				l->DrawXOffset += Rand(-2, 2);
				l->DrawYOffset += Rand(-2, 2);
				l->HitXOffset += Rand(-2, 2);
				l->HitYOffset += Rand(-2, 2);
				l->Angle = DegtoRad(RadtoDeg(l->Angle)+Rand(-20, 20));
				l->Dir = Rand(8);
				l->Step += Rand(-4, 4);
				l->Tile += Rand(-1, 1);
				l->CSet = Rand(12);
				l->X += Rand(-1, 1);
				l->Y += Rand(-1, 1);
			}
		}
		if(baconArray[1]>0){
			for(i=1; i<=Screen->NumNPCs(); i++){
				npc n = Screen->LoadNPC(i);
				n->DrawXOffset += Rand(-2, 2);
				n->DrawYOffset += Rand(-2, 2);
				n->HitXOffset += Rand(-2, 2);
				n->HitYOffset += Rand(-2, 2);
				n->Dir = Rand(8);
				n->Step += Rand(-4, 4);
				n->Tile += Rand(-1, 1);
				n->CSet = Rand(12);
				n->X += Rand(-1, 1);
				n->Y += Rand(-1, 1);
				if(n->Z<=0&&Rand(64)==0)
					n->Jump = Rand(10, 40)/10;
			}
	}
	}
	bool Is_It_Time_To_Stop(int baconArray){
		for(int i=0; i<8; i++){
			if(baconArray[i]>0)
				return false;
		}
		return true;
	}
}