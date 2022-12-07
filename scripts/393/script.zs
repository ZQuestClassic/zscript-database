const int SFX_LIGHTPANEL_TURN = 6; //Sound to play when a light panel turns

const int SFX_LIGHTPATH_SOLVED = 27; //Sound to play when Light Path puzzle has been solved



const int CF_LIGHTPATH_SOURCE_NODE = 100; //Combo flag to set node as source node.

const int CT_LIGHTPATH_WRAPAROUND_PORTAL = 50; //Combo type used for wraparound portals.



const int LIGHTPATH_ALLOW_ROTATE_TILES_WITHOUT_SWORD = 1; //Set to >0 to allow Link to rotate tiles just by standing on them and pressing A.



//!\Don`t Edit//!\

const int LIGHTPATH_SPCMB_SIZE = 32; //Don`t edit



const int LIGHTPATH_SPCMB_OFFSET_DOUBLEBEND_UL_DR = 4;//Double bends. 

const int LIGHTPATH_SPCMB_OFFSET_DOUBLEBEND_UR_DL = 8;

const int LIGHTPATH_SPCMB_OFFSET_BRIDGE = 12;//Path can intersect without connecting

const int LIGHTPATH_SPCMB_OFFSET_DOUBLEBEND_UL_DR_ROTATEABLE = 16;//Double bends. Can be rotated

const int LIGHTPATH_SPCMB_OFFSET_DOUBLEBEND_UR_DL_ROTATEABLE = 20;

const int LIGHTPATH_SPCMB_OFFSET_DOUBLEBEND_UL_DR_SOLID = 24;//Double bends. Solid, can ber set as pushable.

const int LIGHTPATH_SPCMB_OFFSET_DOUBLEBEND_UR_DL_SOLID = 28;

const int LIGHTPATH_SPCMB_OFFSET_BRIDGE_SOLID = 32;//Bridge, solid, can be set as pushable.





