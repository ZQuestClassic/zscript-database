import "std.zh"
import "LinkMovement.zh"

namespace DarkSoulsStatus{

	void UpdateDeathPenalty(){
		//If you're using my death penalty script, uncomment this line
		// DeathPenalty[_DP_HASDIED] = 1;
	}
	
	//Status bar drawn position
	const int STATUSBARS_ON_LINK = 0; //0 - Top of screen, 1 - Above Link
	//Status warning drawn positio
	const int STATUSWARNINGS_ON_LINK = 1; //0 - Center Screen, 1 - Above Link, 2 - Invisible
	
	const int FONT_STATUSWARNINGS = FONT_SHERWOOD;

	//Misc colors
	const int C_STATUSBAR_BG = 0x0F; //Meter background
	const int C_STATUSBAR_FG = 0x01; //Meter outline
	const int C_STATUSBAR_TEXTSHADOW = 0x0F; //Text outline and other black things

	//Stats for modifying status. Damage values are percentage based if negative. Decay is a percentage lost every frame.

	//Stats for poison status
	const int POISON_TILE = 460;
	const int POISON_DAMAGE = 1;
	const int POISON_TICKFREQ = 60;
	const int POISON_DURATION = 2400;
	const int POISON_DECAY = 0.05;
	const int POISON_COLOR1 = 0x51;
	const int POISON_COLOR2 = 0x52;

	//Stats for toxic status
	const int TOXIC_TILE = 461;
	const int TOXIC_DAMAGE = -5;
	const int TOXIC_TICKFREQ = 60;
	const int TOXIC_DURATION = 1200;
	const int TOXIC_DECAY = 0.01;
	const int TOXIC_COLOR1 = 0xA1;
	const int TOXIC_COLOR2 = 0xA2;

	//Stats for bleed status
	const int BLEED_TILE = 462;
	const int BLEED_DAMAGE = -40;
	const int BLEED_DECAY = 0.01;
	const int BLEED_COLOR1 = 0x85;
	const int BLEED_COLOR2 = 0x81;

	//Stats for frost status
	const int FROST_TILE = 463;
	const int FROST_DAMAGE = -10;
	const int FROST_HPPENALTY = 1.5; //Multiplier for damage while inflicted
	const int FROST_MPPENALTY = 1.5; //Multiplier for MP used while inflicted
	const int FROST_DURATION = 1200;
	const int FROST_DECAY = 0.05;
	const int FROST_COLOR1 = 0x72;
	const int FROST_COLOR2 = 0x73;

	//Stats for curse status
	const int CURSE_TILE = 464;
	const int CURSE_HPREDUCE = 0.5; //Percentage of HP reduced while cursed
	const int CURSE_KILLS = 1; //Whether or not curse is instant death when inflicted
	const int CURSE_DURATION = -1; //Duration of curse, -1 for infinite
	const int CURSE_DECAY = 0.05;
	const int CURSE_COLOR1 = 0xB1;
	const int CURSE_COLOR2 = 0xB2;
	
	//Sounds when inflicted with each status
	const int SFX_POISON = 67;
	const int SFX_TOXIC = 68;
	const int SFX_BLEED = 69;
	const int SFX_FROST = 70;
	const int SFX_CURSE = 71;
	
	//Sounds for damage ticks from statuses
	const int SFX_POISON_TICK = 67;
	const int SFX_TOXIC_TICK = 68;
	
	int DSStatus[512];

	//INTERNAL CONSTANTS, DON'T MESS WITH THESE
	enum StatusType {POISON, TOXIC, BLEED, FROST, CURSE, NUMSTATUS};

	const int _ANIM = 0;
	const int _CURSEFRAME = 1;
	const int _SWAMPCOUNTER = 2;
	const int _STATUSDATASTART = 16;

	enum StatusData {BUILDUP, TIME, MAXTIME, DECAYDELAY, NUMSTATUSDATA};
	//END OF INTERNAL CONSTANTS
	
	//Functions for accessing array indices
	int GetData(int status, int which){
		return DSStatus[_STATUSDATASTART+NUMSTATUSDATA*status+which];
	}
	void SetData(int status, int which, int val){
		DSStatus[_STATUSDATASTART+NUMSTATUSDATA*status+which] = val;
	}
	void AddData(int status, int which, int val){
		DSStatus[_STATUSDATASTART+NUMSTATUSDATA*status+which] += val;
	}
	void ClampData(int status, int which, int min, int max){
		DSStatus[_STATUSDATASTART+NUMSTATUSDATA*status+which] = Clamp(DSStatus[_STATUSDATASTART+NUMSTATUSDATA*status+which], min, max);
	}
	
