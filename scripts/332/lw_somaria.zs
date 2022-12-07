//No moving platforms for you, Somaria!
const int SOMARIA_SCRIPT = 104;
const int SPR_SOMARIA_BEAM = 20;
const int SOMARIA_COMBO = 28324;
const int SPR_SOMARIA = 109;
const int SFX_PUSH_SOMARIA = 50;
const int PRESSURE_PLATE_SCRIPT = 105;
 
item script Run_Somaria{
	void run(int Damage){
		lweapon somaria = FireLWeapon(LW_SCRIPT10,Link->X+InFrontX(Link->Dir,2), Link->Y+InFrontY(Link->Dir,2),
											__DirtoRad(Link->Dir), 0, Damage, SPR_SOMARIA, SFX_SWORD, 0);
		SetLWeaponLifespan(somaria,LWL_TIMER,15);
		SetLWeaponMovement(somaria,LWM_MELEE,0,LWMF_TRACKER);
		SetLWeaponDeathEffect(somaria,LWD_VANISH,0);
		Link->Action= LA_ATTACKING;
		if(CountFFCsRunning(SOMARIA_SCRIPT)==0){
			int Args[8] = {Damage, SPR_SOMARIA_BEAM, SFX_BEAM};
			NewFFCScript(SOMARIA_SCRIPT, Args);
		}
	}
}
 
bool Is_Switch(int loc){
    return ComboFIT(loc,CF_BLOCKTRIGGER,CT_NONE);
}
 
const int SFX_SWITCH_PUSH= 91;//Sound effect of pushing a switch
const int I_ITEM_SOMARIA= 0;//Item id of Cane of Somaria
const int CF_SOMARIA= 103;//Combo flag for objects affects by Somaria switch. Defaults to CF_SCRIPT5
 
