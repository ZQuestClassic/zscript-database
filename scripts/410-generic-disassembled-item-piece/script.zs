//Generic Disassembled item piece. Link must collect enough items to assemble whole item. 2.53.x
//1. Set aside 1 screen in a DMap, like unused space in a dungeon. You need 1 such screen per 8 disassembled items.
//2. Set up as many consecutive strings to track item assembly progress, like 1/4, 2/4, 3/4 etc.
//3. Create item in Item editor, assign script into Pickup script slot.
// D0 - Item to assemble.
// D1 - Number of pieces to form whole item.
// D2 - First string of the sequence from step 2.
// D3 - Dmap from step 1, needed to track item assembly progress.
// D4 - Dmap Screen from step 1, needed to track item assembly progress.
// D5 - Dmap Screen D register from step 1, needed to track item assembly progress.

item script ItemPiece{
	void run (int Item, int Numpieces, int string, int DMapD, int ScreenD, int ScreenDReg){
		int D = Game->GetDMapScreenD(DMapD, ScreenD, ScreenDReg);
		if (string>0) Screen->Message(string+D);
		D++;
		if (D >= Numpieces){
			item coll = Screen->CreateItem(Item);
			coll->X = Link->X;
			coll->Y = Link->Y;
			D = 0;
		}
		Game->SetDMapScreenD(DMapD, ScreenD, ScreenDReg, D);
	}
}