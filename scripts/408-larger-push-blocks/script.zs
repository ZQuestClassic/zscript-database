const int SCRIPTEDPUSHBLOCK_DELAY = 16; //Frames before pushing
const int SCRIPTEDPUSHBLOCK_PUSHSPEED = 1.5; //Push speed of the blocks
const int SCRIPTEDPUSHBLOCK_STOP_ON_TRIGGER = 1; //Set to 1 if the push blocks stop moving after covering block triggers

const int SFX_SCRIPTPUSHBLOCK = 50; //Sound when a block is pushed

const int CF_LARGEPUSH_TRIGGERED = 105; //This flag doesn't have a constant in std for some reason

//This script is used for regular rectangular push blocks, up to 4x4 in size.
//Place the FFC over the top left corner of your push block.
//D0: Width of the block in tiles
//D1: Height of the block in tiles
//D4: Set to 1 if it's a one time push
//D5: Set to to the sum of the following flags to enable pushing in certain directions, if 0 defaults to 15 (all directions)
//		1 - Up
//		2 - Down
//		4 - Left
//		8 - Right
//D6: Set to affect the push level requirement of the block. 0: None, 1: Bracelet L2, 2: Bracelet L3
//D7: Set to a secret sfx for block puzzles if you're using a custom one
ffc script LargePushBlock{
	void run(int w, int h, int dummy1, int dummy2, int onetime, int canpushdir, int reqpushlevel, int secretSFX){
		this->Flags[FFCF_ETHEREAL] = true;
		
		int i; int j; int k;
		int x; int y;
		
		w = Clamp(w, 1, 4);
		if(h==0)
			h = w;
		h = Clamp(h, 1, 4);
		
		if(canpushdir==0)
			canpushdir = 1111b;
		
		if(secretSFX==0)
			secretSFX = SFX_SECRET;
		
		int blockShape[16];
		
		//Track undercombo stuff for the full shape of the push block
		int underCombo[176];
		int underCSet[176];
		int underFlag[176];
		for(i=0; i<176; ++i){
			underCombo[i] = Screen->UnderCombo;
			underCSet[i] = Screen->UnderCSet;
			underFlag[i] = 0;
		}
		
		//Track combo data, cset, flag, and solidity of combos that are part of the push block
		int subCombo[16];
		int subCSet[16];
		int subFlag[16];
		int subSolid[16];
		for(x=0; x<w; ++x){
			for(y=0; y<h; ++y){
				i = x+y*4;
				j = ComboAt(this->X+8, this->Y+8)+x+y*16;
				subCombo[i] = Screen->ComboD[j];
				subCSet[i] = Screen->ComboC[j];
				subFlag[i] = Screen->ComboF[j];
				subSolid[i] = Screen->ComboS[j];
				blockShape[i] = 1;
			}
		}
		
		int blockX;
		int blockY;
		int scriptedPushBlock[16];
		scriptedPushBlock[0] = 0; //Push Timer
		scriptedPushBlock[1] = this->X; //Block X
		scriptedPushBlock[2] = this->Y; //Block Y
		scriptedPushBlock[3] = 0; //State
		scriptedPushBlock[4] = 0; //Dir
		scriptedPushBlock[5] = 16; //Substep
		scriptedPushBlock[6] = 0; //Can't Push
		scriptedPushBlock[7] = underCombo;
		scriptedPushBlock[8] = underCSet;
		scriptedPushBlock[9] = underFlag;
		scriptedPushBlock[10] = subCombo;
		scriptedPushBlock[11] = subCSet;
		scriptedPushBlock[12] = subFlag;
		scriptedPushBlock[13] = subSolid;
		scriptedPushBlock[14] = blockShape;
		
		while(true){
			//Update the combos that make up the push block in case they are changed
			if(scriptedPushBlock[3]==0){ //State: Idle
				for(x=0; x<w; ++x){
					for(y=0; y<h; ++y){
						i = x+y*4;
						j = ComboAt(scriptedPushBlock[1]+8, scriptedPushBlock[2]+8)+x+y*16;
						subCombo[i] = Screen->ComboD[j];
						subCSet[i] = Screen->ComboC[j];
						subFlag[i] = Screen->ComboF[j];
						subSolid[i] = Screen->ComboS[j];
					}
				}
			}
			ScriptedPushBlock_Update(scriptedPushBlock, onetime, canpushdir, reqpushlevel, secretSFX);
			Waitframe();
		}
	}
}

