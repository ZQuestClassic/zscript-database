const int LW_MOOSHITEM_MELEE = 31; //Weapon type for melee weapons (Script 1 by default)
const int TIL_INVISIBLE = 65260; //Invisible tile

const int SFX_MOOSHITEM_MELEE = 30; //Sound of a MooshItem melee swing
const int SFX_MOOSHITEM_BLOCK = 6; //Sound of a MooshItem blocking a weapon
const int SFX_MOOSHITEM_CHARGE = 35; //Sound of a MooshItem charging up
const int SFX_MOOSHITEM_WALLBOUNCE = 6; //Sound of a MooshItem projectile bouncing off a wall
const int SFX_MOOSHITEM_HP_COST = 19; //Sound that plays when a MooshItem takes Link's HP

const int MOOSHITEM_MP_DRAIN_FREQ = 10; //How many frames it takes for MP draining items to take a charge
const float MOOSHITEM_MP_DRAIN_RATIO = 0.5; //How much subsequent ticks of MP costs drain relative to the initial one

//Type 0: Normal Shot (V)
//Type 1: Normal Shot (Line)
//Type 2: Sine Wave
//Type 3: Homing
//Type 4: Charge Shot
//Type 5: Circle Shield
//Type 6: Breath
//Type 7: Spread Shield
//Type 8: Bouncing Shot

//Moosh Item Flag Constants (Don't change these)
const int MIF_4WAY         = 0000000001b; //1 - Sprites have four directions
const int MIF_8WAY         = 0000000010b; //2 - Sprites have eight directions
const int MIF_360WAY       = 0000000100b; //4 - Sprite rotates 360 degrees and faces left by default
const int MIF_2X2          = 0000001000b; //8 - Sprite is 2x2
const int MIF_PIERCE       = 0000010000b; //16 - Weapon pierces enemies
const int MIF_ANIMSTAB     = 0000100000b; //32 - Has a stab animation (Sprite+1)
const int MIF_ANIMSLASH    = 0001000000b; //64 - Has a slash animation (Sprite+1)
const int MIF_8WAYAIM      = 0010000000b; //128 - Can be aimed in 8 directions
const int MIF_EXPLODEDEATH = 0100000000b; //256 - Explodes when the weapon dies
const int MIF_DRAINMP      = 1000000000b; //512 - Drains MP over time (for circle shield/breath)

//This is the main item script which calls the other two FFCs when the item is used
item script MooshItem{
	void run(int dummy, int ID_mpCost, int type_step, int wType_maxShot, int arg1_arg2, int arg3_arg4, int sprite_sfx, int flags){
		int handler[] = "MooshItem_Handler";
		int anim[] = "MooshItem_Animations";
		
		int type = MooshItem_LeftArg(type_step);
		int maxShot = MooshItem_RightArg(wType_maxShot);
		//Attacks that drain the MP bar over time can't be used twice on a screen
		if(flags&MIF_DRAINMP) 
			maxShot = 0;
		
		int args[8];
		int ID = MooshItem_LeftArg(ID_mpCost);
		int mpCost = MooshItem_RightArg(ID_mpCost);
		
		//Prevent the script running by holding the item button
		if(!MooshItem_PressButtonItem(ID))
			Quit();
		//Prevent the script running if not enough MP (charge shot is an exception)
		if(!MooshItem_CanTakeResource(ID, mpCost)&&type!=4)
			Quit();
		if(MooshItem_NumType(type)<=maxShot){
			if(flags&MIF_ANIMSTAB||flags&MIF_ANIMSLASH){
				//Stab + Slash = Z3 slash
				if(flags&MIF_ANIMSTAB&&flags&MIF_ANIMSLASH)
					args[0] = 2;
				else if(flags&MIF_ANIMSLASH)
					args[0] = 1;
				else
					args[0] = 0;
				args[1] = ID_mpCost;
				args[2] = type_step;
				args[3] = wType_maxShot;
				args[4] = arg1_arg2;
				args[5] = arg3_arg4;
				args[6] = sprite_sfx;
				args[7] = flags;
				RunFFCScript(Game->GetFFCScript(anim), args);
			}
			else{
				Link->Action = LA_ATTACKING;
				args[0] = ID_mpCost;
				args[1] = type_step;
				args[2] = wType_maxShot;
				args[3] = arg1_arg2;
				args[4] = arg3_arg4;
				args[5] = sprite_sfx;
				args[6] = flags;
				RunFFCScript(Game->GetFFCScript(handler), args);
			}
		}
	}
	bool MooshItem_CanTakeResource(int ID, int mpCost){
		if(mpCost==0)
			return true;
		itemdata itemdat = Game->LoadItemData(ID);
		if(itemdat->Counter>-1){ //If a counter is set
			if(itemdat->Counter==CR_LIFE){ //If the counter is health, don't allow it to hit 0
				if(Game->Counter[itemdat->Counter]<=mpCost)
					return false;
			}
			else if(Game->Counter[itemdat->Counter]<mpCost)
				return false;
		}
		else{ //Otherwise it's a regular magic cost
			//Only magic costs are affected by 1/2 magic
			mpCost = mpCost*Game->Generic[GEN_MAGICDRAINRATE];
			if(Link->MP<mpCost)
				return false;
		}
		return true;
	}
}

//Returns the component of an argument left of the decimal point
int MooshItem_LeftArg(float i){
	return Floor(i);
}

//Returns the component of an argument right of the decimal point
int MooshItem_RightArg(float i){
	int left = MooshItem_LeftArg(i);
	return (i-left)*10000;
}

//Count the number of active weapon scripts of a certain type
int MooshItem_NumType(int checktype){
	int handler[] = "MooshItem_Handler";
	int slot = Game->GetFFCScript(handler);
	
	int count;
	for(int i=1; i<=32; i++){
		ffc f = Screen->LoadFFC(i);
		if(f->Script==slot){
			int type = MooshItem_LeftArg(f->InitD[1]);
			if(type==checktype)
				count++;
		}
	}
	return count;
}

//Returns true if Link is pressing an item's button that frame
bool MooshItem_PressButtonItem(int id){
	return (GetEquipmentA()==id&&Link->PressA)||(GetEquipmentB()==id&&Link->PressB);
}

//Returns true if Link is holding down an item's button
bool MooshItem_InputButtonItem(int id){
	return (GetEquipmentA()==id&&Link->InputA)||(GetEquipmentB()==id&&Link->InputB);
}

//Get the difference between two angles in degrees
int MooshItem_AngDiff(int angle1, int angle2){
	
	// Get the difference between the two angles
	float dif = WrapDegrees(angle2) - WrapDegrees(angle1);
	
	// Compensate for the difference being outside of normal bounds
	if(dif >= 180)
		dif -= 360;
	else if(dif <= -1 * 180)
		dif += 360;
		
	return dif;
}

