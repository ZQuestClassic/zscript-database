const int CF_SLOTMACHINE_WILD_SYMBOL = 10;//Combo flag to mark symbol as Wild symbol in symbol pool.
const int CF_SLOTMACHINE_BONUS_SYMBOL = 11;//Combo flag to mark leftmost symbol in paytable combination to trigger free spins bonus game.
const int CF_SLOTMACHINE_PROGRESSIVE_JACKPOT = 12;//Combo flag to mark leftmost symbol in paytable combination to win progressive jackpot
const int CF_SLOTMACHINE_SECRET_TRIGGER = 13;//Combo flag to mark leftmost symbol in paytable combination to trigger secrets
const int CF_SLOTMACHINE_ITEM_AWARD = 14;//Combo flag to mark leftmost symbol in paytable combination to award item

const int SCREEN_D_SLOTMACHINE_PROGRESSIVE_JACKPOT_VALUE = 0;//Screen D to track currant progressive jackpot value
const int SLOTMACHINE_INITIAL_PROGRESSIVE_VALUE = 200;//Initial progressive jackpot value, in multiples ob base stake.
const int SLOTMACHINE_MAX_INCREASE_PROGRESSIVE_VALUE = 100;//Progressive jackpot maximum increase on re-entry, in multiples ob base stake.
const int SLOTMACHINE_PROGRESSIVE_TAKEOUT_CHANCE = 50;//Chance that someone else will win progressive jackpot on reentry, causing it to reset.

const int SFX_SLOTMACHINE_START = 21;//Sound to play on pulling handle of slot machine
const int SFX_SLOTMACHINE_REEL_SPIN = 0;//Sound to play in loop during reel spinning, every SLOTMACHINE_SPIN_ASPEED frames.
const int SFX_SLOTMACHINE_REEL_STOP = 16;//Sound to play on reel stop.
const int SFX_SLOTMACHINE_WIN_GENERIC = 0;//Sound to play on generic win.
const int SFX_SLOTMACHINE_WIN_BONUS = 0;//Sound to play on triggering free spins bonus game.
const int SFX_SLOTMACHINE_WIN_PROGRESSIVE_JACKPOT = 0;//Sound to play on winning progressive jackpot.

const int I_DUMMY_WIN_GENERIC = 1;//ID of dummy item to render generic win animation.
const int I_DUMMY_WIN_JACKPOT = 40;//ID of dummy item to render jackpot win animation.

const int FONT_SLOTMACHINE_PAYTABLE = 0;//Font used to render all strings related to slot machine script.
const int TILE_SLOTMACHINE_PAYTABLE_FRAME = 20052;//Top left corner of 3*3 tile setup used to render frames when viewing paytable
const int CSET_SLOTMACHINE_PAYTABLE_FRAME = 7;//CSet used to render frames when viewing paytable
const int CMB_SLOTMACHINE_RUPEE = 950;// Combo used to render rupee image in both stake indicator and progressive jackpot tracker banner.
const int CSET_SLOTMACHINE_RUPEE = 5;// CSet used to render rupee image in both stake indicator and progressive jackpot tracker banner.

const int SLOTMACHINE_SPIN_ASPEED = 4;//Delay between changing symbols during reel spinning animation, in frames.
const int SLOTMACHINE_SPIN_STOP_TIME = 60;//Delay between stopping reels during spinning , in frames.
const int SLOTMACHINE_COOLDOWN_BETWEEN_SPINS = 90;//Cooldown between spins, in frames.

//Slot machine

//Advanced money losing game. Spin and Win! Come on, Big Money! Features wild symbols, free spins bonus games, item and secret wins and progressive jackpots.
//Stand on FFC, press Ex2, to view paytable, then Ex1 to insert the stake and pull the handle.

