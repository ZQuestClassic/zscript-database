//Used for defining minimap sectors on a large map
void Minimap_GetSectorDefinitions(){
	//MiniMap_DefineSector(int map, int sector, int dmap, int xoff, int yoff)
	//Safe ranges for 16x8 maps:
	//		X: -16, 16
	//		Y: -20, 20
}

const int MINIMAP_LAYER = 7; //Layer the minimap is drawn to
//X and Y position of the minimap on the subscreen
const int MINIMAP_X = 27;
const int MINIMAP_Y = 16;
const int MINIMAP_SQUARESIZE = 6; //Width/Height of a minimap square in pixels
//Width and height of the minimap in screens
const int MINIMAP_TILEWIDTH = 7;
const int MINIMAP_TILEHEIGHT = 5;

const int MINIMAP_MAPWIDTH = 16; //Max width of a map 

const int MINIMAP_MAPS = 10; //First of 4 maps used for minimaps
const int MINIMAP_MARKERMAPS = 14; //First of 4 maps used for minimap markers

const int MINIMAP_USELEVELNUM = 1; //Set to 1 to use level numbers instead of DMaps for getting reference maps
const int MINIMAP_CLAMPPOSITION = 0; //Set to 1 to clamp the position of the minimap to the play area, if 0, Link's position will always be centered
const int MINIMAP_MARKERSREQUIREVISITED = 1; //Set to 1 to make it so markers require you have visited the screen to display
const int MINIMAP_REQUIREDUNGEONMAP = 1; //Set to 1 to require the dungeon map to view unexplored (not hidden) rooms
const int MINIMAP_REQUIRECOMPASS = 1; //Set to 1 to require the compass to view map markers

const int MINIMAP_LARGEMAP_ENABLED = 1; //Set to 1 to enable opening the large map with the "Map" button
const int MINIMAP_LARGEMAP_OPENCLOSEFRAMES = 32; //Frames taken to open the large map
const int MINIMAP_LARGEMAP_FRAMEDRAWCAP = 500; //Rough maximum of draw instructions to run per frame when loading the large map
const int MINIMAP_LARGEMAP_DEBUG = 0; //Set to 1 to show all hidden squares on the large map

const int C_MINIMAP_OUTLINE = 0x01; //Outline color for the minimap
const int C_MINIMAP_BG = 0x0F; //Background color for the minimap
const int C_MINIMAP_DEBUG = 0x02; //Color used for debug draws

const int CF_HIDDENROOM = 98; //Combo flag marking minimap screens as hidden

const int DMF_ENABLEMINIMAP = 1; //DMap flag used for minimaps (1-5, Script 1 by default)

//Two off-screen bitmaps (0-6) to use for drawing the large map
const int RT_LARGEMAP1 = 0;
const int RT_LARGEMAP2 = 1;

const int FFC_SCREENFREEZEA = 31;
const int CMB_SCREENFREEZEA = 2;
const int FFC_SCREENFREEZEB = 32;
const int CMB_SCREENFREEZEB = 3;

//Functions for freezing/unfreezing the screen
void FreezeScreen(){
	ffc a = Screen->LoadFFC(FFC_SCREENFREEZEA);
	a->Data = CMB_SCREENFREEZEA;
	ffc b = Screen->LoadFFC(FFC_SCREENFREEZEB);
	b->Data = CMB_SCREENFREEZEB;
}
void UnfreezeScreen(){
	ffc a = Screen->LoadFFC(FFC_SCREENFREEZEA);
	a->Data = 0;
	ffc b = Screen->LoadFFC(FFC_SCREENFREEZEB);
	b->Data = 0;
}

const int _LML_BGCMB = 0;
const int _LML_BGCS = 2304;
const int _LML_LAYOUTCMB = 4608;
const int _LML_LAYOUTCS = 6912;
const int _LML_MARKERCMB = 9216;
const int _LML_MARKERCS = 11520;

int LargeMapLayout[13824]; //Size should be 48*48*6

//Indices for global variables
const int _LMD_CURDRAWINDEX = 0;
const int _LMD_DRAWCOUNT = 1;
const int _LMD_MINX = 2;
const int _LMD_MAXX = 3;
const int _LMD_MINY = 4;
const int _LMD_MAXY = 5;
const int _LMD_LINKPOS = 6;
const int _LMD_LARGEMAPSTATE = 7;
const int _LMD_LARGEMAPFRAMES = 8;
const int _LMD_MAPVIEWX = 9;
const int _LMD_MAPVIEWY = 10;
const int _LMD_MAPDEFS = 16;

