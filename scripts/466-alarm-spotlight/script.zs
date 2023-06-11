const int CT_ALARM_SHUTTER = 142;//Combo type to change to next, when alarm triggers.
const int SFX_ALARM_TRIGGER = 0;//Sound to play, when alarm triggers.
const int CSET_ALARM_TRIGGER = 8;//CSet to change FFC, when alarm triggers.
const int SFX_ALARM_DESTROYED = 3;//Sound to play, when alarm trigger is destroyed.
const int SPR_ALARM_DESTROYED = 12;//Sprite to display, when alarm is destroyed.


//An spotlight, which, if steppen in, plays alaem sound, change all CT_ALARM_SHUTTER combos to next in table and drops enemies from ceiling.
//If spawned enemies are defeated, secrets open. Can be Killed with specific lweapon - hit center spot of  FFC to destroy it
//
//Requires ghost.zh
//Place FFC the spotlight should start. Move it with FFC settings and changers.
//D0 - ID of spawned enemies
//D1 - number of spawned enemies
//D2 - >0 - secrets unlocked, when spawned enemies are killed, or alarm trigger is destroyed.
//D3 - Killer Lweapon ID
//D4 - Minimum damage of killer lweapon
ffc script AlarmSpotlight{
	void run(int enemy, int count, int secret, int lwID, int minLWDamage){
		if (Screen->State[ST_SECRET]){
			this->Vx=0;
			this->Vy=0;
			this->Ax=0;
			this->Ay=0;
			this->Data=0;
			Quit();
		}
		int str[] = "AlarmSpotlight";
		int scr = Game->GetFFCScript(str);
		lweapon l;
		while(!RectCollision(Link->X+7, Link->Y+7, Link->X+12, Link->Y+12, this->X, this->Y, this->X+this->EffectWidth-1, this->Y+this->EffectHeight-1)){
			if (this->InitD[7]>0){
				this->Data = FFCS_INVISIBLE_COMBO;
				Quit();
			}
			if (lwID>0){
				for (int i=1;i<=Screen->NumLWeapons();i++){
					l = Screen->LoadLWeapon(i);
					debugValue(1,l->ID);
					if (l->ID!=lwID)continue;
					if (l->Damage<minLWDamage)continue;
					debugValue(2,l->ID);
					if (!RectCollision(l->X+l->HitXOffset, l->Y+l->HitYOffset,l->X+l->HitXOffset+l->HitWidth-1, l->Y+l->HitYOffset+l->HitHeight-1,CenterX(this)-8,CenterY(this)-8,CenterX(this)+8,CenterY(this)+8)) continue;
					Game->PlaySound(SFX_ALARM_DESTROYED);
					// Remove(l);
					l=Screen->CreateLWeapon(LW_SPARKLE);
					l->X=CenterX(this)-8;
					l->Y=CenterY(this)-8;
					l->UseSprite(SPR_ALARM_DESTROYED);
					l->CollDetection=false;
					if (secret>0){
						Game->PlaySound(SFX_SECRET);
						Screen->TriggerSecrets();
						Screen->State[ST_SECRET]=true;
					}					
					this->Vx=0;
					this->Vy=0;
					this->Ax=0;
					this->Ay=0;
					this->Data=0;
					Quit();
				}
			}
			Waitframe();
		}
		for (int i=1;i<=32;i++){
			ffc f = Screen->LoadFFC(i);
			if (f->Script!=this->Script)continue;
			if (f==this) continue;
			f->InitD[7]=1;
		}
		Game->PlaySound(SFX_ALARM_TRIGGER);
		this->Vx=0;
		this->Vy=0;
		this->CSet = CSET_ALARM_TRIGGER;
		Waitframes(30);
		for (int i=0;i<176;i++){
			if (Screen->ComboT[i]==CT_ALARM_SHUTTER)Screen->ComboD[i]++;
		}
		for (int i=1;i<=count*16;i++){
			if ((i%16)==0){
				Game->PlaySound(SFX_FALL);
				npc n= SpawnNPC(enemy);
				n->Z=128;
			}
			Waitframe();
		}
		this->Data = FFCS_INVISIBLE_COMBO;
		if (secret==0)Quit();
		while(EnemiesAlive())Waitframe();
		Game->PlaySound(SFX_SECRET);
		Screen->TriggerSecrets();
		Screen->State[ST_SECRET]=true;
	}
}