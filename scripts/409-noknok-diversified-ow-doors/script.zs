const int KNOCK = 66;//Knock SFX
const int OPENING_SFX = 63;//Door Opening SFX

ffc script NokNok
{
	void run(int open_a, int open_b, int open_c, int open_d, int type, int check, int counter, int msg)
	{
		while(true){
			if((DistX(this, 17)) && (DistY(this, 17))){
				Link->SwordJinx = 6;
				if((Link->PressA) && (type == 0)){
					Link->SwordJinx;
					Link->InputA = false;
					Link->PressA = false;
					Game->PlaySound(OPENING_SFX);
					WaitNoAction(24);
					if(open_a > 0){
						Screen->ComboD[ComboAt(this->X, this->Y)] = open_a;
					}
					if(open_b > 0){
						Screen->ComboD[ComboAt(this->X, this->Y-16)] = open_b;
					}
					if(open_c > 0){
						Screen->ComboD[ComboAt(this->X+16, this->Y-16)] = open_c;
					}
					if(open_d > 0){
						Screen->ComboD[ComboAt(this->X+16, this->Y)] = open_d;
					}
					Quit();
				}
				else if((Link->PressA) && (type == 1)){
					Link->SwordJinx;
					Link->InputA = false;
					Link->PressA = false;
					Game->PlaySound(KNOCK);
					WaitNoAction(66);
					Game->PlaySound(OPENING_SFX);
					WaitNoAction(24);
					if(open_a > 0){
						Screen->ComboD[ComboAt(this->X, this->Y)] = open_a;
					}
					if(open_b > 0){
						Screen->ComboD[ComboAt(this->X, this->Y-16)] = open_b;
					}
					if(open_c > 0){
						Screen->ComboD[ComboAt(this->X+16, this->Y-16)] = open_c;
					}
					if(open_d > 0){
						Screen->ComboD[ComboAt(this->X+16, this->Y)] = open_d;
					}
					Quit();
				}
				else if((Link->PressA) && (type == 2)){
					Link->SwordJinx;
					Link->InputA = false;
					Link->PressA = false;
					Game->PlaySound(KNOCK);
					WaitNoAction(66);
					if(Link->Item[check]){
						Game->PlaySound(OPENING_SFX);
						WaitNoAction(24);
						if(open_a > 0){
							Screen->ComboD[ComboAt(this->X, this->Y)] = open_a;
						}
						if(open_b > 0){
							Screen->ComboD[ComboAt(this->X, this->Y-16)] = open_b;
						}
						if(open_c > 0){
							Screen->ComboD[ComboAt(this->X+16, this->Y-16)] = open_c;
						}
						if(open_d > 0){
							Screen->ComboD[ComboAt(this->X+16, this->Y)] = open_d;
						}
						Quit();
					}
					else{
						Screen->Message(msg);
					}
				}
				else if((Link->PressA) && (type == 3)){
					Link->SwordJinx;
					Link->InputA = false;
					Link->PressA = false;
					Game->PlaySound(KNOCK);
					WaitNoAction(66);
					if(ComboFI(Link->X+8, Link->Y+12, check)){
						Game->PlaySound(OPENING_SFX);
						WaitNoAction(24);
						if(open_a > 0){
							Screen->ComboD[ComboAt(this->X, this->Y)] = open_a;
						}
						if(open_b > 0){
							Screen->ComboD[ComboAt(this->X, this->Y-16)] = open_b;
						}
						if(open_c > 0){
							Screen->ComboD[ComboAt(this->X+16, this->Y-16)] = open_c;
						}
						if(open_d > 0){
							Screen->ComboD[ComboAt(this->X+16, this->Y)] = open_d;
						}
						Quit();
					}
					else{
						Screen->Message(msg);
					}
				}
				else if((Link->PressA) && (type == 4)){
					Link->SwordJinx;
					Link->InputA = false;
					Link->PressA = false;
					Game->PlaySound(KNOCK);
					WaitNoAction(66);
					if(Game->Counter[counter] > check){
						Game->PlaySound(OPENING_SFX);
						WaitNoAction(24);
						if(open_a > 0){
							Screen->ComboD[ComboAt(this->X, this->Y)] = open_a;
						}
						if(open_b > 0){
							Screen->ComboD[ComboAt(this->X, this->Y-16)] = open_b;
						}
						if(open_c > 0){
							Screen->ComboD[ComboAt(this->X+16, this->Y-16)] = open_c;
						}
						if(open_d > 0){
							Screen->ComboD[ComboAt(this->X+16, this->Y)] = open_d;
						}
						Quit();
					}
					else{
						Screen->Message(msg);
					}
				}
			}
			Waitframe();
		}
	}
}