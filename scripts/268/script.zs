const int CF_ELEVATOR = 98; //Combo flag marking elevator tracks
const int CF_ELEVATORSTOP = 99; //Combo flag marking that you can get off an elevator

const int SFX_ELEVATOR_START = 6; //Sound that plays when an elevator starts moving
const int SFX_ELEVATOR_PERSISTENT = 17; //Sound that plays while an elevator moves

const int ELEVATOR_SFX_FREQ = 4; //How often the persistent sound plays

const int ELEVATOR_STEP = 4; //How fast elevators move along tracks

const int LM_ACTION = 0; //Link->Misc for special actions
const int LMA_ON_ELEVATOR = 1; //Link->Misc state for being on an elevator

ffc script Elevator{
	void run(int offX, int offY, int combo){
		int elevatorX = this->X+offX;
		int elevatorY = this->Y+offY;
		int elevatorDir;
		int targetX; int targetY;
		int sfxTimer;
		bool onElevator;
		int data = this->Data;
		this->Data = FFCS_INVISIBLE_COMBO;
		Waitframe();
		if(combo>0){
			if(Link->Misc[LM_ACTION]==LMA_ON_ELEVATOR){
				this->Data = combo;
			}
			else{
				Quit();
			}
		}
		else
			this->Data = data;
		if(Link->Misc[LM_ACTION]==LMA_ON_ELEVATOR&&ComboFI(Link->X+8, Link->Y+8, CF_ELEVATOR)){
			elevatorX = ComboX(ComboAt(Link->X+8, Link->Y+8));
			elevatorY = ComboY(ComboAt(Link->X+8, Link->Y+8));
			this->X = elevatorX-offX;
			this->Y = elevatorY-offY;
			
			if(elevatorX==0)
				elevatorDir = DIR_RIGHT;
			else if(elevatorX==240)
				elevatorDir = DIR_LEFT;
			else if(elevatorY==0)
				elevatorDir = DIR_DOWN;
			else if(elevatorY==160)
				elevatorDir = DIR_UP;
			
			targetX = ElevatorTargetX(elevatorX, elevatorY, elevatorDir);
			targetY = ElevatorTargetY(elevatorX, elevatorY, elevatorDir);
			Link->Misc[LM_ACTION] = LMA_ON_ELEVATOR;
		}
		else if(Link->Misc[LM_ACTION]==LMA_ON_ELEVATOR)
			Link->Misc[LM_ACTION] = 0;
		while(true){
			while(Link->Misc[LM_ACTION]==LMA_ON_ELEVATOR){
				while(Distance(elevatorX, elevatorY, targetX, targetY)>ELEVATOR_STEP){
					if(SFX_ELEVATOR_PERSISTENT>0){
						sfxTimer++;
						if(sfxTimer>ELEVATOR_SFX_FREQ){
							sfxTimer = 0;
							Game->PlaySound(SFX_ELEVATOR_PERSISTENT);
						}
					}
					int angle = Angle(elevatorX, elevatorY, targetX, targetY);
					elevatorX += VectorX(ELEVATOR_STEP, angle);
					elevatorY += VectorY(ELEVATOR_STEP, angle);
					this->X = elevatorX-offX;
					this->Y = elevatorY-offY;
					Link->X = elevatorX;
					Link->Y = elevatorY;
					Link->Jump = 0;
					Waitframe();
				}
				elevatorX = targetX;
				elevatorY = targetY;
				this->X = elevatorX-offX;
				this->Y = elevatorY-offY;
				Link->X = elevatorX;
				Link->Y = elevatorY;
				if(ComboFI(elevatorX+8, elevatorY+8, CF_ELEVATORSTOP)){
					Link->Misc[LM_ACTION] = 0;
					if(Link->InputUp&&CheckElevator(elevatorX, elevatorY, DIR_UP)){
						elevatorDir = DIR_UP;
						targetX = ElevatorTargetX(elevatorX, elevatorY, elevatorDir);
						targetY = ElevatorTargetY(elevatorX, elevatorY, elevatorDir);
						Link->Misc[LM_ACTION] = LMA_ON_ELEVATOR;
					}
					else if(Link->InputDown&&CheckElevator(elevatorX, elevatorY, DIR_DOWN)){
						elevatorDir = DIR_DOWN;
						targetX = ElevatorTargetX(elevatorX, elevatorY, elevatorDir);
						targetY = ElevatorTargetY(elevatorX, elevatorY, elevatorDir);
						Link->Misc[LM_ACTION] = LMA_ON_ELEVATOR;
					}
					else if(Link->InputLeft&&CheckElevator(elevatorX, elevatorY, DIR_LEFT)){
						elevatorDir = DIR_LEFT;
						targetX = ElevatorTargetX(elevatorX, elevatorY, elevatorDir);
						targetY = ElevatorTargetY(elevatorX, elevatorY, elevatorDir);
						Link->Misc[LM_ACTION] = LMA_ON_ELEVATOR;
					}
					else if(Link->InputRight&&CheckElevator(elevatorX, elevatorY, DIR_RIGHT)){
						elevatorDir = DIR_RIGHT;
						targetX = ElevatorTargetX(elevatorX, elevatorY, elevatorDir);
						targetY = ElevatorTargetY(elevatorX, elevatorY, elevatorDir);
						Link->Misc[LM_ACTION] = LMA_ON_ELEVATOR;
					}
					else{
						while(!Link->PressUp&&!Link->PressDown&&!Link->PressLeft&&!Link->PressRight){
							Waitframe();
						}
						Waitframe();
					}
				}
				else{
					int oldDir = elevatorDir;
					elevatorDir = -1;
					for(int i=0; i<4&&elevatorDir==-1; i++){
						if(OppositeDir(oldDir)!=i){
							if(CheckElevator(elevatorX, elevatorY, i))
								elevatorDir = i;
						}
					}
					if(elevatorDir==-1)
						elevatorDir = oldDir;
					targetX = ElevatorTargetX(elevatorX, elevatorY, elevatorDir);
					targetY = ElevatorTargetY(elevatorX, elevatorY, elevatorDir);
					if(ElevatorNumBranches(elevatorX, elevatorY)>2){
						elevatorDir = -1;
						while(elevatorDir==-1){
							this->X = elevatorX-offX;
							this->Y = elevatorY-offY;
							Link->X = elevatorX;
							Link->Y = elevatorY;
							Link->Jump = 0;
							if(Link->InputUp&&CheckElevator(elevatorX, elevatorY, DIR_UP)){
								elevatorDir = DIR_UP;
								targetX = ElevatorTargetX(elevatorX, elevatorY, elevatorDir);
								targetY = ElevatorTargetY(elevatorX, elevatorY, elevatorDir);
								Link->Misc[LM_ACTION] = LMA_ON_ELEVATOR;
							}
							else if(Link->InputDown&&CheckElevator(elevatorX, elevatorY, DIR_DOWN)){
								elevatorDir = DIR_DOWN;
								targetX = ElevatorTargetX(elevatorX, elevatorY, elevatorDir);
								targetY = ElevatorTargetY(elevatorX, elevatorY, elevatorDir);
								Link->Misc[LM_ACTION] = LMA_ON_ELEVATOR;
							}
							else if(Link->InputLeft&&CheckElevator(elevatorX, elevatorY, DIR_LEFT)){
								elevatorDir = DIR_LEFT;
								targetX = ElevatorTargetX(elevatorX, elevatorY, elevatorDir);
								targetY = ElevatorTargetY(elevatorX, elevatorY, elevatorDir);
								Link->Misc[LM_ACTION] = LMA_ON_ELEVATOR;
							}
							else if(Link->InputRight&&CheckElevator(elevatorX, elevatorY, DIR_RIGHT)){
								elevatorDir = DIR_RIGHT;
								targetX = ElevatorTargetX(elevatorX, elevatorY, elevatorDir);
								targetY = ElevatorTargetY(elevatorX, elevatorY, elevatorDir);
								Link->Misc[LM_ACTION] = LMA_ON_ELEVATOR;
							}
							Waitframe();
						}
					}
				}
			}
			if(Distance(elevatorX, elevatorY, Link->X, Link->Y)<8){
				if(Link->Dir==DIR_UP&&Link->PressUp&&CheckElevator(elevatorX, elevatorY, DIR_UP)){
					elevatorDir = DIR_UP;
					targetX = ElevatorTargetX(elevatorX, elevatorY, elevatorDir);
					targetY = ElevatorTargetY(elevatorX, elevatorY, elevatorDir);
					Link->Misc[LM_ACTION] = LMA_ON_ELEVATOR;
					Game->PlaySound(SFX_ELEVATOR_START);
				}
				else if(Link->Dir==DIR_DOWN&&Link->PressDown&&CheckElevator(elevatorX, elevatorY, DIR_DOWN)){
					elevatorDir = DIR_DOWN;
					targetX = ElevatorTargetX(elevatorX, elevatorY, elevatorDir);
					targetY = ElevatorTargetY(elevatorX, elevatorY, elevatorDir);
					Link->Misc[LM_ACTION] = LMA_ON_ELEVATOR;
					Game->PlaySound(SFX_ELEVATOR_START);
				}
				else if(Link->Dir==DIR_LEFT&&Link->PressLeft&&CheckElevator(elevatorX, elevatorY, DIR_LEFT)){
					elevatorDir = DIR_LEFT;
					targetX = ElevatorTargetX(elevatorX, elevatorY, elevatorDir);
					targetY = ElevatorTargetY(elevatorX, elevatorY, elevatorDir);
					Link->Misc[LM_ACTION] = LMA_ON_ELEVATOR;
					Game->PlaySound(SFX_ELEVATOR_START);
				}
				else if(Link->Dir==DIR_RIGHT&&Link->PressRight&&CheckElevator(elevatorX, elevatorY, DIR_RIGHT)){
					elevatorDir = DIR_RIGHT;
					targetX = ElevatorTargetX(elevatorX, elevatorY, elevatorDir);
					targetY = ElevatorTargetY(elevatorX, elevatorY, elevatorDir);
					Link->Misc[LM_ACTION] = LMA_ON_ELEVATOR;
					Game->PlaySound(SFX_ELEVATOR_START);
				}
			}
			Waitframe();
		}
	}
	bool CheckElevator(int elevatorX, int elevatorY, int elevatorDir){
		int x; int y;
		if(elevatorDir==DIR_UP){
			x = elevatorX+8;
			y = elevatorY-8;
			if(ComboFI(x, y, CF_ELEVATOR)||ComboFI(x, y, CF_ELEVATORSTOP))
				return true;
		}
		else if(elevatorDir==DIR_DOWN){
			x = elevatorX+8;
			y = elevatorY+24;
			if(ComboFI(x, y, CF_ELEVATOR)||ComboFI(x, y, CF_ELEVATORSTOP))
				return true;
		}
		else if(elevatorDir==DIR_LEFT){
			x = elevatorX-8;
			y = elevatorY+8;
			if(ComboFI(x, y, CF_ELEVATOR)||ComboFI(x, y, CF_ELEVATORSTOP))
				return true;
		}
		else if(elevatorDir==DIR_RIGHT){
			x = elevatorX+24;
			y = elevatorY+8;
			if(ComboFI(x, y, CF_ELEVATOR)||ComboFI(x, y, CF_ELEVATORSTOP))
				return true;
		}
		return false;
	}
	int ElevatorNumBranches(int elevatorX, int elevatorY){
		int count;
		for(int i=0; i<4; i++){
			if(CheckElevator(elevatorX, elevatorY, i))
				count++;
		}
		return count;
	}
	int ElevatorTargetX(int elevatorX, int elevatorY, int elevatorDir){
		if(elevatorDir==DIR_LEFT)
			return elevatorX-16;
		else if(elevatorDir==DIR_RIGHT)
			return elevatorX+16;
		else
			return elevatorX;
	}
	int ElevatorTargetY(int elevatorX, int elevatorY, int elevatorDir){
		if(elevatorDir==DIR_UP)
			return elevatorY-16;
		else if(elevatorDir==DIR_DOWN)
			return elevatorY+16;
		else
			return elevatorY;
	}
}