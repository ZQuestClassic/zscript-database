const int RESET_NPC_LAYER_ON_ENTRY = 1; //This fix will replace all CMB_NPC_SOLID tiles with CMB_NPC_HIDDEN 
										//when entering the screen. This should prevent problems with shared
										//layers. If you don't want this fix, set it to 0.
										
const int NPCSCRIPT_ITEMCHECK_ONLY_UPDATES_ON_SCREEN_ENTRY = 1; //Set to 1 if you want itemcheck NPCs to only disappear 
																//after you leave the screen.
										
const int NPCSCRIPT_WAITS_UNTIL_SCRIPTS_FINISH = 1; //This will make the script wait until a called script
													//finishes before resuming, fixing issues where you talk
													//to the NPC a second time while you should be frozen

const int NPCSCRIPT_CHECK_LINKACTION = 1; //This will make it so Link can't talk to NPCs while in non passive actions
										  //For example, when in a whistle whirlwind.

const int NPCSCRIPT_ALLOW_IN_WATER = 0; //This will make it so Link can still talk to NPCs while swimming. 
										//Otherwise he must be on land.

const int NPCSCRIPT_ALLOW_IN_AIR = 0; //This will make it so Link can still talk to NPCs while jumping.

const int LAYER_NPC = 2; //The layer NPCs use for solid combos
const int CMB_NPC_HIDDEN = 41; //Non-solid combo used for hidden NPCs
const int CMB_NPC_SOLID = 42; //Solid combo placed under visible NPCs

const int LAYER_NPC_CANTALK = 4; //The layer used for the speech bubble
const int CMB_NPC_CANTALK = 44; //The combo used for the speech bubble
const int CS_NPC_CANTALK = 8; //The CSet used for the speech bubble

const int NPCBT_NONE = 0; //Regular NPCs
const int NPCBT_FACELINK = 1; //NPCs that turn to face Link
const int NPCBT_GUARDH = 2; //NPCs that move along a horizontal path
const int NPCBT_GUARDV = 3; //NPCs that move along a vertical path

