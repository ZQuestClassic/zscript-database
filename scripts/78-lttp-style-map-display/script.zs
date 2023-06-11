//Must have all of these at least once in your script file
import "std.zh"
import "string.zh"
import "ffcScript.zh"
import "stdExtra.zh"

//Notes
//Must have spacebar map enabled on each DMap or rooms will not be marked visited

//==== Constants ====
const int RT_BITMAPDUNGMAP = 0; //Bitmap to draw to

//Room features
const int MAP_ROOM_NONE = -1; //No room
const int MAP_ROOM_EMPTY = 0; //No feature
const int MAP_ROOM_CHEST = 1; //Chest (goes away when chest opened)
const int MAP_ROOM_MBOSS = 2; //Miniboss (goes away when permanent secrets triggered)
const int MAP_ROOM_BOSS = 4; //Boss (ditto miniboss)
const int MAP_ROOM_STAIR = 8; //Stairs (or portals)
const int MAP_ROOM_TRIFORCE = 16; //The Triforce piece (or whatever you're collecting)
const int MAP_ROOM_ENTRANCE = 32; //The dungeon's entrance(s)
const int MAP_ROOM_SECRET = 64; //Major secret (goes away when secrets triggered)
const int MAP_ROOM_HEAL = 128; //Healing (fairy fountain, etc)

//Connection directions
const int MAP_ROOM_UP = 256;
const int MAP_ROOM_DOWN = 512;
const int MAP_ROOM_LEFT = 1024;
const int MAP_ROOM_RIGHT = 2048;

//Tiles/CSets
const int MAP_TILE_BG = 19760; //Top-left corner of map BG (11x7 tile block)
const int MAP_TILE_CSET = 8; //CSet of this tile block

const int MAP_TILE_CHEST = 19900; //8x8 pixel icons for each room feature
const int MAP_TILE_MBOSS = 19901; //(Placed in top-left of their respective tiles)
const int MAP_TILE_BOSS = 19902;
const int MAP_TILE_STAIR = 19903;
const int MAP_TILE_TRIFORCE = 19904;
const int MAP_TILE_ENTRANCE = 19905;
const int MAP_TILE_SECRET = 19906;
const int MAP_TILE_HEAL = 19907;
const int MAP_TILE_UPARROW = 19908; //Arrow indicating an upper floor
const int MAP_TILE_DOWNARROW = 19909; //Arrow indicating a lower floor

const int MAP_CSET_CHEST = 0; //CSets of the above tiles
const int MAP_CSET_MBOSS = 0;
const int MAP_CSET_BOSS = 0;
const int MAP_CSET_STAIR = 0;
const int MAP_CSET_TRIFORCE = 0;
const int MAP_CSET_ENTRANCE = 0;
const int MAP_CSET_SECRET = 0;
const int MAP_CSET_HEAL = 0;
const int MAP_CSET_UPARROW = 0;
const int MAP_CSET_DOWNARROW = 0;

//Room colors
const int MAP_COLOR_NOVISIT = 177; //Color of a non-visited room (with map)
const int MAP_COLOR_VISIT = 178; //Color of a visited room
const int MAP_COLOR_CURRENT = 4; //The room you're in
const int MAP_COLOR_BORDER = 7; //Border of the room

//This global script can be used on its own or merged with your existing script.
global script LTTPMap{
	void run(){
		while(true){
			if ( Link->PressEx1 ){
				Link->PressEx1 = false;
				freezeScreen();
				showMap();
				unfreezeScreen();
			}
			Waitframe();
		}
	}
}

