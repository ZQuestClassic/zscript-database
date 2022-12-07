//	Oracle Style Gasha Trees (By Lunaria)
//
//	How To Install:
//	Place GB_Gasha_EnemyDying() in your global active loop
//	Place and config FFCs in your quest
//	???
//	Profit &&|| Gambling addiction

//  Config options:

//General
const int GASHA_Counter = 11;		//	Counter reference used for the amount of seeds you have! Default is (CR_SCRIPT5) Aka, Script 5.
const int GASHA_Ring_ID = 0;		//	Set to an item ID that when Link posses, trees will grow att double the rate. Leave 0 to not use.
const int GASHA_Tree_Cset = 2;		//	Cset the tree will use
const int GASHA_Nut_Cset = 8;		//	Cset the nut will use

//Change the number to match whatever item ID you want for each specific entry in the reward pools
//Trash items only spawn at low gasha progression levels
const int GASHA_R_Trash1 = 2;		//	2 = Recovery heart
const int GASHA_R_Trash2 = 69;		//	69 = Fairy (stationary)

//Rupees spawn in the various gasha progression levels, higher ones in higher progression
const int GASHA_R_Rupee1 = 86;		//	86 = 10 Rupee
const int GASHA_R_Rupee2 = 38;		//	38 = 20 Rupee
const int GASHA_R_Rupee3 = 39;		//	39 = 50 Rupee
const int GASHA_R_Rupee4 = 87;		//	87 = 100 Rupee

//rings only spawn in the highest their gasha progression and they are split up into pools of two.
const int GASHA_R_Ring1 = 101;		//	101 = Charge Ring
const int GASHA_R_Ring2 = 115;		//	115 = Magic Ring (L1)
const int GASHA_R_Ring3 = 121;		//	121 = Peril Ring
const int GASHA_R_Ring4 = 99;		//	99 = Whisp Ring
const int GASHA_R_Ring5 = 112;		//	112 = Heart Ring (L1)
const int GASHA_R_Ring6 = 122;		//	122 = Whimsical Ring


//Piece of heart is a unique drop that can only generate X amount of times:
const int GASHA_PoH_Amount = 1;
const int GASHA_R_PoH = 49;			//	49 = Piece of Heart


//interface drawing crap:
const int GASHA_String = 0;			//	String to play when you inspect a soft soil (leave at 0 if you don't want one).
const int GASAH_BOX = 0x0f;			//	BG colour for a bounding box asking you if you want to plant a seed
const int GASHA_FCset = 0x01;		//	Font colour
const int GASHA_FCsetB = 0x72;		//	Blinking colour for selected text option
const int GASHA_Font = 24;			//	Font used, see std_constants if you need help assiging. (24) Oracle Proportional is default
const int GASHA_BoxX = 32;			//	Where the box starts to draw in X, recommended to not mess with.
const int GASHA_BoxY = 96;			//	How far up or down on the screen the box draws.
const int GASHA_M_SFX = 5;			//	Making a selection SFX.


//Don't mess with these unless you know what you're doing....
const int GASHA_PoH_ID = 99;
float GB_GASHA[100];



//----------------------------------------------------------------------------------------------------------

