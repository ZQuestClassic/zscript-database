import "std.zh"			//Remove this line if you have already imported the standard library!!!
//							// IMPORTANT, READ THIS. ^^^^^^^
//Key block with removable key
ffc script DynamicKeyCube{
	void run(int D0){
		
		int OriginalData = this->Data;
		
		//--------------------------------- CONFIGURATION VARIABLES ---------------------------------//
		
		int PromtCombo = 3;		//Change this number to the number of the combo to appear above link's head when near.
		int PromtComboCset = 8;	//Cset of the above combo.
		int ErrorSound = 0;		//Sound that plays when trying to use the cube but you don't have enough keys, there is no default sfx for this, so you'll have to insert and configure this on your own.
		int KeyReturnSound = 25;	//The sound of the key being returned to your inventory.
		int ActivationSound = 9;	//Sound that plays both when a key is inserted, and when removed.
		
		//	[Insert Area Name].qst   //Stuff//
		//You know the folder/adress, right?   //Stuff//


		//---------------------------------- END OF CONFIGURATIONs ----------------------------------//
		
		if(D0 == 0){		//if no counter value is defined, use the counter value of regular (none level specific) keys.
			D0 = CR_KEYS;
		}
		
		int Width = 16;
		int Height = 16;
		if(this->EffectWidth!=16)
			Width = this->EffectWidth;
		else if(this->TileWidth>1)
			Width = this->TileWidth*16;
		if(this->EffectHeight!=16)
			Height = this->EffectHeight;
		else if(this->TileHeight>1)
			Height = this->TileHeight*16;
		
		while(true){
			
			
			if(Link->Dir==DIR_UP&&Link->Y>=this->Y&&Link->Y<=this->Y+Height-8&&Link->X>=this->X-8&&Link->X<=this->X+Width-8){
				
				DynamicKeyCubeNear(D0, PromtCombo, PromtComboCset, ActivationSound, KeyReturnSound, ErrorSound);
				
			}
			else if(Link->Dir==DIR_DOWN&&Link->Y>=this->Y-16&&Link->Y<=this->Y+Height-16&&Link->X>=this->X-8&&Link->X<=this->X+Width-8){
				
				DynamicKeyCubeNear(D0, PromtCombo, PromtComboCset, ActivationSound, KeyReturnSound, ErrorSound);
				
			}
			else if(Link->Dir==DIR_LEFT&&Link->Y>=this->Y-8&&Link->Y<=this->Y+Height-8&&Link->X>=this->X&&Link->X<=this->X+Width){
				
				DynamicKeyCubeNear(D0, PromtCombo, PromtComboCset, ActivationSound, KeyReturnSound, ErrorSound);
				
			}
			else if(Link->Dir==DIR_RIGHT&&Link->Y>=this->Y-8&&Link->Y<=this->Y+Height-8&&Link->X>=this->X-16&&Link->X<=this->X+Width-16){
				
				DynamicKeyCubeNear(D0, PromtCombo, PromtComboCset, ActivationSound, KeyReturnSound, ErrorSound);
				
			}
			
			
			if(Screen->State[ST_LOCKBLOCK] == false){
				this->Data = OriginalData;
				
			}
			else if(Screen->State[ST_LOCKBLOCK] == true){
				this->Data = OriginalData + 1;
				
			}
			
			
			Waitframe();
		}
		
		
	}
}

