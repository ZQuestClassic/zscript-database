const int mapOne = 1; //Map number of the first state of the dungeon
const int mapTwo = 2; //Map number of the second state of the dungeon
const int mapThree = 3; //Map number of the first state of the dungeon if you want another dungeon with it.
const int mapFour = 4; //Map number of the second state of the dungeon if you want another dungeon with it.


void UpdateMap(){
	int index = Game->GetCurScreen();
	
	if( Game->GetCurMap() == mapOne){
		Game->SetScreenState(mapTwo, index, ST_VISITED, true);
	}
	else if (Game->GetCurMap() == mapTwo){
		Game->SetScreenState(mapOne, index, ST_VISITED, true);
	}
		if( Game->GetCurMap() == mapThree){
		Game->SetScreenState(mapFour, index, ST_VISITED, true);
	}
	else if (Game->GetCurMap() == mapFour){
		Game->SetScreenState(mapThree, index, ST_VISITED, true);
	}
}

global script MultiStateDungeonMap{
	void run(){
		while(true){
			UpdateMap(); // Add this to your global script

			Waitframe();
		}
	}
}