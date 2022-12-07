//Bottle Scripts
//by FlounderMAJ

import "std.zh"

//This is a script for empty bottles!
//D0 is the item number for the pickup potion/bottle item, D1, D2, D3 and D4 are 
//the item numbers for each potion or other bottle item.
//The four Bottle variables in the script are the item numbers of your bottles.
//These will always be the same for your quest.
//D5 is a pickup string, and D6 is a String stating there are no empty bottles.
//D7 is the amount of Rupees to return to Link if there is no empty bottle available.
//For this script to work, Each bottle must be a separate item in a separate custom item class,
//and EACH potion type will have an item for EACH bottle, in the custom item class mathing the respective bottle.
//For 4 Bottles and 4 types of potions/bottle items, this requires 20 custom items in 4 custom item classes.
//This script should be slotted as a pickup script for the built-in potion type items.


//Use this table to organize the D0-D7 needed to set up each item.
//+------------+--------+------------+-------------+--------------+---------------+----------+
//| Item class | Bottle | Red Potion | Blue Potion | Green Potion | Purple Potion | Variable |
//+------------+--------+------------+-------------+--------------+---------------+----------+
//| Potions (for pickup)|     29     |     30      |     125      |    126        |   D0     |
//| Custom 1   |  127   |    129     |    135      |     139      |     63        |   D1     |
//| Custom 2   |  128   |    130     |    136      |     140      |     55        |   D2     |
//| Custom 3   |  131   |    133     |    137      |     141      |    121        |   D3     | 
//| Custom 4   |  132   |    134     |    138      |      50      |    120        |   D4     |
//|   Pickup String     |     10     |     11      |      12      |     13        |   D5     |
//|  No Bottle String   |     14     |     14      |      14      |     14        |   D6     |
//|  Rupees to return   |     40     |    160      |      40      |     60        |   D7     |
//+---------------------+------------+-------------+--------------+---------------+----------+

item script emptybottle
{
	void run(int pickup, int potion1, int potion2, int potion3, int potion4, int string1, int string2, int rupees)
	{
		int bottle1=127;
		int bottle2=128;
		int bottle3=131;
		int bottle4=132;

		Link->Item[pickup]=false;

		if (Link->Item[bottle1])
		{
			
			Link->Item[potion1]=true;
			Link->Item[bottle1]=false;
			Screen->Message(string1);
		}
		else if (Link->Item[bottle2])
		{
			Link->Item[potion2]=true;
			Link->Item[bottle2]=false;
			Screen->Message(string1);
		}
		else if (Link->Item[bottle3])
		{
			Link->Item[potion3]=true;
			Link->Item[bottle3]=false;
			Screen->Message(string1);
		}
		else if (Link->Item[bottle4])
		{
			Link->Item[potion4]=true;
			Link->Item[bottle4]=false;
			Screen->Message(string1);
		}
		else
		{
			Game->MCounter[CR_RUPEES]+=rupees; //This line will increase your maximum wallet cap to make sure you get all the rupees
			                                   //that should be returned to you if you attempt to buy a potion without an empty bottle
											   //and if your wallet is full.
											   //Use the FFC script "WalletReset" on the screen outside your shop to reset the cap to 
											   //what it should be.
			Game->Counter[CR_RUPEES]+=rupees;
			Game->PlaySound(69);
			Screen->Message(string2);

			
		}	
			
	}
}




//This Script is for the bottle potions.
//D0 is the item number of the potion you are using, D1-D4 are the items corresponding to the 4 potion types.
//D5 is the corresponding empty bottle for that potion set, and D6 is a string that is displayed when 
//Link tries to use an empty bottle.  D7 is a sound effect to play.
//The item numbers should be listed in the table above.
//This script should be slotted as the action script for each bottle item, including the empty bottle.


