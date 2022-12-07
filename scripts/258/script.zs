//import "std.zh"
//import "string.zh"
//import "ffcscript.zh"

//Only include if not using ghost.zh
const int GH_INVISIBLE_COMBO = 1;//Can be any invisible combo.

//Test if one location is between two others.
//D0- Location to test
//D1- Lower bound
//D2- Higher bound

bool Between(int loc,int greaterthan, int lessthan){
	if(loc>=greaterthan && loc<=lessthan)return true;
	return false;
}

//Gale Fruit

const int GALE_FRUIT_SCRIPT = 4;//Script run by gale fruit.
const int GALE_COMBO = 83;//Combo of moving gale.
const int GALE_WARP_COMBO = 696;//Combo of opened portal.
const int GALE_SFX = 59;//Sound to make when using item.
const int GALE_WARP_SFX = 83;//Sound to make when warping.
const int GALE_WARP_MISC_INDEX = 0;//Misc ffc index to store X coords in.

item script Gale_Fruit{
	void run(){
		Game->PlaySound(GALE_SFX);//Play a sound.
		//Launch ffc script.
		int args[8];
		ffc launch = RunFFCScriptOrQuit(GALE_FRUIT_SCRIPT, args);
	}
}

ffc script GaleFruit{
	void run(){
		int i;//Iterative variable.
                //Set up ffc.
		this->Data = GALE_COMBO;
		this->Misc[GALE_WARP_MISC_INDEX]= -1;
		//Put in front of Link.
		this->X = Link->X+ InFrontX(Link->Dir,2);
		this->Y = Link->Y+ InFrontY(Link->Dir,2);
		//Arrays to Save coords for entry and exit.
		int EntryX[8];
		int EntryY[8];
		int ExitX[8];
		int ExitY[8];
		//Determine value of coords.
		for ( i = 0; i < 175; i++ ){
			if(ComboFI(i,CF_SCRIPT1)){
				if(Screen->ComboT[i]==CT_SCRIPT1){
					EntryX[0] = ComboX(i);
					EntryY[0] = ComboY(i);
				}
				else if(Screen->ComboT[i]==CT_SCRIPT2){
					EntryX[1] = ComboX(i);
					EntryY[1] = ComboY(i);
				}
				else if(Screen->ComboT[i]==CT_SCRIPT3){
					EntryX[2] = ComboX(i);
					EntryY[2] = ComboY(i);
				}
				else if(Screen->ComboT[i]==CT_SCRIPT4){
					EntryX[3] = ComboX(i);
					EntryY[3] = ComboY(i);
				}
				else if(Screen->ComboT[i]==CT_SCRIPT5){
					EntryX[4] = ComboX(i);
					EntryY[4] = ComboY(i);
				}
				else if(Screen->ComboT[i]==CT_LEFTSTATUE){
					EntryX[5] = ComboX(i);
					EntryY[5] = ComboY(i);
				}
				else if(Screen->ComboT[i]==CT_RIGHTSTATUE){
					EntryX[6] = ComboX(i);
					EntryY[6] = ComboY(i);
				}
			}
			else if(ComboFI(i,CF_SCRIPT2)){
				if(Screen->ComboT[i]==CT_SCRIPT1){
					ExitX[0] = ComboX(i);
					ExitY[0] = ComboY(i);
				}
				else if(Screen->ComboT[i]==CT_SCRIPT2){
					ExitX[1] = ComboX(i);
					ExitY[1] = ComboY(i);
				}
				else if(Screen->ComboT[i]==CT_SCRIPT3){
					ExitX[2] = ComboX(i);
					ExitY[2] = ComboY(i);
				}
				else if(Screen->ComboT[i]==CT_SCRIPT4){
					ExitX[3] = ComboX(i);
					ExitY[3] = ComboY(i);
				}
				else if(Screen->ComboT[i]==CT_SCRIPT5){
					ExitX[4] = ComboX(i);
					ExitY[4] = ComboY(i);
				}
				else if(Screen->ComboT[i]==CT_LEFTSTATUE){
					ExitX[5] = ComboX(i);
					ExitY[5] = ComboY(i);
				}
				else if(Screen->ComboT[i]==CT_RIGHTSTATUE){
					ExitX[6] = ComboX(i);
					ExitY[6] = ComboY(i);
				}
			}
		}
		int SavedDir = Link->Dir;//Remember what direction Link was facing.
		bool Moving = true;//The gale is moving.
		bool Warping = false;//You're not warping yet.
		int StoredCombo[8];//Array to store original appearance of combos in.
		//Set speed of movement.
		if(SavedDir==DIR_UP){
			this->Vy = -1;
			this->Vx = 0;
		}
		else if(SavedDir == DIR_DOWN){
			this->Vy = 1;
			this->Vx = 0;
		}
		else if(SavedDir == DIR_LEFT){
			this->Vx = -1;
			this->Vy = 0;
		}
		else{
			this->Vx= 1;
			this->Vy = 0;
		}
		//Moving now.
		while(Moving){
			for(i=0;i<7;i++){
				//The ffc has met a portal entry.
				//Change to a warp.
				if(Between(this->X+8,EntryX[i],EntryX[i]+16) && Between(this->Y+8,EntryY[i],EntryY[i]+16)&& EntryY[i] !=0){
					StoredCombo[i]= Screen->ComboD[ComboAt(EntryX[i],EntryY[i])];
					Screen->ComboD[ComboAt(EntryX[i],EntryY[i])]= GALE_WARP_COMBO;
					Screen->ComboD[ComboAt(ExitX[i],ExitY[i])]= GALE_WARP_COMBO;
					this->Misc[GALE_WARP_MISC_INDEX]= i;
				}
				else if(Between(this->X+8,ExitX[i],ExitX[i]+16) && Between(this->Y+8,ExitY[i],ExitY[i]+16)&& ExitX[i]!=0){
					StoredCombo[i]= Screen->ComboD[ComboAt(EntryX[i],EntryY[i])];
					Screen->ComboD[ComboAt(EntryX[i],EntryY[i])]= GALE_WARP_COMBO;
					Screen->ComboD[ComboAt(ExitX[i],ExitY[i])]= GALE_WARP_COMBO;
					this->Misc[GALE_WARP_MISC_INDEX]= i;
				}
			}
			//The ffc has gone off the screen. Kill it.
			if(this->X<0||this->Y<0||this->X>256||this->Y>176)Quit();
			//A warp portal exists.
			if(this->Misc[GALE_WARP_MISC_INDEX]!=-1){
				Moving = false;//Stop moving.
				Warping = true;//Start warping.
				//Kill momentum.
				this->Vx = 0;
				this->Vy = 0;
                                //Make ffc invisible.
				this->Data = GH_INVISIBLE_COMBO;
			}
			Waitframe();
		}
		//Time to warp.
		while(Warping){
                        //Draw warp whirlwind at entrance and exit of warp.
			Screen->DrawCombo(1, ExitX[this->Misc[GALE_WARP_MISC_INDEX]], ExitY[this->Misc[GALE_WARP_MISC_INDEX]], GALE_COMBO, 1, 1, -1, -1, -1, 0, 0, 0, -1, 0, true, 128);
			Screen->DrawCombo(1, EntryX[this->Misc[GALE_WARP_MISC_INDEX]], EntryY[this->Misc[GALE_WARP_MISC_INDEX]], GALE_COMBO, 1, 1, -1, -1, -1, 0, 0, 0, -1, 0, true, 128);
			//Link has stepped on a warp tile.
			if(Between(Link->X+8,EntryX[this->Misc[GALE_WARP_MISC_INDEX]],EntryX[this->Misc[GALE_WARP_MISC_INDEX]]+16) 
			   && Between(Link->Y+8,EntryY[this->Misc[GALE_WARP_MISC_INDEX]],EntryY[this->Misc[GALE_WARP_MISC_INDEX]]+16)
			   && Screen->ComboD[ComboAt(EntryX[this->Misc[GALE_WARP_MISC_INDEX]],EntryY[this->Misc[GALE_WARP_MISC_INDEX]])]==GALE_WARP_COMBO){
				 //Change combo appearance.
				Screen->ComboD[ComboAt(EntryX[this->Misc[GALE_WARP_MISC_INDEX]],EntryY[this->Misc[GALE_WARP_MISC_INDEX]])]= StoredCombo[this->Misc[GALE_WARP_MISC_INDEX]];
				Screen->ComboD[ComboAt(ExitX[this->Misc[GALE_WARP_MISC_INDEX]],ExitY[this->Misc[GALE_WARP_MISC_INDEX]])]= StoredCombo[this->Misc[GALE_WARP_MISC_INDEX]];
				//Move Link to exit warp.
				Link->X = ExitX[this->Misc[GALE_WARP_MISC_INDEX]];
				Link->Y = ExitY[this->Misc[GALE_WARP_MISC_INDEX]];
				Game->PlaySound(GALE_WARP_SFX);//Play a sound.
				Warping = false;//Not warping.
			}
			else if(Between(Link->X+8,ExitX[this->Misc[GALE_WARP_MISC_INDEX]],ExitX[this->Misc[GALE_WARP_MISC_INDEX]]+16) 
					&& Between(Link->Y+8,ExitY[this->Misc[GALE_WARP_MISC_INDEX]],ExitY[this->Misc[GALE_WARP_MISC_INDEX]]+16)
					&& Screen->ComboD[ComboAt(ExitX[this->Misc[GALE_WARP_MISC_INDEX]],ExitY[this->Misc[GALE_WARP_MISC_INDEX]])]==GALE_WARP_COMBO){
				 //Change combo appearance.
				Screen->ComboD[ComboAt(EntryX[this->Misc[GALE_WARP_MISC_INDEX]],EntryY[this->Misc[GALE_WARP_MISC_INDEX]])]= StoredCombo[this->Misc[GALE_WARP_MISC_INDEX]];
				Screen->ComboD[ComboAt(ExitX[this->Misc[GALE_WARP_MISC_INDEX]],ExitY[this->Misc[GALE_WARP_MISC_INDEX]])]= StoredCombo[this->Misc[GALE_WARP_MISC_INDEX]];
				//Move Link to exit warp.
				Link->X = EntryX[this->Misc[GALE_WARP_MISC_INDEX]];
				Link->Y = EntryY[this->Misc[GALE_WARP_MISC_INDEX]];
				Game->PlaySound(GALE_WARP_SFX);//Play a sound.
				Warping = false;//Not warping.
			}
                        //An enemy has stepped on a warp tile.
			for(int j = Screen->NumNPCs();j>0;j--){
				npc nme = Screen->LoadNPC(j);
				if(Between(CenterX(nme),ExitX[this->Misc[GALE_WARP_MISC_INDEX]],ExitX[this->Misc[GALE_WARP_MISC_INDEX]]+16)
					&& Between(CenterY(nme),ExitY[this->Misc[GALE_WARP_MISC_INDEX]],ExitY[this->Misc[GALE_WARP_MISC_INDEX]]+16)){
					 //Change combo appearance.
					Screen->ComboD[ComboAt(EntryX[this->Misc[GALE_WARP_MISC_INDEX]],EntryY[this->Misc[GALE_WARP_MISC_INDEX]])]= StoredCombo[this->Misc[GALE_WARP_MISC_INDEX]];
					Screen->ComboD[ComboAt(ExitX[this->Misc[GALE_WARP_MISC_INDEX]],ExitY[this->Misc[GALE_WARP_MISC_INDEX]])]= StoredCombo[this->Misc[GALE_WARP_MISC_INDEX]];
					//Move Link to exit warp.
					nme->X = EntryX[this->Misc[GALE_WARP_MISC_INDEX]];
					nme->Y = EntryY[this->Misc[GALE_WARP_MISC_INDEX]];
					Game->PlaySound(GALE_WARP_SFX);//Play a sound.
					Warping = false;//Not warping.
				}
				else if(Between(CenterX(nme),EntryX[this->Misc[GALE_WARP_MISC_INDEX]],EntryX[this->Misc[GALE_WARP_MISC_INDEX]]+16)
					&& Between(CenterY(nme),EntryY[this->Misc[GALE_WARP_MISC_INDEX]],EntryY[this->Misc[GALE_WARP_MISC_INDEX]]+16)){
					 //Change combo appearance.
					Screen->ComboD[ComboAt(EntryX[this->Misc[GALE_WARP_MISC_INDEX]],EntryY[this->Misc[GALE_WARP_MISC_INDEX]])]= StoredCombo[this->Misc[GALE_WARP_MISC_INDEX]];
					Screen->ComboD[ComboAt(ExitX[this->Misc[GALE_WARP_MISC_INDEX]],ExitY[this->Misc[GALE_WARP_MISC_INDEX]])]= StoredCombo[this->Misc[GALE_WARP_MISC_INDEX]];
					//Move Link to exit warp.
					nme->X = ExitX[this->Misc[GALE_WARP_MISC_INDEX]];
					nme->Y = ExitY[this->Misc[GALE_WARP_MISC_INDEX]];
					Game->PlaySound(GALE_WARP_SFX);//Play a sound.
					Warping = false;//Not warping.
				}
			}
                         //An lweapon has encountered a warp tile.
			for(int j = Screen->NumLWeapons();j>0;j--){
				lweapon lw = Screen->LoadLWeapon(j);
				if(Between(CenterX(lw),ExitX[this->Misc[GALE_WARP_MISC_INDEX]],ExitX[this->Misc[GALE_WARP_MISC_INDEX]]+16)
					&& Between(CenterY(lw),ExitY[this->Misc[GALE_WARP_MISC_INDEX]],ExitY[this->Misc[GALE_WARP_MISC_INDEX]]+16)){
					 //Change combo appearance.
					Screen->ComboD[ComboAt(EntryX[this->Misc[GALE_WARP_MISC_INDEX]],EntryY[this->Misc[GALE_WARP_MISC_INDEX]])]= StoredCombo[this->Misc[GALE_WARP_MISC_INDEX]];
					Screen->ComboD[ComboAt(ExitX[this->Misc[GALE_WARP_MISC_INDEX]],ExitY[this->Misc[GALE_WARP_MISC_INDEX]])]= StoredCombo[this->Misc[GALE_WARP_MISC_INDEX]];
					//Move Link to exit warp.
					lw->X = EntryX[this->Misc[GALE_WARP_MISC_INDEX]];
					lw->Y = EntryY[this->Misc[GALE_WARP_MISC_INDEX]];
					Game->PlaySound(GALE_WARP_SFX);//Play a sound.
					Warping = false;//Not warping.
				}
				else if(Between(CenterX(lw),EntryX[this->Misc[GALE_WARP_MISC_INDEX]],EntryX[this->Misc[GALE_WARP_MISC_INDEX]]+16)
					&& Between(CenterY(lw),EntryY[this->Misc[GALE_WARP_MISC_INDEX]],EntryY[this->Misc[GALE_WARP_MISC_INDEX]]+16)){
					 //Change combo appearance.
					Screen->ComboD[ComboAt(EntryX[this->Misc[GALE_WARP_MISC_INDEX]],EntryY[this->Misc[GALE_WARP_MISC_INDEX]])]= StoredCombo[this->Misc[GALE_WARP_MISC_INDEX]];
					Screen->ComboD[ComboAt(ExitX[this->Misc[GALE_WARP_MISC_INDEX]],ExitY[this->Misc[GALE_WARP_MISC_INDEX]])]= StoredCombo[this->Misc[GALE_WARP_MISC_INDEX]];
					//Move Link to exit warp.
					lw->X = ExitX[this->Misc[GALE_WARP_MISC_INDEX]];
					lw->Y = ExitY[this->Misc[GALE_WARP_MISC_INDEX]];
					Game->PlaySound(GALE_WARP_SFX);//Play a sound.
					Warping = false;//Not warping.
				}
			}
                         //An eweapon has encountered a warp tile.
			for(int j = Screen->NumEWeapons();j>0;j--){
				eweapon ew = Screen->LoadEWeapon(j);
				if(Between(CenterX(ew),ExitX[this->Misc[GALE_WARP_MISC_INDEX]],ExitX[this->Misc[GALE_WARP_MISC_INDEX]]+16)
					&& Between(CenterY(ew),ExitY[this->Misc[GALE_WARP_MISC_INDEX]],ExitY[this->Misc[GALE_WARP_MISC_INDEX]]+16)){
					 //Change combo appearance.
					Screen->ComboD[ComboAt(EntryX[this->Misc[GALE_WARP_MISC_INDEX]],EntryY[this->Misc[GALE_WARP_MISC_INDEX]])]= StoredCombo[this->Misc[GALE_WARP_MISC_INDEX]];
					Screen->ComboD[ComboAt(ExitX[this->Misc[GALE_WARP_MISC_INDEX]],ExitY[this->Misc[GALE_WARP_MISC_INDEX]])]= StoredCombo[this->Misc[GALE_WARP_MISC_INDEX]];
					//Move Link to exit warp.
					ew->X = EntryX[this->Misc[GALE_WARP_MISC_INDEX]];
					ew->Y = EntryY[this->Misc[GALE_WARP_MISC_INDEX]];
					Game->PlaySound(GALE_WARP_SFX);//Play a sound.
					Warping = false;//Not warping.
				}
				else if(Between(CenterX(ew),EntryX[this->Misc[GALE_WARP_MISC_INDEX]],EntryX[this->Misc[GALE_WARP_MISC_INDEX]]+16)
					&& Between(CenterY(ew),EntryY[this->Misc[GALE_WARP_MISC_INDEX]],EntryY[this->Misc[GALE_WARP_MISC_INDEX]]+16)){
					 //Change combo appearance.
					Screen->ComboD[ComboAt(EntryX[this->Misc[GALE_WARP_MISC_INDEX]],EntryY[this->Misc[GALE_WARP_MISC_INDEX]])]= StoredCombo[this->Misc[GALE_WARP_MISC_INDEX]];
					Screen->ComboD[ComboAt(ExitX[this->Misc[GALE_WARP_MISC_INDEX]],ExitY[this->Misc[GALE_WARP_MISC_INDEX]])]= StoredCombo[this->Misc[GALE_WARP_MISC_INDEX]];
					//Move Link to exit warp.
					ew->X = ExitX[this->Misc[GALE_WARP_MISC_INDEX]];
					ew->Y = ExitY[this->Misc[GALE_WARP_MISC_INDEX]];
					Game->PlaySound(GALE_WARP_SFX);//Play a sound.
					Warping = false;//Not warping.
				}
			}
			Waitframe();
		}
		//Kill the ffc.
		this->Data = 0;
		Quit();
	}
}