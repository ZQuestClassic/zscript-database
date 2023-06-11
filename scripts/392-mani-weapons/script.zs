//What FFC script slot the WaveBeamFFC is stored at.
const int WaveBeamSlot = 105;

//This should be a sprite that is blank. You need to set this up manually so the sprite is over empty tiles in the tile page. 
const int BlankSprite = 150;	

//Crossbow's sprite that it will use when out of ammo.
const int CROSSBOW_BU_SPRITE = 214;

//Use Yeet text on yeet item. Set to 0 to turn off.
const int DO_THE_YEET = 1;

//First of four combos used when Link holds up the yeet item before throwing: (Up, Down, Left, Right)
const int MW_YEET_COMBOS = 2428;

//Wavegun projectile sprite. The sprite itself should be the last of 3 horizontal tiles, which one is used is random.
const int WAVEGUN_PROJ = 211;

//Spin attack SFX for the sword
const int MW_SPINATTACK_SFX = 54;

//Spin attack Charge time
const int MW_SWORD_CHARGE = 120;

item script FFCWeaponLauncher{
	void run(int DMG, int Sprite, int ItemID, int Variable1, int Variable2, int SFX, int Variable4, int FFCScriptSlot){
		
		int PassArray[7];
		PassArray[0] = DMG;
		PassArray[1] = Sprite;
		PassArray[2] = ItemID;
		PassArray[3] = Variable1;
		PassArray[4] = Variable2;
		PassArray[5] = SFX;
		PassArray[6] = Variable4;
		
		RunFFCScript(FFCScriptSlot, PassArray);		// 81?
		
		
	}
}

item script FFCWeaponLauncherNoMulti{
	void run(int DMG, int Sprite, int ItemID, int Variable1, int Variable2, int SFX, int Variable4, int FFCScriptSlot){
		
		ffc Checking;
		bool Duprunning = false;
		
		for(int i = 0; i < 32; i++){
			Checking = Screen->LoadFFC(i);
			if(Checking->Script == FFCScriptSlot) Duprunning = true;
		}
		
		
		if(!Duprunning){
			int PassArray[7];
			PassArray[0] = DMG;
			PassArray[1] = Sprite;
			PassArray[2] = ItemID;
			PassArray[3] = Variable1;
			PassArray[4] = Variable2;
			PassArray[5] = SFX;
			PassArray[6] = Variable4;
			
			RunFFCScript(FFCScriptSlot, PassArray);		// 81?
		}
		
	}
}


int ButtonHeld(int ItemID){
	
	int Output = 0;
	
	if( (GetEquipmentB() == ItemID) && Link->InputB) Output = 2;
	else if( (GetEquipmentA() == ItemID) && Link->InputA) Output = 1;
	
	return Output;
	
}

int ButtonPress(int ItemID){
	
	int Output = 0;
	
	if( (GetEquipmentB() == ItemID) && Link->PressB) Output = 2;
	else if( (GetEquipmentA() == ItemID) && Link->PressA) Output = 1;
	
	return Output;
	
}