//1. Set up screen for loading symbol pool. Put combos staring from top left corner and left to right then up to down. Flag one combo with CF_SLOTMACHINE_WILD_SYMBOL to set it as wild symbol.
//2. Set up screen for loading paytable. For each combination, put the follwoing sequence of 5 combos: 3 symbols forming combination (leave as combo 0 to no checking for position), then combo, whose ID is win amount, paid in multiples of stake, i.e. if stake is 10 rupees and combo ID is 100, actual win on hitting this combination is 1000 rupees. The 5th combo in set is blank, leave as combo 0. Combinations in paytable must be left aligned along combo pos 0, 5 and 10. 
//3. Flag leftmost symbol of combinations with special flags (CF_SLOMACHINE_* constants in script file).
//4. Place invisible FFC in front of actual slot machine position in the screen.
// D0 - Map ID where screens with slot machine data is located.
// D1 - ID of screen (decimal), where symbol pool data is located (step 1).
// D2 - ID of screen (decimal), where paytable data is located (step 2).
// D3 - cost per play/ base bet, in rupees.
// D4 - #####.____ - ID of item to award if combination flagged with CF_SLOTMACHINE_ITEM_AWARD was hit for the first time.
// D4 - _____.#### - ID of item to award if combination flagged with CF_SLOTMACHINE_ITEM_AWARD was hit for the subsequent times.
// D5 - #####.____ - all wins are multiplied by this value during free spins bonus game.
// D5 - _____.#### - Number of free spins to award when bunus game is triggered by hitting combination flagged with CF_SLOTMACHINE_BONUS_SYMBOL.
// D6 - #####.____ - MIDI to play during free spins bonus game.
// D6 - _____.#### - String to display, when entering screen with slot machine.
// D7 - #####.____ - String to display, when winning progressive jackpot.
// D7 - _____.#### - String to display, when triggering free spins bonus game.
//5. Place FFC with ProgressiveJackpotTracker script where you want that huge banner that shows the current value of progressive jackpot.
// D0 - Must matach with alot machine`s D3
// D1 - Top left corner of 3*3 tile setup used to render banner frame (4*2 tiles).
// D2 - CSet used to render banner frame.

