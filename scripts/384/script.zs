const int TIL_LTTP_DARKROOM = 52000; //Tile for the larger dark room cone
const int TIL_LTTP_DARKROOM_TRANS = 52006; //Tile for the smaller transparent dark room cone
const int CS_LTTP_DARKROOM = 7; //CSet for the cone tiles
const int C_BLACK = 0x0F; //The color black

const int LTTP_DARKROOM_LIGHTDIST = 24; //Distance in front of Link the light cone tile is drawn
const bool LTTP_DARKROOM_SKIPSCROLLFRAME1 = true; //Whether or not to skip drawing during the first frame of scrolling (fixes a flickering issue)

//D0: Darkness of the room
//		0 - Same as 128
//		64 - Translucent light cone
//		96 - Two translucent light cones stacked on top of each other
//		128 - One translucent light cone with one solid light cone stacked on top of it (fully dark)
dmapdata script DarkRoom{
	void run(int opacity){
		int scrollFrames;
		if(opacity==0)
			opacity = 128;
		while(true){
			//When scrolling, Link's position isn't updated. Add the new screen's position to compensate.
			if(Link->Action==LA_SCROLLING){
				if(!LTTP_DARKROOM_SKIPSCROLLFRAME1||scrollFrames>0)
					DrawDarkRoom(6, Game->Scrolling[SCROLL_NX]+Link->X, Game->Scrolling[SCROLL_NY]+Link->Y, Link->Dir, opacity);
				++scrollFrames;
			}
			else{
				DrawDarkRoom(6, Link->X, Link->Y, Link->Dir, opacity);
				scrollFrames = 0;
			}
			Waitframe();
		}
	}
	void DrawDarkRoom(int layer, int x, int y, int dir, int op){
		int op2;
		//Offset the center point based on direction
		if(dir>DIR_DOWN)
			x += dir==DIR_LEFT?-LTTP_DARKROOM_LIGHTDIST:LTTP_DARKROOM_LIGHTDIST;
		else
			y += dir==DIR_UP?-LTTP_DARKROOM_LIGHTDIST:LTTP_DARKROOM_LIGHTDIST;
			
		//Positions are rounded to transparent rectangle draws don't overlap
		x = Round(x);
		y = Round(y);
		int coneX = x-40;
		int coneY = y-40;
		int coneAngle = DirAngle(dir)+90;
		
		//Draw the light cone
		if(op==64){ //Single transparent
			op2 = 64;
			Screen->DrawTile(layer, coneX, coneY, TIL_LTTP_DARKROOM_TRANS, 6, 6, CS_LTTP_DARKROOM, -1, -1, coneX, coneY, coneAngle, 0, true, 64);
		}
		else if(op==96){ //Double transparent
			op2 = 64;
			Screen->DrawTile(layer, coneX, coneY, TIL_LTTP_DARKROOM_TRANS, 6, 6, CS_LTTP_DARKROOM, -1, -1, coneX, coneY, coneAngle, 0, true, 64);
			Screen->DrawTile(layer, coneX, coneY, TIL_LTTP_DARKROOM, 6, 6, CS_LTTP_DARKROOM, -1, -1, coneX, coneY, coneAngle, 0, true, 64);
		}
		else if(op==128){ //Solid color w/ transparency
			op2 = 128;
			Screen->DrawTile(layer, coneX, coneY, TIL_LTTP_DARKROOM_TRANS, 6, 6, CS_LTTP_DARKROOM, -1, -1, coneX, coneY, coneAngle, 0, true, 64);
			Screen->DrawTile(layer, coneX, coneY, TIL_LTTP_DARKROOM, 6, 6, CS_LTTP_DARKROOM, -1, -1, coneX, coneY, coneAngle, 0, true, 128);
		}
		
		//Draw a series of rectangles surrounding the tile draw
		if(op2){
			Screen->Rectangle(layer, -8, -8, coneX-1, 255, C_BLACK, 1, 0, 0, 0, true, op2);
			Screen->Rectangle(layer, coneX+96, -8, 263, 255, C_BLACK, 1, 0, 0, 0, true, op2);
			Screen->Rectangle(layer, coneX, -8, coneX+95, coneY-1, C_BLACK, 1, 0, 0, 0, true, op2);
			Screen->Rectangle(layer, coneX, coneY+96, coneX+95, 183, C_BLACK, 1, 0, 0, 0, true, op2);
			//Double thick transparency needs to be drawn twice
			if(op==96){
				Screen->Rectangle(layer, -8, -8, coneX-1, 255, C_BLACK, 1, 0, 0, 0, true, op2);
				Screen->Rectangle(layer, coneX+96, -8, 263, 255, C_BLACK, 1, 0, 0, 0, true, op2);
				Screen->Rectangle(layer, coneX, -8, coneX+95, coneY-1, C_BLACK, 1, 0, 0, 0, true, op2);
				Screen->Rectangle(layer, coneX, coneY+96, coneX+95, 183, C_BLACK, 1, 0, 0, 0, true, op2);
			}
		}
	}
}