//Constants for Pitfall
//Type PF_*
//Pits
const int PF_PIT_COMBO = 0; //Combo Type of pits.
const int PF_PIT_WARP = 98; //Flag for pit warping.
const int PF_LINK_FALL = 0; //LWeapon for Link falling.
const int PF_SFX_FALL = 0; //SFX for Link falling.
const int PF_PIT_DAMAGE = 8; //Damage from pits in 1/16ths of a heart.

//Lava
const int PF_LAVA_COMBO = 0; //Combo Type of lava.
const int PF_LINK_MELT = 0; //LWeapon for Link melting.
const int PF_SFX_MELT = 0; //SFX for Link melting.
const int PF_LAVA_DAMAGE = 16; //Damage from lava in 1/16ths of a heart.

//Globals ...Do Not Change...
int PF_curscreen = -1;
int PF_curmap = -1;
bool PF_stored = false;
bool PF_warp = false;
bool PF_onplatform = false;

//=================================Pitfall=====================================================
void PF_Drawing(){
  //Add functions you need drawn here.
}

void PitFall(){

	int wait;

	//Grab current screen.
	if(PF_curscreen != Game->GetCurScreen() || PF_curmap != Game->GetCurMap()){
		PF_curscreen = Game->GetCurScreen();
		PF_curmap = Game->GetCurMap();
		PF_stored = false;
	}
	else if(Link->Action != LA_SCROLLING && !PF_stored && Link->Z <= 0){
		Link->Misc[2] = Link->X;
		Link->Misc[3] = Link->Y;
		PF_stored = true;
	}
	
	//if Link was warped.
	if(PF_warp){
		Link->Z = Link->Y;
		PF_warp = false;
		while(Link->Z > 0){
			PF_Drawing();
			WaitNoAction(); //Wait for Link to Land before continuing.
		}
		return;
	}
	
	//Check for Hookshot or platform.
	lweapon hook = LoadLWeaponOf(LW_HOOKSHOT);
	if(hook->isValid() || PF_onplatform) return;
	
	//Check for Pit Combo.
	if(Screen->ComboT[ComboAt(CenterLinkX(), CenterLinkY() + 4)] == PF_PIT_COMBO){
		NoAction();
		wait = PF_LinkSetup(PF_LINK_FALL, PF_SFX_FALL);
		while(wait > 0){
			PF_Drawing();
			wait--;
			WaitNoAction();
		}
		Link->Invisible = false;
		Link->CollDetection = true;
		if(Screen->ComboF[ComboAt(CenterLinkX(), CenterLinkY() + 4)] == PF_PIT_WARP){
			Link->PitWarp(Screen->GetSideWarpDMap(3), Screen->GetSideWarpScreen(3));
			PF_warp = true;
		}
		else{
			Link->HP -= PF_PIT_DAMAGE;
			Game->PlaySound(SFX_OUCH);
			Link->X = Link->Misc[2];
			Link->Y = Link->Misc[3];
		}
	}
	//Check for Lava Combo.
	else if(Screen->ComboT[ComboAt(CenterLinkX(), CenterLinkY() + 4)] == PF_LAVA_COMBO){
		NoAction();
		wait = PF_LinkSetup(PF_LINK_MELT, PF_SFX_MELT);
		while(wait > 0){
			PF_Drawing();
			wait--;
			WaitNoAction();
		}
		Link->Invisible = false;
		Link->CollDetection = true;
		Link->HP -= PF_LAVA_DAMAGE;
		Game->PlaySound(SFX_OUCH);
		Link->X = Link->Misc[2];
		Link->Y = Link->Misc[3];
	}
}

int PF_LinkSetup(int sprite, int sfx){

	//Snap Link to grid and make invisible.
	Link->Invisible = true;
	Link->CollDetection = false;
	Link->X = GridX(Link->X + 8);
	Link->Y = GridY(Link->Y + 12);
	
	//Create Dummy lweapon.
	lweapon dummy = CreateLWeaponAt(LW_SCRIPT1, Link->X, Link->Y);
	dummy->UseSprite(sprite);
	dummy->DeadState = dummy->NumFrames * dummy->ASpeed;
	dummy->CollDetection = false;
	
	//Play Sound sfx.
	Game->PlaySound(sfx);
	
	//return timer
	return dummy->NumFrames * dummy->ASpeed;

}

//========================================Platform========================================
//D0: Type: Changer (0) or Platform (1)
//D1: Delay at each corner in frames.
//D2: Wait for screen secrets. No(0) or Yes(1).

//if type 0.
		//D1 - 7 to use as data holders.
		//D1: New direction. Use one of 4 standard directions. Use -1 for same direction.
		//D2: New Speed. Use -1 for same speed.
		//D3: Platform teleports. No(0), Yes(1), Take Link(2).
		//D4: New X.
		//D5: New Y.
		//D6: TeleEffect. No Effect(0). Effect(1).

