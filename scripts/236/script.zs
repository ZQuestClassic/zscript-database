import "std.zh"
import "ffcscript.zh"

//X--------------------X
//|  Bottle Constants  |
//X--------------------X

const int FFC_SFA = 31; //FFC used for screen freeze A
const int FFC_SFB = 32; //FFC used for screen freeze B
const int CMB_SFA = 2; //Combo used for screen freeze A
const int CMB_SFB = 3; //Combo used for screen freeze B

const int BOTTLE_SETTING_NO_WATER = 0; //Set to 1 if water shouldn't be bottleable

const int TIL_BOTTLE = 52020; //First of the tiles used for the bottle items. Should come in four identical rows.
                              //Tile order in each row should go as such:
							  //Empty, Empty, Red Potion, Green Potion, Blue Potion, Water, Fairy, Bee

const int REDPOTION_HEARTS = 8; //Hearts the red potion heals
const int GREENPOTION_MP = 256; //MP the green potion restores
const int BLUEPOTION_HEARTS = 16; //Hearts the blue potion heals
const int BLUEPOTION_MP = 256; //MP the blue potion restores

const int LW_WATER = 31; //LWeapon type used for bottled water. Script 1 by default
const int SPR_BOTTLEWATER = 88; //Sprite used for bottled water
const int SFX_BOTTLEWATER = 55; //Sound when water is dumped out

const int FAIRY_HEARTS = 3; //Hearts healed by a fairy
const int CMB_FAIRY = 904; //Fairy combo
const int CS_FAIRY = 8; //Fairy cset
const int SFX_FAIRY = 64; //Sound that plays when a fairy appears

const int IC_BOTTLE = 67; //Item class used for bottles. Custom 1 by default.

const int I_BOTTLE1 = 143; //Item ID for the first bottle (Level 1)
const int I_BOTTLE2 = 144; //Item ID for the second bottle (Level 2)
const int I_BOTTLE3 = 145; //Item ID for the second bottle (Level 3)
const int I_BOTTLE4 = 146; //Item ID for the second bottle (Level 4)

const int FREQ_HEARTREFILL = 8; //Frequency in frames at which potions/fairies restore hearts
const int SFX_HEARTREFILL = 22; //Sound when potion/fairy restores a heart
const int FREQ_MAGICSOUND = 8; //Frequency in frames where the magic refill sound plays
const int SFX_MAGICREFILL = 61; //Magic refill sound
const int SFX_ERROR = 62; //Error sound
						  
const int TIL_BOTTLESWING = 52006; //Tile of a right facing open bottle used when trying to catch something
const int CS_BOTTLESWING = 11; //CSet of the swinging bottle
const int SFX_BOTTLESWING = 63; //Sound used for the bottle being swung

const int I_WATERBOTTLE = 150; //Item for bottle water pickup
const int I_FAIRYBOTTLE = 151; //Item for bottle fairy pickup
const int I_BEEBOTTLE = 152; //Item for bottle bee pickup

const int CMB_BEE = 905; //Combo used for the bee
const int CS_BEE = 8; //CSet used for the bee
const int SFX_BEE = 65; //SFX used for the bee
const int LW_BEE = 32; //Lweapon used for the bee (Script 2 by default)
const int EW_BEE = 32; //Eweapon used for the bee (Script 2 by default)
const int DAMAGE_BEE = 4; //Damage the bee deals
const int FFCM_BEE_SELFDESTRUCT = 0; //FFC misc used to tell the bee to disappear

const int STR_CANTAFFORD = 2; //Message for when you can't afford an item
const int STR_NOBOTTLE = 3; //Message for when you don't have a bottle to store a potion in

const int C_WHITE = 0x01; //The color white
const int C_BLACK = 0x0F; //The color black


//X--------------------------X
//|  Screen Freeze Function  |
//X--------------------------X

void Screen_Freeze(){
	ffc f1 = Screen->LoadFFC(FFC_SFA);
	ffc f2 = Screen->LoadFFC(FFC_SFB);
	f1->Data = CMB_SFA;
	f2->Data = CMB_SFB;
}

void Screen_Unfreeze(){
	ffc f1 = Screen->LoadFFC(FFC_SFA);
	ffc f2 = Screen->LoadFFC(FFC_SFB);
	f1->Data = 0;
	f2->Data = 0;
}