void DynamicKeyCubeNear(int D0, int PromtCombo, int PromtComboCset, int ActivationSound, int KeyReturnSound, int ErrorSound){
	
	Screen->FastCombo(4, Link->X, Link->Y-16, PromtCombo, PromtComboCset, 128);
	
	if(Link->PressA){
		
		Link->InputA = false;
		Link->PressA = false;
		
		
		if(Screen->State[ST_LOCKBLOCK] == false){
			
			
			
			if(Game->Counter[D0] > 0){
				
				Game->Counter[D0] --;
				Screen->State[ST_LOCKBLOCK] = true;
				Game->PlaySound(ActivationSound);	//sound for shutter in standard.
				
				//Waitframe();													//These solutions did not work.
				//Link->PitWarp(Game->GetCurDMap(), Game->GetCurScreen());
				//ScreenCopy(Game->GetCurMap(), Game->GetCurScreen(), Game->GetCurMap(), Game->GetCurScreen());
				
				
				for(int a = 0; a <= 175; a++){
					if(Screen->ComboT[a] == 59 || Screen->ComboT[a] == 60){
						
						Screen->ComboD[a] ++;
						
						//Game->Counter[20] = 25;
						
					}
				}
				
				Waitframe();
				Link->InputA = false;
			}
			else{
				
				Game->PlaySound(ErrorSound);
				
			}
			
			
			
		}
		else if(Screen->State[ST_LOCKBLOCK] == true){
			
			Game->Counter[D0] ++;
			Screen->State[ST_LOCKBLOCK] = false;
			
			Game->PlaySound(KeyReturnSound);		//sound for Itemget(2) in standard.
			Game->PlaySound(ActivationSound);			//sound for shutter in standard.
			
			//Waitframe();
			//Link->PitWarp(Game->GetCurDMap(), Game->GetCurScreen());
			//ScreenCopy(Game->GetCurMap(), Game->GetCurScreen(), Game->GetCurMap(), Game->GetCurScreen());
			
			
			for(int a = 0; a <= 175; a++){
				
				Screen->ComboD[a] --;
				
				if(Screen->ComboT[a] == 59 || Screen->ComboT[a] == 60){
					
					
					
				}
				else{
					
					Screen->ComboD[a] ++;
					
					
					
				}
				
			}
			
			
			Waitframe();
			Link->InputA = false;
			
		}
		
		for(int i = 0; i < 25; i++){
			
			
			Link->InputA = false;
			Link->PressA = false;
			Waitframe();
			
			if(Link->InputA == false){
				
				break; 
				
			}
			
		}
		
		
	}
}



ffc script DynamicItemCube{
	void run(int D0){
		
		int OriginalData = this->Data;
		
		//--------------------------------- CONFIGURATION VARIABLES ---------------------------------//
		
		int PromtCombo = 3;		//Change this number to the number of the combo to appear above link's head when near.
		int PromtComboCset = 8;	//Cset of the above combo.
		int ErrorSound = 71;		//Sound that plays when trying to use the cube but you don't have the item, there is no default sfx for this, so you'll have to insert and configure this on your own.
		//int KeyReturnSound = 25;	//The sound of the key being returned to your inventory.
		int ActivationSound = 65;	//Sound that plays both when a item is inserted, and when removed.
		
		
		//---------------------------------- END OF CONFIGURATIONs ----------------------------------//
		
		
		int Width = 16;
		int Height = 16;
		if(this->EffectWidth!=16)
			Width = this->EffectWidth;
		else if(this->TileWidth>1)
			Width = this->TileWidth*16;
		if(this->EffectHeight!=16)
			Height = this->EffectHeight;
		else if(this->TileHeight>1)
			Height = this->TileHeight*16;
		
		int holdupanimation = 0;
		
		while(true){
			
			
			
			if(Link->Dir==DIR_UP&&Link->Y>=this->Y&&Link->Y<=this->Y+Height-8&&Link->X>=this->X-8&&Link->X<=this->X+Width-8){
				
				holdupanimation = DynamicItemCubeNear(D0, PromtCombo, PromtComboCset, ActivationSound, ErrorSound);
				
			}
			//else if(Link->Dir==DIR_DOWN&&Link->Y>=this->Y-16&&Link->Y<=this->Y+Height-16&&Link->X>=this->X-8&&Link->X<=this->X+Width-8){
				
				//holdupanimation = DynamicItemCubeNear(D0, PromtCombo, PromtComboCset, ActivationSound, ErrorSound);
				
			//}
			//else if(Link->Dir==DIR_LEFT&&Link->Y>=this->Y-8&&Link->Y<=this->Y+Height-8&&Link->X>=this->X&&Link->X<=this->X+Width){
				
				//holdupanimation = DynamicItemCubeNear(D0, PromtCombo, PromtComboCset, ActivationSound, ErrorSound);
				
			//}
			//else if(Link->Dir==DIR_RIGHT&&Link->Y>=this->Y-8&&Link->Y<=this->Y+Height-8&&Link->X>=this->X-16&&Link->X<=this->X+Width-16){
				
				//holdupanimation = DynamicItemCubeNear(D0, PromtCombo, PromtComboCset, ActivationSound, ErrorSound);
				
			//}
			
			
			if(Screen->State[ST_CHEST] == false){
				this->Data = OriginalData;
				
			}
			else if(Screen->State[ST_CHEST] == true){
				this->Data = OriginalData + 1;
				
			}
			
			
			if(holdupanimation == 1){
				
				int itemRaise = 0;
				for(int i; i < 28; i++){
					
					item Temp = CreateItemAt(D0, 0, 0);
					Screen->FastTile(2, this->X, this->Y-8+itemRaise, Temp->OriginalTile, Temp->CSet, OP_OPAQUE);
					Remove(Temp);
					itemRaise-=0.25;
					
					NoAction();
					if(i==27){
						
						Screen->ComboT[ComboAt(this->X, this->Y)] = Screen->ComboT[ComboAt(this->X, this->Y)];
					}
					Waitframe();
				}
				
				holdupanimation = 0;
				
			}
			
			
			
			
			Waitframe();
		}
		
		
	}
}