ffc script NPCScript{
	void run(int msg, int ItemCheck, int Type, int Arg1, int Arg2, int NoSolid, int scriptSlot, int ScriptArg){
		//Stores the NPC's combo, hides it
		int Combo = this->Data;
		this->Data = CMB_NPC_HIDDEN;
		//Waits until the NPC should appear and shows it
		if(ItemCheck<0){
			while(!Link->Item[Abs(ItemCheck)]){
				Waitframe();
			}
			this->Data = Combo;
			if(Type==NPCBT_FACELINK){
				this->Data = Combo + Arg1;
			}
		}
		else if(ItemCheck>0){
			if(!Link->Item[Abs(ItemCheck)]){
				this->Data = Combo;
				if(Type==NPCBT_FACELINK){
					this->Data = Combo + Arg1;
				}
			}
		}
		else if(ItemCheck==0){
			this->Data = Combo;
			if(Type==NPCBT_FACELINK){
				this->Data = Combo + Arg1;
			}
		}
		//Saves the width and height of the FFC for collision checks
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
		//Wait until the screen is done scrolling to avoid a weird ZC crashing bug
		Waitframe();
		while(Link->Action==LA_SCROLLING){
			Waitframe();
		}
		//Shared Layer Fix
		if(RESET_NPC_LAYER_ON_ENTRY==1){
			if(Screen->LoadFFC(FindFFCRunning(this->Script))==this){
				for(int i=0; i<176; i++){
					if(GetLayerComboD(LAYER_NPC, i)==CMB_NPC_SOLID){
						SetLayerComboD(LAYER_NPC, i, CMB_NPC_HIDDEN);
					}
				}
			}
		}
		//Sets the space below the NPC or the space a guard NPC occupies to be solid
		if(LAYER_NPC>-1&&NoSolid==0){
			if(Type==NPCBT_GUARDH){
				for(int x=Arg1; x<=Arg2+this->TileWidth-1; x++){
					for(int y=Floor(this->Y/16); y<=Floor(this->Y/16)+this->TileHeight-1; y++){
						SetLayerComboD(LAYER_NPC, y*16+x, CMB_NPC_SOLID);
					}
				}
			}
			else if(Type==NPCBT_GUARDV){
				for(int x=Floor(this->X/16); x<=Floor(this->X/16)+this->TileWidth-1; x++){
					for(int y=Arg1; y<=Arg2+this->TileHeight-1; y++){
						SetLayerComboD(LAYER_NPC, y*16+x, CMB_NPC_SOLID);
					}
				}
			}
			else{
				for(int x=Floor(this->X/16); x<=Floor(this->X/16)+this->TileWidth-1; x++){
					for(int y=Floor(this->Y/16); y<=Floor(this->Y/16)+this->TileHeight-1; y++){
						SetLayerComboD(LAYER_NPC, y*16+x, CMB_NPC_SOLID);
					}
				}
			}
		}
		bool canTalk;
		bool canItemCheck = true;
		while(true){
			//Prevent checking items past the first frame if the rule is checked
			if(!NPCSCRIPT_ITEMCHECK_ONLY_UPDATES_ON_SCREEN_ENTRY)
				canItemCheck = true;
			
			//Removes NPCs if Link has the required item
			if(ItemCheck>0&&canItemCheck){
				if(Link->Item[ItemCheck]){
					this->Data = CMB_NPC_HIDDEN;
					if(LAYER_NPC>-1&&NoSolid==0){
						if(Type==NPCBT_GUARDH){
							for(int x=Arg1; x<=Arg2+this->TileWidth-1; x++){
								for(int y=Floor(this->Y/16); y<=Floor(this->Y/16)+this->TileHeight-1; y++){
									SetLayerComboD(LAYER_NPC, y*16+x, CMB_NPC_HIDDEN);
								}
							}
						}
						else if(Type==NPCBT_GUARDV){
							for(int x=Floor(this->X/16); x<=Floor(this->X/16)+this->TileWidth-1; x++){
								for(int y=Arg1; y<=Arg2+this->TileHeight-1; y++){
									SetLayerComboD(LAYER_NPC, y*16+x, CMB_NPC_HIDDEN);
								}
							}
						}
						else{
							for(int x=Floor(this->X/16); x<=Floor(this->X/16)+this->TileWidth-1; x++){
								for(int y=Floor(this->Y/16); y<=Floor(this->Y/16)+this->TileHeight-1; y++){
									SetLayerComboD(LAYER_NPC, y*16+x, CMB_NPC_HIDDEN);
								}
							}
						}
					}
					Quit();
				}
			}
			
			canItemCheck = false;
			
			//Handles animation for turning NPCs
			if(Type==NPCBT_FACELINK&&(Link->X>0&&Link->X<240&&Link->Y>0&&Link->Y<160)){
				if(Distance(CenterLinkX(), CenterLinkY(), CenterX(this), CenterY(this))<Arg2)
					this->Data = Combo + AngleDir4(Angle(CenterX(this), CenterY(this), CenterLinkX(), CenterLinkY()));
				else
					this->Data = Combo + Arg1;
			}
			
			//Handles movement for guard NPCs
			else if(Type==NPCBT_GUARDH){
				if(Link->X>16*Arg1-32&&Link->X<16*Arg2+32&&Link->Y>this->Y-32&&Link->Y<this->Y+32){
					this->X = Clamp(this->X+(-this->X + Link->X)/4, 16*Arg1, 16*Arg2);
				}
			}
			else if(Type==NPCBT_GUARDV){
				if(Link->X>this->X-32&&Link->X<this->X+32&&Link->Y>16*Arg1-32&&Link->Y<16*Arg2+32){
					this->Y = Clamp(this->Y+(-this->Y + Link->Y)/4, 16*Arg1, 16*Arg2);
				}
			}
			
			int dialogueBox1[] = "DialogueBranch_Simple";
			int dialogueBox2[] = "DialogueBranch_Advanced";
			int scrDB1 = Game->GetFFCScript(dialogueBox1);
			int scrDB2 = Game->GetFFCScript(dialogueBox2);
			
			
			bool noTalk;
			if(CountFFCsRunning(scrDB1)>0)
				noTalk = true;
			if(CountFFCsRunning(scrDB2)>0)
				noTalk = true;
			if(NPCSCRIPT_CHECK_LINKACTION){
				if(Link->Action!=LA_NONE&&Link->Action!=LA_WALKING&&(Link->Action!=LA_SWIMMING||!NPCSCRIPT_ALLOW_IN_WATER))
					noTalk = true;
			}
			if(!NPCSCRIPT_ALLOW_IN_AIR&&Link->Z>0)
				noTalk = true;
			
			canTalk = false;
			//Facing Up
			if(!noTalk&&Link->Dir==DIR_UP&&Link->Y>=this->Y&&Link->Y<=this->Y+Height-8&&Link->X>=this->X-8&&Link->X<=this->X+Width-8){
				if(CMB_NPC_CANTALK>0)
					Screen->FastCombo(LAYER_NPC_CANTALK, Link->X, Link->Y-16-Link->Z, CMB_NPC_CANTALK, CS_NPC_CANTALK, 128);
				canTalk = true;
			}
			//Facing Down
			else if(!noTalk&&Link->Dir==DIR_DOWN&&Link->Y>=this->Y-16&&Link->Y<=this->Y+Height-16&&Link->X>=this->X-8&&Link->X<=this->X+Width-8){
				if(CMB_NPC_CANTALK>0)
					Screen->FastCombo(LAYER_NPC_CANTALK, Link->X, Link->Y-16-Link->Z, CMB_NPC_CANTALK, CS_NPC_CANTALK, 128);
				canTalk = true;
			}
			//Facing Left
			else if(!noTalk&&Link->Dir==DIR_LEFT&&Link->Y>=this->Y-8&&Link->Y<=this->Y+Height-8&&Link->X>=this->X&&Link->X<=this->X+Width){
				if(CMB_NPC_CANTALK>0)
					Screen->FastCombo(LAYER_NPC_CANTALK, Link->X, Link->Y-16-Link->Z, CMB_NPC_CANTALK, CS_NPC_CANTALK, 128);
				canTalk = true;
			}
			//Facing Right
			else if(!noTalk&&Link->Dir==DIR_RIGHT&&Link->Y>=this->Y-8&&Link->Y<=this->Y+Height-8&&Link->X>=this->X-16&&Link->X<=this->X+Width-16){
				if(CMB_NPC_CANTALK>0)
					Screen->FastCombo(LAYER_NPC_CANTALK, Link->X, Link->Y-16-Link->Z, CMB_NPC_CANTALK, CS_NPC_CANTALK, 128);
				canTalk = true;
			}
			
			if(canTalk&&Link->PressA){
				Link->InputA = false;
				Link->PressA = false;
				Screen->Message(msg);
				if(scriptSlot>0){
					int args[8] = {ScriptArg};
					int i = RunFFCScript(scriptSlot, args);
					if(NPCSCRIPT_WAITS_UNTIL_SCRIPTS_FINISH){
						ffc f = Screen->LoadFFC(i);
						while(f->Script==scriptSlot){
							Waitframe();
						}
					}
				}
			}
			Waitframe();
		}
	}
}

