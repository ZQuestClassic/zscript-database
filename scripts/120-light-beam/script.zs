//=========================================Beam of Light=======================================
//For push block puzzles. If 2 types of blocks are used, max 6. If one block is used, max 7.
//Place FFC at the Light Emitter's position. Light Draw starts from the FFC.
//Flag 98 "General purpose 1 (scripts)" will block the light.
//D0: Starting direction of light beam. Use DIR_ constants.
//D1: Set Light on or off. If 1 Light will be on. If 0 Light will be off unless Screen->D[0] value is 1.
//D2: The difference between the map of layer 0 and the map of the layer the Light is on.
//eg. If layer 0 is on map 1 and the light is on layer 5, which is on map 5, the difference is 4.
//D3: Screen Pos of the secret trigger. Use Combo positions not [X,Y]. Use -1 if there is no secret.
//Secrets are permanent!
//D4: CSet of the push blocks.
//D5-6: Ignore screen in this direction. If set the screen will not set the D[0] values. MirrorOut_ combo's 
//will override ignore values. Best used if Light screens are next to each other but you don't want them to 
//affect each other or if screen uses D[0]. Use DIR_ constants for directions. Use the opposite DIR_ of the emitter to disable this check.

//Light Combos
const int LightU = 0; //Combo of Light moving up.
const int LightD = 0; //Combo of Light moving down.
const int LightL = 0; //Combo of Light moving left.
const int LightR = 0; //Combo of Light moving right.
const int LightB = 0; //Combo of Light hitting a mirror.
const int LightS = 0; //Combo of Light hitting an impassable.
const int LightEmitter_Up = 0; //Combo of Light on the emitter moving Up.
const int LightEmitter_Down = 0; //Combo of Light on the emitter moving Down.
const int LightEmitter_Left = 0; //Combo of Light on the emitter moving Left.
const int LightEmitter_Right = 0; //Combo of Light on the emitter moving Right.
const int LightOut_Up = 0; //Combo of Light leaving the screen moving Up.
const int LightOut_Down = 0; //Combo of Light leaving the screen moving Down.
const int LightOut_Left = 0; //Combo of Light leaving the screen moving Left.
const int LightOut_Right = 0; //Combo of Light leaving the screen moving Right.

//Mirror Combos
const int MirrorA_Push = 0; //Combo of Mirror Up-Left, Down-Right. Pushable.
const int MirrorB_Push = 0; //Combo of Mirror Up-Right, Down-Left. Pushable.
const int MirrorOut_Up = 0; //Combo of Mirror leaving the screen Up.
const int MirrorOut_Down = 0; //Combo of Mirror leaving the screen Down.
const int MirrorOut_Left = 0; //Combo of Mirror leaving the screen Left.
const int MirrorOut_Right = 0; //Combo of Mirror leaving the screen Right.

//Draw Layer
const int Layer = 0; //Layer to draw the Light combos. Layer should have no other combos.
const int LightColor = 0; //Cset of Light combos.

//Sounds
const int LightSound = 0; //Sound of light beam.
const int SoundCycle = 0; //Number of frames before the sound loops.