void showMap(){
	int X = MAP_ROOM_NONE; //No room
	
	int C = MAP_ROOM_CHEST;
	int M = MAP_ROOM_MBOSS;
	int B = MAP_ROOM_BOSS;
	int T = MAP_ROOM_TRIFORCE;
	int E = MAP_ROOM_ENTRANCE;
	int S = MAP_ROOM_SECRET;
	int H = MAP_ROOM_HEAL;
	
	int s = MAP_ROOM_STAIR;
	int u = MAP_ROOM_UP;
	int d = MAP_ROOM_DOWN;
	int l = MAP_ROOM_LEFT;
	int r = MAP_ROOM_RIGHT;
	
	//dungMaps setup:
		//For each map (one floor of a dungeon), make an 8x8 grid; each number is a room.
		//Fill in each room with the appropriate flags OR-ed (|) together
			//Example: C|B|u|d = chest, boss, door up, and door down
			//Only two icons (chest, boss, etc) can be shown in each room
			//Doors do not have this limitation
		//This is not a global array so it's safe to alter without re-starting your save
	int dungMaps[] = {
		//0: Dungeon of DOOM F1
		X    , B|d|r  , T|l, X, X, X, X, X,
		C|s|d, s|u    , X  , X, X, X, X, X,
		C|u|r, E|C|l|r, S|l, X, X, X, X, X,
		X    , X      , X  , X, X, X, X, X,
		X    , X      , X  , X, X, X, X, X,
		X    , X      , X  , X, X, X, X, X,
		X    , X      , X  , X, X, X, X, X,
		X    , X      , X  , X, X, X, X, X,
		
		//1: Dungeon of DOOM F2
		X    , X      , X  , X, X, X, X, X,
		s|r  , s|l    , X  , X, X, X, X, X,
		X    , X      , X  , X, X, X, X, X,
		X    , X      , X  , X, X, X, X, X,
		X    , X      , X  , X, X, X, X, X,
		X    , X      , X  , X, X, X, X, X,
		X    , X      , X  , X, X, X, X, X,
		X    , X      , X  , X, X, X, X, X
	};

	int mapNumber = -1; //Find out which map to display
	int row;
	//mapNumber: Which row we are using
	
	//Find a map matching this DMap
	for ( row = 0; row < MAP_INDEXCOUNT; row++ ){
		if ( Game->GetCurDMap() == mapIndex(row, MAPINDEX_DMAP) ){
			mapNumber = mapIndex(row, MAPINDEX_MAPNUM);
			break;
		}
	}
	
	//If no map found for this DMap, quit
	if ( mapNumber == -1 )
		return;

	//Set position of the map to be drawn
	int mapX = 40;
	int mapY = 32;
	
	int curScrIndex = screenToIndex(Game->GetCurScreen(), mapNumber); //Find out where Link is relative to the whole map
	
	//DRAW THE MAP
	generateMap(dungMaps, mapX, mapY, row, curScrIndex);

	//Until player closes map with start or EX1
	NoAction();
	while(!Link->PressStart && !Link->PressEx1){
		//Put anything you need to draw, like ghost enemies, here
		//DrawGhostFFCs();
		
		//Floor switching
		if ( Link->PressUp //If Link presses up
		&& mapIndex(row, MAPINDEX_UP) >= 0 ){ //And upper floor exists
			row = mapIndex(row, MAPINDEX_UP); //Go to upper floor
			generateMap(dungMaps, mapX, mapY, row, curScrIndex); //Generate new map
		}
		
		else if ( Link->PressDown //If Link presses down
		&& mapIndex(row, MAPINDEX_DOWN) >= 0 ){ //And lower floor exists
			row = mapIndex(row, MAPINDEX_DOWN); //Go to lower floor
			generateMap(dungMaps, mapX, mapY, row, curScrIndex); //Generate new map
		}
		
		//Draw BG and pre-generated map
		Screen->DrawBitmap( 7, RT_BITMAPDUNGMAP, 0, 0, SCREEN_WIDTH, SCREEN_HEIGHT, 0, 0, SCREEN_WIDTH, SCREEN_HEIGHT, 0, true);
		
		//Wait and disable inputs
		WaitNoAction();
	}
		
	//Start (or error): Exit subscreen
	return;
}

//MapIndex setup
	//Create an index row for each DMap that uses the mapDisplay
	//Insert the following values for each row:
		//Which map (from dungMaps[]) to show
		//What map the screen is on
		//What DMap this is
		//What level the DMap is (dungeon level, not floor)
		//Index row of floor above this (-1 means there is no floor above)
		//Ditto below
	//Set MAP_INDEXCOUNT to the number of index rows you have.
	//It's safe to edit this without re-starting your save file.
const int MAP_INDEXCOUNT = 2; //Number of entries

const int MAPINDEX_WIDTH = 6; //Width of index array
const int MAPINDEX_MAPNUM = 0; //Map display number
const int MAPINDEX_MAP = 1; //DMap number
const int MAPINDEX_DMAP = 2; //DMap number
const int MAPINDEX_LEVEL = 3; //Level number
const int MAPINDEX_UP = 4; //What mapIndex entry is up from here (-1 = none)
const int MAPINDEX_DOWN = 5; //What mapIndex entry is down from here
int mapIndex(int row, int slot){
	int mapIndex[] =
	{
		//Map layout, Map, DMap, Level, Up, Down
		0           , 1  ,  0  , 1    ,  1, -1, //0: Dungeon of DOOM F1
		1           , 1  ,  1  , 1    , -1,  0 //1: Dungeon of DOOM F2
	};
	if(slot < 0 || slot >= MAPINDEX_WIDTH )
		return -1;
	return mapIndex[(row*MAPINDEX_WIDTH)+slot];
}

