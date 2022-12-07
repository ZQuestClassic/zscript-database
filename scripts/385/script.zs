const int SCROLLINGLAYER_LINKSTEP = 1.5; //Link's step speed
const int SCROLLINGLAYER_FASTSCROLLING = 1; //Set to 1 if Very Fast Scrolling is enabled
const int SCROLLINGLAYER_DEBUG = 0; //Set to 1 to show positions of onscreen layers

int ScrollingBG[112]; //Size should be at least _SBG_START + 6 * _SBG_BLOCK

//Global array indices
const int _SBG_LINKX			 = 0;
const int _SBG_LINKY			 = 1;
const int _SBG_SCROLLDIR		 = 2;
const int _SBG_SCROLLCOUNTER	 = 3;

//Start index of the 2D part of the global array and block size
const int _SBG_START = 16;
const int _SBG_BLOCK = 16;

//Indices for scrolling layer properties
const int _SBG_X		 = 0;
const int _SBG_Y		 = 1;
const int _SBG_XSTEP	 = 2;
const int _SBG_YSTEP	 = 3;
const int _SBG_MAP		 = 4;
const int _SBG_SCREEN	 = 5;
const int _SBG_LAYER	 = 6;
const int _SBG_WIDTH	 = 7;
const int _SBG_HEIGHT	 = 8;
const int _SBG_OPACITY	 = 9;
const int _SBG_FLAGS	 = 10;
const int _SBG_DMAP		 = 11;

//Flag constants
const int _SBGF_NORESET			 = 00000001b;
const int _SBGF_NOPOSITION		 = 00000010b;
const int _SBGF_TRACKX			 = 00000100b;
const int _SBGF_TRACKY			 = 00001000b;
const int _SBGF_TRACKXSCROLL	 = 00010000b;
const int _SBGF_TRACKYSCROLL	 = 00100000b;
const int _SBGF_FORCEDRAWSCREEN	 = 01000000b;

global script ScrollingLayer_Example{
	void run(){
		ScrollingBG_Init();
		while(true){
			ScrollingBG_Update();
			
			Waitdraw();
			
			Waitframe();
		}
	}
}

void ScrollingBG_Init(){
	int i; int j; int k;
	for(i=0; i<6; ++i){
		j = _SBG_START+i*_SBG_BLOCK;
		//If the layer hasn't been assigned by an FFC this frame, clear it on F6
		if(!(ScrollingBG[j+_SBG_FLAGS]&_SBGF_NORESET)){
			for(k=0; k<_SBG_BLOCK; ++k){
				ScrollingBG[j+k] = 0;
			}
		}
	}
	
	ScrollingBG[_SBG_LINKX] = Link->X;
	ScrollingBG[_SBG_LINKY] = Link->Y;
	ScrollingBG[_SBG_SCROLLDIR] = -1;
	ScrollingBG[_SBG_SCROLLCOUNTER] = 0;
}

