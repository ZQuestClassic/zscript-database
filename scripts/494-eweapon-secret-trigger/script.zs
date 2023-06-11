//Triggers screen secrets, when hit by specific eweapon. Changes to next combo in list.

//Place at trigger location.
//D0 - eweapon type ( EW_* from stdConstants.zh)
//D1 - minimum damaging power needed to trigger.
ffc script EweaponTrigger{
	void run (int ewtype, int mindamage){
		int cmb = ComboAt(CenterX(this), CenterY(this));
		if (Screen->State[ST_SECRET]){
			Screen->ComboD[cmb]++;
			Quit();
		}
		while(true){
			for (int i=1;i<=Screen->NumEWeapons();i++){
				eweapon e = Screen->LoadEWeapon(i);
				if (this->InitD[7]==1) continue;
				if (e->ID!=ewtype) continue;
				if (e->Damage<mindamage) continue;
				if (!Collision(this,e)) continue;
				Remove(e);
				Game->PlaySound(SFX_SECRET);
				Screen->ComboD[cmb]++;
				this->InitD[7]=1;
				for(int j=1;j<=33;j++){
					if (j==33){
						//Game->PlaySound(SFX_SECRET);
						Screen->TriggerSecrets();
						Screen->State[ST_SECRET]=true;
						break;
					}
					ffc n = Screen->LoadFFC(j);
					if (n->Script!=this->Script)continue;
					if (n->InitD[7] == 0) break;
				}
			}
			Waitframe();
		}
	}
}