	//Functions for getting status settings
	float StatusTile(int status){
		switch(status){
			case POISON:
				return POISON_TILE;
			case TOXIC:
				return TOXIC_TILE;
			case BLEED:
				return BLEED_TILE;
			case FROST:
				return FROST_TILE;
			case CURSE:
				return CURSE_TILE;
		}
	}
	float StatusDuration(int status){
		switch(status){
			case POISON:
				return POISON_DURATION;
			case TOXIC:
				return TOXIC_DURATION;
			case BLEED:
				return 0;
			case FROST:
				return FROST_DURATION;
			case CURSE:
				return CURSE_DURATION;
		}
	}
	float StatusDecay(int status){
		switch(status){
			case POISON:
				return POISON_DECAY;
			case TOXIC:
				return TOXIC_DECAY;
			case BLEED:
				return BLEED_DECAY;
			case FROST:
				return FROST_DECAY;
			case CURSE:
				return CURSE_DECAY;
		}
	}
	float StatusColor1(int status){
		switch(status){
			case POISON:
				return POISON_COLOR1;
			case TOXIC:
				return TOXIC_COLOR1;
			case BLEED:
				return BLEED_COLOR1;
			case FROST:
				return FROST_COLOR1;
			case CURSE:
				return CURSE_COLOR1;
		}
	}
	float StatusColor2(int status){
		switch(status){
			case POISON:
				return POISON_COLOR2;
			case TOXIC:
				return TOXIC_COLOR2;
			case BLEED:
				return BLEED_COLOR2;
			case FROST:
				return FROST_COLOR2;
			case CURSE:
				return CURSE_COLOR2;
		}
	}
	
	//Returns true if the status bars can be drawn
	bool CanDrawStatus(){
		switch(Link->Action){
			case LA_SCROLLING:
			case LA_HOLD1LAND:
			case LA_HOLD2LAND:
			case LA_HOLD1WATER:
			case LA_HOLD2WATER:
				return false;
		}
		return true;
	}
	
	//Draws a status meter to the screen
	void DrawStatusMeter(int x, int y, int til, int c1, int c2, int percent, bool flash){
		Screen->Rectangle(6, x+8, y+2, x+8+17, y+6, C_STATUSBAR_BG, 1, 0, 0, 0, true, 128);
		Screen->Rectangle(6, x+8, y+2, x+8+17, y+6, C_STATUSBAR_FG, 1, 0, 0, 0, false, 128);
		int c = c1;
		if(flash&&DSStatus[_ANIM]%4<2)
			c = c2;
		Screen->Rectangle(6, x+9, y+3, x+Lerp(8+1, 8+16, percent), y+5, c, 1, 0, 0, 0, true, 128);
		Screen->FastTile(6, x, y, til, 0, 128);
	}		

	//These items will reduce the effect of status buildup. If 0, no item has that effect
	const int I_RING_POISONBITE = 0;
	const int MULTIPLIER_POISONBITE = 0.5;
	
	const int I_RING_TOXINBITE = 0;
	const int MULTIPLIER_TOXINBITE = 0.5;
	
	const int I_RING_BLOODBITE = 0;
	const int MULTIPLIER_BLOODBITE = 0.5;
	
	const int I_RING_FROSTBITE = 0;
	const int MULTIPLIER_FROSTBITE = 0.5;
	
	const int I_RING_CURSEBITE = 0;
	const int MULTIPLIER_CURSEBITE = 0.5;

	//Fills a status by a certain amount
	void FillStatus(int status, int amount, int maxTime){
		switch(status){
			case POISON:
				if(I_RING_POISONBITE){
					if(Link->Item[I_RING_POISONBITE])
						amount = Ceiling(amount*MULTIPLIER_POISONBITE);
				}
				break;
			case TOXIC:
				if(I_RING_TOXINBITE){
					if(Link->Item[I_RING_TOXINBITE])
						amount = Ceiling(amount*MULTIPLIER_TOXINBITE);
				}
				break;
			case BLEED:
				if(I_RING_BLOODBITE){
					if(Link->Item[I_RING_BLOODBITE])
						amount = Ceiling(amount*MULTIPLIER_BLOODBITE);
				}
				break;
			case FROST:
				if(I_RING_FROSTBITE){
					if(Link->Item[I_RING_FROSTBITE])
						amount = Ceiling(amount*MULTIPLIER_FROSTBITE);
				}
				break;
			case CURSE:
				if(I_RING_CURSEBITE){
					if(Link->Item[I_RING_CURSEBITE])
						amount = Ceiling(amount*MULTIPLIER_CURSEBITE);
				}
				break;
		}
		AddData(status, BUILDUP, amount);
		SetData(status, MAXTIME, maxTime);
		SetData(status, DECAYDELAY, 48);
		ClampData(status, BUILDUP, 0, 100);
	}
	