//Indices for map sectors (3-dimensional, map x sector x index)
const int _LMD_DMAP = 0;
const int _LMD_XOFF = 1;
const int _LMD_YOFF = 2;
const int _LMD_SECTORSIZE = 3;
//
const int _LMD_MAXMAPS = 4; //Max number of large maps
const int _LMD_MAXMAPSECTORS = 32; //Max number of sectors for maps

int LargeMapData[400]; //Size should be at least _LMD_MAPDEFS+_LMD_MAXMAPS*_LMD_MAXMAPSECTORS*_LMD_SECTORSIZE

void MiniMap_Init(){
	LargeMapData[_LMD_LARGEMAPSTATE] = 0;
	for(int i=0; i<_LMD_MAXMAPS*_LMD_MAXMAPSECTORS; ++i){
		LargeMapData[_LMD_MAPDEFS+_LMD_SECTORSIZE*i+_LMD_DMAP] = -1;
	}
	Minimap_GetSectorDefinitions();
}

//Defines a single sector in the large map
void MiniMap_DefineSector(int map, int sector, int dmap, int xoff, int yoff){
	LargeMapData[_LMD_MAPDEFS+_LMD_MAXMAPSECTORS*_LMD_SECTORSIZE*map+_LMD_SECTORSIZE*sector+_LMD_DMAP] = dmap;
	LargeMapData[_LMD_MAPDEFS+_LMD_MAXMAPSECTORS*_LMD_SECTORSIZE*map+_LMD_SECTORSIZE*sector+_LMD_XOFF] = 16+xoff;
	LargeMapData[_LMD_MAPDEFS+_LMD_MAXMAPSECTORS*_LMD_SECTORSIZE*map+_LMD_SECTORSIZE*sector+_LMD_YOFF] = 20+yoff;
}

