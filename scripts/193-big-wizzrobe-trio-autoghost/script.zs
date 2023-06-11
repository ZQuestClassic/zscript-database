//Fake enemy
//Set to not be a beatable enemy
//Set to not return on death
//Will die along with main boss
//Must be placed on screen in enemy editor and set up like other enemies

ffc script Fake_Agahnim{
	void run(int enemyid){
		int i; 
		npc ghost = Ghost_InitAutoGhost(this, enemyid);
		int SFX = ghost->Attributes[0];
		int SPR = ghost->Attributes[1];
		int combo = ghost->Attributes[10];
		int attackCooldown = ghost->Haltrate*10;
		float angle = Rand(360);
		bool attackCond = false;
		eweapon fireball;
		int counter=-1;
		int attack;
		int X;
		int Y;
		Ghost_SetSize(this,ghost,2,2);
		while(true){
			if(Ghost_Dir==DIR_UP)
				Ghost_Data = combo;
			else if(Ghost_Dir==DIR_DOWN)
				Ghost_Data = combo+1;
			else if(Ghost_Dir==DIR_LEFT)
				Ghost_Data = combo+2;
			else if(Ghost_Dir==DIR_RIGHT)
				Ghost_Data = combo+3;		
			if(attackCooldown>0){
				counter = Ghost_ConstantWalk4(counter, ghost->Step, ghost->Rate, ghost->Homing, ghost->Hunger);
				attackCooldown--;
			}
			else if(attackCooldown<=0)
				attackCond=true;
			if(attackCond){
				Gen_Explode_Waitframes(this,ghost, Choose(32, 48, 96));
				TeleportNPC(this, ghost);	
				angle = Angle(ghost->X+16,ghost->Y+16,CenterLinkX(),CenterLinkY());
				if(Between(angle,0,45))
					angle=0;
				else if(Between(angle,46,135))
					angle=90;
				else if(Between(angle,136,225))
					angle= 180;
				else if(Between(angle,226,315))
					angle= 270;
				else
					angle= 0;
				if(angle==90){
					Ghost_Dir=DIR_DOWN;
					Ghost_Data = combo+1;
					X= 12;
					Y= 32;
				}
				else if(angle==180){
					Ghost_Dir=DIR_LEFT;
					Ghost_Data = combo+2;
					X= -16;
					Y= 12;
				}
				else if(angle==270){
					Ghost_Dir=DIR_UP;
					Ghost_Data = combo;
					X= 12;
					Y= -16;
				}
				else{
					Ghost_Dir= DIR_RIGHT;
					Ghost_Data = combo+3;
					X= 32;
					Y= 12;
				}
				Ghost_Waitframes(this,ghost,30);
				fireball = FireEWeapon(EW_MAGIC,ghost->X+X,ghost->Y+Y,DegtoRad(angle), 200, 
											ghost->WeaponDamage, SPR, SFX,0);
				attackCooldown = ghost->Haltrate*10;
				attackCond = false;
			}
			Gen_Explode_Waitframe(this,ghost);
		}
	}
}

