//	Set-up instructions:
//	First configures all options at the start of the script in regards to what combo IDs to use and combo types, etc.
//	Import scripts and be sure to slot in both the item script and the FFC scripts in appropriate spots (important!)
//	Next, set up an item in Zelda Quest that has the item script Shovel configured to it.
//	Configure combos to be diggable in your quest based on the pre-sets you configured.
//	Dig away!
//
//	For Special Items you can dig up or Dig Secrets use the specialized FFC for that:
//		A good rule of thumb is to either have the combo of the FFC itself be nothing but transparent or have it only show up with lens of truth.
//		The FFC needs to be placed *ON* the combo you want the desired effect on.
//			(For you coders out there thats the ComboAt the FFC's X+4, Y+4 position, to give slight leeway).
//		If you give the FFC no data it will spawn the screens Secret Item (assuming it has not been gotten) when you dig there.
//		The other use for it (which does *not* spawn items) is to dig up a secret combo of your desire when you dig there.
//		If so you need to give the FFC the following info:
//		D0: Combo ID of the combo you wish to be there after you have dug.
//		D1: Set this to "1" if you want the Screen Secret to be triggered when you dig there. (Handy if you want it to be a thing you dig up once)
//
//Special items that are dug up uses the RoomData, set room type to special item to use.



//The combo type for diggable ground.
const int Shovel_ComboType = 143;	//Script 2 (143) is default for this. (Same as in the VD Tileset).

//Digging on proper combos will change the combo to this one:
const int Shovel_DugCombo = 10;		//Change to 0 to use the screens undercombo instead (Not really recommended).

//Digging up a pre-defined item (or secret temporarily) using the FFC will change the combo to this one:
const int Shovel_ItemCombo = 38;		//Note: It needs to be a *DIFFERENT* combo ID than the regular dug up terrain.

//Defined items that the shovel can dig up on generic diggable ground.
const int Shovel_ItemDrop1 = 0;			// 10% Chance.	(Default item is 1 Rupee)
const int Shovel_ItemDrop2 = 2;			// 10% Chance.	(Default item is a Recovery Heart)
const int Shovel_ItemDrop3 = 34;		// 3% Chance.	(Default item is a Fairy)
const int Shovel_ItemDrop4 = 1;			// 4% Chance.	(Default item is 5 Rupee)
const int Shovel_ItemDrop5 = 87;		// 1% Chance.	(Default item is 100 Rupee)

//Start of 8 combos in a row for the dig animation. (Up 1, Down 1, Left 1, Right 1, Up 2, Down 2, Left 2, Right 2)
const int Shovel_Anima_Start = 64;
//Start of 4 combos for the dirt clut that the shovel flings. (Up, Down, Left, Right)
const int Shovel_FlyingDirt = 72;

//The FFC slot where you put the main shovel script.
const int Shovel_FFC_Script = 14;

//Sound Effects that play:
const int Shovel_Sound = 100;		// successfully dig.
const int Shovel_Fail = 101;			//A error sound that plays when you dig undiggable combos.
const int Shovel_SecretSFX = 27;	//Places when you dig up a secret.
const int Shovel_SPItemSFX = 27;	//Secret SFX that plays when you dig up the special item.






//The flag to dig on to trigger secrets. (Does not need to be on a digable combo type!)
const int Shovel_SecretFlag = 99;	//General Purpose 2	 (99) is default for this.













item script Shovel{
	void run(){
		
		if(Link->Z > 0) return;
		int args[] = {103,0,0,0,0,0,0,0};
		RunFFCScript(Shovel_FFC_Script, args);
		
	}
}