ffc script SpearFFC{
	void run(int DMG, int Sprite, int ItemID, int S_DMG, int Variable2, int SFX, int Variable4){
		
		Link->Action = LA_ATTACKING;
		
		Game->PlaySound(SFX);
		
		int InitialX = Link->X;
		int InitialY = Link->Y;
		
		int TrueDir = 0;
		if(Link->InputUp && Link->InputLeft) TrueDir = DIR_LEFTUP;
		else if(Link->InputUp && Link->InputRight) TrueDir = DIR_RIGHTUP;
		else if(Link->InputDown && Link->InputLeft) TrueDir = DIR_LEFTDOWN;
		else if(Link->InputDown && Link->InputRight) TrueDir = DIR_RIGHTDOWN;
		else TrueDir = Link->Dir;
		
		
		lweapon Damage;
		
		lweapon Spear = Screen->CreateLWeapon(LW_SCRIPT3);
		Spear->UseSprite(Sprite);
		Spear->CollDetection = false;
		Spear->Angular = true;
		Spear->Angle = 0;
		Spear->Extend = 4;
		Spear->TileWidth = 2;
		Spear->HitWidth = 0;
		Spear->HitHeight = 0;
		
		Spear->Dir = Link->Dir;
		Spear->X = Link->X;
		Spear->Y = Link->Y;
		
		//Spear sprites: 221, 222, 223
		
		int DrawTile = Spear->OriginalTile;
		int DrawCSet = Spear->CSet;
		
		//Reset to blank tiles
		Spear->UseSprite(BlankSprite);
		
		
		//Angular Directions
		if(TrueDir == DIR_UP) Spear->Angle = PI + PI/2;
		else if(TrueDir == DIR_RIGHT) Spear->Angle = 0;
		else if(TrueDir == DIR_LEFT) Spear->Angle = PI;
		else if(TrueDir == DIR_DOWN) Spear->Angle = PI/2;
		else if(TrueDir == DIR_LEFTUP) Spear->Angle = PI + PI/4;
		else if(TrueDir == DIR_RIGHTUP) Spear->Angle = PI + PI/2 + PI/4;
		else if(TrueDir == DIR_LEFTDOWN) Spear->Angle = PI - PI/4;
		else if(TrueDir == DIR_RIGHTDOWN) Spear->Angle = PI/4;
		
		//	Spear->OriginalTile = Spear->OriginalTile + DIR;
		
		
		for(int i = 0; i < 17; i ++){
			if(i <= 6) Link->Action = LA_NONE;
			if(i <= 6) Link->Action = LA_ATTACKING;
			else if(Link->Action == LA_GOTHURTLAND) Link->Action = LA_NONE;
			
			if(Damage->isValid() == false){
				Damage = Screen->CreateLWeapon(LW_SCRIPT3);
				Damage->Extend = 2;
				Damage->TileWidth = 2;
				Damage->UseSprite(BlankSprite);
				//	Damage->X = Spear->X;
				//	Damage->Y = Spear->Y;
				Damage->Dir = TrueDir;
				Damage->HitWidth = 12;
				Damage->HitHeight = 12;
				Damage->HitXOffset = 0;
				Damage->HitYOffset = 0;
				Damage->Angular = true;
				Damage->Angle = Spear->Angle;
				Damage->Damage = DMG;
				
				//Hardcoded hitbox directions (because it does not move with angular movement)
				if(TrueDir == DIR_UP){
					Damage->HitXOffset = 2;
					Damage->HitYOffset = 2 - 8;
				}
				else if(TrueDir == DIR_RIGHT){
					Damage->HitXOffset = 2 + 8;
					Damage->HitYOffset = 2;
				}
				else if(TrueDir == DIR_LEFT){
					Damage->HitXOffset = 2 - 8;
					Damage->HitYOffset = 2;
				}
				else if(TrueDir == DIR_DOWN){
					Damage->HitXOffset = 2;
					Damage->HitYOffset = 2 + 8;
				}
				else if(TrueDir == DIR_LEFTUP){
					Damage->HitXOffset = 2 - 6;
					Damage->HitYOffset = 2 - 6;
				}
				else if(TrueDir == DIR_RIGHTUP){
					Damage->HitXOffset = 2 + 6;
					Damage->HitYOffset = 2 - 6;
				}
				else if(TrueDir == DIR_LEFTDOWN){
					Damage->HitXOffset = 2 - 6;
					Damage->HitYOffset = 2 + 6;
				}
				else if(TrueDir == DIR_RIGHTDOWN){
					Damage->HitXOffset = 2 + 6;
					Damage->HitYOffset = 2 + 6;
				}
			}
			
			Damage->X = Spear->X;
			Damage->Y = Spear->Y;
			
			if(Spear->X != 0 && Spear->Y != 0) Screen->DrawTile(2, Spear->X - 8, Spear->Y, DrawTile, 2, 1, DrawCSet, -1, -1, Spear->X - 8, Spear->Y, RadtoDeg(Spear->Angle), 0, true, OP_OPAQUE);
			//DrawTile(int layer, int x, int y, int tile, int blockw, int blockh, int cset, int xscale, int yscale, int rx, int ry, int rangle, int flip, bool transparency, int opacity)
			
			if(i < 6) Spear->Step = 350;
			else if(i < 12) Spear->Step = 0;
			else if(i < 16) Spear->Step = -400;
			else if(i < 17){
				
				Damage->DeadState = 0;
				Spear->DeadState = 0;
				Spear->X = - 60;
				Spear->Y = - 60;
				
			}
			
			
			Link->HitDir = 99;
			Waitframe();
		}
		
		

		//If the special move damage is set to 0, there is no special move.
		if(S_DMG > 0){
			
			
			int ChargeUp = 0;
			
			while(((GetEquipmentB() == ItemID) && Link->InputB == true) || ((GetEquipmentA() == ItemID) && Link->InputA == true)){
				
				ChargeUp ++;
				
				//If the special move have any requirements, this is where you put a check for that in order to play the charge complete SFX.
				if(ChargeUp == 180 && Link->MP >= Link->MaxMP){		//this one checks for MP being full.
					Game->PlaySound(35);
				}
				
				Waitframe();
			}
			
			//This part happens when you have charged long enough and meet the requirements.
			if(ChargeUp >= 180 && Link->MP >= Link->MaxMP){
				
				Game->PlaySound(30);
				
				//Charge attack goes here.
				
			}
			else if(ChargeUp >= 180){
				Game->PlaySound(71);
			}
			
			
			
			
		}
		
		this->X = 0;
		this->Y = 0;
		this->Data = 0;
		this->Script = 0;
		
	}
}


