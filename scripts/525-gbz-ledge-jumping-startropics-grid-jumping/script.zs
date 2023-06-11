const int CT_LEDGE_JUMP = 42;//Combo type used for Link`s Awakening Ledge Jumping

const int CF_LEDGE_ONEWAY_UP = 98;//Combo flags to define one-way sloping ledges, 0 for Startropics-like pit jumping.
const int CF_LEDGE_ONEWAY_DOWN = 99;
const int CF_LEDGE_ONEWAY_LEFT = 100;
const int CF_LEDGE_ONEWAY_RIGHT = 101;

const int IC_GRIDJUMP = 86;//Class of items needed to perform ledge jumping. Use Power to define max jump distance

const int GRIDJUMP_SENSIVITY = 12;//How long Link must push against ledge combo to perform Ledge Jump

const int _GRIDJUMP_JUMPDIR = 0;//Don`t edit
const int _GRIDJUMP_JUMPTIMER = 1;
const int _GRIDJUMP_JUMPPOWER = 2;

//LttP Ledge Jumping + Startropics Grid Jumping

//Use CT_LEDGE_JUMP combo type to define solid ledge combos. Use CF_LEDGE_ONEWAY_UP,CF_LEDGE_ONEWAY_DOWN,CF_LEDGE_ONEWAY_LEFT and CF_LEDGE_ONEWAY_RIGHT to define one-way ledges. Or leave inherent flag as 0 for grid-like jumping combos, ala Startropics/Golden Sun.

//Combine this global script with other global scripts
global script LedgeJumping{
	void run(){
		int gridjump[3]={-1,0,0};
		
		while(true){
			
			GridJumpUpdate(gridjump);
			
			Waitframe();
		}
	}
}

global script Ledge_Active{
	void run(){		
		StartGhostZH();
		Tango_Start();
		__classic_zh_InitScreenUpdating();
		int gridjump[3]={-1,0,0};
		while(true)	{
			GridJumpUpdate(gridjump);
			UpdateGhostZH1();
			__classic_zh_UpdateScreenChange1();
			Tango_Update1();
			__classic_zh_do_z2_lantern();
			if ( __classic_zc_internal[__classic_zh_SCREENCHANGED] )
			{
				__classic_zh_CompassBeep();
				__classic_zh_ResetScreenChange();
			}
			Waitdraw();
			UpdateGhostZH2();
			Tango_Update2();
			Waitframe();
		}
	}
}

