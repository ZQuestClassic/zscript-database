//Tiered secrets, depending on Triforce piece count.
//D0 - ScreenD to use.
//D1 - String to display, when no triforces, or first time entered.
ffc script TierEntranceTriforce{
	void run(int d, int str){
		if (Screen->D[d]==0){
			Screen->Message(str);
			Quit();
		}
		for (int i=1;i<=NumTriforcePieces();i++){
			Screen->TriggerSecrets();
		}
		if (Screen->D[d]<NumTriforcePieces()){
			Game->PlaySound(SFX_SECRET);
			Screen->D[d]=NumTriforcePieces();
		}
	}
}

//Checks items with the given list and triggers tiered secrets for each one in the list.
//D0 - ScreenD to use.
//D1 - String to display, when no items, or first time entered.
//D2-D7 - Item ID list (6 items).  Multiply by -1 to remove item from Link`s inventory on trigger.
ffc script TierEntranceItems{
	void run(int d, int str, int i1, int i2, int i3, int i4, int i5, int i6){
		int items[6] = {i1,i2,i3,i4,i5,i6};
		if (Screen->D[d]==0)Screen->Message(str);
		int count = 0;
		int thrshold = 0;
		for (int i=0;i<6;i++){
			thrshold = Abs(items[i]);
			if (Screen->D[d]<i)continue;
			if (items[i]==0)continue;
			if (!Link->Item[thrshold]) continue;
			if (items[i]<0)Link->Item[thrshold]=false;
			count++;
		}
		if (Screen->D[d]<count){
			Game->PlaySound(SFX_SECRET);
			Screen->D[d]=count;
		}
		if (Screen->D[d]==0)Quit();
		for (int i=1; i<=Screen->D[d];i++){
			Screen->TriggerSecrets();
		}
	}
}

// Counter-driven Tiered entrance trigger
//D0 - Screen D tu use
//D1 - String to display, when no new counter thresholds achieved..
//D2 - Counter to use.
//D3-D7 - Thresholds. Like 3, then 5, then 10 etc to trigger. Multiply by -1 to subtract target value from counter on trigger.
ffc script TierEntranceCounter{
	void run(int d, int str, int counter, int i1, int i2, int i3, int i4, int i5){
		int items[5] = {i1,i2,i3,i4,i5};
		if (Screen->D[d]==0)Screen->Message(str);
		int count = 0;
		int thrshold = 0;
		for (int i=0;i<5;i++){
			thrshold = Abs(items[i]);
			if (Screen->D[d]<i)continue;
			if (Game->Counter[counter]<thrshold) continue;
			if (items[i]<0)Game->DCounter[counter]-=thrshold;
			count++;
		}
		if (Screen->D[d]<count){
			Game->PlaySound(SFX_SECRET);
			Screen->D[d]=count;
		}
		if (Screen->D[d]==0)Quit();
		for (int i=1; i<=Screen->D[d];i++){
			Screen->TriggerSecrets();
		}
	}
}