ffc script GashaTree{
	void run(float ID, int RewardPool, int ScreenFFCIndex, int FreezeCombo, int FirstTreeCombo, int GrowDirection, int CustomLoot1, int CustomLoot2){
		
		
		ffc ThisFFC = Screen->LoadFFC(ScreenFFCIndex);
		int StringPlant[] = "Plant Gasha Seed?";
		int StringYes[] = "Plant";
		int StringNo[] = "Don't";
		
		int ComboOnFile = this->Data;
		
		int NutX = GASHA_NutX(this->X, this->Y, GrowDirection);
		int NutY = GASHA_NutY(this->X, this->Y, GrowDirection);
		
		//RNG of the seed is set when they are planted, no save scumming :^)
		int NutRNG = 0;
		if(GB_GASHA[ID] > -1){
			NutRNG = (GB_GASHA[ID] - Floor(GB_GASHA[ID])) * 100;
		}
		
		//Makes sure you can carry seeds.
		if(Game->MCounter[GASHA_Counter] < 99) Game->MCounter[GASHA_Counter] = 99;
		
		//initical array config
		if(GB_GASHA[98] == 0){
			
			for(int i = 0; i < 99; i++){
				
				GB_GASHA[i] = -1;
				
			}
			
		}
		

		if(GB_GASHA[ID] == -1){
			while(GB_GASHA[ID] == -1){
				
				if(LinkCollision(ThisFFC) && Link->PressA){
					
					Screen->Message(GASHA_String);
					Waitframes(1);
					Link->PressA = false;
					
					bool YesOrNo = true;
					bool ChoiceMade = false;
					int CSetFlash = 0;
					
					if(Game->Counter[GASHA_Counter] > 0){
						
						this->Data = FreezeCombo;
						
						while(!ChoiceMade){
							Screen->Rectangle(6, GASHA_BoxX, GASHA_BoxY, GASHA_BoxX + 16 * 12, GASHA_BoxY + 16 * 2, GASAH_BOX, 1, 0, 0, 0, true, OP_OPAQUE);
							//	Screen->Rectangle(6, GASHA_BoxX, GASHA_Boxy, GASHA_BoxX + 16 * 12, GASHA_BoxY + 16 * 3, GASAH_BOX, float scale, int rx, int ry, int rangle, true, OP_OPAQUE);
							
							Screen->DrawString(6, GASHA_BoxX + 16 * 6, GASHA_BoxY, GASHA_Font, GASHA_FCset, -1, TF_CENTERED, StringPlant, OP_OPAQUE);
							
							Screen->DrawString(6, GASHA_BoxX + 16 * 3, GASHA_BoxY + 16, GASHA_Font, GASHA_FCset, -1, TF_CENTERED, StringYes, OP_OPAQUE);
							Screen->DrawString(6, GASHA_BoxX + 16 * 9, GASHA_BoxY + 16, GASHA_Font, GASHA_FCset, -1, TF_CENTERED, StringNo, OP_OPAQUE);	
							
							if(CSetFlash <= 15){
								if(YesOrNo)Screen->DrawString(6, GASHA_BoxX + 16 * 3, GASHA_BoxY + 16, GASHA_Font, GASHA_FCsetB, -1, TF_CENTERED, StringYes, OP_OPAQUE);			
								else{
									Screen->DrawString(6, GASHA_BoxX + 16 * 9, GASHA_BoxY + 16, GASHA_Font, GASHA_FCsetB, -1, TF_CENTERED, StringNo, OP_OPAQUE);		
								}
							}
							
							if(Link->PressLeft || Link->PressRight){
								Game->PlaySound(GASHA_M_SFX);
								if(YesOrNo == true) YesOrNo = false;
								else{
									YesOrNo = true;
								}
							}
							else if(Link->PressA){
								ChoiceMade = true;
								Game->PlaySound(GASHA_M_SFX);
								Link->PressA = false;
							}
							
							
							CSetFlash ++;
							if(CSetFlash > 30) CSetFlash = 0;
							Waitframe();
						}
						
						this->Data = ComboOnFile;
						
						if(YesOrNo == true){
						
							Game->Counter[GASHA_Counter] --;
							GB_GASHA[ID] = 0 + (Rand(100) / 100);
							
							Screen->ComboD[ComboAt(this->X +4, this->Y +4)] = FirstTreeCombo + 2;
							Screen->ComboC[ComboAt(this->X +4, this->Y +4)] = GASHA_Tree_Cset;
							
						}
						
						
					}
					
					
					
					
					
					
					
					
					
				}
				
				
				Waitframe();
			}
		}
		else if(GB_GASHA[ID] < 40){
			//Sapling stage
			Screen->ComboD[ComboAt(this->X +4, this->Y +4)] = FirstTreeCombo + 2;
			Screen->ComboC[ComboAt(this->X +4, this->Y +4)] = GASHA_Tree_Cset;
			
		}
		else if(GB_GASHA[ID] < 60){
			//Grown stage
			GASHA_SpawnTree(this->X + 4, this->Y + 4, GrowDirection, FirstTreeCombo);
			
		}
		else if(GB_GASHA[ID] >= 60){
			//Nut reward stage 1 - 3
			GASHA_SpawnTree(this->X + 4, this->Y + 4, GrowDirection, FirstTreeCombo);
			
			int RewardGrowthCycle = 1;
			if(GB_GASHA[ID] < 90) RewardGrowthCycle = 1;
			else if(GB_GASHA[ID] < 120) RewardGrowthCycle = 2;
			else if(GB_GASHA[ID] >= 120) RewardGrowthCycle = 3;
			
			int RewardID = GASHA_NutContent(RewardGrowthCycle, NutRNG, RewardPool, CustomLoot1, CustomLoot2);
			
			item GashaReward = Screen->CreateItem(RewardID);
			GashaReward->X = NutX;
			GashaReward->Y = NutY;
			GashaReward->DrawXOffset = 16*16;
			GashaReward->Pickup = IP_HOLDUP;
			
			lweapon SwordDe;
			
			bool harvest = false;
			while(!harvest){
				
				for(int i = 0; i <= Screen->NumLWeapons(); i++){

					SwordDe = Screen->LoadLWeapon(i);
					
					if(SwordDe->ID == LW_SWORD && Collision(SwordDe, GashaReward) && Link->Z == 0){
						harvest = true;
						i = i + 999;
					} 
				}
				
				
				if(GashaReward->isValid()) Screen->FastCombo(6, GashaReward->X, GashaReward->Y, FirstTreeCombo + 3, GASHA_Nut_Cset, OP_OPAQUE);
				else{
					harvest = true;
				}
				
				Waitframe();
			}
			
			GashaReward->Z = 16;
			GashaReward->Y = GashaReward->Y + 16;
			
			int ReduceZ_Fcount = 0;
			
			this->Data = FreezeCombo;
			while(GashaReward->X != Link->X || GashaReward->Y != Link->Y){
				
				
				
				if(GashaReward->X < Link->X - 8) GashaReward->X = GashaReward->X + 2;
				else if(GashaReward->X < Link->X) GashaReward->X ++;
				else if(GashaReward->X > Link->X + 8) GashaReward->X = GashaReward->X - 2;
				else if(GashaReward->X > Link->X) GashaReward->X --;
				
				if(GashaReward->Y < Link->Y - 8) GashaReward->Y = GashaReward->Y + 2;
				else if(GashaReward->Y < Link->Y) GashaReward->Y ++;
				else if(GashaReward->Y > Link->Y + 8) GashaReward->Y = GashaReward->Y - 2;
				else if(GashaReward->Y > Link->Y) GashaReward->Y --;
				
				if(ReduceZ_Fcount < 4) GashaReward->Z = 16;
				else if(ReduceZ_Fcount < 8) GashaReward->Z = 15;
				else{
					GashaReward->Z = 14;
				} 
				
				Screen->FastCombo(6, GashaReward->X, GashaReward->Y - GashaReward->Z, FirstTreeCombo + 3, GASHA_Nut_Cset, OP_OPAQUE);
				ReduceZ_Fcount ++;
				Waitframe();
			}

			GashaReward->DrawXOffset = 0;
			GashaReward->Jump = -10;
			
			this->Data = ComboOnFile;
			GB_GASHA[ID] = -1;
			//if piece of heart, increase PoH count
			if(RewardID == GASHA_R_PoH) GB_GASHA[GASHA_PoH_ID] ++;
			
		}
		
		
		
	}
}