void GridJumpUpdate(int gridjump){
	int br = GetHighestLevelItemOwned(IC_GRIDJUMP);
	int power = 0;
	int cmb=-1;
	int dir=Link->Dir;
	int jumppower=0;
	int dircf[4]={CF_LEDGE_ONEWAY_UP,CF_LEDGE_ONEWAY_DOWN,CF_LEDGE_ONEWAY_LEFT,CF_LEDGE_ONEWAY_RIGHT};
	if (br>=0){
		itemdata it = Game->LoadItemData(br);
		power = it->Power;
	}
	if (gridjump[_GRIDJUMP_JUMPDIR]<0){
		if (dir==DIR_UP){
			cmb = ComboAt(Link->X+9,Link->Y+7);
			if (Screen->ComboT[cmb]== CT_LEDGE_JUMP && Screen->ComboS[cmb]==15 && Link->InputUp) gridjump[_GRIDJUMP_JUMPTIMER]++;
			else gridjump[_GRIDJUMP_JUMPTIMER]=0;
		}
		if (dir==DIR_DOWN){
			cmb = ComboAt(Link->X+9,Link->Y+16);
			if (Screen->ComboT[cmb]== CT_LEDGE_JUMP && Screen->ComboS[cmb]==15 && Link->InputDown) gridjump[_GRIDJUMP_JUMPTIMER]++;
			else gridjump[_GRIDJUMP_JUMPTIMER]=0;
		}
		if (dir==DIR_LEFT){
			cmb = ComboAt(Link->X-1,Link->Y+11);
			if (Screen->ComboT[cmb]== CT_LEDGE_JUMP && Screen->ComboS[cmb]==15 && Link->InputLeft) gridjump[_GRIDJUMP_JUMPTIMER]++;
			else gridjump[_GRIDJUMP_JUMPTIMER]=0;
		}
		if (dir==DIR_RIGHT){
			cmb = ComboAt(Link->X+16,Link->Y+11);
			if (Screen->ComboT[cmb]== CT_LEDGE_JUMP && Screen->ComboS[cmb]==15 && Link->InputRight) gridjump[_GRIDJUMP_JUMPTIMER]++;
			else gridjump[_GRIDJUMP_JUMPTIMER]=0;
		}
		if (gridjump[_GRIDJUMP_JUMPTIMER]>=GRIDJUMP_SENSIVITY){
			gridjump[_GRIDJUMP_JUMPPOWER] = CanGridJump(cmb, dir,power);
			if (gridjump[_GRIDJUMP_JUMPPOWER]!=0){
				if (gridjump[_GRIDJUMP_JUMPPOWER]>0)gridjump[_GRIDJUMP_JUMPTIMER] = gridjump[_GRIDJUMP_JUMPPOWER]*8+8;
				else gridjump[_GRIDJUMP_JUMPTIMER]=6;
				gridjump[_GRIDJUMP_JUMPDIR] = dir;
				Game->PlaySound(SFX_JUMP);
			}
			else gridjump[_GRIDJUMP_JUMPTIMER]=0;
		}
	}
	else{
		if (Link->Action==LA_SCROLLING) return;
		//else if (Link->Z<16) Link->Z+=2;
		//else Link->Z=16;
		if (Link->Z<4)Link->Jump=1;
		if (gridjump[_GRIDJUMP_JUMPPOWER]<0){
			if (gridjump[_GRIDJUMP_JUMPDIR]==DIR_UP){ 
				Link->Y-=2;
			}
			if (gridjump[_GRIDJUMP_JUMPDIR]==DIR_DOWN){
				Link->Y+=2;
			}
			if (gridjump[_GRIDJUMP_JUMPDIR]==DIR_LEFT){
				Link->X-=2;
			}
			if (gridjump[_GRIDJUMP_JUMPDIR]==DIR_RIGHT){
				Link->X+=2;
			}
			cmb = ComboAt (CenterLinkX(), CenterLinkY());
			if (Screen->ComboS[cmb]==0){
				gridjump[_GRIDJUMP_JUMPTIMER] --;
				if (gridjump[_GRIDJUMP_JUMPTIMER] <=0) gridjump[_GRIDJUMP_JUMPDIR] = -1;
			}
			else{
				int newdir = ArrayMatch(dircf, Screen->ComboI[cmb]);
				if (newdir>=0 && newdir != gridjump[_GRIDJUMP_JUMPDIR]){
					Link->X = ComboX(cmb);
					Link->Y = ComboY(cmb);
					gridjump[_GRIDJUMP_JUMPDIR]=newdir;
					Link->Dir=newdir;
				}
			}
		}
		else{
			if (gridjump[_GRIDJUMP_JUMPDIR]==DIR_UP){ 
				Link->Y-=2;
			}
			if (gridjump[_GRIDJUMP_JUMPDIR]==DIR_DOWN){
				Link->Y+=2;
			}
			if (gridjump[_GRIDJUMP_JUMPDIR]==DIR_LEFT){
				Link->X-=2;
			}
			if (gridjump[_GRIDJUMP_JUMPDIR]==DIR_RIGHT){
				Link->X+=2;
			}
			gridjump[_GRIDJUMP_JUMPTIMER] --;
			if (gridjump[_GRIDJUMP_JUMPTIMER] <=0) gridjump[_GRIDJUMP_JUMPDIR] = -1;
		}
		NoAction();
		if (gridjump[_GRIDJUMP_JUMPDIR]<0){
			gridjump[_GRIDJUMP_JUMPPOWER]=0;
			gridjump[_GRIDJUMP_JUMPTIMER]=0;
		}
	}
	// for (int i=0; i<3;i++){
	// debugValue(i+1, gridjump[i]);
	// }
}

