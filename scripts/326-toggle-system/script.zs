import "std.zh"

//Also used by Linked Secrets script.
//If using both comment this out.
//Be sure to give all switches that use this unique values.
int SecretArray[65536];

//A collision between an lweapon and an ffc.
bool WeaponCollision(lweapon b, ffc a) {
  int ax = a->X +1;
  int bx = b->X + b->HitXOffset+1;
  int ay = a->Y+1;
  int by = b->Y + b->HitYOffset+1;
  if(!b->CollDetection)
	return false;
  return RectCollision(ax, ay, ax+a->EffectWidth-1, ay+a->EffectHeight-1, 
						bx, by, bx+b->HitWidth-1, by+b->HitHeight-1);
}

//A collision between an lweapon and an ffc.
bool WeaponCollision(ffc a, lweapon b) {
  int ax = a->X +1;
  int bx = b->X + b->HitXOffset+1;
  int ay = a->Y+1;
  int by = b->Y + b->HitYOffset+1;
  if(!b->CollDetection)
	return false;
  return RectCollision(ax, ay, ax+a->EffectWidth-1, ay+a->EffectHeight-1, 
						bx, by, bx+b->HitWidth-1, by+b->HitHeight-1);
}

//D0- Sound made when switch is hit.
//D1- Which toggle has been hit.
//D2- Which lweapon activates this toggle
//D3- How to affect toggled combos, in terms of combo ids
//	  Can use both positive and negative values.
//D4- What placed flag to look for
//D5- If more than one toggle of this index is on screen, set the first one to non-zero.
//    Uses values from 1 to 7.

ffc script Toggle_Handler{
	void run(int sfx,int level_index, int lw_id, int secret_offset, int combo_flag, int lone){
		int i;
		lweapon wpn;
		//If nothing is stored in Screen->D zero.
		if(lone){
			if(Screen->D[lone]==0){
				Screen->D[lone]= SecretArray[level_index];
				if(SecretArray[level_index])
					ComboHandler(level_index,combo_flag,secret_offset);
			}
			else{
				if(SecretArray[level_index])
					ComboHandler(level_index,combo_flag,secret_offset);
			}
			
		}
		int Switch_Cooldown;
		while(true){
			if(lw_id!=0){
				for(i= Screen->NumLWeapons();i>0;i--){
					wpn = Screen->LoadLWeapon(i);
					if(wpn->ID==lw_id && WeaponCollision(wpn,this)
						&& Switch_Cooldown<=0){
						if(!SecretArray[level_index])
							SecretArray[level_index]=1;
						else if(SecretArray[level_index])
							SecretArray[level_index]=0;
						Game->PlaySound(sfx);
						ComboHandler(level_index,combo_flag,secret_offset);
						Screen->D[lone]= SecretArray[level_index];
						Switch_Cooldown= 60;
						if(wpn->ID!=LW_BRANG
							&& wpn->ID!=LW_HOOKSHOT)
							Remove(wpn);
						else
							wpn->DeadState = WDS_BOUNCE;
					}
				}
			}
			if(Switch_Cooldown>0)
				Switch_Cooldown--;
			Waitframe();
		}
	}
	void ComboHandler(int index, int flag, int secret_offset){
		for(int i=0;i<=175;i++){
			if(Screen->ComboF[i]==flag){
				if(SecretArray[index])
					Screen->ComboD[i]+=secret_offset;
				else if(!SecretArray[index])
					Screen->ComboD[i]-=secret_offset;
			}
		}
	}
}