void ScrollingBG_Update(){
	int i; int j; int k;
	
	int x; int y; int w; int h;
	bool trackLinkX; bool trackScrollX;
	bool trackLinkY; bool trackScrollY;
	
	int dX = (Link->X-ScrollingBG[_SBG_LINKX])/SCROLLINGLAYER_LINKSTEP;
	int dY = (Link->Y-ScrollingBG[_SBG_LINKY])/SCROLLINGLAYER_LINKSTEP;
	ScrollingBG[_SBG_LINKX] = Link->X;
	ScrollingBG[_SBG_LINKY] = Link->Y;
	
	if(Link->Action==LA_SCROLLING){
		if(ScrollingBG[_SBG_SCROLLDIR]==-1){
			if(Link->Y>160)
				ScrollingBG[_SBG_SCROLLDIR] = DIR_UP;
			else if(Link->Y<0)
				ScrollingBG[_SBG_SCROLLDIR] = DIR_DOWN;
			else if(Link->X>240)
				ScrollingBG[_SBG_SCROLLDIR] = DIR_LEFT;
			else
				ScrollingBG[_SBG_SCROLLDIR] = DIR_RIGHT;
			
			ScrollingBG[_SBG_SCROLLCOUNTER] = 0;
		}
		else
			++ScrollingBG[_SBG_SCROLLCOUNTER];
	}
	else
		ScrollingBG[_SBG_SCROLLDIR] = -1;
	
	for(i=0; i<6; ++i){
		j = _SBG_START+i*_SBG_BLOCK;
		if(ScrollingBG[j+_SBG_OPACITY]&&ScrollingBG[j+_SBG_DMAP]==Game->GetCurDMap()&&Game->GetCurScreen()<0x80){
			if(ScrollingBG[j+_SBG_FLAGS]&_SBGF_TRACKX)
				trackLinkX = true;
			if(ScrollingBG[j+_SBG_FLAGS]&_SBGF_TRACKY)
				trackLinkY = true;
			if(ScrollingBG[j+_SBG_FLAGS]&_SBGF_TRACKXSCROLL)
				trackScrollX = true;
			if(ScrollingBG[j+_SBG_FLAGS]&_SBGF_TRACKYSCROLL)
				trackScrollY = true;
			
			w = 256*ScrollingBG[j+_SBG_WIDTH];
			h = 176*ScrollingBG[j+_SBG_HEIGHT];
			
			//Process scrolling animation
			//X-axis
			if(ScrollingBG_IsScrolling()){
				//During the scroll animation, move the background if set to track scrolling
				if(trackScrollX){
					if(ScrollingBG[_SBG_SCROLLDIR]==DIR_LEFT)
						ScrollingBG[j+_SBG_X] -= ScrollingBG[j+_SBG_XSTEP];
					else if(ScrollingBG[_SBG_SCROLLDIR]==DIR_RIGHT)
						ScrollingBG[j+_SBG_X] += ScrollingBG[j+_SBG_XSTEP];
				}
				//Scroll automatically if neither Link nor scrolling are being tracked
				else if(!trackLinkX){
					ScrollingBG[j+_SBG_X] += ScrollingBG[j+_SBG_XSTEP];
				}
			}
			else{
				//Only move when Link does if tracking him
				if(trackLinkX){
					ScrollingBG[j+_SBG_X] += ScrollingBG[j+_SBG_XSTEP]*dX;
				}
				else if(!trackScrollX)
					ScrollingBG[j+_SBG_X] += ScrollingBG[j+_SBG_XSTEP];
			}
			//Y-axis
			if(ScrollingBG_IsScrolling()){
				//During the scroll animation, move the background if set to track scrolling
				if(trackScrollY){
					if(ScrollingBG[_SBG_SCROLLDIR]==DIR_UP)
						ScrollingBG[j+_SBG_Y] -= ScrollingBG[j+_SBG_YSTEP];
					else if(ScrollingBG[_SBG_SCROLLDIR]==DIR_DOWN)
						ScrollingBG[j+_SBG_Y] += ScrollingBG[j+_SBG_YSTEP];
				}
				//Scroll automatically if neither Link nor scrolling are being tracked
				else if(!trackLinkY){
					ScrollingBG[j+_SBG_Y] += ScrollingBG[j+_SBG_YSTEP];
				}
			}
			else{
				//Only move when Link does if tracking him
				if(trackLinkY){
					ScrollingBG[j+_SBG_Y] += ScrollingBG[j+_SBG_YSTEP]*dY;
				}
				else if(!trackScrollX)
					ScrollingBG[j+_SBG_Y] += ScrollingBG[j+_SBG_YSTEP];
			}
			
			//Keep the X and Y positions of the background wrapped based on size
			if(ScrollingBG[j+_SBG_X]<0)
				ScrollingBG[j+_SBG_X] += w;
			if(ScrollingBG[j+_SBG_X]>=w)
				ScrollingBG[j+_SBG_X] -= w;
			
			if(ScrollingBG[j+_SBG_Y]<0)
				ScrollingBG[j+_SBG_Y] += h;
			if(ScrollingBG[j+_SBG_Y]>=h)
				ScrollingBG[j+_SBG_Y] -= h;
			
			x = Floor(ScrollingBG[j+_SBG_X]);
			y = Floor(ScrollingBG[j+_SBG_Y]);
			
			ScrollingBG_DrawLayer(ScrollingBG[j+_SBG_LAYER], ScrollingBG[j+_SBG_MAP], ScrollingBG[j+_SBG_SCREEN], x, y, ScrollingBG[j+_SBG_WIDTH], ScrollingBG[j+_SBG_HEIGHT], ScrollingBG[j+_SBG_OPACITY], ScrollingBG[j+_SBG_FLAGS]&_SBGF_FORCEDRAWSCREEN);
		
			if(SCROLLINGLAYER_DEBUG){
				Screen->DrawInteger(6, 24*i, 0, FONT_Z3SMALL, 0x01, 0x0F, -1, -1, x, 0, 128);
				Screen->DrawInteger(6, 24*i, 8, FONT_Z3SMALL, 0x01, 0x0F, -1, -1, y, 0, 128);
			}
		}
		
		//Unmark flags telling the global not to reset it and the FFC not to reposition it
		if(ScrollingBG[j+_SBG_FLAGS]&_SBGF_NORESET)
			ScrollingBG[j+_SBG_FLAGS] &= ~_SBGF_NORESET;
		if(ScrollingBG[j+_SBG_FLAGS]&_SBGF_NOPOSITION)
			ScrollingBG[j+_SBG_FLAGS] &= ~_SBGF_NOPOSITION;
	}
}

