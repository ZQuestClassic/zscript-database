//These are all copies of existing functions with the layering fix for layer -2 and -3 applied
void Rectangle(int layer, int x, int y, int x2, int y2, int color, float scale, int rx, int ry, int rangle, bool fill, int opacity){
	if(ScreenFlag(1, 4)&&layer==2) //Layer -2
		layer = 1;
	else if(ScreenFlag(1, 5)&&layer==3) //Layer -3
		layer = 4;
	Screen->Rectangle(layer, x, y, x2, y2, color, scale, rx, ry, rangle, fill, opacity);
}

void Circle(int layer, int x, int y, int radius, int color, float scale, int rx, int ry, int rangle, bool fill, int opacity){
	if(ScreenFlag(1, 4)&&layer==2) //Layer -2
		layer = 1;
	else if(ScreenFlag(1, 5)&&layer==3) //Layer -3
		layer = 4;
	Screen->Circle(layer, x, y, radius, color, scale, rx, ry, rangle, fill, opacity);
}

void Arc(int layer, int x, int y, int radius, int startangle, int endangle, int color, float scale, int rx, int ry, int rangle, bool closed, bool fill, int opacity){
	if(ScreenFlag(1, 4)&&layer==2) //Layer -2
		layer = 1;
	else if(ScreenFlag(1, 5)&&layer==3) //Layer -3
		layer = 4;
	Screen->Arc(layer, x, y, radius, startangle, endangle, color, scale, rx, ry, rangle, closed, fill, opacity);
}

void Ellipse(int layer, int x, int y, int xradius, int yradius, int color, float scale, int rx, int ry, int rangle, bool fill, int opacity){
	if(ScreenFlag(1, 4)&&layer==2) //Layer -2
		layer = 1;
	else if(ScreenFlag(1, 5)&&layer==3) //Layer -3
		layer = 4;
	Screen->Ellipse(layer, x, y, xradius, yradius, color, scale, rx, ry, rangle, fill, opacity);
}

void Spline(int layer, int x1, int y1, int x2, int y2, int x3, int y3,int x4, int y4, int color, int opacity){
	if(ScreenFlag(1, 4)&&layer==2) //Layer -2
		layer = 1;
	else if(ScreenFlag(1, 5)&&layer==3) //Layer -3
		layer = 4;
	Screen->Spline(layer, x1, y1, x2, y2, x3, y3,x4, y4, color, opacity);
}

void Line(int layer, int x, int y, int x2, int y2, int color, float scale, int rx, int ry, int rangle, int opacity){
	if(ScreenFlag(1, 4)&&layer==2) //Layer -2
		layer = 1;
	else if(ScreenFlag(1, 5)&&layer==3) //Layer -3
		layer = 4;
	Screen->Line(layer, x, y, x2, y2, color, scale, rx, ry, rangle, opacity);
}

void PutPixel(int layer, int x, int y, int color, int rx, int ry, int rangle, int opacity){
	if(ScreenFlag(1, 4)&&layer==2) //Layer -2
		layer = 1;
	else if(ScreenFlag(1, 5)&&layer==3) //Layer -3
		layer = 4;
	Screen->PutPixel(layer, x, y, color, rx, ry, rangle, opacity);
}

void DrawTile(int layer, int x, int y, int tile, int blockw, int blockh, int cset, int xscale, int yscale, int rx, int ry, int rangle, int flip, bool transparency, int opacity){
	if(ScreenFlag(1, 4)&&layer==2) //Layer -2
		layer = 1;
	else if(ScreenFlag(1, 5)&&layer==3) //Layer -3
		layer = 4;
	Screen->DrawTile(layer, x, y, tile, blockw, blockh, cset, xscale, yscale, rx, ry, rangle, flip, transparency, opacity);
}

void FastTile( int layer, int x, int y, int tile, int cset, int opacity ){
	if(ScreenFlag(1, 4)&&layer==2) //Layer -2
		layer = 1;
	else if(ScreenFlag(1, 5)&&layer==3) //Layer -3
		layer = 4;
	Screen->FastTile(layer, x, y, tile, cset, opacity);
}

void DrawCombo(int layer, int x, int y, int combo, int w, int h, int cset, int xscale, int yscale, int rx, int ry, int rangle, int frame, int flip, bool transparency, int opacity){
	if(ScreenFlag(1, 4)&&layer==2) //Layer -2
		layer = 1;
	else if(ScreenFlag(1, 5)&&layer==3) //Layer -3
		layer = 4;
	Screen->DrawCombo(layer, x, y, combo, w, h, cset, xscale, yscale, rx, ry, rangle, frame, flip, transparency, opacity);
}

void FastCombo(int layer, int x, int y, int combo, int cset, int opacity){
	if(ScreenFlag(1, 4)&&layer==2) //Layer -2
		layer = 1;
	else if(ScreenFlag(1, 5)&&layer==3) //Layer -3
		layer = 4;
	Screen->FastCombo(layer, x, y, combo, cset, opacity);
}

void DrawCharacter(int layer, int x, int y, int font,int color, int background_color,int width, int height, int glyph, int opacity ){
	if(ScreenFlag(1, 4)&&layer==2) //Layer -2
		layer = 1;
	else if(ScreenFlag(1, 5)&&layer==3) //Layer -3
		layer = 4;
	Screen->DrawCharacter(layer, x, y, font,color, background_color,width, height, glyph, opacity );
}

