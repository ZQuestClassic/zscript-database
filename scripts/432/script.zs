const int SFX_BANK_DEPOSIT = 0;//Sound to play on bank deposit.
const int SFX_BANK_WITHDRAW = 0;//Sound to play on bank withdraw.

const int FONT_BANK_RENDER_ACCOUNT = 0;//Font used to render bank account details

//Counter Bank. Stand on FFC and press either EX1 to deposit counter, or EX2 to withdraw previously deposited. Bank safe has limited capacity
//and triggers reward, if filled.

//Place FFC at trigger position.
//D0 - Screen D to keep track balance on bank account.
//D1 - Counter to be used by this bank. For blood donations, minimum of 1 full heart should left upon deposit.
//D2 - Max counter amount transferred per button press.
//D3 - String to display when bank account is either empty of full. Insert user manual here.
//D4 - Bank account limit. If filled, reward triggers.
//D5 - Reward. >0 - Award item ID, -1 - Secret trigger.
//D6 - Combo position to render bank account balance.
//D7 - Combo used to render counter image.

ffc script Bank{
	void run (int ScreenD, int counter, int step, int string, int capacity, int reward, int drawpos, int cmb){
		if (Screen->D[ScreenD]==0 || Screen->D[ScreenD]==capacity) Screen->Message(string);
		while(true){
			if (RectCollision(Link->X+7, Link->Y+7, Link->X+8, Link->Y+8, this->X, this->Y, this->X+this->EffectWidth-1, this->Y+this->EffectHeight-1)){
				if (Screen->D[ScreenD]<capacity){
					int min = 0;
					if (counter == CR_LIFE) min = 16;
					if (((Game->Counter[counter]+Game->DCounter[counter])>min)&&Link->PressEx1){
						int dep = step;
						if ((Game->Counter[counter]+Game->DCounter[counter])<(min+step))dep = Game->Counter[counter]+Game->DCounter[counter] - min;
						if ((capacity - Screen->D[ScreenD])<dep) dep = capacity - Screen->D[ScreenD];
						Game->PlaySound(SFX_BANK_DEPOSIT);
						if (counter==CR_LIFE)Game->PlaySound(SFX_OUCH);
						Game->DCounter[counter] -= dep;
						Screen->D[ScreenD] += dep;
						if (Screen->D[ScreenD]==capacity){
							if (reward!=0){
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
			if (Screen->D[ScreenD]>0){
				if ((Game->Counter[counter]+Game->DCounter[counter])< Game->MCounter[counter]){
					if (Link->PressEx2){
						int dep = step;
						if (Screen->D[ScreenD]<step) dep = Screen->D[ScreenD];
						if ((Game->MCounter[counter]-Game->Counter[counter]-Game->DCounter[counter])<dep) dep = Game->MCounter[counter]-Game->Counter[counter]-Game->DCounter[counter];
						Game->PlaySound(SFX_BANK_WITHDRAW);
						Game->DCounter[counter] +=dep;
						Screen->D[ScreenD] -=dep;
					}
				}
			}
			int drawx = ComboX(drawpos);
			int drawy = ComboY(drawpos);
			Screen->FastCombo(2, drawx, drawy, cmb, this->CSet, OP_OPAQUE);
			drawx+=16;
			drawy+=8;
			Screen->DrawInteger(2, drawx, drawy,FONT_BANK_RENDER_ACCOUNT, 1, 0, -1, -1, Screen->D[ScreenD], 0, OP_OPAQUE);
			int str[]="/";
			drawx+=40;
			Screen->DrawString(2, drawx, drawy, FONT_BANK_RENDER_ACCOUNT, 1,0,  0, str,OP_OPAQUE);
			drawx+=8;
			Screen->DrawInteger(2, drawx, drawy,FONT_BANK_RENDER_ACCOUNT, 1, 0, -1, -1, capacity, 0, OP_OPAQUE);
			Waitframe();
		}		
	}
}