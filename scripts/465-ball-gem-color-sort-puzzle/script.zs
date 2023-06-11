const int SFX_COLORSORT_MOVE = 16;//Sound to play when putting a ball into jar

const int TILE_COLORSORT_TOP = 16094; //Tile used for jar top
const int TILE_COLORSORT_MIDDLE = 16095;//Tile used for jar middle
const int TILE_COLORSORT_BOTTOM = 16096;//Tile used for jar bottom
const int TILE_COLORSORT_BALL = 15953;//Tiles used to render balls. Must be ID of leftmost ball tile -1.
const int TILE_COLORSORT_GOAL = 16097;//Tile used to mark completed jars

const int LINK_MISC_BALL_IN_HAND = 0;//Link Misc variable to track which ball Link has in hand.
const int LINK_MISC_PREV_JAR = 1;//Link Misc variable to track which jar Link was drawn from.

const int CSET_COLORSORT = 7; //CSet used to render jars.
const int CSET_COLORSORT_BALLS = 2;//CSet used to render balls.
const int CSET_COLORSORT_DEFAULT = 7;//Cset used for unselected jar.
const int CSET_COLORSORT_GOAL = 8;//CSet used to mark completed jars

const int COLORSORT_SIZE_PER_UNIT = 8;//Unit to pixel conversion rate.

//Color/gem sorting puzzle.
//You have a number of jars. Some of them have colored gems stacked one on top of another. 
//You can grab top grm from jap and drop it into another jar, adding it on top of the stack.
//If all jars are either empty, or full of same-colored gems, puzzle is solved.
//
//1. Set up tiles to render jars, balls and goal marks. Tiles must be as tall as COLORSORT_SIZE_PER_UNIT constant, rest should be transparent.
//   Balls must be consecutive. 
//2. Set TILE_COLORSORT_BALL constant to 1 lower than ID of leftmost ball tile.
//3. Set up combo for bottom part of the jar what looks like, if jar was empty.
//4. Place jar FFC`s with combo from step 2 as Data and assigned script. Put solid combo underneath FFC.
// D0 to D5. IDs of ball colors (0-6), starting from bottom.
// D6 - #####.____ - jar capacity, in units.
//      _____.#### - >0 - It`s prohibited to place a ball onto different-colored one, unless placed back where it was taken from.


ffc script ColorSortPipe{
	void run(int ball1, int ball2, int ball3, int ball4, int ball5, int ball6, int set){
		int balls[6]={ball1, ball2,ball3,ball4,ball5, ball6};
		BallGravity(balls);
		Link->Misc[LINK_MISC_BALL_IN_HAND]=0;
		int cap = GetHighFloat(set);
		int flags = GetLowFloat(set);
		int drawy = this->Y;
		if (JarCompleted(balls,cap)) this->InitD[7]=1;
		while(true){
			if ((Link->Y == this->Y + 8 && (Link->X < this->X + 8 && Link->X > this->X - 8) && Link->Dir == DIR_UP)){
				if (Link->PressEx1){
					if (Link->Misc[LINK_MISC_BALL_IN_HAND] == 0){
						if ( GetLastNonZero(balls)>0){
							Link->Misc[LINK_MISC_BALL_IN_HAND] = RemoveFromArray (balls);
							Link->Misc[LINK_MISC_PREV_JAR] = FFCNum(this);
							this->InitD[7]=0;
							if (JarCompleted(balls, cap)) this->InitD[7]=1;
						}
					}
					else{
						if ((flags&1)==0 || Link->Misc[LINK_MISC_PREV_JAR]==FFCNum(this) || Link->Misc[LINK_MISC_BALL_IN_HAND]==GetLastNonZero(balls)|| GetLastNonZero(balls)==0){
							if (balls[cap-1]==0){
								AppendToArray(balls, Link->Misc[LINK_MISC_BALL_IN_HAND]);
								Link->Misc[LINK_MISC_BALL_IN_HAND]=0;
								Link->Misc[LINK_MISC_PREV_JAR]=0;
								Game->PlaySound(SFX_COLORSORT_MOVE);
								this->InitD[7]=0;
								if (JarCompleted(balls,cap)) this->InitD[7]=1;
								for (int i=1; i<=33; i++){
									if (i==33){
										Game->PlaySound(SFX_SECRET);
										Screen->TriggerSecrets();
										Screen->State[ST_SECRET] = true;
										break;
									}
									ffc s = Screen->LoadFFC(i);
									if (s->Script!=this->Script) continue;
									if (s->InitD[7]==0) break;
								}
							}
						}
					}
				}
			}
			//render jars and level of liquids in them
			drawy = this->Y;
			for (int i = 0; i<6; i++){
				if (balls[i]>0)Screen->FastTile(Cond(i<=4, 2, 4), this->X, drawy, TILE_COLORSORT_BALL+balls[i],CSET_COLORSORT_BALLS , OP_OPAQUE);
				drawy-=COLORSORT_SIZE_PER_UNIT;
			}
			drawy = this->Y;
			for (int t=1; t<=cap+1; t++){
				int tile = TILE_COLORSORT_MIDDLE;
				if (t==1) tile = TILE_COLORSORT_BOTTOM;
				if (t ==cap+1) tile = TILE_COLORSORT_TOP;
				Screen->FastTile(Cond(t==1, 2, 4), this->X, drawy, tile, CSET_COLORSORT, OP_OPAQUE);
				//Screen->DrawTile(Cond(t==1, 2, 4), this->X, drawy, tile, 1, 1, CSET_WATERJAR, -1, -1, 0, 0, 0, 0, true, OP_OPAQUE);
				drawy-=COLORSORT_SIZE_PER_UNIT;
			}
			drawy+=COLORSORT_SIZE_PER_UNIT;
			if (this->InitD[7]>0)Screen->FastTile(4, this->X, drawy, TILE_COLORSORT_GOAL,CSET_COLORSORT_GOAL,OP_OPAQUE);
			drawy = this->Y;
			if (Link->Misc[LINK_MISC_BALL_IN_HAND]>0)Screen->FastTile(3, Link->X, Link->Y-8, TILE_COLORSORT_BALL+Link->Misc[LINK_MISC_BALL_IN_HAND], CSET_COLORSORT_BALLS, OP_OPAQUE);
			Waitframe();
		}
	}
}

bool JarCompleted(int arr, int cap){
	if(GetLastNonZero(arr)==0)return true;
	int check = arr[0];
	for(int i=0; i<cap; i++){
		if (arr[i]!=check)return false;
	}
	return true;
}

void BallGravity(int arr){
	for( int i=1; i<6; i++){
		if (arr[i]==0)continue;
		int p=i;
		while(arr[p-1]==0){
			SwapArray(arr, p, p-1);
			p--;
		}
	}
}

void AppendToArray(int arr, int a){
	for (int i =0; i<SizeOfArray(arr);i++){
		if (arr[i]>0) continue;
		arr[i]=a;
		return;
	}
}

int GetLastNonZero(int arr){
	for (int i=SizeOfArray(arr)-1; i>=0;i--){
		if (arr[i]==0) continue;
		return  arr[i];
	}
	return 0;
}

int RemoveFromArray (int arr){
	for (int i=SizeOfArray(arr)-1; i>=0;i--){
		if (arr[i]==0) continue;
		int ret = arr[i];
		arr[i]=0;
		return ret;
	}
}

//Swaps two elements in the given array
void SwapArray(int arr, int pos1, int pos2){
	int r = arr[pos1];
	arr[pos1]=arr[pos2];
	arr[pos2]=r;
}