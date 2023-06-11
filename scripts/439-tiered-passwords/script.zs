const int SCREEN_D_TIER_PASSWORD = 0;//Screen D used for tiered password progress tracking.

//Tiered passwords. Input multiple passwords in sequence to trigger multiple secrets.
//Each password is separate FFC. Any way to change combos can be used.
//Build password panel (4 combos).
//D0 - Screen D bit that must be set to True prior to inputing password.
//D1 - D4 Password
// #####.____ - combo ID
// _____.#### - combo position.
//D5 - Screen D bit to set on correct password input.
//D6 - if set to >= 0 - ID of combo to change to next one. -1 for standard secret trigger.
//D7 - If set to >0, password won`t trigger automatically. Link must stand on combo underneath FFC, make sure it matches FFC`s orig data and press EX1 to check validity of password. 

ffc script TieredPassword{
	void run(int dreq, int cmb1, int cmb2, int cmb3, int cmb4, int dset, int cmbsecret, int inputcheck){
		int origdata = this->Data;
		this->Data = FFCS_INVISIBLE_COMBO;
		if (GetScreenDBit(SCREEN_D_TIER_PASSWORD, dset)){
			if (cmbsecret==-1) Screen->TriggerSecrets();
			else for (int i=0;i<176;i++){
				if (Screen->ComboD[i]==cmbsecret)Screen->ComboD[i]++;
			}
			Quit();
		}
		int arrcmb[4] = {cmb1, cmb2, cmb3, cmb4};
		int pos[4];
		int cmb[4];
		for(int i=0; i<4; i++){
			pos[i] = GetLowFloat(arrcmb[i]);
			cmb[i] = GetHighFloat(arrcmb[i]);
		}
		if (dreq>=0){
			while(!GetScreenDBit(SCREEN_D_TIER_PASSWORD, dreq)) Waitframe();
		}
		while(true){
			bool check = false;
			if (inputcheck==0) check=true;
			int linkcmb = ComboAt(CenterLinkX(), CenterLinkY());
			int ffccmb = ComboAt(CenterX(this), CenterY(this));
			if (Link->PressEx1 && linkcmb==ffccmb && Screen->ComboD[ffccmb]==origdata) check=true;
			if (check){
				for (int i=0; i<=4; i++){
					if (i==4){
						Game->PlaySound(SFX_SECRET);
						if (cmbsecret==-1) Screen->TriggerSecrets();
						else for (int i=0;i<176;i++){
							if (Screen->ComboD[i]==cmbsecret)Screen->ComboD[i]++;
						}
						SetScreenDBit(SCREEN_D_TIER_PASSWORD, dset, true);
						Quit();
					}
					int sol = pos[i];
					if (Screen->ComboD[sol] != cmb[i]){
						//debugValue(9, i);
						break;
					}
				}
			}
			//for (int i=0; i<4; i++){
			//	int sol = pos[i];
			//	debugValue(i+1, Screen->ComboD[sol]);
			//	debugValue(i+5, sol);
			//	debugValue(i+10, cmb[i]);
			//}
			Waitframe();
		}
	}
}