void Minimap_Update(){
	//Don't bother with either map if the flag is checked
	if(!(Game->DMapFlags[Game->GetCurDMap()]&(1<<(10+DMF_ENABLEMINIMAP)))||Game->GetCurScreen()>=0x80){
		if(MINIMAP_LARGEMAP_ENABLED){
			Link->InputMap = false; Link->PressMap = false;
		}
		return;
	}
	
	Minimap_UpdateMapSubscreen();
	
	//Don't bother with the minimap if the large map is open
	if(LargeMapData[_LMD_LARGEMAPSTATE]!=0)
		return;
	
	int refMap; int refMarkerMap; int refScrn;
	//Get the maps to reference for map drawing
	if(MINIMAP_USELEVELNUM){
		refMap = MINIMAP_MAPS+Floor(Game->GetCurLevel()/128);
		refMarkerMap = MINIMAP_MARKERMAPS+Floor(Game->GetCurLevel()/128);
		refScrn = Game->GetCurLevel()%128;
	}
	else{
		refMap = MINIMAP_MAPS+Floor(Game->GetCurDMap()/128);
		refMarkerMap = MINIMAP_MARKERMAPS+Floor(Game->GetCurDMap()/128);
		refScrn = Game->GetCurDMap()%128;
	}
	
	int dmapOffset = Game->DMapOffset[Game->GetCurDMap()];
	
	//Get the map X and Y position of the top-left corner of the minimap
	int offX = (Game->GetCurDMapScreen()%16)-Floor((MINIMAP_TILEWIDTH-1)/2);
	int offY = Floor(Game->GetCurDMapScreen()/16)-Floor((MINIMAP_TILEHEIGHT-1)/2);
	if(MINIMAP_CLAMPPOSITION){
		offX = Clamp(offX, 0, MINIMAP_MAPWIDTH-MINIMAP_TILEWIDTH);
		offY = Clamp(offY, 0, 8-MINIMAP_TILEHEIGHT);
	}
	
	int bgCD = Game->GetComboData(refMap, refScrn, 160);
	
	int roomX; int roomY; int roomPos; 
	int roomVisited; int markerState;
	int roomCD; int roomCS; int roomCF;
	int markerCD; int markerCS; int markerCT;
	
	//Draw the rectangle background
	if(C_MINIMAP_BG)
		Screen->Rectangle(MINIMAP_LAYER, MINIMAP_X, MINIMAP_Y-56, MINIMAP_X+MINIMAP_SQUARESIZE*MINIMAP_TILEWIDTH, MINIMAP_Y-56+MINIMAP_SQUARESIZE*MINIMAP_TILEHEIGHT, C_MINIMAP_BG, 1, 0, 0, 0, true, 128);
	
	//Cycle through all minimap squares to draw
	for(int x=0; x<MINIMAP_TILEWIDTH; ++x){
		for(int y=0; y<MINIMAP_TILEHEIGHT; ++y){
			roomX = offX+x;
			roomY = offY+y;
			roomPos = roomX+roomY*16;
			if(roomX>=0&&roomX<=MINIMAP_MAPWIDTH-1&&roomY>=0&&roomY<=7){
				roomCD = Game->GetComboData(refMap, refScrn, roomPos);
				roomCS = Game->GetComboCSet(refMap, refScrn, roomPos);
				roomCF = Game->GetComboFlag(refMap, refScrn, roomPos);
				markerCD = Game->GetComboData(refMarkerMap, refScrn, roomPos);
				markerCS = Game->GetComboCSet(refMarkerMap, refScrn, roomPos);
				markerCT = Game->GetComboType(refMarkerMap, refScrn, roomPos);
				roomVisited = 0;
				markerState = 0;
				
				//Check if Link has visited or is in this screen
				if(roomPos==Game->GetCurDMapScreen())
					roomVisited = 2;
				else if(roomPos+dmapOffset<0x80&&Game->GetScreenState(Game->GetCurMap(), roomPos+dmapOffset, ST_VISITED))
					roomVisited = 1;
				//Hidden rooms are marked with a flag so they're visible in the editor but not in normal play until visited
				if(roomCF==CF_HIDDENROOM&&roomVisited==0)
					roomCD = 0;
				//Prevent showing unvisited rooms without the map
				if(!(Game->LItems[Game->GetCurLevel()]&LI_MAP)&&MINIMAP_REQUIREDUNGEONMAP&&roomVisited==0)
					roomCD = 0;
				//If the combo at that position >0, this is a valid screen to draw
				if(roomCD){
					//If the background combo was set, draw that under the screen first
					if(bgCD){
						Screen->FastCombo(MINIMAP_LAYER, MINIMAP_X+x*MINIMAP_SQUARESIZE, MINIMAP_Y-56+y*MINIMAP_SQUARESIZE, bgCD-1+roomVisited, roomCS, 128);
						Screen->FastCombo(MINIMAP_LAYER, MINIMAP_X+x*MINIMAP_SQUARESIZE, MINIMAP_Y-56+y*MINIMAP_SQUARESIZE, roomCD, roomCS, 128);
					}
					else
						Screen->FastCombo(MINIMAP_LAYER, MINIMAP_X+x*MINIMAP_SQUARESIZE, MINIMAP_Y-56+y*MINIMAP_SQUARESIZE, roomCD+roomVisited, roomCS, 128);
					//Check for markers on the layer screen
					if(markerCD&&(roomVisited||!MINIMAP_MARKERSREQUIREVISITED)&&(Game->LItems[Game->GetCurLevel()]&LI_COMPASS||!MINIMAP_REQUIRECOMPASS)&&roomPos+dmapOffset<0x80){
						//Item or Special Item
						if(markerCT==CT_CHEST){
							if(Game->GetScreenState(Game->GetCurMap(), roomPos+dmapOffset, ST_ITEM)||Game->GetScreenState(Game->GetCurMap(), roomPos+dmapOffset, ST_SPECIALITEM))
								markerState = 1;
						}
						//Item and Special Item (4 states)
						else if(markerCT==CT_BOSSCHEST){
							if(Game->GetScreenState(Game->GetCurMap(), roomPos+dmapOffset, ST_SPECIALITEM))
								++markerState;
							if(Game->GetScreenState(Game->GetCurMap(), roomPos+dmapOffset, ST_ITEM))
								markerState += 2;
						}
						//Boss level state
						else if(markerCT==CT_DAMAGE1){
							if(Game->LItems[Game->GetCurLevel()]&LI_BOSS)
								markerState = 1;
						}
						//Lock block
						else if(markerCT==CT_LOCKBLOCK){
							if(Game->GetScreenState(Game->GetCurMap(), roomPos+dmapOffset, ST_LOCKBLOCK))
								markerState = 1;
						}
						//Boss lock
						else if(markerCT==CT_BOSSLOCKBLOCK){
							if(Game->GetScreenState(Game->GetCurMap(), roomPos+dmapOffset, ST_BOSSLOCKBLOCK))
								markerState = 1;
						}
						//Secret combo
						else if(markerCT==CT_STEP){
							if(Game->GetScreenState(Game->GetCurMap(), roomPos+dmapOffset, ST_SECRET))
								markerState = 1;
						}
						Screen->FastCombo(MINIMAP_LAYER, MINIMAP_X+x*MINIMAP_SQUARESIZE, MINIMAP_Y-56+y*MINIMAP_SQUARESIZE, markerCD+markerState, markerCS, 128);
					}
				}
			}
		}
	}

	//Draw the rectangle outline
	if(C_MINIMAP_OUTLINE)
		Screen->Rectangle(MINIMAP_LAYER, MINIMAP_X, MINIMAP_Y-56, MINIMAP_X+MINIMAP_SQUARESIZE*MINIMAP_TILEWIDTH, MINIMAP_Y-56+MINIMAP_SQUARESIZE*MINIMAP_TILEHEIGHT, C_MINIMAP_OUTLINE, 1, 0, 0, 0, false, 128);
}