//X--------------------------X
//|  Empty Bottle Functions  |
//X--------------------------X

//X--------------------------------------------------------X
//|  These constants don't need to be changed.             |
//|  They just define various states of the empty bottle.  |
//|  BS_ constants are also used for  the potion filling   |
//|  pickup item script. Look here to see what to set D2   |
//|  to for that.                                          |
//X--------------------------------------------------------X
//                                                         |
const int BS_EMPTY = 0; //                                 |
const int BS_POTIONRED = 1; //                             |
const int BS_POTIONGREEN = 2; //                           |
const int BS_POTIONBLUE = 3; //                            |
const int BS_WATER = 4; //                                 |
const int BS_FAIRY = 5; //                                 |
const int BS_BEE = 6; //                                   |
//                                                         |
const int BSI_BOTTLEUSED = 4; //                           |
const int BSI_BOTTLETIMER = 5; //                          |
const int BSI_OLDHP = 6; //                                |
const int BSI_OLDMP = 7; //                                |
const int BSI_FAIRYTIMER = 8; //                           |
const int BSI_FAIRYREVIVE = 9; //                          |
//                                                         |
//---------------------------------------------------------X


int BottleState[12]; //0-3: States of bottles, 4: Bottle used, 
                     //5: Potion timer, 6: OldHP, 7: OldMP

//This function should be called at the beginning of your global and 
//refreshes the graphics for the bottles.
void RefreshBottles(){
	for(int i=0; i<4; i++){
		CopyTile(TIL_BOTTLE+20*i+1+BottleState[i], TIL_BOTTLE+20*i);
	}
}

int UsingEmptyBottle(){
	if(Link->PressA){
		int id = GetEquipmentA();
		if(id>0){
			itemdata A = Game->LoadItemData(id);
			if(A->Family==IC_BOTTLE)
				return A->Level-1;
		}
	}
	else if(Link->PressB){
		int id = GetEquipmentB();
		if(id>0){
			itemdata B = Game->LoadItemData(id);
			if(B->Family==IC_BOTTLE)
				return B->Level-1;
		}
	}
	return -1;
}

bool CanFillBottle(){
	int bottles[4] = {I_BOTTLE1, I_BOTTLE2, I_BOTTLE3, I_BOTTLE4};
	for(int i=0; i<4; i++){
		if(Link->Item[bottles[i]]&&BottleState[i]==BS_EMPTY)
			return true;
	}
	return false;
}

int FillBottle(int state){
	int bottles[4] = {I_BOTTLE1, I_BOTTLE2, I_BOTTLE3, I_BOTTLE4};
	for(int i=0; i<4; i++){
		if(Link->Item[bottles[i]]&&BottleState[i]==BS_EMPTY){
			BottleState[i] = state;
			RefreshBottles();
			return i;
		}
	}
}

int HasFairy(){
	int bottles[4] = {I_BOTTLE1, I_BOTTLE2, I_BOTTLE3, I_BOTTLE4};
	for(int i=0; i<4; i++){
		if(Link->Item[bottles[i]]&&BottleState[i]==BS_FAIRY)
			return i;
	}
	return -1;
}