ffc script WaveGunFFC{
	void run(int DMG, int Sprite, int ItemID, int Variable1, int REACH, int SFX, int Variable4){
		
		int LW_BELL = LW_SCRIPT3;
		int LW_NOTE = LW_BEAM;
		
		Game->PlaySound(SFX);
		
		Link->Action = LA_ATTACKING;
		lweapon Blade = Screen->CreateLWeapon(LW_BELL);
		Blade->UseSprite(Sprite);
		
		lweapon Handle = Screen->CreateLWeapon(LW_BELL);
		Handle->UseSprite(Sprite);
		
		Blade->Damage = DMG + 1;
		int NoteDMG = DMG;
		
		
		int DIR = Link->Dir;
		
		Blade->CollDetection = false;
		Handle->CollDetection = false;
		
		Blade->Tile = Blade->Tile + DIR;
		Handle->Tile = Blade->Tile + 4;
		
		
		Blade->X = Link->X;
		Blade->Y = Link->Y;
		
		Blade->Dir = DIR;
		
		
		int FFCScriptSlot = 105;
		int PassArray[7];
		PassArray[0] = NoteDMG;
		PassArray[1] = WAVEGUN_PROJ;
		PassArray[2] = ItemID;
		PassArray[3] = LW_NOTE;
		PassArray[4] = LW_NOTE;
		PassArray[5] = LW_NOTE;
		PassArray[6] = LW_NOTE;
		RunFFCScript(FFCScriptSlot, PassArray);		// 81?
		
		for(int i = 0; i < 15; i ++){
			
			if(i <= 6) Link->Action = LA_NONE;
			if(i <= 6) Link->Action = LA_ATTACKING;
			
			if(Blade->Dir == DIR_UP){
				
				Blade->DrawYOffset = 1;
				Handle->DrawYOffset = 1;
				
				if(i == 0) Blade->Y = Link->Y - 8;
				
				if(i == 1)Blade->Y = Link->Y - 16;
				
				
				if(i == 11 && REACH <= 1)Blade->Y = Link->Y - 12;

				if(i == 12 && REACH <= 1)Blade->Y = Link->Y - 8;

				
				if(i == 13)Blade->Y = Link->Y - 4;
				
			}
			else if(Blade->Dir == DIR_DOWN){
				
				Blade->DrawYOffset = -4;
				Handle->DrawYOffset = -4;
				
				if(i == 0) Blade->Y = Link->Y + 8;
				
				if(i == 1)Blade->Y = Link->Y + 16;
				
				
				if(i == 11 && REACH <= 1)Blade->Y = Link->Y + 12;
				
				if(i == 12 && REACH <= 1)Blade->Y = Link->Y + 8;
				
				if(i == 13)Blade->Y = Link->Y + 4;
				
				
			}
			else if(Blade->Dir == DIR_LEFT){
				
				Handle->DrawXOffset = -2;
				Blade->Y = Link->Y + 2;
				
				if(i == 0) Blade->X = Link->X - 8;
				
				if(i == 1) Blade->X = Link->X - 16;
				
				
				if(i == 11 && REACH <= 1) Blade->X = Link->X - 12;
				
				if(i == 12 && REACH <= 1) Blade->X = Link->X - 8;
				
				if(i == 13)Blade->X = Link->X - 4;
				
				
			}
			else if(Blade->Dir == DIR_RIGHT){
				
				Handle->DrawXOffset = 2;
				Blade->Y = Link->Y + 2;
				
				if(i == 0) Blade->X = Link->X + 8;
				
				if(i == 1) Blade->X = Link->X + 16;
				
				if(i == 2 && REACH >= 2) Blade->X = Link->X + 24;
				
				if(i == 3 && REACH >= 3) Blade->X = Link->X + 32;
				
				if(i == 10 && REACH == 2) Blade->X = Link->X + 22;
				else if(i == 10 && REACH == 3) Blade->X = Link->X + 28;
				
				if(i == 11 && REACH <= 1) Blade->X = Link->X + 12;
				else if(i == 11 && REACH == 2) Blade->X = Link->X + 16;
				else if(i == 11 && REACH == 3) Blade->X = Link->X + 20;
				
				if(i == 12 && REACH <= 1) Blade->X = Link->X + 8;
				else if(i == 12 && REACH == 2) Blade->X = Link->X + 10;
				else if(i == 12 && REACH == 3) Blade->X = Link->X + 12;
				
				if(i == 13)Blade->X = Link->X + 4;
				
			}
			
			
			
			Handle->X = Blade->X;
			Handle->Y = Blade->Y;
			if(DIR == DIR_UP) Handle->Y = Blade->Y + 16;
			if(DIR == DIR_UP && Handle->Y > Link->Y + 2) Handle->DrawXOffset = 384;
			if(DIR == DIR_DOWN) Handle->Y = Blade->Y - 16;
			if(DIR == DIR_DOWN && Handle->Y < Link->Y - 2) Handle->DrawXOffset = 384;
			if(DIR == DIR_RIGHT) Handle->X = Blade->X - 16;
			if(DIR == DIR_RIGHT && Handle->X < Link->X - 2) Handle->DrawXOffset = 384;
			if(DIR == DIR_LEFT) Handle->X = Blade->X + 16;
			if(DIR == DIR_LEFT && Handle->X > Link->X + 2) Handle->DrawXOffset = 384;
			
			if(i == 14){
				Blade->Y = -32;
				Blade->X = -32;
				Handle->Y = -32;
				Handle->X = -32;
				
				Blade->DeadState = 0;
				Handle->DeadState = 0;
			}
			
			lweapon Damage = Screen->CreateLWeapon(LW_BELL);
			
			Damage->UseSprite(150);
			
			if(DIR < 2){
				Damage->HitWidth = 12;
				Damage->HitHeight =12;
				Damage->HitXOffset = 2;
				Damage->HitYOffset = 2;
				
				if(REACH == 2){
					Damage->HitHeight = 20;
				}
				
				if(Blade->Dir == DIR_UP) Damage->HitYOffset = 2;
				
			}
			else{
				Damage->HitWidth = 12;
				Damage->HitHeight = 12;
				Damage->HitXOffset = 2;
				Damage->HitYOffset = 2;
				
				if(REACH == 2){
					Damage->HitWidth = 20;
				}
				
				if(Blade->Dir == DIR_LEFT) Damage->HitXOffset = 2;
				
			}
			
			Damage->Damage = Blade->Damage;
			Damage->X = Blade->X;
			Damage->Y = Blade->Y;
			
			Damage->Dir = DIR;
			
			Waitframe();
			
			Handle->DrawXOffset = 0;
			Damage->DeadState = 0;
			
		}
		
		//If the special move damage is set to 0, there is no special move.
		
		this->X = 0;
		this->Y = 0;
		this->Data = 0;
		this->Script = 0;
		
	}
}


