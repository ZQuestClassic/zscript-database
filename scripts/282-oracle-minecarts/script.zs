const int CMB_MINECART = 7688; //Combo of the minecart, first of 16
							   //1-4: Minecart, stationary, 4-way
							   //5-8: Minecart, moving, 4-way
							   //9-12: Minecart, front layer, 4-way
							   //13-16: Link riding in minecart, 4-way
const int CS_MINECART = 2;

const int CMB_MINECART_TRACK = 7680; //First of a set of 7 minecart track combos.
									 //Only these combos when placed on layer 0 will actually function as minecart tracks
									 //1: Up/Down
									 //2: Left/Right
									 //3: Right/Down
									 //4: Left/Down
									 //5: Right/Up
									 //6: Left/Up
									 //7: Exit pad
									 
const int SFX_MINECART = 65; //Looping sound of the minecart on the tracks
const int MINECART_SFX_FREQ = 30; //How often the sound loops
									 
const int MINECART_LINKYOFFSET = -10; //Offset Link's sprite is drawn at compared to the minecart

const int DAMAGE_MINECART_COLLISION = 8; //How much damage the minecart does when it hits enemies
const int LW_MINECART_DAMAGE = 2; //Weapon type the minecart's hitbox uses. LW_BEAM by default

int GBCart[80];
const int GBC_DIR = 65;
const int GBC_CURID = 66;
const int GBC_FIRSTLOAD = 67;
const int GBC_ACTIVEFFC = 68;

void Minecart_Init(){
	Link->DrawYOffset = 0;
	Link->CollDetection = true;
	GBCart[GBC_DIR] = -1;
	if(GBCart[GBC_FIRSTLOAD]==0){
		for(int i=0; i<64; i++){
			GBCart[i] = -1;
		}
		GBCart[GBC_FIRSTLOAD] = 1;
	}
}

void DisableButtonItem(int itm){
	if(GetEquipmentA()==itm){
		Link->PressA = false;
		Link->InputA = false;
	}
	else if(GetEquipmentB()==itm){
		Link->PressB = false;
		Link->InputB = false;
	}
}

void Minecart_DisableItems(){
	DisableButtonItem(I_ROCSFEATHER);
}

void Minecart_Update1(){
	if(GBCart[GBC_DIR]>-1){
		Minecart_DisableItems();
	}
}

void Minecart_Update2(){
	if(GBCart[GBC_DIR]>-1){
		int scr[] = "GBMinecart_FFC";
		Link->DrawYOffset = MINECART_LINKYOFFSET;
		Link->CollDetection = false;
		if(Link->Action==LA_SCROLLING){
			GBCart[GBC_ACTIVEFFC] = -1;
			Minecart_Draw(ScrollingLinkX(), ScrollingLinkY(), GBCart[GBC_DIR], true);
		}
		else if(GBCart[GBC_ACTIVEFFC]>0){
			ffc f = Screen->LoadFFC(GBCart[GBC_ACTIVEFFC]);
			if(f->Script==Game->GetFFCScript(scr)){
				Link->X = f->X;
				Link->Y = f->Y;
			}
		}
		if(Minecart_CountFFCs(Game->GetFFCScript(scr), GBCart[GBC_CURID])==0){
			ffc f = Screen->LoadFFC(GBCart[GBC_ACTIVEFFC]);
			if(f->Script!=Game->GetFFCScript(scr)||f->InitD[1]!=GBCart[GBC_CURID]){
				if(Link->X>=0&&Link->X<=240&&Link->Y>=0&&Link->Y<=160){
					int args[8];
					args[0] = GBCart[GBC_DIR];
					args[1] = GBCart[GBC_CURID];
					args[2] = 0;
					args[3] = 1;
					f = Screen->LoadFFC(RunFFCScript(Game->GetFFCScript(scr), args));
					f->CSet = CS_MINECART;
					GBCart[GBC_ACTIVEFFC] = FFCNum(f);
					f->Flags[FFCF_PRELOAD] = true;
					f->X = Link->X;
					f->Y = Link->Y;
				}
			}
		}
	}
}

int Minecart_CountFFCs(int scrpt, int id){
	int count;
	for(int i=1; i<=32; i++){
		ffc f = Screen->LoadFFC(i);
		if(f->Script==scrpt&&f->InitD[1]==id&&f->InitD[3]==1)
			count++;
	}
	return count;
}

