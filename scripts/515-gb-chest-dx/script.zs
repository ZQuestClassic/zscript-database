const int SCREEN_D_GBCHEST_DATA = 5; // change this to change which Screen->D value the chest data is stored into, to avoid conflicts with other scripts that use them



const int GBCHEST_PRIZE_RENDER_TIMER = 13; //Time to render prize before acquisition, in frames.

const int GBCHEST_PRIZE_RENDER_SPEED = 0.25; //Rising speed of revealed item during display.



//Reworked GB styled treasure chest, originally made by Nimono.

//Place invisible FFC on top left corner of treasure chest. Set TileWidth and TileHeight to match chest size 

// Variables:

// SCREEN_D_GBCHEST_DATA: Which Screen->D[] to use to track the chests. Make sure to pick one not currently in use by other scripts!

// D0 chestCombo: The starting combo for your chest. The script changes all combos overlapped by FFC to their next ones in combo data table. If left at 0, it uses combo underneath top left corner of FFC. Otherwise, it cannot be open, until combo underneath top left corner of FFC changes to combo, whose ID is stated in D0, usually via secrets. 

// D1 openSFX: What sound effect ID to play upon opening the chest.

// D2 receiveSFX: What sound to play upon receiving the item.

// D3 itemID: The item to give to the player upon opening the chest.

// D4 receiveMessage: Which message to display upon receiving the item.

// D5 itemDisplay: Whether or not to display the item rising from the chest. 0 = do not display, anything else = display.

// D6 lockValue: Whether or not to have the chest be locked. 0 = no lock, 1 = regular key required; 2 = boss key required. Original script had no support for Magic Key, this script allows using Magic Key to unlock GB chests.



// If you are using ghost.zh, uncomment out SuspendGhostZHScripts() and ResumeGhostZHScripts().



ffc script GBChest{

	void run(int chestCombo, int openSFX, int receiveSFX, int itemID, int receiveMessage, int itemDisplay, int lockValue){

		if (Screen->D[SCREEN_D_GBCHEST_DATA]&ConvertToBit(FFCNum(this))){

			GBChestReplaceCombosUnderFFC(this);

			Quit();

		}

		int cmb = ComboAt(this->X+1, this->Y+1);

		if (chestCombo==0)chestCombo = Screen->ComboD[cmb];

		if(itemID == 0)itemID = Screen->RoomData;

		int holdType = 0;

		int itemRaise = 0;

		item Temp = CreateItemAt(itemID, 0, 0);

		int itemtile = Temp->OriginalTile;

		int itemcset = Temp->CSet;

		Remove(Temp);

		while(true){

			if(Link->X >= this->X-8 && Link->X <= this->X+this->TileWidth*16-8 && Link->Y >= this->Y+4 && Link->Y <= this->Y+this->TileHeight*16-8){

				if(CenterLinkY() > CenterY(this) && Link->Dir==DIR_UP && Screen->ComboD[cmb] == chestCombo && (lockValue == 0 || (lockValue == 1 && Game->Counter[CR_KEYS] > 0) || (lockValue == 1 && (Game->LKeys[Game->GetCurLevel()] > 0 || Link->Item[I_MAGICKEY])) || (lockValue == 2 && Game->LItems[Game->GetCurLevel()]&LI_BOSSKEY))){

					if(lockValue == 1 && !Link->Item[I_MAGICKEY]){

						if(Game->LKeys[Game->GetCurLevel()] > 0){

							Game->LKeys[Game->GetCurLevel()] -= 1;

						}

						else{

							Game->DCounter[CR_KEYS] = -1;

						}

					}

					NoAction();

					//SuspendGhostZHScripts();

					Game->PlaySound(openSFX);

					GBChestReplaceCombosUnderFFC(this);

					holdType = Screen->ComboT[ComboAt(this->X, this->Y)];

					Screen->ComboT[ComboAt(this->X, this->Y)] = CT_SCREENFREEZE;

					Screen->D[SCREEN_D_GBCHEST_DATA] |= ConvertToBit(FFCNum(this));

					for(int i=0; i < GBCHEST_PRIZE_RENDER_TIMER; i++){

						if(itemDisplay > 0)	{

							Screen->FastTile(1, CenterX(this)-8, CenterY(this)-8+itemRaise, itemtile, itemcset, OP_OPAQUE);

							itemRaise-=GBCHEST_PRIZE_RENDER_SPEED;

						}

						NoAction();

						Waitframe();

					}

					Screen->ComboT[ComboAt(this->X, this->Y)] = holdType;

					NoAction();

					item Box = CreateItemAt(itemID, CenterX(this)-8, CenterY(this)-8+itemRaise);

					// if(itemDisplay > 0){

					// item Temp = CreateItemAt(itemID, 0, 0);

					// Screen->FastTile(1, this->X, this->Y-8+itemRaise, Temp->OriginalTile, Temp->CSet, OP_OPAQUE);

					// Remove(Temp);

					// }

					

					Game->PlaySound(receiveSFX);

					Screen->Message(receiveMessage);

					Waitframe();

					if(Screen->Flags[SF_ITEMS]&1)Box->Pickup|=IP_HOLDUP;

					Box->X = Link->X;

					Box->Y = Link->Y;

					//ResumeGhostZHScripts();

					Quit();

				}

			}

			Waitframe();

		}

	}

}





int ConvertToBit(int num){

	return 1 << (num-1);

}



//Change combos under FFC to next in list.

void GBChestReplaceCombosUnderFFC(ffc this){

	int x1 = this->X+1;

	int y1 = this->Y+1;

	int x2 = x1+(this->TileWidth*16)-2;

	int y2 = y1+(this->TileHeight*16)-2;

	for (int i=0;i<176;i++){

		int cx1 = ComboX(i);

		int cy1 = ComboY(i);

		int cx2 = cx1+15;

		int cy2 = cy1+15;

		if (!RectCollision(x1,y1,x2,y2,cx1,cy1,cx2,cy2))continue;

		Screen->ComboD[i]++;

	}

}