//This FFC script contains most of the item behaviors
ffc script MooshItem_Handler{
	void run(int ID_mpCost, int type_step, int wType_maxShot, int arg1_arg2, int arg3_arg4, int sprite_sfx, int flags){
		int i; int j; int k; int m;
		int x; int y;
		
		//First we split a bunch of the arguments into their two halves
		int ID = MooshItem_LeftArg(ID_mpCost);
		int mpCost = MooshItem_RightArg(ID_mpCost);
		
		int type = MooshItem_LeftArg(type_step);
		int step = MooshItem_RightArg(type_step);
		
		int wType = MooshItem_LeftArg(wType_maxShot);
		if(wType==0)
			wType = LW_SCRIPT1;
		int maxShot = MooshItem_RightArg(wType_maxShot);
		
		int arg1 = MooshItem_LeftArg(arg1_arg2);
		int arg2 = MooshItem_RightArg(arg1_arg2);
		
		int arg3 = MooshItem_LeftArg(arg3_arg4);
		int arg4 = MooshItem_RightArg(arg3_arg4);
		
		int sprite = MooshItem_LeftArg(sprite_sfx);
		int sfx = MooshItem_RightArg(sprite_sfx);
		
		itemdata itemdat = Game->LoadItemData(ID);
		
		if(type!=4){ //Charge shot calculates MP differently
			//Take MP / Counter if applicable
			if(!MooshItem_CanTakeResource(ID, mpCost))
				Quit();
			else
				MooshItem_TakeResource(ID, mpCost);
		}
		
		//Get Link's direction
		int LinkAng;
		int angle;
		if(Link->Dir==DIR_UP)
			LinkAng = -90;
		else if(Link->Dir==DIR_DOWN)
			LinkAng = 90;
		else if(Link->Dir==DIR_LEFT)
			LinkAng = 180;
		//Update the direction if the weapon has 8-way aiming
		if(flags&MIF_8WAYAIM){
			LinkAng = MooshItem_8WayAimAngle(LinkAng);
		}
		
		//Look at all this garbage!
		lweapon lgroup[256];
		lweapon l;
		int lTimer[256];
		int lTile[256];
		int lAng[256];
		int lType[256];
		int lMisc1[256];
		int lMisc2[256];
		int lDecay[256];
		int lFlags[256];
		int lACounter[256];
		int lNumFrames[256];
		int lASpeed[256];
		int lBombSP[256];
		int lLastX[256];
		int lLastY[256];
		int vars[17] = {0, lTimer, lTile, lAng, lType, lMisc1, lMisc2, lDecay, lFlags, lACounter, lNumFrames, lASpeed, 0, lLastX, lLastY, itemdat->Power*2, 0};
		
		//Bomb blasts get converted into a weapon with no collsion that regularly drops them
		if(wType==LW_BOMBBLAST){
			wType = LW_MOOSHITEM_MELEE;
			vars[12] = 1;
		}
		else if(wType==LW_SBOMBBLAST){
			wType = LW_MOOSHITEM_MELEE;
			vars[12] = 2;
		}
		
		if(type==0){ //Normal (V)
			//Arg 1 = Decay
			//Arg 2 = NumShots
			//Arg 3 = Spread
			//Arg 4 = Step 2
			if(arg2==0)
				arg2 = 1;
			if(arg3==0&&arg2>1)
				arg3 = 60;
			if(arg4==0)
				arg4 = step;
				
			x = Link->X+VectorX(12, LinkAng);
			y = Link->Y+VectorY(12, LinkAng);
			for(i=0; i<arg2; i++){
				angle = LinkAng-arg3/2+(i/(arg2-1))*arg3;
				if(arg2==1)
					angle = LinkAng;
				l = MooshItem_FireLWeapon(wType, x, y, angle, step-(step-arg4)*Abs((i/(arg2-1)*2)-1), itemdat->Power*2, sprite, sfx, flags);
				j = MooshItem_AddLWeapon(vars, lgroup, l, 0, angle, flags);
				lDecay[j] = arg1;
			}
			while(vars[0]>0){
				MooshItem_UpdateLWeapons(vars, lgroup);
				Waitframe();
			}
		}
		else if(type==1){ //Normal (Line)
			//Arg 1 = Decay
			//Arg 2 = NumShots
			//Arg 3 = Spread
			//Arg 4 = Step 2
			if(arg2==0)
				arg2 = 1;
			if(arg4==0)
				arg4 = step;
				
			x = Link->X+VectorX(12, LinkAng);
			y = Link->Y+VectorY(12, LinkAng);
			for(i=0; i<arg2; i++){
				angle = LinkAng+Rand(-arg3/2, arg3/2);
				if(arg2==1)
					angle = LinkAng;
				l = MooshItem_FireLWeapon(wType, x, y, angle, step-(step-arg4)*(i/(arg2-1)), itemdat->Power*2, sprite, sfx, flags);
				j = MooshItem_AddLWeapon(vars, lgroup, l, 0, angle, flags);
				lDecay[j] = arg1;
			}
			while(vars[0]>0){
				MooshItem_UpdateLWeapons(vars, lgroup);
				Waitframe();
			}
		}
		else if(type==2){ //Sine Wave
			//Arg 1 = Amplitude
			//Arg 2 = Frequency
			//Arg 3 = NumShots
			//Arg 4 = Repeat
			if(arg1==0)
				arg1 = 16;
			if(arg2==0)
				arg2 = 32;
			if(arg3==0)
				arg3 = 1;
			do{
				for(i=0; i<arg3; i++){
					LinkAng = 0;
					if(Link->Dir==DIR_UP)
						LinkAng = -90;
					else if(Link->Dir==DIR_DOWN)
						LinkAng = 90;
					else if(Link->Dir==DIR_LEFT)
						LinkAng = 180;
					if(flags&MIF_8WAYAIM){
						LinkAng = MooshItem_8WayAimAngle(LinkAng);
					}
					x = Link->X+VectorX(12, LinkAng);
					y = Link->Y+VectorY(12, LinkAng);
					l = MooshItem_FireLWeapon(wType, x, y, LinkAng, step, itemdat->Power*2, sprite, sfx, flags);
					j = MooshItem_AddLWeapon(vars, lgroup, l, 1, angle, flags);
					lMisc1[j] = (Cond(i%2==0, 1, -1)*(arg1+Floor(i/2)*16))/2;
					lMisc2[j] = arg2;
					lTimer[j] += (45/arg2*(step/100))*Floor(i/2);
				}
				if(arg4>0){
					k = 16/(step/100);
					for(j=0; j<k; j++){
						MooshItem_UpdateLWeapons(vars, lgroup);
						NoAction();
						Waitframe();
					}
				}
				arg4--;
			}while(arg4>0)
				
			while(vars[0]>0){
				MooshItem_UpdateLWeapons(vars, lgroup);
				Waitframe();
			}
		}
		else if(type==3){ //Homing
			//Arg 1 = Decay
			//Arg 2 = TurnSpeed
			//Arg 3 = NumShots
			//Arg 4 = Spread
			if(arg2==0)
				arg2 = 100;
			if(arg4==0)
				arg4 = 60;
				
			x = Link->X+VectorX(12, LinkAng);
			y = Link->Y+VectorY(12, LinkAng);
			for(i=0; i<arg3; i++){
				angle = LinkAng-arg4/2+(i/(arg3-1))*arg4;
				if(arg3==1)
					angle = LinkAng;
				l = MooshItem_FireLWeapon(wType, x, y, angle, step, itemdat->Power*2, sprite, sfx, flags);
				j = MooshItem_AddLWeapon(vars, lgroup, l, 2, angle, flags);
				lDecay[j] = arg1;
				lMisc1[j] = arg2;
			}
			while(vars[0]>0){
				MooshItem_UpdateLWeapons(vars, lgroup);
				Waitframe();
			}
		}
		else if(type==4){ //Charge shot
			//Arg 1 = Charge time
			//Arg 2 = Charge Type: 0 - 2x2 weapon, 1 - spread shot, 2 - homing shots
			//Arg 3 = Sprite
			//Arg 4 = Damage
			if(arg1==0)
				arg1 = 90;
			int chargeCounter = 0;
			while(MooshItem_InputButtonItem(ID)){
				i = (i+1)%360;
				if(i%3==0){
					Link->InputUp = false;
					Link->InputDown = false;
					Link->InputLeft = false;
					Link->InputRight = false;
				}
				if(!MooshItem_CanTakeResource(ID, mpCost))
					chargeCounter = 0;
				if(chargeCounter<arg1){
					chargeCounter++;
					if(chargeCounter==arg1)
						Game->PlaySound(SFX_MOOSHITEM_CHARGE);
				}
				else{
					DrawTile(3, Link->X+Link->DrawXOffset, Link->Y+Link->DrawYOffset-Link->Z, Link->Tile, 1, 1, 9-((Floor(i/2)%32)>>1), -1, -1, 0, 0, 0, Link->Flip, true, 128);
				}
				Waitframe();
			}
			LinkAng = 0;
			if(Link->Dir==DIR_UP)
				LinkAng = -90;
			else if(Link->Dir==DIR_DOWN)
				LinkAng = 90;
			else if(Link->Dir==DIR_LEFT)
				LinkAng = 180;
			if(flags&MIF_8WAYAIM){
				LinkAng = MooshItem_8WayAimAngle(LinkAng);
			}
			x = Link->X+VectorX(12, LinkAng);
			y = Link->Y+VectorY(12, LinkAng);
			if(chargeCounter<arg1){
				l = MooshItem_FireLWeapon(wType, x, y, LinkAng, step, itemdat->Power*2, sprite, sfx, flags);
				j = MooshItem_AddLWeapon(vars, lgroup, l, 0, angle, flags);
			}
			else{
				if(!MooshItem_CanTakeResource(ID, mpCost))
					Quit();
				else
					MooshItem_TakeResource(ID, mpCost);
				if(arg2==0){ //Big shot
					l = MooshItem_FireLWeapon(wType, x, y, LinkAng, step, arg4*2, arg3, sfx, flags|MIF_2X2);
					j = MooshItem_AddLWeapon(vars, lgroup, l, 0, angle, flags|MIF_2X2);
				}
				else if(arg2==1){ //Spread shot
					if(arg3==0)
						arg3 = 3;
					if(arg4==0)
						arg4 = 45;
					for(i=0; i<12; i++){
						angle = LinkAng-arg4/2+(i/(12-1))*arg4;
						l = MooshItem_FireLWeapon(wType, x, y, angle, step, arg4*2, arg3, sfx, flags);
						j = MooshItem_AddLWeapon(vars, lgroup, l, 0, angle, flags);
					}
				}
				else if(arg2==2){ //Homing
					for(i=0; i<12; i++){
						angle = LinkAng+(360/12)*i;
						l = MooshItem_FireLWeapon(wType, x, y, angle, step, arg4*2, arg3, sfx, flags);
						j = MooshItem_AddLWeapon(vars, lgroup, l, 2, angle, flags);
						lMisc1[j] = 1000;
					}
				}
			}
			while(vars[0]>0){
				MooshItem_UpdateLWeapons(vars, lgroup);
				Waitframe();
			}
		}
		else if(type==5){ //Circular Shield
			//Arg 1 = NumShots
			//Arg 2 = Distance
			//Arg 3 = AngOffset
			//Arg 4 = BlockFlags
			if(arg1==0)
				arg1 = 6;
			if(arg2==0)
				arg2 = 24;
			if(MooshItem_NumType(type)>1){
				arg2 += Max(8, arg2-16)*MooshItem_NumType(type);
				if(MooshItem_NumType(type)%2==0){
					step = -step;
					arg3 = -arg3;
				}
			}
			x = Link->X;
			y = Link->Y;
			vars[16] = 1;
			for(i=0; i<arg1; i++){
				l = MooshItem_FireLWeapon(wType, x, y, 0, 0, itemdat->Power*2, sprite, sfx, flags);
				j = MooshItem_AddLWeapon(vars, lgroup, l, 3, 0, flags);
				lMisc1[j] = arg4;
			}
			for(j=0; j<16; j++){
				LinkAng = WrapDegrees(LinkAng+step/100);
				for(i=0; i<arg1; i++){
					x = Link->X;
					y = Link->Y;
					if(lgroup[i]->isValid()){
						lgroup[i]->HitXOffset = VectorX(arg2*(j/16), LinkAng+360/arg1*i+arg3); 
						lgroup[i]->HitYOffset = VectorY(arg2*(j/16), LinkAng+360/arg1*i);
						lgroup[i]->DrawXOffset = lgroup[i]->HitXOffset;
						lgroup[i]->DrawYOffset = lgroup[i]->HitYOffset;
						lgroup[i]->X = x;
						lgroup[i]->Y = y;
						lgroup[i]->Z = Link->Z;
						if(arg3<=0)
							lAng[i] = LinkAng+360/arg1*i+90;
						else
							lAng[i] = LinkAng+360/arg1*i-90;
					}
				}
				MooshItem_UpdateLWeapons(vars, lgroup);
				Waitframe();
			}
			k = 0;
			while(vars[0]>0){
				if(flags&MIF_DRAINMP){
					k++;
					if(k>=MOOSHITEM_MP_DRAIN_FREQ){
						k = 0;
						if(MooshItem_CanTakeResource(ID, Max(1, mpCost*MOOSHITEM_MP_DRAIN_RATIO)))
							MooshItem_TakeResource(ID, Max(1, mpCost*MOOSHITEM_MP_DRAIN_RATIO));
						else
							break;
					}
					if(MooshItem_PressButtonItem(ID)){
						NoAction();
						break;
					}
				}
				LinkAng = WrapDegrees(LinkAng+step/100);
				int activeWeapons = 0;
				for(i=0; i<arg1; i++){
					x = Link->X; 
					y = Link->Y; 
					if(lgroup[i]->isValid()){
						lgroup[i]->HitXOffset = VectorX(arg2, LinkAng+360/arg1*i+arg3); 
						lgroup[i]->HitYOffset = VectorY(arg2, LinkAng+360/arg1*i);
						lgroup[i]->DrawXOffset = lgroup[i]->HitXOffset;
						lgroup[i]->DrawYOffset = lgroup[i]->HitYOffset;
						lgroup[i]->X = x;
						lgroup[i]->Y = y;
						lgroup[i]->Z = Link->Z;
						if(arg3<=0)
							lAng[i] = LinkAng+360/arg1*i+90;
						else
							lAng[i] = LinkAng+360/arg1*i-90;
						//Count how many of the weapons are still alive.
						//This is to fix a bug that was caused by another bugfix.
						activeWeapons++;
					}
				}
				if(activeWeapons==0)
					break;
				MooshItem_UpdateLWeapons(vars, lgroup);
				Waitframe();
			}
			for(j=0; j<16; j++){
				LinkAng = WrapDegrees(LinkAng+step/100);
				for(i=0; i<arg1; i++){
					x = Link->X;
					y = Link->Y;
					if(lgroup[i]->isValid()){
						lgroup[i]->HitXOffset = VectorX(arg2-arg2*(j/16), LinkAng+360/arg1*i+arg3); 
						lgroup[i]->HitYOffset = VectorY(arg2-arg2*(j/16), LinkAng+360/arg1*i);
						lgroup[i]->DrawXOffset = lgroup[i]->HitXOffset;
						lgroup[i]->DrawYOffset = lgroup[i]->HitYOffset;
						lgroup[i]->X = x;
						lgroup[i]->Y = y;
						lgroup[i]->Z = Link->Z;
						if(arg3<=0)
							lAng[i] = LinkAng+360/arg1*i+90;
						else
							lAng[i] = LinkAng+360/arg1*i-90;
					}
				}
				MooshItem_UpdateLWeapons(vars, lgroup);
				Waitframe();
			}
			for(i=0; i<arg1; i++){
				if(lgroup[i]->isValid())
					lgroup[i]->DeadState = 0;
			}
		}
		else if(type==6){ //Breath
			//Arg 1 = Decay
			//Arg 2 = Spread
			//Arg 3 = Special Firing
			//Arg 4 = Special Arg
			k = 0;
			m = 0;
			do{
				if(flags&MIF_DRAINMP){
					k++;
					if(k>=MOOSHITEM_MP_DRAIN_FREQ){
						k = 0;
						if(MooshItem_CanTakeResource(ID, Max(1, mpCost*MOOSHITEM_MP_DRAIN_RATIO)))
							MooshItem_TakeResource(ID, Max(1, mpCost*MOOSHITEM_MP_DRAIN_RATIO));
						else
							break;
					}
				}
				m++;
				if(m>=4){
					m = 0;
					
					LinkAng = 0;
					if(Link->Dir==DIR_UP)
						LinkAng = -90;
					else if(Link->Dir==DIR_DOWN)
						LinkAng = 90;
					else if(Link->Dir==DIR_LEFT)
						LinkAng = 180;
					if(flags&MIF_8WAYAIM){
						LinkAng = MooshItem_8WayAimAngle(LinkAng);
					}
					
					x = Link->X+VectorX(12, LinkAng);
					y = Link->Y+VectorY(12, LinkAng);
					if(arg3==0){ //Normal shot
						if(arg4==0)
							arg4 = step;
						angle = LinkAng+Rand(-arg2/2, arg2/2);
						l = MooshItem_FireLWeapon(wType, x, y, angle, Rand(arg4, step), itemdat->Power*2, sprite, sfx, flags);
						j = MooshItem_AddLWeapon(vars, lgroup, l, 0, angle, flags);
						lDecay[j] = arg1;
					}
					else if(arg3==1){ //Sine Wave
						if(arg4==0)
							arg4 = 16;
						angle = LinkAng+Rand(-arg2/2, arg2/2);
						l = MooshItem_FireLWeapon(wType, x, y, angle, step, itemdat->Power*2, sprite, sfx, flags);
						j = MooshItem_AddLWeapon(vars, lgroup, l, 1, angle, flags);
						lDecay[j] = arg1;
						lMisc1[j] = arg4*Choose(-1, 1);
						lMisc2[j] = arg4*2;
					}
					else if(arg3==2){ //Homing
						if(arg4==0)
							arg4 = 1000;
						angle = LinkAng+Rand(-arg2/2, arg2/2);
						l = MooshItem_FireLWeapon(wType, x, y, angle, step, itemdat->Power*2, sprite, sfx, flags);
						j = MooshItem_AddLWeapon(vars, lgroup, l, 2, angle, flags);
						lDecay[j] = arg1;
						lMisc1[j] = arg4;
					}
					else if(arg3==3){ //Wall Bounce
						if(arg4==0)
							arg4 = 3;
						angle = LinkAng+Rand(-arg2/2, arg2/2);
						l = MooshItem_FireLWeapon(wType, x, y, angle, step, itemdat->Power*2, sprite, sfx, flags);
						j = MooshItem_AddLWeapon(vars, lgroup, l, 4, angle, flags);
						lDecay[j] = arg1;
						lMisc1[j] = arg4;
					}
				}
				MooshItem_UpdateLWeapons(vars, lgroup);
				NoAction();
				Waitframe();
			}while(MooshItem_InputButtonItem(ID))
			
		while(vars[0]>0){
				MooshItem_UpdateLWeapons(vars, lgroup);
				Waitframe();
			}
		}
		else if(type==7){ //Spread Shield
			//Arg 1 = Decay
			//Arg 2 = NumShots
			//Arg 3 = Spread
			//Arg 4 = BlockFlags
			if(arg2==0)
				arg2 = 1;
			if(arg3==0&&arg2>1)
				arg3 = 60;
			if(arg4==0)
				arg4 = 1023;
				
			x = Link->X+VectorX(12, LinkAng);
			y = Link->Y+VectorY(12, LinkAng);
			for(i=0; i<arg2; i++){
				angle = LinkAng-arg3/2+(i/(arg2-1))*arg3;
				if(arg2==1)
					angle = LinkAng;
				l = MooshItem_FireLWeapon(wType, x, y, angle, step, itemdat->Power*2, sprite, sfx, flags);
				j = MooshItem_AddLWeapon(vars, lgroup, l, 3, angle, flags);
				lDecay[j] = arg1;
				lMisc1[j] = arg4;
			}
			while(vars[0]>0){
				MooshItem_UpdateLWeapons(vars, lgroup);
				Waitframe();
			}
		}
		else if(type==8){ //Bouncing Gem
			//Arg 1 = Decay
			//Arg 2 = NumShots
			//Arg 3 = Spread
			//Arg 4 = Bounces
			x = Link->X+VectorX(12, LinkAng);
			y = Link->Y+VectorY(12, LinkAng);
			for(i=0; i<arg2; i++){
				angle = LinkAng+Rand(-arg3/2, arg3/2);
				k = 0;
				if(arg2>1)
					k = step*(Rand(5)*0.125);
				l = MooshItem_FireLWeapon(wType, x, y, angle, step+k, itemdat->Power*2, sprite, sfx, flags);
				j = MooshItem_AddLWeapon(vars, lgroup, l, 4, angle, flags);
				lDecay[j] = arg1;
				lMisc1[j] = arg4;
			}
			while(vars[0]>0){
				MooshItem_UpdateLWeapons(vars, lgroup);
				Waitframe();
			}
		}
	}
	//This function is used to shoot projectile lweapons used by the script
	lweapon MooshItem_FireLWeapon(int type, int x, int y, int angle, int step, int damage, int sprite, int sfx, int flags){
		lweapon l = CreateLWeaponAt(type, x, y);
		l->Z = Link->Z;
		l->Angular = true;
		l->Angle = DegtoRad(angle);
		l->Dir = AngleDir4(WrapDegrees(angle));
		l->Step = step;
		l->Damage = damage;
		l->UseSprite(sprite);
		//Adjust the hitbox if 2x2
		if(flags&MIF_2X2){
			l->Extend = 3;
			l->HitWidth = 32;
			l->HitHeight = 32;
			l->TileWidth = 2;
			l->TileHeight = 2;
			l->X-=8;
			l->Y-=8;
		}
		Game->PlaySound(sfx);
		return l;
	}
	//This function is the main guts of the script
	//It updates all the weapons every frame
	void MooshItem_UpdateLWeapons(int vars, lweapon lgroup){
		int i; int j; int k; int m; int o;
		int x; int y;
		int dir;
		
		//vars[0] = Total weapons onscreen
		int lTimer = vars[1];
		int lTile = vars[2];
		int lAng = vars[3];
		int lType = vars[4];
		int lMisc1 = vars[5];
		int lMisc2 = vars[6];
		int lDecay = vars[7];
		int lFlags = vars[8];
		int lACounter = vars[9];
		int lNumFrames = vars[10];
		int lASpeed = vars[11];
		//vars[12] = BombSP
		int lLastX = vars[13];
		int lLastY = vars[14];
		//vars[15] = Weapon Damage
		//vars[16] = Prevent weapon clear
		//Only cycle through weapons currently in use to save iterations
		for(i=0; i<vars[0]; i++){
			//If the weapon itself is there, run its behavior
			if(lgroup[i]->isValid()){
				lTimer[i] = (lTimer[i]+1)%360;
				x = lgroup[i]->X;
				y = lgroup[i]->Y;
				if(lType[i]==1){ //Sine Wave
					k = RadtoDeg(lgroup[i]->Angle);
					o = lgroup[i]->Step/100;
					j = lMisc1[i]*Sin((180/lMisc2[i]*o)*lTimer[i]);
					lgroup[i]->HitXOffset = VectorX(j, k+90);
					lgroup[i]->HitYOffset = VectorY(j, k+90);
					//Weapons with -1000 draw offset are being drawn by the script instead of ZC.
					//Thus they don't need draw offsets to be applied.
					if(lgroup[i]->DrawYOffset>-1000){
						lgroup[i]->DrawXOffset = lgroup[i]->HitXOffset;
						lgroup[i]->DrawYOffset = lgroup[i]->HitYOffset;
					}
					//Adding hit offsets to X and Y affects where the script draws them in special cases
					x += lgroup[i]->HitXOffset;
					y += lgroup[i]->HitYOffset;
					//Here we predict the weapon's position in the next frame so 360 rotating ones are angled right
					m = lMisc1[i]*Sin((180/lMisc2[i]*o)*(lTimer[i]+1));
					int nextX = lgroup[i]->X+VectorX(Max(1, o), k)+VectorX(m, k+90);
					int nextY = lgroup[i]->Y+VectorY(Max(1, o), k)+VectorY(m, k+90);
					lAng[i] = Angle(x, y, nextX, nextY);
				}
				else if(lType[i]==2){ //Homing
					k = MooshItem_Homing_TargetAngle(vars, lAng[i], lgroup[i]);
					j = MooshItem_AngDiff(lAng[i], k);
					//If the distance to the target angle is less than the turn speed, turn it
					if(Abs(j)>lMisc1[i]/100){
						lAng[i] = WrapDegrees(lAng[i]+Sign(j)*(lMisc1[i]/100));
					}
					//Otherwise set the angle to the target angle
					else
						lAng[i] = k;
					lgroup[i]->Angle = DegtoRad(lAng[i]);
				}
				else if(lType[i]==3){ //Shield
					//Once again setting offsets to x and y for special cases
					x += lgroup[i]->HitXOffset;
					y += lgroup[i]->HitYOffset;
					if(lMisc1[i]>0){ //If the shield has block flags, run the block weapons function
						if(lFlags[i]&MIF_PIERCE)
							MooshItem_BlockWeapons(vars, lgroup[i], i, false);
						else
							MooshItem_BlockWeapons(vars, lgroup[i], i, true);
					}
				}
				else if(lType[i]==4){ //Wall bounce
					//Turn angle into vX and vY components
					int vX = VectorX(10, lAng[i]);
					int vY = VectorY(10, lAng[i]);
					o = Max(lgroup[i]->Step/100, 1);
					bool bounce = false;
					//Flip if they hit a wall
					if((vX<0&&!MooshItem_CanWalk(lgroup[i], DIR_LEFT, o)) || (vX>0&&!MooshItem_CanWalk(lgroup[i], DIR_RIGHT, o))){
						vX = -vX;
						
						bounce = true;
					}
					if((vY<0&&!MooshItem_CanWalk(lgroup[i], DIR_UP, o)) || (vY>0&&!MooshItem_CanWalk(lgroup[i], DIR_DOWN, o))){
						vY = -vY;
						
						bounce = true;
					}
					//If a wall was hit, update the angle
					if(bounce){
						Game->PlaySound(SFX_MOOSHITEM_WALLBOUNCE);
						lAng[i] = Angle(0, 0, vX, vY);
						lgroup[i]->Angle = DegtoRad(lAng[i]);
						lMisc1[i]--;
						if(lMisc1[i]<=0){
							lgroup[i]->DeadState = 0;
							lFlags[i] &= ~MIF_PIERCE; //Pierce messes with killing weapons here so we take it away when a weapon should be killed
						}
					}
				}
				int tile = lgroup[i]->Tile;
				//OH BOY OH BOY BEAM WEAPONS
				//We have a special way of handling these. Because ZC is so intent on drawing the beam shards, I had to clear the weapon's sprite completely.
				//Then we redraw what it should be with scripts.
				if(lgroup[i]->ID==LW_BEAM){
					//Detect any uncleared beams.
					if(lgroup[i]->OriginalTile!=TIL_INVISIBLE){
						lACounter[i] = 0;
						lgroup[i]->OriginalTile = TIL_INVISIBLE;
						lgroup[i]->Tile = lgroup[i]->OriginalTile;
						lgroup[i]->NumFrames = 0;
						lgroup[i]->ASpeed = 0;
					}
					else{
						lACounter[i] = (lACounter[i]+1)%(lNumFrames[i]*lASpeed[i]);
						tile = lTile[i]+Clamp(Floor(lACounter[i]/lASpeed[i]), 0, lNumFrames[i]-1)*lgroup[i]->TileWidth;
					}
					//When the beam shards happen, kill the weapon early so drawing doesn't bug out
					if(lgroup[i]->DeadState>0)
						lgroup[i]->DeadState = 0;
				}
				//These weapons have special collision exceptions because they can cause friendly fire damage
				else if(lgroup[i]->ID==LW_FIRE||lgroup[i]->ID==LW_REFBEAM||lgroup[i]->ID==LW_REFMAGIC||lgroup[i]->ID==LW_REFROCK){
					if(MooshItem_LinkCollisionNoZ(lgroup[i]))
						lgroup[i]->CollDetection = false;
					else
						lgroup[i]->CollDetection = true;
				}
				int frames = Max(1, lNumFrames[i]);
				//These all handle redrawing of beam animations and setting the directions of other weapon types based on angle so they animate correctly.
				if(lFlags[i]&MIF_4WAY){ //4 way animations
					dir = AngleDir4(WrapDegrees(lAng[i]));
					if(lType[i]!=3)
						lgroup[i]->Dir = dir;
					j = (lgroup[i]->Tile-lTile[i])%frames;
					if(lgroup[i]->ID!=LW_BEAM&&lgroup[i]->OriginalTile!=lTile[i]+frames*dir){
						lgroup[i]->OriginalTile = lTile[i]+frames*dir;
						lgroup[i]->Tile = lgroup[i]->OriginalTile+j;
					}
					if(lgroup[i]->ID==LW_BEAM&&lgroup[i]->DeadState==WDS_ALIVE){
						tile += frames*dir;
						if(Link->HP>0){
							if(lFlags[i]&MIF_2X2)
								Screen->DrawTile(2, x, y-2-lgroup[i]->Z, tile, 2, 2, lgroup[i]->CSet, -1, -1, 0, 0, 0, 0, true, 128);
							else 
								Screen->FastTile(2, x, y-2-lgroup[i]->Z, tile, lgroup[i]->CSet, 128);
						}
					}
				}
				else if(lFlags[i]&MIF_8WAY){ //8 way animations
					dir = AngleDir8(WrapDegrees(lAng[i]));
					if(lType[i]!=3)
						lgroup[i]->Dir = AngleDir4(WrapDegrees(lAng[i]));
					j = (lgroup[i]->Tile-lTile[i])%frames;
					if(lgroup[i]->ID!=LW_BEAM&&lgroup[i]->OriginalTile!=lTile[i]+frames*dir){
						lgroup[i]->OriginalTile = lTile[i]+frames*dir;
						lgroup[i]->Tile = lgroup[i]->OriginalTile+j;
					}
					if(lgroup[i]->ID==LW_BEAM&&lgroup[i]->DeadState==WDS_ALIVE){
						tile += frames*dir;
						if(Link->HP>0){
							if(lFlags[i]&MIF_2X2)
								Screen->DrawTile(2, x, y-2-lgroup[i]->Z, tile, 2, 2, lgroup[i]->CSet, -1, -1, 0, 0, 0, 0, true, 128);
							else
								Screen->FastTile(2, x, y-2-lgroup[i]->Z, tile, lgroup[i]->CSet, 128);
						}
					}
				}
				else if(lFlags[i]&MIF_360WAY){ //360 degree animations
					lgroup[i]->DrawYOffset = -1000;
					if(lType[i]!=3)
						lgroup[i]->Dir = AngleDir4(WrapDegrees(lAng[i]));
						
					if(Link->HP>0){
						if(lFlags[i]&MIF_2X2)
							DrawTile(2, x, y-2-lgroup[i]->Z, tile, 2, 2, lgroup[i]->CSet, -1, -1, x, y-2-lgroup[i]->Z, lAng[i], 0, true, 128);
						else
							DrawTile(2, x, y-2-lgroup[i]->Z, tile, 1, 1, lgroup[i]->CSet, -1, -1, x, y-2-lgroup[i]->Z, lAng[i], 0, true, 128);
					}
				}
				else{ //Static animations
					if(lgroup[i]->ID==LW_BEAM&&lgroup[i]->DeadState==WDS_ALIVE){
						if(Link->HP>0){
							if(lFlags[i]&MIF_2X2)
								DrawTile(2, x, y-2-lgroup[i]->Z, tile, 2, 2, lgroup[i]->CSet, -1, -1, 0, 0, 0, 0, true, 128);
							else
								DrawTile(2, x, y-2-lgroup[i]->Z, tile, 1, 1, lgroup[i]->CSet, -1, -1, 0, 0, 0, 0, true, 128);
						}
					}
				}
				
				//Keep track of the weapon's position so we know where to put death effects when it dies
				lLastX[i] = x;
				lLastY[i] = y;
				
				if(lFlags[i]&MIF_PIERCE){
					lgroup[i]->DeadState = -1;
					lgroup[i]->Dir = -1;
					//Pierce is weird and lets weapons go way offscreen but only when the planets are aligned just right.
					//When I tried to reproduce this in another part of the script, it said "No!"
					if(lgroup[i]->X<-80||lgroup[i]->X>256+64||lgroup[i]->Y<-80||lgroup[i]->Y>176+64)
						lgroup[i]->DeadState = 0;
				}
				
				//This handles the creation of bomb explosions on replacement explosion weapons
				if(vars[12]>0){
					lgroup[i]->CollDetection = false;
					if(lTimer[i]%30==0){
						if(vars[12]==1){
							lweapon boom = CreateLWeaponAt(LW_BOMBBLAST, x+Rand(-8*lgroup[i]->TileWidth, 8*lgroup[i]->TileWidth), y+Rand(-8*lgroup[i]->TileWidth, 8*lgroup[i]->TileWidth));
							boom->Damage = lgroup[i]->Damage;
						}
						else if(vars[12]==2){
							lweapon boom = CreateLWeaponAt(LW_SBOMBBLAST, x+Rand(-8*lgroup[i]->TileWidth, 8*lgroup[i]->TileWidth), y+Rand(-8*lgroup[i]->TileWidth, 8*lgroup[i]->TileWidth));
							boom->Damage = lgroup[i]->Damage;
						}
					}
				}
				
				//Death timer for weapons
				if(lDecay[i]>0){
					lDecay[i]--;
					if(lDecay[i]==0)
						lgroup[i]->DeadState = 0;
				}
			
			}
			//Otherwise we remove it
			else{
				//Here's also where we put special weapon death effects
				if(lFlags[i]&MIF_EXPLODEDEATH){
					lweapon boom = CreateLWeaponAt(LW_BOMBBLAST, lLastX[i], lLastY[i]);
					boom->Damage = vars[15];
					boom->Dir = AngleDir4(WrapDegrees(lAng[i]));
					lFlags[i] &= ~MIF_EXPLODEDEATH;
				}
				//Circular shield weapons shouldn't be cleared in order to prevent an animation error.
				//The way I scripted the behavior is bad and I should feel bad.
				if(vars[16]==0)
					MooshItem_RemLWeapon(vars, lgroup, i);
			}
		}
	}
	int MooshItem_AddLWeapon(int vars, lweapon lgroup, lweapon l, int type, int angle, int flags){
		int lTimer = vars[1];
		int lTile = vars[2];
		int lAng = vars[3];
		int lType = vars[4];
		int lMisc1 = vars[5];
		int lMisc2 = vars[6];
		int lDecay = vars[7];
		int lFlags = vars[8];
		int lACounter = vars[9];
		int lNumFrames = vars[10];
		int lASpeed = vars[11];
		int lLastX = vars[13];
		int lLastY = vars[14];
		
		//All weapons are added at the end of the active part of the array
		lgroup[vars[0]] = l;
		lTimer[vars[0]] = 0;
		lTile[vars[0]] = l->OriginalTile;
		lAng[vars[0]] = angle;
		lType[vars[0]] = type;
		lMisc1[vars[0]] = 0;
		lMisc2[vars[0]] = 0;
		lDecay[vars[0]] = 0;
		lFlags[vars[0]] = flags;
		lACounter[vars[0]] = 0;
		lNumFrames[vars[0]] = Max(l->NumFrames, 1);
		lASpeed[vars[0]] = Max(l->ASpeed, 1);
		lLastX[vars[0]] = l->X;
		lLastY[vars[0]] = l->Y;
		
		//Grow the "size" of the "array" to accomodate
		vars[0]++;
		//But the return value is what it used to be
		return vars[0]-1;
	}
	void MooshItem_RemLWeapon(int vars, lweapon lgroup, int i){
		int lTimer = vars[1];
		int lTile = vars[2];
		int lAng = vars[3];
		int lType = vars[4];
		int lMisc1 = vars[5];
		int lMisc2 = vars[6];
		int lDecay = vars[7];
		int lFlags = vars[8];
		int lACounter = vars[9];
		int lNumFrames = vars[10];
		int lASpeed = vars[11];
		int lLastX = vars[13];
		int lLastY = vars[14];
		
		//Whenever a weapon is removed, the weapon at the end of the array gets copied over to it.
		//It's then marked as free space for a new weapon to be created over.
		vars[0]--;
		lgroup[i] = lgroup[vars[0]];
		lTimer[i] = lTimer[vars[0]];
		lTile[i] = lTile[vars[0]];
		lAng[i] = lAng[vars[0]];
		lType[i] = lType[vars[0]];
		lMisc1[i] = lMisc1[vars[0]];
		lMisc2[i] = lMisc2[vars[0]];
		lDecay[i] = lDecay[vars[0]];
		lFlags[i] = lFlags[vars[0]];
		lACounter[i] = lACounter[vars[0]];
		lNumFrames[i] = lNumFrames[vars[0]];
		lASpeed[i] = lASpeed[vars[0]];
		lLastX[i] = lLastX[vars[0]];
		lLastY[i] = lLastY[vars[0]];
	}
	int MooshItem_Homing_TargetAngle(int vars, int angle, lweapon l){
		int minDist = 1000;
		npc min;
		for(int i=Screen->NumNPCs(); i>=1; i--){
			npc n = Screen->LoadNPC(i);
			//If the enemy isn't flagged as beatable, don't target it
			if(n->MiscFlags&(1<<3))
				continue;
			if(!n->CollDetection)
				continue;
			//Get potential value for the enemy (based on how much it resists damage)
			float potential = MooshItem_CanHurt(l, n);
			if(potential==0)
				continue;
			//A combination of the distance to the enemy and the damage potential determines which the script will target
			if(Distance(CenterX(l), CenterY(l), CenterX(n), CenterY(n))-10*potential<minDist){
				minDist = Distance(CenterX(l), CenterY(l), CenterX(n), CenterY(n))-10*potential;
				min = n;
			}
		}
		//If a valid target was found, return the angle to it
		if(min->isValid())
			return Angle(CenterX(l), CenterY(l), CenterX(min), CenterY(min));
		//Otherwise return the last angle
		return angle;
	}
	int MooshItem_BlockWeapons(int vars, lweapon l, int i, bool remOnCollision){
		bool hit;
		//Cycle through all eweapons
		for(int j=Screen->NumEWeapons(); j>=1; j--){
			eweapon e = Screen->LoadEWeapon(j);
			//Remove the ones that collide with the lweapon and can be destroyed
			if(Collision(e, l)){
				if(MooshItem_CanBlockEWeapon(vars, i, e)){
					Game->PlaySound(SFX_MOOSHITEM_BLOCK);
					e->DeadState = 0;
					hit = true;
				}
			}
		}
		//Only kill the lweapon once its cycled through all weapons to prevent weapon priority BS with multiple collisions
		if(remOnCollision&&hit)
			l->DeadState = 0;
	}
	bool MooshItem_CanBlockEWeapon(int vars, int i, eweapon e){
		int lMisc1 = vars[5];
		//This is pretty much just imitating shield block flags
		if(e->ID==EW_ROCK){
			if(lMisc1[i]&1)
				return true;
		}
		else if(e->ID==EW_ARROW){
			if(lMisc1[i]&2)
				return true;
		}
		else if(e->ID==EW_BRANG){
			if(lMisc1[i]&4)
				return true;
		}
		else if(e->ID==EW_FIREBALL){
			if(lMisc1[i]&8)
				return true;
		}
		else if(e->ID==EW_BEAM){
			if(lMisc1[i]&16)
				return true;
		}
		else if(e->ID==EW_MAGIC){
			if(lMisc1[i]&32)
				return true;
		}
		else if(e->ID==EW_FIRE||e->ID==EW_FIRE2){
			if(lMisc1[i]&64)
				return true;
		}
		else if(e->ID<=EW_SCRIPT10){
			if(lMisc1[i]&128)
				return true;
		}
		else if(e->ID==EW_FIREBALL2){
			if(lMisc1[i]&256)
				return true;
		}
		//But there's an extra flag for bombs and supers
		else if(e->ID==EW_BOMB||e->ID==EW_SBOMB){
			if(lMisc1[i]&512)
				return true;
		}
		return false;
	}
	float MooshItem_CanHurt(lweapon l, npc n){
		int type = l->ID;
		int def;
		//This is imitating enemy editor defenses
		if(type>=LW_SCRIPT1)
			def = n->Defense[NPCD_SCRIPT];
		else if(type==LW_BRANG)
			def = n->Defense[NPCD_BRANG];
		else if(type==LW_BOMBBLAST)
			def = n->Defense[NPCD_BOMB];
		else if(type==LW_SBOMBBLAST)
			def = n->Defense[NPCD_SBOMB];
		else if(type==LW_ARROW)
			def = n->Defense[NPCD_ARROW];
		else if(type==LW_FIRE)
			def = n->Defense[NPCD_FIRE];
		else if(type==LW_MAGIC)
			def = n->Defense[NPCD_MAGIC];
		else if(type==LW_BEAM)
			def = n->Defense[NPCD_BEAM];
		else if(type==LW_REFBEAM)
			def = n->Defense[NPCD_REFBEAM];
		else if(type==LW_REFMAGIC)
			def = n->Defense[NPCD_REFMAGIC];
		else if(type==LW_REFROCK)
			def = n->Defense[NPCD_REFROCK];
		
		//But the return value is treated as the enemy's damage potential.
		//This should make the script priotitize enemies that it will deal more damage to.
		if(def==NPCDT_BLOCK||def==NPCDT_IGNORE)
			return 0;
		if(def==NPCDT_ONEHITKILL)
			return 10;
		if(def>=NPCDT_BLOCK1&&def<=NPCDT_BLOCK8||def==NPCDT_IGNORE1){
			if(def==NPCDT_BLOCK8&&l->Damage>=16)
				return 1;
			else if(def==NPCDT_BLOCK6&&l->Damage>=12)
				return 1;
			else if(def==NPCDT_BLOCK4&&l->Damage>=8)
				return 1;
			else if(def==NPCDT_BLOCK2&&l->Damage>=4)
				return 1;
			else if(l->Damage>=2)
				return 1;
			return 0;
		}
		if(def==NPCDT_HALFDAMAGE)
			return 0.5;
		else if(def==NPCDT_QUARTERDAMAGE)
			return 0.25;
		return 1;
	}
	bool MooshItem_CanTakeResource(int ID, int mpCost){
		if(mpCost==0)
			return true;
		itemdata itemdat = Game->LoadItemData(ID);
		if(itemdat->Counter>-1){ //If a counter is set
			if(itemdat->Counter==CR_LIFE){ //If the counter is health, don't allow it to hit 0
				if(Game->Counter[itemdat->Counter]<=mpCost)
					return false;
			}
			else if(Game->Counter[itemdat->Counter]<mpCost)
				return false;
		}
		else{ //Otherwise it's a regular magic cost
			//Only magic costs are affected by 1/2 magic
			mpCost = mpCost*Game->Generic[GEN_MAGICDRAINRATE];
			if(Link->MP<mpCost)
				return false;
		}
		return true;
	}
	void MooshItem_TakeResource(int ID, int mpCost){
		if(mpCost==0)
			return;
		itemdata itemdat = Game->LoadItemData(ID);
		if(itemdat->Counter>-1){ //If a counter is set
			if(itemdat->Counter==CR_LIFE){ //If the counter is health, don't allow it to hit 0
				if(Game->Counter[itemdat->Counter]>mpCost){
					Game->Counter[itemdat->Counter] -= mpCost;
					Game->PlaySound(SFX_MOOSHITEM_HP_COST);
					if(Link->Action==LA_NONE||Link->Action==LA_WALKING||Link->Action==LA_ATTACKING||Link->Action==LA_GOTHURTLAND)
						Link->Action = LA_GOTHURTLAND;
					else if(Link->Action==LA_SWIMMING||Link->Action==LA_GOTHURTWATER)
						Link->Action = LA_GOTHURTWATER;
					Link->HitDir = -1;
				}
			}
			else if(Game->Counter[itemdat->Counter]>=mpCost)
				Game->Counter[itemdat->Counter] -= mpCost;
		}
		else{ //Otherwise it's a regular magic cost
			//Only magic costs are affected by 1/2 magic
			mpCost = mpCost*Game->Generic[GEN_MAGICDRAINRATE];
			if(Link->MP>=mpCost)
				Link->MP -= mpCost;
		}
	}
	int MooshItem_8WayAimAngle(int angle){
		int xAxis;
		int yAxis;
		//Convert Link's directional inputs into axes so opposite inputs cancel out
		if(Link->InputLeft&&!Link->InputRight)
			xAxis = -1;
		else if(!Link->InputLeft&&Link->InputRight)
			xAxis = 1;
		if(Link->InputUp&&!Link->InputDown)
			yAxis = -1;
		else if(!Link->InputUp&&Link->InputDown)
			yAxis = 1;
		
		//If he's holding a cardinal diretcion face that way
		if(yAxis==-1&&xAxis==0)
			Link->Dir=DIR_UP;
		else if(yAxis==1&&xAxis==0)
			Link->Dir=DIR_DOWN;
		else if(xAxis==-1&&yAxis==0)
			Link->Dir=DIR_LEFT;
		else if(xAxis==1&&yAxis==0)
			Link->Dir=DIR_RIGHT;
		
		//But if he's holding the opposite of the direction he's facing, turn him around
		if(Link->Dir==DIR_UP&&yAxis==1)
			Link->Dir=DIR_DOWN;
		else if(Link->Dir==DIR_UP&&yAxis==-1)
			Link->Dir=DIR_UP;
		else if(Link->Dir==DIR_LEFT&&xAxis==1)
			Link->Dir=DIR_RIGHT;
		else if(Link->Dir==DIR_RIGHT&&xAxis==-1)
			Link->Dir=DIR_LEFT;
		
		//Left up
		if(xAxis==-1&&yAxis==-1)
			return -135;
		//Right up
		else if(xAxis==1&&yAxis==-1)
			return -45;
		//Left down
		else if(xAxis==-1&&yAxis==1)
			return 135;
		//Right down
		else if(xAxis==1&&yAxis==1)
			return 45;
		//Up
		else if(yAxis==-1)
			return -90;
		//Down
		else if(yAxis==1)
			return 90;
		//Left
		else if(xAxis==-1)
			return 180;
		//Right
		else if(xAxis==1)
			return 0;
		return angle;
	}
	bool MooshItem_CanWalk(lweapon l, int dir, int step){
		int x; int y;
		//Returns whether a square weapon can move in a direction
		for(int i=0; i<=l->HitWidth-1; i=Min(i+8, l->HitWidth-1)){
			if(dir==DIR_UP){
				x = l->X+l->HitXOffset+i;
				y = l->Y+l->HitYOffset-step;
			}
			else if(dir==DIR_DOWN){
				x = l->X+l->HitXOffset+i;
				y = l->Y+l->HitYOffset+l->HitHeight-1+step;
			}
			else if(dir==DIR_LEFT){
				x = l->X+l->HitXOffset-step;
				y = l->Y+l->HitYOffset+i;
			}
			else if(dir==DIR_RIGHT){
				x = l->X+l->HitXOffset+l->HitWidth-1+step;
				y = l->Y+l->HitYOffset+i;
			}
			if(Screen->isSolid(x, y)){
				//Account for combo types that are solid but aren't "solid"
				int cd = Screen->ComboD[ComboAt(x, y)];
				if(cd!=CT_WATER&&cd!=CT_SWIMWARP&&cd!=CT_SWIMWARPB&&cd!=CT_SWIMWARPC&&cd!=CT_SWIMWARPD&&
					cd!=CT_DIVEWARP&&cd!=CT_DIVEWARPB&&cd!=CT_DIVEWARPC&&cd!=CT_DIVEWARPD&&
					cd!=CT_LADDERONLY&&cd!=CT_LADDERHOOKSHOT&&cd!=CT_HOOKSHOTONLY)
				return false;
			}
			//Return when the end of the collision line is reached
			if(i==l->HitWidth-1)
				return true;
		}
		return true;
	}
	//Duplicate of LinkCollision that doesn't account for Z-axis
	//This prevents Link jumping onto fire/reflected weapons and hurting himself
	bool MooshItem_LinkCollisionNoZ(lweapon b) {
	  int ax = Link->X + Link->HitXOffset;
	  int bx = b->X + b->HitXOffset;
	  int ay = Link->Y + Link->HitYOffset;
	  int by = b->Y + b->HitYOffset;
	  return RectCollision(ax, ay, ax+Link->HitWidth, ay+Link->HitHeight, bx, by, bx+b->HitWidth, by+b->HitHeight);
	}
}

