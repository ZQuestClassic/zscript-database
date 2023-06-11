const int SFX_ROULETTE_SPIN = 17; //Sound to play during roulette spinning

const int ROULETTE_RENDER_TRUE_RESULTS = 0; //Set to >0 - render exact angle wheel is, when not spinning.
const int ROULETTE_LOCK_HIGHLIGHT_CORRECT_LANDING = 0;//Set to >0 - outline rectangle around lock wheel, when the pointer is in target sector.

//Roulette wheel. Step on FFC and press EX1 to spin it. You need to meet counter requirements to do this. Roulette itself 
//is d360 and does not do anything, only set it`s InitD[7] to result angle. While roulette is spinning, InitD[7] is set to -1. You need
//other scripts that can read FFC`s InitD[7] to determine and resolve various events depending on wheel spin result.

//Requires ghost.zh

//Place FFC on the at activation button.
//D0 - combo position where the wheel will be located. Size is 3*3.
//D1 - combo used to render roulette wheel
//D2 - counter required to spin the wheel
//    #####.____ - counter ID;
//    _____.#### - counter cost, not subtracted on spin.
//D3 - if > 0 - subtract cost.
ffc script RouletteWheel{
	void run (int pos, int cmb, int req, int sub){
		int xpos = ComboX(pos);
		int ypos = ComboY(pos);
		int angle = Rand(360);
		int rnd[3] = {0,0,0};
		this->InitD[7] = 0;
		bool spin = false;
		int origdata = this->Data;
		int counter = Abs(GetHighFloat(req));
		int cost = GetLowFloat(req);
		int rat = Div(angle, 10);
		while (true){
			if (!spin){
				if (RectCollision(Link->X+7, Link->Y+7, Link->X+8, Link->Y+8, this->X, this->Y, this->X+this->EffectWidth-1, this->Y+this->EffectHeight-1)){
					if ((Game->Counter[counter]>=cost)&&(Link->PressEx1)){
						//angle = Rand(360);
						rat = Div(angle, 10);
						rnd[0] = 120 + Rand(120);
						rnd[1] = 60;
						rnd[2] = 60 + Rand(3);;
						this->InitD[7]=-1;
						this->Data++;
						if (sub>0) Game->DCounter[counter] -=cost;
						spin = true;
					}
				}
			}
			else{
				NoAction();
				angle%=360;
				if (Div(angle, 10)==rat){
					Game->PlaySound(SFX_ROULETTE_SPIN);
					rat++;
					if (rat>=36) rat=0;
				}
				if (rnd[0]>0){
					angle+=3;
					rnd[0]--;
				}
				else if (rnd[1]>0){
					angle+=2;
					rnd[1]--;
				}
				else if (rnd[2]>0){
					angle++;
					rnd[2]--;
				}
				else{
					this->Data=origdata;
					this->InitD[7]=angle;
					spin = false;
				}
			}
			Screen->DrawCombo(2, xpos, ypos,cmb, 3, 3, this->CSet, -1, -1, xpos, ypos, angle, 0, 0,true, OP_OPAQUE);
			if (!spin && (ROULETTE_RENDER_TRUE_RESULTS>0)) Screen->DrawInteger(2, xpos, ypos,0, 1,0, -1, -1, angle, 0, OP_OPAQUE);
			Waitframe();
		}
	}
}


//Roulette wheel event resolver. Has up 4 events, one of them can happen after spinning the wheel. Each event has minimum angle value (0-359) 
//that roullete must stop at for event to happen. Only 1 event happens per spin. Each event is evaluated in sequence, in order: D1, D3, D5, D7.
//So for 4th event to happen, the following inequality must be true: D1 > D3 > D5 > D7. If Roulette result is lower than D7, in that instance, 
//nothing happens.
//Place invisible FFC anywhere in the screen.
// D1, D3, D5, D7 - angles used to determine event chances.
// D0, D2, D4, D6 - events to occur
// #####.[0-31] - counter affected, in positive or negative way. #####.____ amount, _____.#### - counter to affect.
// _____.0033 - Trigger permanent screen secrets
// #####.0034 - Spawn 1 enemy. High value - Enemy ID.
// #####.0035 - Positive - give Link item #####. Negative - take away item ##### from Link`s inventory.
ffc script DiceEvent{
	void run(int event1, int chance1, int event2, int chance2, int event3,int chance3, int event4, int chance4){
		int str[] = "RouletteWheel";
		int scr = Game->GetFFCScript(str);
		ffc r;
		int events[4] = {event1, event2, event3, event4};
		int chance[4] = {chance1, chance2, chance3, chance4};
		int eventpower[4];
		int eventtype[4];
		int origdata = this->Data;
		for (int i=0;i<4; i++){
			eventpower[i] = GetHighFloat(events[i]);
			eventtype[i] = GetLowFloat(events[i]);
			eventtype[i]=Abs(eventtype[i]); 
		}
		bool spin = false;
		for (int i=1; i<=33; i++){
			if (i==33){
				int error[] = "Roulette not found. Use RouletteWheel FFC script";
				TraceS(error);
				Quit();
			}
			r = Screen->LoadFFC(i);
			if (r->Script!=scr) continue;
			else break;
		}
		while (true){
			if (spin){
				if (r->InitD[7]>0){
					int res = r->InitD[7];
					for (int i = 0; i<=3; i++){
						if (res>=chance[i]){
							//Trace(eventpower[i]);
							//Trace(eventtype[i]);
							if (eventtype[i]>=0 && eventtype[i]<32){
								int cr = eventtype[i];
								Game->DCounter[cr] += eventpower[i];
							}
							if (eventtype[i]==33){
								Game->PlaySound(SFX_SECRET);
								Screen->TriggerSecrets();
								Screen->State[ST_SECRET]=true;
							}
							if (eventtype[i]==34){
								npc en = SpawnNPC(eventpower[i]);								
							}
							if (eventtype[i]==35){
								int itm = Abs(eventpower[i]);
								if (eventpower[i]>0){
									item it = CreateItemAt(itm, Link->X, Link->Y);
									it->Pickup=2;
								}
								else {
									Game->PlaySound(SFX_OUCH);
									Link->Item[itm] = false;
								}
							}							
							spin=false;
							break;
						}
					}
					//Trace(r->InitD[7]);
				}
			}
			else{
				if (r->InitD[7]<0) spin=true;
			}
			Waitframe();
		}
	}
}