bool ScrollingBG_IsScrolling(){
	int xFrames = 64;
	int yFrames = 44;
	if(SCROLLINGLAYER_FASTSCROLLING){
		xFrames = 16;
		yFrames = 11;
	}
	if(ScrollingBG[_SBG_SCROLLDIR]>-1&&ScrollingBG[_SBG_SCROLLCOUNTER]>0){
		if(ScrollingBG[_SBG_SCROLLDIR]<2&&ScrollingBG[_SBG_SCROLLCOUNTER]<yFrames+1)
			return true;
		if(ScrollingBG[_SBG_SCROLLDIR]>=2&&ScrollingBG[_SBG_SCROLLCOUNTER]<xFrames+1)
			return true;
	}
	return false;
}

void ScrollingBG_DrawLayer(int layer, int srcMap, int srcScreen, int x, int y, int w, int h, int op, bool forceDrawScreen){
	int i;
	bool useDrawScreen;
	if(forceDrawScreen)
		useDrawScreen = true;
	//While scrolling, avoid using DrawLayer on negative layers. ZC does not like this.
	if(op==128&&Link->Action==LA_SCROLLING){
		if(layer==2&&ScreenFlag(SF_VIEW, 4))
			useDrawScreen = true;
		if(layer==3&&ScreenFlag(SF_VIEW, 5))
			useDrawScreen = true;
	}
	
	int tmpScreen;
	int scrnX;
	int scrnY;
	
	for(i=0; i<4; ++i){
		scrnX = Floor(x/256)+(i%2);
		scrnY = Floor(y/176)+Floor(i/2);

		if(scrnX<0)
			scrnX += w;
		if(scrnX>w-1)
			scrnX -= w;
		if(scrnY<0)
			scrnY += h;
		if(scrnY>h-1)
			scrnY -= h;
		
		tmpScreen = srcScreen+scrnX+scrnY*16;
		if(useDrawScreen)
			Screen->DrawScreen(layer, srcMap, tmpScreen, -(x%256)+256*(i%2), -(y%176)+176*Floor(i/2), 0);
		else
			Screen->DrawLayer(layer, srcMap, tmpScreen, 0, -(x%256)+256*(i%2), -(y%176)+176*Floor(i/2), 0, op);
	}
}