ffc script LightBeam{
	void run(int LightDir, int Light, int MapDiff, int Secret, int BlockColor, int IgnoreA, int IgnoreB){
	
		int StartDir = LightDir;
		int X = this->X;
		int Y = this->Y;
		int index = 1;
		int timer = 0;
		
		//Check for first run.
		if(Light == 1 && Screen->D[0] < 2){
			Screen->D[0] = 2;
			SetDIndex(index);
		}//end if
		else if(Screen->D[0] == 1){
			Screen->D[0] = Screen->D[0] + 1;
			SetDIndex(index);
		}//end else if
		else if(Screen->ComboT[ComboAt(CenterLinkX(), CenterLinkY())] == CT_RESET){
			SetDIndex(index);
		}//end else if
		else if(Light == 1 || Screen->D[0] == 2){
			index = BlockDrawA(BlockColor, index);
			index = BlockDrawB(BlockColor, index);
		}//end else
		
		DrawBlank();
	
		while(Light == 1 || Screen->D[0] == 2){
			DrawBlank();
			BlockSaveA(index);
			index = BlockDrawA(BlockColor, index);
			BlockSaveB(index);
			index = BlockDrawB(BlockColor, index);
			
			//Play Light sound every SoundCycle frames.
			if(timer == SoundCycle){
				Game->PlaySound(LightSound);
				timer = 0;
			}//end if
			else{
				timer++;
			}//end else
			
			//Draw the Emitter combo.
			if(LightDir == DIR_UP){
				SetLayerComboD(Layer, ComboAt(X, Y), LightEmitter_Up);
				Game->SetComboCSet((Game->GetCurMap() + MapDiff), Game->GetCurScreen(), ComboAt(X, Y), LightColor);
			}//end if
			else if(LightDir == DIR_DOWN){
				SetLayerComboD(Layer, ComboAt(X, Y), LightEmitter_Down);
				Game->SetComboCSet((Game->GetCurMap() + MapDiff), Game->GetCurScreen(), ComboAt(X, Y), LightColor);
			}//end else if
			else if(LightDir == DIR_LEFT){
				SetLayerComboD(Layer, ComboAt(X, Y), LightEmitter_Left);
				Game->SetComboCSet((Game->GetCurMap() + MapDiff), Game->GetCurScreen(), ComboAt(X, Y), LightColor);
			}//end else if
			else{
				SetLayerComboD(Layer, ComboAt(X, Y), LightEmitter_Right);
				Game->SetComboCSet((Game->GetCurMap() + MapDiff), Game->GetCurScreen(), ComboAt(X, Y), LightColor);
			}//end else
			
			//Loop runs in one frame.
			do{
				//Check if Link is in the Light path.
				if(GetLayerComboD(Layer, ComboAt((Link->X + 8), (Link->Y + 8))) == GetLayerComboD(Layer, ComboAt(X, Y))){
					LightDir = LinkMirror(LightDir);
				}//end if
				
				//Check for flag 98 and stop Light.
				if(Screen->ComboF[ComboAt(X, Y)] == CF_SCRIPT1 || Screen->ComboI[ComboAt(X, Y)] == CF_SCRIPT1){
					SetLayerComboD(Layer, ComboAt(X, Y), LightS);
					Game->SetComboCSet((Game->GetCurMap() + MapDiff), Game->GetCurScreen(), ComboAt(X, Y), LightColor);
					break;
				}//end if
				
				//Check if Light is on a MirrorOut Combo.
				//Check if Light is on a Trigger Secret Combo. Checked by Combo Pos.
				if(LightScreenPass(X, Y, MapDiff, StartDir, IgnoreA, IgnoreB) || LightScreenSecret(X, Y, MapDiff, Secret)){
					break;
				}//end if
				
				//Check Light Direction and draw Light path.
				if(LightDir == DIR_UP){ //Up
					Y = Y - 16;
					LightDir = DrawCombo(LightDir, X, Y, LightU, MapDiff);
				}//end if
				else if(LightDir == DIR_DOWN){ //Down
					Y = Y + 16;
					LightDir = DrawCombo(LightDir, X, Y, LightD, MapDiff);
				}//end else if
				else if(LightDir == DIR_LEFT){ //Left
					X = X - 16;
					LightDir = DrawCombo(LightDir, X, Y, LightL, MapDiff);
				}//end else if
				else if(LightDir == DIR_RIGHT){ //Right
					X = X + 16;
					LightDir = DrawCombo(LightDir, X, Y, LightR, MapDiff);
				}//end else if
			}while(ScreenCheck(X, Y)); //Loop while the Light path is in Screen boundaries.
			
			X = this->X;
			Y = this->Y;
			LightDir = StartDir;
			Waitframe();
		}//end while
	
	}//end run
}//end ffc

void SetDIndex(int index){
	for(index; index <= 7; index++){
		Screen->D[index] = -1;
	}//end for
}//end SetDIndex

void BlockSaveA(int index){
	for(int a = 0; a <= 175; a++){
		if(Game->GetComboData(Game->GetCurMap(), Game->GetCurScreen(), a) == MirrorA_Push){
			Screen->D[index] = a;
			index++;
		}//end if
		else{
			Screen->D[index] = -1;
		}//end else
	}//end for
}//end BlockSaveA

void BlockSaveB(int index){
	for(int a = 0; a <= 175; a++){
		if(Game->GetComboData(Game->GetCurMap(), Game->GetCurScreen(), a) == MirrorB_Push){
			Screen->D[index] = a;
			index++;
		}//end if
		else{
			Screen->D[index] = -1;
		}//end else
	}//end for
}//end BlockSaveB