ffc script SlotMachine{
	void run (int map, int poolscreen, int paytablescreen, int stake, int itm, int bonusdata, int string1, int string2){
		int symbols[176];
		int symbolcset[176];
		int paytable[165];
		int wins[34];		
		for (int i=0;i<34;i++){
			wins[i]=0;
		}
		int totalwin = 0;
		int numsymbols = LoadSlotMachineSymbolPool(map, poolscreen, symbols, symbolcset);
		LoadSlotMachinePaytable(map,paytablescreen, paytable);
		
		int wildsymbol=0;
		// int DebugP[]="Tracing symbol pool";
		// TraceNL();
		// TraceS(DebugP);
		// TraceNL();
		// for (int i=0;i<176;i++){
			// Trace(symbols[i]);
			// if (i==numsymbols) TraceNL();
		// }
		// TraceNL();
		for (int i=0;i<176;i++){
			if (symbols[i]<0){
				symbols[i]*=-1;
				wildsymbol = symbols[i];
				break;
			}
		}
		int slots[3];
		int slotcsets[3];
		int random=0;
		for (int i=0;i<3;i++){
			random=Rand(numsymbols);
			slots[i]=symbols[random];
			slotcsets[i] = symbolcset[random];
		}
		if (Screen->D[SCREEN_D_SLOTMACHINE_PROGRESSIVE_JACKPOT_VALUE]>=0){
			if (Rand(SLOTMACHINE_PROGRESSIVE_TAKEOUT_CHANCE)==0)Screen->D[SCREEN_D_SLOTMACHINE_PROGRESSIVE_JACKPOT_VALUE]=0;
			if (Screen->D[SCREEN_D_SLOTMACHINE_PROGRESSIVE_JACKPOT_VALUE]==0)Screen->D[SCREEN_D_SLOTMACHINE_PROGRESSIVE_JACKPOT_VALUE]=Rand(SLOTMACHINE_MAX_INCREASE_PROGRESSIVE_VALUE)+SLOTMACHINE_INITIAL_PROGRESSIVE_VALUE;
			else Screen->D[SCREEN_D_SLOTMACHINE_PROGRESSIVE_JACKPOT_VALUE]+=Rand(SLOTMACHINE_MAX_INCREASE_PROGRESSIVE_VALUE);
		}
		
		int bonus = 0;
		int winmultiplier  = 1;
		int bonusspins = GetLowFloat(bonusdata);
		int bonusmiltiplier = GetHighFloat(bonusdata);
		int bonusmusic = GetHighFloat(string1);
		
		int main_item = GetHighFloat(itm);
		int backup_item = GetLowFloat(itm);
		
		int introstr = GetLowFloat(string1);
		int jackpotstr = GetHighFloat(string2);
		int bonusstr = GetLowFloat(string2);
		
		int State = 0;
		int cmb=-1;
		int pos = ComboAt(CenterX(this),CenterY(this));
		
		int slottimer = 0;
		int spintimer = 0;
		int stopslot=0;
		
		int origmidi = Game->GetMIDI();
		
		Screen->Message(introstr);
		
		int bonusstr2[] = "FREE SPINS";
		
		while(true){
			cmb = ComboAt (CenterLinkX(), CenterLinkY()-2);
			if (State==0){
				if (slottimer>0)slottimer--;
				cmb = ComboAt (CenterLinkX(), CenterLinkY()-2);
				if (cmb==pos){	
					Screen->FastCombo(7, Link->X-16, Link->Y-48, CMB_SLOTMACHINE_RUPEE, CSET_SLOTMACHINE_RUPEE, OP_OPAQUE);
					Screen->DrawInteger(7, Link->X, Link->Y-44, FONT_SLOTMACHINE_PAYTABLE,1,0, -1, -1, -stake, 0, OP_OPAQUE);
					if (Link->PressEx1&& slottimer==0){
						if (Game->Counter[CR_RUPEES]>= stake){
							Game->DCounter[CR_RUPEES]-=stake;
							Game->PlaySound(SFX_SLOTMACHINE_START);
							State=1;
							slottimer = SLOTMACHINE_SPIN_STOP_TIME;
							spintimer = SLOTMACHINE_SPIN_ASPEED;
							stopslot = 0;
							for (int i=0;i<3;i++){
								random=Rand(numsymbols);
								slots[i]=symbols[random];
								slotcsets[i] = symbolcset[random];
							}
						}
					}
					if (Link->PressEx2) RenderSlotMachinePaytable(this, paytable, wildsymbol);
				}
			}
			if (State==1){
				spintimer--;
				slottimer--;
				NoAction();
				if (spintimer<=0){
					for (int i=0;i<3;i++){
						if (stopslot>i) continue;
						random=Rand(numsymbols);
						slots[i]=symbols[random];
						slotcsets[i] = symbolcset[random];						
					}
					Game->PlaySound(SFX_SLOTMACHINE_REEL_SPIN);
					spintimer = SLOTMACHINE_SPIN_ASPEED;
				}
				if (slottimer<=0){
					Game->PlaySound(SFX_SLOTMACHINE_REEL_STOP);
					slottimer = SLOTMACHINE_SPIN_STOP_TIME;
					stopslot++;
					for (int i=0;i<3;i++){
						if (stopslot>i) continue;
						random=Rand(numsymbols);
						slots[i]=symbols[random];
						slotcsets[i] = symbolcset[random];
					}
					if (stopslot>=3){
						slottimer = 0;
						spintimer = 0;
						stopslot=0;
						totalwin = EvaluateWins(slots, paytable, wins, wildsymbol, false);
						if (totalwin>0){
							Game->PlaySound(SFX_SLOTMACHINE_WIN_GENERIC);
							Game->DCounter[CR_RUPEES]+=stake*totalwin*winmultiplier;
							if ((wins[22]&2)==0){
								Link->HeldItem = I_DUMMY_WIN_GENERIC;
								Link->Action = LA_HOLD1LAND;
							}
							else{
								Link->HeldItem = I_DUMMY_WIN_JACKPOT;
								Link->Action = LA_HOLD2LAND;
							}
							while(Link->Action == LA_HOLD1LAND || Link->Action == LA_HOLD2LAND){
								DrawFrame(1, TILE_SLOTMACHINE_PAYTABLE_FRAME, Link->X-32, Link->Y-48, 5, 3, CSET_SLOTMACHINE_PAYTABLE_FRAME, OP_OPAQUE);
								if (bonus>0){
									Screen->DrawString(7, Link->X-32, Link->Y-48,FONT_SLOTMACHINE_PAYTABLE, 1, 0, 0, bonusstr2, OP_OPAQUE);
									Screen->DrawInteger(7, Link->X-32, Link->Y-40, FONT_SLOTMACHINE_PAYTABLE,1,0, -1, -1, bonus, 0, OP_OPAQUE);
								}
								for (int i=0;i<3;i++){
									if (slots[i]>0)Screen->FastCombo(1, Link->X-16+16*i, Link->Y-32, Abs(slots[i]), slotcsets[i], OP_OPAQUE);
								}
								Screen->DrawInteger(7, Link->X+8, Link->Y-16, FONT_SLOTMACHINE_PAYTABLE,1,0, -1, -1, totalwin*stake, 0, OP_OPAQUE);
								Waitframe();
							}
						}
						else if (Rand(10)==0)Screen->D[SCREEN_D_SLOTMACHINE_PROGRESSIVE_JACKPOT_VALUE]++;
						if ((wins[33]&2)>0){
							Game->PlaySound(SFX_SLOTMACHINE_WIN_PROGRESSIVE_JACKPOT);
							Game->DCounter[CR_RUPEES]+=Screen->D[SCREEN_D_SLOTMACHINE_PROGRESSIVE_JACKPOT_VALUE]*stake;
							Screen->D[SCREEN_D_SLOTMACHINE_PROGRESSIVE_JACKPOT_VALUE]=SLOTMACHINE_INITIAL_PROGRESSIVE_VALUE;
							Screen->Message(jackpotstr);
							WaitNoAction(45);
						}
						if ((wins[33]&1)>0){
							Game->PlaySound(SFX_SLOTMACHINE_WIN_BONUS);
							bonus+=bonusspins;
							Game->PlayMIDI(bonusmusic);
							Screen->Message(bonusstr);
							WaitNoAction(45);
						}
						if ((wins[33]&4)>0){
							if (!Screen->State[ST_SECRET]){
								Game->PlaySound(SFX_SECRET);
								Screen->TriggerSecrets();
								Screen->State[ST_SECRET]=true;
							}
							else Game->PlaySound(SFX_SECRET);
						}
						if ((wins[33]&8)>0){
							if (Screen->State[ST_ITEM]){
								item it = CreateItemAt(backup_item, Link->X, Link->Y);
								it->Pickup +=IP_HOLDUP;
							}
							else{
								item it = CreateItemAt(main_item, Link->X, Link->Y);
								it->Pickup |= IP_ST_ITEM;
								it->Pickup +=IP_HOLDUP;
							}
						}
						if (bonus>0){
							for (int c = 0; c<SLOTMACHINE_COOLDOWN_BETWEEN_SPINS; c++){
								if (cmb==pos){
									DrawFrame(1, TILE_SLOTMACHINE_PAYTABLE_FRAME, Link->X-32, Link->Y-48, 5, 3, CSET_SLOTMACHINE_PAYTABLE_FRAME, OP_OPAQUE);
									if (bonus>0){
										Screen->DrawString(7, Link->X-32, Link->Y-48,FONT_SLOTMACHINE_PAYTABLE, 1, 0, 0, bonusstr2, OP_OPAQUE);
										Screen->DrawInteger(7, Link->X-32, Link->Y-40, FONT_SLOTMACHINE_PAYTABLE,1,0, -1, -1, bonus, 0, OP_OPAQUE);
									}
									for (int i=0;i<3;i++){
										if (slots[i]>0)Screen->FastCombo(1, Link->X-16+16*i, Link->Y-32, Abs(slots[i]), slotcsets[i], OP_OPAQUE);
									}
								}
								Waitframe();
							}
							bonus--;
							winmultiplier = bonusmiltiplier;
							Game->PlaySound(SFX_SLOTMACHINE_START);
							State=1;
							slottimer = SLOTMACHINE_SPIN_STOP_TIME;
							spintimer = SLOTMACHINE_SPIN_ASPEED;
							stopslot = 0;
							for (int i=0;i<3;i++){
								random=Rand(numsymbols);
								slots[i]=symbols[random];
								slotcsets[i] = symbolcset[random];
							}
						}
						else{
							winmultiplier = 1;
							Game->PlayMIDI(origmidi);
							slottimer = SLOTMACHINE_COOLDOWN_BETWEEN_SPINS;
							State=0;
						}
						slottimer = 0;
						spintimer = 0;
						stopslot=0;
					}
				}
			}
			if (cmb==pos){
				DrawFrame(1, TILE_SLOTMACHINE_PAYTABLE_FRAME, Link->X-32, Link->Y-48, 5, 3, CSET_SLOTMACHINE_PAYTABLE_FRAME, OP_OPAQUE);
				if (bonus>0){
					Screen->DrawString(7, Link->X-32, Link->Y-48,FONT_SLOTMACHINE_PAYTABLE, 1, 0, 0, bonusstr2, OP_OPAQUE);
					Screen->DrawInteger(7, Link->X, Link->Y-40, FONT_SLOTMACHINE_PAYTABLE,1,0, -1, -1, bonus, 0, OP_OPAQUE);
				}
				for (int i=0;i<3;i++){
					if (slots[i]>0)Screen->FastCombo(1, Link->X-16+16*i, Link->Y-32, Abs(slots[i]), slotcsets[i], OP_OPAQUE);
				}
			}
			// debugValue(1,winmultiplier);
			//TODO: Render Progressive Jackpot value.
			// debugValue(2,slottimer);
			// debugValue(3,stopslot);
			Waitframe();
		}
	}
}