	//Damages Link with status
	void DamageLinkStatus(int damage){
		if(damage<0){
			damage = Ceiling(Link->MaxHP*(Abs(damage)/100));
		}
		Link->HP -= damage;
	}

	void Init(){
		DSStatus[_CURSEFRAME] = 0;
		for(int i=0; i<NUMSTATUS; ++i){
			SetData(i, BUILDUP, 0);
			if(i!=CURSE)
				SetData(i, TIME, 0);
			SetData(i, MAXTIME, 0);
			SetData(i, DECAYDELAY, 0);
		}
		if(GetData(CURSE, TIME)!=0){
			genericdata gd = Game->LoadGenericData(Game->GetGenericScript("CurseEffect"));
			gd->Running = true;
		}
	}
	
	void Update(){
		DSStatus[_ANIM] = (DSStatus[_ANIM]+1)%360;
		int numMeters;
		for(int i=0; i<NUMSTATUS; ++i){
			int drawMeterFill;
			bool flashMeter;
			//Status is active
			if(GetData(i, TIME)!=0){
				switch(i){
					case POISON:
						break;
				}
				
				if(GetData(i, TIME)>0){
					drawMeterFill = Clamp(GetData(i, TIME)/GetData(i, MAXTIME), 0, 1);
					flashMeter = true;
					AddData(i, TIME, -1);
				}
				else if(GetData(i, TIME)==-1){
					drawMeterFill = 1;
				}
				SetData(i, BUILDUP, 0);
			}
			//Status is being filled
			else if(GetData(i, BUILDUP)){
				//Status is fully filled
				if(GetData(i, BUILDUP)>=100){
					SetData(i, BUILDUP, 0);
					SetData(i, TIME, GetData(i, MAXTIME));
					switch(i){
						case POISON:
							genericdata gd = Game->LoadGenericData(Game->GetGenericScript("PoisonEffect"));
							gd->Running = true;
							break;
						case TOXIC:
							genericdata gd = Game->LoadGenericData(Game->GetGenericScript("ToxicEffect"));
							gd->Running = true;
							break;
						case BLEED:
							genericdata gd = Game->LoadGenericData(Game->GetGenericScript("BleedEffect"));
							gd->Running = true;
							break;
						case FROST:
							genericdata gd = Game->LoadGenericData(Game->GetGenericScript("FrostEffect"));
							gd->Running = true;
							break;
						case CURSE:
							DSStatus[_CURSEFRAME] = 1;
							genericdata gd = Game->LoadGenericData(Game->GetGenericScript("CurseEffect"));
							gd->Running = true;
							break;
					}
				}
				//Status is filling/decaying
				else{
					if(GetData(i, DECAYDELAY)>0)
						AddData(i, DECAYDELAY, -1);
					else{
						AddData(i, BUILDUP, -StatusDecay(i));
						ClampData(i, BUILDUP, 0, 100);
					}
					
					drawMeterFill = Clamp(GetData(i, BUILDUP)/100, 0, 1);
				}
			}
		
			if(drawMeterFill>0){
				if(CanDrawStatus()){
					if(STATUSBARS_ON_LINK)
						DrawStatusMeter(Link->X-6, Link->Y-10-numMeters*10, StatusTile(i), StatusColor1(i), StatusColor2(i), drawMeterFill, flashMeter);
					else
						DrawStatusMeter(8+32*numMeters, 8, StatusTile(i), StatusColor1(i), StatusColor2(i), drawMeterFill, flashMeter);
				}
				++numMeters;
			}
		}
	}
	
