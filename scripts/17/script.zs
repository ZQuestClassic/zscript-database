// This script is a pickup script that will give some items.
// This was mostly made to bundle the Bow and Arrows into one item,
// but it could have other uses.
// Bundle this with an item that increases a counter to also increase counters.
// 		D0-D7: Items to give.
//		D0: If D0 is negative, it will display an item pickup message containing the positive version of the number entered...
item script itemBundle{
	void run(int item1, int item2, int item3, int item4, int item5, int item6, int item7, int item8)
	{
		if(item1 > 0)
			Link->Item[item1] = true;
		if(item2 > 0)
			Link->Item[item2] = true;
		if(item3 > 0)
			Link->Item[item3] = true;
		if(item4 > 0)
			Link->Item[item4] = true;
		if(item5 > 0)
			Link->Item[item5] = true;
		if(item6 > 0)
			Link->Item[item6] = true;
		if(item7 > 0)
			Link->Item[item7] = true;
		if(item8 > 0)
			Link->Item[item8] = true;
			
		// Display Item pickup message?
		if(item1 < 0)
		{
			Screen->Message(item1 * -1);
		}
	}//!End void run()
}//!End item script itemBundle