void generateMap(int dungMaps, int mapX, int mapY, int row, int curScrIndex){
	int mapNumber = mapIndex(row, MAPINDEX_MAPNUM);
	bool hasMap = Game->LItems[mapIndex(row, MAPINDEX_LEVEL)] & LI_MAP; //Whether Link has the map item
	bool hasCompass = Game->LItems[mapIndex(row, MAPINDEX_LEVEL)] & LI_COMPASS; //Whether Link has the compass item
	
	Screen->SetRenderTarget(RT_BITMAPDUNGMAP);
	Screen->Rectangle(7, 0, 0, SCREEN_WIDTH, SCREEN_HEIGHT, 0, 1, 0, 0, 0, true, OP_OPAQUE);
	
	//Draw the background
	Screen->DrawTile(7, mapX, mapY, MAP_TILE_BG, 11, 7, MAP_TILE_CSET, -1, -1, 0, 0, 0, 0, true, 128);
	
	//And title
	int dmapNum = mapIndex(row, MAPINDEX_DMAP);
	int dmapName[21];
	Game->GetDMapTitle(dmapNum, dmapName);
	//Change trailing spaces to NULLs
	int space[] = " ";
	for(int i = 20; i >= 0; i--){
		if(dmapName[i] == space[0])
			dmapName[i] = 0;
		//Once last non-space is reached, quit
		else if (dmapName[i] != 0)
			break;
	}
	//Draw the resulting DMap name on the map
	Screen->DrawString(7, mapX+88, mapY-8, FONT_L, COLOR_WHITE, -1, TF_CENTERED, dmapName, OP_OPAQUE);
	
	//Draw up/down arrows if any
	if(mapIndex(row, MAPINDEX_UP) >= 0)
		Screen->FastTile(7, mapX+160, mapY-16, MAP_TILE_UPARROW, MAP_CSET_UPARROW, OP_OPAQUE);
	if(mapIndex(row, MAPINDEX_DOWN) >= 0)
		Screen->FastTile(7, mapX+160, mapY, MAP_TILE_DOWNARROW, MAP_CSET_DOWNARROW, OP_OPAQUE);
	
	//Room drawing
	for ( int y = 0; y < 8; y++ ){ //For each row
		for ( int x = 0; x < 8; x++ ){ //And column
			int index = (mapNumber*64) + (y*8) + x; //Find index in map array (each map is 64 #s)
			int screen = indexToScreen(index, dmapNum); //Find actual screen number (not DMap!) from DMap offset
			int color = MAP_COLOR_NOVISIT; //The color of this screen on the map
			int icons[4] = {0, 0, 0, 0}; //Icon1, CSet1, Icon2, CSet2
			int roomX = mapX + 8 + x*20; //Position of room on screen
			int roomY = mapY + 8 + y*10;
			
			
			//If room doesn't exist or isn't visted and no map, skip it
			if ( dungMaps[index] < 0 || (!hasMap && !Game->GetScreenState(Game->GetCurMap(), screen, ST_VISITED)) )
				continue;
				
			//Otherwise, set the color
			if ( Game->GetScreenState(mapIndex(row, MAPINDEX_MAP), screen, ST_VISITED) ) //Room is visited
				color = MAP_COLOR_VISIT;
			if ( index == curScrIndex ) //Current room
				color = MAP_COLOR_CURRENT;
			// else //Room not visited
				// color = MAP_COLOR_NOVISIT;
			
			//Once color is set, draw the room.
			Screen->Rectangle(7, roomX, roomY, roomX+20, roomY+10, color, 1, 0, 0, 0, true, 128); //BG
			Screen->Rectangle(7, roomX, roomY, roomX+20, roomY+10, MAP_COLOR_BORDER, 1, 0, 0, 0, false, 128); //Border
						
			//Draw connections
			if ( dungMaps[index] & MAP_ROOM_UP )
				//Screen->PutPixel(7, roomX+10, roomY, color, 0, 0, 0, OP_OPAQUE);
				Screen->Line(7, roomX+9, roomY, roomX+11, roomY, color, 1, 0, 0, 0, OP_OPAQUE);
			if ( dungMaps[index] & MAP_ROOM_DOWN )
				//Screen->PutPixel(7, roomX+10, roomY+10, color, 0, 0, 0, OP_OPAQUE);
				Screen->Line(7, roomX+9, roomY+10, roomX+11, roomY+10, color, 1, 0, 0, 0, OP_OPAQUE);
			if ( dungMaps[index] & MAP_ROOM_LEFT )
				//Screen->PutPixel(7, roomX, roomY+5, color, 0, 0, 0, OP_OPAQUE);
				Screen->Line(7, roomX, roomY+4, roomX, roomY+6, color, 1, 0, 0, 0, OP_OPAQUE);
			if ( dungMaps[index] & MAP_ROOM_RIGHT )
				//Screen->PutPixel(7, roomX+20, roomY+5, color, 0, 0, 0, OP_OPAQUE);
				Screen->Line(7, roomX+20, roomY+4, roomX+20, roomY+6, color, 1, 0, 0, 0, OP_OPAQUE);
				//Line(int layer, int x, int y, int x2, int y2, int color, float scale, int rx, int ry, int rangle, int opacity);
			
			//Finally, the icon(s). If no compass, skip these.
			if(hasCompass)
			{
				if ( dungMaps[index] & MAP_ROOM_SECRET
				  && !Game->GetScreenState(Game->GetCurMap(), screen, ST_SECRET)){	//Secret
					addMapIcon(icons, MAP_TILE_SECRET, MAP_CSET_SECRET);
				}
				if ( dungMaps[index] & MAP_ROOM_BOSS
				  && !Game->GetScreenState(Game->GetCurMap(), screen, ST_SECRET)){	//Boss
					addMapIcon(icons, MAP_TILE_BOSS, MAP_CSET_BOSS);
				}
				if ( dungMaps[index] & MAP_ROOM_MBOSS
				  && !Game->GetScreenState(Game->GetCurMap(), screen, ST_SECRET)){	//Miniboss
					addMapIcon(icons, MAP_TILE_MBOSS, MAP_CSET_MBOSS);
				}
				if ( dungMaps[index] & MAP_ROOM_TRIFORCE
				  && !(Game->LItems[Game->GetCurLevel()] & LI_TRIFORCE) ){			//Triforce
					addMapIcon(icons, MAP_TILE_TRIFORCE, MAP_CSET_TRIFORCE);
				}
				if ( dungMaps[index] & MAP_ROOM_CHEST
				&& !Game->GetScreenState(Game->GetCurMap(), screen, ST_CHEST)
				&& !Game->GetScreenState(Game->GetCurMap(), screen, ST_LOCKEDCHEST)
				&& !Game->GetScreenState(Game->GetCurMap(), screen, ST_BOSSCHEST)
				&& !Game->GetScreenState(Game->GetCurMap(), screen, ST_ITEM)){		//Chest
					addMapIcon(icons, MAP_TILE_CHEST, MAP_CSET_CHEST);
				}
				if ( dungMaps[index] & MAP_ROOM_ENTRANCE ){							//Entrance
					addMapIcon(icons, MAP_TILE_ENTRANCE, MAP_CSET_ENTRANCE);
				}
				if ( dungMaps[index] & MAP_ROOM_STAIR ){							//Stair
					addMapIcon(icons, MAP_TILE_STAIR, MAP_CSET_STAIR);
				}
				if ( dungMaps[index] & MAP_ROOM_HEAL ){								//Healing pad
					addMapIcon(icons, MAP_TILE_HEAL, MAP_CSET_HEAL);
				}
				if ( icons[2] > 0 ){ //Two icons filling the room
					Screen->FastTile( 7, roomX+1, roomY+1, icons[0], icons[1], 128 );
					Screen->FastTile( 7, roomX+11, roomY+1, icons[2], icons[3], 128 );
				}
				else if ( icons[0] > 0 ){ //One icon in middle of room
					Screen->FastTile( 7, roomX+6, roomY+1, icons[0], icons[1], 128 );
				}
			}
		}
	}
	Screen->SetRenderTarget(RT_SCREEN);
}

void addMapIcon(int icons, int tile, int cset){
	if ( icons[0] == 0 ){
		icons[0] = tile;
		icons[1] = cset;
	}
	else if ( icons[2] == 0 ){
		icons[2] = tile;
		icons[3] = cset;
	}
}

int screenToIndex(int screen, int mapNumber){
	// if ( screen >= 0x10 ){ //Row is more than 1
		// int row = curScrIndex/0x10; //Find row #
		// curScrIndex -= row*8; //Subtract half the row size * # rows
	// }
	int doffset = Game->DMapOffset[Game->GetCurDMap()];
	return (screen & 0xF) - doffset + ((screen >> 4) * 8) + (mapNumber * 64);
}

int indexToScreen(int index, int dmap){
	index %= 64;
	int doffset = Game->DMapOffset[dmap];
	return (index & 7) + doffset + (index >> 3) * 16;
}