int GASHA_NutContent(int GrowthCycle, int NutRNG, int SoilTier, int C_Loot1, int C_Loot2){
	
	int NutContents = 0;
	int Ring1 = 0;
	int Ring2 = 0;
	int Ring3 = 0;
	
	bool CustomPool = false;
	if(C_Loot1 != 0 && C_Loot2 != 0){
		
		CustomPool = true;
		
	}
	else if(SoilTier <= 1){
		Ring1 = GASHA_R_Ring1;
		Ring2 = GASHA_R_Ring2;
	}
	else if(SoilTier == 2){
		Ring1 = GASHA_R_Ring3;
		Ring2 = GASHA_R_Ring4;
	}
	else if(SoilTier == 3){
		Ring1 = GASHA_R_Ring5;
		Ring2 = GASHA_R_Ring6;
	}
	else if(SoilTier >= 4){
		Ring1 = GASHA_R_Ring2;
		Ring2 = GASHA_R_Ring4;
		Ring3 = GASHA_R_Ring6;
	}
	
	//---------------
	
	if(GrowthCycle == 1){
		//mostly trash
		if(NutRNG < 10) NutContents = GASHA_R_Rupee2;
		else if(NutRNG < 50) NutContents = GASHA_R_Rupee1;
		else if(NutRNG < 65) NutContents = GASHA_R_Trash2;
		else{
			NutContents = GASHA_R_Trash1;
		}
		
	}
	else if(GrowthCycle == 2){
		
		if(NutRNG < 10) NutContents = GASHA_R_Rupee3;
		else if(NutRNG < 15) NutContents = GASHA_R_Trash2;
		else{
			NutContents = GASHA_R_Rupee2;
		}
		
	}
	else if(GrowthCycle == 3 && CustomPool == true){
		
		if(NutRNG < 20) NutContents = SoilTier;
		else if(NutRNG < 60) NutContents = C_Loot1;
		else{
			NutContents = C_Loot2;
		}
		
	}
	else if(GrowthCycle == 3 && SoilTier == 4){
		
		if(NutRNG < 25 && GB_GASHA[GASHA_PoH_ID] < GASHA_PoH_Amount) NutContents = GASHA_R_PoH;
		else if(NutRNG < 40) NutContents = Ring1;
		else if(NutRNG < 70) NutContents = Ring2;
		else{
			NutContents = Ring3;
		}
		
	}
	else if(GrowthCycle == 3){
		
		if(NutRNG < 10) NutContents = GASHA_R_Rupee4;
		else if(NutRNG < 55) NutContents = Ring1;
		else{
			NutContents = Ring2;
		}
		
	}
	
	return NutContents;
}