const int TELECOMBO = 0; //Combo of the teleport effect. upto 3x3.
const int TELETIME = 120; //Length of the teleport animation in frames.
const int TELELAYER = 3; //Layer to draw the effect on.
const int TELESOUND = 0; //SFX for effect.		
		
ffc script Platform
{
	void run(int type, int delay, bool secret)
	{
		int t1;
		int direction = 0;
		int scriptnum;
		int currentFFC = 0;
		float speed = 0;
		float rate;
		float accel = 0;
		
		ffc temp;
		
		int scriptname[] = "Platform";
	
		if(type == 1) //Type 1: Platform
		{
			scriptnum = Game->GetFFCScript(scriptname);
			if(secret == 1)
			{
				while(!Screen->State[ST_SECRET])
				{
					Waitframe();
				}
			}
			for(t1 = 0; t1 < delay; t1++)
			{
				//Update and check for collision.
				if(RectCollision(Link->X+6, Link->Y+8, Link->X+10, Link->Y+16, this->X, this->Y, this->X+(16*this->TileWidth), this->Y+(16*this->TileHeight)))
					PF_onplatform = true;
				else
					PF_onplatform = false;
				//Wait for delay.
				Waitframe();
			}
			
		//Start Loop
			while(true)
			{
				//Update and check for collision.
				if(RectCollision(Link->X+6, Link->Y+8, Link->X+10, Link->Y+16, this->X, this->Y, this->X+(16*this->TileWidth), this->Y+(16*this->TileHeight)))
					PF_onplatform = true;
				else
				{
					PF_onplatform = false;
					rate = speed % 1;
				}
					
				//Check for flags.
				for(t1 = 32; t1 > 0; t1--)
				{
					temp = Screen->LoadFFC(t1);
					if(temp->Script == scriptnum && temp->InitD[0] == 0 && PlatformGridX(this->X, speed) == PlatformGridX(temp->X, speed) && PlatformGridY(this->Y, speed) == PlatformGridY(temp->Y, speed) && currentFFC != t1)
					{
						PF_Snap(this, temp);
						direction = PF_Direction(temp, direction);
						speed = PF_Speed(temp, speed);
						rate = speed % 1;
						accel = 0;
						if(PF_Teleport(temp, this))
							PF_Delay(this, delay);
						currentFFC = t1;
					}
				}
				
				//Move Platform.
				accel += PF_Move(this, direction, speed, accel, rate);
				accel %= 1;
				
				Waitframe();
			}
		}
		else //Type 0: Changer
		{
			while(true)
				Waitframe();
		}
	}
}

int PlatformGridX(int x, float speed)
{
	if(x % 0.25 == 0 && speed < 1)
		return x;
	else
		return (x >> 2) << 2;
}

int PlatformGridY(int y, float speed)
{
	if(y % 0.25 == 0 && speed < 1)
		return y;
	else
		return (y >> 2) << 2;
}

void PF_Snap(ffc this, ffc temp)
{
	int X = this->X;
	int Y = this->Y;
	
	//Snap to changer.
	this->X = temp->X;
	this->Y = temp->Y;
	if(PF_onplatform)
	{
		Link->X += this->X - X;
		Link->Y += this->Y - Y;
	}
}

void PF_Delay(ffc this, int delay)
{
	for(int t1 = delay; t1 > 0; t1--)
	{
		//Update and check for collision.
		if(RectCollision(Link->X+6, Link->Y+8, Link->X+10, Link->Y+16, this->X, this->Y, this->X+(16*this->TileWidth), this->Y+(16*this->TileHeight)))
			PF_onplatform = true;
		else
			PF_onplatform = false;
		Waitframe();
	}
}

int PF_Direction(ffc temp, int direction)
{
	int newdirection = temp->InitD[1];
	
	if(newdirection > -1)
		return newdirection;
	else
		return direction;
}

int PF_Speed(ffc temp, float speed)
{
	float newspeed = temp->InitD[2];
	
	if(newspeed > -1)
		return newspeed;
	else
		return speed;
}

bool PF_Teleport(ffc temp, ffc this)
{
	int type = temp->InitD[3];
	int newX = temp->InitD[4];
	int newY = temp->InitD[5];
	int width = this->TileWidth;
	int height = this->TileHeight;
	int teletime = 120; //time to teleport in frames.
	bool effect = temp->InitD[6];
	
	//2, Move platform and Link.
	if(type == 2)
	{
		PF_TeleEffect(this, newX, newY, width, height, 7, effect, true);
		if((Link->X+8 >= this->X && Link->X+8 <= this->X + this->EffectWidth) && (Link->Y+12 >= this->Y && Link->Y+12 <= this->Y + this->EffectHeight))
		{
			Link->X = newX + (this->X - Link->X);
			Link->Y = newY + (this->Y - Link->Y);
		}
		this->X = newX;
		this->Y = newY;
		return false;
	}
	//1, Move platform.
	else if(type == 1)
	{
		PF_TeleEffect(this, newX, newY, width, height, 8, effect, false);
		this->X = newX;
		this->Y = newY;
		return false;
	}
	//0, No teleport return
	else
		return true;
}