void Minecart_Draw(int x, int y, int dir, bool linkInside){
	int layer = 2;
	if(ScreenFlag(1, 4))
		layer = 1;
	dir = Clamp(dir, 0, 3);
	if(linkInside){
		Screen->FastCombo(layer, x, y, CMB_MINECART+4+dir, CS_MINECART, 128);
		if(Link->Action==LA_WALKING||Link->Action==LA_NONE||Link->Action==LA_SCROLLING){
			Screen->FastCombo(layer, x, y+MINECART_LINKYOFFSET, CMB_MINECART+12+Link->Dir, 6, 128);
			Link->Invisible = true;
		}
		else
			Link->Invisible = false;
		Screen->FastCombo(4, x, y, CMB_MINECART+8+dir, CS_MINECART, 128);
	}
	else{
		Screen->FastCombo(layer, x, y, CMB_MINECART+dir, CS_MINECART, 128);
	}
}

global script GBMinecart_Slot2{
	void run(){
		ScrollingDraws_Init();
		Minecart_Init();
		while(true){
			ScrollingDraws_Update();
			Minecart_Update1();
			Waitdraw();
			Minecart_Update2();
			Waitframe();
		}
	}
}

ffc script GBMinecart_FFC{
	void run(int startDir, int ID, int start, int spawned){
		int ffcNum = FFCNum(this);
		int tempID;
		if(ID>0)
			tempID = Clamp(ID-1, 0, 63);
			
		if(GBCart[GBC_DIR]<=-1||GBCart[GBC_CURID]!=ID)
			this->Data = CMB_MINECART+startDir;
		else if(spawned==0){
			if(Link->X<=0||Link->X>=240||Link->Y<=0||Link->Y>=160){
				this->Data = 0;
				Quit();
			}
			else{
				GBCart[GBC_DIR] = -1;
				Waitframe();
			}
		}
		else{
			if(GBCart[GBC_ACTIVEFFC]==-1)
				GBCart[GBC_ACTIVEFFC] = ffcNum;
		}
		if(spawned==0&&GBCart[GBC_DIR]==-1&&ID>0){
			if(GBCart[tempID]==-1){
				if(start){
					GBCart[tempID] = Game->GetCurScreen();
				}
				else{
					this->Data = 0;
					Quit();
				}
			}
			else if(GBCart[tempID]!=Game->GetCurScreen()&&GBCart[GBC_FIRSTLOAD]==1){
				this->Data = 0;
				Quit();
			}
		}
		int lastDir = startDir;
		int sfxCounter;
		lweapon hitbox;
		while(true){
			while(GBCart[GBC_DIR]==-1||GBCart[GBC_CURID]!=ID){
				this->Data = CMB_MINECART+startDir;
				if(Link->Y<this->Y)
					this->Flags[FFCF_OVERLAY] = true;
				else
					this->Flags[FFCF_OVERLAY] = false;
				if(GBMinecart_Collision(this)){
					while(Link->Z>0){
						WaitNoAction();
					}
					this->Flags[FFCF_OVERLAY] = false;
					Link->Dir = AngleDir4(Angle(Link->X, Link->Y, this->X, this->Y));
					Link->Jump = 2;
					Game->PlaySound(SFX_JUMP);
					int angle = Angle(Link->X, Link->Y, this->X, this->Y+MINECART_LINKYOFFSET);
					int dist = Distance(Link->X, Link->Y, this->X, this->Y+MINECART_LINKYOFFSET);
					int linkX = Link->X;
					int linkY = Link->Y;
					for(int i=0; i<26; i++){
						linkX += VectorX(dist/26, angle);
						linkY += VectorY(dist/26, angle);
						Link->X = linkX;
						Link->Y = linkY;
						WaitNoAction();
					}
					Link->DrawYOffset = MINECART_LINKYOFFSET;
					Link->CollDetection = false;
					GBCart[GBC_DIR] = startDir;
					GBCart[GBC_CURID] = ID;
					GBCart[GBC_ACTIVEFFC] = FFCNum(this);
					sfxCounter = 0;
				}
				Waitframe();
			}
			while(GBCart[GBC_DIR]!=-1&&GBCart[GBC_CURID]==ID){		
				int cp = ComboAt(this->X+8, this->Y+8);
				lastDir = GBCart[GBC_DIR];
				GBCart[GBC_DIR] = GBMinecart_NextDirection(cp, GBCart[GBC_DIR]);
				for(int i=0; i<8&&GBCart[GBC_DIR]>-1; i++){
					if(sfxCounter==0)
						Game->PlaySound(SFX_MINECART);
						
					sfxCounter++;
					if(sfxCounter>MINECART_SFX_FREQ)
						sfxCounter = 0;
					if(GBCart[GBC_DIR]==DIR_UP)
						this->Y -= 2;
					else if(GBCart[GBC_DIR]==DIR_DOWN)
						this->Y += 2;
					else if(GBCart[GBC_DIR]==DIR_LEFT)
						this->X -= 2;
					else if(GBCart[GBC_DIR]==DIR_RIGHT)
						this->X += 2;
					this->Data = FFCS_INVISIBLE_COMBO;
					hitbox = GBMinecart_UpdateHitbox(hitbox, this->X, this->Y, true);
					Minecart_Draw(this->X, this->Y, GBCart[GBC_DIR], true);
					Link->X = this->X;
					Link->Y = this->Y;
					Waitframe();
				}
				this->X = GridX(this->X+8);
				this->Y = GridY(this->Y+8);
				if(GBCart[GBC_DIR]<=-1){
					if(GBCart[GBC_DIR]<-1)
						lastDir = Abs(GBCart[GBC_DIR])-2;
					GBCart[GBC_DIR] = -1;
					this->Data = CMB_MINECART+lastDir;
				
					Link->DrawYOffset = 0;
					Link->Invisible = false;
					Link->CollDetection = true;
					cp = GBMinecart_ComboInFront(cp, lastDir);
					Link->Dir = AngleDir4(Angle(Link->X, Link->Y, ComboX(cp), ComboY(cp)));
					Link->Y += MINECART_LINKYOFFSET;
					Link->Jump = 2;
					Game->PlaySound(SFX_JUMP);
					int angle = Angle(Link->X, Link->Y, ComboX(cp), ComboY(cp));
					int dist = Distance(Link->X, Link->Y, ComboX(cp), ComboY(cp));
					int linkX = Link->X;
					int linkY = Link->Y;
					for(int i=0; i<26; i++){
						linkX += VectorX(dist/26, angle);
						linkY += VectorY(dist/26, angle);
						Link->X = linkX;
						Link->Y = linkY;
						hitbox = GBMinecart_UpdateHitbox(hitbox, this->X, this->Y, false);
						WaitNoAction();
					}
					startDir = OppositeDir(lastDir);
					if(GBCart[GBC_CURID]>0){
						tempID = Clamp(GBCart[GBC_CURID]-1, 0, 63);
						GBCart[tempID] = Game->GetCurScreen();
					}
					//MooshPit_ResetEntry();
				}
			}
		}
	}
	int GBMinecart_NextDirection(int cp, int dir){
		int up[6]    = {1, 0, 0, 0, 1, 1};
		int down[6]  = {1, 0, 1, 1, 0, 0};
		int left[6]  = {0, 1, 0, 1, 0, 1};
		int right[6] = {0, 1, 1, 0, 1, 0};
		int directions[4] = {up, down, left, right};
		
		int c;
		
		//Combo under
		c = Screen->ComboD[cp];
		if(c>=CMB_MINECART_TRACK&&c<=CMB_MINECART_TRACK+5)
			c = Clamp(c-CMB_MINECART_TRACK, 0, 5);
		else
			c = -1;
			
		int frontDir = -1;
		int d = directions[dir];
		if(d[c]==1&&frontDir==-1){
			frontDir = dir;
		}
		else{
			for(int i=0; i<4; i++){
				if(i!=OppositeDir(dir)&&i!=dir){
					d = directions[i];
					if(d[c]==1){
						int c2 = Screen->ComboD[GBMinecart_ComboInFront(cp, i)];
						if(c2>=CMB_MINECART_TRACK&&c2<=CMB_MINECART_TRACK+5)
							return i;
						if(c2==CMB_MINECART_TRACK+6)
							return -2-i;
						else
							return OppositeDir(dir);
					}
				}
			}
		}
		
		c = Screen->ComboD[GBMinecart_ComboInFront(cp, dir)];
		if(c>=CMB_MINECART_TRACK&&c<=CMB_MINECART_TRACK+6)
			c = Clamp(c-CMB_MINECART_TRACK, 0, 6);
		else
			c = -1;
		if(c==-1)
			return OppositeDir(dir);
		else if(c==6)
			return -1;
			
		if(frontDir>-1)
			return frontDir;
		return dir;	
	}
	int GBMinecart_ComboInFront(int cp, int dir){
		if(cp<16&&dir==DIR_UP)
			return cp;
		else if(cp>159&&dir==DIR_DOWN)
			return cp;
		else if(cp%16==0&&dir==DIR_LEFT)
			return cp;
		else if(cp%16==15&&dir==DIR_RIGHT)
			return cp;
		if(dir==DIR_UP)
			cp -= 16;
		else if(dir==DIR_DOWN)
			cp += 16;
		else if(dir==DIR_LEFT)
			cp--;
		else if(dir==DIR_RIGHT)
			cp++;
		return cp;
	}
	bool GBMinecart_Collision(ffc this){
		if(Abs(Link->X-this->X)<12&&Abs(Link->Y-this->Y)<10)
			return true;
		return false;
	}
	lweapon GBMinecart_UpdateHitbox(lweapon hitbox, int x, int y, bool alive){
		if(hitbox->isValid()){
			hitbox->X = x;
			hitbox->Y = y;
			hitbox->Dir = GBCart[GBC_DIR];
			hitbox->Step = 0;
			hitbox->DeadState = -1;
			hitbox->DrawYOffset = -1000;
			if(!alive){
				hitbox->DeadState = 0;
			}
		}
		else{
			if(alive){
				hitbox = CreateLWeaponAt(LW_MINECART_DAMAGE, x, y);
				hitbox->Dir = GBCart[GBC_DIR];
				hitbox->Damage = DAMAGE_MINECART_COLLISION;
				hitbox->Step = 0;
				hitbox->DeadState = -1;
				hitbox->DrawYOffset = -1000;
			}
		}
		return hitbox;
	}
}