//This script is used for irregularly shaped push blocks, up to 4x4 in size.
//Place the FFC over the top left corner of your push block shape.
//D0-D3 represent the shape of the push block by row, being a number from 0000 to 1111
//For example, an O shaped block would look like
//		D0: 1110
//		D1: 1010
//		D2: 1110
//		D3: 0000
//D4: Set to 1 if it's a one time push
//D5: Set to to the sum of the following flags to enable pushing in certain directions, if 0 defaults to 15 (all directions)
//		1 - Up
//		2 - Down
//		4 - Left
//		8 - Right
//D6: Set to affect the push level requirement of the block. 0: None, 1: Bracelet L2, 2: Bracelet L3
//D7: Set to a secret sfx for block puzzles if you're using a custom one
ffc script OddlyShapedPushBlock{
	void SetBlockRow(int blockShape, int row, int rowNum){
		//Hi. This function is dumb.
		//I wrote it to quarantine these calculations from the rest of the script so I don't have to look at them.
		//I also did this for you, end user!
		blockShape[rowNum*4+0] = Floor((row%10000)/1000);
		blockShape[rowNum*4+1] = Floor((row%1000)/100);
		blockShape[rowNum*4+2] = Floor((row%100)/10);
		blockShape[rowNum*4+3] = (row%10);
	}
	void run(int row1, int row2, int row3, int row4, int onetime, int canpushdir, int reqpushlevel, int secretSFX){
		this->Flags[FFCF_ETHEREAL] = true;
		
		int i; int j; int k;
		int x; int y;
		
		if(canpushdir==0)
			canpushdir = 1111b;
		
		if(secretSFX==0)
			secretSFX = SFX_SECRET;
		
		int blockShape[16];
		SetBlockRow(blockShape, row1, 0);
		SetBlockRow(blockShape, row2, 1);
		SetBlockRow(blockShape, row3, 2);
		SetBlockRow(blockShape, row4, 3);
		
		//Track undercombo stuff for the full shape of the push block
		int underCombo[176];
		int underCSet[176];
		int underFlag[176];
		for(i=0; i<176; ++i){
			underCombo[i] = Screen->UnderCombo;
			underCSet[i] = Screen->UnderCSet;
			underFlag[i] = 0;
		}
		
		//Track combo data, cset, flag, and solidity of combos that are part of the push block
		int subCombo[16];
		int subCSet[16];
		int subFlag[16];
		int subSolid[16];
		for(x=0; x<4; ++x){
			for(y=0; y<4; ++y){
				i = x+y*4;
				if(blockShape[i]){
					j = ComboAt(this->X+8, this->Y+8)+x+y*16;
					subCombo[i] = Screen->ComboD[j];
					subCSet[i] = Screen->ComboC[j];
					subFlag[i] = Screen->ComboF[j];
					subSolid[i] = Screen->ComboS[j];
				}
			}
		}
		
		int blockX;
		int blockY;
		int scriptedPushBlock[16];
		scriptedPushBlock[0] = 0; //Push Timer
		scriptedPushBlock[1] = this->X; //Block X
		scriptedPushBlock[2] = this->Y; //Block Y
		scriptedPushBlock[3] = 0; //State
		scriptedPushBlock[4] = 0; //Dir
		scriptedPushBlock[5] = 16; //Substep
		scriptedPushBlock[6] = 0; //Can't Push
		scriptedPushBlock[7] = underCombo;
		scriptedPushBlock[8] = underCSet;
		scriptedPushBlock[9] = underFlag;
		scriptedPushBlock[10] = subCombo;
		scriptedPushBlock[11] = subCSet;
		scriptedPushBlock[12] = subFlag;
		scriptedPushBlock[13] = subSolid;
		scriptedPushBlock[14] = blockShape;
		
		while(true){
			//Update the combos that make up the push block in case they are changed
			if(scriptedPushBlock[3]==0){ //State: Idle
				for(x=0; x<4; ++x){
					for(y=0; y<4; ++y){
						i = x+y*4;
						if(blockShape[i]){
							j = ComboAt(scriptedPushBlock[1]+8, scriptedPushBlock[2]+8)+x+y*16;
							subCombo[i] = Screen->ComboD[j];
							subCSet[i] = Screen->ComboC[j];
							subFlag[i] = Screen->ComboF[j];
							subSolid[i] = Screen->ComboS[j];
						}
					}
				}
			}
			ScriptedPushBlock_Update(scriptedPushBlock, onetime, canpushdir, reqpushlevel, secretSFX);
			Waitframe();
		}
	}
}

