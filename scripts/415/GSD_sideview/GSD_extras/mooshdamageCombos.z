const int SCRIPTEDDAMAGECOMBO_ONLYFACING = 1; //If 1, scripted damage combos will only do damage when Link is facing them
const int SCRIPTEDDAMAGECOMBO_DAMAGEONHEADBONK = 1; //If 1, Link takes damage instantly when jumping into a spiked ceiling

const int DELAY_SCRIPTEDDAMAGECOMBO = 8; //Default frame delay before taking damage
const int DELAY_SCRIPTEDDAMAGECOMBO_SIDEVIEW = 8; //Frame delay for sideview screens
const int EW_SCRIPTEDDAMAGECOMBO = 40; //EWeapon used for dealing damage. Script 10 by default

//Collision points for spike hitboxes
//This tells the script which points to check offset from 
//Link's hitbox for various collision checks. Unless you're using 
//large Link these shouldn't need to be changed
const int SDC_SOLID_HITBOX_UD_LEFT = 7;
const int SDC_SOLID_HITBOX_UD_RIGHT = 8;
const int SDC_SOLID_HITBOX_UD_TOP = 8;
const int SDC_SOLID_HITBOX_LR_TOP = 11;
const int SDC_SOLID_HITBOX_LR_BOTTOM = 12;

const int SDC_FALLING_HITBOX_LEFT = 4;
const int SDC_FALLING_HITBOX_RIGHT = 11;

const int SDC_CEILING_HITBOX_LEFT = 4;
const int SDC_CEILING_HITBOX_RIGHT = 11;

const int SDC_NONSOLID_HITBOX_LEFT = 4;
const int SDC_NONSOLID_HITBOX_RIGHT = 11;
const int SDC_NONSOLID_HITBOX_TOP = 11;
const int SDC_NONSOLID_HITBOX_BOTTOM = 12;

const int SDC_NONSOLID_HITBOX_SIDEVIEW_LEFT = 4;
const int SDC_NONSOLID_HITBOX_SIDEVIEW_RIGHT = 11;
const int SDC_NONSOLID_HITBOX_SIDEVIEW_TOP = 4;
const int SDC_NONSOLID_HITBOX_SIDEVIEW_BOTTOM = 11;

//Change this function is you have custom rings with different damage divisors in your quest
int ScriptedDamageCombo_GetTunicMultipliers(){
	//Return the divisor of the highest level ring
	if(Link->Item[I_RING3])
		return 8;
	else if(Link->Item[I_RING2])
		return 4;
	else if(Link->Item[I_RING1])
		return 2;
	//Otherwise no ring and damage is normal
	return 1;
}