ffc script WaveBeamFFC{
	void run(int DMG, int Sprite, int ItemID, int LW_NOTE, int REACH, int Variable3, int Variable4){
		
		lweapon Note = Screen->CreateLWeapon(LW_NOTE);
		Note->UseSprite(Sprite);
		
		if(Rand(10) < 4) Note->Tile = Note->OriginalTile - 1;
		else if(Rand(18) == 0) Note->Tile = Note->OriginalTile - 2;
		
		Note->Dir = Link->Dir;
		Note->Damage = DMG;
		Note->Step = 280;
		Note->HitWidth = 8;
		Note->HitHeight = 8;
		Note->HitXOffset = 4;
		Note->HitYOffset = 4;
		Note->X = Link->X;
		Note->Y = Link->Y;
		Note->Angular = true;
		int AngleMov = -PI/2;
		bool MoveDir = false;
		if(Note->Dir == DIR_UP){
			Note->Angle = PI;
			Note->Y = Note->Y - 16;
		} 
		else if(Note->Dir == DIR_RIGHT){
			Note->Angle = -PI/2;
			Note->X = Note->X + 16;
		} 
		else if(Note->Dir == DIR_DOWN){
			Note->Angle = 0;
			Note->Y = Note->Y + 16;
		} 
		else if(Note->Dir == DIR_LEFT){
			Note->Angle = -PI/2;
			MoveDir = true;
			AngleMov = PI/2;
			
			Note->X = Note->X - 16;
		} 
		
		//if(Note->Dir == DIR_UP) Note->Angle = PI + PI/2;
		//else if(Note->Dir == DIR_RIGHT) Note->Angle = 0;
		//else if(Note->Dir == DIR_DOWN) Note->Angle = PI/2;
		//else if(Note->Dir == DIR_LEFT) Note->Angle = PI;
		
		
		
		while(Note->isValid() == true){
			
			if(MoveDir == true){
				AngleMov = AngleMov + PI/24;
				Note->Angle = Note->Angle + PI/24;
			}
			else{
				AngleMov = AngleMov - PI/24;
				Note->Angle = Note->Angle - PI/24;
			}
			
			if(AngleMov > PI/2) MoveDir = false;
			else if(AngleMov < -PI/2) MoveDir = true;
			
			Waitframe();
		}
		
		this->Data = 0;
		
	}
}


