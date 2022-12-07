//Constants used by bombchu script.
const int LW_BOMBCHU = 31; //The weapon ID of the bombchu, must be unique and between 31 and 40.
const int CF_BOMBCHU = 98; //Combo solidity on combos locations with this flag will be treated opposite by the bombchu.

item script Bombchu{
	//d0 is the ffc script slot that has the
	//d1 is the explosion type. 0-2: bomb blast, super bomb blast, and 8 fires respectfully.
	//d2 is the movement type. 0-2: no direction changing, 4 way, and 8 way respectfully.
	//d3 is the step speed. 100 is one pixel.
	//d4 is the sprite. Sprite to use for the bombchu. Sprites are organized UP DOWN LEFT RIGHT.
	//d5 is the sfx to use if the 8 fire blast type is used.
	//Power is the damage done by the bombchu's explosion
	//The Counter reference in the pickup tab is what counter it will use.
	void run(int ffcScriptNum, int blastType, int moveType, int step, int sprite, int sfx){
		if(!Link->PressA && !Link->PressB) Quit();
		if(CountFFCsRunning(ffcScriptNum) == 0 && Game->Counter[this->Counter] > 0){
			Game->Counter[this->Counter]--;
			Game->PlaySound(SFX_PLACE);
			int args[8] = {blastType, moveType, step, sprite, sfx, this->Power};
			RunFFCScript(ffcScriptNum, args);
		}
	}
}

ffc script Bombchu_FFC{
	void run(int blastType, int moveType, int step, int sprite, int sfx, int damage){
		//Create the bombchu infront of link.
		lweapon bombchu = NextToLink(LW_BOMBCHU, 0);
		bombchu->CollDetection = false;
		bombchu->Dir = Link->Dir;
		bombchu->Step = step;
		bombchu->HitZHeight = 2;
		//Loop until it becomes invalid.
		while(bombchu->isValid()){
			//Update direction based off input, but only if moveType is between 1 and 2.
			if(moveType == VBound(moveType, 2, 1)){
				int dir = -1;
				if(Link->InputUp && !Link->InputDown) dir = DIR_UP;
				else if(Link->InputDown && !Link->InputUp) dir = DIR_DOWN;
				if(Link->InputLeft && !Link->InputRight){
					if(moveType == 2){
						if(dir == DIR_UP) dir = DIR_LEFTUP;
						if(dir == DIR_DOWN) dir = DIR_LEFTDOWN;
					}
					if(dir == -1) dir = DIR_LEFT;
				}
				else if(Link->InputRight && !Link->InputLeft){
					if(moveType == 2){
						if(dir == DIR_UP) dir = DIR_RIGHTUP;
						if(dir == DIR_DOWN) dir = DIR_RIGHTDOWN;
					}
					if(dir == -1) dir = DIR_RIGHT;
				}
				if(dir != -1) bombchu->Dir = dir;
			}
			//Update the sprite based off direction.
			bombchu->UseSprite(sprite);
			bombchu->OriginalTile += bombchu->NumFrames*bombchu->Dir;
			//Declare variables to be used to detect collisions.
			bool contact;
			int dir = bombchu->Dir;
			//If the bombchu is about to go off screen expode.
			if(dir == 0 || dir == 4 || dir == 5) contact = (bombchu->Y - step/100 <= 0);
			else if(dir == 1 || dir == 6 || dir == 7) contact = (bombchu->Y + step/100 >= 152);
			else if(dir == 2 || dir == 4 || dir == 6) contact = (bombchu->X - step/100 <= 0);
			else if(dir == 3 || dir == 5 || dir == 7) contact = (bombchu->X + step/100 >= 240);
			//If the bombchu collided with a npc expode.
			for(int i = Screen->NumNPCs(); i > 0 && !contact; i--){
				npc n = Screen->LoadNPC(i);
				if(!n->CollDetection) continue;
				if(n->ID == NPC_ITEMFAIRY) continue;
				if(n->Type == NPCT_PEAHAT && n->Step != 0 && n->Z == 0) continue;
				if(n->Defense[NPCD_SCRIPT] == NPCDT_IGNORE) continue;
				if(Collision(n, bombchu)) contact = true;
			}
			//If the bombchu is about to hit something solid according to bombchu solidity explode.
			if(!contact){
			   int x = bombchu->X + AtFrontX(bombchu->Dir);
			   int y = bombchu->Y + AtFrontY(bombchu->Dir);
			   if(!contact){
				   if(ComboFI(x, y, CF_BOMBCHU)) contact = !Screen->isSolid(x, y);
				   else contact = Screen->isSolid(x, y);
			   }
			   if(IsWater(ComboAt(x,y)) || IsPit(ComboAt(x,y))) contact = true;
			}
			if(Link->Action == LA_GOTHURTLAND) contact = true;
			//If contact was set to true explode.
			if(contact){
				if(blastType == 0){
					lweapon blast = CreateLWeaponAt(LW_BOMBBLAST, bombchu->X, bombchu->Y);
					blast->Damage = damage;
				}
				else if(blastType == 1){
					lweapon blast = CreateLWeaponAt(LW_SBOMBBLAST, bombchu->X, bombchu->Y);
					blast->Damage = damage;
				}
				else if(blastType == 2){
					for(int i; i < 8; i++){
						lweapon fire = CreateLWeaponAt(LW_FIRE, bombchu->X, bombchu->Y);
						fire->Dir = i;
						fire->Step = 100;
						fire->Angular = true;
						fire->Angle = DegtoRad(i*45);
						fire->Damage = damage;
					}
				}
				bombchu->DeadState = 0;
				Game->PlaySound(sfx);
			}
			WaitNoAction();
		}
	}
}