void Minimap_UpdateMapSubscreen(){
	int i; int j;
	if(!MINIMAP_LARGEMAP_ENABLED)
		return;
	if(LargeMapData[_LMD_LARGEMAPSTATE]==0){ //Map is closed
		if(Link->PressMap){
			LargeMapData[_LMD_LARGEMAPSTATE] = 1;
			LargeMapData[_LMD_LARGEMAPFRAMES] = 0;
			FreezeScreen();
			int currentMap = Minimap_GetCurrentLargeMap();
			for(i=0; i<2304; ++i){
				LargeMapLayout[_LML_BGCMB+i] = 0;
				LargeMapLayout[_LML_LAYOUTCMB+i] = 0;
				LargeMapLayout[_LML_MARKERCMB+i] = 0;
			}
			//If the current DMap isn't in the map array, just load that one
			if(currentMap==-1){
				Minimap_Overlay(Game->GetCurDMap(), 16, 20);
			}
			//Else load every other DMap in the same large map
			else{
				for(i=0; i<32; ++i){
					int dmap = LargeMapData[_LMD_MAPDEFS+_LMD_MAXMAPSECTORS*_LMD_SECTORSIZE*currentMap+_LMD_SECTORSIZE*i+_LMD_DMAP]; 
					if(dmap>-1){
						int xoff = LargeMapData[_LMD_MAPDEFS+_LMD_MAXMAPSECTORS*_LMD_SECTORSIZE*currentMap+_LMD_SECTORSIZE*i+_LMD_XOFF];
						int yoff = LargeMapData[_LMD_MAPDEFS+_LMD_MAXMAPSECTORS*_LMD_SECTORSIZE*currentMap+_LMD_SECTORSIZE*i+_LMD_YOFF];
						Minimap_Overlay(dmap, xoff, yoff);
					}
				}
			}
			Screen->SetRenderTarget(RT_LARGEMAP1);
			Screen->Rectangle(0, 0, 0, 511, 511, 0x00, 1, 0, 0, 0, true, 128);
			Screen->SetRenderTarget(RT_LARGEMAP2);
			Screen->Rectangle(0, 0, 0, 511, 511, 0x00, 1, 0, 0, 0, true, 128);
			LargeMapData[_LMD_CURDRAWINDEX] = 0;
			LargeMapData[_LMD_DRAWCOUNT] = 0;
			LargeMapData[_LMD_MINX] = -1;
			LargeMapData[_LMD_MINY] = -1;
			LargeMapData[_LMD_MAXX] = -1;
			LargeMapData[_LMD_MAXY] = -1;
		}
	}
	else if(LargeMapData[_LMD_LARGEMAPSTATE]==1){ //Map is opening
		Minimap_LoadLargeMapData();
		if(LargeMapData[_LMD_LARGEMAPFRAMES]>MINIMAP_LARGEMAP_OPENCLOSEFRAMES*0.6666){
			Screen->Rectangle(MINIMAP_LAYER, 0, -56, 255, 175, C_MINIMAP_BG, 1, 0, 0, 0, true, 128);
		}
		else{
			if(LargeMapData[_LMD_LARGEMAPFRAMES]>MINIMAP_LARGEMAP_OPENCLOSEFRAMES*0.3333)
				Screen->Rectangle(MINIMAP_LAYER, 0, -56, 255, 175, C_MINIMAP_BG, 1, 0, 0, 0, true, 64);
			Screen->Rectangle(MINIMAP_LAYER, 0, -56, 255, 175, C_MINIMAP_BG, 1, 0, 0, 0, true, 64);
		}
		if(LargeMapData[_LMD_LARGEMAPFRAMES]<MINIMAP_LARGEMAP_OPENCLOSEFRAMES)
			++LargeMapData[_LMD_LARGEMAPFRAMES];
		else{
			LargeMapData[_LMD_LARGEMAPSTATE] = 2;
			//Position the camera in the center of the map
			LargeMapData[_LMD_MAPVIEWX] = Floor((LargeMapData[_LMD_MINX]+LargeMapData[_LMD_MAXX]+1)*MINIMAP_SQUARESIZE/2)-128;
			LargeMapData[_LMD_MAPVIEWY] = Floor((LargeMapData[_LMD_MINY]+LargeMapData[_LMD_MAXY]+1)*MINIMAP_SQUARESIZE/2)-128;
		}
	}
	else if(LargeMapData[_LMD_LARGEMAPSTATE]==2){ //Map is open
		Screen->Rectangle(MINIMAP_LAYER, 0, -56, 255, 175, C_MINIMAP_BG, 1, 0, 0, 0, true, 128);
		Minimap_DrawBitmaps(LargeMapData[_LMD_MAPVIEWX], LargeMapData[_LMD_MAPVIEWY]);
		if(Link->PressMap){
			LargeMapData[_LMD_LARGEMAPSTATE] = 3;
			LargeMapData[_LMD_LARGEMAPFRAMES] = MINIMAP_LARGEMAP_OPENCLOSEFRAMES;
		}
		//Allow the camera to pan around
		LargeMapData[_LMD_MAPVIEWX] += Cond(Link->InputLeft, -2, 0) + Cond(Link->InputRight, 2, 0);
		LargeMapData[_LMD_MAPVIEWY] += Cond(Link->InputUp, -2, 0) + Cond(Link->InputDown, 2, 0);
		int edgeDist = 48;
		if(LargeMapData[_LMD_MAPVIEWX]<LargeMapData[_LMD_MINX]*MINIMAP_SQUARESIZE-edgeDist&&LargeMapData[_LMD_MAPVIEWX]>(LargeMapData[_LMD_MAXX]+1)*MINIMAP_SQUARESIZE+edgeDist-256)
			LargeMapData[_LMD_MAPVIEWX] = Floor((LargeMapData[_LMD_MINX]+LargeMapData[_LMD_MAXX]+1)*MINIMAP_SQUARESIZE/2)-128;
		else if(LargeMapData[_LMD_MAPVIEWX]<LargeMapData[_LMD_MINX]*MINIMAP_SQUARESIZE-edgeDist)
			LargeMapData[_LMD_MAPVIEWX] = LargeMapData[_LMD_MINX]*MINIMAP_SQUARESIZE-edgeDist;
		else if(LargeMapData[_LMD_MAPVIEWX]>(LargeMapData[_LMD_MAXX]+1)*MINIMAP_SQUARESIZE+edgeDist-256)
			LargeMapData[_LMD_MAPVIEWX] = (LargeMapData[_LMD_MAXX]+1)*MINIMAP_SQUARESIZE+edgeDist-256;
		
		if(LargeMapData[_LMD_MAPVIEWY]<LargeMapData[_LMD_MINY]*MINIMAP_SQUARESIZE-edgeDist&&LargeMapData[_LMD_MAPVIEWY]>(LargeMapData[_LMD_MAXY]+1)*MINIMAP_SQUARESIZE+24+edgeDist-256)
			LargeMapData[_LMD_MAPVIEWY] = Floor((LargeMapData[_LMD_MINY]+LargeMapData[_LMD_MAXY]+1)*MINIMAP_SQUARESIZE/2)-128;
		else if(LargeMapData[_LMD_MAPVIEWY]<LargeMapData[_LMD_MINY]*MINIMAP_SQUARESIZE-edgeDist)
			LargeMapData[_LMD_MAPVIEWY] = LargeMapData[_LMD_MINY]*MINIMAP_SQUARESIZE-edgeDist;
		else if(LargeMapData[_LMD_MAPVIEWY]>(LargeMapData[_LMD_MAXY]+1)*MINIMAP_SQUARESIZE+24+edgeDist-256)
			LargeMapData[_LMD_MAPVIEWY] = (LargeMapData[_LMD_MAXY]+1)*MINIMAP_SQUARESIZE+24+edgeDist-256;
		
	}
	else if(LargeMapData[_LMD_LARGEMAPSTATE]==3){ //Map is closed
		if(LargeMapData[_LMD_LARGEMAPFRAMES]>MINIMAP_LARGEMAP_OPENCLOSEFRAMES*0.6666){
			Screen->Rectangle(MINIMAP_LAYER, 0, -56, 255, 175, C_MINIMAP_BG, 1, 0, 0, 0, true, 128);
		}
		else{
			if(LargeMapData[_LMD_LARGEMAPFRAMES]>MINIMAP_LARGEMAP_OPENCLOSEFRAMES*0.3333)
				Screen->Rectangle(MINIMAP_LAYER, 0, -56, 255, 175, C_MINIMAP_BG, 1, 0, 0, 0, true, 64);
			Screen->Rectangle(MINIMAP_LAYER, 0, -56, 255, 175, C_MINIMAP_BG, 1, 0, 0, 0, true, 64);
		}
		if(LargeMapData[_LMD_LARGEMAPFRAMES])
			--LargeMapData[_LMD_LARGEMAPFRAMES];
		else{
			LargeMapData[_LMD_LARGEMAPSTATE] = 0;
			UnfreezeScreen();
		}
	}
	Screen->SetRenderTarget(RT_SCREEN);
	Link->InputMap = false; Link->PressMap = false;
}