void PF_TeleEffect(ffc this, int newX, int newY, int width, int height, int color, bool effect, bool movelink)
{
	int t1;
	if(movelink)
		Link->CollDetection = false;
	if(effect)
	{
		Game->PlaySound(TELESOUND);
		for(t1 = TELETIME; t1 > 0; t1--)
		{
			if(effect)
			{
				Screen->DrawCombo(TELELAYER, this->X, this->Y, TELECOMBO, width, height, color, -1, -1, 0, 0, 0, 1, 0, true, OP_TRANS);
				Screen->DrawCombo(TELELAYER, newX, newY, TELECOMBO, width, height, color, -1, -1, 0, 0, 0, 1, 0, true, OP_TRANS);
			}
			if(movelink)
				WaitNoAction();
			else
				Waitframe();
		}
	}
	if(movelink)
		Link->CollDetection = true;
}

float PF_Move(ffc this, int direction, float speed, float accel, float rate)
{
	//Move Platform.
	if(direction == DIR_UP)
		this->Y -= speed;
	else if(direction == DIR_DOWN)
		this->Y += speed;
	else if(direction == DIR_LEFT)
		this->X -= speed;
	else
		this->X += speed;
		
	//Move Link.
	if((Link->X+8 >= this->X && Link->X+8 <= this->X + this->EffectWidth) && (Link->Y+12 >= this->Y && Link->Y+12 <= this->Y + this->EffectHeight) && Link->Z <= 0)
	{
		moveLink(direction, Floor(speed+accel), true, true);
		return rate;
	}
	else
		return 0;
}

//=======================================Shutter Doors============================================
//D0 side of screen the door is located on. Use directions from std_constants.
//D1 Link's Pos in pixels before Door will close. Link will be moved a further 16px first then the door will shut.
//D2-3 Combo location on the screen. use -1 if combo is not used.
//D4-5 Combo used for shutter door. use -1 if combo is not used.
//D6 Extra pixels to move Link. When the Door shuts Link is moved 16px first then this value.
//D7 Secrets will open this door. 0 will open. 1 will not open. !!REMINDER: standard secret combo setup is still required!!
ffc script shutterdoor{
	void run(int Side, int Distance, int Door1_L, int Door2_L, int Door1_C, int Door2_C, int ExtraDis, int Perm){
		Waitframe(); //Wait one frame to let the screen load.
		
		while(!Screen->State[ST_SECRET] || Perm == 1){
			if(Side == 0){ //Up
				if(CenterLinkY() > Distance){
					for(int a = CenterLinkY(); a < Distance + 16 + ExtraDis; a++){
						moveLink(DIR_DOWN, 1, true, true);
						WaitNoAction();
					}//end for
					if(Door1_L > -1) SetLayerComboD(0, Door1_L, Door1_C);
					if(Door2_L > -1) SetLayerComboD(0, Door2_L, Door2_C);
					Game->PlaySound(77);
					PF_stored = false;
					Quit(); //Unload FFC
				}//end if
			}//end if
			else if(Side == 1){ //Down
				if(CenterLinkY() < Distance){
					for(int a = CenterLinkY(); a > Distance - 16 - ExtraDis; a--){
						moveLink(DIR_UP, 1, true, true);
						WaitNoAction();
					}//end for
					if(Door1_L > -1) SetLayerComboD(0, Door1_L, Door1_C);
					if(Door2_L > -1) SetLayerComboD(0, Door2_L, Door2_C);
					Game->PlaySound(77);
					PF_stored = false;
					Quit(); //Unload FFC
				}//end if
			}//end else if
			else if(Side == 2){ //Left
				if(CenterLinkX() > Distance){
					for(int a = CenterLinkX(); a < Distance + 16 + ExtraDis; a++){
						moveLink(DIR_RIGHT, 1, true, true);
						WaitNoAction();
					}//end for
					if(Door1_L > -1) SetLayerComboD(0, Door1_L, Door1_C);
					if(Door2_L > -1) SetLayerComboD(0, Door2_L, Door2_C);
					Game->PlaySound(77);
					PF_stored = false;
					Quit(); //Unload FFC
				}//end if
			}//end else if
			else if(Side == 3){ //Right
				if(CenterLinkX() < Distance){
					for(int a = CenterLinkX(); a > Distance - 16 - ExtraDis; a--){
						moveLink(DIR_LEFT, 1, true, true);
						WaitNoAction();
					}//end for
					if(Door1_L > -1) SetLayerComboD(0, Door1_L, Door1_C);
					if(Door2_L > -1) SetLayerComboD(0, Door2_L, Door2_C);
					Game->PlaySound(77);
					PF_stored = false;
					Quit(); //Unload FFC
				}//end if
			}//end else if
			Waitframe();
		}//end while
	
	}
}