const int FONT_DONATION = 0; //Font used for drawing donation values.
const int SFX_DONATION = 0;//Sound to play on successful donation.

//Modern Donation Shop. Stand on FFC and press either EX1 to perform donation. Donate target total for reward.

//Place FFC at trigger position.
//D0 - Screen D to keep track charity progress.
//D1 - Counter to be used by this charity organization. For blood donations, minimum of 1 full heart should left upon donation.
//D2 - Target total for this charity campaign.
//D3 - Max counter amount transferred per button press.
//D4 - Reward. >0 - Award item ID, -1 - Secret trigger.
//D5 - #####.____ - String to display, when charity progress is 0.
//     _____.#### - String to display, when charity campaign is completed.
//D6 - Combo position to render charity progress.
//D7 - Combo used to render counter image.

ffc script DonationShop2{
	void run (int ScreenD, int counter, int capacity, int step, int reward,int str, int drawpos, int cmb){
		int cooldown = 0;
		int mincounter = 0;
		int intromsg = GetHighFloat(str);
		int endmsg = GetLowFloat(str);
		if (counter == CR_LIFE) mincounter += 16;
		if (intromsg>0 && Screen->D[ScreenD]==0)Screen->Message(intromsg);
		while(true){
			if (RectCollision(Link->X+7, Link->Y+7, Link->X+8, Link->Y+8, this->X, this->Y, this->X+this->EffectWidth-1, this->Y+this->EffectHeight-1)){
				if (Screen->D[ScreenD]<capacity){
					int min = 0;
					if (counter == CR_LIFE) min = 16;
					if (((Game->Counter[counter]+Game->DCounter[counter])>min)&&Link->PressEx1){
						int dep = step;
						if ((Game->Counter[counter]+Game->DCounter[counter])<(min+step))dep = Game->Counter[counter]+Game->DCounter[counter] - min;
						if ((capacity - Screen->D[ScreenD])<dep) dep = capacity - Screen->D[ScreenD];
						Game->PlaySound(SFX_DONATION);
						if (counter==CR_LIFE)Game->PlaySound(SFX_OUCH);
						Game->DCounter[counter] -= dep;
						Screen->D[ScreenD] += dep;
						if (Screen->D[ScreenD]==capacity){
							if (reward!=0){
								Screen->Message(endmsg);
								if (reward<0 && !Screen->State[ST_SECRET]){
									
									Game->PlaySound(SFX_SECRET);
									Screen->TriggerSecrets();
									Screen->State[ST_SECRET]=true;
								}
								if (reward>0 && !Screen->State[ST_SPECIALITEM]){
									Game->PlaySound(SFX_SECRET);
									item it = CreateItemAt(reward, Link->X, Link->Y);
									it->Pickup = 0x802;
								}
							}
						}
					}
				}
			}
			int drawx = ComboX(drawpos);
			int drawy = ComboY(drawpos);
			Screen->FastCombo(2, drawx, drawy, cmb, this->CSet, OP_OPAQUE);
			drawx+=16;
			drawy+=8;
			Screen->DrawInteger(2, drawx, drawy,FONT_DONATION, 1, 0, -1, -1, Screen->D[ScreenD], 0, OP_OPAQUE);
			int stra[]="/";
			drawx+=40;
			Screen->DrawString(2, drawx, drawy, FONT_DONATION, 1,0,  0, stra,OP_OPAQUE);
			drawx+=8;
			Screen->DrawInteger(2, drawx, drawy,FONT_DONATION, 1, 0, -1, -1, capacity, 0, OP_OPAQUE);
			Waitframe();
		}
	}
}