void Minimap_DrawBitmaps(int x, int y){
	int origX = x;
	int origY = y;
	int sx = 0;
	int sy = 0;
	int w = 256;
	int h = 256;
	int offsc;
	//Allow the bitmap draws to go off the edges of the bitmap.
	//I don't like this math and I don't trust it.
	//Me and spatial awareness never got along great.
	if(x<0){
		offsc = -x;
		x = 0;
		sx += offsc;
		w -= offsc;
	}
	else if(x+w-1>511){
		offsc = ((x+w-1)-511);
		w -= offsc;
	}
	if(y<0){
		offsc = -y;
		y = 0;
		sy += offsc;
		h -= offsc;
	}
	else if(y+h-1>511){
		offsc = ((y+h-1)-511);
		h -= offsc;
	}
		
	//Draw Link's position to the bitmap so it can animate (this is the only exception for animated icons on the large map)
	Screen->SetRenderTarget(RT_LARGEMAP1);
	int linkPos = LargeMapData[_LMD_LINKPOS];
	int roomX = (linkPos%48)*MINIMAP_SQUARESIZE;
	int roomY = Floor(linkPos/48)*MINIMAP_SQUARESIZE;
	Screen->FastCombo(0, roomX, roomY, 2654, 7, 128);
	if(LargeMapLayout[_LML_LAYOUTCMB+linkPos]){
		if(LargeMapLayout[_LML_BGCMB+linkPos]){
			Screen->FastCombo(0, roomX, roomY, LargeMapLayout[_LML_BGCMB+linkPos]+1, LargeMapLayout[_LML_LAYOUTCS+linkPos], 128);
			Screen->FastCombo(0, roomX, roomY, LargeMapLayout[_LML_LAYOUTCMB+linkPos], LargeMapLayout[_LML_LAYOUTCS+linkPos], 128);
		}
		else{
			Screen->FastCombo(0, roomX, roomY, LargeMapLayout[_LML_LAYOUTCMB+linkPos]+1, LargeMapLayout[_LML_LAYOUTCS+linkPos], 128);
		}
	}
	Screen->SetRenderTarget(RT_SCREEN);
	Screen->DrawBitmap(MINIMAP_LAYER, RT_LARGEMAP1, x, y, w, h, sx, -56+sy, w, h, 0, true);
	Screen->DrawBitmap(MINIMAP_LAYER, RT_LARGEMAP2, x, y, w, h, sx, -56+sy, w, h, 0, true);
}

