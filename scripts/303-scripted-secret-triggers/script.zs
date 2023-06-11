//D0: The LW_ weapon type to check for (std_constants.zh)
//D1: The screen flag to check for on layer 0. If 0, the FFC itself is the trigger.
//D2: The type of secret it's using:
//		-0: Self only
//		-1: Trigger Secrets (Temp)
//		-2: Trigger Secrets (Perm)
//		-3: Hit All (Temp)
//		-4: Hit All (Perm)
//D3: The combo to set the trigger combo to. If 0, will increase the combo by 1
//D4: The CSet for the trigger combo
//D5: The sound to play when the secret is triggered

ffc script ScriptWeaponTrigger{
	void run(int weapon_type, int marker_flag, int secret_type, int secret_combo, int secret_cset, int sfx){
		int i; int j; int k;
		if(secret_type==4){ //If a permanent trigger is set
			if(Screen->State[ST_SECRET]){
				if(marker_flag==0){ //If the FFC is the trigger
					if(secret_combo>0){
						this->Data = secret_combo;
						this->CSet = secret_cset;
					}
					else{
						this->Data++;
					}
				}
				else{ //If a combo is the trigger
					for(j=0; j<176; j++){
						if(ComboFI(j, marker_flag)){
							if(secret_combo>0){
								Screen->ComboD[j] = secret_combo;
								Screen->ComboC[j] = secret_cset;
								Screen->ComboF[j] = 0;
							}
							else{
								Screen->ComboD[j]++;
								Screen->ComboF[j] = 0;
							}
						}
					}
				}
			}
		}
		bool trigger;
		while(!trigger){
			//Cycle through weapons backwards to save the frames
			for(i=Screen->NumLWeapons(); i>=1; i--){
				lweapon l = Screen->LoadLWeapon(i);
				if(l->ID==weapon_type){ //First check if the weapon is the right type
					if(l->CollDetection&&l->DeadState<0){ //Then check if it has collision
						if(marker_flag==0){ //If the FFC is the trigger
							if(Collision(this, l)){
								Game->PlaySound(sfx);
								SWT_BounceWeapon(l);
								if(secret_combo>0){ //If a secret combo is specified, change to that
									this->Data = secret_combo;
									this->CSet = secret_cset;
								}
								else{ //Else increase by 1
									this->Data++;
								}
								if(secret_type==0){ //A self only secret quits out here
									Quit();
								}
								else if(secret_type==1||secret_type==2){ //A screen secret trigger breaks the loop
									trigger = true;
								}
								else if(secret_type==3||secret_type==4){ //A hit all trigger breaks the loop
									if(CountFFCsRunning(this->Script)==1){ //Only if it's the last one
										trigger = true;
									}
									else //Otherwise it quits
										Quit();
								}
							}
						}
						else{ //If a combo is the trigger
							int flagCount;
							for(j=0; j<176; j++){
								if(ComboFI(j, marker_flag)){
									flagCount++;
									int x = l->X+l->HitXOffset;
									int y = l->Y+l->HitYOffset;
									if(RectCollision(ComboX(j), ComboY(j), ComboX(j)+15, ComboY(j)+15, x, y, x+l->HitWidth-1, y+l->HitHeight-1)){
										Game->PlaySound(sfx);
										SWT_BounceWeapon(l);
										if(secret_combo>0){ //If a secret combo is specified, change to that
											Screen->ComboD[j] = secret_combo;
											Screen->ComboC[j] = secret_cset;
											Screen->ComboF[j] = 0;
										}
										else{ //Else increase by 1
											Screen->ComboD[j]++;
											Screen->ComboF[j] = 0;
										}
										if(secret_type==1||secret_type==2){ //A screen secret triggers secrets
											Screen->TriggerSecrets();
											if(secret_type==2)
												Screen->State[ST_SECRET] = true;
										}
									}
								}
							}
							if(flagCount==0){ //If all triggers are hit and type is 3 or 4, break out of the loop
								if(secret_type==3||secret_type==4){
									trigger = true;
								}
							}
						}
					}
				}
				if(trigger)
					break;
			}
			Waitframe();
		}
		Screen->TriggerSecrets();
		if(secret_type==2||secret_type==4)
			Screen->State[ST_SECRET] = true;
	}
	void SWT_BounceWeapon(lweapon l){
		if(l->ID==LW_BRANG||l->ID==LW_HOOKSHOT)
			l->DeadState = WDS_BOUNCE;
		else if(l->ID==LW_ARROW)
			l->DeadState = WDS_ARROW;
		else if(l->ID==LW_BEAM)
			l->DeadState = WDS_BEAMSHARDS;
	}
}