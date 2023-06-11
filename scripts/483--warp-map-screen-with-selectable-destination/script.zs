#include "std.zh"

/**
"Warp Map" FFC scripts by eNJuR (aka dragonsword)
Thank you Emily for pointing out a better way to handle the bit flag array and pointing out improvements!

Setup: Warp screen should be a solid room drawn on an overhead layer. Change the combo at the second row second column to a "sensitive warp" combo (Make sure the warp return square places Link elsewhere).
FFCs should be flagged "Draw Over"; set up FFCs as such:
First in sequence should be the wind ffc.
Second is the Selector FFC. It should be a 2 tile high/wide and will appear at selected location combos with a -8,-8 offset.
Next are the Location FFCs, in consecutive order that the player will cycle thru them when selecting. Place them on the screen where appropriate. Location FFC will use its set combo if invalid and the next combo if it is a valid location.
For best results, set FFCs to run script at screen init.
Set up FFCs variables according to notes in each script below.

Warp Map screen uses Screen-D[0] as a trigger.

Valid_CSet and Skip_CSet must be different. To use icons that are the same color, use the combo editor's "CSet 2" feature.

This script is not intented to be used if there are ever no valid warp locations. I've added a line to prevent freezing, but please be aware to only warp the player when there is an available destination.
*/

//constants and global variables for eNJuR's Warp_Map_ scripts:
const float WARP_MAP_WIND_SPEED = 2; // default speed of wind combo
const int WARP_MAP_CURSOR_SFX = 5; // default selector sound effect
const int WARP_MAP_VALID_CSET = 8; // CSet of valid destination icons
const int WARP_MAP_SKIP_CSET = 7; // CSet of invalid destination icons
const int WARP_MAP_LABEL_BG = 0x0F; // Color of label background
const int WARP_MAP_LABEL_TEXT = 0x01; // Color of label text
int S_label[160] = "???"; //buffer for string handling
long Warp_Map_Index = 0;

@Author("eNJuR")
ffc script Warp_Map_Wind{
	//d0 = FFC # of selector FFC,
	//d1 = Speed to move at (defaults to WARP_MAP_WIND_SPEED)
	void run(int cursorFFC, float speed){
		
		  // initialization
		ffc Cursor = Screen->LoadFFC(cursorFFC);
		this->Y=176;
		if(speed==0)speed=WARP_MAP_WIND_SPEED;
		Waitframe();
		this->X=Cursor->X+8;
		Waitframes(24);
		
		  // main loop
		while(true){
			if(this->Vx==0 && this->Vy==0 && this->X==Cursor->X+8 && this->Y==Cursor->Y+8) {
				if(Screen->D[0]>0) Quit();
				Waitframe();
				continue;
			}
			else if(Distance(this->X,this->Y,Cursor->X+8,Cursor->Y+8)<speed){
				this->X=Cursor->X+8;
				this->Y=Cursor->Y+8;
				this->Vx=0; this->Vy=0;
			}
			else{
				this->Vx=VectorX(speed,Angle(this->X,this->Y,Cursor->X+8,Cursor->Y+8));
				this->Vy=VectorY(speed,Angle(this->X,this->Y,Cursor->X+8,Cursor->Y+8));
			}
			Waitframe();
		}
	}
}