int BlockDrawA(int BlockColor, int index){
	for(int a = 0; a <= 175; a++){
		if(Game->GetComboData(Game->GetCurMap(), Game->GetCurScreen(), a) == MirrorA_Push){
			Screen->ComboD[a] = 0;
		}//end if
	}//end for
	
	for(index; index <= 7; index++){
		if(Screen->D[index] == -1){
			index++;
			return index;
		}//end if
		Screen->ComboD[Screen->D[index]] = MirrorA_Push;
		Screen->ComboC[Screen->D[index]] = BlockColor;
	}//end for
}//end BlockDraw

int BlockDrawB(int BlockColor, int index){
	for(int a = 0; a <= 175; a++){
		if(Game->GetComboData(Game->GetCurMap(), Game->GetCurScreen(), a) == MirrorB_Push){
			Screen->ComboD[a] = 0;
		}//end if
	}//end for
	
	for(index; index <= 7; index++){
		if(Screen->D[index] == -1){
			index = 1;
			return index;
		}//end if
		Screen->ComboD[Screen->D[index]] = MirrorB_Push;
		Screen->ComboC[Screen->D[index]] = BlockColor;
	}//end for
	index = 1;
	return index;
}//end BlockDrawB

bool LightScreenSecret(int X, int Y, int MapDiff, int Secret){
	if(ComboAt(X, Y) == Secret){
		SetLayerComboD(Layer, ComboAt(X, Y), LightS);
		Game->SetComboCSet((Game->GetCurMap() + MapDiff), Game->GetCurScreen(), ComboAt(X, Y), LightColor);
		if(!Screen->State[ST_SECRET]){
			Screen->TriggerSecrets();
			Screen->State[ST_SECRET] = true;
			Game->PlaySound(SFX_SECRET);
		}//end if
		return true;
	}//end if
	else{
		return false;
	}//end else
}//end LightScreenSecret

bool LightScreenPass(int X, int Y, int MapDiff, int StartDir, int IgnoreA, int IgnoreB){
	if(Game->GetComboData(Game->GetCurMap(), Game->GetCurScreen(), ComboAt(X, Y)) == MirrorOut_Up){
		SetLayerComboD(Layer, ComboAt(X, Y), LightOut_Up);
		Game->SetComboCSet((Game->GetCurMap() + MapDiff), Game->GetCurScreen(), ComboAt(X, Y), LightColor);
		Game->SetDMapScreenD(Game->GetCurDMap(), (Game->GetCurDMapScreen() - 16), 0, 1);
		return true;
	}//end if
	else if(Game->GetComboData(Game->GetCurMap(), Game->GetCurScreen(), ComboAt(X, Y)) == MirrorOut_Down){
		SetLayerComboD(Layer, ComboAt(X, Y), LightOut_Down);
		Game->SetComboCSet((Game->GetCurMap() + MapDiff), Game->GetCurScreen(), ComboAt(X, Y), LightColor);
		Game->SetDMapScreenD(Game->GetCurDMap(), (Game->GetCurDMapScreen() + 16), 0, 1);
		return true;
	}//end else if
	else if(Game->GetComboData(Game->GetCurMap(), Game->GetCurScreen(), ComboAt(X, Y)) ==  MirrorOut_Left){
		SetLayerComboD(Layer, ComboAt(X, Y), LightOut_Left);
		Game->SetComboCSet((Game->GetCurMap() + MapDiff), Game->GetCurScreen(), ComboAt(X, Y), LightColor);
		Game->SetDMapScreenD(Game->GetCurDMap(), (Game->GetCurDMapScreen() - 1), 0, 1);
		return true;
	}//end else if
	else if(Game->GetComboData(Game->GetCurMap(), Game->GetCurScreen(), ComboAt(X, Y)) == MirrorOut_Left){
		SetLayerComboD(Layer, ComboAt(X, Y), LightOut_Right);
		Game->SetComboCSet((Game->GetCurMap() + MapDiff), Game->GetCurScreen(), ComboAt(X, Y), LightColor);
		Game->SetDMapScreenD(Game->GetCurDMap(), (Game->GetCurDMapScreen() + 1), 0, 1);
		return true;
	}//end else if
	else{
		if(!StartDir == DIR_DOWN || !IgnoreA == DIR_UP || !IgnoreB == DIR_UP){
			Game->SetDMapScreenD(Game->GetCurDMap(), (Game->GetCurDMapScreen() - 16), 0, 0); //One screen up.
		}//end if
		if(!StartDir == DIR_UP || !IgnoreA == DIR_DOWN || !IgnoreB == DIR_DOWN){
			Game->SetDMapScreenD(Game->GetCurDMap(), (Game->GetCurDMapScreen() + 16), 0, 0); //One screen down.
		}//end if
		if(!StartDir == DIR_RIGHT || !IgnoreA == DIR_LEFT || !IgnoreB == DIR_LEFT){
			Game->SetDMapScreenD(Game->GetCurDMap(), (Game->GetCurDMapScreen() - 1), 0, 0); //One screen left.
		}//end if
		if(!StartDir == DIR_LEFT || !IgnoreA == DIR_RIGHT || !IgnoreB == DIR_RIGHT){
		Game->SetDMapScreenD(Game->GetCurDMap(), (Game->GetCurDMapScreen() + 1), 0, 0); //One screen right.
		}//end if
		return false;
	}//end else
}//end LightScreenPass

