//import "std.zh"
//import "string.zh"

//Requires std.zh and string.zh.

//1. Set up 5 consecutive tiles in a row in Tile Editor as following:
// 1. Full heart.
// 2. 3/4 heart.
// 3. 1/2 heart.
// 4. 1/4 heart.
// 5. Empty heart.
//2. Note down ID of the first tile in the row (the "Full Heart" one).
//A. Set up the 3 x BACKDROP_NUMROWS tile sheet for backdrop that will be drawn beneath HP gauge.
//   Set BACKDROP_TILE to ID of the top left corner tile of the sheet.
//3. Import and compile the script.
//4. In your boss screen, place the invisible FFC, one for each boss, if multiple bosses are in one screen, and assign the following arguments:
// D0: ID of the tile you noted down in step 2.
// D1: Slot number of the boss enemy, or his weak spot.
// D2: Hit Points per tile. Larger values means smaller life meter and vise versa.
// D3: Cset used for drawing the life gauge. Setting value exceeding 11 results in health meter flashing trough all csets.
// D4: X offset of boss name drawing. et to a negative to disable name drawing. 
//     Refer to the "FONT_Y_OFFSET" constant in the script file.
// D5: X margin on both sides of the screen. If settings 
// D6: Width of backdrop, in tiles plus one tile to the left and to the right.
//     Set it to -1 for no background.
// D7: String to display at the start of the battle, accompanied by earthquake, if D1 is set to 1. 
//     Otherwise, it sets Y position of boss health gauge.
//5. Assign the script to FFC.
//6. Test and enjoy.

const int BOSS_HP_TILE_OFFSET = 8; //Distance between gauge piece positions.
//const int xpos = 16; //X position of the leftmost gauge piece.
const int FONT_BOSS_NAME = 0; //Font used for boss name string drawing.
const int SHADOW_COLOR_BOSS_NAME = 1; //Drop shadow Color used for boss name string drawing. Set to -1 for no shadow.
const int COLOR_BOSS_NAME = 0; //Color used for boss name string drawing.
const int BKGCOLOR_BOSS_NAME = -1; //Background color used for boss name string drawing. Change to -1 for transparent.
const int FONT_Y_OFFSET = 8; //Y position of the Boss name string drawing relative to gauge position.
const int BACKDROP_TILE = 0;//Tile used for backdrop
const int BACKDROP_CSET = 6; //Cset used for drawing backdrop beneath boss HP meter.
const int BACKDROP_XOFFSET = -8; //Backdrop position offset.
const int BACKDROP_YOFFSET = -16; //relative to gauge`s coordinates.
const int BACKDROP_NUMROWS = 3; //Number of tile rows used for composing backdrop.
const int I_STETOSCOPE = 0; //ID of item that is needed to be in Link`s inventory for HP meter to be visible. 0 means always visible
const int BOSS_HP_DRAW_LAYER = 3; //Layer used to draw Boss HP meter
const int INTRO_BOSS_HP_REGENERATION = 1;//Set to >0, to cause boss HP meter to fill up at the start of the boss battle, like in Megeman games.