@Author("eNJuR")
ffc script Warp_Map_Selector{
	//d0 = FFC # of first (and defaultly selected) of the consecutive FFCs representing warp locations,
	//d1 = total number of location FFCs,
	//d2 = bit flag of first location FFC (0 skips checking validity on init.),
	//d3 = FFC # of backup location if d0 is invalid,
	//d4 = move SFX (defaults to WARP_MAP_CURSOR_SFX)
	void run(int firstLocFFC, int numLocFFC, int firstLocFlag, int backupFirstFFC, int cursorSFX){
		
		  // initialization
		Screen->D[0]=0;
		ffc Currently = Screen->LoadFFC(firstLocFFC);
		int positionNum = 0;
		if(cursorSFX==0) cursorSFX=WARP_MAP_CURSOR_SFX;
		if(firstLocFlag>0 && backupFirstFFC>0 && (Warp_Map_Index&(1Lb<<(firstLocFlag-1)))==0){
			Currently = Screen->LoadFFC(backupFirstFFC);
			positionNum = backupFirstFFC - firstLocFFC;
		}
		this->X=Currently->X-8;
		this->Y=Currently->Y-8;
		for (int i=0; i<25; i++){
			Screen->Rectangle(5,0,0,255,8,WARP_MAP_LABEL_BG,1,0,0,0,true,OP_OPAQUE);
			WaitNoAction();
		}
		
		  // main loop
		while(true){
			if(Link->PressStart || Link->PressA || Link->PressB){
				Screen->D[0]=firstLocFFC+positionNum;
				WaitNoAction();
				break;
			}
			if((Link->PressUp || Link->PressLeft) && !(Link->PressDown || Link->PressRight)){
				Game->PlaySound(cursorSFX);
				int preventinfinateloop = 0;
				do{
					preventinfinateloop++;
					positionNum--;
					if(positionNum<0) positionNum=numLocFFC-1;
					Currently = Screen->LoadFFC(firstLocFFC+positionNum);
					this->X = Currently->X-8;
					this->Y = Currently->Y-8;
				}while(Currently->CSet==WARP_MAP_SKIP_CSET && preventinfinateloop<numLocFFC);
			}
			if((Link->PressDown || Link->PressRight) && !(Link->PressUp || Link->PressLeft)){
				Game->PlaySound(cursorSFX);
				int preventinfinateloop = 0;
				do{
					preventinfinateloop++;
					positionNum++;
					if(positionNum>=numLocFFC) positionNum=0;
					Currently = Screen->LoadFFC(firstLocFFC+positionNum);
					this->X = Currently->X-8;
					this->Y = Currently->Y-8;
				}while(Currently->CSet==WARP_MAP_SKIP_CSET && preventinfinateloop<numLocFFC);
			}
			Screen->Rectangle(5,0,0,255,8,WARP_MAP_LABEL_BG,1,0,0,0,true,OP_OPAQUE);
			WaitNoAction();
		}
		Link->X=16; Link->Y=16;
	}
}

@Author("eNJuR")
ffc script Warp_Map_Location{
	//d0 = bit flag to determine if this is a valid destination (valid if nth bit from the right is on. if d0=0, this location is always valid),
	//d1 = label string (should be <= 32 characters long),
	//d2 = FFC # of selector
	//d3 = destination dmap
	//d4 = destination screen (note: make sure to use the hex value)
	void run(int vflag, int title, int selectornum, int dmap, int screen){
		
		  // initialization
		if(vflag!=0){
			if((Warp_Map_Index & (1Lb<<(vflag-1)))==0){
				this->CSet = WARP_MAP_SKIP_CSET;
				Quit();
			}
		}
		ffc Sel = Screen->LoadFFC(selectornum);
		this->CSet = WARP_MAP_VALID_CSET;
		this->Data++;
		Waitframes(25);
		
		  // main loop
		while(Screen->D[0]==0){
			if(this->X==Sel->X+8 && this->Y==Sel->Y+8){
				GetMessage(title,S_label);
				Screen->DrawString( 7, 128, 0, FONT_Z1, WARP_MAP_LABEL_TEXT, -1, TF_CENTERED, S_label, OP_OPAQUE );
			}
			Waitframe();
		}
		if(this->X==Sel->X+8 && this->Y==Sel->Y+8){
			Screen->SetTileWarp(0,screen,dmap,-1);
		}
		WaitNoAction(60);
	}
}

@Author("eNJuR")
ffc script Warp_Map_Set_Valid{
	//d0 = bit flag to set (nth from the right)
	//d1 = if 0 -> set this location valid,
	//		 1 -> unset,
	//		 2 -> toggle,
	//		-1 -> set this and unset all others
	//d2 = dely before setting Screen->D[0] (useful if other objects are relying on Screen->D[0]==0 to determine first time visitng the screen)
	//		-1 means don't change Screen->D[0]
	//		at least 36 is good for screens with script control codes
	void run(int flagNum, int op, int setdelay){
		if(Screen->D[0]>0) Quit();
		switch(op){
			case 1 : Warp_Map_Index ~= 1Lb<<(flagNum-1); break;
			case 2 : Warp_Map_Index ^= 1Lb<<(flagNum-1); break;
			case -1 : Warp_Map_Index = 1Lb<<(flagNum-1); break;
			default : Warp_Map_Index |= 1Lb<<(flagNum-1);
		}
		if(setdelay>=0){
			Waitframes(setdelay);
			if(Screen->D[0]==0) Screen->D[0]=1;
		}
	}
}

@Author("eNJuR")
item script Warp_Map_Set_Valid_I{
	//d0 = bit flag to set (nth from the right)
	//d1 = if 0 -> set this location valid,
	//		 1 -> unset,
	//		 2 -> toggle,
	//		-1 -> set this and unset all others
	void run(int flagNum, int op){
		switch(op){
			case 1 : Warp_Map_Index ~= 1Lb<<(flagNum-1); break;
			case 2 : Warp_Map_Index ^= 1Lb<<(flagNum-1); break;
			case -1 : Warp_Map_Index = 1Lb<<(flagNum-1); break;
			default : Warp_Map_Index |= 1Lb<<(flagNum-1);
		}
	}
}