int LinkMirror(int LightDir){
	//Change Light direction if Link is facing left or right and Light is travelling down.
	if(GetLayerComboD(Layer, ComboAt((Link->X + 8), (Link->Y + 8))) == LightD && Link->Item[I_SHIELD3]){
		if(Link->Dir == DIR_LEFT){
			LightDir = DIR_LEFT;
			return LightDir;
		}//end if
		else if(Link->Dir == DIR_RIGHT){
			LightDir = DIR_RIGHT;
			return LightDir;
		}//end else if
		else{
			return LightDir;
		}//end else
	}//end if
	
	//Change Light direction if Link is facing left or right and Light is travelling up.
	else if(GetLayerComboD(Layer, ComboAt((Link->X + 8), (Link->Y + 8))) == LightU && Link->Item[I_SHIELD3]){
		if(Link->Dir == DIR_LEFT){
			LightDir = DIR_LEFT;
			return LightDir;
		}//end if
		else if(Link->Dir == DIR_RIGHT){
			LightDir = DIR_RIGHT;
			return LightDir;
		}//end else if
		else{
			return LightDir;
		}//end else
	}//end else if
	
	//Change Light direction if Link is facing up or down and Light is travelling left.
	else if(GetLayerComboD(Layer, ComboAt((Link->X + 8), (Link->Y + 8))) == LightL && Link->Item[I_SHIELD3]){
		if(Link->Dir == DIR_UP){
			LightDir = DIR_UP;
			return LightDir;
		}//end if
		 else if(Link->Dir == DIR_DOWN){
			LightDir = DIR_DOWN;
			return LightDir;
		}//end else if
		else{
			return LightDir;
		}//end else
	}//end else if
	
	//Change Light direction if Link is facing up or down and Light is travelling right.
	else if(GetLayerComboD(Layer, ComboAt((Link->X + 8), (Link->Y + 8))) == LightR && Link->Item[I_SHIELD3]){
		if(Link->Dir == DIR_UP){
			LightDir = DIR_UP;
			return LightDir;
		}//end if
		else if(Link->Dir == DIR_DOWN){
			LightDir = DIR_DOWN;
			return LightDir;
		}//end else if
		else{
			return LightDir;
		}//end else
	}//end else if
	else{
		return LightDir;
	}//end else
}//end LinkMirror

