const int SFX_WATERJAR_MOVE = 16;//Sound to play when pouring liquid from one jar to another.
const int SFX_WATERJAR_SOLVED = 27;//Sound to play when puzzle is solved.

const int TILE_WATERJAR_TOP = 16094; //Tile used for jar top
const int TILE_WATERJAR_MIDDLE = 16095;//Tile used for jar middle
const int TILE_WATERJAR_BOTTOM = 16096;//Tile used for jar bottom
const int TILE_WATERJAR_WATER = 16093;//Tile used to render water level in jar
const int TILE_WATERJAR_GOAL_MARK = 16097;//Tile used to render goal mark.

const int LINK_MISC_JAR_IN_HAND = 0;//Link Misc variable to track which jar Link has in hand.

const int CSET_WATERJAR = 7; //CSet used to render water jars.
const int CSET_WATERJAR_ACTIVE = 8;//Cset used for selected jar to pour from.
const int CSET_WATERJAR_DEFAULT = 7;//Cset used for unselected jar.
const int CSET_WATERJAR_GOAL_MARK = 8;//Cset used to render goal marks on jars.

const int WATERJAR_SIZE_PER_UNIT = 4;//Unit to pixel conversion rate.

//You have a couple of jars with different capacity and amounts of liquid in them. 
//Some of them have goal marks. You can pour liquid from one jar to another until only either previous is empty or one filled up to it`s capacity.
//The goal is to end up with all marked jars having filled exactly up to marks placed on them.
// Stand on jar base, press A, then stand on another jar base and press A to pour liquid.

//1. Set up tiles to render jars, water units and goal marks. Tiles must be as tall as WATERJAR_SIZE_PER_UNIT constant, rest should be transparent.
//2. Set up combo for bottom part of the jar what looks like, if jar was empty.
//3. Place jar FFC`s with combo from step 2 as Data and assigned script.
// D0 - Jar capacity, in units.
// D1 - Initial amount of liquid in jar, in units.
// D2 - Target amount of liquid in jar, in units.
//    - If set to 0, the jar must be empty to solve the puzzle.
//    - Set to -1 to remove mark at all.
ffc script WaterJar{
	void run (int capacity, int amount, int goal){
		this->InitD[6] = CSET_WATERJAR_DEFAULT;
		Link->Misc[LINK_MISC_JAR_IN_HAND] = 0;
		int drawy = this->Y;
		while (true){
			if (this->InitD[7]==0){
				if ((Link->Y == this->Y + 8 && (Link->X < this->X + 8 && Link->X > this->X - 8) && Link->Dir == DIR_UP)){
					if (Link->PressEx1){
						if (Link->Misc[LINK_MISC_JAR_IN_HAND] == 0){
							Link->Misc[LINK_MISC_JAR_IN_HAND] = FFCNum(this);
							this->InitD[6] = CSET_WATERJAR_ACTIVE;
						}
						else {
							if (Link->Misc[LINK_MISC_JAR_IN_HAND] != FFCNum(this)){
								Game->PlaySound(SFX_WATERJAR_MOVE);
								ffc f= Screen->LoadFFC(Link->Misc[LINK_MISC_JAR_IN_HAND]);
								while (this->InitD[1]<capacity){
									if (f->InitD[1]<=0) break;
									this->InitD[1]++;
									f->InitD[1]--;
									this->InitD[7] -= WATERJAR_SIZE_PER_UNIT;
									f->InitD[7] += WATERJAR_SIZE_PER_UNIT;
								}
								f->InitD[6] = CSET_WATERJAR_DEFAULT;
								Link->Misc[LINK_MISC_JAR_IN_HAND] = 0;
							}
							else {
								this->InitD[6] = CSET_WATERJAR_DEFAULT;
								Link->Misc[LINK_MISC_JAR_IN_HAND] = 0;
							}
						}
						for (int i=1; i<=33; i++){
							if (i==33){
								Game->PlaySound(SFX_WATERJAR_SOLVED);
								Screen->TriggerSecrets();
								Screen->State[ST_SECRET] = true;
								break;
							}
							ffc s = Screen->LoadFFC(i);
							if (s->Script!=this->Script) continue;
							if (s->InitD[2]<0)continue;
							if (s->InitD[1]!= s->InitD[2]) break;
						}
					}
				}
			}
			else{
				if (this->InitD[7]<0)this->InitD[7]++;
				else if (this->InitD[7]>0) this->InitD[7]--;
			}
			//render jars and level of liquids in them
			drawy = this->Y;
			int numtiles = this->InitD[1]*WATERJAR_SIZE_PER_UNIT + this->InitD[7];
			for (int i = 1; i<=numtiles; i++){
				Screen->FastTile(Cond(i<=4, 2, 4), this->X, drawy, TILE_WATERJAR_WATER, this->InitD[6], OP_OPAQUE);
				drawy--;
			}
			drawy = this->Y;
			for (int t=1; t<=capacity+1; t++){
				int tile = TILE_WATERJAR_MIDDLE;
				if (t==1) tile = TILE_WATERJAR_BOTTOM;
				if (t ==capacity+1) tile = TILE_WATERJAR_TOP;
				Screen->FastTile(Cond(t==1, 2, 4), this->X, drawy, tile, CSET_WATERJAR, OP_OPAQUE);
				//Screen->DrawTile(Cond(t==1, 2, 4), this->X, drawy, tile, 1, 1, CSET_WATERJAR, -1, -1, 0, 0, 0, 0, true, OP_OPAQUE);
				drawy-=WATERJAR_SIZE_PER_UNIT;
			}
			drawy = this->Y;
			if (goal>=0)Screen->FastTile(Cond(goal<2, 2, 4), this->X, this->Y-(goal*WATERJAR_SIZE_PER_UNIT), TILE_WATERJAR_GOAL_MARK, CSET_WATERJAR_GOAL_MARK, OP_OPAQUE);
			Waitframe();
		}
	}
}