	void DrawEffectLabel(int statusType, int str, int labelFrames, int drawTime){
		if(STATUSWARNINGS_ON_LINK==2)
			return;
		int x = 128;
		int y = 88;
		if(STATUSWARNINGS_ON_LINK){
			x = Link->X;
			y = Link->Y-8;
			int stringW = Text->StringWidth(str, FONT_STATUSWARNINGS);
			if(x-stringW/2<8)
				x += Abs((x-stringW/2)-8);
			if(x+stringW/2>248)
				x -= Abs((x+stringW/2)-248);
		}
		if(labelFrames[0]<drawTime){
			int op = 128;
			if(labelFrames[0]>=drawTime-8)
				op = 64;
			int c = StatusColor1(statusType);
			if(labelFrames[0]%4<2)
				c = StatusColor2(statusType);
			Screen->DrawString(6, x, y-labelFrames[0]/2-Text->FontHeight(FONT_STATUSWARNINGS)/2, FONT_STATUSWARNINGS, c, -1, TF_CENTERED, str, op, SHD_OUTLINED8, C_STATUSBAR_TEXTSHADOW);
			++labelFrames[0];
		}
	}
	
	generic script PoisonEffect{
		void run(){
			this->ExitState[GENSCR_ST_RELOAD] = true;
			this->ExitState[GENSCR_ST_CONTINUE] = true;
			int labelFrames[1];
			int damageTimer;
			if(SFX_POISON)
				Game->PlaySound(SFX_POISON);
			while(GetData(POISON, TIME)>0){
				WaitTo(SCR_TIMING_POST_GLOBAL_ACTIVE, false);
				DrawEffectLabel(POISON, "POISONED", labelFrames, 64);
				++damageTimer;
				if(damageTimer>=POISON_TICKFREQ){
					if(SFX_POISON_TICK)
						Game->PlaySound(SFX_POISON_TICK);
					DamageLinkStatus(POISON_DAMAGE);
					damageTimer = 0;
				}
				Waitframe();
			}
		}
	}
	
	generic script ToxicEffect{
		void run(){
			this->ExitState[GENSCR_ST_RELOAD] = true;
			this->ExitState[GENSCR_ST_CONTINUE] = true;
			int labelFrames[1];
			int damageTimer;
			if(SFX_TOXIC)
				Game->PlaySound(SFX_TOXIC);
			while(GetData(TOXIC, TIME)>0){
				WaitTo(SCR_TIMING_POST_GLOBAL_ACTIVE, false);
				DrawEffectLabel(TOXIC, "TOXIC", labelFrames, 64);
				++damageTimer;
				if(damageTimer>=TOXIC_TICKFREQ){
					if(SFX_TOXIC_TICK)
						Game->PlaySound(SFX_TOXIC_TICK);
					DamageLinkStatus(TOXIC_DAMAGE);
					damageTimer = 0;
				}
				Waitframe();
			}
		}
	}
	
	const int SPR_BLEEDPARTICLES = 102; //2x2 sprite animation used for bleed
	
	generic script BleedEffect{
		void run(){
			this->ExitState[GENSCR_ST_RELOAD] = true;
			this->ExitState[GENSCR_ST_CONTINUE] = true;
			int labelFrames[1];
			int damageTimer;
			if(SFX_BLEED)
				Game->PlaySound(SFX_BLEED);
			if(SPR_BLEEDPARTICLES){
				lweapon bleed = CreateLWeaponAt(LW_SPARKLE, Link->X, Link->Y);
				bleed->DrawXOffset = -8;
				bleed->DrawYOffset = -8;
				bleed->Extend = 3;
				bleed->TileWidth = 2;
				bleed->TileHeight = 2;
				bleed->UseSprite(SPR_BLEEDPARTICLES);
			}
			int totalDamage = BLEED_DAMAGE;
			if(BLEED_DAMAGE<0)
				totalDamage = Ceiling(Link->MaxHP*(Abs(BLEED_DAMAGE)/100));
			int remainingDamage = totalDamage;
			for(int i=0; i<64; ++i){
				WaitTo(SCR_TIMING_POST_GLOBAL_ACTIVE, false);
				DrawEffectLabel(BLEED, "BLOOD LOSS", labelFrames, 64);
				
				int tickDamage = Clamp(Ceiling(totalDamage/32), 0, remainingDamage);
				Link->HP -= tickDamage;
				remainingDamage -= tickDamage;
				
				Waitframe();
			}
		}
	}
	