bool ScriptedPushBlock_HasPushLevel(int reqpushlevel){
	if(reqpushlevel>1&&Link->Item[I_BRACELET2])
		return true;
	if(reqpushlevel>0&&(Link->Item[I_BRACELET2]||Link->Item[I_BRACELET3]))
		return true;
	if(reqpushlevel==0)
		return true;
	return false;
}

void ScriptedPushBlock_Update(int scriptedPushBlock, int onetime, int canpushdir, int reqpushlevel, int secretSFX){
	int i; int j;
	int x; int y;
	
	int underCombo = scriptedPushBlock[7];
	int underCSet = scriptedPushBlock[8];
	int underFlag = scriptedPushBlock[9];
	int subCombo = scriptedPushBlock[10];
	int subCSet = scriptedPushBlock[11];
	int subFlag = scriptedPushBlock[12];
	int subSolid = scriptedPushBlock[13];
	int blockShape = scriptedPushBlock[14];
	
	if(scriptedPushBlock[3]==0){ //State: Idle
		//If the block can be pushed, pushDir is the direction, -1 if not
		int pushDir = ScriptedPushBlock_DetectLinkPush(scriptedPushBlock, canpushdir, reqpushlevel);
		if(pushDir>-1){
			if(scriptedPushBlock[4]!=pushDir) //If the pushing direction changes, reset the timer
				scriptedPushBlock[0] = 0;
			++scriptedPushBlock[0];
			//After pushing for long enough, set the state to moving
			if(scriptedPushBlock[0]>SCRIPTEDPUSHBLOCK_DELAY){
				scriptedPushBlock[0] = 0;
				scriptedPushBlock[3] = 1;
				scriptedPushBlock[5] = 16;
				
				Game->PlaySound(SFX_SCRIPTPUSHBLOCK);
				
				//Place down undercombos
				for(x=0; x<4; ++x){
					for(y=0; y<4; ++y){
						i = x+y*4;
						if(blockShape[i]){
							j = ComboAt(scriptedPushBlock[1]+8, scriptedPushBlock[2]+8)+x+y*16;
							Screen->ComboD[j] = underCombo[j];
							Screen->ComboC[j] = underCSet[j];
							Screen->ComboF[j] = underFlag[j];
						}
					}
				}
				
				ScriptedPushBlock_DrawMovingBlock(scriptedPushBlock, scriptedPushBlock[1], scriptedPushBlock[2]);
			}
		}
		else{
			scriptedPushBlock[0] = 0;
		}
		scriptedPushBlock[4] = pushDir;
	}
	else if(scriptedPushBlock[3]==1){ //State: Moving
		int pushDir = scriptedPushBlock[4];
		
		//Calculate the distance offset for movement, ranges from 0 to 16 pixels in front
		scriptedPushBlock[5] -= SCRIPTEDPUSHBLOCK_PUSHSPEED;
		scriptedPushBlock[5] = Max(scriptedPushBlock[5], 0);
		int move = 16 - scriptedPushBlock[5];
		
		//Draw the block and place solidity hitboxes in front of its position
		if(pushDir==DIR_UP)
			ScriptedPushBlock_DrawMovingBlock(scriptedPushBlock, scriptedPushBlock[1], scriptedPushBlock[2]-move);
		else if(pushDir==DIR_DOWN)
			ScriptedPushBlock_DrawMovingBlock(scriptedPushBlock, scriptedPushBlock[1], scriptedPushBlock[2]+move);
		else if(pushDir==DIR_LEFT)
			ScriptedPushBlock_DrawMovingBlock(scriptedPushBlock, scriptedPushBlock[1]-move, scriptedPushBlock[2]);
		else if(pushDir==DIR_RIGHT)
			ScriptedPushBlock_DrawMovingBlock(scriptedPushBlock, scriptedPushBlock[1]+move, scriptedPushBlock[2]);
		
		//When the block has completed movement, place the combos again
		if(scriptedPushBlock[5]==0){
			//Offset the block's internal position by 16
			if(pushDir==DIR_UP)
				scriptedPushBlock[2] -= 16;
			else if(pushDir==DIR_DOWN)
				scriptedPushBlock[2] += 16;
			else if(pushDir==DIR_LEFT)
				scriptedPushBlock[1] -= 16;
			else if(pushDir==DIR_RIGHT)
				scriptedPushBlock[1] += 16;
			
			//Update the undercombos and place the block
			bool coverAllTriggers = true;
			bool pushedOntoTrigger = false;
			for(x=0; x<4; ++x){
				for(y=0; y<4; ++y){
					i = x+y*4;
					if(blockShape[i]){
						j = ComboAt(scriptedPushBlock[1]+8, scriptedPushBlock[2]+8)+x+y*16;
						underCombo[j] = Screen->ComboD[j];
						underCSet[j] = Screen->ComboC[j];
						//Don't mess with block triggered flags for undercombos
						if(Screen->ComboF[j]!=CF_LARGEPUSH_TRIGGERED)
							underFlag[j] = Screen->ComboF[j];
						if(!ComboFI(j, CF_BLOCKTRIGGER))
							coverAllTriggers = false;
						else
							pushedOntoTrigger = true;
						Screen->ComboD[j] = subCombo[i];
						Screen->ComboC[j] = subCSet[i];
						Screen->ComboF[j] = subFlag[i];
					}
				}
			}
			
			//Set block triggered flags for communication with vanilla push blocks
			for(x=0; x<4; ++x){
				for(y=0; y<4; ++y){
					i = x+y*4;
					if(blockShape[i]){
						j = ComboAt(scriptedPushBlock[1]+8, scriptedPushBlock[2]+8)+x+y*16;
						if(ComboFI(j, CF_BLOCKTRIGGER))
							Screen->ComboF[j] = CF_LARGEPUSH_TRIGGERED;
					}
				}
			}
			
			//Stop the block from moving when overlapping a trigger or one time push
			if((coverAllTriggers&&SCRIPTEDPUSHBLOCK_STOP_ON_TRIGGER)||onetime)
				scriptedPushBlock[6] = 1; //Can't Push
			
			//Simulate triggering screen secrets for puzzles (messy and limited)
			if(pushedOntoTrigger&&(coverAllTriggers||!SCRIPTEDPUSHBLOCK_STOP_ON_TRIGGER))
				ScriptedPushBlock_DoBlockTriggerSecret(secretSFX);
			
			scriptedPushBlock[3] = 0;
			scriptedPushBlock[4] = -1;
		}
	}
}

