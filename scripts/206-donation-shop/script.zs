const int FONT_DONATION = 0; //Font used for drawing donation values.
const int COOLDOWN_BETWEEN_PLEDGES = 60; //Cooldown between donations. Set to -1 to render consequtive donations impossible without exiting and reentering the screen.
const int SFX_DONATION = 25;//Sound to play on successful donation.

ffc script DonationShop{
	void run (int screenD, int counter, int target, int pledge, int reward,int string_offer , int string_on_donation, int string_on_target){
		int cooldown = 0;
		int mincounter = 0;
		if (counter == CR_LIFE) mincounter += 16;
		if (Screen->D[screenD]>=target){
			if (string_on_target>0)Screen->Message(string_on_target);
			this->Data = 0;
			Quit();
		}
		if (string_offer>0)Screen->Message(string_offer);
		while(true){
			if (cooldown>0)cooldown--;
			int cost = pledge; //This variable will be drawn onto screen.
			if (counter == CR_LIFE) cost /= 16; //Blood donation will be displayed measured in full hearts
			if (counter == CR_MAGIC) cost /= 32; //Ditto for magic. Measured in full beakers.
			int numdcm = 0; //
			if ((counter == CR_LIFE)&&((pledge%16)>0)) numdcm=2;//Show partial amounts if needed.
			if ((counter == CR_MAGIC)&&((pledge%32)>0)) numdcm=2;//
			Screen->DrawInteger(0, ((this->X)+16), ((this->Y)+4),FONT_DONATION ,1,-1, 0, 0, cost, numdcm, OP_OPAQUE);
			if ((LinkCollision(this))&&(cooldown==0)&&(Link->PressA)){
				if (Game->Counter[counter]>=(mincounter+pledge)){
					Game->PlaySound(SFX_DONATION);
					if (counter == CR_LIFE){ //No one likes blood donations. :-(
						Game->PlaySound(SFX_OUCH);
						Link->HitDir = OppositeDir(Link->Dir);
						if (Link->Action==LA_SWIMMING) Link->Action=LA_GOTHURTWATER;
						else Link->Action = LA_GOTHURTLAND;
					}
					if ((counter == CR_LIFE)||(counter == CR_MAGIC)) Game->Counter[counter]-=pledge;
					else Game->DCounter[counter] -= pledge;
					Screen->D[screenD]+=pledge;
					if (string_on_donation>0)Screen->Message(string_on_donation);
					Waitframe();
					if (Screen->D[screenD]>=target){
						if (string_on_target>0)Screen->Message(string_on_target);
						Waitframe();
						if (reward>0){
							Game->PlaySound(SFX_PICKUP);
							if (Link->Action==LA_SWIMMING)Link->Action==LA_HOLD2WATER;
							else Link->Action = LA_HOLD2LAND;
							Link->HeldItem=reward;
							Link->Item[reward]= true;
						}
						else if (reward == -1){
							Game->PlaySound(SFX_SECRET);
							Screen->TriggerSecrets();
							Screen->State[ST_SECRET]=true;
						}
						this->Data = 0;
						Quit();
					}
					cooldown= COOLDOWN_BETWEEN_PLEDGES;
				}
			}
			Waitframe();
		}
	}
}