//D0: The combo flag to check for scripted damage combos. If 0, the FFC itself is a hitbox
//D1: How much base damage the spikes deal. 4 points = 1 heart
//D2: If 1, the damage pierces rings
//D3: If >0 set the delay before spikes deal damage when holding up against them
//D4: If 1, the combos are treated as non solid damage combos
//D5: If 1, Link takes no knockback when hit
ffc script ScriptedDamageCombo{
	void run(int flag, int damage, int pierce, int damageDelay, int notSolid, int noKnockback){
		if(damageDelay==0){
			damageDelay = DELAY_SCRIPTEDDAMAGECOMBO;
			if(IsSideview())
				damageDelay = DELAY_SCRIPTEDDAMAGECOMBO_SIDEVIEW;
		}
		
		int timer;
		
		int xyInput[2];
		while(true){
			//Combo placed on the screen
			if(flag>0){
				int collchk = ScriptedDamageCombo_DetectLinkCollision(flag, Link->X, Link->Y, Link->Dir, notSolid, xyInput);
				if(collchk){
					if(notSolid){
						ScriptedDamageCombo_DamageLink(damage, pierce, noKnockback);
					}
					else{
						if(timer<damageDelay&&collchk!=2)
							timer++;
						else{
							ScriptedDamageCombo_DamageLink(damage, pierce, noKnockback);
						}
					}
				}
				else
					timer = 0;
			}
			//Combo is the FFC
			else{
				eweapon e = FireEWeapon(EW_SCRIPTEDDAMAGECOMBO, this->X, this->Y, 0, 0, damage, 0, 0, EWF_UNBLOCKABLE);
				e->DrawYOffset = -1000;
				e->HitWidth = this->EffectWidth;
				e->HitHeight = this->EffectHeight;
				SetEWeaponLifespan(e, EWL_TIMER, 0);
				SetEWeaponDeathEffect(e, EWD_VANISH, 0);
			}
			Waitframe();
		}
	}
	void ScriptedDamageCombo_DamageLink(int damage, bool pierce, bool noKnockback){
		ScriptedDamageCombo_DamageLink(damage, pierce, noKnockback, Link->Dir);
	}
	void ScriptedDamageCombo_DamageLink(int damage, bool pierce, bool noKnockback, int dir){
		int x = Link->X;
		int y = Link->Y;
		if(dir==DIR_UP)
			y -= 4;
		else if(dir==DIR_DOWN)
			y += 4;
		else if(dir==DIR_LEFT)
			x -= 4;
		else if(dir==DIR_RIGHT)
			x += 4;
		
		if(pierce)
			damage *= ScriptedDamageCombo_GetTunicMultipliers();
		
		eweapon e = FireEWeapon(EW_SCRIPTEDDAMAGECOMBO, x, y, 0, 0, damage, 0, 0, EWF_UNBLOCKABLE);
		e->DrawYOffset = -1000;
		SetEWeaponLifespan(e, EWL_TIMER, 0);
		SetEWeaponDeathEffect(e, EWD_VANISH, 0);
		if(noKnockback)
			Link->HitDir = -1;
	}
	void ScriptedDamageCombo_UpdateInput(int xyInput){
		if(xyInput[1]==0){ //If no Y axis pressed
			if(Link->PressUp&&Link->PressDown) //Default to up when buttons pressed simultaneously
				xyInput[1] = -1;
			else if(Link->PressUp||Link->InputUp) //Set axis based on which button what pressed
				xyInput[1] = -1;
			else if(Link->PressDown||Link->InputDown)
				xyInput[1] = 1;
		}
		else{ //If Y axis pressed
			if(!Link->InputUp&&!Link->InputDown) //Release Y axis if neither button pressed
				xyInput[1] = 0;
			else if(xyInput[1]==-1&&!Link->InputUp) //Reverse Y axis if opposite direction held and button released
				xyInput[1] = 1;
			else if(xyInput[1]==1&&!Link->InputDown)
				xyInput[1] = -1;
		}
		
		if(xyInput[0]==0){ //If no X axis pressed
			if(Link->PressLeft&&Link->PressRight) //Default to left when buttons pressed simultaneously
				xyInput[0] = -1;
			else if(Link->PressLeft||Link->InputLeft) //Set axis based on which button what pressed
				xyInput[0] = -1;
			else if(Link->PressRight||Link->InputRight)
				xyInput[0] = 1;
		}
		else{ //If Y axis pressed
			if(!Link->InputLeft&&!Link->InputRight) //Release Y axis if neither button pressed
				xyInput[0] = 0;
			else if(xyInput[0]==-1&&!Link->InputLeft) //Reverse Y axis if opposite direction held and button released
				xyInput[0] = 1;
			else if(xyInput[0]==1&&!Link->InputRight)
				xyInput[0] = -1;
		}
	}
	int ScriptedDamageCombo_DetectLinkCollision(int flag, int x, int y, int dir, bool notSolid, int xyInput){
		ScriptedDamageCombo_UpdateInput(xyInput);
		
		int x2; int y2;
		//Check for collisions against solid combos
		if(!notSolid){
			//Check for sideview gravity
			if(IsSideview()){
				bool onSpikes;
				bool onSafeSolid;
				for(int i=SDC_FALLING_HITBOX_LEFT;i<=SDC_FALLING_HITBOX_RIGHT; i=Min(i+8, SDC_FALLING_HITBOX_RIGHT)){
					x2 = x+i;
					y2 = y+16;
					//Spikes mark Link as getting hurt
					if(ComboFI(x2, y2, flag)){
						if(Screen->isSolid(x2, y2)){
							onSpikes = true;
						}
					}
					//But standing on adjacent land overrides this
					else{
						if(Screen->isSolid(x2, y2)){
							onSafeSolid = true;
						}
					}
					if(i==SDC_FALLING_HITBOX_RIGHT)
						break;
				}
				if(onSpikes&&!onSafeSolid){
					return 2; //Special return value for sideview spikes, which overrides the damage cooldown
				}
				
				if(SCRIPTEDDAMAGECOMBO_DAMAGEONHEADBONK){
					if(Link->Jump>0){
						onSpikes = false;
						onSafeSolid  = false;
						for(int i=SDC_CEILING_HITBOX_LEFT;i<=SDC_CEILING_HITBOX_RIGHT; i=Min(i+8, SDC_CEILING_HITBOX_RIGHT)){
							x2 = x+i;
							y2 = y-Max(Ceiling(Link->Jump), 1);
							//Spikes mark Link as getting hurt
							if(ComboFI(x2, y2, flag)){
								if(Screen->isSolid(x2, y2)){
									onSpikes = true;
								}
							}
							//But standing on adjacent land overrides this
							else{
								if(Screen->isSolid(x2, y2)){
									onSafeSolid = true;
								}
							}
							if(i==SDC_CEILING_HITBOX_RIGHT)
								break;
						}
						if(onSpikes&&!onSafeSolid){
							return 2; //Special return value for sideview spikes, which overrides the damage cooldown
						}
					}
				}
			}
			
			//Check collisions walking up
			if(xyInput[1]==-1){
				for(int i=SDC_SOLID_HITBOX_UD_LEFT; i<=SDC_SOLID_HITBOX_UD_RIGHT; i=Min(i+8, SDC_SOLID_HITBOX_UD_RIGHT)){
					x2 = x+i;
					y2 = y+SDC_SOLID_HITBOX_UD_TOP-1;
					if(ComboFI(x2, y2, flag)){
						if(Screen->isSolid(x2, y2)){
							if(!SCRIPTEDDAMAGECOMBO_ONLYFACING||Link->Dir==DIR_UP)
								return 1;
						}
					}
					if(i==SDC_SOLID_HITBOX_UD_RIGHT)
						break;
				}
			}
			//Check collisions walking down
			else if(xyInput[1]==1){
				for(int i=SDC_SOLID_HITBOX_UD_LEFT; i<=SDC_SOLID_HITBOX_UD_RIGHT; i=Min(i+8, SDC_SOLID_HITBOX_UD_RIGHT)){
					x2 = x+i;
					y2 = y+16;
					if(ComboFI(x2, y2, flag)){
						if(Screen->isSolid(x2, y2)){
							if(!SCRIPTEDDAMAGECOMBO_ONLYFACING||Link->Dir==DIR_DOWN)
								return 1;
						}
					}
					if(i==SDC_SOLID_HITBOX_UD_RIGHT)
						break;
				}
			}
			//Check collisions walking left
			else if(xyInput[0]==-1){
				for(int i=SDC_SOLID_HITBOX_LR_TOP; i<=SDC_SOLID_HITBOX_LR_BOTTOM; i=Min(i+8, SDC_SOLID_HITBOX_LR_BOTTOM)){
					x2 = x-1;
					y2 = y+i;
					if(ComboFI(x2, y2, flag)){
						if(Screen->isSolid(x2, y2)){
							if(!SCRIPTEDDAMAGECOMBO_ONLYFACING||Link->Dir==DIR_LEFT)
								return 1;
						}
					}
					if(i==SDC_SOLID_HITBOX_LR_BOTTOM)
						break;
				}
			}
			//Check collisions walking right
			else if(xyInput[0]==1){
				for(int i=SDC_SOLID_HITBOX_LR_TOP; i<=SDC_SOLID_HITBOX_LR_BOTTOM; i=Min(i+8, SDC_SOLID_HITBOX_LR_BOTTOM)){
					x2 = x+16;
					y2 = y+i;
					if(ComboFI(x2, y2, flag)){
						if(Screen->isSolid(x2, y2)){
							if(!SCRIPTEDDAMAGECOMBO_ONLYFACING||Link->Dir==DIR_RIGHT)
								return 1;
						}
					}
					if(i==SDC_SOLID_HITBOX_LR_BOTTOM)
						break;
				}
			}
		}
		//Check for collisions against nonsolid combos
		else{
			int hit[4] = {SDC_NONSOLID_HITBOX_LEFT, SDC_NONSOLID_HITBOX_RIGHT, SDC_NONSOLID_HITBOX_TOP, SDC_NONSOLID_HITBOX_BOTTOM};
			if(IsSideview()){
				hit[0] = SDC_NONSOLID_HITBOX_SIDEVIEW_LEFT;
				hit[1] = SDC_NONSOLID_HITBOX_SIDEVIEW_RIGHT;
				hit[2] = SDC_NONSOLID_HITBOX_SIDEVIEW_TOP;
				hit[3] = SDC_NONSOLID_HITBOX_SIDEVIEW_BOTTOM;
			}
			
			for(int xi=hit[0]; xi<=hit[1]; xi=Min(xi+8, hit[1])){
				for(int yi=hit[2]; yi<=hit[3]; yi=Min(yi+8, hit[3])){
					x2 = x+xi;
					y2 = y+yi;
					if(ComboFI(x2, y2, flag)){
						return 1;
					}
					if(yi==hit[3])
						break;
				}
				if(xi==hit[1])
					break;
			}
		}
		return 0;
	}
}