ffc script LightPath{

	void run(int cmbNode, int cmbRotatepath, int cmbFloorPath, int cmbSolidPath, int cmbRotateNode, int cmbSpecial){

		bool alreadyTriggered;

		if(Screen->State[ST_SECRET])

			alreadyTriggered = true;

		int mainState[176]; //The type of each combo

		int dirState[176]; //Binary flag for the four directions of the combo

		int active[176]; //Whether or not the combo is activated

		int rotTime[176]; //Timer for rotating panels

		//First we cycle through every combo on the screen and

		//assign it a type based on ComboD.

		int vars[16] = {1, cmbFloorPath, cmbRotatepath, cmbNode, cmbNode, cmbSolidPath, cmbRotateNode, cmbRotateNode, cmbSpecial};

		for(int i=0; i<176; i++){

			int cd = Screen->ComboD[i];

			if(cd>=cmbFloorPath&&cd<=cmbFloorPath+31){

				mainState[i] = 1; //Fixed Path

				dirState[i] = (cd-cmbFloorPath)%16;

			}

			else if(cd>=cmbSolidPath&&cd<=cmbSolidPath+31){

				mainState[i] = 5; //Solid Path

				dirState[i] = (cd-cmbSolidPath)%16;

			}

			else if(cd>=cmbRotatepath&&cd<=cmbRotatepath+31){

				mainState[i] = 2; //Rotating Path

				dirState[i] = (cd-cmbRotatepath)%16;

			}

			else if(cd>=cmbNode&&cd<=cmbNode+15){

				mainState[i] = 3; //Trigger Node

				dirState[i] = (cd-cmbNode)%16;

			}

			else if(cd>=cmbNode+16&&cd<=cmbNode+31){

				Screen->ComboF[i] = CF_LIGHTPATH_SOURCE_NODE;

				mainState[i] = 4; //Source Node

				dirState[i] = (cd-cmbNode+16)%16;

				active[i]=1;

			}

			else if(cd>=cmbRotateNode&&cd<=cmbRotateNode+15){

				mainState[i] = 6; //Trigger Node (rotateable)

				dirState[i] = (cd-cmbRotateNode)%16;

			}

			else if(cd>=cmbRotateNode+16&&cd<=cmbRotateNode+31){

				Screen->ComboF[i] = CF_LIGHTPATH_SOURCE_NODE;

				mainState[i] = 7; //Source Node (rotateable)

				dirState[i] = (cd-cmbRotateNode+16)%16;

				active[i]=1;

			}		

			else if (cd>=cmbSpecial&&cd<=cmbSpecial+LIGHTPATH_SPCMB_SIZE){

				mainState[i] = 8; //Special LightPath tile

				dirState[i] = ((cd - cmbSpecial)>>2<<2)+4;

			}	

			else{

				mainState[i]=0; //No paths

				dirState[i]=0;

			}

		}	

		//Update the path for the start of the puzzle

		LightPath_UpdatePath(mainState, dirState, active);

		while(true){

			//If there's no active nodes left and the puzzle hasn't already been

			//solved, play the chime and solve it.

			if(vars[0]<=0&&!alreadyTriggered){

				alreadyTriggered = true;

				Game->PlaySound(SFX_LIGHTPATH_SOLVED);

				Screen->TriggerSecrets();

				Screen->State[ST_SECRET] = true;

			}

			//Keep the combos up to date and keep track of active nodes

			UpdateExistingPathCombos(mainState, dirState, cmbFloorPath, cmbRotatepath, cmbNode, cmbSolidPath, cmbRotateNode, cmbSpecial);

			LightPath_UpdatePath(mainState, dirState, active);

			LightPath_UpdateCombos(vars, mainState, dirState, active, rotTime);

			Waitframe();

		}

	}

	//Finds the combo next to another combo

	int LightPath_AdjacentPos(int pos, int dir){

		if(dir==DIR_UP){

			if(pos<16)

				return -1;

			return pos-16;

		}

		if(dir==DIR_DOWN){

			if(pos>159)

				return -1;

			return pos+16;

		}

		if(dir==DIR_LEFT){

			if(pos%16==0)

				return -1;

			return pos-1;

		}

		if(dir==DIR_RIGHT){

			if(pos%16==15)

				return -1;

			return pos+1;

		}

	}

	

	//Finds the next direction in a node with two or less directions

	int LightPath_FindNextDir(int node, int dirState, int lastDir){

		for(int i=0; i<4; i++){

			if(i!=OppositeDir(lastDir)){

				if(dirState[node]&(1<<i)){

					return i;

				}

			}

		}

		return lastDir;

	}

	//Rotate a panel's directions clockwise

	void LightPath_Rotate(int node,  int mainState,int dirState){

		int newState;

		if (mainState[node]==8){

			if ((dirState[node]==LIGHTPATH_SPCMB_OFFSET_DOUBLEBEND_UR_DL_ROTATEABLE)) dirState[node]= LIGHTPATH_SPCMB_OFFSET_DOUBLEBEND_UL_DR_ROTATEABLE;

			else if ((dirState[node]==LIGHTPATH_SPCMB_OFFSET_DOUBLEBEND_UL_DR_ROTATEABLE)) dirState[node]= LIGHTPATH_SPCMB_OFFSET_DOUBLEBEND_UR_DL_ROTATEABLE;

			return;

		}

		if(dirState[node]&(1<<DIR_UP))

			newState |= (1<<DIR_RIGHT);

		if(dirState[node]&(1<<DIR_RIGHT))

			newState |= (1<<DIR_DOWN);

		if(dirState[node]&(1<<DIR_DOWN))

			newState |= (1<<DIR_LEFT);

		if(dirState[node]&(1<<DIR_LEFT))

			newState |= (1<<DIR_UP);

		dirState[node] = newState;

	}

	

	//Run the light path from a branching node until it hits a dead end

	//or runs through all directions.

	void LightPath_RunFromNode(int node, int mainState, int dirState, int active){

		int nextPos;

		int dir = -1;

		for(int i=0; i<4; i++){ //Run through all directions

			if((dirState[node]&(1<<i))||(mainState[i]==8)){ //If that direction is valid

				nextPos = LightPath_AdjacentPos(node, i);

				dir = i;

				if ((Screen->ComboT[nextPos])==CT_LIGHTPATH_WRAPAROUND_PORTAL) nextPos = LightpathProcessWraparound (nextPos, dir);

				while(true){

					if ((active[nextPos])&&(mainState[nextPos]!=8)) break;

					if ((mainState[nextPos]!=8)&&(!(dirState[nextPos]&(1<<OppositeDir(dir))))) break;

					if (mainState[nextPos]!=8){

						active[nextPos] = 1;

						if(dirState[nextPos]==1111b||dirState[nextPos]==0111b||dirState[nextPos]==1011b||dirState[nextPos]==1101b||dirState[nextPos]==1110b){

							//You play a dangerous game there, Moosh...

							//Working with powers beyond your understanding...

							//Will ZScript break under the strain of the recursive functions?

							//Only time will tell...

							LightPath_RunFromNode(nextPos, mainState, dirState, active);

							break;

						}

						if (dirState[nextPos]==(1<<OppositeDir(dir))) break;// Capped dead end reached.

					}

					else{

						dir = LightPath_RunThroughSpecialTile(dir, nextPos,  dirState, active);

						if (dir<0) break;

					}					

					if (mainState[nextPos]!=8) dir = LightPath_FindNextDir(nextPos, dirState, dir);

					nextPos = LightPath_AdjacentPos(nextPos, dir);

					if ((Screen->ComboT[nextPos])==CT_LIGHTPATH_WRAPAROUND_PORTAL) nextPos = LightpathProcessWraparound (nextPos, dir);

					if(nextPos==-1) //If it goes off the screen, break out

						break;

				}

			}

		}

	}

	//Update the entire path

	void LightPath_UpdatePath(int mainState, int dirState, int active){

		//Cycle through an deactivate all nodes but the start

		for(int i=0; i<176; i++){

			if((mainState[i]!=4)&&(mainState[i]!=7)) //Don't deactivate source nodes

				active[i] = 0;

		}

		//Cycle to any start nodes and run from there

		for(int i=0; i<176; i++){

			if((mainState[i]==4)||(mainState[i]==7)){ //Source Node

				LightPath_RunFromNode(i, mainState, dirState, active);

			}

		}

	}

	

	//Processes light run through wrap around portals.

	int LightpathProcessWraparound (int loc, int dir){

		int cmb = loc;

		while(cmb>0){

			cmb = LightPath_AdjacentPos(cmb, OppositeDir(dir));

			if ((Screen->ComboT[cmb])==CT_LIGHTPATH_WRAPAROUND_PORTAL) return LightPath_AdjacentPos(cmb, dir);

		}

		return cmb;

	}

	

	//Set combo GFX and keep track of if the puzzle has been solved

	void LightPath_UpdateCombos(int vars, int mainState, int dirState, int active, int rotTime){

		vars[0] = 0;

		if (LIGHTPATH_ALLOW_ROTATE_TILES_WITHOUT_SWORD>0){

			int pos = ComboAt (CenterLinkX(), CenterLinkY());

			if(CanBeRotated(pos, mainState, dirState)){

				if (Link->PressA){

					if(rotTime[pos]==0){

						Game->PlaySound(SFX_LIGHTPANEL_TURN);

						rotTime[pos] = 1;

					}

				}

			}

		}

		else{

			//Detect the sword collision

			lweapon sword = LoadLWeaponOf(LW_SWORD);

			if(sword->isValid()){

				int pos = LightPath_SwordCombo(sword, mainState,dirState);

				if(pos>-1){ //Rotating path

					if(Distance(Link->X, Link->Y, sword->X, sword->Y)>10){

						if(rotTime[pos]==0){

							Game->PlaySound(SFX_LIGHTPANEL_TURN);

							rotTime[pos] = 1;

						}

					}

				}

			}

		}

		for(int i=0; i<176; i++){

			if(CanBeRotated(i, mainState, dirState)){ //Rotating Path

				if(rotTime[i]>0){

					Screen->FastCombo(2, ComboX(i), ComboY(i), Screen->UnderCombo, Screen->UnderCSet, 128);

					Screen->DrawCombo(2, ComboX(i), ComboY(i), Screen->ComboD[i], 1, 1, Screen->ComboC[i], -1, -1, ComboX(i), ComboY(i), rotTime[i]*6, -1, 0, false, 128);

					rotTime[i]++;

					if(rotTime[i]>=15){

						rotTime[i] = 0;

						LightPath_Rotate(i, mainState, dirState);

						LightPath_UpdatePath(mainState, dirState, active);

						//A weird bug happened here, so I added this hack fix

						//to ensure the puzzle can't be solved on the same frame

						//as a panel was flipped.

						vars[0] = 1;

					}

				}

			}

			if((mainState[i]==3)||(mainState[i]==6)||(mainState[i]==7)){ //Trigger Node

				if(!active[i])

					vars[0]++;

			}

			if (mainState[i]==8) Screen->ComboD[i]= vars[mainState[i]] + dirState[i]-4+active[i];

			else if (mainState[i]>0) Screen->ComboD[i] = vars[mainState[i]]+dirState[i]+16*active[i];

		}

	}

}



