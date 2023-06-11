const int COMBOFX_NOT_TRIGGERED_BY_PUSH = 1; //Set to 1 if you don't want push blocks triggering slash effects (like with a pushable pot)

const int NPC_COMBOSFX_DROPSET = 85; //Item dropset enemy (Fire by default)
const int COMBOSFX_CHECKALL = 0; //If set to 1, the script will check all combos on screen every frame. This is generally slower and not advised, but there may be cases you'd want this.

void CSA_AutoSlashable_Update(int lastDMapScreen){
	if(lastDMapScreen[0]!=Game->GetCurDMap()||lastDMapScreen[1]!=Game->GetCurDMapScreen()){
		int i; int j; int k;
		
		int autoSlashableID[65280];
		int autoSlashableData[2056];
		autoSlashableData[0] = 0;
		
		//AUTO SLASHABLES HERE
		//Add your auto slashables with the provided function here
		//                                                         COMBO   SFX     TYPE    GFX     CS      FRAMES  ASPEED  RAND/DROPSET
		//EXAMPLE: 
		//CSA_AddAutoSlashable(autoSlashableID, autoSlashableData, 7680,   41,     2,      52020,  2,      0,      0,      0); //Bush - Green
		
		
		
		//End of auto slashables
		
		for(i=0; i<176; i++){
			int cd = Screen->ComboD[i];
			if(autoSlashableID[cd]){
				int scr[] = "ComboSFXAnim";
				int args[8];
				k = autoSlashableID[cd];
				for(j=0; j<8; j++){
					args[j] = autoSlashableData[k*8+j];
				}
				
				RunFFCScript(Game->GetFFCScript(scr), args);
				
				autoSlashableID[cd] = 0;
			}
		}
		
		lastDMapScreen[0] = Game->GetCurDMap();
		lastDMapScreen[1] = Game->GetCurDMapScreen();
	}
}

ffc script ComboSFXAnim{
	void run(int combo, int sfx, int type, int gfx, int cs, int frames, int aspeed, int rand_or_dropset){
		int i; int j; int k;
		int comboCount; //Max index of positions[]
		int positions[176]; //Keeps track of all combo position (0-175) currently being tracked
		int lastCombo[176]; //Last known combo of every position onscreen
		bool hadCombo[176]; //Used for when COMBOSFX_CHECKALL is used in combination with negative combo ID
		
		//Negative combo ID makes it animate every time the combo changes
		bool everyFrame = false;
		if(combo<0){
			combo = Abs(combo);
			everyFrame = true;
		}
		
		for(i=0; i<176; i++){
			positions[i] = -1;
			lastCombo[i] = Screen->ComboD[i];
		}
		//Find all valid combos
		for(i=0; i<176; i++){
			if(Screen->ComboD[i]==combo||COMBOSFX_CHECKALL){
				positions[comboCount] = i;
				if(Screen->ComboD[i]==combo)
					hadCombo[i] = true;
				comboCount++;
			}
		}
		
		int lastMovingBlockX;
		int lastMovingBlockY;
		int movingBlockPositionIndex = -1; //Array index for the moving block's combo position
		
		while(true){
			bool blockStartedMoving = false;
			bool blockStoppedMoving = false;
			//If the push block is active
			if(Screen->MovingBlockX>-1&&Screen->MovingBlockY>-1){
				//If this is the first frame it was active
				if(lastMovingBlockX==-1){
					blockStartedMoving = true;
				}
			}
			//If the push block was previously active
			if(lastMovingBlockX>-1&&lastMovingBlockY>-1){
				//If it isn't active anymore
				if(Screen->MovingBlockX==-1){
					blockStoppedMoving = true;
				}
			}
							
			//Only check combos that had the right ID on init
			for(i=0; i<comboCount; i++){
				j = positions[i];
				if(j>-1){
					//Whenever it changes
					if(Screen->ComboD[j]!=lastCombo[j]){
						//Keeps track of whether a push block triggered the combo change
						bool wasPushBlockTriggered;
						if(COMBOFX_NOT_TRIGGERED_BY_PUSH){
							if(blockStartedMoving){
								//If the push block was triggered by this combo
								if(ComboAt(Screen->MovingBlockX+8, Screen->MovingBlockY+8)==j){
									wasPushBlockTriggered = true;
								}
							}
							if(blockStoppedMoving){
								//If the push block ended up on this combo
								if(ComboAt(lastMovingBlockX+8, lastMovingBlockY+8)==j){
									wasPushBlockTriggered = true;
								}
							}
						}
						
						if(Screen->ComboD[j]==combo)
							hadCombo[j] = true;
						//Do the animation if other conditions are right
						bool doAnim = false;
						if(!everyFrame){
							if(lastCombo[j]==combo)
								doAnim = true;
						}
						else{
							if(hadCombo[j])
								doAnim = true;
						}
						
						if(wasPushBlockTriggered)
							doAnim = false;
						
						if(doAnim){
							Game->PlaySound(sfx);
							//Create and kill an enemy if the dropset is set
							if(rand_or_dropset<0){
								npc n = CreateNPCAt(NPC_COMBOSFX_DROPSET, ComboX(j), ComboY(j));
								n->ItemSet = Abs(rand_or_dropset);
								n->HP = -1000;
								n->DrawYOffset = -1000;
							}
							if(type>1){ //Particle animations
								int scr[] = "CSA_Animations";
								int args[8];
								args[0] = type-2;
								args[1] = gfx;
								args[2] = cs;
								args[3] = frames;
								args[4] = aspeed;
								args[5] = rand_or_dropset;
								ffc f = Screen->LoadFFC(RunFFCScript(Game->GetFFCScript(scr), args));
								f->X = ComboX(j);
								f->Y = ComboY(j);
							}
							else if(type==1){ //Sprite animation
								lweapon poof = CreateLWeaponAt(LW_SCRIPT10, ComboX(j), ComboY(j));
								poof->UseSprite(gfx);
								poof->DrawYOffset = 0;
								if(cs>0)
									poof->CSet = cs;
								poof->DeadState = poof->NumFrames*poof->ASpeed;
								if(rand_or_dropset>1){
									poof->OriginalTile += Rand(rand_or_dropset)*poof->NumFrames;
									poof->Tile = poof->OriginalTile;
								}
							}
						}
						lastCombo[j] = Screen->ComboD[j];
					}
				}
			}
			
			if(blockStartedMoving){
				//Find if the moving block is starting on one of the combo positions in the array
				k = ComboAt(Screen->MovingBlockX+8, Screen->MovingBlockY+8);
				for(i=0; i<comboCount; i++){
					j = positions[i];
					if(j==k){
						movingBlockPositionIndex = i;
						break;
					}
				}
			}
			else if(blockStoppedMoving){
				//If the moving block was in the array, update its position
				if(movingBlockPositionIndex>-1){
					k = ComboAt(lastMovingBlockX+8, lastMovingBlockY+8);
					positions[movingBlockPositionIndex] = k;
				}
				movingBlockPositionIndex = -1;
			}
			
			lastMovingBlockX = Screen->MovingBlockX;
			lastMovingBlockY = Screen->MovingBlockY;
			Waitframe();
		}
	}
}