ffc script YeetFFC{
	void run(int DMG, int Sprite, int ItemID, int Variable1, int Variable2, int Variable3, int Variable4){
		if(Link->Z > 0) return;
		
		int YEET[] = "YEET";
		
		int InitialX = Link->X;
		int InitialY = Link->Y;
		
		int LadderDMG = DMG;
		
		//Link->Action = LA_ATTACKING;
		
		lweapon Dummy = Screen->CreateLWeapon(LW_SCRIPT3);
		Dummy->CollDetection = false;
		Dummy->X = Link->X;
		Dummy->Y = Link->Y;
		Dummy->UseSprite(Sprite);
		//Dummy->DeadState = -2;
		
		lweapon Ladder;
		
		int ThrowDelay = 0;
		
		Waitframe();
		
		while(Dummy->isValid() || ThrowDelay < 60){
			
			if(Ladder->isValid() == false){
				Ladder = Screen->CreateLWeapon(LW_SCRIPT3);
				Ladder->Damage = LadderDMG;
				Ladder->Dir = Dummy->Dir;
				Ladder->UseSprite(BlankSprite);
			}
			
			if(ThrowDelay < 25){
				
				Link->Invisible = true;
				Link->CollDetection = false;
				Screen->FastCombo(3, Link->X, Link->Y, MW_YEET_COMBOS + Link->Dir, 6, OP_OPAQUE);
				NoAction();
				Dummy->X = InitialX;
				Dummy->Y = InitialY - 12;
				
				
			}
			else if(ThrowDelay == 25){
				
				Link->Action = LA_NONE;
				Link->Action = LA_ATTACKING;
				Link->Invisible = false;
				Link->CollDetection = true;
				
				Game->PlaySound(Variable3);
				
				Dummy->X = InitialX;
				Dummy->Y = InitialY;
				Dummy->Dir = Link->Dir;
				if(Dummy->Dir == DIR_LEFT) Dummy->Tile = Dummy->OriginalTile + 1;
				else if(Dummy->Dir == DIR_RIGHT) Dummy->Tile = Dummy->OriginalTile + 2;
				Dummy->Step = 500;
				
			}
			else if(ThrowDelay < 90){
				
				if(DO_THE_YEET >= 1){
						Screen->DrawString(5, InitialX + 4 + 1, InitialY - 14 + 1, FONT_Z1, 0x0F, -1, TF_NORMAL, YEET, OP_OPAQUE);
				Screen->DrawString(5, InitialX + 4, InitialY - 14, FONT_Z1, 0x01, -1, TF_NORMAL, YEET, OP_OPAQUE);
				}
				
				
			}
			
			Ladder->X = Dummy->X;
			Ladder->Y = Dummy->Y;
			
			//Kill if off screen
			if(Dummy->X > 288 || Dummy->X < -32 || Dummy->Y > 288 || Dummy->Y < -32){
				Dummy->DeadState = WDS_DEAD;
				//Dummy->X = -999;
				//Dummy->Y = -999;
			}
			
			if(ThrowDelay > 360) Dummy->DeadState = WDS_DEAD;
			
			
			ThrowDelay ++;
			Waitframe();
		}
		
		
		if(Dummy->isValid()) Dummy->DeadState = WDS_DEAD;
		if(Ladder->isValid()) Ladder->DeadState = WDS_DEAD;
		
		
		this->Data = 0;
		
		
	}
}


ffc script SmartBombFFC{
	void run(int DMG, int Sprite, int ItemID, int LW_NOTE, int REACH, int Variable3, int SFX){
		if(Link->Z > 0) return;
		
		Game->PlaySound(SFX);
		
		lweapon Note;
		int ShootAngle = 0;
		
		for(int i = 0; i < 8; i++){
			Note = Screen->CreateLWeapon(LW_SCRIPT3);
			Note->UseSprite(Sprite);
			Note->Dir = Link->Dir;
			Note->Damage = DMG;
			Note->Step = 350;
			Note->HitWidth = 8;
			Note->HitHeight = 8;
			Note->HitXOffset = 4;
			Note->HitYOffset = 4;
			Note->X = Link->X;
			Note->Y = Link->Y;
			Note->Angular = true;
			Note->Angle = ShootAngle;
			Note->Dir = 8;
			
			if(Rand(10) < 4) Note->Tile = Note->OriginalTile - 1;
			else if(Rand(10) == 0) Note->Tile = Note->OriginalTile - 2;
			
			ShootAngle = ShootAngle + PI/4;
		}
		
		for(int i = 0; i < 30; i++){
			
			Link->Action = LA_CASTING;
			
			Screen->Circle(5, Link->X+8, Link->Y + 8, (1 + i*3), 0x01, 1.0, -1, -1, 0, false, OP_OPAQUE);
			Screen->Circle(5, Link->X+8, Link->Y + 8, (3 + i*3), 0x01, 1.0, -1, -1, 0, false, OP_OPAQUE);
			Screen->Circle(5, Link->X+8, Link->Y + 8, (5 + i*3), 0x01, 1.0, -1, -1, 0, false, OP_OPAQUE);
			
			if(i < 15) NoAction();
			else if(i == 15){
				npc HitThis;
				for(int i = 0; i <= Screen->NumNPCs(); i++){
					HitThis = Screen->LoadNPC(i);
					if(HitThis->ID > 9) HitThis->HP = HitThis->HP - DMG;
				}
			}
			
			Waitframe();
		}
		
		if(Link->Action == LA_CASTING) Link->Action = LA_NONE;
		
		
	}
}