//Update combos to handle changing paths by other means, like push blocks to assemble wires.

void UpdateExistingPathCombos(int mainState, int dirState, int cmbFloorPath, int cmbRotatepath, int cmbNode, int cmbSolidPath, int cmbRotateNode, int cmbSpecial){

	for(int i=0; i<176; i++){

		int cd = Screen->ComboD[i];

		if(cd>=cmbFloorPath&&cd<=cmbFloorPath+31){

			mainState[i] = 1; //Fixed Path

			dirState[i] = (cd-cmbFloorPath)%16;

		}

		else if(cd>=cmbSolidPath&&cd<=cmbSolidPath+31){

			mainState[i] = 5; //Fixed Path

			dirState[i] = (cd-cmbSolidPath)%16;

		}

		else if(cd>=cmbRotatepath&&cd<=cmbRotatepath+31){

			mainState[i] = 2; //Rotating Path

			if (dirState==0)dirState[i] = (cd-cmbRotatepath)%16;

		}

		else if(cd>=cmbNode&&cd<=cmbNode+15){

			mainState[i] = 3; //Trigger Node

			dirState[i] = (cd-cmbNode)%16;

		}

		else if(cd>=cmbNode+16&&cd<=cmbNode+31){

			if (ComboFI(i,CF_LIGHTPATH_SOURCE_NODE))mainState[i] = 4; //Source Node

			else mainState[i] = 3; //Trigger Node

			dirState[i] = (cd-cmbNode+16)%16;

		}

		else if(cd>=cmbRotateNode&&cd<=cmbRotateNode+15){

			mainState[i] = 6; //Trigger Node (rotateable)

			dirState[i] = (cd-cmbRotateNode)%16;

		}

		else if(cd>=cmbRotateNode+16&&cd<=cmbRotateNode+31){

			if (ComboFI(i,CF_LIGHTPATH_SOURCE_NODE))mainState[i] = 7; //Source Node (rotateable)

			else mainState[i] = 6; //Trigger Node (rotateable)

			dirState[i] = (cd-cmbRotateNode+16)%16;

		}

		else if (cd>=cmbSpecial&&cd<=cmbSpecial+LIGHTPATH_SPCMB_SIZE){//Special Path

			mainState[i] = 8; //Special LightPath tile

			dirState[i] = ((cd - cmbSpecial)>>2<<2)+4;

			}

		else if (mainState[i]!=8) {

			mainState[i]=0; //No paths

			dirState[i]=0;

		}

	}

}



