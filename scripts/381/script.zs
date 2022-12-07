//Main Files
#include "include/std.zh"
//Imports functions exclusive to my quest
//#include "CustomFunctions.zs"// You probably won't need this.
//I'm not sure you'll need this either.
#include "headers/stdExtra.zh"

// Section 28. ffcscript.zh
// Version 1.1.1
// Be sure to check if you're already importing ffcscript.zh
// Adjust to match the settings therein

// Combo to be used for generic script vehicle FFCs. This should be
// an invisible combo with no type or flag. It cannot be combo 0.
const int FFCS_INVISIBLE_COMBO = 1;

// Range of FFCs to use. Numbers must be between 1 and 32.
const int FFCS_MIN_FFC = 1;
const int FFCS_MAX_FFC = 32;


int RunFFCScript(int scriptNum, float args){
    // Invalid script
    if(scriptNum<0 || scriptNum>511)
        return 0;
    
    ffc theFFC;
    
    // Find an FFC not already in use
    for(int i=FFCS_MIN_FFC; i<=FFCS_MAX_FFC; i++){
        theFFC=Screen->LoadFFC(i);
        
        if(theFFC->Script!=0 ||
         theFFC->Data!=0 ||
         theFFC->Flags[FFCF_CHANGER])
            continue;
        
        // Found an unused one; set it up
        theFFC->Data=FFCS_INVISIBLE_COMBO;
        theFFC->Script=scriptNum;
        
        if(args!=NULL){
            for(int j=Min(SizeOfArray(args), 8)-1; j>=0; j--)
                theFFC->InitD[j]=args[j];
        }
        
        return i;
    }
    
    // No FFCs available
    return 0;
}

ffc RunFFCScriptOrQuit(int scriptNum, float args){
    // Invalid script
    if(scriptNum<0 || scriptNum>511)
        Quit();
    
    int ffcID=RunFFCScript(scriptNum, args);
    if(ffcID==0)
        Quit();
    
    return Screen->LoadFFC(ffcID);
}

int FindFFCRunning(int scriptNum){
    // Invalid script
    if(scriptNum<0 || scriptNum>511)
        return 0;
    
    ffc f;
    
    for(int i=1; i<=32; i++){
        f=Screen->LoadFFC(i);
        if(f->Script==scriptNum)
            return i;
    }
    
    // No FFCs running it
    return 0;
}

int FindNthFFCRunning(int scriptNum, int n){
    // Invalid script
    if(scriptNum<0 || scriptNum>511)
        return 0;
    
    ffc f;
    
    for(int i=1; i<=32; i++){
        f=Screen->LoadFFC(i);
        if(f->Script==scriptNum){
            n--;
            if(n==0)
                return i;
        }
    }
    
    // Not that many FFCs running it
    return 0;
}

int CountFFCsRunning(int scriptNum){
    // Invalid script
    if(scriptNum<0 || scriptNum>511)
        return 0;
    
    ffc f;
    int numFFCs=0;
    
    for(int i=1; i<=32; i++){
        f=Screen->LoadFFC(i);
        if(f->Script==scriptNum)
            numFFCs++;
    }
    
    return numFFCs;
}

const int LADDER_COMB0		=3;//Combo used to show ladder
const int LADDER_CSET		=5;//CSet of that combo
const int LADDER_SCRIPT		=1;//Script slot used by ladder script
const int LADDER_WALKABLE	=2;//A walkable combo. Place inherent flags to limit enemy movement
const int I_SCRIPT_LADDER	=50;//Item id of scripted ladder. Defaults to Amulet 1
const int GH_INVISIBLE_COMBO=1;//An invisible combo. 

//Place in items active slot
item script BetterLadder{
	void run(int four_way){
		//You aren't currently running the ladder script
		if(!CountFFCsRunning(LADDER_SCRIPT)){
			int Args[8]= {four_way};
			NewFFCScript(LADDER_SCRIPT, Args);
		}
	}
}

// A better function for launching ffcs
int NewFFCScript(int scriptNum, float args){
    // Invalid script
    if(scriptNum<0 || scriptNum>511)
        return 0;
    
    ffc theFFC;
    
    // Find an FFC not already in use
    for(int i=FFCS_MIN_FFC; i<=FFCS_MAX_FFC; i++){
        theFFC=Screen->LoadFFC(i);
        
        if(theFFC->Script!=0 ||
         (theFFC->Data!=0 && theFFC->Data!=FFCS_INVISIBLE_COMBO) ||
         theFFC->Flags[FFCF_CHANGER])
            continue;
        
        // Found an unused one; set it up
        theFFC->Data=FFCS_INVISIBLE_COMBO;
		theFFC->TileWidth = 1;
		theFFC->TileHeight = 1;
        theFFC->Script=scriptNum;
        
        if(args!=NULL){
            for(int j=Min(SizeOfArray(args), 8)-1; j>=0; j--)
                theFFC->InitD[j]=args[j];
        }
        theFFC->Flags[FFCF_ETHEREAL]= true;
        return i;
    }
    
    // No FFCs available
    return 0;
}

//Check to see if a particular location can be crossed with a ladder
//Supports checks of layers 1 and 2
bool CanLadder(int loc){
	int Layer1_Map = Screen->LayerMap(1);
    int Layer1_Screen= Screen->LayerScreen(1);
	int Layer2_Map = Screen->LayerMap(2);
    int Layer2_Screen= Screen->LayerScreen(2);
	if (Screen->ComboT[loc]==CT_LADDERONLY)
		return true;
	if (Screen->ComboT[loc]==CT_LADDERHOOKSHOT)
		return true;
	if (Screen->ComboT[loc]==CT_WATER)
		return true;	
    if(Game->GetComboType(Layer1_Map,Layer1_Screen,loc)==CT_LADDERONLY)
		return true;
	if(Game->GetComboType(Layer1_Map,Layer1_Screen,loc)==CT_LADDERHOOKSHOT)
		return true;	
	if(Game->GetComboType(Layer2_Map,Layer2_Screen,loc)==CT_LADDERONLY)
		return true;	
	if(Game->GetComboType(Layer2_Map,Layer2_Screen,loc)==CT_LADDERHOOKSHOT)
		return true;	
	return false;
}