ffc script ProgressiveJackpotTracker{
	void run(int stake){
		while(true){
			// if (framecmb>0)DrawFrame(1, framecmb, this->X, this->Y, 4, 2, cset, OP_OPAQUE);
			// Screen->FastCombo(1, this->X-4, this->Y, CMB_SLOTMACHINE_RUPEE, CSET_SLOTMACHINE_RUPEE, OP_OPAQUE);
			Screen->DrawInteger(1,this->X+16, this->Y+4, FONT_SLOTMACHINE_PAYTABLE,1,0, -1, -1, Screen->D[SCREEN_D_SLOTMACHINE_PROGRESSIVE_JACKPOT_VALUE]*stake, 0, OP_OPAQUE);
			Waitframe();
		}
	}
}

void RenderSlotMachinePaytable(ffc slotmachine, int paytable, int wildsymbol){
	int bonusspins = GetLowFloat(slotmachine->InitD[5]);
	int bonusmiltiplier = GetHighFloat(slotmachine->InitD[5]);
	int state = 0;
	int paycount = 0;
	int offset = 0;
	int pos = 0;
	int scet = 0;
	int jackpot[]="PROG";
	int wildstr[]="is wild and can replace"; 
	int wildstr2[]="any symbol in combination.";
	int bonusstr[24]= "Awards %d free spins";
	int formatbonus1[40];
	sprintf(formatbonus1, bonusstr, bonusspins);
	int bonusstr2[24] = "with all wins paid %dX.";
	int formatbonus2[40];
	sprintf(formatbonus2, bonusstr2, bonusmiltiplier);
	int bonusstr3[]= " - ?????";
	int genstr[] = "All winning combinations";
	int genstr2[] = "must match left to right.";
	int genstr3[] = "Only highest win pays.";
	int genstr4[] = "EX2 >>";
	int genstr5[] = "PAYTABLE";
	int itemstr[] = "awards item:";
	int itemstr2[120];
	itemdata itm;
	int main_item = GetHighFloat(slotmachine->InitD[4]);
	int backup_item = GetLowFloat(slotmachine->InitD[4]);
	if (Screen->State[ST_ITEM])itm = Game->LoadItemData(backup_item);
	else itm = Game->LoadItemData(main_item);
	itm->GetName(itemstr2);
	Link->PressEx2=false;
	while (LinkCollision (slotmachine)){
		DrawFrame(7, TILE_SLOTMACHINE_PAYTABLE_FRAME, 0, 0, 16, 10, CSET_SLOTMACHINE_PAYTABLE_FRAME, OP_OPAQUE);
		if (state ==0){
			for (int i=0; i<165; i+=5){
				if (paytable[i]==0)continue;
				if (i>=110) offset = 10;
				else if (i>=55) offset = 5;
				else offset = 0;
				pos = (((i/5)%11)*16)+offset;
				scet = Game->GetComboCSet(slotmachine->InitD[0], slotmachine->InitD[2], pos);
				Screen->FastCombo(7, ComboX(pos)+16, ComboY(pos)+8, paytable[i], scet, OP_OPAQUE);
				scet = Game->GetComboCSet(slotmachine->InitD[0], slotmachine->InitD[2], pos+1);
				Screen->FastCombo(7, ComboX(pos)+32, ComboY(pos)+8, paytable[i+1], scet, OP_OPAQUE);
				scet = Game->GetComboCSet(slotmachine->InitD[0], slotmachine->InitD[2], pos+2);
				Screen->FastCombo(7, ComboX(pos)+48, ComboY(pos)+8, paytable[i+2], scet, OP_OPAQUE);
				if ((paytable[i+4] & 2)>0)Screen->DrawString( 7, ComboX(pos + 3)+16, ComboY(pos)+8,FONT_SLOTMACHINE_PAYTABLE, 6, 0, 0,jackpot,OP_OPAQUE );
				Screen->DrawInteger(7, ComboX(pos)+64, ComboY(pos)+16, FONT_SLOTMACHINE_PAYTABLE,1,0, -1, -1, paytable[i+3]*slotmachine->InitD[3], 0, OP_OPAQUE);
				if (Link->PressEx2) state=1;
			}
		}
		else if (state==1){
			if (wildsymbol>0){
				Screen->FastCombo(7, 16, 16, wildsymbol, slotmachine->CSet, OP_OPAQUE);
				Screen->DrawString( 	7, 48, 20,	FONT_SLOTMACHINE_PAYTABLE, 1, 0, 0, wildstr, OP_OPAQUE);
				Screen->DrawString( 	7, 16, 32,	FONT_SLOTMACHINE_PAYTABLE, 1, 0, 0, wildstr2, OP_OPAQUE);
			}
			for (int i=0; i<165; i+=5){
				if (i>=110) offset = 10;
				else if (i>=55) offset = 5;
				else offset = 0;
				pos = (((i/5)%11)*16)+offset;
				if ((paytable[i+4]&1)>0){
					scet = Game->GetComboCSet(slotmachine->InitD[0], slotmachine->InitD[2], pos);
					Screen->FastCombo(7, 16, 48, paytable[i], scet, OP_OPAQUE);
					scet = Game->GetComboCSet(slotmachine->InitD[0], slotmachine->InitD[2], pos+1);
					Screen->FastCombo(7, 32, 48, paytable[i+1], scet, OP_OPAQUE);
					scet = Game->GetComboCSet(slotmachine->InitD[0], slotmachine->InitD[2], pos+2);
					Screen->FastCombo(7, 48, 48, paytable[i+2], scet, OP_OPAQUE);
					Screen->DrawString(7, 64, 52,FONT_SLOTMACHINE_PAYTABLE, 1, 0, 0, formatbonus1, OP_OPAQUE);
					Screen->DrawString(7, 16, 64,FONT_SLOTMACHINE_PAYTABLE, 1, 0, 0, formatbonus2, OP_OPAQUE);
					
				}
				if ((paytable[i+4]&4)>0){
					scet = Game->GetComboCSet(slotmachine->InitD[0], slotmachine->InitD[2], pos);
					Screen->FastCombo(7, 16, 80, paytable[i], scet, OP_OPAQUE);
					scet = Game->GetComboCSet(slotmachine->InitD[0], slotmachine->InitD[2], pos+1);
					Screen->FastCombo(7, 32, 80, paytable[i+1], scet, OP_OPAQUE);
					scet = Game->GetComboCSet(slotmachine->InitD[0], slotmachine->InitD[2], pos+2);
					Screen->FastCombo(7, 48, 80, paytable[i+2], scet, OP_OPAQUE);
					Screen->DrawString(7, 64, 84,FONT_SLOTMACHINE_PAYTABLE, 1, 0, 0, bonusstr3, OP_OPAQUE);
					
				}
				if ((paytable[i+4]&8)>0){
					scet = Game->GetComboCSet(slotmachine->InitD[0], slotmachine->InitD[2], pos);
					Screen->FastCombo(7, 16, 104, paytable[i], scet, OP_OPAQUE);
					scet = Game->GetComboCSet(slotmachine->InitD[0], slotmachine->InitD[2], pos+1);
					Screen->FastCombo(7, 32, 104, paytable[i+1], scet, OP_OPAQUE);
					scet = Game->GetComboCSet(slotmachine->InitD[0], slotmachine->InitD[2], pos+2);
					Screen->FastCombo(7, 48, 104, paytable[i+2], scet, OP_OPAQUE);
					Screen->DrawString(7, 64, 104,FONT_SLOTMACHINE_PAYTABLE, 1, 0, 0, itemstr, OP_OPAQUE);
					Screen->DrawString(7, 64, 112,FONT_SLOTMACHINE_PAYTABLE, 1, 0, 0, itemstr2, OP_OPAQUE);
				}
			}
			Screen->DrawString(7, 16, 128,FONT_SLOTMACHINE_PAYTABLE, 1, 0, 0, genstr, OP_OPAQUE);
			Screen->DrawString(7, 16, 136,FONT_SLOTMACHINE_PAYTABLE, 1, 0, 0, genstr2, OP_OPAQUE);
			Screen->DrawString(7, 16, 144,FONT_SLOTMACHINE_PAYTABLE, 1, 0, 0, genstr3, OP_OPAQUE);
			if (Link->PressEx2) return;
		}
		Screen->DrawString(7, 128, 0,FONT_SLOTMACHINE_PAYTABLE, 1, 0, 1, genstr5, OP_OPAQUE);
		Screen->DrawString(7, 128, 152,FONT_SLOTMACHINE_PAYTABLE, 1, 0, 1, genstr4, OP_OPAQUE);
		Waitframe();
	}
}