int Minimap_GetCurrentLargeMap(){
	for(int i=0; i<_LMD_MAXMAPS; ++i){
		for(int j=0; j<_LMD_MAXMAPSECTORS; ++j){
			if(LargeMapData[_LMD_MAPDEFS+_LMD_MAXMAPSECTORS*_LMD_SECTORSIZE*i+_LMD_SECTORSIZE*j+_LMD_DMAP]==Game->GetCurDMap())
				return i;
		}
	}
	return -1;
}

void Minimap_Overlay(int dmap, int xoff, int yoff){
	int refMap; int refMarkerMap; int refScrn;
	int level = Game->DMapLevel[dmap];
	//Get the maps to reference for map drawing
	if(MINIMAP_USELEVELNUM){
		refMap = MINIMAP_MAPS+Floor(level/128);
		refMarkerMap = MINIMAP_MARKERMAPS+Floor(level/128);
		refScrn = level%128;
	}
	else{
		refMap = MINIMAP_MAPS+Floor(dmap/128);
		refMarkerMap = MINIMAP_MARKERMAPS+Floor(dmap/128);
		refScrn = dmap%128;
	}
	
	int map = Game->DMapMap[dmap];
	int dmapOffset = Game->DMapOffset[dmap];
	
	int bgCD = Game->GetComboData(refMap, refScrn, 160);
	
	int xpos;
	int totalX; int totalY;
	int roomX;
	int roomVisited; int markerState;
	int roomCD; int roomCS; int roomCF;
	int markerCD; int markerCS; int markerCT;
	
	for(int i=0; i<128; ++i){
		xpos = i%16+dmapOffset;
		roomCD = Game->GetComboData(refMap, refScrn, i);
		if(roomCD&&xpos>=0&&xpos<=15){
			totalX = (i%16)+xoff;
			totalY = Floor(i/16)+yoff;
			roomX = (i%16)+dmapOffset;
			if(totalX>=0&&totalX<=47&&totalY>=0&&totalY<=47&&roomX>=0&&roomX<=15){
				roomCS = Game->GetComboCSet(refMap, refScrn, i);
				roomCF = Game->GetComboFlag(refMap, refScrn, i);
				markerCD = Game->GetComboData(refMarkerMap, refScrn, i);
				markerCS = Game->GetComboCSet(refMarkerMap, refScrn, i);
				markerCT = Game->GetComboType(refMarkerMap, refScrn, i);
				roomVisited = 0;
				markerState = 0;
				//Check if Link has visited or is in this screen
				if(dmap==Game->GetCurDMap()&&i==Game->GetCurDMapScreen())
					LargeMapData[_LMD_LINKPOS] = ((i%16)+xoff)+48*(Floor(i/16)+yoff);
				if(Game->GetScreenState(map, i+dmapOffset, ST_VISITED)&&i+dmapOffset>-1)
					roomVisited = 1;
				//Hidden rooms are marked with a flag so they're visible in the editor but not in normal play until visited
				if(roomCF==CF_HIDDENROOM&&roomVisited==0)
					roomCD = 0;
				//Prevent showing unvisited rooms without the map
				if(!(Game->LItems[level]&LI_MAP)&&MINIMAP_REQUIREDUNGEONMAP&&roomVisited==0)
					roomCD = 0;
				if(roomCD){
					//If the background combo was set, draw that under the screen first
					if(bgCD){
						LargeMapLayout[_LML_BGCMB+totalX+48*totalY] = bgCD-1+roomVisited;
						LargeMapLayout[_LML_LAYOUTCMB+totalX+48*totalY] = roomCD;
						LargeMapLayout[_LML_LAYOUTCS+totalX+48*totalY] = roomCS;
					}
					else{
						LargeMapLayout[_LML_LAYOUTCMB+totalX+48*totalY] = roomCD+roomVisited;
						LargeMapLayout[_LML_LAYOUTCS+totalX+48*totalY] = roomCS+roomVisited;
					}
					//Check for markers on the layer screen
					if(markerCD&&(roomVisited||!MINIMAP_MARKERSREQUIREVISITED)&&(Game->LItems[level]&LI_COMPASS||!MINIMAP_REQUIRECOMPASS)){
						//Item or Special Item
						if(markerCT==CT_CHEST){
							if(Game->GetScreenState(map, i+dmapOffset, ST_ITEM)||Game->GetScreenState(map, i+dmapOffset, ST_SPECIALITEM))
								markerState = 1;
						}
						//Item and Special Item (4 states)
						else if(markerCT==CT_BOSSCHEST){
							if(Game->GetScreenState(map, i+dmapOffset, ST_SPECIALITEM))
								++markerState;
							if(Game->GetScreenState(map, i+dmapOffset, ST_ITEM))
								markerState += 2;
						}
						//Boss level state
						else if(markerCT==CT_DAMAGE1){
							if(Game->LItems[Game->DMapLevel[dmap]]&LI_BOSS)
								markerState = 1;
						}
						//Lock block
						else if(markerCT==CT_LOCKBLOCK){
							if(Game->GetScreenState(map, i+dmapOffset, ST_LOCKBLOCK))
								markerState = 1;
						}
						//Boss lock
						else if(markerCT==CT_BOSSLOCKBLOCK){
							if(Game->GetScreenState(map, i+dmapOffset, ST_BOSSLOCKBLOCK))
								markerState = 1;
						}
						//Secret combo
						else if(markerCT==CT_STEP){
							if(Game->GetScreenState(map, i+dmapOffset, ST_SECRET))
								markerState = 1;
						}
						LargeMapLayout[_LML_MARKERCMB+totalX+48*totalY] = markerCD+markerState;
						LargeMapLayout[_LML_MARKERCS+totalX+48*totalY] = markerCS;
					}
				}
			}
		}
	}
}