	generic script FrostEffect{
		void run(){
			this->ExitState[GENSCR_ST_RELOAD] = true;
			this->ExitState[GENSCR_ST_CONTINUE] = true;
			int labelFrames[1];
			int damageTimer;
			if(SFX_FROST)
				Game->PlaySound(SFX_FROST);
			
			int totalDamage = FROST_DAMAGE;
			if(FROST_DAMAGE<0)
				totalDamage = Ceiling(Link->MaxHP*(Abs(FROST_DAMAGE)/100));
			int remainingDamage = totalDamage;
			
			int lastLinkHP = Link->HP;
			int lastLinkMP = Link->MP;
			while(GetData(FROST, TIME)>0){
				WaitTo(SCR_TIMING_POST_GLOBAL_ACTIVE, false);
				DrawEffectLabel(FROST, "FROSTBITTEN", labelFrames, 64);
				
				//Deal initial ticks of damage
				if(remainingDamage>0){
					int tickDamage = Clamp(Ceiling(totalDamage/32), 0, remainingDamage);
					Link->HP -= tickDamage;
					remainingDamage -= tickDamage;
				}
				//Extra damage when Link gets hit
				else{
					if(Link->HP<lastLinkHP){
						int damage = lastLinkHP-Link->HP;
						Link->HP -= Ceiling(damage*(FROST_HPPENALTY-1));
					}
				}
				
				//Increase MP costs
				if(Link->MP<lastLinkMP){
					int cost = lastLinkMP-Link->MP;
					Link->MP = Max(Link->MP-Ceiling(cost*(FROST_MPPENALTY-1)), 0);
				}
				
				lastLinkHP = Link->HP;
				lastLinkMP = Link->MP;
				
				Waitframe();
			}
		}
	}
	
	generic script CurseEffect{
		void run(){
			this->ExitState[GENSCR_ST_RELOAD] = true;
			this->ExitState[GENSCR_ST_CONTINUE] = true;
			int labelFrames[1];
			int damageTimer;
			if(DSStatus[_CURSEFRAME]){
				if(SFX_CURSE)
					Game->PlaySound(SFX_CURSE);
				if(CURSE_KILLS){
					genericdata gd = Game->LoadGenericData(Game->GetGenericScript("CurseDeathAnim"));
					Link->Invisible = true;
					Waitframe();
					gd->RunFrozen();
				}
			}
			DSStatus[_CURSEFRAME] = 0;
			
			while(GetData(CURSE, TIME)!=0){
				if(!CURSE_KILLS)
					DrawEffectLabel(CURSE, "CURSED", labelFrames, 64);
				
				if(Link->HP>Ceiling(Link->MaxHP*CURSE_HPREDUCE))
					--Link->HP;
				
				Waitframe();
			}
		}
	}
	
	//Data for the tile animation that plays when Link is cursed
	const int CURSE_ANIM_TILE = 440;
	const int CURSE_ANIM_W = 1;
	const int CURSE_ANIM_H = 1;
	const int CURSE_ANIM_FRAMES = 20;
	const int CURSE_ANIM_ASPEED = 16;
	
	generic script CurseDeathAnim{
		void run(){
			Game->PlayMIDI(0);
			DSStatus[_CURSEFRAME] = 0;
			int labelFrames[1];
			int animTime = CURSE_ANIM_FRAMES*CURSE_ANIM_ASPEED;
			int fadeSpeed = animTime/4;
			if(animTime<16)
				fadeSpeed = 0;
			int xOff = (CURSE_ANIM_W-1)*-8;
			int yOff = (CURSE_ANIM_H-1)*-8;
			for(int i=0; i<animTime; ++i){
				if(fadeSpeed){
					if(i>fadeSpeed)
						Screen->Rectangle(6, 0, -56, 255, 175, C_STATUSBAR_TEXTSHADOW, 1, 0, 0, 0, true, 128);
					if(i>fadeSpeed/3*2)
						Screen->Rectangle(6, 0, -56, 255, 175, C_STATUSBAR_TEXTSHADOW, 1, 0, 0, 0, true, 64);
					if(i>fadeSpeed/3)
						Screen->Rectangle(6, 0, -56, 255, 175, C_STATUSBAR_TEXTSHADOW, 1, 0, 0, 0, true, 64);
				}
				else{
					Screen->Rectangle(6, 0, -56, 255, 175, C_STATUSBAR_TEXTSHADOW, 1, 0, 0, 0, true, 128);
				}
				Screen->DrawTile(6, Link->X+Link->DrawXOffset+xOff, Link->Y+Link->DrawYOffset+yOff, CURSE_ANIM_TILE+Floor(i/CURSE_ANIM_ASPEED), CURSE_ANIM_W, CURSE_ANIM_H, 6, -1, -1, 0, 0, 0, 0, true, 128);
				if(fadeSpeed){
					if(i>animTime-fadeSpeed/3)
						Screen->Rectangle(6, 0, -56, 255, 175, C_STATUSBAR_TEXTSHADOW, 1, 0, 0, 0, true, 128);
					if(i>animTime-fadeSpeed/3*2)
						Screen->Rectangle(6, 0, -56, 255, 175, C_STATUSBAR_TEXTSHADOW, 1, 0, 0, 0, true, 64);
					if(i>animTime-fadeSpeed)
						Screen->Rectangle(6, 0, -56, 255, 175, C_STATUSBAR_TEXTSHADOW, 1, 0, 0, 0, true, 64);
				}
				Waitframe();
			}
			if(STATUSWARNINGS_ON_LINK<2){
				for(int i=0; i<80; ++i){
					Screen->Rectangle(6, 0, -56, 255, 175, C_STATUSBAR_TEXTSHADOW, 1, 0, 0, 0, true, 128);
					DrawEffectLabel(CURSE, "CURSED", labelFrames, 64);
					Waitframe();
				}
			}
			UpdateDeathPenalty();
			Game->Continue();
		}
	}
	