ffc script CSA_Animations{
	void run(int type, int gfx, int cs, int frames, int aspeed, int rand_or_dropset){
		this->Flags[FFCF_ETHEREAL] = true;
		int i; int j; int k;
		int thisNum;
		for(i=1; i<=32; i++){
			ffc f = Screen->LoadFFC(i);
			if(f->Script==this->Script){
				if(f==this)
					break;
				else
					thisNum++;
			}
		}
		
		
		if(type==0){ //Bush leaves
			for(i=0; i<8; i++){
				for(j=0; j<3; j++){
					TileAnim_BushAnim(this->X-8, this->Y, gfx, cs, i, thisNum);
					Waitframe();
				}
			}
		}
		else{
			int particleX[32];
			int particleY[32];
			int particleTile[32];
			int particleA[32];
			int particleS[32];
			int particleT[32];
			int particleMT[32];
			int particleAnim[32];
			int particle[16] = {999, particleX, particleY, particleTile, particleA, particleS, particleT, particleMT, particleAnim};
			if(type==1){ //Random spread
				for(i=0; i<12; i++){
					j = gfx;
					if(rand_or_dropset>1)
						j += Rand(rand_or_dropset)*Max(frames, 1);
					Particle_Add(particle, this->X+Rand(-4, 4), this->Y+Rand(-4, 4), j, Rand(360), Rand(20, 120)/100, Rand(12, 18));
				}
				//Run until all particles are dead
				while(particle[0]>0){
					Particle_Update(particle, frames, aspeed, cs);
					Waitframe();
				}
			}
			else if(type==2){ //Aimed spread
				k = Angle(Link->X, Link->Y, this->X, this->Y);
				for(i=0; i<6; i++){
					j = gfx;
					if(rand_or_dropset>1)
						j += Rand(rand_or_dropset)*Max(frames, 1);
					Particle_Add(particle, this->X+Rand(-4, 4), this->Y+Rand(-4, 4), j, k+Rand(-20, 20), Rand(5, 20)/10, Rand(12, 18));
				}
				//Run until all particles are dead
				while(particle[0]>0){
					Particle_Update(particle, frames, aspeed, cs);
					Waitframe();
				}
			}
		}
	}
	void Particle_Update(int particle, int frames, int aspeed, int cs){
		int particleX = particle[1];
		int particleY = particle[2];
		int particleTile = particle[3];
		int particleA = particle[4];
		int particleS = particle[5];
		int particleT = particle[6];
		int particleMT = particle[7];
		int particleAnim = particle[8];
		particle[0] = 0; //Reset particle counter for the frame
		for(int i=0; i<32; i++){
			if(particleT[i]>0){
				particle[0]++;
				
				//Movement
				particleX[i] += VectorX(particleS[i], particleA[i]);
				particleY[i] += VectorY(particleS[i], particleA[i]);
				
				//Animations
				int til = particleTile[i];
				if(frames>0){
					if(aspeed==0){
						int j = Floor((particleMT[i]-particleT[i])/(particleMT[i]/frames));
						til = particleTile[i]+Clamp(j, 0, frames-1);
					}
					else{
						til = particleTile[i] + Floor(particleAnim[i]/aspeed);
						particleAnim[i] = (particleAnim[i]+1)%(frames*aspeed);
					}
				}
				
				//Drawing
				Screen->FastTile(4, particleX[i], particleY[i], til, cs, 128);
				particleT[i]--;
			}
		}
	}
	int Particle_Add(int particle, int x, int y, int tile, int angle, int step, int time){
		int particleX = particle[1];
		int particleY = particle[2];
		int particleTile = particle[3];
		int particleA = particle[4];
		int particleS = particle[5];
		int particleT = particle[6];
		int particleMT = particle[7];
		int particleAnim = particle[8];
		for(int i=0; i<32; i++){
			//Find unused particle, set the stuff
			if(particleT[i]==0){
				particleX[i] = x;
				particleY[i] = y;
				particleTile[i] = tile;
				particleA[i] = angle;
				particleS[i] = step;
				particleT[i] = time;
				particleMT[i] = time;
				particleAnim[i] = 0;
				return i;
			}
		}
	}
	void TileAnim_BushAnim(int x, int y, int tile, int cset, int frame, int thisNum){
		int posX[32] = {16, 6,  20, 14, //Frame 1
						16, 9,  17, 14, //Frame 2
						17, 10, 14, 12, //Frame 3
						17, 11, 15, 11, //Frame 4
						19, 8,  18, 10, //Frame 5
						20, 4,  19, 9,  //Frame 6
						21, 3,  22, 8,  //Frame 7
						14, 1,  16, 7}; //Frame 8
						
						
		int posY[32] = {11, 8,  7,   1, //Frame 1 
						14, 9,  8,  -1, //Frame 2
						16, 10, 10, -2, //Frame 3
						18, 10, 10, -3, //Frame 4
						20, 10, 14, -4, //Frame 5
						21, 10, 14, -6, //Frame 6
						23, 9,  14, -9, //Frame 7
						24, 7,  21, -11};//Frame 8
						
		int flip[32] = {0,  0,  1,  0,  //Frame 1
						0,  0,  1,  0,  //Frame 2
						1,  0,  1,  0,  //Frame 3
						0,  1,  0,  3,  //Frame 4
						0,  1,  0,  0,  //Frame 5
						0,  0,  0,  0,  //Frame 6
						0,  0,  1,  0,  //Frame 7
						1,  1,  0,  0}; //Frame 8
		
		for(int i=0; i<4; i++){
			Screen->DrawTile(4, x+posX[frame*4+i]-4, y+posY[frame*4+i]-4, tile+i, 1, 1, cset, -1, -1, 0, 0, 0, flip[frame*4+i], true, 128);
		}
	}
}

void CSA_AddAutoSlashable(int autoSlashableID, int autoSlashableData, int combo, int sfx, int type, int gfx, int cs, int frames, int aspeed, int rand_or_dropset){
	++autoSlashableData[0];
	int k = autoSlashableData[0];
	
	autoSlashableID[combo] = k;
	
	autoSlashableData[k*8+0] = combo;
	autoSlashableData[k*8+1] = sfx;
	autoSlashableData[k*8+2] = type;
	autoSlashableData[k*8+3] = gfx;
	autoSlashableData[k*8+4] = cs;
	autoSlashableData[k*8+5] = frames;
	autoSlashableData[k*8+6] = aspeed;
	autoSlashableData[k*8+7] = rand_or_dropset;
	
	autoSlashableData[0] = Min(autoSlashableData[0], 256);
}

global script CSA_AutoSlashable_Example{
	void run(){
		int lastDMapScreen[2];
		while(true){
			CSA_AutoSlashable_Update(lastDMapScreen);
			Waitdraw();
			Waitframe();
		}
	}
}