ffc script Agahnim{
	void run(int enemyid){
		int i; 
		npc ghost = Ghost_InitAutoGhost(this, enemyid);
		int SFX = ghost->Attributes[0];
		int SPR = ghost->Attributes[1];
		int combo = ghost->Attributes[10];
		int attackCooldown = ghost->Haltrate*10;
		float angle = Rand(360);
		bool attackCond = false;
		eweapon fireball;
		int counter=-1;
		int attack;
		int X;
		int Y;
		Ghost_SetSize(this,ghost,2,2);
		while(true){
			if(Ghost_Dir==DIR_UP)
				Ghost_Data = combo;
			else if(Ghost_Dir==DIR_DOWN)
				Ghost_Data = combo+1;
			else if(Ghost_Dir==DIR_LEFT)
				Ghost_Data = combo+2;
			else if(Ghost_Dir==DIR_RIGHT)
				Ghost_Data = combo+3;		
			if(attackCooldown>0){
				counter = Ghost_ConstantWalk4(counter, ghost->Step, ghost->Rate, ghost->Homing, ghost->Hunger);
				attackCooldown--;
			}
			else if(attackCooldown<=0)
				attackCond=true;
			if(attackCond){
				Gen_Leader_Waitframes(this,ghost, Choose(32, 48, 96));
				if(Rand(0,100)>51)
					attack= 1;
				else
					attack=0;
				if(attack==0){
					TeleportNPC(this, ghost);	
					angle = Angle(ghost->X+16,ghost->Y+16,CenterLinkX(),CenterLinkY());
					if(Between(angle,0,45))
						angle=0;
					else if(Between(angle,46,135))
						angle=90;
					else if(Between(angle,136,225))
						angle= 180;
					else if(Between(angle,226,315))
						angle= 270;
					else
						angle= 0;
					if(angle==90){
						Ghost_Dir=DIR_DOWN;
						Ghost_Data = combo+1;
						X= 12;
						Y= 32;
					}
					else if(angle==180){
						Ghost_Dir=DIR_LEFT;
						Ghost_Data = combo+2;
						X= -16;
						Y= 12;
					}
					else if(angle==270){
						Ghost_Dir=DIR_UP;
						Ghost_Data = combo;
						X= 12;
						Y= -16;
					}
					else{
						Ghost_Dir= DIR_RIGHT;
						Ghost_Data = combo+3;
						X= 32;
						Y= 12;
					}
					Gen_Leader_Waitframes(this,ghost,30);
					fireball = FireEWeapon(EW_MAGIC,ghost->X+X,ghost->Y+Y,DegtoRad(angle), 200, 
												ghost->WeaponDamage, SPR, SFX,0);
				}
				else{
					X= 120;
					Y= 32;
					angle = Angle(CenterX(ghost), CenterY(ghost), X,Y);
					Ghost_Data= combo+1;
					Gen_Leader_Waitframe(this,ghost);
					while(Ghost_CanMove(AngleDir8(angle), 16, 0)){
						Ghost_MoveAtAngle(angle, 5, 0);
						Phantom_Rush(this, ghost);
						Gen_Leader_Waitframe(this,ghost);
					}
					Lightning(this,ghost);
				}
				attackCooldown = ghost->Haltrate*10;
				attackCond = false;
			}
			Gen_Leader_Waitframe(this,ghost);
		}
	}
}

//Newbie boss functions by Moosh
const int GALE_WARP_SFX = 91;

void TeleportNPC(ffc this, npc ghost){	
	int w = ghost->TileWidth;
	int h = ghost->TileHeight;
	Game->PlaySound(GALE_WARP_SFX);
	int tc;
	ghost->CollDetection = false;
	for(int i=0; i<16; i++){
		if(i%2==0)
			ghost->DrawYOffset = -1000;
		else
			ghost->DrawYOffset = -2;
		Gen_Explode_Waitframe(this,ghost);
	}
	ghost->DrawYOffset = -1000;
	tc = Rand(176);
	for(int i=0; i<352&&(!CanPlaceNPC(ghost, ComboX(tc), 
			ComboY(tc))||Distance(ComboX(tc)+ghost->HitWidth/2, 
			ComboY(tc)+ghost->HitHeight/2, CenterLinkX(), CenterLinkY())<((w+h)/2)*8+32); i++){
		if(i>=176)
			tc = i-176;
		else
			tc = Rand(176);
	}
	Ghost_X = ComboX(tc);
	Ghost_Y = ComboY(tc);
	Gen_Explode_Waitframe(this,ghost);
	Ghost_Dir = AngleDir4(Angle(CenterX(ghost), CenterY(ghost), CenterLinkX(), CenterLinkY()));
	for(int i=0; i<16; i++){
		if(i%2==0)
			ghost->DrawYOffset = -1000;
		else
			ghost->DrawYOffset = -2;
		Gen_Explode_Waitframe(this,ghost);
	}
	ghost->DrawYOffset = -2;
	ghost->CollDetection = true;
}

bool CanPlaceNPC(npc ghost, int X, int Y){
	for(int x=ghost->HitXOffset; x<=ghost->HitXOffset+ghost->HitWidth-1; x=Min(x+8, ghost->HitXOffset+ghost->HitWidth-1)){
		for(int y=ghost->HitYOffset; y<=ghost->HitYOffset+ghost->HitHeight-1; y=Min(y+8, ghost->HitYOffset+ghost->HitHeight-1)){
			if(!Ghost_CanMovePixel(X+x, Y+y))
				return false;
			if(y==ghost->HitYOffset+ghost->HitHeight-1)
				break;
		}
		if(x==ghost->HitXOffset+ghost->HitWidth-1)
			break;
	}
	return true;
}