	//NPC script to be put on enemies to apply status
	npc script EnemyStatusContact{
		void run(int statusType, int amount, int duration){
			if(duration==0)
				duration = StatusDuration(statusType);
			while(true){
				untyped hitby = Link->HitBy[0]; //HIT_BY_NPC
				if(hitby>0){
					npc hitNPC = Screen->LoadNPC(hitby);
					if(hitNPC->isValid()){
						if(hitNPC==this){
							FillStatus(statusType, amount, duration);
						}
					}
				}
				Waitframe();
			}
		}
	}
	
	//Weapon script to be put on enemies to apply status
	eweapon script EWeaponStatusContact{
		void run(int statusType, int amount, int duration){
			if(duration==0)
				duration = StatusDuration(statusType);
			while(true){
				untyped hitby = Link->HitBy[1]; //HIT_BY_EWEAPON
				if(hitby>0){
					eweapon hitEW = Screen->LoadEWeapon(hitby);
					if(hitEW->isValid()){
						if(hitEW==this){
							FillStatus(statusType, amount, duration);
						}
					}
				}
				Waitframe();
			}
		}
	}


	const int SFX_CURSE_CURE = 25;
	
	//Simple item script to remove curse when used
	itemdata script CurseCure{
		void run(){
			if(GetData(CURSE, TIME)!=0){
				Game->PlaySound(25);
				SetData(CURSE, TIME, 0);
				Link->Item[this->ID] = false;
			}
		}
	}
	
	//This item makes it so swamp combos don't slow you down
	const int I_RUSTEDIRONRING = 0;
	
	//Poison swamps that inflict status. Miyazaki would be proud
	combodata script PoisonSwamp{
		void run(){
			int statusType = this->Attribytes[0];
			int amount = this->Attribytes[1];
			int freq = this->Attribytes[2];
			int onlyWalk = this->Attribytes[3];
			int walkSFX = this->Attribytes[4];
			int duration = this->Attrishorts[0];
			int stepMod = this->Attributes[0];
			int walkCMB = this->Attributes[1];
			if(duration==0)
				duration = StatusDuration(statusType);
			while(true){
				int pos = ComboAt(Link->X+8, Link->Y+12);
				if(pos==this->Pos){
					if(walkCMB){
						Screen->FastCombo(4, Link->X+Link->DrawXOffset, Link->Y+Link->DrawYOffset+2, walkCMB, Screen->ComboC[this->Pos], 128);
					}
					if(!(I_RUSTEDIRONRING&&Link->Item[I_RUSTEDIRONRING]))
						LinkMovement_AddLinkSpeedBoost(stepMod);
					if(onlyWalk==0||Link->Action==LA_WALKING)
						++DSStatus[_SWAMPCOUNTER];
					if(DSStatus[_SWAMPCOUNTER]>=freq){
						if(statusType>=0)
							FillStatus(statusType, amount, duration);
						if(walkSFX&&Link->Action==LA_WALKING)
							Game->PlaySound(walkSFX);
						DSStatus[_SWAMPCOUNTER] = 0;
					}
				}
				Waitframe();
			}
		}
	}
}

global script Active{
	void run(){
		DarkSoulsStatus::Init();
		LinkMovement_Init();
		while(true){
			DarkSoulsStatus::Update();
			LinkMovement_Update1();
			
			Waitdraw();
			
			LinkMovement_Update2();
			
			Waitframe();
		}
	}
}