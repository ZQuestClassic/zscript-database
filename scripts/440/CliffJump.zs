const bool CLIFF_DEBUG = false; //Used for debugging combo setups, will show direction values of all cliffs on the screen
const bool CLIFF_BREAK_SLASHABLES = true; //If true, Link can jump down onto slashables and they'll break when he lands
const bool CLIFF_CHECK_LAYER_BARRIERS = true; //If true, solidity layered over a cliff on layers 1 and 2 will block its use

const int CLIFF_JUMP = 1.6; //Jump value for jumping off cliffs
const int CLIFF_PUSH_TIME = 16; //Frames Link has to push against a cliff before jumping

const int LW_CLIFF_FAKESWORD = LW_SCRIPT10; //Weapon type used for faking a sword hitbox
/*
All cliff combos Link can jump over should have this script. Their arguments should be set as follows
InitD[0]: Jump Direction
			0 - No Jump
			1 - Up
			2 - Down
			3 - Left
			4 - Right
			5 - Up-Left
			6 - Up-Right
			7 - Down-Left
			8 - Down-Right
InitD[1]: GB Cliff Height. If >0, Left, Right, and Down facing cliffs will behave differently, to work with Gameboy style cliffs.
			For left and right facing cliff, the value will affect how far down Link gets shifted after jumping off in half tiles
*/
combodata script CliffJump{
	//Returns a combo position if Link is facing a cliff, -1 if not
	int Cliff_FacingCliffPos(int scriptID){
		int LinkX = Link->X;
		int LinkY = Link->Y+8;
		int w = 15;
		int h = 7;
		if(Link->BigHitbox){
			LinkY = Link->Y;
			h = 15;
		}
		
		int collisionPos[] = {-1, -1, -1};
		int collisionDir[] = {-1, -1, -1};
		/*
			For each direction we:
			-Check if the player is pressing the dirctional button
			-Loop through three points starting from the center of the hitbox
			-Check if the point is solid
			-Check if the point is using this script
			
			When these conditions are met, Link is facing a cliff
		*/
		switch(Link->Dir){
			case DIR_UP:
				if(!Link->InputUp)
					return -1;
				if(LinkY<1)
					return -1;
				int offs[3] = {8, 0, 15};
				for(int i=0; i<3; ++i){
					int x = LinkX+offs[i];
					int y = LinkY-1;
					if(Screen->isSolid(x, y)){
						int pos = ComboAt(x, y);
						combodata cd = Game->LoadComboData(Screen->ComboD[pos]);
						if(cd->Script==scriptID){
							if(!Cliff_IsSolidLayer(scriptID, x, y, true)){
								collisionPos[i] = pos;
								collisionDir[i] = cd->InitD[0]-1;
							}
						}
					}
				}
				break;
			case DIR_DOWN:
				if(!Link->InputDown)
					return -1;
				if(LinkY>159)
					return -1;
				int offs[3] = {8, 0, 15};
				for(int i=0; i<3; ++i){
					int x = LinkX+offs[i];
					int y = LinkY+h+1;
					if(Screen->isSolid(x, y)){
						int pos = ComboAt(x, y);
						combodata cd = Game->LoadComboData(Screen->ComboD[pos]);
						if(cd->Script==scriptID){
							if(!Cliff_IsSolidLayer(scriptID, x, y, true)){
								collisionPos[i] = pos;
								collisionDir[i] = cd->InitD[0]-1;
							}
						}
					}
				}
				break;
			case DIR_LEFT:
				if(!Link->InputLeft)
					return -1;
				if(LinkX<1)
					return -1;
				int offs[3] = {4, 0, 7};
				if(Link->BigHitbox){
					offs[0] = 8;
					offs[1] = 0;
					offs[2] = 15;
				}
				for(int i=0; i<3; ++i){
					int x = LinkX-1;
					int y = LinkY+offs[i];
					if(Screen->isSolid(x, y)){
						int pos = ComboAt(x, y);
						combodata cd = Game->LoadComboData(Screen->ComboD[pos]);
						if(cd->Script==scriptID){
							if(!Cliff_IsSolidLayer(scriptID, x, y, true)){
								collisionPos[i] = pos;
								collisionDir[i] = cd->InitD[0]-1;
							}
						}
					}
				}
				break;
			case DIR_RIGHT:
				if(!Link->InputRight)
					return -1;
				if(LinkX>239)
					return -1;
				int offs[3] = {4, 0, 7};
				if(Link->BigHitbox){
					offs[0] = 8;
					offs[1] = 0;
					offs[2] = 15;
				}
				for(int i=0; i<3; ++i){
					int x = LinkX+w+1;
					int y = LinkY+offs[i];
					if(Screen->isSolid(x, y)){
						int pos = ComboAt(x, y);
						combodata cd = Game->LoadComboData(Screen->ComboD[pos]);
						if(cd->Script==scriptID){
							if(!Cliff_IsSolidLayer(scriptID, x, y, true)){
								collisionPos[i] = pos;
								collisionDir[i] = cd->InitD[0]-1;
							}
						}
					}
				}
				break;
		}
		return Cliff_CollisionPriority(collisionPos, collisionDir);
	}
	//Prioritize 4-direction collisions over diagonal
	int Cliff_CollisionPriority(int collisionPos, int collisionDir){
		for(int i=0; i<3; ++i){
			if(collisionPos[i]>-1&&collisionDir[i]<DIR_LEFTUP)
				return collisionPos[i];
		}
		for(int i=0; i<3; ++i){
			if(collisionPos[i]>-1)
				return collisionPos[i];
		}
		return -1;
	}
	//Returns true if there's solidity layered over a cliff (borders)
	bool Cliff_IsSolidLayer(int scriptID, int x, int y, bool checkSetting){
		if(!CLIFF_CHECK_LAYER_BARRIERS&&checkSetting)
			return false;
		
		int s;
		int pos = ComboAt(x, y);
		if(Screen->LayerMap(1)>-1){
			mapdata l1 = Game->LoadTempScreen(1);
			combodata l1cd = Game->LoadComboData(l1->ComboD[pos]);
			if(l1cd->Script!=scriptID)
				s |= l1cd->Walk;
		}
		if(Screen->LayerMap(2)>-1){
			mapdata l2 = Game->LoadTempScreen(2);
			combodata l2cd = Game->LoadComboData(l2->ComboD[pos]);
			if(l2cd->Script!=scriptID)
				s |= l2cd->Walk;
		}
		
		if(x%16<8){
			if(y%16<8){
				return s&0x1;
			}
			else{
				return s&0x2;
			}
		}
		else{
			if(y%16<8){
				return s&0x4;
			}
			else{
				return s&0x8;
			}
		}
	}
	//Returns true if Link would be touching a cliff at this position
	bool Cliff_Collision(int scriptID, int posX, int posY){
		int offX = 0;
		int offY = 8;
		int w = 15;
		int h = 7;
		if(Link->BigHitbox){
			offY = 0;
			h = 15;
		}
		if(posX<0||posX>240||posY<0||posY>160)
			return false;
		bool collided = false; //Collision is true when one of the 9 points has a cliff under it
		for(int x=posX+offX; x<=posX+offX+w; x=Min(x+8, posX+offX+w)){
			for(int y=posY+offY; y<=posY+offY+h; y=Min(y+8, posY+offY+h)){
				if(Screen->isSolid(x, y)){
					int pos = ComboAt(x, y);
					combodata cd = Game->LoadComboData(Screen->ComboD[pos]);
					if(cd->Script==scriptID){
						if(Cliff_IsSolidLayer(scriptID, x, y, true))
							return false;
						else
							collided = true;
					}
				}
				if(y==posY+offY+h)
					break;
			}
			if(x==posX+offX+w)
				break;
		}
		return collided;
	}
	//Returns true if Link would be touching a cliff at this position
	bool Cliff_CanLand(int scriptID, int posX, int posY){
		int offX = 0;
		int offY = 8;
		int w = 15;
		int h = 7;
		if(Link->BigHitbox){
			offY = 0;
			h = 15;
		}
		if(posX<0||posX>240||posY<0||posY>160)
			return false;
		for(int x=posX+offX; x<=posX+offX+w; x=Min(x+8, posX+offX+w)){
			for(int y=posY+offY; y<=posY+offY+h; y=Min(y+8, posY+offY+h)){
				if(Screen->isSolid(x, y)){
					combodata cd = Game->LoadComboData(Screen->ComboD[ComboAt(x, y)]);
					//If the solidity isn't from a slashable, the landing point isn't valid
					if(!(Cliff_IsSlashable(cd, scriptID, x, y)&&CLIFF_BREAK_SLASHABLES))
						return false;
				}
				if(y==posY+offY+h)
					break;
			}
			if(x==posX+offX+w)
				break;
		}
		return true;
	}
	//Creates sword weapons on top of slashable combos
	void Cliff_TriggerSlashables(int scriptID, int posX, int posY){
		int offX = 0;
		int offY = 8;
		int w = 15;
		int h = 7;
		if(Link->BigHitbox){
			offY = 0;
			h = 15;
		}
		for(int x=posX+offX; x<=posX+offX+w; x=Min(x+8, posX+offX+w)){
			for(int y=posY+offY; y<=posY+offY+h; y=Min(y+8, posY+offY+h)){
				if(Screen->isSolid(x, y)){
					combodata cd = Game->LoadComboData(Screen->ComboD[ComboAt(x, y)]);
					if(Cliff_IsSlashable(cd, scriptID, x, y)){
						lweapon l = CreateLWeaponAt(LW_CLIFF_FAKESWORD, GridX(x), GridY(y));
						l->DrawYOffset = -1000;
						l->CollDetection = false;
						l->DeadState = 1;
						l->Weapon = LW_SWORD;
					}
				}
				if(y==posY+offY+h)
					break;
			}
			if(x==posX+offX+w)
				break;
		}
	}
	//Returns true if a combo is slashable
	bool Cliff_IsSlashable(combodata cd, int scriptID, int x, int y){
		switch(cd->Type){
			case CT_SLASH:
			case CT_SLASHITEM:
			case CT_SLASHNEXT:
			case CT_SLASHNEXTITEM:
			case CT_SLASHC:
			case CT_SLASHITEMC:
			case CT_SLASHNEXTC:
			case CT_SLASHNEXTITEMC:
			case CT_BUSH:
			case CT_BUSHNEXT:
			case CT_BUSHC:
			case CT_BUSHNEXTC:
			case CT_FLOWERS:
			case CT_FLOWERSC:
			case CT_TALLGRASS:
			case CT_TALLGRASSC:
			case CT_TALLGRASSNEXT:
				if(!Cliff_IsSolidLayer(scriptID, x, y, false))
					return true;
				break;
			case CT_GENERIC:
				//Sword trigger and ->Next
				if(cd->TriggerFlags[0]&0x1&&cd->Flags[3]){
					if(!Cliff_IsSolidLayer(scriptID, x, y, false))
						return true;
				}
				return false;
		}
		return false;
	}
	//This janky hack of a function approximates ZC jump lengths by using a table, becuase I hate doing math
	int Cliff_FindJumpLength(int jumpInput, bool inputFrames){
		//Big ol table of rough jump values and their durations
		int jumpTBL[] = 
		{
			0.0, 0,
			0.1, 3,
			0.2, 4,
			0.3, 5,
			0.4, 6,
			0.5, 8,
			0.6, 9,
			0.7, 10,
			0.8, 11,
			0.9, 13,
			1.0, 14,
			1.1, 15,
			1.2, 16,
			1.3, 18,
			1.4, 19,
			1.5, 20,
			1.6, 21,
			1.7, 23,
			1.8, 24,
			1.9, 25,
			2.0, 26,
			2.1, 28,
			2.2, 29,
			2.3, 30,
			2.4, 31,
			2.5, 33,
			2.6, 34,
			2.7, 35,
			2.8, 36,
			2.9, 38,
			3.0, 39,
			3.1, 40,
			3.2, 41,
			3.3, 43,
			3.4, 44,
			3.5, 45,
			3.6, 47,
			3.7, 48,
			3.8, 49,
			3.9, 51,
			4.0, 52,
			4.1, 54,
			4.2, 55,
			4.3, 57,
			4.4, 58,
			4.5, 60,
			4.6, 61,
			4.7, 63,
			4.8, 64,
			4.9, 66,
			5.0, 67,
			5.1, 69,
			5.2, 71,
			5.3, 72,
			5.4, 74,
			5.5, 76,
			5.6, 77,
			5.7, 79,
			5.8, 81,
			5.9, 83,
			6.0, 85,
			6.1, 86,
			6.2, 88,
			6.3, 90,
			6.4, 92,
			6.5, 94,
			6.6, 96,
			6.7, 98,
			6.8, 100,
			6.9, 102,
			7.0, 104,
			7.1, 106,
			7.2, 108,
			7.3, 110,
			7.4, 112,
			7.5, 114,
			7.6, 116,
			7.7, 118,
			7.8, 120,
			7.9, 123,
			8.0, 125,
			8.1, 127,
			8.2, 129,
			8.3, 131,
			8.4, 134,
			8.5, 136,
			8.6, 138,
			8.7, 141,
			8.8, 143,
			8.9, 145,
			9.0, 148,
			9.1, 150,
			9.2, 153,
			9.3, 155,
			9.4, 158,
			9.5, 160,
			9.6, 162,
			9.7, 165,
			9.8, 168,
			9.9, 170,
			10.0, 173
		};

		//When getting a duration from a jump
		if(!inputFrames){
			//Keep values between 0 and 10, nothing beyond that would be sensible in most cases
			jumpInput = Clamp(jumpInput, 0, 10);
			//Round to the nearest 0.1
			jumpInput *= 10;
			jumpInput = Round(jumpInput);
			//In case there's some stupid reason this was here I'm leaving a comment,
			//but I'm pretty sure I'm just a moron.
			//jumpInput *= 0.1;
			
			return jumpTBL[jumpInput*2+1];
		}
		//When getting a jump from a duration
		else{
			int closestIndex = 0;
			int closest = 0;
			//Cycle through the table to find the closest duration to the desired one
			for(int i=1; i<100; i++){
				if(Abs(jumpTBL[i*2+1]-jumpInput)<Abs(closest-jumpInput)){
					closestIndex = i;
					closest = jumpTBL[i*2+1];
				}
			}
			
			return jumpTBL[closestIndex*2+0];
		}
	}
	//Returns true if a 4-way direction and an 8-way direction line up
	bool Cliff_FacingJumpDir(int dir4, int dir8){
		if(dir4==dir8)
			return true;
		switch(dir8){
			case DIR_LEFTUP:
				return dir4==DIR_UP||dir4==DIR_LEFT;
				break;
			case DIR_LEFTDOWN:
				return dir4==DIR_DOWN||dir4==DIR_LEFT;
				break;
			case DIR_RIGHTUP:
				return dir4==DIR_UP||dir4==DIR_RIGHT;
				break;
			case DIR_RIGHTDOWN:
				return dir4==DIR_DOWN||dir4==DIR_RIGHT;
				break;
		}
		return false;
	}
	void run(){
		if(this->Layer!=0)
			Quit();
		//Find the first instance of this script on the screen
		int firstPos = -1;
		for(int i=0; i<176; ++i){
			combodata cd = Game->LoadComboData(Screen->ComboD[i]);
			if(cd->Script==this->Script){
				firstPos = i;
				break;
			}
		}
		//Only run one instance of the combo script at a time. This script is basically an automated FFC script
		if(this->Pos!=firstPos)
			Quit();
			
		int pushTime;
		while(true){
			if(CLIFF_DEBUG){
				for(int i=0; i<176; ++i){
					combodata cd = Game->LoadComboData(Screen->ComboD[i]);
					if(cd->Script==this->Script){
						switch(cd->InitD[0]){
							case 1:
								Screen->DrawString(6, ComboX(i), ComboY(i), FONT_Z3SMALL, 0x01, 0x0F, TF_NORMAL, "UP", 128);
								break;
							case 2:
								Screen->DrawString(6, ComboX(i), ComboY(i), FONT_Z3SMALL, 0x01, 0x0F, TF_NORMAL, "DN", 128);
								break;
							case 3:
								Screen->DrawString(6, ComboX(i), ComboY(i), FONT_Z3SMALL, 0x01, 0x0F, TF_NORMAL, "LF", 128);
								break;
							case 4:
								Screen->DrawString(6, ComboX(i), ComboY(i), FONT_Z3SMALL, 0x01, 0x0F, TF_NORMAL, "RT", 128);
								break;
							case 5:
								Screen->DrawString(6, ComboX(i), ComboY(i), FONT_Z3SMALL, 0x01, 0x0F, TF_NORMAL, "ULF", 128);
								break;
							case 6:
								Screen->DrawString(6, ComboX(i), ComboY(i), FONT_Z3SMALL, 0x01, 0x0F, TF_NORMAL, "URT", 128);
								break;
							case 7:
								Screen->DrawString(6, ComboX(i), ComboY(i), FONT_Z3SMALL, 0x01, 0x0F, TF_NORMAL, "DLF", 128);
								break;
							case 8:
								Screen->DrawString(6, ComboX(i), ComboY(i), FONT_Z3SMALL, 0x01, 0x0F, TF_NORMAL, "DRT", 128);
								break;
							default:
								Screen->DrawString(6, ComboX(i), ComboY(i), FONT_Z3SMALL, 0x01, 0x0F, TF_NORMAL, "--", 128);
								break;
						}
						Screen->DrawInteger(6, ComboX(i), ComboY(i)+6, FONT_Z3SMALL, 0x01, 0x0F, -1, -1, cd->InitD[0], 0, 128);
					}
				}
			}
			
			//Check if Link is facing a cliff combo with this script
			int facingPos = Cliff_FacingCliffPos(this->Script);
			if(facingPos>-1&&Link->Z==0){
				combodata cd = Game->LoadComboData(Screen->ComboD[facingPos]);
				int jumpDir = cd->InitD[0]-1;
				int gbMod = cd->InitD[1];
				//Check if the cliff's direction lines up with Link's
				if(Cliff_FacingJumpDir(Link->Dir, jumpDir)){
					++pushTime;
					if(pushTime>CLIFF_PUSH_TIME){
						pushTime = CLIFF_PUSH_TIME;
						bool safeJump = true;
						int vX; int vY;
						//Get the velocity for the jump
						switch(jumpDir){
							case DIR_UP:
								vY = -1;
								break;
							case DIR_DOWN:
								vY = 1;
								break;
							case DIR_LEFT:
								vX = -1;
								break;
							case DIR_RIGHT:
								vX = 1;
								break;
							case DIR_LEFTUP:
								vX = -1;
								vY = -1;
								break;
							case DIR_RIGHTUP:
								vX = 1;
								vY = -1;
								break;
							case DIR_LEFTDOWN:
								vX = -1;
								vY = 1;
								break;
							case DIR_RIGHTDOWN:
								vX = 1;
								vY = 1;
								break;
						}
						//Simulate the jump
						int endX = Link->X;
						int endY = Link->Y;
						while(true){
							endX += vX;
							endY += vY;
							//If the jump would go offscreen, it isn't possible
							if(endX<0||endX>240||endY<0||endY>160){
								safeJump = false;
								pushTime = 0;
								break;
							}
							//If there's no cliffs under the position, the jump has completed
							if(!Cliff_Collision(this->Script, endX, endY)){
								break;
							}
						}
						int landX = endX;
						int landY = endY;
						if(gbMod){
							if(jumpDir!=DIR_UP&&jumpDir!=DIR_DOWN){
								landY += gbMod * 16;
							}
						}
						//If the landing point goes offscreen, the jump is invalid
						if(landY>160){
							landY = 160;
						}
						//Make sure there's room to land at the end of the jump
						if(safeJump&&!Cliff_CanLand(this->Script, landX, landY)){
							//Attempt grid snapping in case it's just off by a few pixels
							endX = Floor((endX+4)/8)*8;
							endY = Floor((endY+4)/8)*8;
							landX = Floor((landX+4)/8)*8;
							landY = Floor((landY+4)/8)*8;
							if(!Cliff_CanLand(this->Script, landX, landY)){
								safeJump = false;
								pushTime = 0;
							}
						}
						//If all the conditions are met, perform the jump
						if(safeJump){
							int jumpDist = Distance(Link->X, Link->Y, endX, endY);
							int jumpTime = Cliff_FindJumpLength(CLIFF_JUMP, false);
							int jumpStep = jumpDist/jumpTime;
							Game->PlaySound(SFX_JUMP);
							Link->Jump = CLIFF_JUMP;
							int LinkX = Link->X;
							int LinkY = Link->Y;
							Link->MoveFlags[HEROMV_CAN_PITFALL] = false;
							if(gbMod&&jumpDir==DIR_DOWN){
								endX = Link->X;
								endY = Link->Y;
								Link->X = landX;
								Link->Y = landY;
								Link->Z += landY-endY;
								while(Link->Z>0){
									WaitNoAction();
								}
							}
							else{
								while(Link->Jump>0||Link->Z>0){
									if(Distance(LinkX, LinkY, endX, endY)>jumpStep){
										int angle = Angle(LinkX, LinkY, endX, endY);
										LinkX += VectorX(jumpStep, angle);
										LinkY += VectorY(jumpStep, angle);
									}
									else{
										LinkX = endX;
										LinkY = endY;
									}
									Link->X = LinkX;
									Link->Y = LinkY;
									WaitNoAction();
								}
								Link->X = endX;
								Link->Y = endY;
								if(gbMod&&(jumpDir!=DIR_UP&&jumpDir!=DIR_DOWN)){
									Link->Z = landY-endY;
									Link->Y += landY-endY;
									while(Link->Z>0){
										WaitNoAction();
									}
								}
							}
							Link->MoveFlags[HEROMV_CAN_PITFALL] = true;
							if(CLIFF_BREAK_SLASHABLES)
								Cliff_TriggerSlashables(this->Script, landX, landY);
							pushTime = 0;
						}
					}
				}
				else
					pushTime = 0;
			}
			else
				pushTime = 0;
			
			Waitframe();
		}
	}
}