void LoadSlotMachinePaytable(int map, int screen, int table){
	int offset = 0;
	int pos = 0;
	// int Debug[]="Tracing paytable contents";
	// TraceNL();
	// TraceS(Debug);
	// TraceNL();
	for (int i=0; i<165; i+=5){
		if (i>=110) offset = 10;
		else if (i>=55) offset = 5;
		else offset = 0;
		pos = (((i/5)%11)*16)+offset;
		table[i] =  Game->GetComboData(map, screen, pos);
		table[i+1] = Game->GetComboData(map, screen, pos+1);
		table[i+2] = Game->GetComboData(map, screen, pos+2);
		table[i+3] = Game->GetComboData(map, screen, pos+3);
		if (Game->GetComboFlag(map, screen, pos)==CF_SLOTMACHINE_BONUS_SYMBOL) table[i+4]|=1;
		if (Game->GetComboFlag(map, screen, pos)==CF_SLOTMACHINE_PROGRESSIVE_JACKPOT) table[i+4]|=2;
		if (Game->GetComboFlag(map, screen, pos)==CF_SLOTMACHINE_SECRET_TRIGGER) table[i+4]|=4;
		if (Game->GetComboFlag(map, screen, pos)==CF_SLOTMACHINE_ITEM_AWARD) table[i+4]|=8;
		// for(int d=0; d<5;d++){
			// Trace(table[i+d]);
		// }
	}
	TraceNL();
}