item script potions
{
	void run(int PotionUsed, int Red, int Blue, int Green, int Purple, int Bottle, int String, int sfx)
	{
		Link->Item[29]=false;    //These lines remove any pickup potions Link has, 
		Link->Item[30]=false;    //see table above and change item numbers to match
		Link->Item[125]=false;
		Link->Item[126]=false;

		Link->Item[Bottle]=true;
		Game->PlaySound(sfx);		

		if (PotionUsed==Red)
		{
			Link->HP=Link->MaxHP;
			Link->Item[PotionUsed]=false;			
		}

		if (PotionUsed==Blue)
		{
			Link->HP=Link->MaxHP;
			Link->MP=Link->MaxMP;
			Link->Item[PotionUsed]=false;		
		}

		if (PotionUsed==Green)
		{
			Link->MP=Link->MaxMP;
			Link->Item[PotionUsed]=false;		
		}

		if (PotionUsed==Purple)
		{
			if (Link->MaxHP<129)
			{
				Link->HP=Link->MaxHP;
				Link->Item[PotionUsed]=false;			
			}

			else
			{
				Link->HP=Link->HP+128;
				Link->Item[PotionUsed]=false;		
			}
		}
		
		if (PotionUsed==Bottle)
		{
			Screen->Message(String);
		}
	}
		
}

//This Global script is designed to work with the purple potion, and to automatically restore 4 hearts of health to Link 
//if his health drops to 0.  May be used to implement bottle fairies also.  the Item numbers used should match the table 
//above, and the sound effect and amount of health restored can be adjusted as well. Paste the contents of the while(true)
//loop into your own loop on your own custom global script if you want to.  Remember to copy the variable declarations also. 

global script BottlesGlobal
{


	void run()
	{
		int purple1=63;
		int purple2=55;
		int purple3=121;
		int purple4=120;
		
		int bottle1=127;
		int bottle2=128;
		int bottle3=131;
		int bottle4=132;
		
		int sfx=25;
		int RestoreAmt=64;
		
		while (true)
		{
			if (Link->HP==0)
			{
				if (Link->Item[purple1])
				{
					Link->Item[bottle1]=true;
					Link->Item[purple1]=false;
					Game->PlaySound(sfx);
					if (Link->MaxHP<(RestoreAmt-1))
					{
						Link->HP=Link->MaxHP;
					}

					else
					{
						Link->HP=Link->HP+RestoreAmt;
					}
				}

				else if (Link->Item[purple2])
				{
					Link->Item[bottle2]=true;
					Link->Item[purple2]=false;
					Game->PlaySound(sfx);
					if (Link->MaxHP<(RestoreAmt-1))
					{
						Link->HP=Link->MaxHP;
					}

					else
					{
						Link->HP=Link->HP+RestoreAmt;
					}
				}	
			
				else if (Link->Item[purple3])
				{
					Link->Item[bottle3]=true;
					Link->Item[purple3]=false;
					Game->PlaySound(sfx);
					if (Link->MaxHP<(RestoreAmt-1))
					{
						Link->HP=Link->MaxHP;
					}

					else
					{
						Link->HP=Link->HP+RestoreAmt;
					}
				}
				else if (Link->Item[purple4])
				{
					Link->Item[bottle4]=true;
					Link->Item[purple4]=false;
					Game->PlaySound(sfx);
					if (Link->MaxHP<(RestoreAmt-1))
					{
						Link->HP=Link->MaxHP;
					}

					else
					{
						Link->HP=Link->HP+RestoreAmt;
					}
				}									
			}	

			Waitframe();
		}
	}
}

//Place this FFC script on the screen just outside of your potion shop and change the constants to match the Large wallet, 
//Medium Wallet, and default rupee capacity for your quest.  D0 and D1 are the item numbers for your Large and Medium Wallet, 
//respectively. This will reset the wallet capacity that is adjusted if you try to buy a potion without an empty bottle and a
//full wallet.
	const int LWMax=1000;
	const int MWMax=500;
	const int DefaultMax=100;

ffc script WalletReset 
{
	

	void run(int LWallet, int MWallet)
	{
		if (Link->Item[LWallet]) Game->MCounter[CR_RUPEES]=LWMax;
		else if (Link->Item[MWallet]) Game->MCounter[CR_RUPEES]=MWMax;
		else Game->MCounter[CR_RUPEES]=DefaultMax;
	}
}