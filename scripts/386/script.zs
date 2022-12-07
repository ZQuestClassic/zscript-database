//Simple Shop Script

//D0: ID of the item
//D1: Price of the item
//D2: Message that plays when the item is bought
//D3: Message that plays when you don't have enough currency/rupees
//D4: Input type 0=A 1=B 2=L 3=R
//D5: Font colour
//D6: Counter Reference to use (0 or negative values uses the default)

//A few constants to configure:
//offsets for where the item is shown and where the price is listed.
const int S_SHOP_DISPLAY_X = 0;
const int S_SHOP_DISPLAY_Y = -8;
const int S_SHOP_PRICE_X = 0;
const int S_SHOP_PRICE_Y = -16;
const int S_SHOP_TEXT_CSET = 0x0F;

//If you don't want the shop to display the item, set this to 0:
const int S_SHOP_DISPLAY_ITEM = 1;
//same for price
const int S_SHOP_DISPLAY_PRICE = 1;

//font choice, for the proper values see std_constants.zh or ask a scripter (I guess).
const int S_SHOP_FONT = 0;

//Default counter reference		(if you want shops to be able to cost life you NEED to set this to "0")
const int S_SHOP_CR = 1;		//CR_RUPEES

//Combo the FFC changes to when the script starts running, set to 0 to not use this feature
const int S_SHOP_REPLACECOMBO = 1;

//Wealth medals only apply if the price is in Rupees, set to 0 to turn off, 1 to on.
const int S_SHOP_WMEDAL_A = 1;

//wealth Medals
const int S_SHOP_WMEDAL1 = 109;
const float S_SHOP_WM1_MOD = 0.95;
const int S_SHOP_WMEDAL2 = 110;
const float S_SHOP_WM2_MOD = 0.90;
const int S_SHOP_WMEDAL3 = 111;
const float S_SHOP_WM3_MOD = 0.80;


ffc script SimpleShop{
    void run(int itemID, int input_price, int m, int n, int input, int TEXT_COLOUR, int CounterID){
		
		if(S_SHOP_REPLACECOMBO > 0) this->Data = S_SHOP_REPLACECOMBO;
		
		int price = input_price;
		
		if(CounterID <= 0) CounterID = S_SHOP_CR;
		
		if(S_SHOP_WMEDAL_A == 0 || CounterID == 1){
			if(Link->Item[S_SHOP_WMEDAL3]){
				price = Floor(input_price * S_SHOP_WM3_MOD);
			}
			else if(Link->Item[S_SHOP_WMEDAL2]){
				price = Floor(input_price * S_SHOP_WM2_MOD);
			}
			else if(Link->Item[S_SHOP_WMEDAL1]){
				price = Floor(input_price * S_SHOP_WM1_MOD);
			}
			
		}
		
        int loc = ComboAt(this->X + 8,this->Y + 8);
		if(TEXT_COLOUR <= 0) TEXT_COLOUR = S_SHOP_TEXT_CSET;
		
		//Drawing of shop item functionality.
		int PriceOffset = 0;
		if(price > 99) PriceOffset = PriceOffset -4;
		if(price > 999) PriceOffset = PriceOffset -4;
		if(price > 9999) PriceOffset = PriceOffset -4;
		if(price > 99999) PriceOffset = PriceOffset -4;
		
		if(S_SHOP_DISPLAY_ITEM > 0){
			item DisplayGoods = CreateItemAt(itemID, this->X + S_SHOP_DISPLAY_X, this->Y + S_SHOP_DISPLAY_Y);
			DisplayGoods->Pickup = IP_DUMMY;
		}
		
        while(true){
			
			if(S_SHOP_DISPLAY_PRICE > 0) Screen->DrawInteger(4, this->X + S_SHOP_PRICE_X + PriceOffset, this->Y + S_SHOP_PRICE_Y, S_SHOP_FONT, TEXT_COLOUR, -1, 0, 0, price, 0, OP_OPAQUE);
			

			
            if(Link->Z == 0 && Link->Dir == DIR_UP && Link->Y > this->Y && Link->Y < this->Y + 14  && Link->X > this->X - 4 && Link->X < this->X + 4 && Shop_SelectPressInput(input)){
				
				Shop_SetInput(input,false);
				if(Game->Counter[CounterID] >= price){
					Game->DCounter[CounterID] -= price;
					item shpitm = CreateItemAt(itemID, Link->X, Link->Y);
					shpitm->Pickup = IP_HOLDUP;
					Screen->Message(m);
				}
				else{
					Screen->Message(n);
				}
			}

            
			
            Waitframe();
        }
    }
	bool AgainstFFCBase(int FFCX, int FFCY){
	return Link->Z == 0 && Link->Dir == DIR_UP && Link->Y > FFCY && Link->Y < FFCY + 16  && Link->X > FFCY - 2 && Link->X < FFCY + 2;
	}
	
	//What's the point of this? the script should never exit from while(true)...?
    bool AgainstComboBase(int loc){
        return Link->Z == 0 && (Link->Dir == DIR_UP && Link->Y == ComboY(loc)+8 && Abs(Link->X-ComboX(loc)) < 8);
    }
}


//	This was made to use it's own unique functions instead, mostly since the functio names were too generic.
bool Shop_SelectPressInput(int input){
    if(input == 0) return Link->PressA;
    else if(input == 1) return Link->PressB;
    else if(input == 2) return Link->PressL;
    else if(input == 3) return Link->PressR;
}
void Shop_SetInput(int input, bool state){
    if(input == 0) Link->InputA = state;
    else if(input == 1) Link->InputB = state;
    else if(input == 2) Link->InputL = state;
    else if(input == 3) Link->InputR = state;
}