void Phantom_Rush(ffc this, npc ghost){
	int tile = Game->ComboTile(this->Data);
	lweapon trail = CreateLWeaponAt(LW_SCRIPT5, ghost->X+ghost->DrawXOffset, ghost->Y+ghost->DrawYOffset);
	trail->Extend = 3;
	trail->TileWidth = ghost->TileWidth;
	trail->TileHeight = ghost->TileHeight;
	trail->CSet = this->CSet;
	trail->Tile = tile;
	trail->OriginalTile = tile;
	trail->DrawStyle = DS_PHANTOM;
	trail->DeadState = 8;
}

//Lightning functions by Dimi
const int SFX_BOLT = 66;

void Lightning(ffc this, npc ghost){
	int Lightning1X[25];
	int Lightning1Y[25];
	int Lightning2X[25];
	int Lightning2Y[25];
	int Lightning3X[25];
	int Lightning3Y[25];
	int Lightning4X[25];
	int Lightning4Y[25];
	int HitCounter = 0;
	int i;
	int m= Rand(2,6);
	for (; m!= 0;){
		if (m > 0) m--;
		for (i = 24; i >= 0; i--){
			Lightning1X[i] = this->X+16;
			Lightning1Y[i] = this->Y+32;
			Lightning2X[i] = this->X+16;
			Lightning2Y[i] = this->Y+32;
			Lightning3X[i] = this->X+16;
			Lightning3Y[i] = this->Y+32;
			Lightning4X[i] = this->X+16;
			Lightning4Y[i] = this->Y+32;
		}
		Game->PlaySound(SFX_BOLT);
		while((Lightning1Y[24] < 176 
				|| Lightning2Y[24] < 176 
				|| Lightning3Y[24] < 176
				|| Lightning4Y[24] < 176)){
			bool Struck = false;
			for (int l = 0; l <= 2; l++){
				int Angle1 = Choose(210, 150, 225, 135);
				Angle1 -= 90;
				if(Link->X<=ghost->X-16)
					Angle1+=22;
				else if(Link->X>=ghost->X+48)
					Angle1-=22;
				ShiftArray(Lightning1X);
				ShiftArray(Lightning1Y);
				Lightning1X[0] += VectorX(10, Angle1);
				Lightning1Y[0] += VectorY(10, Angle1);
				int Angle2 = Choose(210, 150, 225, 135);
				Angle2 -= 90;
				if(Link->X<=ghost->X-16)
					Angle2+=22;
				else if(Link->X>=ghost->X+48)
					Angle2-=22;
				ShiftArray(Lightning2X);
				ShiftArray(Lightning2Y);
				Lightning2X[0] += VectorX(10, Angle2);
				Lightning2Y[0] += VectorY(10, Angle2);
				int Angle3 = Choose(210, 150, 225, 135);
				Angle3 -= 90;
				if(Link->X<=ghost->X-16)
					Angle3+=22;
				else if(Link->X>=ghost->X+48)
					Angle3-=22;
				ShiftArray(Lightning3X);
				ShiftArray(Lightning3Y);
				Lightning3X[0] += VectorX(10, Angle3);
				Lightning3Y[0] += VectorY(10, Angle3);
				int Angle4 = Choose(210, 150, 225, 135);
				Angle4 -= 90;
				if(Link->X<=ghost->X-16)
					Angle4+=22;
				else if(Link->X>=ghost->X+48)
					Angle4-=22;
				ShiftArray(Lightning4X);
				ShiftArray(Lightning4Y);
				Lightning4X[0] += VectorX(10, Angle4);
				Lightning4Y[0] += VectorY(10, Angle4);
				for (i = 24; i > 0; i--){
					Screen->Line(2, Lightning1X[i], Lightning1Y[i], Lightning1X[i-1], 
									Lightning1Y[i-1], 0x0B, 1, 0, 0, 0, 128);
					Screen->Line(2, Lightning2X[i], Lightning2Y[i], Lightning2X[i-1], 
									Lightning2Y[i-1], 0x0B, 1, 0, 0, 0, 128);
					Screen->Line(2, Lightning3X[i], Lightning3Y[i], Lightning3X[i-1], 
									Lightning3Y[i-1], 0x0B, 1, 0, 0, 0, 128);
					Screen->Line(2, Lightning4X[i], Lightning4Y[i], Lightning4X[i-1], 
									Lightning4Y[i-1], 0x0B, 1, 0, 0, 0, 128);
					Screen->Line(2, Lightning1X[i] - 1, Lightning1Y[i], Lightning1X[i-1] - 1, 
									Lightning1Y[i-1], 0x0B, 2, 0, 0, 0, 64);
					Screen->Line(2, Lightning2X[i] - 1, Lightning2Y[i], Lightning2X[i-1] - 1, 
									Lightning2Y[i-1], 0x0B, 2, 0, 0, 0, 64);
					Screen->Line(2, Lightning3X[i] - 1, Lightning3Y[i], Lightning3X[i-1] - 1, 
									Lightning3Y[i-1], 0x0B, 2, 0, 0, 0, 64);
					Screen->Line(2, Lightning4X[i] - 1, Lightning4Y[i], Lightning4X[i-1] - 1, 
									Lightning4Y[i-1], 0x0B, 2, 0, 0, 0, 64);
					if (!Struck){
						if (lineBoxCollision(Lightning1X[i], Lightning1Y[i], 
												Lightning1X[i-1], Lightning1Y[i-1], 
												Link->X, Link->Y, Link->X+Link->HitWidth, Link->Y+Link->HitHeight, 0))
						{
							Struck = true;
							if (HitCounter <= 0) HitCounter = 10;
							continue;
						}	
						if (lineBoxCollision(Lightning2X[i], Lightning2Y[i], 
												Lightning2X[i-1], Lightning2Y[i-1], 
												Link->X, Link->Y, Link->X+Link->HitWidth, Link->Y+Link->HitHeight, 0))
						{
							Struck = true;
							if (HitCounter <= 0) HitCounter = 10;
							continue;
						}
						if (lineBoxCollision(Lightning3X[i], Lightning3Y[i], 
												Lightning3X[i-1], Lightning3Y[i-1], 
												Link->X, Link->Y, Link->X+Link->HitWidth, Link->Y+Link->HitHeight, 0))
						{
							Struck = true;
							if (HitCounter <= 0) HitCounter = 10;
							continue;
						}
						if (lineBoxCollision(Lightning4X[i], Lightning4Y[i], 
												Lightning4X[i-1], Lightning4Y[i-1], 
												Link->X, Link->Y, Link->X+Link->HitWidth, Link->Y+Link->HitHeight, 0))
						{
							Struck = true;
							if (HitCounter <= 0) HitCounter = 10;
							continue;
						}
					}
				}
			}
			if (Struck){
				eweapon e = FireEWeapon(EW_SCRIPT10, Link->X+InFrontX(Link->Dir, 10), 
											Link->Y+InFrontY(Link->Dir, 10), 0, 0, 8, -1, -1, EWF_UNBLOCKABLE);
				SetEWeaponLifespan(e, EWL_TIMER, 1);
				SetEWeaponDeathEffect(e, EWD_VANISH, 0);
				e->DrawYOffset = -1000;
			}
			if (HitCounter > 0){
				if (Link->HP > 0)
					Screen->Rectangle(6, 0, 0, 256, 176, 1, 1, 0, 0, 0, true, OP_TRANS);
			}
			Gen_Explode_Waitframe(this,ghost);
			for (i = 24; i > 0; i--){
				Screen->Line(2, Lightning1X[i], Lightning1Y[i], 
								Lightning1X[i-1], Lightning1Y[i-1], 0x0B, 1, 0, 0, 0, 128);
				Screen->Line(2, Lightning2X[i], Lightning2Y[i], 
								Lightning2X[i-1], Lightning2Y[i-1], 0x0B, 1, 0, 0, 0, 128);
				Screen->Line(2, Lightning3X[i], Lightning3Y[i], 
								Lightning3X[i-1], Lightning3Y[i-1], 0x0B, 1, 0, 0, 0, 128);
				Screen->Line(2, Lightning4X[i], Lightning4Y[i], 
								Lightning4X[i-1], Lightning4Y[i-1], 0x0B, 1, 0, 0, 0, 128);
				Screen->Line(2, Lightning1X[i] - 1, Lightning1Y[i], 
								Lightning1X[i-1] - 1, Lightning1Y[i-1], 0x01, 2, 0, 0, 0, 64);
				Screen->Line(2, Lightning2X[i] - 1, Lightning2Y[i], 
								Lightning2X[i-1] - 1, Lightning2Y[i-1], 0x01, 2, 0, 0, 0, 64);
				Screen->Line(2, Lightning3X[i] - 1, Lightning3Y[i], 
								Lightning3X[i-1] - 1, Lightning3Y[i-1], 0x01, 2, 0, 0, 0, 64);
				Screen->Line(2, Lightning4X[i] - 1, Lightning4Y[i], 
								Lightning4X[i-1] - 1, Lightning4Y[i-1], 0x01, 2, 0, 0, 0, 64);
			}
			if (HitCounter > 0){
				if (Link->HP > 0)
					Screen->Rectangle(6, 0, 0, 256, 176, 1, 1, 0, 0, 0, true, OP_OPAQUE);
				HitCounter--;
			}
			Gen_Explode_Waitframe(this,ghost);
			for (i = 24; i > 0; i--){
				Screen->Line(2, Lightning1X[i], Lightning1Y[i], 
								Lightning1X[i-1], Lightning1Y[i-1], 0x01, 1, 0, 0, 0, 128);
				Screen->Line(2, Lightning2X[i], Lightning2Y[i], 
								Lightning2X[i-1], Lightning2Y[i-1], 0x01, 1, 0, 0, 0, 128);
				Screen->Line(2, Lightning3X[i], Lightning3Y[i],
								Lightning3X[i-1], Lightning3Y[i-1], 0x01, 1, 0, 0, 0, 128);
				Screen->Line(2, Lightning4X[i], Lightning4Y[i], 
								Lightning4X[i-1], Lightning4Y[i-1], 0x01, 1, 0, 0, 0, 128);
				Screen->Line(2, Lightning1X[i] - 1, Lightning1Y[i], 
								Lightning1X[i-1] - 1, Lightning1Y[i-1], 0x0B, 2, 0, 0, 0, 64);
				Screen->Line(2, Lightning2X[i] - 1, Lightning2Y[i], 
								Lightning2X[i-1] - 1, Lightning2Y[i-1], 0x0B, 2, 0, 0, 0, 64);
				Screen->Line(2, Lightning3X[i] - 1, Lightning3Y[i], 
								Lightning3X[i-1] - 1, Lightning3Y[i-1], 0x0B, 2, 0, 0, 0, 64);
				Screen->Line(2, Lightning4X[i] - 1, Lightning4Y[i], 
								Lightning4X[i-1] - 1, Lightning4Y[i-1], 0x0B, 2, 0, 0, 0, 64);
			}
			Gen_Explode_Waitframe(this,ghost);
			for (i = 24; i > 0; i--){
				Screen->Line(2, Lightning1X[i], Lightning1Y[i], 
								Lightning1X[i-1], Lightning1Y[i-1], 0x01, 1, 0, 0, 0, 128);
				Screen->Line(2, Lightning2X[i], Lightning2Y[i], 
								Lightning2X[i-1], Lightning2Y[i-1], 0x01, 1, 0, 0, 0, 128);
				Screen->Line(2, Lightning3X[i], Lightning3Y[i], 
								Lightning3X[i-1], Lightning3Y[i-1], 0x01, 1, 0, 0, 0, 128);
				Screen->Line(2, Lightning4X[i], Lightning4Y[i], 
								Lightning4X[i-1], Lightning4Y[i-1], 0x01, 1, 0, 0, 0, 128);
				Screen->Line(2, Lightning1X[i] - 1, Lightning1Y[i], 
								Lightning1X[i-1] - 1, Lightning1Y[i-1], 0x01, 2, 0, 0, 0, 64);
				Screen->Line(2, Lightning2X[i] - 1, Lightning2Y[i], 
								Lightning2X[i-1] - 1, Lightning2Y[i-1], 0x01, 2, 0, 0, 0, 64);
				Screen->Line(2, Lightning3X[i] - 1, Lightning3Y[i], 
								Lightning3X[i-1] - 1, Lightning3Y[i-1], 0x01, 2, 0, 0, 0, 64);
				Screen->Line(2, Lightning4X[i] - 1, Lightning4Y[i], 
								Lightning4X[i-1] - 1, Lightning4Y[i-1], 0x01, 2, 0, 0, 0, 64);
			}
			Gen_Explode_Waitframe(this,ghost);
		}
	}
	while(HitCounter > 0){
		if (Link->HP > 0)
			Screen->Rectangle(6, 0, 0, 256, 176, 1, 1, 0, 0, 0, true, OP_OPAQUE);
		Gen_Explode_Waitframe(this,ghost);
		if (Link->HP > 0) 
			Screen->Rectangle(6, 0, 0, 256, 176, 1, 1, 0, 0, 0, true, OP_OPAQUE);
		HitCounter--;
		Gen_Explode_Waitframes(this,ghost,3);
	}
}

