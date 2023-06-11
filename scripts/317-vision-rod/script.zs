//Only put this in your script once
import "std.zh"

//Put these variables outside your global script and adjust for your quest
const int I_VISIONSTAFF = 146;	//Set this to the item ID of a custom itemclass equipment item
const int VISION_COMBO = 1000;	//Set this to the combo ID of the combo you want to appear above secrets
const int VISION_CSET = 8;		//CSet for the combo
const int VISION_MPCOST = 10;	//MP cost
const int VISION_LAYER = 7;		//Layer where to put the combo. 7 is over everything
const int VISION_INTERVAL = 60;	//Frames between MP cost. 60 frames = 1 second.
const int VISION_SFX = 32;		//Sound effect to play while the item is working
const int VISION_FAIL = 11;		//Sound effect to play if you don't have enough MP

global script visionstaff
{
	void run()
	{
		bool visionactive = false;
		int visiontimer = 0;
		int visionflags[] = {CF_BOMB, CF_CANDLE1};	//Combo flag IDs to check for. Use CF_ in std_constants

		while(true)
		{
		
			//Vision Staff
			if((GetEquipmentB() == I_VISIONSTAFF && Link->PressB && Link->MP < VISION_MPCOST) ||
			   (GetEquipmentA() == I_VISIONSTAFF && Link->PressA && Link->MP < VISION_MPCOST))
					Game->PlaySound(VISION_FAIL); //Sound if you don't have enough MP
		
			if((GetEquipmentB() == I_VISIONSTAFF && Link->InputB && Link->MP >= VISION_MPCOST) ||
			   (GetEquipmentA() == I_VISIONSTAFF && Link->InputA && Link->MP >= VISION_MPCOST))	
			{
				visionactive = true;
				for(int i = 0; i < 176; i++)
				{
					for(int j = 0; j <= SizeOfArray(visionflags); j++)
					{
						if(Screen->ComboF[i] == visionflags[j] || Screen->ComboI[i] == visionflags[j])	//Check for flags
						{
							Screen->FastCombo(7, ComboX(i), ComboY(i), VISION_COMBO, VISION_CSET, OP_TRANS);	//Draw the combo
						}
					}
				}
			}

			//Timers & Sound
			if((visionactive && Link->InputB) || (visionactive && Link->InputA))
			{
				visiontimer--;
				if(visiontimer <= 0)
				{
					if(Link->MP >= VISION_MPCOST)
					{
						Link->MP -= VISION_MPCOST;
						visiontimer = VISION_INTERVAL;
						Game->PlaySound(VISION_SFX);
					}
					else
					{
						Game->PlaySound(VISION_FAIL);
						visionactive = false;
						visiontimer = 0;
					}
				}
			}
			
			//If you let go of the button the counters reset
			if(visionactive && !UsingItem(I_VISIONSTAFF))
			{
				visionactive = false;
				visiontimer = 0;
			}
		
			//If you switch items the counters reset
			if(visionactive && GetEquipmentB() != I_VISIONSTAFF && GetEquipmentA() != I_VISIONSTAFF)
			{
				visionactive = false;
				visiontimer = 0;
			}
		
		Waitframe();
		}
	}
}