int DynamicItemCubeNear(int D0, int PromtCombo, int PromtComboCset, int ActivationSound, int ErrorSound){
	
	//Key pressing button when near.
	// Screen->FastCombo(4, Link->X, Link->Y-16, PromtCombo, PromtComboCset, 128);	
	
	if(Link->PressA){
		
		Link->InputA = false;
		Link->PressA = false;
		
		
		if(Screen->State[ST_CHEST] == false){
			
			
			
			if(Link->Item[D0] == true){
				
				Link->Item[D0] = false;
				
				Screen->State[ST_CHEST] = true;
				Game->PlaySound(ActivationSound);	//sound for shutter in standard.
				
				//Waitframe();													//These solutions did not work.
				//Link->PitWarp(Game->GetCurDMap(), Game->GetCurScreen());
				//ScreenCopy(Game->GetCurMap(), Game->GetCurScreen(), Game->GetCurMap(), Game->GetCurScreen());
				
				
				for(int a = 0; a <= 175; a++){
					if(Screen->ComboT[a] == 65 || Screen->ComboT[a] == 66){
						
						Screen->ComboD[a] ++;
						
						//Game->Counter[20] = 25;
						
					}
				}
				
				Waitframe();
				Link->InputA = false;
				
				for(int i = 0; i < 25; i++){
					
					Link->InputA = false;
					Link->PressA = false;
					Waitframe();
					
					if(Link->InputA == false){
						
						break; 
						
					}
					
				}
				
			}
			else{
				
				Game->PlaySound(ErrorSound);
				
			}
			
			
			
		}
		else if(Screen->State[ST_CHEST] == true){
			
			Link->Item[D0] = true;
			Screen->State[ST_CHEST] = false;
			
			Game->PlaySound(20);		//sound for Itemget(2) in standard.
			Game->PlaySound(ActivationSound);			//sound for shutter in standard.
			
			//Waitframe();
			//Link->PitWarp(Game->GetCurDMap(), Game->GetCurScreen());
			//ScreenCopy(Game->GetCurMap(), Game->GetCurScreen(), Game->GetCurMap(), Game->GetCurScreen());
			
			
			for(int a = 0; a <= 175; a++){
				
				Screen->ComboD[a] --;
				
				if(Screen->ComboT[a] == 65 || Screen->ComboT[a] == 66){
					
					
					
				}
				else{
					
					Screen->ComboD[a] ++;
					
					
					
				}
				
			}
			
			
			
			
			return (1);
			
		}
		
		
	}
	
	return (0);
}