//This FFC script handles the sword animations
ffc script MooshItem_Animations{
	void run(int animType, int ID_mpCost, int type_step, int wType_maxShot, int arg1_arg2, int arg3_arg4, int sprite_sfx, int flags){
		int i; int j; int k;
		lweapon melee; 
		int meleeSprite = MooshItem_LeftArg(sprite_sfx)+1;
		int ID = MooshItem_LeftArg(ID_mpCost);
		itemdata itemdat = Game->LoadItemData(ID);
		int damage = itemdat->Power*2;
		int startTile;
		melee = CreateLWeaponAt(LW_MOOSHITEM_MELEE, -48, -48);
		melee->UseSprite(meleeSprite);
		startTile = melee->OriginalTile;
		melee->DeadState = 0;
		
		int args[8];
		
		args[0] = ID_mpCost;
		args[1] = type_step;
		args[2] = wType_maxShot;
		args[3] = arg1_arg2;
		args[4] = arg3_arg4;
		args[5] = sprite_sfx;
		args[6] = flags;
		
		int handler[] = "MooshItem_Handler";		
		
		//These are all reproductions of the slash animations in ZC as measured with a script
		//Some minor details like the little step forward Link takes aren't included
		if(animType==0){ //Stab
			Game->PlaySound(SFX_MOOSHITEM_MELEE);
			for(i=0; i<10; i++){
				if(Link->Dir==DIR_UP){
					if(i<8)
						melee = MooshItem_UpdateMeleeAnim(melee, meleeSprite, startTile, -1, -10, DIR_UP, damage);
					else if(i<9)
						melee = MooshItem_UpdateMeleeAnim(melee, meleeSprite, startTile, -1, -6, DIR_UP, damage);
					else	
						melee = MooshItem_UpdateMeleeAnim(melee, meleeSprite, startTile, -1, -2, DIR_UP, damage);
				}
				else if(Link->Dir==DIR_DOWN){
					if(i<8)
						melee = MooshItem_UpdateMeleeAnim(melee, meleeSprite, startTile, 1, 13, DIR_DOWN, damage);
					else if(i<9)
						melee = MooshItem_UpdateMeleeAnim(melee, meleeSprite, startTile, 1, 9, DIR_DOWN, damage);
					else	
						melee = MooshItem_UpdateMeleeAnim(melee, meleeSprite, startTile, 1, 5, DIR_DOWN, damage);
				}
				else if(Link->Dir==DIR_LEFT){
					if(i<8)
						melee = MooshItem_UpdateMeleeAnim(melee, meleeSprite, startTile, -11, 3, DIR_LEFT, damage);
					else if(i<9)
						melee = MooshItem_UpdateMeleeAnim(melee, meleeSprite, startTile, -7, 3, DIR_LEFT, damage);
					else	
						melee = MooshItem_UpdateMeleeAnim(melee, meleeSprite, startTile, -3, 3, DIR_LEFT, damage);
				}
				else if(Link->Dir==DIR_RIGHT){
					if(i<8)
						melee = MooshItem_UpdateMeleeAnim(melee, meleeSprite, startTile, 11, 3, DIR_RIGHT, damage);
					else if(i<9)
						melee = MooshItem_UpdateMeleeAnim(melee, meleeSprite, startTile, 7, 3, DIR_RIGHT, damage);
					else	
						melee = MooshItem_UpdateMeleeAnim(melee, meleeSprite, startTile, 3, 3, DIR_RIGHT, damage);
				}
				Link->Action = LA_NONE;
				Link->Action = LA_ATTACKING;
				if(i==8)
					RunFFCScript(Game->GetFFCScript(handler), args);
				if(melee->isValid())
					melee->Dir = Link->Dir;
				Waitframe();
			}
		}
		else if(animType==1){ //Slash
			Game->PlaySound(SFX_MOOSHITEM_MELEE);
			for(i=0; i<14; i++){
				if(Link->Dir==DIR_UP){
					if(i<6)
						melee = MooshItem_UpdateMeleeAnim(melee, meleeSprite, startTile, 15, -1, DIR_RIGHT, damage);
					else if(i<10)
						melee = MooshItem_UpdateMeleeAnim(melee, meleeSprite, startTile, 12, -10, DIR_RIGHTUP, damage);
					else if(i<13)
						melee = MooshItem_UpdateMeleeAnim(melee, meleeSprite, startTile, -1, -15, DIR_UP, damage);
					else
						melee = MooshItem_UpdateMeleeAnim(melee, meleeSprite, startTile, -1, -10, DIR_UP, damage);
				}
				else if(Link->Dir==DIR_DOWN){
					if(i<6)
						melee = MooshItem_UpdateMeleeAnim(melee, meleeSprite, startTile, -13, 1, DIR_LEFT, damage);
					else if(i<10)
						melee = MooshItem_UpdateMeleeAnim(melee, meleeSprite, startTile, -11, 16, DIR_LEFTDOWN, damage);
					else if(i<13)
						melee = MooshItem_UpdateMeleeAnim(melee, meleeSprite, startTile, 1, 18, DIR_DOWN, damage);
					else
						melee = MooshItem_UpdateMeleeAnim(melee, meleeSprite, startTile, 1, 13, DIR_DOWN, damage);
				}
				else if(Link->Dir==DIR_LEFT){
					if(i<6)
						melee = MooshItem_UpdateMeleeAnim(melee, meleeSprite, startTile, 3, -13, DIR_UP, damage);
					else if(i<10)
						melee = MooshItem_UpdateMeleeAnim(melee, meleeSprite, startTile, -12, -10, DIR_LEFTUP, damage);
					else if(i<13)
						melee = MooshItem_UpdateMeleeAnim(melee, meleeSprite, startTile, -18, 3, DIR_LEFT, damage);
					else
						melee = MooshItem_UpdateMeleeAnim(melee, meleeSprite, startTile, -11, 3, DIR_LEFT, damage);
				}
				else if(Link->Dir==DIR_RIGHT){
					if(i<6)
						melee = MooshItem_UpdateMeleeAnim(melee, meleeSprite, startTile, 3, -13, DIR_UP, damage);
					else if(i<10)
						melee = MooshItem_UpdateMeleeAnim(melee, meleeSprite, startTile, 18, -10, DIR_RIGHTUP, damage);
					else if(i<13)
						melee = MooshItem_UpdateMeleeAnim(melee, meleeSprite, startTile, 18, 3, DIR_RIGHT, damage);
					else
						melee = MooshItem_UpdateMeleeAnim(melee, meleeSprite, startTile, 11, 3, DIR_RIGHT, damage);
				}
				if(i<10){
					Link->Action = LA_NONE;
					Link->Action = LA_ATTACKING;
				}
				if(i==10)
					RunFFCScript(Game->GetFFCScript(handler), args);
				if(melee->isValid())
					melee->Dir = Link->Dir;
				Waitframe();
			}
		}
		else if(animType==2){ //Z3 Slash
			Game->PlaySound(SFX_MOOSHITEM_MELEE);
			for(i=0; i<14; i++){
				if(Link->Dir==DIR_UP){
					if(i<6)
						melee = MooshItem_UpdateMeleeAnim(melee, meleeSprite, startTile, 18, -10, DIR_RIGHTUP, damage);
					else if(i<10)
						melee = MooshItem_UpdateMeleeAnim(melee, meleeSprite, startTile, -1, -15, DIR_UP, damage);
					else if(i<13)
						melee = MooshItem_UpdateMeleeAnim(melee, meleeSprite, startTile, -12, -10, DIR_LEFTUP, damage);
					else
						melee = MooshItem_UpdateMeleeAnim(melee, meleeSprite, startTile, -5, -5, DIR_LEFTUP, damage);
				}
				else if(Link->Dir==DIR_DOWN){
					if(i<6)
						melee = MooshItem_UpdateMeleeAnim(melee, meleeSprite, startTile, -11, 16, DIR_LEFTDOWN, damage);
					else if(i<10)
						melee = MooshItem_UpdateMeleeAnim(melee, meleeSprite, startTile, 1, 18, DIR_DOWN, damage);
					else if(i<13)
						melee = MooshItem_UpdateMeleeAnim(melee, meleeSprite, startTile, 15, 13, DIR_RIGHTDOWN, damage);
					else
						melee = MooshItem_UpdateMeleeAnim(melee, meleeSprite, startTile, 8, 8, DIR_RIGHTDOWN, damage);
				}
				else if(Link->Dir==DIR_LEFT){
					if(i<6)
						melee = MooshItem_UpdateMeleeAnim(melee, meleeSprite, startTile, -12, -10, DIR_LEFTUP, damage);
					else if(i<10)
						melee = MooshItem_UpdateMeleeAnim(melee, meleeSprite, startTile, -18, 3, DIR_LEFT, damage);
					else if(i<13)
						melee = MooshItem_UpdateMeleeAnim(melee, meleeSprite, startTile, -11, 16, DIR_LEFTDOWN, damage);
					else
						melee = MooshItem_UpdateMeleeAnim(melee, meleeSprite, startTile, -4, 11, DIR_LEFTDOWN, damage);
				}
				else if(Link->Dir==DIR_RIGHT){
					if(i<6)
						melee = MooshItem_UpdateMeleeAnim(melee, meleeSprite, startTile, 18, -10, DIR_RIGHTUP, damage);
					else if(i<10)
						melee = MooshItem_UpdateMeleeAnim(melee, meleeSprite, startTile, 18, 3, DIR_RIGHT, damage);
					else if(i<13)
						melee = MooshItem_UpdateMeleeAnim(melee, meleeSprite, startTile, 15, 13, DIR_RIGHTDOWN, damage);
					else
						melee = MooshItem_UpdateMeleeAnim(melee, meleeSprite, startTile, 8, 8, DIR_RIGHTDOWN, damage);
				}
				if(i<10){
					Link->Action = LA_NONE;
					Link->Action = LA_ATTACKING;
				}
				if(i==10)
					RunFFCScript(Game->GetFFCScript(handler), args);
				if(melee->isValid())
					melee->Dir = Link->Dir;
				Waitframe();
			}
		}
		if(melee->isValid())
			melee->DeadState = 0;
	}
	lweapon MooshItem_UpdateMeleeAnim(lweapon melee, int sprite, int startTile, int x, int y, int dir, int damage){
		//This updates the melee lweapon and ensures that one always exists
		if(melee->isValid()){
			melee->X = Link->X+x;
			melee->Y = Link->Y+y;
			melee->Z = Link->Z;
		}
		else{
			melee = CreateLWeaponAt(LW_MOOSHITEM_MELEE, Link->X+x, Link->Y+y);
			melee->Z = Link->Z;
			melee->UseSprite(sprite);
			melee->Step = 0;
			melee->Damage = damage;
		}
		//Change the tile  based on the current direction
		int frames = Max(melee->NumFrames, 1);
		melee->OriginalTile = startTile+frames*dir;
		melee->Tile = melee->OriginalTile+((melee->Tile-melee->OriginalTile)%frames);
		return melee;
	}
}