int ScriptedPushBlock_DetectLinkPush(int scriptedPushBlock, int canpushdir, int reqpushlevel){
	int blockShape = scriptedPushBlock[14];
	
	int blockX = Round(scriptedPushBlock[1]);
	int blockY = Round(scriptedPushBlock[2]);
	int pushDir = -1;
	
	//Check if the block was already pushed
	if(scriptedPushBlock[6])
		return -1;
	
	//Check if Link has the required bracelets
	if(!ScriptedPushBlock_HasPushLevel(reqpushlevel))
		return -1;
	
	//Detect Link pushing against the combos
	for(int i=0; i<16; ++i){
		int x = blockX+(i%4)*16;
		int y = blockY+Floor(i/4)*16;
		if(blockShape[i]){
			if(RectCollision(Link->X, Link->Y, Link->X+15, Link->Y+15, x-1, y-1, x+16, y+16)){
				if(Link->Dir==DIR_UP){
					if(Abs(Link->X-x)<16&&Link->Y>=y&&Link->InputUp&&!CanWalk(Link->X, Link->Y, DIR_UP, 1, 0))
						pushDir = DIR_UP;
				}
				else if(Abs(Link->X-x)<16&&Link->Dir==DIR_DOWN){
					if(Link->Y<=y-8&&Link->InputDown&&!CanWalk(Link->X, Link->Y, DIR_DOWN, 1, 0))
						pushDir = DIR_DOWN;
				}
				else if(Link->Dir==DIR_LEFT){
					if(Link->Y>y-16&&Link->Y<y+8&&Link->X>=x+8&&Link->InputLeft&&!CanWalk(Link->X, Link->Y, DIR_LEFT, 1, 0))
						pushDir = DIR_LEFT;
				}
				else if(Link->Dir==DIR_RIGHT){
					if(Link->Y>y-16&&Link->Y<y+8&&Link->X<=x-8&&Link->InputRight&&!CanWalk(Link->X, Link->Y, DIR_RIGHT, 1, 0))
						pushDir = DIR_RIGHT;
				}
			}
		}
	}
	//Detect if the block is blocked from being pushed
	if(pushDir>-1){
		//If trying to push in a direction flagged as illegal, stop it, get some help
		if(pushDir==DIR_UP&&!(canpushdir&0001b))
			return -1;
		else if(pushDir==DIR_DOWN&&!(canpushdir&0010b))
			return -1;
		else if(pushDir==DIR_LEFT&&!(canpushdir&0100b))
			return -1;
		else if(pushDir==DIR_LEFT&&!(canpushdir&1000b))
			return -1;
		
		//Do collisions for every combo in the set
		for(int i=0; i<16; ++i){
			if(blockShape[i]){
				int x = blockX+(i%4)*16;
				int y = blockY+Floor(i/4)*16;
				if(!ScriptedPushBlock_CanWalkSubCombo(x, y, blockShape, i, pushDir)){
					return -1;
				}
			}
		}
	}
	return pushDir;
}