ffc script GBMinecart_Shutter{
	void run(){
		int thisData = this->Data;
		int thisCSet = this->CSet;
		this->Data = FFCS_INVISIBLE_COMBO;
		int cp = ComboAt(this->X+8, this->Y+8);
		int underCombo = Screen->ComboD[cp];
		int underCSet = Screen->ComboC[cp];
		int LinkX = Link->X;
		if(LinkX<=0)
			LinkX = 240;
		else if(LinkX>=240)
			LinkX = 0;
		int LinkY = Link->Y;
		if(LinkY<=0)
			LinkY = 160;
		else if(LinkY>=160)
			LinkY = 0;
		if(!(Abs(this->X-LinkX)<20&&Abs(this->Y-LinkY)<20)){
			Screen->ComboD[cp] = thisData;
			Screen->ComboC[cp] = thisCSet;
			while(GBCart[GBC_DIR]==-1||!(Abs(this->X-Link->X)<20&&Abs(this->Y-Link->Y)<20)){
				Waitframe();
			}
			Game->PlaySound(SFX_SHUTTER);
			Screen->ComboD[cp] = underCombo;
			Screen->ComboC[cp] = underCSet;
			this->Data = thisData+1;
			this->CSet = thisCSet;
			Waitframes(4);
			this->Data = FFCS_INVISIBLE_COMBO;
		}
		else{
			Waitframe();
			
		}
		while(true){
			while(GBCart[GBC_DIR]>-1&&(Abs(this->X-Link->X)<20&&Abs(this->Y-Link->Y)<20)){
				Waitframe();
			}
			Game->PlaySound(SFX_SHUTTER);
			this->Data = thisData+1;
			this->CSet = thisCSet;
			Waitframes(4);
			Screen->ComboD[cp] = thisData;
			Screen->ComboC[cp] = thisCSet;
			this->Data = FFCS_INVISIBLE_COMBO;
			while(GBCart[GBC_DIR]==-1||!(Abs(this->X-Link->X)<20&&Abs(this->Y-Link->Y)<20)){
				Waitframe();
			}
			Game->PlaySound(SFX_SHUTTER);
			Screen->ComboD[cp] = underCombo;
			Screen->ComboC[cp] = underCSet;
			this->Data = thisData+1;
			this->CSet = thisCSet;
			Waitframes(4);
			this->Data = FFCS_INVISIBLE_COMBO;
		}
	}
}

ffc script GBMinecart_ResetID{
	void run(int id1, int id2, int id3, int id4, int id5, int id6, int id7, int id8){
		if(Distance(Link->X, Link->Y, this->X, this->Y)<16){
			int ids[8];
			ids[0] = id1;
			ids[1] = id2;
			ids[2] = id3;
			ids[3] = id4;
			ids[4] = id5;
			ids[5] = id6;
			ids[6] = id7;
			ids[7] = id8;
			for(int i=0; i<8; i++){
				int tempID = Clamp(ids[i]-1, 0, 63);
				if(ids[i]>0)
					GBCart[tempID] = -1;
			}
		}
	}
}