//This function goes in the while loop of your global script before waitdraw
void EmptyBottleGlobal(){
	int bottle = BottleState[BSI_BOTTLEUSED];
	if(BottleState[BSI_BOTTLETIMER]>0){
		if(BottleState[bottle]==BS_POTIONRED){
			if(BottleState[BSI_BOTTLETIMER]%FREQ_HEARTREFILL==0){
				Link->HP += 16;
				Game->PlaySound(SFX_HEARTREFILL);
				if(Link->HP>=Link->MaxHP){
					BottleState[BSI_BOTTLETIMER] = 0;
				}
			}
		}
		else if(BottleState[bottle]==BS_POTIONGREEN){
			Link->MP += 2;
			if(BottleState[BSI_BOTTLETIMER]%FREQ_MAGICSOUND==0)
				Game->PlaySound(SFX_MAGICREFILL);
			if(Link->MP>=Link->MaxMP){
				BottleState[BSI_BOTTLETIMER] = 0;
			}
		}
		else if(BottleState[bottle]==BS_POTIONBLUE){
			if(BottleState[BSI_BOTTLETIMER]%FREQ_HEARTREFILL==0&&Link->HP<BottleState[BSI_OLDHP]+BLUEPOTION_HEARTS*16&&Link->HP<Link->MaxHP){
				Link->HP += 16;
				Game->PlaySound(SFX_HEARTREFILL);
			}
			if(Link->MP<BottleState[BSI_OLDMP]+BLUEPOTION_MP&&Link->MP<Link->MaxMP){
				if(BottleState[BSI_BOTTLETIMER]%FREQ_MAGICSOUND==0)
					Game->PlaySound(SFX_MAGICREFILL);
				Link->MP += 2;
			}
			if(Link->HP>=Link->MaxHP&&Link->MP>=Link->MaxMP){
				BottleState[BSI_BOTTLETIMER] = 0;
			}
		}
		else if(BottleState[bottle]==BS_FAIRY){
			if(BottleState[BSI_BOTTLETIMER]<2&&BottleState[BSI_FAIRYTIMER]<120)
				BottleState[BSI_BOTTLETIMER] = 2;
			BottleState[BSI_FAIRYTIMER]++;
			int X = Link->X+VectorX(16*(BottleState[BSI_FAIRYTIMER]/120), BottleState[BSI_FAIRYTIMER]*8);
			int Y = Link->Y+VectorY(8*(BottleState[BSI_FAIRYTIMER]/120), BottleState[BSI_FAIRYTIMER]*8)-BottleState[BSI_FAIRYTIMER]/8;
			if(BottleState[BSI_FAIRYREVIVE]==1){
				if(BottleState[BSI_FAIRYTIMER]<10||BottleState[BSI_FAIRYTIMER]>110)
					Screen->Rectangle(6, 0, 0, 256, 176, C_BLACK, 1, 0, 0, 0, true, 64);
				else
					Screen->Rectangle(6, 0, 0, 256, 176, C_BLACK, 1, 0, 0, 0, true, 128);
				Screen->FastTile(6, Link->X+Link->DrawXOffset, Link->Y+Link->DrawYOffset, Link->Tile, 6, 128);
			}
			if(BottleState[BSI_FAIRYTIMER]<80||BottleState[BSI_FAIRYTIMER]%2==0)
				Screen->FastCombo(6, X, Y, CMB_FAIRY, CS_FAIRY, 128);
			if(BottleState[BSI_BOTTLETIMER]%FREQ_HEARTREFILL==0&&Link->HP<Link->MaxHP){
				Link->HP += 16;
				Game->PlaySound(SFX_HEARTREFILL);
			}
			if(Link->HP>=Link->MaxHP&&BottleState[BSI_FAIRYTIMER]>=120){
				BottleState[BSI_BOTTLETIMER] = 0;
			}
		}
		BottleState[BSI_BOTTLETIMER]--;
		NoAction();
		if(BottleState[BSI_BOTTLETIMER]<=0){
			BottleState[bottle] = BS_EMPTY;
			BottleState[BSI_BOTTLEUSED] = -1;
			RefreshBottles();
			Screen_Unfreeze();
		}
	}
	else{
		bottle = UsingEmptyBottle();
		if(bottle>-1){
			if(BottleState[bottle]==BS_EMPTY){
				int scriptname[] = "Bottle_Empty";
				int scriptid = Game->GetFFCScript(scriptname);
				int Args[8] = {bottle};
				RunFFCScript(scriptid, Args);
			}
			else if(BottleState[bottle]==BS_POTIONRED){
				if(Link->HP==Link->MaxHP){
					Game->PlaySound(SFX_ERROR);
				}
				else{
					BottleState[BSI_BOTTLEUSED] = bottle;
					BottleState[BSI_BOTTLETIMER] = FREQ_HEARTREFILL*REDPOTION_HEARTS;
					Screen_Freeze();
				}
			}
			else if(BottleState[bottle]==BS_POTIONGREEN){
				if(Link->MP==Link->MaxMP){
					Game->PlaySound(SFX_ERROR);
				}
				else{
					BottleState[BSI_BOTTLEUSED] = bottle;
					BottleState[BSI_BOTTLETIMER] = GREENPOTION_MP/2;
					Screen_Freeze();
				}
			}
			else if(BottleState[bottle]==BS_POTIONBLUE){
				if(Link->HP==Link->MaxHP&&Link->MP==Link->MaxMP){
					Game->PlaySound(SFX_ERROR);
				}
				else{
					BottleState[BSI_BOTTLEUSED] = bottle;
					BottleState[BSI_BOTTLETIMER] = Max(FREQ_HEARTREFILL*BLUEPOTION_HEARTS, BLUEPOTION_MP/2);
					BottleState[BSI_OLDHP] = Link->HP;
					BottleState[BSI_OLDMP] = Link->MP;
					Screen_Freeze();
				}
			}
			else if(BottleState[bottle]==BS_WATER){
				Link->Action = LA_ATTACKING;
				lweapon l = CreateLWeaponAt(LW_WATER, Link->X+InFrontX(Link->Dir, 0), Link->Y+InFrontY(Link->Dir, 0));
				l->UseSprite(SPR_BOTTLEWATER);
				l->DeadState = l->ASpeed*l->NumFrames;
				l->CollDetection = false;
				Game->PlaySound(SFX_BOTTLEWATER);
				BottleState[bottle] = BS_EMPTY;
				RefreshBottles();
			}
			else if(BottleState[bottle]==BS_FAIRY){
				if(Link->HP==Link->MaxHP){
					Game->PlaySound(SFX_ERROR);
				}
				else{
					BottleState[BSI_BOTTLEUSED] = bottle;
					BottleState[BSI_BOTTLETIMER] = FREQ_HEARTREFILL*FAIRY_HEARTS;
					BottleState[BSI_FAIRYTIMER] = 0;
					BottleState[BSI_FAIRYREVIVE] = 0;
					Game->PlaySound(SFX_FAIRY);
					Screen_Freeze();
				}
			}
			else if(BottleState[bottle]==BS_BEE){
				int scriptname[] = "Bottle_Bee";
				int scriptid = Game->GetFFCScript(scriptname);
				int vars[8] = {1};
				RunFFCScript(scriptid, vars);
				BottleState[bottle] = BS_EMPTY;
				RefreshBottles();
			}
		}
		int fairy = HasFairy();
		if(Link->HP<=0&&fairy>-1){
			Link->HP = 1;
			BottleState[BSI_BOTTLEUSED] = fairy;
			BottleState[BSI_BOTTLETIMER] = FREQ_HEARTREFILL*FAIRY_HEARTS;
			BottleState[BSI_FAIRYTIMER] = 0;
			BottleState[BSI_FAIRYREVIVE] = 1;
			Game->PlaySound(SFX_FAIRY);
			Screen_Freeze();
		}
	}
}