ffc script NPCScript_Simple{
	void run(int msg, int scriptSlot, int D0, int D1, int D2, int D3, int D4, int D5){
		//Saves the width and height of the FFC for collision checks
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
		bool canTalk;
		while(true){
			int dialogueBox1[] = "DialogueBranch_Simple";
			int dialogueBox2[] = "DialogueBranch_Advanced";
			int scrDB1 = Game->GetFFCScript(dialogueBox1);
			int scrDB2 = Game->GetFFCScript(dialogueBox2);
			
			bool noTalk;
			if(CountFFCsRunning(scrDB1)>0)
				noTalk = true;
			if(CountFFCsRunning(scrDB2)>0)
				noTalk = true;
			if(NPCSCRIPT_CHECK_LINKACTION){
				if(Link->Action!=LA_NONE&&Link->Action!=LA_WALKING&&(Link->Action!=LA_SWIMMING||!NPCSCRIPT_ALLOW_IN_WATER))
					noTalk = true;
			}
			if(!NPCSCRIPT_ALLOW_IN_AIR&&Link->Z>0)
				noTalk = true;
			
			canTalk = false;
			//Facing Up
			if(!noTalk&&Link->Dir==DIR_UP&&Link->Y>=this->Y&&Link->Y<=this->Y+Height-8&&Link->X>=this->X-8&&Link->X<=this->X+Width-8){
				if(CMB_NPC_CANTALK>0)
					Screen->FastCombo(LAYER_NPC_CANTALK, Link->X, Link->Y-16-Link->Z, CMB_NPC_CANTALK, CS_NPC_CANTALK, 128);
				canTalk = true;
			}
			//Facing Down
			else if(!noTalk&&Link->Dir==DIR_DOWN&&Link->Y>=this->Y-16&&Link->Y<=this->Y+Height-16&&Link->X>=this->X-8&&Link->X<=this->X+Width-8){
				if(CMB_NPC_CANTALK>0)
					Screen->FastCombo(LAYER_NPC_CANTALK, Link->X, Link->Y-16-Link->Z, CMB_NPC_CANTALK, CS_NPC_CANTALK, 128);
				canTalk = true;
			}
			//Facing Left
			else if(!noTalk&&Link->Dir==DIR_LEFT&&Link->Y>=this->Y-8&&Link->Y<=this->Y+Height-8&&Link->X>=this->X&&Link->X<=this->X+Width){
				if(CMB_NPC_CANTALK>0)
					Screen->FastCombo(LAYER_NPC_CANTALK, Link->X, Link->Y-16-Link->Z, CMB_NPC_CANTALK, CS_NPC_CANTALK, 128);
				canTalk = true;
			}
			//Facing Right
			else if(!noTalk&&Link->Dir==DIR_RIGHT&&Link->Y>=this->Y-8&&Link->Y<=this->Y+Height-8&&Link->X>=this->X-16&&Link->X<=this->X+Width-16){
				if(CMB_NPC_CANTALK>0)
					Screen->FastCombo(LAYER_NPC_CANTALK, Link->X, Link->Y-16-Link->Z, CMB_NPC_CANTALK, CS_NPC_CANTALK, 128);
				canTalk = true;
			}
			
			if(canTalk&&Link->PressA){
				Link->InputA = false;
				Link->PressA = false;
				Screen->Message(msg);
				if(scriptSlot>0){
					int Args[8] = {D0, D1, D2, D3, D4, D5};
					int i = RunFFCScript(scriptSlot, Args);
					if(NPCSCRIPT_WAITS_UNTIL_SCRIPTS_FINISH){
						ffc f = Screen->LoadFFC(i);
						while(f->Script==scriptSlot){
							Waitframe();
						}
					}
				}
			}
			Waitframe();
		}
	}
}

const int D_TRADE = 0; //Screen->D value used for the trade sequence state

ffc script TradeSequence{
	void run(int CheckItem, int TradeItem, int NoItemString, int HasItemString, int TradedString){
		//Check if the player has already traded
		if(Screen->D[D_TRADE]==0){
			//If player hasn't traded and has the required item, play HasItemString, give the new item, and take the old item
			if(Link->Item[CheckItem]){
				Screen->Message(HasItemString);
				WaitNoAction();
				item itm = CreateItemAt(TradeItem, Link->X, Link->Y);
				itm->Pickup = IP_HOLDUP;
				Link->Item[CheckItem] = false;
				Screen->D[D_TRADE] = 1;
				WaitNoAction();
			}
			//If player hasn't traded and doesn't have the required item, play NoItemString
			else{
				Screen->Message(NoItemString);
				WaitNoAction();
			}
		}
		//If the player has already traded, play TradedString
		else{
			Screen->Message(TradedString);
			WaitNoAction();
		}
	}
}