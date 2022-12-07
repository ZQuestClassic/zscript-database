const int MONTY_HALL_DEFAULT_COST = 10;
const int MONTY_HALL_DEFAULT_CONSOLATION = 0;
const int MONTY_HALL_DEFAULT_MAIN_PRIZE = 38;

const int DEFAULT_RUPEE_ICON_TILE = 21532;
const int DEFAULT_RUPEE_ICON_CSET = 5;

ffc script MontyHallMinigame{
	void run (int prize, int consol, int cost, int stringintro, int stringstart, int stringlose, int stringwin){
		if (prize==0) prize = MONTY_HALL_DEFAULT_MAIN_PRIZE;
		if (cost==0) cost = MONTY_HALL_DEFAULT_COST;
		int phase = 0;
		int cmb_start = ComboAt(CenterX(this), CenterY(this));
		int cmb_step[3];
		int cmb_chest[3];
		for (int i=0;i<=2; i++){
			cmb_step[i] = cmb_start - (34-2*i);
			cmb_chest[i] = cmb_step[i] - 32;			
		} 
		int Rnd = -1;
		int step = -1;
		Screen->Message(stringintro);
		for (int i=0; i<=2;i++) Screen->ComboD[cmb_chest[i]]++;
		while (true){
			if (phase ==0){//Monty is waiting for entry fee.
				Screen->FastTile(0, this->X, this->Y, DEFAULT_RUPEE_ICON_TILE, DEFAULT_RUPEE_ICON_CSET, OP_OPAQUE);
				Screen->DrawInteger(0, this->X, this->Y+16,0, 1,-1, 0,0, -cost, 0, OP_OPAQUE);
				if ((Game->Counter[CR_RUPEES]>=cost)&&(LinkCollision(this))){
					Game->Counter[CR_RUPEES]-=cost;
					Rnd=Rand(3);
					Screen->Message(stringstart);
					for (int i=0; i<=2;i++) Screen->ComboD[cmb_chest[i]]--;
					phase = 1;
				}
			}
			else if (phase == 1){//Game started, all 3 chests are closed.			
				for (int i=0; i<=2; i++){
					if (LinkComboStepped(cmb_step[i], 1, false, -1)) step=i;
				}
				if (step>=0){
					int open = step;
					while ((open==Rnd)||(open==step)) open = Rand(3);
					Screen->ComboD[cmb_chest[open]]++;
					item reveal = Screen->CreateItem(consol);
					reveal->X = ComboX(cmb_chest[open]);
					reveal->Y = ComboY(cmb_chest[open]);
					WaitNoAction(60);
					Screen->ComboD[cmb_chest[open]]--;
					Remove(reveal);
					step=-1;
					phase=2;
				}
			}
			else if (phase == 2){//As Link approaches one of the chests, one chest opens itself to reveal it`s emptiness.
				for (int i=0; i<=2; i++){
					if (LinkComboCollision(cmb_chest[i], 8, true, -1)) step=i;
				}
				if ((step>=0)&&(Link->InputUp)){
					item win= Screen->CreateItem(prize);
					int prizetile = win->Tile;
					int prizecset = win->CSet;
					Remove(win);
					item loss= Screen->CreateItem(consol);
					int losstile = loss->Tile;
					int losscset = loss->CSet;
					Remove(loss);
					for (int i=0; i<=2;i++) Screen->ComboD[cmb_chest[i]]++;
					for (int s=0; s<45; s++){
						for (int i=0; i<=2; i++){
							if (i==Rnd)Screen->FastTile(0, ComboX(cmb_chest[i]), ComboY(cmb_chest[i]), prizetile, prizecset, OP_OPAQUE);
							else Screen->FastTile(0, ComboX(cmb_chest[i]), ComboY(cmb_chest[i]), losstile, losscset, OP_OPAQUE);
						}
						WaitNoAction();
					}
					if (step==Rnd){
						Screen->Message(stringwin);
						item itm = Screen->CreateItem(prize);
						itm->Pickup=2;
						itm->X=Link->X;
						itm->Y=Link->Y;
					}
					else{
						Screen->Message(stringlose);
						item itm = Screen->CreateItem(consol);
						itm->Pickup=2;
						itm->X=Link->X;
						itm->Y=Link->Y;
					}
					Quit();
				}
			}
			Waitframe();
		}
	}
}