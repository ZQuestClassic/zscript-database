const int MogShop_DefaultFailMessage = 1; // Default message to play when Link can't afford the item

const int MogShop_PriceTag = 1; // use 0 if you don't want to display price tags, otherwise use 1
const int MogShop_FontColour = 0x01; // colour of the price tag font (the 2 digits after "0x" is the code for your colour)
const int MogShop_FontOutline = 0x0F; // colour of the price tag font's outline
const int MogShop_FontType = 16; // which font to use (0 is the Z1 font, 16 is the LA font. you might have to look up std_constants.zh or just experiment)
const int MogShop_FontYOffset = -8; // positional offset of the price tag on the Y axis relative to the FFC

const int MogShop_SoldOutComboID = 1; // ID of the combo for the FFC to be when the item is sold out (can't use 0)
const int MogShop_SoldOutComboCSet = 8; // CSet of the combo

const int MogShop_InteractComboID = 0; // ID of the combo to show above Link's head when he's standing in front of the item. Use 0 if you don't want any.
const int MogShop_InteractComboCSet = 8; // CSet of the combo

ffc script MogShop{
	void run(int ShopItem, int InfoMessage, int Price, int Currency, int OnlyOnceID, int FailMessage, int CollisionStyle){
		// Saves the width and height of the FFC for collision checks
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
		// Determine collision check position
		int HitX = this->X;
		int HitY = this->Y;
		if ( CollisionStyle != 0 )
			HitY = this->Y + 8;
		
		// Disable the shop if the item is sold out
		int SoldOutComboID = MogShop_SoldOutComboID;
		if ( SoldOutComboID < 0 )
			SoldOutComboID = 1;
		if ( OnlyOnceID >= 0 ) {
			if ( Screen->D[OnlyOnceID] == 1 ) {
				this->Data = SoldOutComboID;
				this->CSet = MogShop_SoldOutComboCSet;
				while(true){
					DrawOverUpdate(this, HitX, HitY, CollisionStyle);
					Waitframe();
				}
			}
		}
		
		// Determine currency
		int CounterToUse = Currency;
		if ( Currency <= 0 )
			CounterToUse = 1;
		
		// Create price tag string
		int PriceTag[100];
		itoa(PriceTag, Price);
		
		// Determine price tag layer
		int PriceTagLayer;
		if ( CollisionStyle != 0 )
			PriceTagLayer = 6;
		
		while(true){
			// Check collision with the item
			bool CanInteract;
			if ( LinkCanInteract() ) {
				// Facing Up
				if(Link->Dir==DIR_UP&&Link->Y>=HitY&&Link->Y<=HitY+Height-8&&Link->X>=HitX-8&&Link->X<=HitX+Width-8)
					CanInteract = true;
				else if ( CollisionStyle == 0 ) { // Only allow other directions when CollisionStyle is 0
					// Facing Down
					if(Link->Dir==DIR_DOWN&&Link->Y>=HitY-16&&Link->Y<=HitY+Height-16&&Link->X>=HitX-8&&Link->X<=HitX+Width-8)
						CanInteract = true;
					// Facing Left
					else if(Link->Dir==DIR_LEFT&&Link->Y>=HitY-8&&Link->Y<=HitY+Height-9&&Link->X>=HitX&&Link->X<=HitX+Width)
						CanInteract = true;
					// Facing Right
					else if(Link->Dir==DIR_RIGHT&&Link->Y>=HitY-8&&Link->Y<=HitY+Height-9&&Link->X>=HitX-16&&Link->X<=HitX+Width-16)
						CanInteract = true;
				}
			}
			
			DrawOverUpdate(this, HitX, HitY, CollisionStyle);
			
			// Draw price tag
			if ( MogShop_PriceTag == 1 ) {
				Screen->DrawString(PriceTagLayer, this->X+8 +1, this->Y+MogShop_FontYOffset, MogShop_FontType, MogShop_FontOutline, -1, TF_CENTERED, PriceTag, OP_OPAQUE);
				Screen->DrawString(PriceTagLayer, this->X+8 -1, this->Y+MogShop_FontYOffset, MogShop_FontType, MogShop_FontOutline, -1, TF_CENTERED, PriceTag, OP_OPAQUE);
				Screen->DrawString(PriceTagLayer, this->X+8, this->Y+MogShop_FontYOffset +1, MogShop_FontType, MogShop_FontOutline, -1, TF_CENTERED, PriceTag, OP_OPAQUE);
				Screen->DrawString(PriceTagLayer, this->X+8, this->Y+MogShop_FontYOffset -1, MogShop_FontType, MogShop_FontOutline, -1, TF_CENTERED, PriceTag, OP_OPAQUE);
				Screen->DrawString(PriceTagLayer, this->X+8, this->Y+MogShop_FontYOffset, MogShop_FontType, MogShop_FontColour, -1, TF_CENTERED, PriceTag, OP_OPAQUE);
			}
			
			// Handle interaction
			if ( CanInteract ) {
				if ( Link->PressA ) {
					Link->InputA = false;
					Link->PressA = false;
					Screen->Message(InfoMessage);
				}
				else if ( Link->PressR ) {
					Link->InputR = false;
					Link->PressR = false;
					
					// Check if affordable
					if ( Game->Counter[CounterToUse] >= Price && (CounterToUse != CR_LIFE || Game->Counter[CR_LIFE] - Price > 0) ) {
						Game->DCounter[CounterToUse] -= Price;
						item drop = CreateItemAt(ShopItem, Link->X, Link->Y);
						SetItemPickup(drop, IP_HOLDUP, true);
						
						if ( OnlyOnceID >= 0 ) { // Check if it can only be bought once
							Screen->D[OnlyOnceID] = 1;
							this->Data = SoldOutComboID;
							this->CSet = MogShop_SoldOutComboCSet;
							while(true){
								DrawOverUpdate(this, HitX, HitY, CollisionStyle);
								Waitframe();
							}
						}
					}
					else { // Can't afford
						if ( FailMessage > 0 )
							Screen->Message(FailMessage);
						else
							Screen->Message(MogShop_DefaultFailMessage);
					}
				}
				else if ( MogShop_InteractComboID > 0 )
					Screen->FastCombo(6, Link->X, Link->Y-16, MogShop_InteractComboID, MogShop_InteractComboCSet, OP_OPAQUE);
			}
			Waitframe();
		}
	}
	bool LinkCanInteract(){
		if ( Link->Action != LA_NONE && Link->Action != LA_WALKING )
			return false;
		if ( Link->Z > 0 )
			return false;
		return true;
	}
	void DrawOverUpdate(ffc this, int HitX, int HitY, int CollisionStyle){
		// Toggle draw-over if CollisionStyle is not 0
		if ( CollisionStyle != 0 ) {
			if ( Link->Y < HitY )
				this->Flags[FFCF_OVERLAY] = true;
			else
				this->Flags[FFCF_OVERLAY] = false;
		}
	}
}