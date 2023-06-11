const int NPC_MISC_SIUTSTATE = 14;//NPC Misc variable to track currant poker number. 

const int CSET_POKER_FLASH = 7;//Default Cset to flash when target poker combination is achieved and monster is about to die.
const int POKER_FLASH_ASPEED = 8;//Near death flash aspeed.
//Link`s Awakening poker monsters. Walks like normal Darknut, changing displayed number every so often. Csn only be stunned. If Link stun all such monsters, so numbers shown form specific poker combination, all such enemies die and the puzzle is solved. Hit with Lweapon to stun, hit again to wake up. 

//Random rate, hunger, homing factor, and step speed are used. Must have absurdly high HP.
//Animation - sequence of 2 framed anims in row equal to number of possible numbers

ffc script NofaKind{
	void run(int enemyID){
		npc ghost = Ghost_InitAutoGhost(this, enemyID);
		
		int HF = ghost->Homing;
		int HR = ghost->Haltrate;
		int RR = ghost->Rate;
		int HNG = ghost->Hunger;
		int SPD = ghost->Step;
		int WPND = ghost->WeaponDamage;
		
		int delay = Ghost_GetAttribute(ghost, 0, 15);//Cooldown between hits, in frames
		int numstates = Ghost_GetAttribute(ghost, 1, 1);//Number of numbers/states (like 1-6)
		int cycledelay = Ghost_GetAttribute(ghost, 2, 45);//Delay between changing displayed numbers, in frames.
		int deathflashcset = Ghost_GetAttribute(ghost, 3, CSET_POKER_FLASH);//CSet of flash when solved to kill
		
		Ghost_SetFlag(GHF_NORMAL);		
		Ghost_UnsetFlag(GHF_KNOCKBACK);
		
		// int defs[18];
		// Ghost_StoreDefenses(ghost,defs);
		// Ghost_SetAllDefenses(ghost, NPCDT_STUN);
		
		int OrigTile = ghost->OriginalTile;
		int origcset = Ghost_CSet;
		int State = 1;
		int haltcounter = 0;
		int counter=delay;
		ghost->Misc[NPC_MISC_SIUTSTATE]=0;
		int Ghost_MaxHP = Ghost_HP; 
		int cycle = cycledelay;
		
		while(true){
			if (ghost->Misc[NPC_MISC_SIUTSTATE]>=0){
				if (ghost->Misc[NPC_MISC_SIUTSTATE]==0){
					haltcounter = Ghost_ConstantWalk4(haltcounter, SPD, RR, HF, HNG);
					cycle--;
					if (cycle==0){
						State++;
						if (State>numstates)State=1;
						cycle = cycledelay;
					}
					Ghost_HP=Ghost_MaxHP;
					if (counter>0)counter--;
					if (Ghost_GotHit()&& counter==0){
					Ghost_HP=Ghost_MaxHP;
						ghost->Misc[NPC_MISC_SIUTSTATE]=State;
						counter=delay;
					}
				}
				else {
					if (counter>0)counter--;
					if (Ghost_GotHit()&& counter==0){
					Ghost_HP=Ghost_MaxHP;
						ghost->Misc[NPC_MISC_SIUTSTATE]=0;
						counter=delay;
					}
				}
				Ghost_HP=Ghost_MaxHP;
				ghost->OriginalTile = OrigTile + 2*State-2;
			}
			else{
				if (ghost->Misc[NPC_MISC_SIUTSTATE]==-1){
					counter=90;
					ghost->CollDetection=false;
					ghost->Misc[NPC_MISC_SIUTSTATE]=-2;
				}
				if (ghost->Misc[NPC_MISC_SIUTSTATE]==-2){
					counter--;
					if ((counter%POKER_FLASH_ASPEED)<POKER_FLASH_ASPEED/2)Ghost_CSet = deathflashcset;
					else Ghost_CSet = origcset;
					if (counter==0){
						ghost->Misc[NPC_MISC_SIUTSTATE]=-3;
						Ghost_HP=0;
					}
				}
			}
			if (!Ghost_Waitframe(this, ghost, false, false)){
				if (ghost->Misc[NPC_MISC_SIUTSTATE]>=-2)Ghost_HP=Ghost_MaxHP;
				else Quit();
			}
		}
	}
}