ffc script Somaria_Block{
	void run(int damage, int spr, int sfx){
		lweapon spark;
		this->Data = SOMARIA_COMBO;
		this->X = Link->X+InFrontX(Link->Dir,2);
		this->Y = Link->Y+InFrontY(Link->Dir,2);
		int Pushing = -1;
		int PushCooldown;
		int i;
		bool Pressed;
		int ComboArray[176];
		for(i= 0;i<=175;i++){
            ComboArray[i]= -1;
            if(Is_Switch(i))
                ComboArray[i]= Screen->ComboD[i];
        }
		int loc;
		int Sfx_Timer;
		int Push_Counter;
		int Switch_Spot;
		while(true){
			while(Link->X+16< this->X
					|| Link->X> this->X+16
					|| Link->Y> this->Y+16
					|| Link->Y+16< this->Y){
				if(Link->PressB){
					if(GetEquipmentB()==I_ITEM_SOMARIA){
						for(i=0;i<=3;i++)
							spark= FireLWeapon(LW_SCRIPT1,this->X+InFrontX(i,2),this->Y+InFrontY(i,2),
												__DirtoRad(i),100,damage,spr,sfx,LWF_PIERCES_ENEMIES);
						for(i= 0;i<=175;i++){
							if(ComboArray[i]!=-1)
								Screen->ComboD[i]=ComboArray[i];
							if(Pressed){
								if(Screen->ComboF[i]==CF_SOMARIA)
									Screen->ComboD[i]--;	
							}
						}
						if(Switch_Spot)
							Screen->ComboD[Switch_Spot]=ComboArray[Switch_Spot];
						this->Data = GH_INVISIBLE_COMBO;
						this->Flags[FFCF_ETHEREAL]= true;
						Waitframes(30);
						Quit();
					}
				}
				if(IsSideview()){
					if(!OnSidePlatform(this->X,this->Y))
						this->Y++;
					if(Link->Y+16< this->Y
						&&Link->Y>this->Y-18){
						if(Link->X+16> this->X
							&& Link->X< this->X+16){
							if(GetEquipmentB()!=I_ROCSFEATHER)
								Link->Jump=0;
							else{
								if(!Link->PressB
									&& !Link->InputB)
									Link->Jump=0;
							}
						}
					}
				}
				loc = ComboAt(this->X+8,this->Y+8);
				if(Is_Switch(loc)){
					Screen->ComboD[loc]++;
					Game->PlaySound(SFX_SWITCH_PUSH);
					Switch_Spot= loc;
					if(!Pressed){
						for(i= 0;i<=175;i++){
							if(Screen->ComboF[i]==CF_SOMARIA)
								Screen->ComboD[i]++;
						}
						Pressed= true;
					}
				}
				else{
					if(loc!=Switch_Spot){
						if(ComboArray[Switch_Spot]!=-1){
							Screen->ComboD[Switch_Spot]=ComboArray[Switch_Spot];
							Switch_Spot= 0;
							if(Pressed){
								for(i= 0;i<=175;i++){
									if(Screen->ComboF[i]==CF_SOMARIA)
										Screen->ComboD[i]--;
								}
								Pressed= false;
							}
						}
					}
				}
				Waitframe();
			}
			while(Pushing==-1){
				if(Link->PressB){
					if(GetEquipmentB()==I_ITEM_SOMARIA){
						for(i=0;i<=3;i++)
							spark= FireLWeapon(LW_SCRIPT1,this->X+InFrontX(i,2),this->Y+InFrontY(i,2),
												__DirtoRad(i),100,damage,spr,sfx,LWF_PIERCES_ENEMIES);
						for(i= 0;i<=175;i++){
							if(ComboArray[i]!=-1)
								Screen->ComboD[i]=ComboArray[i];
							if(Pressed){
								if(Screen->ComboF[i]==CF_SOMARIA)
									Screen->ComboD[i]--;	
							}
						}
						if(Switch_Spot)
							Screen->ComboD[Switch_Spot]=ComboArray[Switch_Spot];
						this->Data = GH_INVISIBLE_COMBO;
						this->Flags[FFCF_ETHEREAL]= true;
						Waitframes(30);
						Quit();
					}
				}
				if(Link->X+16 >=this->X && Link->X < this->X
					&& (Link->PressRight||Link->InputRight)
					&& (Between(Link->Y+8,this->Y,this->Y+16)
						||Between(Link->Y+1,this->Y,this->Y+16)
						||Between(Link->Y+15,this->Y,this->Y+16))){
					if(!Screen->isSolid(this->X+17,this->Y)
						&& !Screen->isSolid(this->X+17,this->Y+8)
						&& !Screen->isSolid(this->X+17,this->Y+15)){
						if(Push_Counter<=5){
							Link->PressRight = false;
							Link->InputRight = false;
							Push_Counter++;
						}
						else{
							Game->PlaySound(SFX_PUSH_SOMARIA);
							Pushing = DIR_RIGHT;
						}
					}
					else{
						Link->PressRight = false;
						Link->InputRight = false;
					}
				}
				else if(Link->X <=this->X+16 && Link->X+16 > this->X+16
					&& (Link->PressLeft||Link->InputLeft)
					&& (Between(Link->Y+8,this->Y,this->Y+16)
						||Between(Link->Y+1,this->Y,this->Y+16)
						||Between(Link->Y+15,this->Y,this->Y+16))){
					if(!Screen->isSolid(this->X-1,this->Y)
						&& !Screen->isSolid(this->X-1,this->Y+8)
						&& !Screen->isSolid(this->X-1,this->Y+15)){
						if(Push_Counter<=5){
							Link->PressLeft = false;
							Link->InputLeft = false;
							Push_Counter++;
						}
						else{
							Game->PlaySound(SFX_PUSH_SOMARIA);
							Pushing = DIR_LEFT;
						}
					}
					else{
						Link->PressLeft = false;
						Link->InputLeft = false;
					}
				}
				else if(Link->Y+16 >=this->Y && Link->Y <= this->Y
					&& (Link->PressDown||Link->InputDown)
					&& (Between(Link->X+8,this->X,this->X+16)
						||Between(Link->X+1,this->X,this->X+16)
						||Between(Link->X+15,this->X,this->X+16))){
					if(!Screen->isSolid(this->X,this->Y+17)
						&& !Screen->isSolid(this->X+8,this->Y+17)
						&& !Screen->isSolid(this->X+15,this->Y+17)){
						if(Push_Counter<=5){
							Link->PressDown = false;
							Link->InputDown = false;
							Push_Counter++;
						}
						else{
							Game->PlaySound(SFX_PUSH_SOMARIA);
							Pushing = DIR_DOWN;
						}
					}
					else{
						Link->PressDown = false;
						Link->InputDown = false;
					}
				}
				else if(Link->Y <=this->Y+16&& Link->Y+16 > this->Y+16 
					&& (Link->PressUp||Link->InputUp)
					&& (Between(Link->X+8,this->X,this->X+16)
						||Between(Link->X+1,this->X,this->X+16)
						||Between(Link->X+15,this->X,this->X+16))){
					if(!Screen->isSolid(this->X,this->Y-1)
						&& !Screen->isSolid(this->X+8,this->Y-1)
						&& !Screen->isSolid(this->X+15,this->Y-1)){
						if(Push_Counter<=5){
							Link->PressUp = false;
							Link->InputUp = false;
							Push_Counter++;
						}
						else{
							Game->PlaySound(SFX_PUSH_SOMARIA);
							Pushing = DIR_UP;
						}
					}
					else{
						Link->PressUp = false;
						Link->InputUp = false;
					}	
				}
				if(IsSideview()){
					if(!OnSidePlatform(this->X,this->Y))
						this->Y++;
					if(Link->Y+16< this->Y
						&&Link->Y>this->Y-18){
						if(Link->X+16> this->X
							&& Link->X< this->X+16){
							if(GetEquipmentB()!=I_ROCSFEATHER)
								Link->Jump=0;
							else{
								if(!Link->PressB
									&& !Link->InputB)
									Link->Jump=0;
							}
						}
					}	
				}
				loc = ComboAt(this->X+8,this->Y+8);
				if(Is_Switch(loc)){
					Screen->ComboD[loc]++;
					Game->PlaySound(SFX_SWITCH_PUSH);
					Switch_Spot= loc;
					if(!Pressed){
						for(i= 0;i<=175;i++){
							if(Screen->ComboF[i]==CF_SOMARIA)
								Screen->ComboD[i]++;
						}
						Pressed= true;
					}
				}
				else{
					if(loc!=Switch_Spot){
						if(ComboArray[Switch_Spot]!=-1){
							Screen->ComboD[Switch_Spot]=ComboArray[Switch_Spot];
							Switch_Spot= 0;
							if(Pressed){
								for(i= 0;i<=175;i++){
									if(Screen->ComboF[i]==CF_SOMARIA)
										Screen->ComboD[i]--;
								}
								Pressed= false;
							}
						}
					}
				}
				Waitframe();
			}	
			while(Pushing!=-1){
				if(Link->PressB){
					if(GetEquipmentB()==I_ITEM_SOMARIA){
						for(i=0;i<=3;i++)
							spark= FireLWeapon(LW_SCRIPT1,this->X+InFrontX(i,2),this->Y+InFrontY(i,2),
												__DirtoRad(i),100,damage,spr,sfx,LWF_PIERCES_ENEMIES);
						for(i= 0;i<=175;i++){
							if(ComboArray[i]!=-1)
								Screen->ComboD[i]=ComboArray[i];
							if(Pressed){
								if(Screen->ComboF[i]==CF_SOMARIA)
									Screen->ComboD[i]--;	
							}
						}
						if(Switch_Spot)
							Screen->ComboD[Switch_Spot]=ComboArray[Switch_Spot];
						this->Data = GH_INVISIBLE_COMBO;
						this->Flags[FFCF_ETHEREAL]= true;
						Waitframes(30);
						Quit();
					}
				}
				if(Sfx_Timer==0)
					Game->PlaySound(SFX_PUSH_SOMARIA);
				Sfx_Timer = (Sfx_Timer+1)%10;
				if(Pushing==DIR_LEFT){
					if(!Link->PressRight
						&& !Link->InputRight
						&& !Link->InputUp
						&& !Link->PressDown
						&& !Link->PressUp
						&& !Link->InputDown){
						this->X = Link->X-16;
						if(Screen->isSolid(this->X-1,this->Y)
							|| Screen->isSolid(this->X-1,this->Y+8)
							|| Screen->isSolid(this->X-1,this->Y+15)){
							Link->InputLeft = false;
							Link->PressLeft = false;
						}
					}
					else
						Pushing = -1;
				}
				else if(Pushing==DIR_RIGHT){
					if(!Link->PressLeft
						&& !Link->InputLeft
						&& !Link->InputUp
						&& !Link->PressDown
						&& !Link->PressUp
						&& !Link->InputDown){
						this->X = Link->X+16;
						if(Screen->isSolid(this->X+17,this->Y)
							|| Screen->isSolid(this->X+17,this->Y+8)
							|| Screen->isSolid(this->X+17,this->Y+15)){
							Link->InputRight = false;
							Link->PressRight = false;
						}
					}
					else
						Pushing = -1;
				}
				else if(Pushing==DIR_UP){
					if(!Link->PressRight
						&& !Link->InputRight
						&& !Link->InputLeft
						&& !Link->PressDown
						&& !Link->PressLeft
						&& !Link->InputDown){
						this->Y = Link->Y-16;
						if(Screen->isSolid(this->X,this->Y-1)
							|| Screen->isSolid(this->X+8,this->Y-1)
							|| Screen->isSolid(this->X+15,this->Y-1)){
							Link->InputUp = false;
							Link->PressUp = false;
						}
					}
					else
						Pushing = -1;
				}
				else if(Pushing==DIR_DOWN){
					if(!Link->PressRight
						&& !Link->InputRight
						&& !Link->InputUp
						&& !Link->PressLeft
						&& !Link->PressUp
						&& !Link->InputLeft){
						this->Y = Link->Y+16;
						if(Screen->isSolid(this->X,this->Y+17)
							|| Screen->isSolid(this->X+8,this->Y+17)
							|| Screen->isSolid(this->X+15,this->Y+17)){
							Link->InputDown = false;
							Link->PressDown = false;
						}
					}
					else
						Pushing = -1;
				}
				if(IsSideview()){
					if(!OnSidePlatform(this->X,this->Y))
						this->Y++;
					if(Link->Y+16< this->Y
						&& Link->Y>this->Y-16){
						if(Link->X+16> this->X
							&& Link->X< this->X+16){
							if(GetEquipmentB()!=I_ROCSFEATHER)
								Link->Jump=0;
							else{
								if(!Link->PressB
									&& !Link->InputB)
									Link->Jump=0;
							}
						}
					}	
				}
				loc = ComboAt(this->X+8,this->Y+8);
				if(Is_Switch(loc)){
					Screen->ComboD[loc]++;
					Game->PlaySound(SFX_SWITCH_PUSH);
					Switch_Spot= loc;
					if(!Pressed){
						for(i= 0;i<=175;i++){
							if(Screen->ComboF[i]==CF_SOMARIA)
								Screen->ComboD[i]++;
						}
						Pressed= true;
					}
				}
				else{
					if(loc!=Switch_Spot){
						if(ComboArray[Switch_Spot]!=-1){
							Screen->ComboD[Switch_Spot]=ComboArray[Switch_Spot];
							Switch_Spot= 0;
							if(Pressed){
								for(i= 0;i<=175;i++){
									if(Screen->ComboF[i]==CF_SOMARIA)
										Screen->ComboD[i]--;
								}
								Pressed= false;
							}
						}
					}
				}
				Waitframe();
			}
			if(IsSideview()){
				if(!OnSidePlatform(this->X,this->Y))
					this->Y++;
			}
			Push_Counter = 0;
			Waitframe();
		}
	}
}