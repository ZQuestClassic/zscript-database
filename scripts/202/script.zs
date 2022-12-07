const int VITREOUS_EYE = 209;//Enemy Id for small eyes.


ffc script Vitreous{
      void run(int enemyID){
          npc n = Ghost_InitAutoGhost(this, enemyID);
		  Ghost_SetSize(this,n,2,3);
          int combo = n->Attributes[10];
          Ghost_Data = combo;
		  //Remember speed so we can change it.
          float speed = n->Step/100;
          int step = 0;
		  //Handles boss behavior.
          int mode = 1;
		  //Make it wait before trying to attack you.
		  int mode_timer;
		  //Create small eyes.
          npc n2 = Screen->CreateNPC(VITREOUS_EYE);
          npc n3 = Screen->CreateNPC(VITREOUS_EYE);
          npc n4 = Screen->CreateNPC(VITREOUS_EYE);
          npc n5 = Screen->CreateNPC(VITREOUS_EYE);
		  //Position boss.
          Ghost_X = 112;
          Ghost_Y = 32;
		  //Position eyes.
          n2->X = Ghost_X-16;
          n2->Y = Ghost_Y+32;
          n3->X = Ghost_X;
          n3->Y = Ghost_Y+48;
          n4->X = Ghost_X+16;
          n4->Y = Ghost_Y+48;
          n5->X = Ghost_X+32;
          n5->Y = Ghost_Y+32;
		  //Activates if it is time to change behavior.
          int turncombo = combo+1;
		  Ghost_SetHitOffsets(n,6,11,0,0);
		  //Determine how often to fire lightning.
		  int fire_timer= Rand(100,200);
		  Ghost_CSet= 5;
		  Ghost_SetFlag(GHF_FAKE_Z);
		  Ghost_SetFlag(GHF_KNOCKBACK_4WAY);
		  this->Flags[FFCF_OVERLAY]= true;
		  int eye_pick;
		  bool Jump_Eye;
		  n2->Defense[NPCD_SWORD]= NPCDT_IGNORE;
		  n3->Defense[NPCD_SWORD]= NPCDT_IGNORE;
		  n4->Defense[NPCD_SWORD]= NPCDT_IGNORE;
		  n5->Defense[NPCD_SWORD]= NPCDT_IGNORE;
          while(n->HP > 0){
				if(mode==1 && fire_timer<=0){
					n2->Defense[NPCD_SWORD]= NPCDT_IGNORE;
					n3->Defense[NPCD_SWORD]= NPCDT_IGNORE;
					n4->Defense[NPCD_SWORD]= NPCDT_IGNORE;
					n5->Defense[NPCD_SWORD]= NPCDT_IGNORE;
					Lightning(this,n);					
					if(!Jump_Eye){
						if(n2->isValid() 
							&& n3->isValid() 
							&& n4->isValid() 
							&& n5->isValid()) 
							eye_pick= Choose(1,2,3,4);
						else if(!n2->isValid() 
								&& n3->isValid() 
								&& n4->isValid() 
								&& n5->isValid()) 
							eye_pick= Choose(2,3,4);
						else if(!n2->isValid() 
								&& !n3->isValid() 
								&& n4->isValid() 
								&& n5->isValid()) 
							eye_pick= Choose(3,4);	
						else if(!n2->isValid() 
								&& !n3->isValid() 
								&& !n4->isValid() 
								&& n5->isValid()) 
							eye_pick= 4;
						else if(n2->isValid() 
								&& !n3->isValid() 
								&& n4->isValid() 
								&& n5->isValid()) 
							eye_pick= Choose(1,3,4);
						else if(n2->isValid() 
								&& !n3->isValid() 
								&& !n4->isValid() 
								&& n5->isValid()) 
							eye_pick= Choose(1,4);
						else if(n2->isValid() 
								&& !n3->isValid() 
								&& !n4->isValid() 
								&& !n5->isValid()) 
							eye_pick= 1;
						else if(!n2->isValid() 
								&& n3->isValid() 
								&& !n4->isValid() 
								&& n5->isValid()) 
							eye_pick= Choose(2,4);
						else if(!n2->isValid() 
								&& n3->isValid() 
								&& !n4->isValid() 
								&& !n5->isValid()) 
							eye_pick= 2;
						else if(n2->isValid() 
								&& !n3->isValid() 
								&& n4->isValid() 
								&& !n5->isValid()) 
							eye_pick= Choose(1,3);
						else if(!n2->isValid() 
								&& !n3->isValid() 
								&& n4->isValid() 
								&& !n5->isValid()) 
							eye_pick= 3;
						else if(n2->isValid() 
								&& n3->isValid() 
								&& n4->isValid() 
								&& !n5->isValid()) 
							eye_pick= Choose(1,2,3);
						else if(n2->isValid() 
								&& n3->isValid() 
								&& !n4->isValid() 
								&& n5->isValid()) 
							eye_pick= Choose(1,2,4);
						else if(n2->isValid() 
								&& n3->isValid() 
								&& !n4->isValid() 
								&& !n5->isValid()) 
							eye_pick= Choose(1,2);
						else if(!n2->isValid() 
								&& n3->isValid() 
								&& n4->isValid() 
								&& !n5->isValid()) 
							eye_pick= Choose(2,3);	
						Jump_Eye = true;
						fire_timer= Rand(100,200);
					}
					else{
						if(n2->isValid()){
							n2->Defense[NPCD_SWORD]= NPCDT_IGNORE;
							while(n2->X-(n->X-16)>4 && n2->Y-(n->Y+32)>4){
								MoveToXY(n2,n->X-16,n->Y+32);
								Gen_Explode_Waitframe(this,n);
							}
							n2->X= n->X-16;
							n2->Y= n->Y+32;
							
						}
						if(n3->isValid()){
							n3->Defense[NPCD_SWORD]= NPCDT_IGNORE;
							while(n3->X-n->X>4 && n3->Y-(n->Y+48)>4){
								MoveToXY(n3,n->X,n->Y+48);
								Gen_Explode_Waitframe(this,n);
							}
							n3->X= n->X;
							n3->Y= n->Y+48;
						}
						if(n4->isValid()){
							n4->Defense[NPCD_SWORD]= NPCDT_IGNORE;
							while(n4->X-(n->X+16)>4 && n4->Y-(n->Y+48)>4){
								MoveToXY(n4,n->X+16,n->Y+48);
								Gen_Explode_Waitframe(this,n);
							}
							n4->X = n->X+16;
							n4->Y= n->Y+48;
						}
						if(n5->isValid()){
							n5->Defense[NPCD_SWORD]= NPCDT_IGNORE;
							while(n5->X-(n->X+32)>4 && n5->Y-(n->Y+32)>4){
								MoveToXY(n5,n->X+32,n->Y+32);
								Gen_Explode_Waitframe(this,n);
							}
							n5->X= n->X+32;
							n5->Y= n->Y+32;
						}
						Jump_Eye = false;
					}
					fire_timer= Rand(100,200);
			   }
			   else if(mode==1 && Jump_Eye){
					if(eye_pick==1){
						n2->Defense[NPCD_SWORD]=NPCDT_NONE;
						MoveToLink(n2);
					}
					else if(eye_pick==2){
						n3->Defense[NPCD_SWORD]=NPCDT_NONE;
						MoveToLink(n3);
					}
					else if(eye_pick==3){
						n4->Defense[NPCD_SWORD]=NPCDT_NONE;
						MoveToLink(n4);
					}
					else if(eye_pick==4){
						n5->Defense[NPCD_SWORD]=NPCDT_NONE;
						MoveToLink(n5);
					}
			   }
			   //Time to bounce towards Link
               else if(mode == 2 && mode_timer<=0){
                    Ghost_SetAllDefenses(n, NPCDT_NONE);
					//Set speed.
                    step = speed;
					//Change appearance
					if(Ghost_Data!=turncombo)
						Ghost_Data=turncombo;
					//Jump if not jumping
					if(Ghost_Jump==0)
						Ghost_Jump = 3;
					//In the air.
					while(Ghost_Jump>0){
						//Move towards Link
						if(Ghost_X>Link->X)Ghost_X-=step;
						else if(Ghost_X<Link->X)Ghost_X+=step;
						if(Ghost_Y>Link->Y)Ghost_Y-=step;
						else if(Ghost_Y<Link->Y)Ghost_Y+=step;
						Gen_Explode_Waitframe(this,n);
					}
               }
			   //Handles changing modees.
			   //All eyes are dead.
               if(n2->HP <=0 
					&& n3->HP <= 0 
					&& n4->HP <= 0 
					&& n5->HP <= 0 
					&& mode == 1){
                    mode = 2;
					mode_timer = 90;
               }
			   if(mode_timer>0)mode_timer--;
			   else mode_timer =0;
			   fire_timer--;
               Gen_Explode_Waitframe(this,n); 
          }
     }
}

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
					Screen->Line(2, Lightning1X[i], Lightning1Y[i], Lightning1X[i-1], Lightning1Y[i-1], 0x0B, 1, 0, 0, 0, 128);
					Screen->Line(2, Lightning2X[i], Lightning2Y[i], Lightning2X[i-1], Lightning2Y[i-1], 0x0B, 1, 0, 0, 0, 128);
					Screen->Line(2, Lightning3X[i], Lightning3Y[i], Lightning3X[i-1], Lightning3Y[i-1], 0x0B, 1, 0, 0, 0, 128);
					Screen->Line(2, Lightning4X[i], Lightning4Y[i], Lightning4X[i-1], Lightning4Y[i-1], 0x0B, 1, 0, 0, 0, 128);
					Screen->Line(2, Lightning1X[i] - 1, Lightning1Y[i], Lightning1X[i-1] - 1, Lightning1Y[i-1], 0x0B, 2, 0, 0, 0, 64);
					Screen->Line(2, Lightning2X[i] - 1, Lightning2Y[i], Lightning2X[i-1] - 1, Lightning2Y[i-1], 0x0B, 2, 0, 0, 0, 64);
					Screen->Line(2, Lightning3X[i] - 1, Lightning3Y[i], Lightning3X[i-1] - 1, Lightning3Y[i-1], 0x0B, 2, 0, 0, 0, 64);
					Screen->Line(2, Lightning4X[i] - 1, Lightning4Y[i], Lightning4X[i-1] - 1, Lightning4Y[i-1], 0x0B, 2, 0, 0, 0, 64);
					if (!Struck){
						if (lineBoxCollision(Lightning1X[i], Lightning1Y[i], Lightning1X[i-1], Lightning1Y[i-1], Link->X, Link->Y, Link->X+Link->HitWidth, Link->Y+Link->HitHeight, 0))
						{
							Struck = true;
							if (HitCounter <= 0) HitCounter = 10;
							continue;
						}	
						if (lineBoxCollision(Lightning2X[i], Lightning2Y[i], Lightning2X[i-1], Lightning2Y[i-1], Link->X, Link->Y, Link->X+Link->HitWidth, Link->Y+Link->HitHeight, 0))
						{
							Struck = true;
							if (HitCounter <= 0) HitCounter = 10;
							continue;
						}
						if (lineBoxCollision(Lightning3X[i], Lightning3Y[i], Lightning3X[i-1], Lightning3Y[i-1], Link->X, Link->Y, Link->X+Link->HitWidth, Link->Y+Link->HitHeight, 0))
						{
							Struck = true;
							if (HitCounter <= 0) HitCounter = 10;
							continue;
						}
						if (lineBoxCollision(Lightning4X[i], Lightning4Y[i], Lightning4X[i-1], Lightning4Y[i-1], Link->X, Link->Y, Link->X+Link->HitWidth, Link->Y+Link->HitHeight, 0))
						{
							Struck = true;
							if (HitCounter <= 0) HitCounter = 10;
							continue;
						}
					}
				}
			}
			if (Struck){
				eweapon e = FireEWeapon(EW_SCRIPT10, Link->X+InFrontX(Link->Dir, 10), Link->Y+InFrontY(Link->Dir, 10), 0, 0, 8, -1, -1, EWF_UNBLOCKABLE);
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
				Screen->Line(2, Lightning1X[i], Lightning1Y[i], Lightning1X[i-1], Lightning1Y[i-1], 0x0B, 1, 0, 0, 0, 128);
				Screen->Line(2, Lightning2X[i], Lightning2Y[i], Lightning2X[i-1], Lightning2Y[i-1], 0x0B, 1, 0, 0, 0, 128);
				Screen->Line(2, Lightning3X[i], Lightning3Y[i], Lightning3X[i-1], Lightning3Y[i-1], 0x0B, 1, 0, 0, 0, 128);
				Screen->Line(2, Lightning4X[i], Lightning4Y[i], Lightning4X[i-1], Lightning4Y[i-1], 0x0B, 1, 0, 0, 0, 128);
				Screen->Line(2, Lightning1X[i] - 1, Lightning1Y[i], Lightning1X[i-1] - 1, Lightning1Y[i-1], 0x01, 2, 0, 0, 0, 64);
				Screen->Line(2, Lightning2X[i] - 1, Lightning2Y[i], Lightning2X[i-1] - 1, Lightning2Y[i-1], 0x01, 2, 0, 0, 0, 64);
				Screen->Line(2, Lightning3X[i] - 1, Lightning3Y[i], Lightning3X[i-1] - 1, Lightning3Y[i-1], 0x01, 2, 0, 0, 0, 64);
				Screen->Line(2, Lightning4X[i] - 1, Lightning4Y[i], Lightning4X[i-1] - 1, Lightning4Y[i-1], 0x01, 2, 0, 0, 0, 64);
			}
			if (HitCounter > 0){
				if (Link->HP > 0)
					Screen->Rectangle(6, 0, 0, 256, 176, 1, 1, 0, 0, 0, true, OP_OPAQUE);
				HitCounter--;
			}
			Waitframe();
			for (i = 24; i > 0; i--){
				Screen->Line(2, Lightning1X[i], Lightning1Y[i], Lightning1X[i-1], Lightning1Y[i-1], 0x01, 1, 0, 0, 0, 128);
				Screen->Line(2, Lightning2X[i], Lightning2Y[i], Lightning2X[i-1], Lightning2Y[i-1], 0x01, 1, 0, 0, 0, 128);
				Screen->Line(2, Lightning3X[i], Lightning3Y[i], Lightning3X[i-1], Lightning3Y[i-1], 0x01, 1, 0, 0, 0, 128);
				Screen->Line(2, Lightning4X[i], Lightning4Y[i], Lightning4X[i-1], Lightning4Y[i-1], 0x01, 1, 0, 0, 0, 128);
				Screen->Line(2, Lightning1X[i] - 1, Lightning1Y[i], Lightning1X[i-1] - 1, Lightning1Y[i-1], 0x0B, 2, 0, 0, 0, 64);
				Screen->Line(2, Lightning2X[i] - 1, Lightning2Y[i], Lightning2X[i-1] - 1, Lightning2Y[i-1], 0x0B, 2, 0, 0, 0, 64);
				Screen->Line(2, Lightning3X[i] - 1, Lightning3Y[i], Lightning3X[i-1] - 1, Lightning3Y[i-1], 0x0B, 2, 0, 0, 0, 64);
				Screen->Line(2, Lightning4X[i] - 1, Lightning4Y[i], Lightning4X[i-1] - 1, Lightning4Y[i-1], 0x0B, 2, 0, 0, 0, 64);
			}
			Gen_Explode_Waitframe(this,ghost);
			for (i = 24; i > 0; i--){
				Screen->Line(2, Lightning1X[i], Lightning1Y[i], Lightning1X[i-1], Lightning1Y[i-1], 0x01, 1, 0, 0, 0, 128);
				Screen->Line(2, Lightning2X[i], Lightning2Y[i], Lightning2X[i-1], Lightning2Y[i-1], 0x01, 1, 0, 0, 0, 128);
				Screen->Line(2, Lightning3X[i], Lightning3Y[i], Lightning3X[i-1], Lightning3Y[i-1], 0x01, 1, 0, 0, 0, 128);
				Screen->Line(2, Lightning4X[i], Lightning4Y[i], Lightning4X[i-1], Lightning4Y[i-1], 0x01, 1, 0, 0, 0, 128);
				Screen->Line(2, Lightning1X[i] - 1, Lightning1Y[i], Lightning1X[i-1] - 1, Lightning1Y[i-1], 0x01, 2, 0, 0, 0, 64);
				Screen->Line(2, Lightning2X[i] - 1, Lightning2Y[i], Lightning2X[i-1] - 1, Lightning2Y[i-1], 0x01, 2, 0, 0, 0, 64);
				Screen->Line(2, Lightning3X[i] - 1, Lightning3Y[i], Lightning3X[i-1] - 1, Lightning3Y[i-1], 0x01, 2, 0, 0, 0, 64);
				Screen->Line(2, Lightning4X[i] - 1, Lightning4Y[i], Lightning4X[i-1] - 1, Lightning4Y[i-1], 0x01, 2, 0, 0, 0, 64);
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

void Gen_Explode_Waitframe(ffc this, npc ghost){
     if(!Ghost_Waitframe(this, ghost, false, false)){
	   Ghost_DeathAnimation(this, ghost, 2);
	   Quit();
     }
}

void Gen_Explode_Waitframes(ffc this, npc ghost,int frames){
     for(;frames>0;frames--)
		Gen_Explode_Waitframe(this,ghost);
}

const int NPC_INDEX_DELAY = 0;

void MoveToLink(npc ghost){
	if(ghost->Misc[NPC_INDEX_DELAY]==0){
		ghost->Misc[NPC_INDEX_DELAY]=3;
		if(ghost->X<Link->X)ghost->X+=(ghost->Step/100);
		else if(ghost->X>Link->X)ghost->X-=(ghost->Step/100);
		if(ghost->Y<Link->Y)ghost->Y+=(ghost->Step/100);
		else if(ghost->Y>Link->Y)ghost->Y-=(ghost->Step/100);
	}
	else if(ghost->Misc[NPC_INDEX_DELAY]>0)
		ghost->Misc[NPC_INDEX_DELAY]--;
}

void MoveToXY(npc ghost,int X, int Y){
	if(ghost->Misc[NPC_INDEX_DELAY]==0){
		ghost->Misc[NPC_INDEX_DELAY]=3;
		if(ghost->X<X)ghost->X++;
		else if(ghost->X>X)ghost->X--;
		if(ghost->Y<Y)ghost->Y++;
		else if(ghost->Y>Y)ghost->Y--;
	}
	else if(ghost->Misc[NPC_INDEX_DELAY]>0)
		ghost->Misc[NPC_INDEX_DELAY]--;
}
	
void ShiftArray(int Array){
	for (int i = SizeOfArray(Array)-1; i > 0; i--)
		Array[i] = Array[i-1];
}

// Function to see if a box has collided with a line
bool lineBoxCollision(int lineX1, int lineY1, int lineX2, int lineY2, int boxX1, int boxY1, int boxX2, int boxY2, int boxBorder)
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
} //! End of lineBoxCollision