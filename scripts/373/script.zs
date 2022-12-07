//Changes Armor and Sowrd Equipment (Sword Levels should be 5-7 or higher).
//No need to enable "Can select A-Button Items" Rule to use different swords, available whenever you want.
//Not more than 2 Items of this (max)4-Item-SetUp may use "GoldenForce2", to guarant accurate "downleveling effects".
//Create LttP Amulets, OoT Spiritual ore selectable Triforce Fragments and assign 1 of these scripts in the active slot.
//"GoldenForce1" can add 2 variable items (Sword 5-6 + related Armor/Ring you decided to use) and remove a max of 6 items (added by the other GoldenForce Items).
//"GoldenForce2" can add 3 variable items (Sword 6-7 + Armor/Ring 3rd variable item) and remove a max of 5 items (while there is no need to remove Sword and Armor items, if used to add the highest level Sword/Armor).
//The 3rd addable Item, of "GoldenSwords2" is meant to gain an invisible/unused item to your inventory. I used it to add the Charge Ring L2 as long as I use the "Triforce of Wisdom Status" (GoldenForce2)
//The PureMasterBlade Script is meant to restore the "original" status of your hero (free of triforce powers).

const int GOLDEN_SOUND = 179; //SFX, played when activating a Triforce (Golden Force)  item effect.

//D0   = Item ID of the Sword, gained to inventory.
//D1   = Item ID of the Armor/Ring, gained to your inventory.
//D2-7 = Items to Remove 
//Take care to remove ALL items, possibly added with the other GoldenForce1/2 scripted Items. Also the variable 3rd Items of GoldenForce2.

item script GoldenForce1
{
	void run(int item1, int item2, int item3, int item4, int item5, int item6, int item7, int item8)
	{
		Link->Item[item1] = true;
		Link->Item[item2] = true;
		Game->PlaySound(GOLDEN_SOUND);
		Link->Item[item3] = false;
		Link->Item[item4] = false;
		Link->Item[item5] = false;
		Link->Item[item6] = false;
		Link->Item[item7] = false;
		Link->Item[item8] = false;
	}
}


//D0   = Item ID of the Sword, gained to inventory.
//D1   = Item ID of the Armor/Ring, gained to your inventory.
//D2-7 = Items to Remove 
//If used to add the strongest Sword + Armor, there's no need to remove lower level Swords * Armor.
//Always take care to remove variable items, possibly added with other GoldenForce2 Items. 


item script GoldenForce2
{
	void run(int item1, int item2, int item3, int item4, int item5, int item6, int item7, int item8)
	{
		Link->Item[item1] = true;
		Link->Item[item2] = true;
		Link->Item[item3] = true;
		Game->PlaySound(GOLDEN_SOUND);
		Link->Item[item3] = false;
		Link->Item[item4] = false;
		Link->Item[item5] = false;
		Link->Item[item6] = false;
		Link->Item[item7] = false;
		Link->Item[item8] = false;	
	}
}


//PureMasterBlade will remove all items, gained by GoldenForce1/2 and restore the orignial status of your hero.
//D0-7 = Items to Remove

item script PureMasterBlade
{
	void run (int item1, int item2, int item3, int item4, int item5, int item6, int item7, int item8)
	{
		Link->Item[item1] = false;
		Link->Item[item2] = false;
		Link->Item[item3] = false;
		Link->Item[item4] = false;
		Link->Item[item5] = false;
		Link->Item[item6] = false;
		Link->Item[item7] = false;
		Link->Item[item8] = false;
		Game->PlaySound(GOLDEN_SOUND);
	}
}