int CanGridJump(int cmb, int dir, int power){
	if (Link->Z>0) return 0;
	if (power==0) return 0;
	// Screen->Rectangle(3, ComboX(cmb), ComboY(cmb), ComboX(cmb)+15, ComboY(cmb)+15, 1, -1,0, 0, 0,true, OP_OPAQUE);
	int jumppower = 0;
	int adjcmb = AdjacentComboFix(cmb, dir);
	int dircf[4]={CF_LEDGE_ONEWAY_UP,CF_LEDGE_ONEWAY_DOWN,CF_LEDGE_ONEWAY_LEFT,CF_LEDGE_ONEWAY_RIGHT};
	if (Screen->ComboT[cmb]!= CT_LEDGE_JUMP) return 0;
	if (Screen->ComboI[cmb]>0 && Screen->ComboI[cmb]!=dircf[dir]) return 0;
	if (Screen->ComboI[adjcmb]==0){
		while(jumppower<=power){
			// Screen->Rectangle(3, ComboX(adjcmb), ComboY(adjcmb), ComboX(adjcmb)+15, ComboY(adjcmb)+15, 1, -1,0, 0, 0,false, OP_OPAQUE);
			jumppower++;			
			if (adjcmb<0) return 0;
			if(Screen->ComboS[adjcmb]== 0) return jumppower;
			if (Screen->ComboT[adjcmb]!= CT_LEDGE_JUMP) return 0;
			adjcmb = AdjacentComboFix(adjcmb, dir);
		}
		return 0;
	}
	else{
		while (adjcmb>=0){
			if (Screen->ComboI[adjcmb]!=dircf[dir]) return 0;
			if (adjcmb<0) return -1;
			if(Screen->ComboS[adjcmb]== 0) return -1;
			adjcmb = AdjacentComboFix(adjcmb, dir);
			if (adjcmb<0) return -1;
			if(Screen->ComboS[adjcmb]== 0) return -1;
		}
		return -1;
	}
}

int AdjacentComboFix(int cmb, int dir)
{
	int combooffsets[13]={-0x10, 0x10, -1, 1, -0x11, -0x0F, 0x0F, 0x11};
	if ( cmb % 16 == 0 ) combooffsets[9] = -1;//if it's the left edge
	if ( (cmb % 16) == 15 ) combooffsets[10] = -1; //if it's the right edge
	if ( cmb < 0x10 ) combooffsets[11] = -1; //if it's the top row
	if ( cmb > 0x9F ) combooffsets[12] = -1; //if it's on the bottom row
	if ( combooffsets[9]==-1 && ( dir == DIR_LEFT || dir == DIR_LEFTUP || dir == DIR_LEFTDOWN ) ) return -1; //if the left columb
	if ( combooffsets[10]==-1 && ( dir == DIR_RIGHT || dir == DIR_RIGHTUP || dir == DIR_RIGHTDOWN ) ) return -1; //if the right column
	if ( combooffsets[11]==-1 && ( dir == DIR_UP || dir == DIR_RIGHTUP || dir == DIR_LEFTUP ) ) return -1; //if the top row
	if ( combooffsets[12]==-1 && ( dir == DIR_DOWN || dir == DIR_RIGHTDOWN || dir == DIR_LEFTDOWN ) ) return -1; //if the bottom row
	if ( cmb >= 0 && cmb < 176 ) return cmb + combooffsets[dir];
	else return -1;
}	

//Returns index of the given element that exists in the given array or -1, if it does not exist.
int ArrayMatch(int arr, int value){
	for (int i=0; i<SizeOfArray(arr); i++){
		if (arr[i] == value) return i;
	}
	return -1;
}