//Process light run through special tiles, like double bends and bridges.

int LightPath_RunThroughSpecialTile(int dir,int cmb, int dirState, int active){

	if ((dirState[cmb]==LIGHTPATH_SPCMB_OFFSET_DOUBLEBEND_UL_DR)

	||(dirState[cmb]==LIGHTPATH_SPCMB_OFFSET_DOUBLEBEND_UL_DR_ROTATEABLE)

	||(dirState[cmb]==LIGHTPATH_SPCMB_OFFSET_DOUBLEBEND_UL_DR_SOLID)){

		if (dir==DIR_UP){

			active[cmb]|=2;

			return DIR_RIGHT;

		}

		else if (dir==DIR_DOWN){

			active[cmb]|=1;

			return DIR_LEFT;

		}

		else if (dir==DIR_LEFT){

			active[cmb]|=2;

			return DIR_DOWN;

		}

		else if (dir==DIR_RIGHT){

			active[cmb]|=1;

			return DIR_UP;

		}

	}

	else if ((dirState[cmb]==LIGHTPATH_SPCMB_OFFSET_DOUBLEBEND_UR_DL)

	||(dirState[cmb]==LIGHTPATH_SPCMB_OFFSET_DOUBLEBEND_UR_DL_ROTATEABLE)

	||(dirState[cmb]==LIGHTPATH_SPCMB_OFFSET_DOUBLEBEND_UR_DL_SOLID)){

		if (dir==DIR_UP){

			active[cmb]|=2;

			return DIR_LEFT;

		}

		else if (dir==DIR_DOWN){

			active[cmb]|=1;

			return DIR_RIGHT;

		}

		else if (dir==DIR_LEFT){

			active[cmb]|=1;

			return DIR_UP;

		}

		else if (dir==DIR_RIGHT){

			active[cmb]|=2;

			return DIR_DOWN;

		}

	}

	else if ((dirState[cmb]==LIGHTPATH_SPCMB_OFFSET_BRIDGE)

	||(dirState[cmb]==LIGHTPATH_SPCMB_OFFSET_BRIDGE_SOLID)){

		if (dir==DIR_UP)active[cmb]|=1;

		else if (dir==DIR_DOWN)	active[cmb]|=1;

		else if (dir==DIR_LEFT)	active[cmb]|=2;		

		else if (dir==DIR_RIGHT)active[cmb]|=2;		

		return dir;

	}

}