ffc script Shovel_Diggy{
  void run(){
    int chance;
    int itemdrop;
    int itemlocx;
    int itemlocy;
	bool SpecialItem = false;
    // Link->Action=LA_ATTACKING;
	
	item ShovelLoot;
	
	bool DigSuccess = false;
	
	int DigComboX;
	int DigComboY;
	int DigComboLocation;
	if(Link->Dir == 0){
		DigComboX = Link->X + 8;
		DigComboY = Link->Y - 2;
	}
	else if(Link->Dir == 1){
		DigComboX = Link->X + 8;
		DigComboY = Link->Y + 18;
	}
	else if(Link->Dir == 2){
		DigComboX = Link->X - 2;
		DigComboY = Link->Y + 8;
	}
	else if(Link->Dir == 3){
		DigComboX = Link->X + 18;
		DigComboY = Link->Y + 8;
	}
	
	DigComboLocation = ComboAt(DigComboX,DigComboY);
	
	int DigComboX2 = ComboAt(DigComboX,DigComboY) % 16;
	DigComboX2 = DigComboX2 * 16;
	int DigComboY2 = ComboAt(DigComboX,DigComboY) / 16;
	DigComboY2 = Floor(DigComboY2);
	DigComboY2 = DigComboY2 * 16;
	
	
	for(int i; i != 10; i ++){
		Link->Invisible = true;
		
		Screen->FastCombo(2, Link->X, Link->Y, Shovel_Anima_Start + Link->Dir, 6, OP_OPAQUE);
		NoAction();
		
		Waitframe();
		Link->Invisible = false;
	}

	
    if(Screen->ComboT[ComboAt(DigComboX,DigComboY)] != Shovel_ComboType){
       Game->PlaySound(Shovel_Fail);
    }
    else{
		
       Game->PlaySound(Shovel_Sound);
	   DigSuccess = true;
	   
       chance=Rand(100)+1;
	   
//	   if(Screen->ComboT[ComboAt(DigComboX,DigComboY)] == Shovel_ComboType && Screen->ComboI[ComboAt(DigComboX,DigComboY)] == Shovel_SecretFlag){
//		   
//		   Screen->ComboD[ComboAt(DigComboX,DigComboY)] = Screen->UnderCombo;
//		   chance = 101;
//		   
//	   }
//	   else if(Screen->ComboF[ComboAt(DigComboX,DigComboY)] == Shovel_SecretFlag || Screen->ComboI[ComboAt(DigComboX,DigComboY)] == Shovel_SecretFlag){
//		   Game->PlaySound(Shovel_SecretSFX);
//		   Screen->TriggerSecrets();
//		   Screen->State[ST_SECRET] = true;
//		   chance = 101;
//	   }

	   Screen->ComboD[ComboAt(DigComboX,DigComboY)] = Screen->UnderCombo;
	   
	   if(Shovel_DugCombo > 0){
		   Screen->ComboD[ComboAt(DigComboX,DigComboY)] = Shovel_DugCombo;
		}

	   

		//Waiting to perfrom check for Secret Combo
		Waitframe();
		if(Screen->ComboD[DigComboLocation] == Shovel_DugCombo){
			
		
		   if(chance<=10){		//10%
			   itemdrop = Shovel_ItemDrop1;	//1 rupee
		   }
		   else if(chance<=20){	//10%
			   itemdrop = Shovel_ItemDrop2;	//Recovery heart
		   }
		   else if(chance<=23){	//3%
			   itemdrop = Shovel_ItemDrop3;	//Fairy
		   }
		   else if(chance<=27){	//4%
			   itemdrop = Shovel_ItemDrop4;	//5 Rupee
		   }
		   else if(chance<=28){	//1%
			   itemdrop = Shovel_ItemDrop5;	//100 Rupee
		   }
		   else{
			   itemdrop = - 999;	//No item drop
		   }
			
		}
	   else if(Screen->ComboD[DigComboLocation] == Shovel_ItemCombo){
		   
		   
		   
		   if(Screen->State[ST_SPECIALITEM] == true){
			   itemdrop = - 999;
		   }
		   else{
			   SpecialItem = true;
			   itemdrop = Screen->RoomData;
			   Game->PlaySound(Shovel_SPItemSFX);
		   }
		   
		   
	   }
	   
	   
	    if(Link->Dir==0){	//Spawn location
		   itemlocx=Link->X;
		   itemlocy=Link->Y-16;
	   }
	   if(Link->Dir==1){
		   itemlocx=Link->X;
		   itemlocy=Link->Y+16;
	   }
	   if(Link->Dir==2){
		   itemlocx=Link->X-16;
		   itemlocy=Link->Y;
	   }
	   if(Link->Dir==3){
		   itemlocx=Link->X+16;
		   itemlocy=Link->Y;
	   }
	   

       if(itemdrop != -999){
           ShovelLoot=Screen->CreateItem(itemdrop);
           ShovelLoot->X=itemlocx;
           ShovelLoot->Y=itemlocy;
           ShovelLoot->Z=2;
		   ShovelLoot->Jump = 2;
		   if(SpecialItem){
				ShovelLoot->Pickup=IP_ST_SPECIALITEM + IP_HOLDUP;
				//	ShovelLoot->Pickup=IP_ST_SPECIALITEM;
		   }
		   else{
				ShovelLoot->Pickup=IP_TIMEOUT;
		   }
       }
    }
	
	int shovel_item_dir = Link->Dir;
	int DirtClutX = DigComboX2;
	int DirtClutY = DigComboY2;
	
	
	for(int i; i != 10; i ++){
		Link->Invisible = true;
		
		Screen->FastCombo(2, Link->X, Link->Y, Shovel_Anima_Start + 4 + Link->Dir, 6, OP_OPAQUE);
		NoAction();
		
		if(i < 5){
			
			if(shovel_item_dir == 0)DirtClutY --;
			if(shovel_item_dir == 1 && i % 2 == 0)DirtClutY ++;
			
			//sideways
			if(shovel_item_dir > 1)DirtClutY --;
			if(shovel_item_dir == 3)DirtClutX = DigComboX + (i / 2); 
			if(shovel_item_dir == 2)DirtClutX = DigComboX - (i / 2);
			
		}
		else{
			
			if(shovel_item_dir == 0 && i % 2 == 0)DirtClutY --;
			if(shovel_item_dir == 1)DirtClutY ++;
			
			//sideways
			if(shovel_item_dir > 1)DirtClutY ++;
			if(shovel_item_dir == 3)DirtClutX = DigComboX + (i / 2); 
			if(shovel_item_dir == 2)DirtClutX = DigComboX - (i / 2);
			
		}
		if(DigSuccess)Screen->FastCombo(2, DirtClutX, DirtClutY, Shovel_FlyingDirt + shovel_item_dir, 6, OP_OPAQUE);
		
		
		if(Screen->ComboS[ComboAt(ShovelLoot->X + 8, ShovelLoot->Y + 8)] == 0){
			
			if(shovel_item_dir == 0)ShovelLoot->Y --;
			else if(shovel_item_dir == 1)ShovelLoot->Y ++;
			else if(shovel_item_dir == 2)ShovelLoot->X --;
			else if(shovel_item_dir == 3)ShovelLoot->X ++;
			
		}
		
		
		Waitframe();
		Link->Invisible = false;
	}
	
	while(ShovelLoot->Z > 0){
		
		if(Screen->ComboS[ComboAt(ShovelLoot->X + 8, ShovelLoot->Y + 8)] == 0){
			
			if(shovel_item_dir == 0)ShovelLoot->Y --;
			else if(shovel_item_dir == 1)ShovelLoot->Y ++;
			else if(shovel_item_dir == 2)ShovelLoot->X --;
			else if(shovel_item_dir == 3)ShovelLoot->X ++;
			
		}
		
		Waitframe();
		
	}
	
  }
}


ffc script Shovel_SP_DigPoint{
	void run(int Secret_Combo, int Secret_State){
		
		int ComboLoc = ComboAt(this->X + 4, this->Y + 4);
		//	just script a FFC as "dig point" that changes it's combo to something specific when dug
		//	probably the best solution
		//	since you could define on the fly what you'd want it to be
		
		bool CheckForIt = true;
		
		while(CheckForIt){
		
			if(Screen->ComboD[ComboLoc] == Shovel_DugCombo){
				
				if(Secret_Combo <= 0){
					
					Screen->ComboD[ComboLoc] = Shovel_ItemCombo;
					
				}
				else{
					
					Screen->ComboD[ComboLoc] = Secret_Combo;
					Game->PlaySound(Shovel_SecretSFX);
					
					
					if(Secret_State == 1){
						
						Screen->TriggerSecrets();
						Screen->State[ST_SECRET] = true;
						
					}
					
				}
				
				CheckForIt = false;
				
			}
		
			Waitframe();
		
		}
		
		
	}
}