//Script run when ladder is used
ffc script That_Ladder{
	void run(bool four_way){
		//Set up appearance of ladder ffc
		this->Data= LADDER_COMB0;
		this->CSet= LADDER_CSET;
		//Make sure it still runs while holding up an item
		this->Flags[FFCF_IGNOREHOLDUP]= true;
		//Orient based on the direction you're facing
		if(Link->Dir==DIR_LEFT||
			Link->Dir==DIR_RIGHT){
			if(Link->Dir==DIR_LEFT)
				this->X= GridX(Link->X-8);
			else
				this->X= GridX(Link->X+24);
			this->Y= GridY(Link->Y+8);
		}
		else{
			if(Link->Dir==DIR_UP)
				this->Y= GridY(Link->Y-8);
			else
				this->Y= GridY(Link->Y+24);
			this->X= GridX(Link->X+8);
		}
		//Check what button is being used by the ladder
		bool A_Button;
		if(GetEquipmentA()==I_SCRIPT_LADDER)
			A_Button= true;
		//FFC position checks
		int Combo_X= GridX(this->X);
		int Combo_Y= GridY(this->Y);
		int loc = ComboAt(Combo_X,Combo_Y);
		//Hold data for combo replaced by the script
		int Saved_Combo=-1;
		int Saved_CSet;
		//Used to simplify checks for future ffc position
		int X;
		int Y;
		//Check if the spot the ffc is on is a ladder spot
		if(CanLadder(loc)){
			//Replace the walkable combo's tile with the tile of the combo the ladder is on
			CopyTile(Game->ComboTile(Screen->ComboD[loc]),
						Game->ComboTile(LADDER_WALKABLE));
			//Save the data for the combo the ladder is on
			Saved_Combo= Screen->ComboD[loc];
			Saved_CSet= Screen->ComboC[loc];
			//Replace the combo the ladder is on with a walkable one
			Screen->ComboD[loc] =LADDER_WALKABLE;
			Screen->ComboC[loc] = Saved_CSet;
		}
		//Save the direction you're facing when you place the ladder
		int dir= Link->Dir;
		//You've made a ladder spot walkable
		if(Saved_Combo!=-1){
			//The ladder is on the A button
			if(A_Button){
				//You haven't pressed A
				while(!Link->PressA){
					Waitframe();
					//Check what direction you were facing when you placed the ladder
					if(dir==DIR_UP
						||dir==DIR_DOWN){
						//Check your current coordinates relative to the ffc
						if(Link->Y<=this->Y+15
							&& Link->Y+17>=this->Y){
							if(Link->X>=this->X-2
								&& Link->X<=this->X+18){
								//You're on the ladder
								//Don't let the player walk off the left or right side
								//Don't let the player remove the ladder
								if(!four_way)
									Link->X= this->X;
								Link->PressA=false;
							}
						}
					}
					else{
						if(Link->X<=this->X+15
							&& Link->X+17<=this->X){
							if(Link->Y<=this->Y+18
								&& Link->Y+17>=this->Y){
								if(!four_way)
									Link->Y= this->Y;
								Link->PressA=false;
							}
						}
					}
				}
			}
			else{
				//This ladder is on the B button
				//You haven't pressed B
				while(!Link->PressB){
					Waitframe();
					if(dir==DIR_UP
						||dir==DIR_DOWN){
						if(Link->Y<=this->Y+15
							&& Link->Y+17>=this->Y){
							if(Link->X<=this->X+15
								&& Link->X+17>=this->X){
								if(!four_way)
									Link->X= this->X;
								Link->PressB=false;
							}
						}
					}
					else{
						if(Link->X<=this->X+15
							&& Link->X+15>=this->X){
							if(Link->Y<=this->Y+15
								&& Link->Y+17>=this->Y){
								if(!four_way)
									Link->Y= this->Y;
								Link->PressB=false;
							}
						}
					}
				}
			}
		}
		else{
			//The ladder isn't on a ladder spot
			while(true){
				//On the A button
				if(A_Button){
					//You haven't pressed A
					while(!Link->PressA)
						Waitframe();
					break;
				}
				else{
					//On the B button
					//You haven't pressed B
					while(!Link->PressB)
						Waitframe();
					break;
				}
				Waitframe();
			}
		}
		//Make the ladder invisible
		this->Data= FFCS_INVISIBLE_COMBO;
		//If you replaced a combo, restore it
		if(Saved_Combo!=-1){
			Screen->ComboD[loc]= Saved_Combo;
			Screen->ComboC[loc]= Saved_CSet;
		}
		//Keep you from using the ladder for a bit
		Waitframes(30);
		//This script is done
		Quit();
	}
}

//Checks for matching combo flag and type.

//D0- On scren location.
//D1- Combo Flag to check.
//D2- Combo Type to check.

bool ComboFIT(int loc,int flag,int type){
	if(ComboFI(loc,flag)&& Screen->ComboT[loc]==type)return true;
	return false;
}

//Checks for matching combo flag and type.

//D0- On scren location.
//D1- Combo Flag to check.
//D2- Combo Type to check.

bool ComboFIT(int X, int Y,int flag,int type){
	int loc = ComboAt(X,Y);
	if(ComboFI(loc,flag)&& Screen->ComboT[loc]==type)return true;
	return false;
}