//Roulette wheel combination lock. Keep spinning wheel until it lands on correct angle or within tolerance sector to open secrets.
//Unlike normal roulette wheel, it does not cause Link to freeze in place until spinning wheel stops.
//Place FFC on the at activation button.
//D0 - combo position where the wheel will be located. Size is 3*3.
//D1 - combo used to render roulette wheel
//D2 - counter required to spin the wheel
//    #####.____ - counter ID;
//    _____.#### - counter cost, not subtracted on spin.
//D3 - target angle, or bisect of target sector.
//D4 - Tolerance value. Higher the value, the wider is target sector to land into and open secrets.
//D5 - if > 0 - subtract cost per spin.

ffc script RouletteWheelLock{
	void run (int pos, int cmb, int req, int targangle, int tolerance, int sub){
		int str[] = "RouletteWheelLock";
		int scr = Game->GetFFCScript(str);
		int xpos = ComboX(pos);
		int ypos = ComboY(pos);
		int angle = Rand(360);
		int rnd[3] = {0,0,0};
		this->InitD[7] = 0;
		this->InitD[6] = 0;
		bool spin = false;
		int origdata = this->Data;
		int counter = GetHighFloat(req);
		int cost = GetLowFloat(req);
		int rat = Div(angle, 10);
		while (true){
			if (!spin){
				if (RectCollision(Link->X+7, Link->Y+7, Link->X+8, Link->Y+8, this->X, this->Y, this->X+this->EffectWidth-1, this->Y+this->EffectHeight-1)){
					if ((Game->Counter[counter]>=cost)&&(Link->PressEx1)){
						if (sub>0) Game->DCounter[counter] -=cost;
						this->Data++;
						rat = Div(angle, 10);
						rnd[0] = 120 + Rand(120);
						rnd[1] = 60;
						rnd[2] = 60+ Rand(3);
						this->InitD[7]=-1;
						spin = true;
					}
				}
			}
			else{
				//NoAction();
				angle%=360;
				if (Div(angle, 10)==rat){
					Game->PlaySound(SFX_ROULETTE_SPIN);
					rat++;
					if (rat>=36) rat=0;
				}
				if (rnd[0]>0){
					angle+=3;
					rnd[0]--;
				}
				else if (rnd[1]>0){
					angle+=2;
					rnd[1]--;
				}
				else if (rnd[2]>0){
					angle++;
					rnd[2]--;
				}
				else{
					this->InitD[7]=angle;
					this->Data=origdata;
					int rangeleft = targangle - tolerance + 360;
					int rangeright = targangle + tolerance + 360;
					int checkangle = angle + 360;
					//Trace(rangeleft);
					//Trace(rangeright);
					//Trace(checkangle);
					if (checkangle>= rangeleft && checkangle<= rangeright){
						this->InitD[6]=1;
						for (int i = 1; i<= 33; i++){
							if (Screen->State[ST_SECRET]) break;
							if (i==33 && !Screen->State[ST_SECRET]){
								Game->PlaySound(SFX_SECRET);
								Screen->TriggerSecrets();
								Screen->State[ST_SECRET]=true;
								break;
							}
							ffc f = Screen->LoadFFC(i);
							if (f->Script != scr) continue;
							if (f->InitD[6]==0) break;
						}
					}
					else this->InitD[6] = 0;
					spin = false;
				}
			}
			Screen->DrawCombo(2, xpos, ypos,cmb, 3, 3, this->CSet, -1, -1, xpos, ypos, angle, 0, 0,true, OP_OPAQUE);
			if (!spin && (ROULETTE_RENDER_TRUE_RESULTS>0)) Screen->DrawInteger(2, xpos, ypos,0, 1,0, -1, -1, angle, 0, OP_OPAQUE);
			if ((this->InitD[6]>0)&&(ROULETTE_LOCK_HIGHLIGHT_CORRECT_LANDING>0)) Screen->Rectangle(2, xpos, ypos, xpos+47, ypos+47, 1, -1, 0, 0, 0, false, OP_OPAQUE);
			Waitframe();
		}
	}
}

//Returns a pointer of 1st FFC that runs roulete wheel script. Yields eror message, if none found.
ffc FindRouletteWheel(){
	ffc r;
	int str[] = "RouletteWheel";
	int scr = Game->GetFFCScript(str);
	for (int i=1; i<=33; i++){
		if (i==33){
			int error[] = "Roulette not found. Use RouletteWheel FFC script";
			TraceS(error);
			return r;
		}
		r = Screen->LoadFFC(i);
		if (r->Script!=scr) continue;
		else return r;
	}
}