ffc script DashAttackFFC{
	void run(int DMG, int Sprite, int ItemID, int Variable1, int Variable2, int Variable3, int Variable4){
		
		int Duration = 999;
		int SFXCount = 0;
		
		lweapon Punch;
		
		int FrameCheck = 0;
		
		
		while(AdvanceDir(Link->Dir, Sprite, true) == 0 && ButtonHeld(ItemID) > 0 && Duration > 0 && Link->MP > Variable2){
			
			Link->Action = LA_NONE;
			Link->Action = LA_ATTACKING;
			
			FrameCheck++;
			if(FrameCheck > 4){
				Link->MP = Link->MP - Variable2;
				FrameCheck = 0;
			} 
			
			if(SFXCount > 3){
				Game->PlaySound(Variable1);
				SFXCount = 0;
			}
			
			if(!Punch->isValid()){
				Punch = Screen->CreateLWeapon(LW_SCRIPT5);
				Punch->Damage = DMG;
				Punch->UseSprite(BlankSprite);
				Punch->Dir = Link->Dir;
			}
			Punch->X = Link->X;
			Punch->Y = Link->Y;
			if(Link->Dir == 0) Punch->Y = Link->Y - 4;
			else if(Link->Dir == 1) Punch->Y = Link->Y + 4;
			else if(Link->Dir == 2) Punch->X = Link->X - 4;
			else if(Link->Dir == 3) Punch->X = Link->X + 4;
			
			
			
			if(Link->X <= 1 || Link->X >= 254 || Link->Y <= 1 || Link->Y >= 174) Duration = 0;
			else{
				AdvanceDir(Link->Dir, Sprite, false);
			}
			if(Link->X <= 1 || Link->X >= 254 || Link->Y <= 1 || Link->Y >= 174) Duration = 0;
			else{
				AdvanceDir(Link->Dir, Sprite, false);
			}
			if(Link->X <= 1 || Link->X >= 254 || Link->Y <= 1 || Link->Y >= 174) Duration = 0;
			else{
				if(SFXCount == 0 || SFXCount == 2)AdvanceDir(Link->Dir, Sprite, false);
			}
			if(Link->X <= 1 || Link->X >= 254 || Link->Y <= 1 || Link->Y >= 174) Duration = 0;
			
			SFXCount ++;
			Duration --;
			Waitframe();
		}
		
		
		Link->Action = LA_NONE;
		Punch->DeadState = 0;
		
	}
	int AdvanceDir(int Direction, int Sprite, bool Cloud){
		
		if(Direction == DIR_UP){
			if(Screen->isSolid(Link->X, Link->Y + 8 - 1) || Screen->isSolid(Link->X + 15, Link->Y + 8- 1)) return 1;
			else Link->Y --;
		}
		else if(Direction == DIR_DOWN){
			if(Screen->isSolid(Link->X, Link->Y + 15 + 1) || Screen->isSolid(Link->X + 15, Link->Y + 15 + 1)) return 1;
			else Link->Y ++;
		}
		else if(Direction == DIR_LEFT){
			if(Screen->isSolid(Link->X -1, Link->Y + 8) || Screen->isSolid(Link->X - 1, Link->Y + 15)) return 1;
			else Link->X --;
		}
		else if(Direction == DIR_RIGHT){
			if(Screen->isSolid(Link->X + 15 + 1, Link->Y + 8) || Screen->isSolid(Link->X + 15 + 1, Link->Y + 15)) return 1;
			else Link->X ++;
		}
		
		if(Cloud){
			lweapon Cloud = Screen->CreateLWeapon(LW_SCRIPT5);
			Cloud->UseSprite(Sprite);
			Cloud->X = Link->X;
			Cloud->Y = Link->Y + 8;
			Cloud->CollDetection = false;
			Cloud->DeadState = 5;
			Cloud->Behind = false;
		}
		
		
		return 0;
	}
}


