ffc script SlabConnectPuzzle{
	void run (int cmb, int tile){
		if (Screen->State[ST_SECRET]) Quit();
		int str[] = "FreeformPushBlock";
		int scr = Game->GetFFCScript(str);
		while (true){
			for (int i=0; i<=176; i++){//Process puzzle mechanics
				if (Screen->State[ST_SECRET]) break;
				if (i==176){
					Game->PlaySound(SFX_SECRET);
					Screen->TriggerSecrets();
					Screen->State[ST_SECRET]=true;
				}
				int cd = Screen->ComboD[i];
				if ((cd>= cmb)&&(cd<=(cmb+7))){
					int adj = AdjacentCombo(i, DIR_RIGHT);
					if (adj==-1)break;
					if (Screen->ComboD[adj] != (cd+8)) break;
				}
				if ((cd>= (cmb+8))&&(cd<=(cmb+15))){
					int adj = AdjacentCombo(i, DIR_LEFT);
					if (adj==-1)break;
					if (Screen->ComboD[adj] != (cd-8)) break;
				}
				if ((cd>= (cmb+16)&&(cd<=(cmb+23)))){
					int adj = AdjacentCombo(i, DIR_DOWN);
					if (adj==-1)break;
					if (Screen->ComboD[adj] != (cd+8)) break;
				}
				if ((cd>= (cmb+24))&&(cd<=(cmb+31))){
					int adj = AdjacentCombo(i, DIR_UP);
					if (adj==-1)break;
					if (Screen->ComboD[adj] != (cd-8)) break;
				}
			}
			for (int i=0; i<176; i++){//Render puzzle shapes
				int cd = Screen->ComboD[i];
				int cset = Screen->ComboC[i];
				if ((cd>= cmb)&&(cd<=(cmb+7))){
					int offset = cd - cmb;
					int tl = tile + offset*20;
					DrawPuzzleShape(ComboX(i), ComboY(i), tl, DIR_RIGHT, cset);
				}
				if ((cd>= (cmb+8))&&(cd<=(cmb+15))){
					int offset = cd - cmb - 8;
					int tl = tile + offset*20 + 2;
					DrawPuzzleShape(ComboX(i), ComboY(i), tl, DIR_LEFT, cset);
				}
				if ((cd>= (cmb+16))&&(cd<=(cmb+23))){
					int offset = cd - cmb - 16;
					int tl = tile + offset + 160;
					DrawPuzzleShape(ComboX(i), ComboY(i), tl, DIR_DOWN, cset);
				}
				if ((cd>= (cmb+24))&&(cd<=(cmb+31))){
					int offset = cd - cmb - 24;
					int tl = tile + offset + 168;
					DrawPuzzleShape(ComboX(i), ComboY(i), tl, DIR_UP, cset);
				}
			}
			for (int i=1;i<=32; i++){
				ffc f = Screen->LoadFFC(i);
				if (f->Script != scr) continue;
				if (f->Misc[FFC_MISC_PUSHBLOCK_IMPULSE] ==-1) continue;
				int cset = f->CSet;
				int cd = f->Data;
				int x = f->X;
				int y = f->Y;
				if ((cd>= cmb)&&(cd<=(cmb+7))){
					int offset = cd - cmb;
					int tl = tile + offset*20;
					DrawPuzzleShape(x, y, tl, DIR_RIGHT, cset);
				}
				if ((cd>= (cmb+8))&&(cd<=(cmb+15))){
					int offset = cd - cmb - 8;
					int tl = tile + offset*20 + 2;
					DrawPuzzleShape(x, y, tl, DIR_LEFT, cset);
				}
				if ((cd>= (cmb+16))&&(cd<=(cmb+23))){
					int offset = cd - cmb - 16;
					int tl = tile + offset + 160;
					DrawPuzzleShape(x, y, tl, DIR_DOWN, cset);
				}
				if ((cd>= (cmb+24))&&(cd<=(cmb+31))){
					int offset = cd - cmb - 24;
					int tl = tile + offset + 168;
					DrawPuzzleShape(x, y, tl, DIR_UP, cset);
				}
			}
			Waitframe();
		}
	}
} 

void DrawPuzzleShape(int x, int y, int tile, int dir, int cset){
	if (dir==DIR_LEFT)x -= 16;
	if (dir==DIR_UP)y-=16;
	if (dir<2) Screen->DrawTile(2, x, y, tile, 1, 2, cset, -1, -1, 0, 0, 0, 0, true, OP_OPAQUE);
	else Screen->DrawTile(2, x, y, tile, 2, 1, cset, -1, -1, 0, 0, 0, 0, true, OP_OPAQUE);
}