//Processess interaction between Link and special LightPath tiles, like rotating double bends.

void LightPath_ProcessSpecialCombosInteraction(int cmb, int mainState, int dirState, int rotTime){

	if (mainState[cmb]!=8) return;

	if ((dirState[cmb]==LIGHTPATH_SPCMB_OFFSET_DOUBLEBEND_UR_DL_ROTATEABLE)

	||(dirState[cmb]==LIGHTPATH_SPCMB_OFFSET_DOUBLEBEND_UL_DR_ROTATEABLE)){

		if (LIGHTPATH_ALLOW_ROTATE_TILES_WITHOUT_SWORD>0){

			int pos = ComboAt (CenterLinkX(), CenterLinkY());

			if (Link->PressA){

				if(rotTime[pos]==0){

					Game->PlaySound(SFX_LIGHTPANEL_TURN);

					rotTime[pos] = 1;

				}

			}

		}

		else{

			lweapon sword = LoadLWeaponOf(LW_SWORD);

			if(sword->isValid()){

				int pos = LightPath_SwordCombo(sword, mainState, dirState);

				if(pos== cmb){ //Rotating path

					if(Distance(Link->X, Link->Y, sword->X, sword->Y)>10){

						if(rotTime[pos]==0){

							Game->PlaySound(SFX_LIGHTPANEL_TURN);

							rotTime[pos] = 1;

						}

					}

				}

			}

		}

	}

}



//Returns TRUE, if LightPath tile can be rotated

bool CanBeRotated(int cmb, int mainState, int dirState){

	if (mainState[cmb] == 2) return true;

	if (mainState[cmb] == 7) return true;

	if (mainState[cmb] == 6) return true;

	if (mainState[cmb] == 8){

		if (dirState[cmb]==LIGHTPATH_SPCMB_OFFSET_DOUBLEBEND_UR_DL_ROTATEABLE) return true;

		if (dirState[cmb]==LIGHTPATH_SPCMB_OFFSET_DOUBLEBEND_UL_DR_ROTATEABLE) return true;

		return false;

	}

	return false;

}



//Find a panel combo under a sword weapon

int LightPath_SwordCombo(lweapon sword, int mainState, int dirState){

	//A charged sword doesn't flip panels

	if(Link->Action==LA_CHARGING)

		return -1;

	//Only flip panels when the sword is held in front of Link

	if((Link->Dir==DIR_UP||Link->Dir==DIR_DOWN)&&Abs(sword->X-Link->X)>4)

		return -1;

	if((Link->Dir==DIR_LEFT||Link->Dir==DIR_RIGHT)&&Abs(sword->Y-Link->Y)>4)

		return -1;

	int uc = ComboAt(sword->X+8, sword->Y+8);

	if((CanBeRotated(uc, mainState, dirState)))

		return uc;

	for(int x=0; x<2; x++){

		for(int y=0; y<2; y++){

			uc = ComboAt(sword->X+6+x*3, sword->Y+6+y*3);

			if((CanBeRotated(uc, mainState, dirState)))

				return uc;

		}

	}

	return -1;

}