ffc script CrossBowFFC{
	void run(int DMG, int Sprite, int ItemID, int SpriteArrow, int Variable2, int Variable3, int Variable4){
		
		int PSpeed = 250;
		bool BackUp = false;
		// Arrow Sprites
		// Regular: 10
		// Shock: 241
		// Gold: 11
		// Bolts 147
		//	Chicken: 214
		
		//SpriteArrow = 10;
		if(Game->Counter[CR_ARROWS] > 0){
			if(Link->Item[57]){
				SpriteArrow = 34;
				DMG = DMG * 4;
			} 
			else if(Link->Item[14]){
				SpriteArrow = 11;
				DMG = DMG * 3;
			} 
			else if(Link->Item[13]){
				SpriteArrow = 10;
				DMG = DMG * 2;
			}
			else{
				DMG;
			}
			
			if(Link->Item[149] == true){
				DMG = DMG*2;
				PSpeed = 400;
			} 
		}
		else{
			DMG = DMG / 2;
			BackUp = true;
			SpriteArrow = CROSSBOW_BU_SPRITE;
		}
		
		
		
		
		Link->Action = LA_ATTACKING;
		
		lweapon XBow = Screen->CreateLWeapon(LW_SCRIPT5);
		XBow->CollDetection = false;
		XBow->X = Link->X;
		XBow->Y = Link->Y;
		XBow->UseSprite(Sprite);
		
		if(Link->Dir == DIR_UP){
			XBow->Y = Link->Y - 10;
			XBow->X = Link->X + 1;
			XBow->OriginalTile = XBow->OriginalTile + 0;
			XBow->Tile = XBow->OriginalTile;
		}
		else if(Link->Dir == DIR_DOWN){
			XBow->Y = Link->Y + 11;
			XBow->OriginalTile = XBow->OriginalTile + 1;
			XBow->Tile = XBow->OriginalTile;
		}
		else if(Link->Dir == DIR_LEFT){
			XBow->X = Link->X - 11;
			XBow->OriginalTile = XBow->OriginalTile + 2;
			XBow->Tile = XBow->OriginalTile;
		}
		else if(Link->Dir == DIR_RIGHT){
			XBow->X = Link->X + 11;
			XBow->OriginalTile = XBow->OriginalTile + 3;
			XBow->Tile = XBow->OriginalTile;
		}
		
		LaunchArrow(DMG, SpriteArrow, PSpeed, BackUp, Variable3);
		
		while(Link->Action == LA_ATTACKING){
			
			if(ButtonPress(ItemID) > 0) LaunchArrow(DMG, SpriteArrow, PSpeed, BackUp, Variable3);
			
			Waitframe();
		}
		
		
		XBow->DeadState = 0;
		
	}
	void LaunchArrow(int DMG, int Sprite, int ProjectileStpeed, bool BackUp, int SFX){
		
		if(BackUp);
		else if(Game->Counter[CR_ARROWS] <= 0) return;
		else{
			Game->Counter[CR_ARROWS] = Game->Counter[CR_ARROWS] - 1;
		}
		
		lweapon Arrow = Screen->CreateLWeapon(LW_ARROW);
		Arrow->UseSprite(Sprite);
		Arrow->Damage = DMG;
		Arrow->Dir = Link->Dir;
		Arrow->X = Link->X;
		Arrow->Y = Link->Y;
		Arrow->Step = ProjectileStpeed;
		if(Sprite == CROSSBOW_BU_SPRITE){
			//Cucco
			
			Arrow->Step = ProjectileStpeed -50;
			Game->PlaySound(SFX);
			
			if(Arrow->Dir == 3) Arrow->Flip = 1;
			
		}
		else{
			//Standard Arrows
			if(Arrow->Dir > 1){
				Arrow->OriginalTile = Arrow->OriginalTile + 1;
				Arrow->Tile = Arrow->OriginalTile;
			}
			
			if(Arrow->Dir == 1) Arrow->Flip = 2;
			if(Arrow->Dir == 2) Arrow->Flip = 1;
			
			Game->PlaySound(1);
		}
		
		
		
		
		//Arrow->OriginalTile = Arrow->OriginalTile + Arrow->Dir;
	}
	
}