//X-------------------------------X
//|  Empty Bottle Action Scripts  |
//X-------------------------------X

ffc script Bottle_Empty{
	void run(int bottleid){
		int Angle = 0;
		if(Link->Dir==DIR_UP)
			Angle = -90;
		else if(Link->Dir==DIR_DOWN)
			Angle = 90;
		else if(Link->Dir==DIR_LEFT)
			Angle = 180;
		Game->PlaySound(SFX_BOTTLESWING);
		Link->Action = LA_ATTACKING;
		int Collected = 0;
		for(int i=-45; i<45; i+=10){
			int X = Link->X+VectorX(12, Angle+i);
			int Y = Link->Y+VectorY(12, Angle+i);
			Screen->DrawTile(2, X, Y, TIL_BOTTLESWING, 1, 1, CS_BOTTLESWING, -1, -1, X, Y, Angle+i+90, 0, true, 128);
			if(Collected==0||Collected==BS_WATER){
				if(OnWater(X+8, Y+8)&&Collected==0&&BOTTLE_SETTING_NO_WATER==0){
					Collected = BS_WATER;
				}
				for(int j=1; j<=Screen->NumItems(); j++){
					item itm = Screen->LoadItem(j);
					if(itm->ID==I_FAIRY||itm->ID==I_FAIRYSTILL){
						if(RectCollision(itm->X+itm->HitXOffset, itm->Y+itm->HitYOffset, itm->X+itm->HitXOffset+itm->HitWidth, itm->Y+itm->HitYOffset+itm->HitHeight, X+4, Y+4, X+11, Y+11)){
							Collected = BS_FAIRY;
							Remove(itm);
							break;
						}
					}
				}
				for(int j=1; j<=32; j++){
					ffc f = Screen->LoadFFC(j);
					int scriptname[] = "Bottle_Bee";
					int scriptid = Game->GetFFCScript(scriptname);
					if(f->Script==scriptid){
						if(RectCollision(X+4, Y+4, X+11, Y+11, f->X+4, f->Y+4, f->X+11, f->Y+11)){
							Collected = BS_BEE;
							f->Misc[FFCM_BEE_SELFDESTRUCT] = 1;
						}
					}
				}
			}
			WaitNoAction();
		}
		if(Collected==BS_WATER){
			BottleState[bottleid] = BS_WATER;
			RefreshBottles();
			item itm = CreateItemAt(I_WATERBOTTLE, Link->X, Link->Y);
			itm->Pickup = IP_HOLDUP;
		}
		else if(Collected==BS_FAIRY){
			BottleState[bottleid] = BS_FAIRY;
			RefreshBottles();
			item itm = CreateItemAt(I_FAIRYBOTTLE, Link->X, Link->Y);
			itm->Pickup = IP_HOLDUP;
		}
		else if(Collected==BS_BEE){
			BottleState[bottleid] = BS_BEE;
			RefreshBottles();
			item itm = CreateItemAt(I_BEEBOTTLE, Link->X, Link->Y);
			itm->Pickup = IP_HOLDUP;
		}
		WaitNoAction(10);
	}
	bool OnWater(int x, int y){
		int ct = Screen->ComboT[ComboAt(x, y)];
		if(ct==CT_WATER||ct==CT_SHALLOWWATER)
			return true;
		return false;
	}
}

