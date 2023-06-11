import "std.zh"

const int LIGHT_FLAG = 98;
const int BLACK_COLOR = 15;
const int DARK_ROOM_SLOT = 1;
bool ActiveLastFrame = false;
int LightX[200];
int LightY[200];
int LightSize[200];
bool LightPerm[200];

global script Slot2
{
	void run()
	{
		bool HelloDarknessMyOldFriend = false;
		while(true)
		{
			DarkRoomGlobal(HelloDarknessMyOldFriend);
			Waitframe();
		}
	}
}

void DarkRoomGlobal(bool HelloDarknessMyOldFriend)
{
	bool OkayFoundOne = false;
	if (HelloDarknessMyOldFriend == true)
	{
		if (Link->Action == LA_SCROLLING) 
		{
			Screen->Rectangle(6, 0, 0, 256, 176, BLACK_COLOR, 1, 0, 0, 0, true, OP_OPAQUE);
		}
		else HelloDarknessMyOldFriend = false;
	}
	for (int h = 1; h <= 32; h++)
	{
		ffc DarkMaybe = Screen->LoadFFC(h);
		if (DarkMaybe->Script == DARK_ROOM_SLOT)
		{
			if (Link->Action == LA_SCROLLING) 
			{
				Screen->Rectangle(6, 0, 0, 256, 176, 15, 1, 0, 0, 0, true, OP_OPAQUE);
			}
			OkayFoundOne = true;
		}
	}
	if (OkayFoundOne == false && ActiveLastFrame == true) 
	{
		HelloDarknessMyOldFriend = true;
	}
	ActiveLastFrame = false;
}
 
ffc script DarkRoom
{
	void run(int LinkSize, int FlagSize, int LinkWeaponSize, int EnemyWeaponSize, int Expand, int Expanding, int CandleID)
	{
		int Expander = 0;
		int Expandest = 0;
		bool Expandirect = true;
		if (LinkSize == 0) LinkSize = 48;
		if (FlagSize == 0) FlagSize = 48;
		if (LinkWeaponSize == 0) LinkWeaponSize = 48;
		if (EnemyWeaponSize == 0) EnemyWeaponSize = 48;
		while(true)
		{
			if (Expand > 0)
			{
				if (Expanding > 0) Expander+=Expanding;
				else Expander+=2;
				if (Expander >= 20)
				{
					Expander = 0;
					if (Expandirect) Expandest++;
					else Expandest--;
					if (Expandest >= Expand) Expandirect = false;
					else if (Expandest <= 0) Expandirect = true;
				}
			}
			Screen->SetRenderTarget(RT_BITMAP0);
			Screen->Rectangle(6, 0, 0, 256, 176, 15, 1, 0, 0, 0, true, OP_OPAQUE);
			if (LinkSize >= 0 && (CandleID == 0 || (CandleID < 0 && Link->Item[Abs(CandleID)] == true) || (CandleID > 0 && (GetEquipmentA() == CandleID || GetEquipmentB() == CandleID)))) Screen->Circle(6, Link->X + 8, Link->Y + 8, LinkSize + Expandest, 0, 1, 0, 0, 0, true, OP_OPAQUE);
			
			if (FlagSize >= 0) 
			{
				for(int i = 0; i < 176; i++)
				{
					if (Screen->ComboF[i] == LIGHT_FLAG || Screen->ComboI[i] == LIGHT_FLAG)
					{
						Screen->Circle(6, ComboX(i) + 8, ComboY(i) + 8, FlagSize + Expandest, 0, 1, 0, 0, 0, true, OP_OPAQUE);
					}
				}
			}
			if (LinkWeaponSize >= 0)
			{
				for(int l = Screen->NumLWeapons(); l > 0; l--)
				{
					lweapon MLG = Screen->LoadLWeapon(l);
					if (MLG->ID == LW_FIRE || LW_REFFIREBALL || LW_FIRESPARKLE)
					{
						Screen->Circle(6, MLG->X + 8, MLG->Y + 8, LinkWeaponSize + Expandest, 0, 1, 0, 0, 0, true, OP_OPAQUE);
					}
				}
			}
			if (EnemyWeaponSize >= 0)
			{
				for(int j = Screen->NumEWeapons(); j > 0; j--)
				{
					eweapon GLG = Screen->LoadEWeapon(j);
					if (GLG->ID == EW_FIRE || EW_FIREBALL || EW_FIREBALL2 || EW_FIRE2 || EW_FIRETRAIL)
					{
						Screen->Circle(6, GLG->X + 8, GLG->Y + 8, EnemyWeaponSize + Expandest, 0, 1, 0, 0, 0, true, OP_OPAQUE);
					}
				}
			}
			Screen->SetRenderTarget(RT_SCREEN);
			Screen->DrawBitmap(6, RT_BITMAP0, 0, 0, 256, 176, 0, 0, 256, 176, 0, true);
			ActiveLastFrame = true;
			Waitframe();
		}
	}
}