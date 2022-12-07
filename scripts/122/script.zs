//=========================================Color Cube==========================================
//Place Red Cube first. Default Cube start: Red Up(active), Blue Vertical(up and down), Yellow Horizontal(left and right).
//D0: screen combo position of the secret trigger.
//D1: Color needed to tigger secrets. Use Colors constants for values.



//Color Cube Combos
const int BlockRed = 0;
const int BlockBlue = 0;
const int BlockYellow = 0;

//**Do not edit values past this point**
//Colors
const int RED = 0;
const int BLUE = 1;
const int YELLOW = 2;

ffc script ColorCube{
	void run(int SecretPos, int SecretColor){
	
		//Cube attributes.
		int ColorActive = RED;
		int ColorVert = BLUE;
		int ColorHorz = YELLOW;
		int ColorTemp;
		bool Pushed = false;
		
		//Cube positions.
		int CubePos;
		int CubeUp;
		int CubeDown;
		int CubeLeft;
		int CubeRight;
	
		while(true){
			
			for(int a = 0; a <= 175; a++){
				if(Screen->ComboD[a] == BlockRed || Screen->ComboD[a] == BlockBlue || Screen->ComboD[a] == BlockYellow){
					CubePos = a; //Grab the pos of the cube.
					CubeUp = CubePos - 16; //Grab the pos 1 tile up.
					CubeDown = CubePos + 16; //Grab the pos 1 tile down.
					CubeLeft = CubePos - 1; //Grab the pos 1 tile left.
					CubeRight = CubePos + 1; //Grab the pos 1 tile right.
					break;
				}//end if
			}//end for
			
			if(Screen->MovingBlockX > -1 || Screen->MovingBlockY > -1){
				Pushed = true;
			}//end if
			
			if(Pushed){
			
				while(Screen->MovingBlockX > -1 || Screen->MovingBlockY > -1){
					Waitframe();
				}//end while
				
				for(int a = 0; a <= 175; a++){
					if(Screen->ComboD[a] == BlockRed || Screen->ComboD[a] == BlockBlue || Screen->ComboD[a] == BlockYellow){
						if(a == CubeUp || a == CubeDown){
							ColorTemp = ColorActive;
							ColorActive = ColorVert;
							ColorVert = ColorTemp;
							break;
						}//end if
						else if(a == CubeLeft || a == CubeRight){
							ColorTemp = ColorActive;
							ColorActive = ColorHorz;
							ColorHorz = ColorTemp;
							break;
						}//end else if
					}//end if
				}//end for
				
				
				if(ColorActive == RED){
					Screen->ComboD[FirstComboOf(BlockBlue, 0)] = BlockRed;
					Screen->ComboD[FirstComboOf(BlockYellow, 0)] = BlockRed;
				}//end if
				else if(ColorActive == BLUE){
					Screen->ComboD[FirstComboOf(BlockRed, 0)] = BlockBlue;
					Screen->ComboD[FirstComboOf(BlockYellow, 0)] = BlockBlue;
				}//end else if
				else if(ColorActive == YELLOW){
					Screen->ComboD[FirstComboOf(BlockRed, 0)] = BlockYellow;
					Screen->ComboD[FirstComboOf(BlockBlue, 0)] = BlockYellow;
				}//end else if
			
				Pushed = false;
			
			}//end if
			
			if(Screen->ComboD[SecretPos] == BlockRed && ColorActive == SecretColor || Screen->ComboD[SecretPos] == BlockBlue && ColorActive == SecretColor || Screen->ComboD[SecretPos] == BlockYellow && ColorActive == SecretColor){
				Screen->TriggerSecrets();
				Game->PlaySound(SFX_SECRET);
				//Screen->ComboT[FirstComboOf(BlockRed, 0)] = CT_NONE;
				//Screen->ComboT[FirstComboOf(BlockBlue, 0)] = CT_NONE;
				//Screen->ComboT[FirstComboOf(BlockYellow, 0)] = CT_NONE;
				//Screen->ComboI[FirstComboOf(BlockRed, 0)] = CF_NONE;
				//Screen->ComboI[FirstComboOf(BlockBlue, 0)] = CF_NONE;
				//Screen->ComboI[FirstComboOf(BlockYellow, 0)] = CF_NONE;
				Quit();
			}//end if
			
			Waitframe();
		
		}//end while
	}//end run
}//end ffc