ffc script Bottle_Bee{
	void run(int friendly){
		this->Data = CMB_BEE;
		this->CSet = CS_BEE;
		if(friendly==1){
			this->X = Link->X;
			this->Y = Link->Y;
		}
		int i; int j; int k;
		int X = this->X;
		int Y = this->Y;
		lweapon lh;
		eweapon eh;
		int Lifespan = Rand(900, 1200);
		for(i=0; i<40; i++){
			Y -= 0.5;
			this->X = X;
			this->Y = Y;
			Waitframe();
		}
		while(Lifespan>0){
			int Angle;
			if(friendly==1){
				int Tx = -1000;
				int Ty = -1000;
				int Dist = 1000;
				for(i=1; i<=Screen->NumNPCs(); i++){
					npc n = Screen->LoadNPC(i);
					if(Distance(X+8, Y+8, CenterX(n), CenterY(n))<Dist){
						Dist = Distance(X+8, Y+8, CenterX(n), CenterY(n));
						Tx = CenterX(n)-8;
						Ty = CenterY(n)-8;
					}
				}
				Angle = Angle(X, Y, Tx, Ty);
				if(Screen->NumNPCs()==0)
					Angle = Angle(X, Y, Link->X, Link->Y);
			}
			else{
				if(Distance(Link->X, Link->Y, X, Y)<80&&Rand(2)==0)
					Angle = Angle(X, Y, Link->X, Link->Y);
				else
					Angle = Rand(360);
			}
			k = Rand(32, 48);
			for(i=0; i<k; i++){
				Lifespan--;
				j = (j+1)%360;
				if(j%30==0)
					Game->PlaySound(SFX_BEE);
				X = Clamp(X+VectorX(2, Angle), -16, 256);
				Y = Clamp(Y+VectorY(2, Angle), -16, 176);
				this->X = X;
				this->Y = Y;
				if(friendly==1){
					if(lh->isValid()){
						lh->X = X;
						lh->Y = Y;
					}
					else{
						lh = CreateLWeaponAt(LW_BEE, X, Y);
						lh->HitXOffset = 4;
						lh->HitYOffset = 4;
						lh->HitWidth = 8;
						lh->HitHeight = 8;
						lh->DrawYOffset = -1000;
						lh->Dir = 8;
						lh->Damage = DAMAGE_BEE;
					}
				}
				else{
					if(eh->isValid()){
						eh->X = X;
						eh->Y = Y;
					}
					else{
						eh = CreateEWeaponAt(EW_BEE, X, Y);
						eh->HitXOffset = 4;
						eh->HitYOffset = 4;
						eh->HitWidth = 8;
						eh->HitHeight = 8;
						eh->DrawYOffset = -1000;
						eh->Dir = 8;
						eh->Damage = DAMAGE_BEE;
					}
				}
				if(this->Misc[FFCM_BEE_SELFDESTRUCT]==1){
					if(lh->isValid())
						lh->DeadState = 0;
					if(eh->isValid())
						eh->DeadState = 0;
					this->Data = 0;
					this->CSet = 0;
					Quit();
				}
				Waitframe();
			}
		}
		if(lh->isValid())
			lh->DeadState = 0;
		if(eh->isValid())
			eh->DeadState = 0;
		this->Data = 0;
		this->CSet = 0;
		for(i=0; i<40; i++){
			if(i%2==0)
				Screen->FastCombo(2, X, Y, CMB_BEE, CS_BEE, 128);
			Waitframe();
		}
	}
}


