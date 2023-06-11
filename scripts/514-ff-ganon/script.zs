const int FFGANON_STATE_NORMAL = 0;
const int FFGANON_STATE_STUNNED = 1;
const int FFGANON_STATE_DAMAGED = 2;
const int FFGANON_STATE_INTRO = 3;

const int SFX_FFGANON_FINISH_HIM  = 15;//Sound used for near death state

//Expanded and un-hardcoded variant of Z1 ganon. Teleports around, firing eweapons at Link, if brought down to 0 HP, Link needs to hit him one last time with specific lweapon to finish off, otherwise boss fully recovers.
//Uses 2 rows of tiles, one below another.

ffc script FFGanon{
	void run(int enemyID){
		npc ghost = Ghost_InitAutoGhost(this, enemyID);
		
		int HF = ghost->Homing;
		int HR = ghost->Haltrate;
		int RR = ghost->Rate;
		int HNG = ghost->Hunger;
		int SPD = ghost->Step;
		int WPND = ghost->WeaponDamage;
		
		int stuntime = Ghost_GetAttribute(ghost, 0, 180);//Duration for near death state
		int LWFinisher = Ghost_GetAttribute(ghost, 1, 8);//ID of lweapon needed to finish off Ganon
		int sizex = Ghost_GetAttribute(ghost, 2, 2);//Tile Width
		int sizey = Ghost_GetAttribute(ghost, 3, 2);//Tile Height
		int mindamage = Ghost_GetAttribute(ghost, 4, 8);//Minimum damage of lweapon needed to finish off Ganon
		int stuncset = Ghost_GetAttribute(ghost, 5, 8);//CSet used for near death state
		int invisibility = Ghost_GetAttribute(ghost, 6, 0);//Invisibility: 0 - none, 1 - visible only to Lens of Truth, 2 - completely invisible
		int movedelay = Ghost_GetAttribute(ghost, 7, 60);//Delay between teleporting, in frames
		int ewsprite = Ghost_GetAttribute(ghost, 8, -1);//Eweapon sprite
		int introsequence = Ghost_GetAttribute(ghost, 9, 0);//introduction sequence duration, in frames
		
		ghost->Extend=3;
		Ghost_SetSize(this, ghost, sizex, sizey);
		if (sizex>2 && sizey>2)Ghost_SetHitOffsets(ghost, 8, 8, 8, 8);
		
		Ghost_SetFlag(GHF_NORMAL);
		Ghost_SetFlag(GHF_NO_FALL);
		Ghost_SetFlag(GHF_8WAY);
		Ghost_UnsetFlag(GHF_KNOCKBACK);
		
		int OrigTile = ghost->OriginalTile;
		int OrigCset = ghost->CSet;
		int State = FFGANON_STATE_INTRO;
		int haltcounter = movedelay;
		int defs[18];
		Ghost_StoreDefenses(ghost,defs);
		Ghost_SetAllDefenses(ghost, NPCDT_IGNORE);
		int stuncounter = introsequence;
		int Ghost_MaxHP = ghost->HP;
		int cmb=0;
		
		while(true){
			if (State == FFGANON_STATE_INTRO){
				stuncounter--;
				if (stuncounter==0){
					Ghost_SetDefenses(ghost, defs);
					State = FFGANON_STATE_NORMAL;
					cmb= FindSpawnPoint(true, false, false, false);
					Ghost_X = ComboX(cmb);
					Ghost_Y = ComboY(cmb);
					eweapon e = FireAimedEWeapon(ghost->Weapon, Ghost_X, Ghost_Y, 0, 200, WPND, ewsprite, -1, 0); 
				}
			}
			else if (State == FFGANON_STATE_NORMAL){
				haltcounter--;
				if (haltcounter==0){
					cmb= FindSpawnPoint(true, false, false, false);
					Ghost_X = ComboX(cmb);
					Ghost_Y = ComboY(cmb);
					haltcounter = movedelay;
					eweapon e = FireAimedEWeapon(ghost->Weapon, Ghost_X, Ghost_Y, 0, 200, WPND, ewsprite, -1, 0); 
				}
				if (invisibility>0){
					if (invisibility==1 && UsingItem(I_LENS)) ghost->DrawXOffset=0;
					else ghost->DrawXOffset=1000;
				}
				if ( Ghost_GotHit() && Ghost_HP>0){
					ghost->DrawXOffset=0;
					stuncounter=45;
					State = FFGANON_STATE_DAMAGED;
					Ghost_SetAllDefenses(ghost, NPCDT_IGNORE);
				}
				if(Ghost_HP<=0){
					Game->PlaySound(SFX_FFGANON_FINISH_HIM);
					ghost->DrawXOffset=0;
					Ghost_HP=1;
					Ghost_CSet=stuncset;
					Ghost_SetAllDefenses(ghost, NPCDT_IGNORE);
					stuncounter = stuntime;
					State = FFGANON_STATE_STUNNED;
				}
			}
			else if (State == FFGANON_STATE_DAMAGED){
				stuncounter--;
				if (stuncounter==0){
					Ghost_SetDefenses(ghost, defs);
					State = FFGANON_STATE_NORMAL;
					cmb= FindSpawnPoint(true, false, false, false);
					Ghost_X = ComboX(cmb);
					Ghost_Y = ComboY(cmb);
					eweapon e = FireAimedEWeapon(ghost->Weapon, Ghost_X, Ghost_Y, 0, 200, WPND, ewsprite, -1, 0); 
				}
			}
			else if (State == FFGANON_STATE_STUNNED){
				for (int i=1; i <= Screen->NumLWeapons(); i++){
					lweapon finisher = Screen->LoadLWeapon(i);
					if ((finisher->ID) != LWFinisher) continue;
					if (finisher->Damage<mindamage) continue;
					if (!Collision (ghost, finisher)) continue;
					Remove(finisher);
					ghost->CollDetection=false;
					Ghost_DeathAnimation(this, ghost, GHD_EXPLODE);					
					Ghost_HP=0;
				}
				stuncounter--;
				if(stuncounter==0){
					Ghost_CSet = OrigCset;
					Ghost_HP = Ghost_MaxHP;
					Ghost_SetDefenses(ghost, defs);
					State = FFGANON_STATE_NORMAL;
				}
			}
			GanonAnimation(ghost, OrigTile, State, 4);
			if (State == FFGANON_STATE_NORMAL)Ghost_Waitframe(this, ghost, false, false);
			else Ghost_Waitframe(this, ghost, true, true);
		}
	}
}

