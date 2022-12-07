const int LKLK_STATE_DEFAULT = 0;
const int LKLK_STATE_EATING = 1;

const int LINK_MISC_EATEN=15;//Link Misc variable for checking, if Link was eaten by new LikeLike.

//Variant of LikeLike, but eats any counter, also displays message, when it eats item.
ffc script LikeLikeEX{
	void run(int enemyID){
		npc ghost = Ghost_InitAutoGhost(this, enemyID);
		
		int HF = ghost->Homing;
		int RR = ghost->Rate;
		int HNG = ghost->Hunger;
		int SPD = ghost->Step;
		
		int Eatcounter = Ghost_GetAttribute(ghost, 0, 1);//Counter reference to eat
		int Eatpower = Ghost_GetAttribute(ghost, 1, 1);//counter reduction amount.
		int Eatrate = Ghost_GetAttribute(ghost, 2, 30);//delay between counter reductions. in frames
		int EatItem = Ghost_GetAttribute(ghost, 3, 0);//Item to eat.
		int EatItemDelay = Ghost_GetAttribute(ghost, 4, 180);//Delay between engulfing Link and devouring item, in frames.
		int EatItemString = Ghost_GetAttribute(ghost, 5, 0);//String to display, when enemy eats item.
		
		ghost->Extend=3;
		
		Ghost_SetFlag(GHF_NORMAL);
		
		int OrigTile = ghost->OriginalTile;
		int State = 0;
		int haltcounter = -1;
		Link->Misc[LINK_MISC_EATEN]=0;
		
		while(true){
			if (State==0){
				haltcounter =  Ghost_ConstantWalk4(haltcounter, SPD, RR, HF, HNG);
				if (LinkCollision(ghost)&&Link->Misc[LINK_MISC_EATEN]==0){
					Game->PlaySound(SFX_OUCH);
					Link->HP-=ghost->Damage;
					Link->Misc[LINK_MISC_EATEN]=1;
					Ghost_X=Link->X;
					Ghost_Y=Link->Y;
					State = 1;
					haltcounter=Eatrate;
					Ghost_UnsetFlag(GHF_KNOCKBACK);
					Link->CollDetection=false;
				}
			}
			if (State==1){
				Link->X=ghost->X;
				Link->Y=ghost->Y;
				haltcounter--;
				if (haltcounter==0){
					if (Game->Counter[Eatcounter]>=Eatpower)Game->Counter[Eatcounter]-=Eatpower;
					else Game->Counter[Eatcounter]=0;
					haltcounter = Eatrate;
				}
				if (EatItem>0&& EatItemDelay>0){
					EatItemDelay--;
					if (EatItemDelay==0&&Ghost_HP>0){
						if (Link->Item[EatItem]){
							Link->Item[EatItem]=false;
							if (EatItemString>0)Screen->Message(EatItemString);
						}
					}
				}
			}
			//EaterAnimation(ghost, OrigTile, State, 4);
			if (!Ghost_Waitframe(this, ghost, true, false)){
			if (State==1)Link->Misc[LINK_MISC_EATEN]=0;
			Link->CollDetection=true;
			Quit();
			}
		}
	}
}

void EaterAnimation(npc ghost, int origtile, int state, int numframes){
	int offset = 0;
	Screen->FastTile(5, ghost->X, ghost->Y, ghost->Tile, ghost->CSet, OP_OPAQUE);
}