ffc script SwordFFC{
	void run(int DMG, int Sprite, int ItemID, int S_DMG, int Range, int SFX, int Variable4){
		
		Link->Action = LA_ATTACKING;
		
		Game->PlaySound(SFX);
		
		int BaseImg = 0;
		int BaseCSet = 0;
		int OrgDir = Link->Dir;
		int OrgX = Link->X;
		int OrgY = Link->Y;
		
		lweapon Damage;
		lweapon Sword;
		Sword = Screen->CreateLWeapon(LW_SCRIPT10);
		Sword->UseSprite(Sprite);
		Sword->CollDetection = false;
		Sword->X = Link->X;
		Sword->Y = Link->Y;
		
		
		
		BaseImg = Sword->OriginalTile;
		BaseCSet = Sword->OriginalCSet;
		
		int Sw_Dir = OrgDir;
		
		SwingSword(2, false, Damage, Sword, Sw_Dir, Range, DMG);
		
		Link->Action = LA_NONE;
		
		
		//cleanup 
		if(Sword->isValid()){
			Sword->DeadState = 0;
			Sword->X = -70000;
			Sword->Y = -70000;
		}
		if(Damage->isValid()){
			Damage->DeadState = 0;
			Damage->X = -70000;
			Damage->Y = -70000;
		}
		
		
		//If the special move damage is set to 0, there is no special move.
		if(S_DMG > 0){
			//This function uses S_DMG for MP cost here, rather than damage value, actually not used at all, lol, needs to be not zero
			
			//Brings the FFC with you:
			//this->Flags[FFCF_CARRYOVER] = true;	//actually waaaaay too cursed to use.
			
			int ChargeUp = 0;
			
			while(((GetEquipmentB() == ItemID) && Link->InputB == true) || ((GetEquipmentA() == ItemID) && Link->InputA == true)){
				
				ChargeUp ++;
				
				//If the special move have any requirements, this is where you put a check for that in order to play the charge complete SFX.
				if(ChargeUp == MW_SWORD_CHARGE){	
					Game->PlaySound(35);
				}
				
				Waitframe();
			}
			
			//this->Flags[FFCF_CARRYOVER] = false;
			
			//This part happens when you have charged long enough and meet the requirements.
			if(ChargeUp >= MW_SWORD_CHARGE){
				
				Game->PlaySound(SFX);
				Link->Action = LA_ATTACKING;
				
				Sword = Screen->CreateLWeapon(LW_SCRIPT10);
				Sword->UseSprite(Sprite);
				Sword->CollDetection = false;
				Sword->X = Link->X;
				Sword->Y = Link->Y;
				
				
				SwingSword(5, true, Damage, Sword, Link->Dir, Range, DMG*2);
			}
			
			Link->Action = LA_NONE;
			
			
		}
		
		//cleanup 
		if(Sword->isValid()){
			Sword->DeadState = 0;
			Sword->X = -70000;
			Sword->Y = -70000;
		}
		if(Damage->isValid()){
			Damage->DeadState = 0;
			Damage->X = -70000;
			Damage->Y = -70000;
		}
		
		this->Data = 0;
		this->X = 0;
		this->Y = 0;
		
		
	}
	
	void SwingSword(int MakeSwings, bool TurnLink, lweapon Damage, lweapon Sword, int Sw_Dir, int Range, int DMG){
		
		int Swings = 0;
		
		float SwingAngle = 0;
		int SwindDistance = Range;
		int SwingTime = 8;
		
		int Swordtile = Sword->Tile;
		int SwordCSet = Sword->CSet;
		Sword->UseSprite(BlankSprite);
		
		if(MakeSwings > 2) SwingTime = 6;
		
		while(Swings < MakeSwings){
			
			Link->Action = LA_NONE;
			Link->Action = LA_ATTACKING;
			
			
			
			
			

			for(int i = 0; i < SwingTime; i++){
				
				if(i < 14){
					Link->Action = LA_NONE;
					Link->Action = LA_ATTACKING;
				}
				
				if(Damage->isValid() == false){
					Damage = Screen->CreateLWeapon(LW_SCRIPT10);
					Damage->UseSprite(BlankSprite);
					Damage->HitWidth = 16;
					Damage->HitHeight = 16;
					Damage->Damage = DMG;
					
				}
				
				if(Sw_Dir == DIR_UP){
					SwingAngle = 0; //if(i < SwingTime/2) Damage->Dir = DIR_RIGHT;
				} 
				else if(Sw_Dir == DIR_RIGHT){
					SwingAngle = 90; //if(i < SwingTime/2) Damage->Dir = DIR_DOWN;
				} 
				else if(Sw_Dir == DIR_DOWN){
					SwingAngle = 180; //if(i < SwingTime/2) Damage->Dir = DIR_LEFT;
				} 
				else if(Sw_Dir == DIR_LEFT){
					SwingAngle = 270; //if(i < SwingTime/2) Damage->Dir = DIR_UP;
				} 
				if(TurnLink) Link->Dir = Sw_Dir;
				Damage->Dir = Link->Dir;
				SwingAngle = SwingAngle - (i*(90/SwingTime));
				
				Sword->X = Link->X + VectorX(SwindDistance, SwingAngle);
				Sword->Y = Link->Y + VectorY(SwindDistance, SwingAngle);
				Damage->X = Link->X + VectorX(SwindDistance + 8, SwingAngle);
				Damage->Y = Link->Y + VectorY(SwindDistance + 8, SwingAngle);
				//Screen->PutPixel(6, Sword->X, Sword->Y, 0x44, 0, 0, 0, OP_OPAQUE);
				
				if(Sword->X != 0 && Sword->Y != 0) Screen->DrawTile(2, Sword->X - 8, Sword->Y, Swordtile, 2, 1, SwordCSet, -1, -1, Sword->X - 8, Sword->Y, SwingAngle, 0, true, OP_OPAQUE);
				
				Waitframe();
			}
			
			Swings++;
			if(Sw_Dir == DIR_UP) Sw_Dir = DIR_LEFT;
			else if(Sw_Dir == DIR_RIGHT) Sw_Dir = DIR_UP;
			else if(Sw_Dir == DIR_DOWN) Sw_Dir = DIR_RIGHT;
			else if(Sw_Dir == DIR_LEFT) Sw_Dir = DIR_DOWN;
		

			if(Damage->isValid()){
				Damage->DeadState = 0;
				//Damage->X = -20000;
				//Damage->Y = -20000;
			}
		}
	}
	
}