void GASHA_SpawnTree(int ffc_X, int ffc_Y, int GrowDirection, int FirstTreeCombo){
	
	if(GrowDirection == 0){
		Screen->ComboD[ComboAt(ffc_X - 16, ffc_Y - 16)] = FirstTreeCombo + 0;
		Screen->ComboD[ComboAt(ffc_X - 0, ffc_Y - 16)] = FirstTreeCombo + 1;
		Screen->ComboD[ComboAt(ffc_X - 16, ffc_Y - 0)] = FirstTreeCombo + 4;
		Screen->ComboD[ComboAt(ffc_X - 0, ffc_Y - 0)] = FirstTreeCombo + 5;
		
		Screen->ComboC[ComboAt(ffc_X - 16, ffc_Y - 16)] = GASHA_Tree_Cset;
		Screen->ComboC[ComboAt(ffc_X - 0, ffc_Y - 16)] = GASHA_Tree_Cset;
		Screen->ComboC[ComboAt(ffc_X - 16, ffc_Y - 0)] = GASHA_Tree_Cset;
		Screen->ComboC[ComboAt(ffc_X - 0, ffc_Y - 0)] = GASHA_Tree_Cset;
	}
	else if(GrowDirection == 1){
		Screen->ComboD[ComboAt(ffc_X - 0, ffc_Y - 16)] = FirstTreeCombo + 0;
		Screen->ComboD[ComboAt(ffc_X + 16, ffc_Y - 16)] = FirstTreeCombo + 1;
		Screen->ComboD[ComboAt(ffc_X - 0, ffc_Y - 0)] = FirstTreeCombo + 4;
		Screen->ComboD[ComboAt(ffc_X + 16, ffc_Y - 0)] = FirstTreeCombo + 5;
		
		Screen->ComboC[ComboAt(ffc_X - 0, ffc_Y - 16)] = GASHA_Tree_Cset;
		Screen->ComboC[ComboAt(ffc_X + 16, ffc_Y - 16)] = GASHA_Tree_Cset;
		Screen->ComboC[ComboAt(ffc_X - 0, ffc_Y - 0)] = GASHA_Tree_Cset;
		Screen->ComboC[ComboAt(ffc_X + 16, ffc_Y - 0)] = GASHA_Tree_Cset;
	}
	else if(GrowDirection == 2){
		Screen->ComboD[ComboAt(ffc_X - 16, ffc_Y - 0)] = FirstTreeCombo + 0;
		Screen->ComboD[ComboAt(ffc_X + 0, ffc_Y - 0)] = FirstTreeCombo + 1;
		Screen->ComboD[ComboAt(ffc_X - 16, ffc_Y + 16)] = FirstTreeCombo + 4;
		Screen->ComboD[ComboAt(ffc_X + 0, ffc_Y + 16)] = FirstTreeCombo + 5;
		
		Screen->ComboC[ComboAt(ffc_X - 16, ffc_Y - 0)] = GASHA_Tree_Cset;
		Screen->ComboC[ComboAt(ffc_X - 0, ffc_Y - 0)] = GASHA_Tree_Cset;
		Screen->ComboC[ComboAt(ffc_X - 16, ffc_Y + 16)] = GASHA_Tree_Cset;
		Screen->ComboC[ComboAt(ffc_X - 0, ffc_Y + 16)] = GASHA_Tree_Cset;
	}
	else if(GrowDirection == 3){
		Screen->ComboD[ComboAt(ffc_X - 0, ffc_Y - 0)] = FirstTreeCombo + 0;
		Screen->ComboD[ComboAt(ffc_X + 16, ffc_Y - 0)] = FirstTreeCombo + 1;
		Screen->ComboD[ComboAt(ffc_X - 0, ffc_Y + 16)] = FirstTreeCombo + 4;
		Screen->ComboD[ComboAt(ffc_X + 16, ffc_Y + 16)] = FirstTreeCombo + 5;
		
		Screen->ComboC[ComboAt(ffc_X - 0, ffc_Y - 0)] = GASHA_Tree_Cset;
		Screen->ComboC[ComboAt(ffc_X + 16, ffc_Y - 0)] = GASHA_Tree_Cset;
		Screen->ComboC[ComboAt(ffc_X - 0, ffc_Y + 16)] = GASHA_Tree_Cset;
		Screen->ComboC[ComboAt(ffc_X + 16, ffc_Y + 16)] = GASHA_Tree_Cset;
	}
	
	
}