void ShiftArray(int Array){
	for (int i = SizeOfArray(Array)-1; i > 0; i--)
		Array[i] = Array[i-1];
}

// Function to see if a box has collided with a line
bool lineBoxCollision(int lineX1, int lineY1, int lineX2, 
						int lineY2, int boxX1, int boxY1, int boxX2, int boxY2, int boxBorder)
{
	// Shrink down the box for the border
	boxX1 += boxBorder; boxY1 += boxBorder;
	boxX2 -= boxBorder; boxY2 -= boxBorder;
	
	// If the line isn't vertical
	if(lineX2!=lineX1)
	{
		
		float i0 = (boxX1 - lineX1)/(lineX2-lineX1);
		float i1 = (boxX2 - lineX1)/(lineX2-lineX1);
		
		float yA = lineY1 + i0*(lineY2-lineY1);
		float yB = lineY1 + i1*(lineY2-lineY1);
		
		
		if(Max(boxX1, boxX2) >= Min(lineX1, lineX2) && Min(boxX1, boxX2) <= Max(lineX1, lineX2) &&
			Max(boxY1, boxY2) >= Min(lineY1, lineY2) && Min(boxY1, boxY2) <= Max(lineY1, lineY2))
		{
			if(Min(boxY1, boxY2) > Max(yA, yB) || Max(boxY1, boxY2) < Min(yA, yB))
				return false;
			else
				return true;
		}
		else
			return false;
	}
	// If the line is vertical
	else if(lineX1 >= boxX1 && lineX1 <= boxX2)
	{
		// Basically we need to find the top and bottom y values of the line to check for intersection
		float lineYMin = lineY1;
		float lineYMax = lineY2;
		
		if(lineYMin > lineYMax)
		{
			lineYMin = lineY2;
			lineYMax = lineY1;
		}
		
		// If either point intersects
		if((boxY1 >= lineYMin && boxY1 <= lineYMax) || (boxY2 >= lineYMin && boxY2 <= lineYMax))
			return true;
	}
	
	return false;
} //! End of lineBoxCollisionlineBoxCollision     