//Poker Monsters FFC script
//Spawns a number of Poker Monsters. If all those monsters are stunned and thair numbers form the target poker combination, the puzzle is solved and those monsters are killed.
//Requires poker.zh in addition to ghost.zh
//1. Set up NofaKind ghosted enemy script above
//2. Place invisible FFC anywhere in the screen
//D0 - ID of enemy to spawn
//D1 - number of enemies to spawn
//D2 -combintion type
// D2 = 0 - Longest set must be that long or longer
//   D3 - number of same kind, D4 - target number of sets (i.e 3 6s), if D5 is >0 - target set must be exactly D4 long (i,e, 4 4s, and extra 4 is failure). If D6 is 0, any extra sets will fail the check. For instance 5 elements contain 3 of a kind and remaining 2 enemies must mismatch to solve.
// D2 = 1 - Number of sets. D3 - set size, D4 numberof sets. id D5 is 0, larger set sizes are allowed. Example - 3 pairs, more pairs are allowed if D6 is 0, but quads here don`t count.
// D2 = 2 - Full House - all cards are part of sets, D3 - maximum set length, D4 - min set length, D5>0 - hand must contain one set on minimum length, if specified, and 1 set of max length, if specified.
// D2 = 3 - Straight - sequence of ranks - D3 - number of elements in sequence. if D5 is 0, longer sequences also count.

ffc script PokerMonsters{
	void run (int npcid, int numen, int combination, int miscval1, int miscval2, int exact, int allowothersets){
		if (Screen->State[ST_SECRET])Quit();
		npc card[10];
		int poker[10];
		for (int i=0;i<10;i++){
			poker[i]=-1;
		}
		bool ex = exact>0;
		bool ready=false;
		bool side = allowothersets>0;
		bool fit = false;
		bool check =false;
		int bufferset[40];
		int buffernum[40];
		for (int i=0;i<numen;i++){
			card[i] = SpawnNPC(npcid);
			poker[i]=0;
		}
		Waitframes(60);
		while(true){
			for (int i=0;i<numen;i++){
				if (!card[i]->isValid()){
					Trace(i);
					Game->PlaySound(3);
					Quit();
				}
				else poker[i]=card[i]->Misc[NPC_MISC_SIUTSTATE];
			}
			for (int i=0;i<numen;i++){
				if (poker[i]==0){
					ready=false;
					check=false;
					break;
				}
				if (i==(numen-1)){
					ready=true;
				}
			}
			if (ready && !check){
				if (combination==0){
					fit = IsNoaKind(poker, miscval1, ex, side, miscval2);
				}
				if (combination==1){
					if (!side)fit = GetNumSets(poker, miscval1, Cond(ex, miscval1, 10))== miscval2;
					else fit = GetNumSets(poker, miscval1, Cond(ex, miscval1, 10))>= miscval2;
				}
				if (combination==2){
					fit = IsMultiFullHouse(poker, miscval1, miscval2,ex);
				}
				if (combination==3){
					if (ex) fit = GetBestSequence(poker)==miscval1;
					else fit = GetBestSequence(poker)>=miscval1;
				}
				if (fit){
					Game->PlaySound(SFX_SECRET);
					for (int i=0;i<numen;i++){
						card[i]->Misc[NPC_MISC_SIUTSTATE]=-1;
					}
					Waitframes(90);
					Game->PlaySound(SFX_SECRET);
					Screen->TriggerSecrets();
					Screen->State[ST_SECRET]=true;
					Quit();					
				}
				else {
					check=true;
				}
			}
			if (ready)this->CSet=8;
			else this->CSet=7;
			// for (int i=0; i<numen; i++){
				// Screen->DrawInteger(2, 32+16*i, 32,0, 1,0 , -1, -1, poker[i], 0, OP_OPAQUE);
			// }
			Waitframe();
		}
	}
}