int DrawCombo(int LightDir, int X, int Y, int LightCombo, int MapDiff){
	//Light will change direction from up to Right.
	if(GetLayerComboT(0, ComboAt(X, Y)) == CT_MIRRORSLASH && LightDir == DIR_UP || GetLayerComboT(0, ComboAt(X, Y)) == CT_MIRRORSLASH && LightDir == DIR_UP){
		SetLayerComboD(Layer, ComboAt(X, Y), LightB);
		Game->SetComboCSet((Game->GetCurMap() + MapDiff), Game->GetCurScreen(), ComboAt(X, Y), LightColor);
		LightDir = DIR_RIGHT;
	}//end if
	
	//Light will change direction from up to Left.
	else if(GetLayerComboT(0, ComboAt(X, Y)) == CT_MIRRORBACKSLASH && LightDir == DIR_UP || GetLayerComboT(0, ComboAt(X, Y)) == CT_MIRRORBACKSLASH && LightDir == DIR_UP){
		SetLayerComboD(Layer, ComboAt(X, Y), LightB);
		Game->SetComboCSet((Game->GetCurMap() + MapDiff), Game->GetCurScreen(), ComboAt(X, Y), LightColor);
		LightDir = DIR_LEFT;
	}//end else if
	
	//Light will change direction from Down to Left.
	else if(GetLayerComboT(0, ComboAt(X, Y)) == CT_MIRRORSLASH && LightDir == DIR_DOWN || GetLayerComboT(0, ComboAt(X, Y)) == CT_MIRRORSLASH && LightDir == DIR_DOWN){
		SetLayerComboD(Layer, ComboAt(X, Y), LightB);
		Game->SetComboCSet((Game->GetCurMap() + MapDiff), Game->GetCurScreen(), ComboAt(X, Y), LightColor);
		LightDir = DIR_LEFT;
	}//end else if
	
	//Light will change direction from Down to Right.
	else if(GetLayerComboT(0, ComboAt(X, Y)) == CT_MIRRORBACKSLASH && LightDir == DIR_DOWN || GetLayerComboT(0, ComboAt(X, Y)) == CT_MIRRORBACKSLASH && LightDir == DIR_DOWN){
		SetLayerComboD(Layer, ComboAt(X, Y), LightB);
		Game->SetComboCSet((Game->GetCurMap() + MapDiff), Game->GetCurScreen(), ComboAt(X, Y), LightColor);
		LightDir = DIR_RIGHT;
	}//end else if
	
	//Light will change direction from Left to Down.
	else if(GetLayerComboT(0, ComboAt(X, Y)) == CT_MIRRORSLASH && LightDir == DIR_LEFT || GetLayerComboT(0, ComboAt(X, Y)) == CT_MIRRORSLASH && LightDir == DIR_LEFT){
		SetLayerComboD(Layer, ComboAt(X, Y), LightB);
		Game->SetComboCSet((Game->GetCurMap() + MapDiff), Game->GetCurScreen(), ComboAt(X, Y), LightColor);
		LightDir = DIR_DOWN;
	}//end else if
	
	//Light will change direction from Left to Up.
	else if(GetLayerComboT(0, ComboAt(X, Y)) == CT_MIRRORBACKSLASH && LightDir == DIR_LEFT || GetLayerComboT(0, ComboAt(X, Y)) == CT_MIRRORBACKSLASH && LightDir == DIR_LEFT){
		SetLayerComboD(Layer, ComboAt(X, Y), LightB);
		Game->SetComboCSet((Game->GetCurMap() + MapDiff), Game->GetCurScreen(), ComboAt(X, Y), LightColor);
		LightDir = DIR_UP;
	}//end else if
	
	//Light will change direction from Right to Up.
	else if(GetLayerComboT(0, ComboAt(X, Y)) == CT_MIRRORSLASH && LightDir == DIR_RIGHT || GetLayerComboT(0, ComboAt(X, Y)) == CT_MIRRORSLASH && LightDir == DIR_RIGHT){
		SetLayerComboD(Layer, ComboAt(X, Y), LightB);
		Game->SetComboCSet((Game->GetCurMap() + MapDiff), Game->GetCurScreen(), ComboAt(X, Y), LightColor);
		LightDir = DIR_UP;
	}//end else if
	
	//Light will change direction from Right to Down.
	else if(GetLayerComboT(0, ComboAt(X, Y)) == CT_MIRRORBACKSLASH && LightDir == DIR_RIGHT || GetLayerComboT(0, ComboAt(X, Y)) == CT_MIRRORBACKSLASH && LightDir == DIR_RIGHT){
		SetLayerComboD(Layer, ComboAt(X, Y), LightB);
		Game->SetComboCSet((Game->GetCurMap() + MapDiff), Game->GetCurScreen(), ComboAt(X, Y), LightColor);
		LightDir = DIR_DOWN;
	}//end else if
	
	//Light will not change direction
	else{
		SetLayerComboD(Layer, ComboAt(X, Y), LightCombo);
		Game->SetComboCSet((Game->GetCurMap() + MapDiff), Game->GetCurScreen(), ComboAt(X, Y), LightColor);
		return LightDir;
	}//end else
	//if else-if else bracket ends here.
	return LightDir;
}//end DrawCombo

void DrawBlank(){
	for(int a = 0; a < 175; a++){
		SetLayerComboD(Layer, a, 0);
	}//end for
}//end DrawBlank

bool ScreenCheck(int X, int Y){
	if(X > 272 || X < -16 || Y > 192 || Y < -16){
		return false;
	}//end if
	else{
		return true;
	}//end else
}//end ScreenCheck