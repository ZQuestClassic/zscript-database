//Combo effect that renders Link is on specific combo.

//Find UpdateComboEffects() function and copy RenderComboEffect for each combo that should have effect to render with following params:
// cmb - leave as this
// targcmb - if Link is on that combo (from combo table), render effect.
// cmbeffect - combo to use for rendering animation
// csetdffect - Cset to use for rendering animation
// itm - item that cancels rendering this animation, for instace, when that item prevents speed penalty when walking on that combo.
// reverse - if true, item mentioned in "itm" will be instead REQUIRED to render combo effect, like protective aura on boots vs damage combos.
// drawover - if true, combo effect will render on top of link, instead of under.

global script ComboEffects {
	void run(){		
		while(true){			
			Waitframe();			
			UpdateComboEffects();
		}
	}
}


void UpdateComboEffects(){
	if (Link->Z!=0)return;
	int cmb = ComboAt(Link->X+7,Link->Y+10);
	
	RenderComboEffect (cmb, 16, 1114, 2, 10, false, true);//Add call of this function for each combo and effect atttached.
	RenderComboEffect (cmb, 12, 1114, 2, 10, true, false);
}

void RenderComboEffect (int cmb, int targcmb, int cmbeffect, int cseteffect, int itm, bool reverse, bool drawover){
	if (Screen->ComboD[cmb]!= targcmb)return;
	if (itm>0){
		if (reverse != Link->Item[itm]) return;
	}
	Screen->FastCombo	(Cond(drawover, 4, 1), Link->X, Link->Y, cmbeffect, cseteffect, OP_OPAQUE);
}

global script SandStorm{
    void run(){
		StartGhostZH();
		LinkMovement_Init();

		while(true){
			UpdateGhostZH1();
			LinkMovement_Update1();//Not needed for Combo Effects rendering
			
			Waitdraw();
			
			UpdateGhostZH2();
			LinkMovement_Update2();//Not needed for Combo Effects rendering
						
			Waitframe();
			
			UpdateComboEffects();
		}
	}
}