int GASHA_NutX(int ffc_X, int ffc_Y, int GrowDirection){
	int NutX = ffc_X;
	if(GrowDirection == 0){
		NutX = ffc_X - 8;
	}
	else if(GrowDirection == 1){
		NutX = ffc_X + 8;
	}
	else if(GrowDirection == 2){
		NutX = ffc_X - 8;
	}
	else if(GrowDirection == 3){
		NutX = ffc_X + 8;
	}
	
	return NutX;
}
int GASHA_NutY(int ffc_X, int ffc_Y, int GrowDirection){
	int NutY = ffc_Y;
	if(GrowDirection == 0){
		NutY = ffc_Y - 8;
	}
	else if(GrowDirection == 1){
		NutY = ffc_Y - 8;
	}
	else if(GrowDirection == 2){
		NutY = ffc_Y + 8;
	}
	else if(GrowDirection == 3){
		NutY = ffc_Y + 8;
	}
	
	return NutY;
}







const int GASHA_DYINGTIMER = 5;

bool GB_Gasha_IsDying(npc nme){
	if(nme->isValid() && nme->HP <= 0){
		return true;
	}
	else{
		return false;
	}
}

void GB_Gasha_EnemyDying(){
	for(int i = 1; i <= Screen->NumNPCs(); i ++){
		
		npc nme = Screen->LoadNPC(i); //Loads the NPC
		if(GB_Gasha_IsDying(nme)){ //Check to see if the NPC is dying.
		
			if(nme->Misc[GASHA_DYINGTIMER] == 14){
				
				
				for(int i = 0; i < 98; i++){
				
					if(GB_GASHA[i] > -1) GB_GASHA[i] ++;
					if(Link->Item[GASHA_Ring_ID] && GASHA_Ring_ID != 0 && GB_GASHA[i] > -1) GB_GASHA[i] ++;

				}
				
				
			}
			nme->Misc[GASHA_DYINGTIMER] ++; //Increment the NPC's dying timer
		}
	}
}