void DrawInteger(int layer, int x, int y, int font,int color, int background_color, int width, int height, int number, int number_decimal_places, int opacity){
	if(ScreenFlag(1, 4)&&layer==2) //Layer -2
		layer = 1;
	else if(ScreenFlag(1, 5)&&layer==3) //Layer -3
		layer = 4;
	Screen->DrawInteger(layer, x, y, font,color, background_color,width, height, number, number_decimal_places, opacity);
}

void DrawString(int layer, int x, int y, int font,int color, int background_color, int format, int ptr, int opacity){
	if(ScreenFlag(1, 4)&&layer==2) //Layer -2
		layer = 1;
	else if(ScreenFlag(1, 5)&&layer==3) //Layer -3
		layer = 4;
	Screen->DrawString( layer, x, y, font,color, background_color, format, ptr, opacity);
}

void Quad(int layer, int x1, int y1, int x2, int y2, int x3, int y3, int x4, int y4,int w, int h, int cset, int flip, int texture, int render_mode){
	if(ScreenFlag(1, 4)&&layer==2) //Layer -2
		layer = 1;
	else if(ScreenFlag(1, 5)&&layer==3) //Layer -3
		layer = 4;
	Screen->Quad( layer, x1, y1, x2, y2, x3, y3, x4, y4,w, h, cset, flip, texture, render_mode);
}

void Triangle(int layer, int x1, int y1, int x2, int y2, int x3, int y3,int w, int h, int cset, int flip, int texture, int render_mode){
	if(ScreenFlag(1, 4)&&layer==2) //Layer -2
		layer = 1;
	else if(ScreenFlag(1, 5)&&layer==3) //Layer -3
		layer = 4;
	Screen->Triangle(layer, x1, y1, x2, y2, x3, y3,w, h, cset, flip, texture, render_mode);
}

void Quad3D(int layer, int pos, int uv, int cset, int size, int flip, int texture, int render_mode){
	if(ScreenFlag(1, 4)&&layer==2) //Layer -2
		layer = 1;
	else if(ScreenFlag(1, 5)&&layer==3) //Layer -3
		layer = 4;
	Screen->Quad3D(layer, pos, uv, cset, size, flip, texture, render_mode);
}

void Triangle3D(int layer, int pos, int uv, int csets, int size, int flip, int texture, int render_mode){
	if(ScreenFlag(1, 4)&&layer==2) //Layer -2
		layer = 1;
	else if(ScreenFlag(1, 5)&&layer==3) //Layer -3
		layer = 4;
	Screen->Triangle3D(layer, pos, uv, csets, size, flip, texture, render_mode);
}

void DrawBitmap(int layer, int bitmap_id, int source_x, int source_y, int source_w, int source_h, int dest_x, int dest_y, int dest_w, int dest_h, float rotation, bool mask){
	if(ScreenFlag(1, 4)&&layer==2) //Layer -2
		layer = 1;
	else if(ScreenFlag(1, 5)&&layer==3) //Layer -3
		layer = 4;
	Screen->DrawBitmap(layer, bitmap_id, source_x, source_y, source_w, source_h, dest_x, dest_y, dest_w, dest_h, rotation, mask);
}

void DrawLayer(int layer, int source_map, int source_screen, int source_layer, int x, int y, float rotation, int opacity){
	if(ScreenFlag(1, 4)&&layer==2) //Layer -2
		layer = 1;
	else if(ScreenFlag(1, 5)&&layer==3) //Layer -3
		layer = 4;
	Screen->DrawLayer(layer, source_map, source_screen, source_layer, x, y, rotation, opacity);
}

void DrawScreen(int layer, int map, int source_screen, int x, int y, float rotation){
	if(ScreenFlag(1, 4)&&layer==2) //Layer -2
		layer = 1;
	else if(ScreenFlag(1, 5)&&layer==3) //Layer -3
		layer = 4;
	Screen->DrawScreen(layer, map, source_screen, x, y, rotation);
}

//Function to draw a tile where the scaling, rotation, and position point is the center of the tile
void DrawTileC(int layer, int x, int y, int tile, int blockw, int blockh, int cset, int xscale, int yscale, int rx, int ry, int rangle, int flip, bool transparency, int opacity){
	int w = xscale;
	if(xscale==-1)
		w = blockw*16;
	int h = yscale;
	if(yscale==-1)
		h = blockh*16;
	DrawTile(layer, x-w/2, y-h/2, tile, blockw, blockh, cset, xscale, yscale, rx-w/2, ry-h/2, rangle, flip, transparency, opacity);
}

//Function to draw a combo where the scaling, rotation, and position point is the center of the tile
void DrawComboC(int layer, int x, int y, int combo, int blockw, int blockh, int cset, int xscale, int yscale, int rx, int ry, int rangle, int frame, int flip, bool transparency, int opacity){
	int w = xscale;
	if(xscale==-1)
		w = blockw*16;
	int h = yscale;
	if(yscale==-1)
		h = blockh*16;
	DrawCombo(layer, x-w/2, y-h/2, combo, blockw, blockh, cset, xscale, yscale, rx-w/2, ry-h/2, rangle, frame, flip, transparency, opacity);
}