void Minimap_LoadLargeMapData(){
	//No need to keep drawing if everything has already been drawn
	if(LargeMapData[_LMD_CURDRAWINDEX]==4608)
		return;
	int i;
	int x; int y;
	
	//Start with the layout layer
	Screen->SetRenderTarget(RT_LARGEMAP1);
	for(i=LargeMapData[_LMD_CURDRAWINDEX]; i<2304&&LargeMapData[_LMD_DRAWCOUNT]<=MINIMAP_LARGEMAP_FRAMEDRAWCAP; ++i){
		if(LargeMapLayout[_LML_LAYOUTCMB+i]){
			x = i%48;
			y = Floor(i/48);
			//If this is the first room discovered, set the edges up
			//This should prevent it from reading the top left corner as the edge when there's nothing there
			if(LargeMapData[_LMD_MINX]==-1){
				LargeMapData[_LMD_MINX] = x;
				LargeMapData[_LMD_MAXX] = x;
				LargeMapData[_LMD_MINY] = y;
				LargeMapData[_LMD_MAXY] = y;
			}
			//Record edges of the map space
			if(x<LargeMapData[_LMD_MINX])
				LargeMapData[_LMD_MINX] = x;
			if(x>LargeMapData[_LMD_MAXX])
				LargeMapData[_LMD_MAXX] = x;
			if(y<LargeMapData[_LMD_MINY])
				LargeMapData[_LMD_MINY] = y;
			if(y>LargeMapData[_LMD_MAXY])
				LargeMapData[_LMD_MAXY] = y;
			
			x = i%48*MINIMAP_SQUARESIZE;
			y = Floor(i/48)*MINIMAP_SQUARESIZE;
			if(LargeMapLayout[_LML_BGCMB+i]){
				Screen->FastCombo(0, x, y, LargeMapLayout[_LML_BGCMB+i], LargeMapLayout[_LML_LAYOUTCS+i], 128);
				++LargeMapData[_LMD_DRAWCOUNT];
			}
			Screen->FastCombo(0, x, y, LargeMapLayout[_LML_LAYOUTCMB+i], LargeMapLayout[_LML_LAYOUTCS+i], 128);
			++LargeMapData[_LMD_DRAWCOUNT];
		}
		else if(MINIMAP_LARGEMAP_DEBUG){
			x = i%48;
			y = Floor(i/48);
			//If this is the first room discovered, set the edges up
			//This should prevent it from reading the top left corner as the edge when there's nothing there
			if(LargeMapData[_LMD_MINX]==-1){
				LargeMapData[_LMD_MINX] = x;
				LargeMapData[_LMD_MAXX] = x;
				LargeMapData[_LMD_MINY] = y;
				LargeMapData[_LMD_MAXY] = y;
			}
			//Record edges of the map space
			if(x<LargeMapData[_LMD_MINX])
				LargeMapData[_LMD_MINX] = x;
			if(x>LargeMapData[_LMD_MAXX])
				LargeMapData[_LMD_MAXX] = x;
			if(y<LargeMapData[_LMD_MINY])
				LargeMapData[_LMD_MINY] = y;
			if(y>LargeMapData[_LMD_MAXY])
				LargeMapData[_LMD_MAXY] = y;
			
			x *= MINIMAP_SQUARESIZE;
			y *= MINIMAP_SQUARESIZE;
			Screen->Rectangle(0, x+2, y+2, x+MINIMAP_SQUARESIZE-2, y+MINIMAP_SQUARESIZE-2, C_MINIMAP_DEBUG, 1, 0, 0, 0, false, 128);
			++LargeMapData[_LMD_DRAWCOUNT];
		}
	}
	LargeMapData[_LMD_CURDRAWINDEX] = i;
	if(LargeMapData[_LMD_DRAWCOUNT]>MINIMAP_LARGEMAP_FRAMEDRAWCAP){
		Screen->SetRenderTarget(RT_SCREEN);
		LargeMapData[_LMD_DRAWCOUNT] = 0;
		return;
	}
	
	//Next draw the marker layer
	Screen->SetRenderTarget(RT_LARGEMAP2);
	for(i=LargeMapData[_LMD_CURDRAWINDEX]-2304; i<2304&&LargeMapData[_LMD_DRAWCOUNT]<=MINIMAP_LARGEMAP_FRAMEDRAWCAP; ++i){
		if(LargeMapLayout[_LML_MARKERCMB+i]){
			x = i%48*MINIMAP_SQUARESIZE;
			y = Floor(i/48)*MINIMAP_SQUARESIZE;
			Screen->FastCombo(0, x, y, LargeMapLayout[_LML_MARKERCMB+i], LargeMapLayout[_LML_MARKERCS+i], 128);
			++LargeMapData[_LMD_DRAWCOUNT];
		}
	}
	LargeMapData[_LMD_CURDRAWINDEX] = 2304+i;
	Screen->SetRenderTarget(RT_SCREEN);
	LargeMapData[_LMD_DRAWCOUNT] = 0;
}

global script MetroidvaniaMinimap_Example{
	void run(){
		MiniMap_Init();
		while(true){
			Minimap_Update();
			Waitdraw();
			Waitframe();
		}
	}
}