bool ScriptedPushBlock_IsSolid(int x, int y) {
	int pos = ComboAt(x, y);
	//Respect no push
	if(Screen->ComboF[pos]==CF_NOBLOCKS)
		return true;
	//Get a combination of the solidity mask on layers 0, 1, and 2, don't push blocks into combos with any solidity
	int comboS = Screen->ComboS[pos];
	if(Screen->LayerMap(1)>0)
		comboS |= GetLayerComboS(1, pos);
	if(Screen->LayerMap(2)>0)
		comboS |= GetLayerComboS(2, pos);
	if(comboS)
		return true;
    return false;
}

bool ScriptedPushBlock_CanWalk(int x, int y, int dir, int step, bool full_tile) {
    //Yeah this one's just CanWalk
	int c=8;
    int xx = x+15;
    int yy = y+15;
    if(full_tile) c=0;
    if(dir==0) return !(y-step<0||ScriptedPushBlock_IsSolid(x,y+c-step)||ScriptedPushBlock_IsSolid(x+8,y+c-step)||ScriptedPushBlock_IsSolid(xx,y+c-step));
    else if(dir==1) return !(yy+step>=176||ScriptedPushBlock_IsSolid(x,yy+step)||ScriptedPushBlock_IsSolid(x+8,yy+step)||ScriptedPushBlock_IsSolid(xx,yy+step));
    else if(dir==2) return !(x-step<0||ScriptedPushBlock_IsSolid(x-step,y+c)||ScriptedPushBlock_IsSolid(x-step,y+c+7)||ScriptedPushBlock_IsSolid(x-step,yy));
    else if(dir==3) return !(xx+step>=256||ScriptedPushBlock_IsSolid(xx+step,y+c)||ScriptedPushBlock_IsSolid(xx+step,y+c+7)||ScriptedPushBlock_IsSolid(xx+step,yy));
    return false; //invalid direction
}

