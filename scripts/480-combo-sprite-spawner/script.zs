//Attribytes[0] - Visual Sprite
//Attribytes[1] - Sprite Width
//Attribytes[2] - Sprite Height
//Attribytes[3] - SFX
//Attribytes[4] - Frames before the effect spawns

//Attrishorts[0] - Secondary Effect
//					0 - None
//					1 - LWeapon
//					2 - EWeapon
//					3 - Enemy
//Attrishorts[1] - Effect ID
//Attrishorts[2] - Effect Sprite
//Attrishorts[3] - Effect Damage
//Attrishorts[4] - Effect Step
//Attrishorts[5] - Effect Delay
//Attrishorts[6] - Effect Angle

combodata script ComboSprite{
	void run(){
		int visualSprite = this->Attribytes[0];
		int spriteW = this->Attribytes[1];
		int spriteH = this->Attribytes[2];
		int spriteSFX = this->Attribytes[3];
		int staggerEffect = this->Attribytes[4];
		if(spriteW==0) spriteW = 1;
		if(spriteH==0) spriteH = 1;
		
		int effectType = this->Attrishorts[0];
		int effectID = this->Attrishorts[1];
		int effectSprite = this->Attrishorts[2];
		int effectDamage = this->Attrishorts[3];
		int effectStep = this->Attrishorts[4];
		int effectDelay = this->Attrishorts[5];
		int effectAngle = this->Attrishorts[6];
		
		if(visualSprite){
			lweapon effect = CreateLWeaponAt(LW_SPARKLE, this->X, this->Y);
			effect->DrawXOffset = -(spriteW-1)*8;
			effect->DrawYOffset = -(spriteH-1)*8;
			effect->Extend = 3;
			effect->TileWidth = spriteW;
			effect->TileHeight = spriteH;
			effect->UseSprite(visualSprite);
			effect->CollDetection = false;
		}
		if(spriteSFX)
			Game->PlaySound(spriteSFX);
		
		if(staggerEffect){
			for(int i=0; i<staggerEffect; ++i){
				Waitframe();
			}
		}
		
		switch(effectType){
			case 1: //LWeapon
				lweapon l = CreateLWeaponAt(effectID, this->X, this->Y);
				l->UseSprite(effectSprite);
				l->Step = 0;
				l->Dir = -1;
				l->Damage = effectDamage;
				l->Angular = true;
				int angle = Angle(this->X, this->Y, Link->X, Link->Y);
				if(effectAngle>0)
					angle = effectAngle;
				if(effectStep<0){
					angle += 180;
					effectStep = Abs(effectStep);
				}
				l->Angle = DegtoRad(angle);
				if(effectDelay>0){
					for(int i=0; i<effectDelay; ++i){
						Waitframe();
					}
				}
				l->Step = effectStep;
				break;
			case 2: //EWeapon
				eweapon e = CreateEWeaponAt(effectID, this->X, this->Y);
				e->UseSprite(effectSprite);
				e->Step = 0;
				e->Dir = -1;
				e->Damage = effectDamage;
				e->Angular = true;
				int angle = Angle(this->X, this->Y, Link->X, Link->Y);
				if(effectAngle>0)
					angle = effectAngle;
				if(effectStep<0){
					angle += 180;
					effectStep = Abs(effectStep);
				}
				e->Angle = DegtoRad(angle);
				if(effectDelay>0){
					for(int i=0; i<effectDelay; ++i){
						Waitframe();
					}
				}
				e->Step = effectStep;
				break;
			case 3: //NPC
				npc n = CreateNPCAt(effectID, this->X, this->Y);
				if(effectDamage>0)
					n->Damage = effectDamage;
				if(effectDelay>0){
					int oldStep = n->Step;
					n->Step = 0;
					for(int i=0; i<effectDelay; ++i){
						n->Step = 0;
						Waitframe();
					}
					n->Step = oldStep;
					if(effectStep>0)
						n->Step = effectStep;
				}
				break;
		}
	}
}

combodata script RedrawCombo{
	void run(){
		mapdata lyr = Game->LoadTempScreen(this->Layer);
		while(true){
			Screen->FastCombo(this->Layer, this->X, this->Y, this->ID, lyr->ComboC[this->Pos], 128);
			Waitframe();
		}
	}
}