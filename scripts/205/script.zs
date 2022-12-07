const int WARDEN_FAKE = 214;
const int LIMB_SPRITE = 102;

ffc script Wood_Warden{
    void run(int enemyID){
	npc ghost = Ghost_InitAutoGhost(this, enemyID);
	npc n[4];
	n[0]= Screen->CreateNPC(WARDEN_FAKE);
	n[1]= Screen->CreateNPC(WARDEN_FAKE);
	n[2]= Screen->CreateNPC(WARDEN_FAKE);
	n[3]= Screen->CreateNPC(WARDEN_FAKE);
	n[0]->Extend = 3;
	n[1]->Extend = 3;
	n[2]->Extend = 3;
	n[3]->Extend = 3;
	n[0]->TileHeight = 4;
	n[1]->TileHeight = 4;
	n[2]->TileHeight = 4;
	n[3]->TileHeight = 4;
	n[0]->TileWidth = 3;
	n[1]->TileWidth = 3;
	n[2]->TileWidth = 3;
	n[3]->TileWidth = 3;
	Ghost_TileWidth = 3;
	Ghost_TileHeight = 4;
	int first = Choose(0,1,2,3);
	int second;
	int third;
	int fourth;
	n[0]->X=64;
	n[0]->Y=48;  
	n[1]->X=160;
	n[1]->Y=48;
	n[2]->X=160;
	n[2]->Y=96;
	n[3]->X=64;
	n[3]->Y=96;
	int combo = ghost->Attributes[10];
	int turncombo;
	float counter = -1;
	int mode = 1;
	int step = ghost->Step;
	int dive_timer = Choose(90,120,150,180);
	int throw = Choose(90,120,180);
	if(first==0){
		 second = Choose(1,2,3);
		 if(second ==1){
			third = Choose(2,3);
			if(third ==2)fourth = 3;
			else fourth =2;
		 }
		 else if (second ==2){
			third = Choose(1,3);
			if(third ==1)fourth = 3;
			else fourth =1;
		 }
		 else if(second ==3){
			third = Choose(1,2);
			if(third ==1)fourth = 2;
			else fourth =1;
		 }
	}
	else if(first ==1){
		 second = Choose(0,2,3);
		 if(second ==0){
			  third = Choose(2,3);
			  if(third ==2)fourth = 3;
			  else fourth =2;
		 }
		 else if (second ==2){
			  third = Choose(0,3);
			  if(third ==0)fourth = 3;
			  else fourth =0;
		 }
		 else if(second ==3){
			  third = Choose(0,2);
			  if(third ==0)fourth = 2;
			  else fourth =0;
		 }
	}   
	else if(first ==2){
		 second = Choose(1,0,3);
		 if(second ==0){
			  third = Choose(1,3);
			  if(third ==1)fourth = 3;
			  else fourth =1;
		 }
		 else if (second ==1){
			  third = Choose(0,3);
			  if(third ==0)fourth = 3;
			  else fourth =0;
		 }
		 else if(second ==3){
			  third = Choose(1,0);
			  if(third ==1)fourth = 0;
			  else fourth =1;
		 }
	}
	else if(first ==3){
		 second = Choose(0,1,2);
		 if(second ==0){
			  third = Choose(1,2);
			  if(third ==1)fourth = 2;
			  else fourth =1;
		 }
		 else if (second ==1){
			  third = Choose(0,2);
			  if(third ==0)fourth = 2;
			  else fourth =0;
		 }
		 else if(second ==2){
			  third = Choose(1,0);
			  if(third ==1)fourth = 0;
			  else fourth =0;
		 }
	}
	n[first]->OriginalTile = 120;
	Ghost_X = n[first]->X;
	Ghost_Y = n[first]->Y;
	bool isAlive1 = true;
	bool isAlive2 = true;
	bool isAlive3 = true;
	bool isAlive4 = true;
	bool PlaceSet = true;
	eweapon wave;
	int wait;
	while(true){          
		if(n[first]->HP<=0 && isAlive1){
			isAlive1 = false;
			PlaceSet = true;
			n[second]->OriginalTile = 120;
		}	
		else if(n[second]->HP<=0 && isAlive2){
			isAlive2 = false;
			PlaceSet = true;
			n[third]->OriginalTile = 120;
		}
		else if(n[third]->HP<=0 && isAlive3){
			isAlive3 = false;
			PlaceSet = true;
			n[fourth]->OriginalTile = 120;
		}
		else if(n[fourth]->HP<=0 && isAlive4)isAlive4 = false;
        if(isAlive1 && isAlive2 && isAlive3 && isAlive4){
			if(PlaceSet){
				Ghost_X= n[first]->X;
				Ghost_Y= n[first]->Y;
                Ghost_HP = n[first]->HP+10;
				PlaceSet = false;
			}
			else{
				n[first]->X= Ghost_X;
				n[first]->Y= Ghost_Y;
                n[first]->HP = Ghost_HP-10;
				if(mode == 2)n[first]->CollDetection = false;
				else n[first]->CollDetection = true;
			}	
		}
		if(isAlive2 && isAlive3 && isAlive4 && !isAlive1){
			if(PlaceSet){
				Ghost_X= n[second]->X;
				Ghost_Y= n[second]->Y;
                Ghost_HP = n[second]->HP+10;
				PlaceSet = false;
			}
			else{
				n[second]->X= Ghost_X;
				n[second]->Y= Ghost_Y;
                n[second]->HP = Ghost_HP-10;
				if(mode == 2)n[second]->CollDetection = false;
				else n[second]->CollDetection = true;
			}
		}
		if(isAlive3 && isAlive4 && !isAlive1 && !isAlive2){
			if(PlaceSet){
				Ghost_X= n[third]->X;
				Ghost_Y= n[third]->Y;
                Ghost_HP = n[third]->HP+10;
				PlaceSet = false;
			}
			else{
				n[third]->X= Ghost_X;
				n[third]->Y= Ghost_Y;
                n[third]->HP = Ghost_HP-10;
				if(mode == 2)n[third]->CollDetection = false;
				else n[third]->CollDetection = true;
			}	
		}
		if(isAlive4 && !isAlive3 && !isAlive1 && !isAlive2){
			if(PlaceSet){
				Ghost_X= n[fourth]->X;
				Ghost_Y= n[fourth]->Y;
                Ghost_HP = n[fourth]->HP+10;
				PlaceSet = false;
			}
			else{
				n[fourth]->X= Ghost_X;
				n[fourth]->Y= Ghost_Y;
                n[fourth]->HP = Ghost_HP-10;
				if(mode == 2)n[fourth]->CollDetection = false;
				else n[fourth]->CollDetection = true;
			}
		}
		if(!isAlive4 && !isAlive3 && !isAlive1 && !isAlive2)Ghost_HP = 2;
		if(mode ==1){
			ghost->Defense[NPCD_BEAM]=NPCDT_NONE;
			ghost->Defense[NPCD_FIRE]=NPCDT_NONE;
			ghost->Defense[NPCD_SWORD]=NPCDT_NONE;
			if(ghost->Dir == DIR_UP){
				turncombo = combo;
				Ghost_SetHitOffsets(ghost, 1,4,0,0);
			}
			else if(ghost->Dir == DIR_DOWN){
				turncombo = combo+1;
				Ghost_SetHitOffsets(ghost,1,4,0,2);
			}
			else if(ghost->Dir == DIR_LEFT){
				turncombo = combo+2;
				Ghost_SetHitOffsets(ghost,16,4,14,2);
			}
			else if(ghost->Dir == DIR_RIGHT){
				turncombo = combo+3;
				Ghost_SetHitOffsets(ghost,16,4,2,14);
			}
		}
        else Ghost_SetAllDefenses(ghost, NPCDT_IGNORE);
		if(dive_timer<=0){
			if(mode==1){
				step = 0;
				wait = 20;
				while(wait>0){
					if(wait>14)turncombo = combo+4;
					else if(wait>=7 && wait <=14)turncombo = combo+5;
					else if(wait<7)turncombo = combo+6;
					wait--;
					Ghost_Data = turncombo;
					Gen_Explode_Waitframe(this,ghost);
				}
				turncombo = combo+7;
				ghost->CollDetection = false;
				step = ghost->Step;
				dive_timer = 120;
				mode =2;
			}
			else{
				dive_timer = Choose(90,120,150,180);
				step = 0;
				ghost->CollDetection = true;
				wait = 20;
				while(wait>0){
					if(wait>14)turncombo = combo+6;
					else if(wait>=7 && wait <=14)turncombo = combo+5;
					else if(wait<7)turncombo = combo+4;
					wait--;
					Ghost_Data = turncombo;
					Gen_Explode_Waitframe(this,ghost);
				}
				step = ghost->Step;
				mode = 1;
			} 
		}
		if(throw<0 && mode ==1){
			if (ghost->Dir == DIR_UP){
				 wave = FireAimedEWeapon(ghost->Weapon, ghost->X+24, ghost->Y, DegtoRad(270), 100, ghost->WeaponDamage, LIMB_SPRITE, 40, 0);
				 SetEWeaponLifespan(wave,EWL_TIMER, 120); 
				 SetEWeaponMovement(wave, EWM_HOMING, DegtoRad(3), 120);
				 SetEWeaponDeathEffect(wave,EWD_4_FIRES_RANDOM, LIMB_SPRITE);
			}
			else if(ghost->Dir == DIR_DOWN){
				 wave = FireAimedEWeapon(ghost->Weapon, ghost->X+24, ghost->Y+64, DegtoRad(90), 100, ghost->WeaponDamage, LIMB_SPRITE, 40, 0);
				 SetEWeaponLifespan(wave,EWL_TIMER, 120); 
				 SetEWeaponMovement(wave, EWM_HOMING, DegtoRad(3), 120);
				 SetEWeaponDeathEffect(wave,EWD_4_FIRES_RANDOM, LIMB_SPRITE);
			}
			else if(ghost->Dir == DIR_LEFT){
				 wave = FireAimedEWeapon(ghost->Weapon, ghost->X, ghost->Y+32, DegtoRad(180), 100, ghost->WeaponDamage, LIMB_SPRITE, 40, 0);
				 SetEWeaponLifespan(wave,EWL_TIMER, 120); 
				 SetEWeaponMovement(wave, EWM_HOMING, DegtoRad(3), 120);
				 SetEWeaponDeathEffect(wave,EWD_4_FIRES_RANDOM, LIMB_SPRITE);
			}
			else if(ghost->Dir == DIR_RIGHT){
				 wave = FireAimedEWeapon(ghost->Weapon, ghost->X+48, ghost->Y+32, DegtoRad(0), 100, ghost->WeaponDamage, LIMB_SPRITE, 40, 0);
				 SetEWeaponLifespan(wave,EWL_TIMER, 120); 
				 SetEWeaponMovement(wave, EWM_HOMING, DegtoRad(3), 120);
				 SetEWeaponDeathEffect(wave,EWD_4_FIRES_RANDOM, LIMB_SPRITE);
			}
			throw = Choose(90,120,180);
		}
		dive_timer--;
		throw--;
		counter = Ghost_ConstantWalk4(counter, step, ghost->Rate, ghost->Homing, ghost->Hunger);      
		Ghost_Data = turncombo;
		Gen_Explode_Waitframe(this,ghost);
        }
    }
}

//Generic waitframe to make a boss explode on death.
void Gen_Explode_Waitframe(ffc this, npc ghost){
     if(!Ghost_Waitframe(this, ghost, false, false)){
	   Ghost_DeathAnimation(this, ghost, 2);
	   Quit();
     }
}