bool ScriptedPushBlock_CanWalkSubCombo(int x, int y, int blockShape, int index, int dir){
	//Blocks that are adjacent to other blocks in the shape in the given direction should be ignored
	//If not in one of these cases, do ScriptedPushBlock_CanWalk()
	if(dir==DIR_UP){
		if(index>=4){
			if(blockShape[index-4])
				return true;
		}
		return ScriptedPushBlock_CanWalk(x, y, DIR_UP, 1, true);
	}
	else if(dir==DIR_DOWN){
		if(index<=11){
			if(blockShape[index+4])
				return true;
		}
		return ScriptedPushBlock_CanWalk(x, y, DIR_DOWN, 1, true);
	}
	else if(dir==DIR_LEFT){
		if(index%4>=1){
			if(blockShape[index-1])
				return true;
		}
		return ScriptedPushBlock_CanWalk(x, y, DIR_LEFT, 1, true);
	}
	else if(dir==DIR_RIGHT){
		if(index%4<=2){
			if(blockShape[index+1])
				return true;
		}
		return ScriptedPushBlock_CanWalk(x, y, DIR_RIGHT, 1, true);
	}
}

bool ScriptedPushBlock_DrawMovingBlock(int scriptedPushBlock, int blockX, int blockY){
	int subCombo = scriptedPushBlock[10];
	int subCSet = scriptedPushBlock[11];
	int subSolid = scriptedPushBlock[13];
	int blockShape = scriptedPushBlock[14];
	
	int layer = 2;
	if(ScreenFlag(1, 4)&&layer==2) //Layer -2
		layer = 1;
	
	blockX = Round(blockX);
	blockY = Round(blockY);
	for(int i=0; i<16; ++i){
		int x = blockX+(i%4)*16;
		int y = blockY+Floor(i/4)*16;
		if(blockShape[i]){
			Screen->FastCombo(layer, x, y, subCombo[i], subCSet[i], 128);
			if(subSolid[i]){
				if(subSolid[i]==1111b) //Full Solid
					SolidObjects_Add(0, x, y, 16, 16, 0, 0, 0);
				else if(subSolid[i]==0101b) //Top Half Solid
					SolidObjects_Add(0, x, y, 16, 8, 0, 0, 0);
				else if(subSolid[i]==1010b) //Bottom Half Solid
					SolidObjects_Add(0, x, y+8, 16, 8, 0, 0, 0);
				else if((subSolid[i]&0011b)==0011b){ //Left Half Solid
					SolidObjects_Add(0, x, y, 8, 16, 0, 0, 0);
					if(subSolid[i]&0100b) //Top Right
						SolidObjects_Add(0, x+8, y, 8, 8, 0, 0, 0);
					else if(subSolid[i]&1000b) //Bottom Right
						SolidObjects_Add(0, x+8, y+8, 8, 8, 0, 0, 0);
				}
				else if((subSolid[i]&1100b)==1100b){ //Right Half Solid
					SolidObjects_Add(0, x+8, y, 8, 16, 0, 0, 0);
					if(subSolid[i]&0001b) //Top Left
						SolidObjects_Add(0, x, y, 8, 8, 0, 0, 0);
					else if(subSolid[i]&0010b) //Bottom Left
						SolidObjects_Add(0, x, y+8, 8, 8, 0, 0, 0);
				}
				else{ //Quarter Tile Solid
					if(subSolid[i]&0100b) //Top Right
						SolidObjects_Add(0, x+8, y, 8, 8, 0, 0, 0);
					else if(subSolid[i]&1000b) //Bottom Right
						SolidObjects_Add(0, x+8, y+8, 8, 8, 0, 0, 0);
					else if(subSolid[i]&0001b) //Top Left
						SolidObjects_Add(0, x, y, 8, 8, 0, 0, 0);
					else if(subSolid[i]&0010b) //Bottom Left
						SolidObjects_Add(0, x, y+8, 8, 8, 0, 0, 0);
				}
			}
		}
	}
}

void ScriptedPushBlock_DoBlockTriggerSecret(int secretSFX){
	int triggeredBlocks;
	for(int i=0; i<176; ++i){
		if(ComboFI(i, CF_BLOCKTRIGGER))
			return;
		if(ComboFI(i, CF_LARGEPUSH_TRIGGERED))
			++triggeredBlocks;
	}
	if(triggeredBlocks){
		Game->PlaySound(secretSFX);
		Screen->TriggerSecrets();
	}
}