//This FFC script is placed on the screen to assign or unassign a scrolling layer for the current DMap
//D0: Which of the simultaneous scrolling layers to assign (0-5)
//D1: Layer to draw to
//D2: Source Map for the layer
//D3: Source Screen for the layer (in decimal)
//D4: X speed for the layer
//D5: Y speed for the layer
//D6: Opacity for the layer (0 to clear, 64 for transparent, 128 for opaque)
//D7: Sum of all of these flags you want to use
//		1 - Track Link when walking on the X axis
//		2 - Track Link when walking on the Y axis
//		4 - Track Link when scrolling on the X axis
//		8 - Track Link when scrolling on the Y axis
//		16 - Use 2x2 screen block
//		32 - Use 3x3 screen block
//		64 - Use 4x4 screen block
//		128 - Always use drawscreen (slow)
ffc script ScrollingLayer_Assign{
	void run(int whichScrollingLayer, int drawLayer, int srcMap, int srcScreen, int xStep, int yStep, int opacity, int flags){	
		whichScrollingLayer = Clamp(whichScrollingLayer, 0, 5);
		
		int width = 1;
		if(flags&16)
			width = 2;
		if(flags&32)
			width = 3;
		if(flags&64)
			width = 4;
		
		//Get the starting array index for the scrolling layer block
		int i = _SBG_START+whichScrollingLayer*_SBG_BLOCK;
		int j;
		
		//This runs twice because of script order shenanigans. Hooraaaay! Script order!
		for(j=0; j<2; ++j){
			if(opacity!=0&&(ScrollingBG[i+_SBG_OPACITY]&&ScrollingBG[i+_SBG_DMAP]==Game->GetCurDMap())){
				Waitframe();
				continue;
			}
			
			//Assign that stuff
			if(!(ScrollingBG[i+_SBG_FLAGS]&_SBGF_NOPOSITION)){
				ScrollingBG[i+_SBG_X] = 0;
				ScrollingBG[i+_SBG_Y] = 0;
				ScrollingBG[i+_SBG_WIDTH] = width;
				ScrollingBG[i+_SBG_HEIGHT] = width;
			}
			ScrollingBG[i+_SBG_XSTEP] = xStep;
			ScrollingBG[i+_SBG_YSTEP] = yStep;
			ScrollingBG[i+_SBG_MAP] = srcMap;
			ScrollingBG[i+_SBG_SCREEN] = srcScreen;
			ScrollingBG[i+_SBG_LAYER] = drawLayer;
			ScrollingBG[i+_SBG_OPACITY] = opacity;
			
			//Assign the flag that tells the global not to reset this index, as well as any others specified
			ScrollingBG[i+_SBG_FLAGS] = _SBGF_NORESET;
			if(flags&1)
				ScrollingBG[i+_SBG_FLAGS] |= _SBGF_TRACKX;
			if(flags&2)
				ScrollingBG[i+_SBG_FLAGS] |= _SBGF_TRACKY;
			if(flags&4)
				ScrollingBG[i+_SBG_FLAGS] |= _SBGF_TRACKXSCROLL;
			if(flags&8)
				ScrollingBG[i+_SBG_FLAGS] |= _SBGF_TRACKYSCROLL;
			if(flags&128)
				ScrollingBG[i+_SBG_FLAGS] |= _SBGF_FORCEDRAWSCREEN;
			
			ScrollingBG[i+_SBG_DMAP] = Game->GetCurDMap();
			
			Quit();
		}
	}
}

//This FFC script is placed on the screen to change the position of an assigned layer (because the last script ran out of arguments)
//D0: Which of the simultaneous scrolling layers to assign (0-5)
//D1: X position to set the layer to
//D2: Y position to set the layer to
//D3: Width to set the layer to (overrides flags used by the previous script)
//D4: Height to set the layer to (overrides flags used by the previous script)
ffc script ScrollingLayer_Reposition{
	void run(int whichScrollingLayer, int x, int y, int newW, int newH){	
		whichScrollingLayer = Clamp(whichScrollingLayer, 0, 5);
		newW = Clamp(newW, 0, 16);
		newH = Clamp(newH, 0, 8);
		
		//Get the starting array index for the scrolling layer block
		int i = _SBG_START+whichScrollingLayer*_SBG_BLOCK;
		int j;
		
		int w = ScrollingBG[i+_SBG_WIDTH]*256;
		int h = ScrollingBG[i+_SBG_HEIGHT]*176;
		
		//This runs twice because of script order shenanigans. Hooraaaay! Script order!
		for(j=0; j<2; ++j){
			if(!ScrollingBG[i+_SBG_OPACITY]||ScrollingBG[i+_SBG_FLAGS]&_SBGF_NORESET){
				if(newW&&newH){
					ScrollingBG[i+_SBG_WIDTH] = newW;
					ScrollingBG[i+_SBG_HEIGHT] = newH;
					w = ScrollingBG[i+_SBG_WIDTH]*256;
					h = ScrollingBG[i+_SBG_HEIGHT]*176;
				}
				
				while(x<0)
					x += w;
				while(x>=w)
					x -= w;
				while(y<0)
					y += h;
				while(y>=h)
					y -= h;
				
				ScrollingBG[i+_SBG_X] = x;
				ScrollingBG[i+_SBG_Y] = y;
				
				//Flag that the ScrollingLayer_Assign script shouldn't reset the layer's position, if this one comes first
				ScrollingBG[i+_SBG_FLAGS] |= _SBGF_NOPOSITION;
				Quit();
			}
			
			Waitframe();
		}
	}
}