int LoadSlotMachineSymbolPool(int map, int screen, int symbols, int symbolcset){	
	for (int i=0;i<176;i++){
		if (Game->GetComboData(map, screen, i)==0) return i;
		symbols[i]=Game->GetComboData(map, screen, i);
		symbolcset[i]=Game->GetComboCSet(map, screen, i);		
		if (Game->GetComboFlag(map, screen, i)==CF_SLOTMACHINE_WILD_SYMBOL) symbols[i]*=-1;
		
	}
}

void DrawFrame(int layer, int tile, int posx, int posy, int sizex, int sizey, int CSet, int opacity){
	int drawx = posx;
	int drawy = posy;
	int xoffset=0;
	int yoffset=0;
	for (int w=0; w<sizex; w++){
		drawx = posx+16*w;
		xoffset=0;
		if (w>0)xoffset=1;
		if (w==sizex-1) xoffset=2;
		for (int h=0; h<sizey; h++){
			drawy = posy+16*h;
			yoffset=0;
			if (h>0)yoffset=1;
			if (h==sizey-1) yoffset=2;
			Screen->FastTile(layer, drawx, drawy, tile +xoffset+20*yoffset, CSet, opacity);
		}
	}
}

int EvaluateWins(int slots, int paytable, int wins, int wildsymbol, bool sum){
	int check = 0;
	int ret = 0;
	wins[33]=0;
	for (int i=0; i<33; i++){
		wins[i]=0;
		check = i*5;
		if (slots[0]!=paytable[check]&& paytable[check]>0 && slots[0]!= wildsymbol)continue;
		if (slots[1]!=paytable[check+1] && paytable[check+1]>0 && slots[1]!=wildsymbol)continue;
		if (slots[2]!=paytable[check+2]&& paytable[check+2]>0 && slots[2]!=wildsymbol)continue;
		wins[i]=paytable[check+3];
	}
	if (sum){
		for (int i=0; i<33; i++){
			check = i*5;
			ret += wins[i];
			wins[33]|=paytable[check+4];
		}
	}
	else{
		for (int i=0; i<33; i++){
			if (wins[i]>ret){
				check = i*5;
				ret=wins[i];
				wins[33]=paytable[check+4];
			}
		}
	}
	return ret;
}