//Utility functions from lweapons.zh
//Uses to make a boss using the Gen_Explode_Waitframe wait for a certain number of frames before doing something.

void Gen_Explode_Waitframes(ffc this, npc ghost,int frames){
	for(;frames>0;frames--){
		Gen_Explode_Waitframe(this,ghost);
	}
}    
                   
//A general utility function to make a boss explode on death.

void Gen_Explode_Waitframe(ffc this, npc ghost){
     if(!Ghost_Waitframe(this, ghost, false, false)){
	   Ghost_DeathAnimation(this, ghost, 2);
	   Quit();
     }
}

//Kills all npcs on screen when this enemy dies.

void Gen_Leader_Waitframe(ffc this, npc ghost){
	 if(!Ghost_Waitframe(this, ghost, false, false)){
	   Ghost_DeathAnimation(this, ghost, 2);
	   for(int i =Screen->NumNPCs();i>0;i--){
			npc n = Screen->LoadNPC(i);
			n->HP = 0;
	   }
	   Quit();
     }
}

void Gen_Leader_Waitframes(ffc this, npc ghost, int frames){
	for(;frames>0;frames--)
		Gen_Leader_Waitframe(this,ghost);
}

//Test if one location is between two others.
//D0- Location to test
//D1- Lower bound
//D2- Higher bound

bool Between(int loc,int greaterthan, int lessthan){
	if(loc>=greaterthan && loc<=lessthan)return true;
	return false;
}