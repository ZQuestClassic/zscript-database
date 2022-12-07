//D0: ID of the item
//D1: Price of the item
//D2: Message that plays when the item is bought
//D3: Message that plays when you don't have enough rupees
//D4: Input type 0=A 1=B 2=L 3=R
ffc script SimpleShop{
    void run(int itemID, int price, int m, int n, int input){
        int loc = ComboAt(this->X,this->Y);
        while(true){
            while(!AgainstComboBase(loc) || !SelectPressInput(input)) Waitframe();
            SetInput(input,false);
            	if(Game->Counter[CR_RUPEES] >= price){
	    	Game->DCounter[CR_RUPEES] -= price;
	    	item shpitm = CreateItemAt(itemID, Link->X, Link->Y);
	        shpitm->Pickup = IP_HOLDUP;
            	Screen->Message(m);
		}
		else{
		Screen->Message(n);
		}		
            Waitframe();
        }
    }
    bool AgainstComboBase(int loc){
        return Link->Z == 0 && (Link->Dir == DIR_UP && Link->Y == ComboY(loc)+8 && Abs(Link->X-ComboX(loc)) < 8);
    }
}

//If you are already using the signpost script remove the code below
bool SelectPressInput(int input){
    if(input == 0) return Link->PressA;
    else if(input == 1) return Link->PressB;
    else if(input == 2) return Link->PressL;
    else if(input == 3) return Link->PressR;
}
void SetInput(int input, bool state){
    if(input == 0) Link->InputA = state;
    else if(input == 1) Link->InputB = state;
    else if(input == 2) Link->InputL = state;
    else if(input == 3) Link->InputR = state;
}