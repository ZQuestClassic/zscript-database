const int CUSTOM_LENS_HINTS_MAX_LAYERS = 0; //Maximum layers to check screens for lens hints

//Global script example.
global script LensHints{
	void run (){
		while (true){
			Waitdraw();
			DrawCustomLensHints();
			Waitframe();
		}
	}
}

//Main custom lens hint drawing function. Put this into main loop of "Action" global script.
void DrawCustomLensHints(){
	if (Link->MP<=0) return;
	if (!UsingItem(I_LENS))return;
	//Add lens hints here.
	DrawCustomLensHint(0, 120, 1028, 8, 1);//Draw combo#1028 with cset 8 on all combos of type 120 (damage 8 hearts)
	DrawCustomLensHint(1, 98, 1029, 7, 1);//Draw combo#1029 with cset 7 on all combos with inherent or placed flag 98 (Script 1)
	DrawCustomLensHint(2, 55, 1030, 6, 1);//Draw combo#1030 with cset 6 on all NPC`s with ID#55 (Arrow Pols Voices)
	//Add more lens hints here.
	
}

//Lenstype: 0-combo type, 1-combo flag, 2 - NPC.
//miscvalue1: depends on lenstype:
// 0 - combo type ID
// 1 - combo flag ID
// 2 - NPC ID
//cmb - combo to draw, cset - cset to use for hint drawing
//minlevel - minimum item level for Lens-like item needed to be used to reveal this hint.
void DrawCustomLensHint(int lenstype, int miscvalue1, int cmb, int cset, int minlevel){
	int lens = GetCurrentItem(IC_LENS);
	itemdata it = Game->LoadItemData(lens);
	if (it->Level<minlevel) return;
	if (lenstype==0){//combo types
		for (int l=0; l<=CUSTOM_LENS_HINTS_MAX_LAYERS; l++){
			if (l==0){
				for (int c=0;c<176;c++){
					if (Screen->ComboT[c]==miscvalue1) Screen->FastCombo(0, ComboX(c), ComboY(c), cmb, cset, OP_OPAQUE);
				}
			if ((Screen->LayerMap(l)==-1)||(Screen->LayerScreen(l)==-1))continue;
			for (int c=0;c<176;c++){
					int lc = GetLayerComboT(l, c);
					if (Screen->ComboT[lc]==miscvalue1) Screen->FastCombo(l, ComboX(lc), ComboY(lc), cmb, cset, OP_OPAQUE);
				}
			}
		}
		return;
	}
	else if (lenstype==1){//combo flags
		for (int l=0; l<=CUSTOM_LENS_HINTS_MAX_LAYERS; l++){
			if (l==0){
				for (int c=0;c<176;c++){
					if (ComboFI(c, miscvalue1)) Screen->FastCombo(0, ComboX(c), ComboY(c), cmb, cset, OP_OPAQUE);
				}
			if ((Screen->LayerMap(l)==-1)||(Screen->LayerScreen(l)==-1))continue;
			for (int c=0;c<176;c++){
					int lc = GetLayerComboT(l, c);
					if (ComboFI(lc, miscvalue1)) Screen->FastCombo(l, ComboX(lc), ComboY(lc), cmb, cset, OP_OPAQUE);
				}
			}
		}
		return;
	}
	else if (lenstype==2){//enemies
		for (int i=1; i<= Screen->NumNPCs(); i++ ){
			npc lensie= Screen->LoadNPC(i);
			if (lensie->ID==miscvalue1) Screen->FastCombo(6, lensie->X, lensie->Y-lensie->Z, cmb, cset, OP_OPAQUE);
		}
	}
}

//Draws Lens hints on FFC`s if FFC runs given script and has specific value set in checked Init D variable.
void DrawFFCLensHint(int scr, int dreg, int dvalue, int cmb, int cset, int minlevel){
	int lens = GetCurrentItem(IC_LENS);
	itemdata it = Game->LoadItemData(lens);
	if (it->Level<minlevel) return;
	for (int i=1;i<=32;i++){
		ffc lensie = Screen->LoadFFC(i);
		if (lensie->Script!=scr) continue;
		if (lensie->InitD[dreg]!=dvalue) continue;
		Screen->FastCombo(0, CenterX(lensie), CenterY(lensie), cmb, cset, OP_OPAQUE);
	}
}

//FFC version of custom lens hints.
//D0 - Lenstype: 0-combo type, 1-combo flag, 2 - NPC.
//D1: depends on lenstype:
// 0 - combo type ID
// 1 - combo flag ID
// 2 - NPC ID
//D2 - combo to draw, 
//D3 - cset to use for hint drawing
//D4 - minimum item level for Lens-like item needed to be used to reveal this hint.
ffc script CustomLensHints{
	void run (int lenstype, int miscvalue1, int cmb, int cset, int minlevel){
		while (true){
			DrawCustomLensHint(lenstype, miscvalue1, cmb, cset, minlevel);
			Waitframe();
		}
	}
}