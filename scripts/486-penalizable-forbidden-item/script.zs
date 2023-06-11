//Variant of banning items with penalty for even accidental usage - deals damage and warps Link away.

//Set up 2 consecutive combos, invisibla one, then auto-side warp.
//Place FFC with 1st combo from step 1 and script assigned.
//D0-D3 - ID of forbidden items. 5 banned items total.
//D5 - String to display on violation.
//D6 - Damage to deal as penalty, in addition to warp, in 1/16th of heart.
//D7 - 1-> Confiscate forbidden item from Link`s inventory. +2->Save game immediately to seal penalty in save file. +4 - charge 50% rupees fine
//Set up side warp.
ffc script ForbiddenItem{
	void run(int itm1,int itm2, int itm3, int itm4, int itm5, int str, int dam, int flags){
		int viol = -1;
		int fitems[5]={itm1,itm2,itm3,itm4, itm5};
		Waitframe();
		while(true){
			for (int i=0;i<5;i++){
				int itm=fitems[i];
				if (fitems[i]<=0)continue;
				if (GetEquipmentB()==itm){
					if (Link->InputB || Link->PressB)viol=itm;
				}
				if (GetEquipmentA()==itm){
					if (Link->InputA || Link->PressA)viol=itm;
				}
			}
			if (viol>=0){
				Trace(viol);
				Screen->Message(str);
				Waitframe();
				if (dam>0){
					Link->HP-=dam;
					Game->PlaySound(SFX_OUCH);
				}
				if ((flags&1)>0) Link->Item[viol]=false;
				if ((flags&4)>0) Game->Counter[CR_RUPEES]=Floor(Game->Counter[CR_RUPEES]/2);
				if ((flags&2)>0) Game->Save();
				this->Data++;
			}
			Waitframe();
		}
	}
}