void GanonAnimation(npc ghost, int origtile, int state, int numframes){
	int offset = 0;
	if (state >0) offset = 20*(ghost->TileHeight);
	ghost->OriginalTile = origtile + offset;
}

//Remastered Ganon Room sequence.
//Place anywhere in the screen
//D0 - ID of boss NPC
//D1 - Tile used for rendering Link holding Triforce at intro
//D2 - Tile used for rendering Triforce at intro
//D3 - ID of item dropeed by boss, when killed
ffc script FFGanonRoom{
	void run(int boss, int linkholdtile, int triforcetile, int dropitem){
		if (Screen->State[ST_SECRET]) Quit();
		if (dropitem==0)dropitem = I_TRIFORCEBIG;
		Screen->Lit=false;
		Waitframes(30);
		Screen->Lit=true;
		Game->PlaySound(SFX_GANON);
		npc n = SpawnNPC(boss);
		Link->Invisible=true;
		int tr_X = 0;
		int tr_Y = 0;
		for (int i=0; i<90; i++){
			Screen->FastTile(2, Link->X, Link->Y, linkholdtile, 6, OP_OPAQUE);
			Screen->FastTile(2, Link->X, Link->Y-16, triforcetile, 8, OP_OPAQUE);
			NoAction();
			Waitframe();
		}
		Link->Invisible=false;
		while(n->isValid()){
			tr_X = n->X+8;
			tr_Y = n->Y+8;
			Waitframe();
		}
		item dp = CreateItemAt(I_DUST_PILE, tr_X, tr_Y+4);
		item it = CreateItemAt(dropitem, tr_X, tr_Y);		
		it->Pickup=2;
		while(it->isValid())Waitframe();
		Game->PlaySound(SFX_SECRET);
		Screen->TriggerSecrets();
		Screen->State[ST_SECRET]=true;
	}
}