ffc script BossHPMeter{
	void run (int origtile, int slotnum, int hppertile, int cset, int drawnameXoffset, int xpos, int bkgsize, int string){
		if (Screen->State[ST_SECRET])Quit();
		int ypos = 8;
		if (slotnum!=1) ypos = string;
		Waitframes(4);
		if ((string>0)&&(slotnum==1)){
			Screen->Message(string);
			Screen->Quake=60;
		}
		int regen = 0;
		if (I_STETOSCOPE>0){
			if (!Link->Item[I_STETOSCOPE]) Quit();
		}
		npc boss;
		if (slotnum == 0) boss = Screen->LoadNPC(1);
		else boss = Screen->LoadNPC(slotnum);
		int buffer[256];
		int CSETFLASH[5] = {5,7,8,9,11};
		boss->GetName(buffer);
		int maxhp = boss->HP;
		int curhp = boss->HP;
		int drawhp = curhp;
		if (INTRO_BOSS_HP_REGENERATION==0)regen = maxhp;
		while (boss->isValid()){
			if (boss->HP <= 0) break;
			curhp = boss->HP;
			int backdrawx= xpos+BACKDROP_XOFFSET;
			int backdrawy= ypos+BACKDROP_YOFFSET;
			if (bkgsize>=0) Screen->DrawTile(BOSS_HP_DRAW_LAYER, backdrawx, backdrawy, BACKDROP_TILE, bkgsize, BACKDROP_NUMROWS, BACKDROP_CSET, -1, -1, 0, 0, 0, 0, true, OP_OPAQUE);
			int drawcset;
			drawhp = Min(regen,curhp);
			int drawmaxhp = maxhp;
			int drawxpos = xpos;
			int drawypos = ypos;
			int tiletodraw = origtile;
			if (cset>11) drawcset =CSETFLASH[Rand(4)];
			else drawcset = cset;
			int namey = ypos - FONT_Y_OFFSET;
			if ((drawnameXoffset >= 0)&&(SHADOW_COLOR_BOSS_NAME>=0)) Screen->DrawString(BOSS_HP_DRAW_LAYER, xpos+1, namey+1, FONT_BOSS_NAME, COLOR_BOSS_NAME, BKGCOLOR_BOSS_NAME,  TF_NORMAL, buffer, OP_OPAQUE);
			if (drawnameXoffset >= 0) Screen->DrawString(BOSS_HP_DRAW_LAYER, (xpos+drawnameXoffset), namey, FONT_BOSS_NAME, SHADOW_COLOR_BOSS_NAME, BKGCOLOR_BOSS_NAME,  TF_NORMAL, buffer, OP_OPAQUE);
			while (drawmaxhp > 0){
				int tilechooser = 	drawhp/hppertile;
				if (tilechooser >=1) tiletodraw = origtile;
				else if (tilechooser > 0.75) tiletodraw = origtile;
				else if (tilechooser> 0.5) tiletodraw = origtile + 1;
				else if (tilechooser> 0.25) tiletodraw = origtile + 2;
				else if (tilechooser> 0) tiletodraw = origtile + 3;
				else tiletodraw = origtile + 4;
				Screen->FastTile(BOSS_HP_DRAW_LAYER, drawxpos, drawypos, tiletodraw,drawcset, OP_OPAQUE);
				drawxpos = drawxpos + BOSS_HP_TILE_OFFSET;
				if (drawxpos>=(256-xpos)){
					drawxpos = xpos;
					drawypos +=BOSS_HP_TILE_OFFSET;
				}
				drawmaxhp -= hppertile;
				drawhp -= hppertile;
				}
			if (regen<maxhp){
				regen+=hppertile/4;
			} 
			Waitframe();
		}
	}
}

//Draws n scalable image at (tilex, tiley) with "numrows" height. 
//The backdrop image is built with tiles starting at "bkgorigtile" and each subsequent tile is drawn
//after another with offset defined by "tileoffset".
//"bkgcset" controls Cset used for drawing. 
void DrawBossMeterBackground(int bkgorigtile, int drawcset, int tileoffset, int numrows, int numsections, int tilex, int tiley){
	int curtilex = tilex;
	int tiletodraw = bkgorigtile;
	for (int i=0; i<numrows; i++){
		curtilex = tilex;
		tiletodraw = bkgorigtile+(i*20);
		Screen->FastTile(BOSS_HP_DRAW_LAYER, curtilex, tiley, tiletodraw, drawcset, OP_OPAQUE);
		tiletodraw++;
		curtilex += tileoffset;
		for (int i=1; i<numsections; i++){
			Screen->FastTile(BOSS_HP_DRAW_LAYER, curtilex, tiley, tiletodraw, drawcset, OP_OPAQUE);
			curtilex += tileoffset;
			}
		tiletodraw++;
		Screen->FastTile(BOSS_HP_DRAW_LAYER, curtilex, tiley, tiletodraw, drawcset, OP_OPAQUE);
		tiley +=16;
	}
}