//X----------------------------X
//|  Other Associated Scripts  |
//X----------------------------X

item script PotionFill{
	void run(int str, int state){
		FillBottle(state);
		Screen->Message(str);
	}
}

ffc script ItemShop{
	void run(int id, int strdescription, int price, int potion){
		itemdata ic = Game->LoadItemData(id);
		while(true){
			if(Link->X>this->X-8&&Link->X<this->X+8&&Link->Y>this->Y&&Link->Y<this->Y+10&&Link->Dir==DIR_UP){
				if(Link->PressL){
					Screen->Message(strdescription);
					NoAction();
				}
				else if(Link->PressR){
					if(Game->Counter[CR_RUPEES]+Game->DCounter[CR_RUPEES]>=price){
						if(potion>0&&!CanFillBottle()){
							Screen->Message(STR_NOBOTTLE);
							NoAction();
						}
						else{
							item itm = CreateItemAt(id, Link->X, Link->Y);
							itm->Pickup = IP_HOLDUP;
							Game->DCounter[CR_RUPEES] -= price;
							for(int i=0; i<10; i++){
								WaitNoAction();
							}
						}
					}
					else{
						Screen->Message(STR_CANTAFFORD);
						NoAction();
					}
				}
			}
			DrawPrice(this, price);
			Waitframe();
		}
	}
	void DrawPrice(ffc this, int price){
		int xoff = -2;
		if(price>999)
			xoff = -8;
		else if(price>99)
			xoff = -6;
		else if(price>9)
			xoff = -4;
		Screen->DrawInteger(5, this->X+8+xoff+1, this->Y+18+1, FONT_Z3SMALL, C_BLACK, -1, -1, -1, price, 0, 128);
		Screen->DrawInteger(5, this->X+8+xoff, this->Y+18, FONT_Z3SMALL, C_WHITE, -1, -1, -1, price, 0, 128);
	}
}

ffc script BeeGrass{
	void run(int chances){
		int Combo = Screen->ComboD[ComboAt(this->X+8, this->Y+8)];
		while(Screen->ComboD[ComboAt(this->X+8, this->Y+8)]==Combo){
			Waitframe();
		}
		if(Rand(chances)==0){
			int scriptname[] = "Bottle_Bee";
			int scriptid = Game->GetFFCScript(scriptname);
			int i = RunFFCScript(scriptid, 0);
			ffc f = Screen->LoadFFC(i);
			f->X = this->X;
			f->Y = this->Y;
		}
	}
}

ffc script WaterTrigger{
	void run(){
		if(!Screen->State[ST_SECRET]){
			while(true){
				for(int i=1; i<=Screen->NumLWeapons(); i++){
					lweapon l = Screen->LoadLWeapon(i);
					if(l->ID==LW_WATER&&Collision(this, l)){
						Screen->TriggerSecrets();
						Game->PlaySound(SFX_SECRET);
						Screen->State[ST_SECRET] = true;
						Quit();
					}
				}
				Waitframe();
			}
		}
	}
}

//X-------------------------X
//|  Example Global Script  |
//X-------------------------X


global script Main2{
	void run(){
		RefreshBottles();
		while(true){
			EmptyBottleGlobal();
			Waitdraw();
			Waitframe();
		}
	}
}