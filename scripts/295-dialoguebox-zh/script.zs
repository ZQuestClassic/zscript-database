//== GFX ==
const int TIL_DB_DIALOGUE_BOX = 52000; //First of the 8 tiles used to form the dialogue box
const int CS_DB_DIALOGUE_BOX = 0; //CSet of the dialogue box
const int C_DB_DIALOGUE_BOX_BG = 0x0F; //Color of the dialogue box's background

const int TIL_DB_DIALOGUE_SELECTOR = 52020; //Tile for the dialogue box selector
const int CS_DB_DIALOGUE_SELECTOR = 0; //CSet of the dialogue box selector

//== SFX ==
const int SFX_DB_MOVECURSOR = 5; //Moving the cursor in the dialogue box
const int SFX_DB_CONFIRM = 6; //Selecting an option in the dialogue box

const int SFX_DB_OPEN = 4; //Dialogue box opening
const int SFX_DB_CLOSE = 4; //Dialogue box closing

//== CONTROL CODE ==
const int CHAR_MCC_MARKER = 35; //ASCII character marking special dialogue branch control codes. 35 (#) by default
const int MCC_ENABLE_DEBUG = 0; //Set to 1 for debug traces

//== MISC ==
const int DIALOGUEBOX_WIDTH_SPACING = 48; //Extra width for the non-text part of the dialogue box
const int DIALOGUEBOX_HEIGHT_SPACING = 24; //Extra height for the non-text part of the dialogue box
const int DIALOGUEBOX_MAX_LINEWIDTH = 200; //Max width for line wrapping on strings
const int DIALOGUEBOX_OPTION_SPACING = 4; //Space between dialogue options
const int DIALOGUEBOX_LINE_SPACING = 0; //Space between lines in a dialogue option
const int DIALOGUEBOX_CENTER_CURSOR_VERTICALLY = 0; //Whether or not to center the cursor vertically on multi line dialogue options
const int DIALOGUEBOX_TEXT_ALIGNMENT = 1; //How to align text: 0 - Left, 1 - Centered, 2 - Right (may  be buggy)

//Internal function to draw the dialogue box. The box is centered on the point cx,cy and is formed with 8 tiles and a color.
void DialogueBox_DrawBox(int layer, int cx, int cy, int til, int cs, int color, int w, int h){
	w = Max(w, 16)-16;
	h = Max(h, 16)-16;
	
	int x; int y;
	Screen->Rectangle(layer, cx-w/2, cy-h/2, cx+w/2, cy+h/2, color, 1, 0, 0, 0, true, 128);
	
	Screen->FastTile(layer, cx-8-w/2, cy-8-h/2, til, cs, 128);
	Screen->FastTile(layer, cx+w/2, cy-8-h/2, til+1, cs, 128);
	Screen->FastTile(layer, cx-8-w/2, cy+h/2, til+2, cs, 128);
	Screen->FastTile(layer, cx+w/2, cy+h/2, til+3, cs, 128);
	
	Screen->DrawTile(layer, cx-w/2, cy-8-h/2, til+4, 1, 1, cs, w, 16, 0, 0, 0, 0, true, 128);
	Screen->DrawTile(layer, cx-w/2, cy+h/2, til+5, 1, 1, cs, w, 16, 0, 0, 0, 0, true, 128);
	Screen->DrawTile(layer, cx-8-w/2, cy-h/2, til+6, 1, 1, cs, 16, h, 0, 0, 0, 0, true, 128);
	Screen->DrawTile(layer, cx+w/2, cy-h/2, til+7, 1, 1, cs, 16, h, 0, 0, 0, 0, true, 128);
}

//Function to get string lengths. Calls another function based on font
int DialogueBox_GetStringLength(int string, int font){
	int fontDef[512];
	if(font==FONT_Z1)
		DialogueBox_GetFontDef_Fixed(fontDef, 8);
	else if(font==FONT_Z3)
		DialogueBox_GetFontDef_LttP(fontDef);
	else if(font==FONT_Z3SMALL)
		DialogueBox_GetFontDef_LttPSmall(fontDef);
	else if(font==FONT_DEF)
		DialogueBox_GetFontDef_Fixed(fontDef, 8);
	else if(font==FONT_L)
		DialogueBox_GetFontDef_GUIBold(fontDef);
	else if(font==FONT_L2)
		DialogueBox_GetFontDef_GUI(fontDef);
	else if(font==FONT_P)
		DialogueBox_GetFontDef_GUINarrow(fontDef);
	else if(font==FONT_MATRIX)
		DialogueBox_GetFontDef_Fixed(fontDef, 8);
	else if(font==FONT_S)
		DialogueBox_GetFontDef_Fixed(fontDef, 6);
	else if(font==FONT_S2)
		DialogueBox_GetFontDef_Fixed(fontDef, 4);
	else if(font==FONT_SP)
		DialogueBox_GetFontDef_SmallProportional(fontDef);
	else if(font==FONT_SUBSCREEN3)
		DialogueBox_GetFontDef_SS3(fontDef);
	else if(font==FONT_GBLA)
		DialogueBox_GetFontDef_LA(fontDef);
	else if(font==FONT_GBORACLE)
		DialogueBox_GetFontDef_Fixed(fontDef, 8);
	else if(font==FONT_GBORACLEP)
		DialogueBox_GetFontDef_OracleProportional(fontDef);
	else if(font==FONT_DSPHANTOM)
		DialogueBox_GetFontDef_Fixed(fontDef, 12);
	else if(font==FONT_DSPHANTOMP)
		DialogueBox_GetFontDef_PhantomProportional(fontDef);
	
	int size;
	for(int i=0; i<SizeOfArray(string); i++){
		if(string[i]!=0){
			size += fontDef[string[i]-' '];
		}
		else
			break;
	}
	return size;
}

void DialogueBox_GetFontDef(int fontDef, int font){
	if(font==FONT_Z1)
		DialogueBox_GetFontDef_Fixed(fontDef, 8);
	else if(font==FONT_Z3)
		DialogueBox_GetFontDef_LttP(fontDef);
	else if(font==FONT_Z3SMALL)
		DialogueBox_GetFontDef_LttPSmall(fontDef);
	else if(font==FONT_DEF)
		DialogueBox_GetFontDef_Fixed(fontDef, 8);
	else if(font==FONT_L)
		DialogueBox_GetFontDef_GUIBold(fontDef);
	else if(font==FONT_L2)
		DialogueBox_GetFontDef_GUI(fontDef);
	else if(font==FONT_P)
		DialogueBox_GetFontDef_GUINarrow(fontDef);
	else if(font==FONT_MATRIX)
		DialogueBox_GetFontDef_Fixed(fontDef, 8);
	else if(font==FONT_S)
		DialogueBox_GetFontDef_Fixed(fontDef, 6);
	else if(font==FONT_S2)
		DialogueBox_GetFontDef_Fixed(fontDef, 4);
	else if(font==FONT_SP)
		DialogueBox_GetFontDef_SmallProportional(fontDef);
	else if(font==FONT_SUBSCREEN3)
		DialogueBox_GetFontDef_SS3(fontDef);
	else if(font==FONT_GBLA)
		DialogueBox_GetFontDef_LA(fontDef);
	else if(font==FONT_GBORACLE)
		DialogueBox_GetFontDef_Fixed(fontDef, 8);
	else if(font==FONT_GBORACLEP)
		DialogueBox_GetFontDef_OracleProportional(fontDef);
	else if(font==FONT_DSPHANTOM)
		DialogueBox_GetFontDef_Fixed(fontDef, 12);
	else if(font==FONT_DSPHANTOMP)
		DialogueBox_GetFontDef_PhantomProportional(fontDef);
}

int DialogueBox_GetStringLengthFromDef(int string, int fontDef){
	int size;
	for(int i=0; i<SizeOfArray(string); i++){
		if(string[i]!=0){
			size += fontDef[string[i]-' '];
		}
		else
			break;
	}
	return size;
}

//Function to get string heights.
int DialogueBox_GetStringHeight(int font){
	if(font==FONT_Z1)
		return 8;
	else if(font==FONT_Z3)
		return 16;
	else if(font==FONT_Z3SMALL)
		return 6;
	else if(font==FONT_DEF)
		return 8;
	else if(font==FONT_L)
		return 13;
	else if(font==FONT_L2)
		return 13;
	else if(font==FONT_P)
		return 8;
	else if(font==FONT_MATRIX)
		return 8;
	else if(font==FONT_S)
		return 6;
	else if(font==FONT_S2)
		return 6;
	else if(font==FONT_SP)
		return 6;
	else if(font==FONT_SUBSCREEN3)
		return 8;
	else if(font==FONT_GBLA)
		return 8;
	else if(font==FONT_GBORACLE)
		return 15;
	else if(font==FONT_GBORACLEP)
		return 15;
	else if(font==FONT_DSPHANTOM)
		return 15;
	else if(font==FONT_DSPHANTOMP)
		return 15;
}

//Monospace font measurement function
int DialogueBox_GetStringLength_Fixed(int string, int charWidth){
	int size;
	for(int i=0; i<SizeOfArray(string); i++){
		if(string[i]!=0){
			size += charWidth;
		}
		else
			break;
	}
	return size;
}

//Various font specific measurement functions
void DialogueBox_GetFontDef_Fixed(int buf, int fixedW){
	for(int i=223; i>=0; --i){
		buf[i] = fixedW;
	}
}

void DialogueBox_GetFontDef_GUI(int buf){
	int fontDef[] = {
		// Character widths, including any trailing space
		// ASCII characters 32 to 126
		
		// sp !  "  #  $  %  &  '  (  )  *  +  ,  -  .  /
		   6, 2, 5, 7, 6, 8, 6, 2, 3, 3, 4, 6, 3, 3, 2, 5,
		
		// 0  1  2  3  4  5  6  7  8  9
		   6, 4, 6, 6, 6, 6, 6, 6, 6, 6,
		
		// :  ;  <  =  >  ?  @
		   2, 3, 5, 6, 5, 6, 11,
		
		// A  B  C  D  E  F  G  H  I  J  K  L  M  N  O  P  Q  R  S  T  U  V  W   X  Y  Z
		   8, 6, 7, 7, 6, 6, 7, 7, 2, 5, 7, 6, 8, 7, 7, 7, 7, 7, 6, 6, 7, 8, 12, 8, 8, 8,
		
		// [  \  ]  ^  _  `
		   3, 5, 3, 6, 6, 3,
		
		// a  b  c  d  e  f  g  h  i  j  k  l  m  n  o  p  q  r  s  t  u  v  w  x  y  z
		   6, 6, 6, 6, 6, 3, 6, 6, 2, 2, 6, 2, 8, 6, 6, 6, 6, 3, 5, 3, 6, 6, 8, 5, 5, 5,
		
		// {  |  }  ~
		   4, 2, 4, 7,
		
		// Additional characters
		   3, 14, 14, 8, 8, 8, 8, 14, 14, 10, 10, 6, 6, 4, 13, 3, 3, 3, 3, 3, 3, 3,
		   3, 3, 3, 10, 10, 12, 12, 3, 3, 3, 3, 1, 2, 6, 6, 6, 6, 2, 6, 4, 9, 4, 6,
		   6, 3, 8, 7, 4, 6, 4, 4, 3, 6, 6, 3, 3, 3, 4, 6, 8, 8, 8, 6, 8, 8, 8, 8,
		   8, 8, 10, 7, 6, 6, 6, 6, 2, 3, 4, 4, 8, 7, 7, 7, 7, 7, 7, 6, 7, 7, 7, 7,
		   7, 8, 7, 6, 6, 6, 6, 6, 6, 6, 10, 6, 6, 6, 6, 6, 3, 4, 4, 4, 6, 6, 6, 6,
		   6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6
	};
	
	for(int i=SizeOfArray(fontDef)-1; i>=0; --i){
		buf[i] = fontDef[i];
	}
}

void DialogueBox_GetFontDef_GUIBold(int buf){
	int fontDef[] = {
		// Character widths, including any trailing space
		// ASCII characters 32 to 126
		
		// sp !  "  #  $  %  &  '  (  )  *  +  ,  -  .  /
		   7, 3, 6, 8, 7, 9, 8, 3, 4, 4, 7, 7, 4, 4, 3, 6,
		
		// 0  1  2  3  4  5  6  7  8  9
		   7, 5, 7, 7, 7, 7, 7, 7, 7, 7,
		
		// :  ;  <  =  >  ?  @
		   3, 4, 6, 7, 6, 7, 12,
		
		// A  B  C  D  E  F  G  H  I  J  K  L  M  N  O  P  Q  R  S  T  U  V  W   X  Y  Z
		   9, 7, 8, 8, 7, 7, 8, 8, 3, 6, 8, 7, 9, 8, 8, 8, 8, 8, 7, 7, 8, 9, 13, 9, 9, 9,
		
		// [  \  ]  ^  _  `
		   4, 6, 4, 7, 7, 4,
		
		// a  b  c  d  e  f  g  h  i  j  k  l  m  n  o  p  q  r  s  t  u  v  w  x  y  z
		   7, 7, 7, 7, 7, 4, 7, 7, 3, 3, 7, 3, 9, 7, 7, 7, 7, 4, 6, 4, 7, 7, 9, 6, 6, 6,
		
		// {  |  }  ~
		   5, 3, 5, 8,
		
		// Additional characters
		   4, 11, 11, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4,
		   4, 4, 4, 4, 4, 4, 4, 4, 4, 2, 3, 7, 7, 7, 7, 3, 7, 5, 10, 5, 8, 7, 4, 9,
		   8, 5, 7, 5, 5, 4, 7, 7, 4, 4, 4, 6, 8, 9, 9, 9, 7, 9, 9, 9, 9, 9, 9, 11,
		   8, 7, 7, 7, 7, 3, 4, 5, 5, 9, 8, 8, 8, 8, 8, 8, 7, 8, 8, 8, 8, 8, 9, 8,
		   7, 7, 7, 7, 7, 7, 7, 11, 7, 7, 7, 7, 7, 4, 5, 5, 5, 7, 7, 7, 7, 7, 7, 7,
		   7, 7, 7, 7, 7, 7, 7, 7, 7
	};
	
	for(int i=SizeOfArray(fontDef)-1; i>=0; --i){
		buf[i] = fontDef[i];
	}
}

void DialogueBox_GetFontDef_GUINarrow(int buf){
	int fontDef[] = {
		// Character widths, including any trailing space
		// ASCII characters 32 to 126
		
		// sp !  "  #  $  %  &  '  (  )  *  +  ,  -  .  /
		   4, 2, 4, 6, 6, 4, 5, 2, 3, 3, 4, 4, 3, 4, 2, 4,
		
		// 0  1  2  3  4  5  6  7  8  9
		   4, 4, 4, 4, 4, 4, 4, 4, 4, 4,
		
		// :  ;  <  =  >  ?  @
		   2, 3, 4, 6, 4, 4, 4,
		
		// A  B  C  D  E  F  G  H  I  J  K  L  M  N  O  P  Q  R  S  T  U  V  W  X  Y  Z
		   4, 4, 4, 4, 4, 3, 4, 4, 4, 5, 4, 3, 6, 5, 4, 4, 4, 4, 4, 4, 4, 6, 6, 4, 4, 4,
		
		// [  \  ]  ^  _  `
		   4, 4, 4, 4, 4, 4,
		
		// a  b  c  d  e  f  g  h  i  j  k  l  m  n  o  p  q  r  s  t  u  v  w  x  y  z
		   4, 4, 4, 4, 4, 4, 4, 4, 2, 3, 4, 2, 6, 4, 4, 4, 4, 4, 4, 4, 4, 4, 6, 4, 4, 4,
		
		// {  |  }  ~
		   4, 2, 4, 5,
		
		// Additional characters
		   6, 6, 6, 5, 6, 6, 6, 7, 7, 8, 8, 5, 5, 3, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6,
		   6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6,
		   6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 9, 9, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6,
		   6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6,
		   6, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4,
		   4, 4, 4, 4, 4, 4, 4, 4, 4
	};
	
	for(int i=SizeOfArray(fontDef)-1; i>=0; --i){
		buf[i] = fontDef[i];
	}
}

void DialogueBox_GetFontDef_LA(int buf){
	int fontDef[] = {
		// Character widths, including any trailing space
		// ASCII characters 32 to 126
		
		// sp !  "  #  $  %  &  '  (  )  *  +  ,  -  .  /  
		   4, 4, 5, 8, 8, 7, 8, 3, 5, 5, 6, 6, 3, 6, 3, 5,
		
		// 0  1  2  3  4  5  6  7  8  9
		   6, 5, 7, 7, 7, 7, 6, 6, 7, 6,
		
		// :  ;  <  =  >  ?  @
		   4, 4, 6, 6, 6, 7, 8,
		
		// A  B  C  D  E  F  G  H  I  J  K  L  M  N  O  P  Q  R  S  T  U  V  W  X  Y  Z
		   8, 8, 8, 8, 8, 8, 8, 8, 7, 8, 7, 6, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8,
		
		// [  \  ]  ^  _  `
		   8, 8, 8, 4, 6, 3,
		
		// a  b  c  d  e  f  g  h  i  j  k  l  m  n  o  p  q  r  s  t  u  v  w  x  y  z
		   6, 6, 5, 7, 6, 7, 6, 5, 5, 7, 6, 4, 7, 6, 6, 6, 6, 5, 6, 5, 6, 6, 7, 6, 7, 6,
		
		// {  |  }  ~
		   6, 3, 6, 5
	};
	
	for(int i=SizeOfArray(fontDef)-1; i>=0; --i){
		buf[i] = fontDef[i];
	}
}

void DialogueBox_GetFontDef_LttP(int buf){
	int fontDef[] = {
		// Character widths, including any trailing space
		// ASCII characters 32 to 126
		
		// sp !  "  #  $  %  &  '  (  )  *  +  ,  -  .  /
		   3, 2, 4, 6, 6, 6, 6, 3, 5, 5, 6, 6, 3, 5, 3, 6,
		
		// 0  1  2  3  4  5  6  7  8  9
		   5, 3, 5, 5, 5, 5, 5, 5, 5, 5,
		// :  ;  <  =  >  ?  @
		   3, 3, 6, 5, 6, 6, 6,
		// A  B  C  D  E  F  G  H  I  J  K  L  M  N  O  P  Q  R  S  T  U  V  W  X  Y  Z
		   5, 5, 5, 5, 5, 5, 5, 5, 2, 5, 5, 5, 6, 5, 5, 5, 5, 5, 5, 6, 5, 6, 6, 6, 6, 5,
		// [  \  ]  ^  _  `
		   5, 6, 5, 6, 7, 3,
		// a  b  c  d  e  f  g  h  i  j  k  l  m  n  o  p  q  r  s  t  u  v  w  x  y  z
		   5, 5, 5, 5, 5, 5, 5, 5, 2, 4, 5, 2, 6, 5, 5, 5, 5, 4, 5, 5, 5, 6, 6, 6, 6, 5,
		// {  |  }  ~
		   6, 2, 6, 6,
		   
		// Additional characters
		   5, 5, 5, 15, 6, 6, 6, 6, 6, 5, 5, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7,
		   7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7,
		   7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 8,
		   7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7,
		   7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7,
		   7, 7, 7, 7, 7, 7, 7, 7, 6
	};
	
	for(int i=SizeOfArray(fontDef)-1; i>=0; --i){
		buf[i] = fontDef[i];
	}
}

void DialogueBox_GetFontDef_LttPSmall(int buf){
	int fontDef[] = {
		// Character widths, including any trailing space
		// ASCII characters 32 to 126
		
		// sp !  "  #  $  %  &  '  (  )  *  +  ,  -  .  /
		   4, 2, 4, 6, 6, 4, 5, 2, 3, 3, 4, 4, 3, 4, 2, 4,
		
		// 0  1  2  3  4  5  6  7  8  9
		   4, 3, 4, 4, 4, 4, 4, 4, 4, 4,
		
		// :  ;  <  =  >  ?  @
		   2, 2, 4, 4, 4, 4, 6,
		
		// A  B  C  D  E  F  G  H  I  J  K  L  M  N  O  P  Q  R  S  T  U  V  W  X  Y  Z
		   5, 5, 4, 5, 4, 4, 5, 4, 2, 4, 5, 4, 6, 5, 5, 5, 6, 5, 4, 4, 5, 6, 6, 4, 4, 4,
		
		// [  \  ]  ^  _  `
		   4, 4, 4, 4, 4, 4,
		
		// Note: This font's capital and lowercase letters are identical, but
		// ZC spaces some of them differently. This appears to be unintentional,
		// so it is not duplicated here.
		// a  b  c  d  e  f  g  h  i  j  k  l  m  n  o  p  q  r  s  t  u  v  w  x  y  z
		   5, 5, 4, 5, 4, 4, 5, 4, 2, 4, 5, 4, 6, 5, 5, 5, 6, 5, 4, 4, 5, 6, 6, 4, 4, 4,
		
		// {  |  }  ~
		   4, 2, 4, 5,
		
		// Additional characters
		   6, 10, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6,
		   6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6,
		   6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6,
		   6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6,
		   6, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4,
		   4, 4, 4, 4, 4, 4, 4, 4, 4
	};
	
	for(int i=SizeOfArray(fontDef)-1; i>=0; --i){
		buf[i] = fontDef[i];
	}
}

void DialogueBox_GetFontDef_OracleProportional(int buf){
	int fontDef[] = {
		// Character widths, including any trailing space
		// ASCII characters 32 to 126
		
		// sp !  "  #  $  %  &  '  (  )  *  +  ,  -  .  /
		   5, 3, 6, 8, 6, 8, 8, 3, 4, 4, 6, 6, 3, 7, 3, 7,
		
		// 0  1  2  3  4  5  6  7  8  9
		   7, 7, 7, 7, 7, 7, 7, 7, 7, 7,
		
		// :  ;  <  =  >  ?  @
		   3, 3, 4, 6, 4, 7, 8,
		
		// A  B  C  D  E  F  G  H  I  J  K  L  M  N  O  P  Q  R  S  T  U  V  W  X  Y  Z
		   7, 7, 7, 7, 7, 7, 7, 7, 4, 7, 7, 6, 7, 7, 7, 7, 7, 7, 7, 8, 7, 8, 7, 7, 8, 7,
		
		// [  \  ]  ^  _  `
		   4, 7, 4, 6, 8, 4,
		
		// a  b  c  d  e  f  g  h  i  j  k  l  m  n  o  p  q  r  s  t  u  v  w  x  y  z
		   7, 6, 6, 6, 6, 6, 6, 6, 2, 6, 6, 2, 7, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 7, 6, 6,
		
		// {  |  }  ~
		   5, 2, 5, 7,
		
		// Additional characters
		   7, 8, 8, 8, 8, 8, 8, 8, 8, 8, 7, 7, 7, 7, 7, 7, 7, 7, 3, 3, 6, 6, 7, 5,
		   9, 7, 9, 7, 7, 7, 7, 7, 7, 5, 3, 6, 7, 7, 6, 2, 5, 5, 8, 6, 7, 8, 7, 8,
		   8, 5, 6, 4, 4, 4, 6, 7, 3, 4, 3, 5, 7, 8, 8, 9, 7, 7, 7, 7, 7, 7, 7, 7,
		   7, 7, 7, 7, 7, 4, 4, 4, 4, 8, 7, 7, 7, 7, 7, 7, 5, 7, 7, 7, 7, 7, 8, 6,
		   7, 7, 7, 7, 7, 7, 7, 7, 6, 6, 6, 6, 6, 4, 4, 4, 4, 6, 7, 6, 6, 6, 7, 6,
		   6, 6, 6, 6, 6, 7, 6, 5, 6
	};
	
	for(int i=SizeOfArray(fontDef)-1; i>=0; --i){
		buf[i] = fontDef[i];
	}
}

void DialogueBox_GetFontDef_PhantomProportional(int buf){
	int fontDef[] = {
		// Character widths, including any trailing space
		// ASCII characters 32 to 126
		
		// sp !  "  #  $  %   &  '  (  )  *  +  ,  -  .  /  
		   5, 2, 7, 8, 8, 10, 8, 3, 4, 4, 6, 8, 3, 8, 2, 6,
		
		// 0  1  2  3  4  5  6  7  8  9
		   7, 4, 8, 8, 8, 8, 8, 8, 8, 8,
		
		// :  ;  <  =  >  ?  @
		   2, 3, 5, 7, 5, 6, 10,
		
		// A  B  C  D  E  F  G  H  I  J  K  L  M  N  O  P  Q  R  S  T  U  V  W   X  Y  Z
		   8, 8, 8, 8, 7, 7, 8, 8, 4, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 10, 8, 8, 7,
		
		// [  \  ]  ^  _  `
		   5, 6, 5, 6, 8, 5,
		
		// a  b  c  d  e  f  g  h  i  j  k  l  m   n  o  p  q  r  s  t  u  v  w   x  y  z
		   7, 7, 7, 7, 8, 6, 7, 7, 2, 5, 7, 3, 10, 7, 8, 7, 7, 6, 7, 6, 7, 8, 10, 8, 8, 7,
		
		// {  |  }  ~
		   5, 2, 5, 11,
		   
		// Additional characters
		   12, 6, 6, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 3,
		   3, 5, 5, 8, 6, 10, 12, 12, 12, 12, 12, 12, 12, 12, 5, 2, 8, 9, 9, 8, 2,
		   7, 4, 10, 6, 8, 10, 8, 10, 13, 4, 8, 4, 4, 5, 7, 8, 6, 4, 3, 5, 8, 9, 9,
		   9, 6, 8, 8, 8, 8, 8, 8, 8, 7, 7, 7, 7, 7, 5, 5, 4, 4, 9, 8, 8, 8, 8, 8,
		   8, 8, 8, 8, 8, 8, 8, 8, 8, 7, 7, 7, 7, 7, 7, 7, 9, 7, 8, 8, 8, 8, 5, 5,
		   4, 4, 8, 7, 8, 8, 8, 8, 8, 8, 8, 7, 7, 7, 7, 8, 6, 8
	};
	
	for(int i=SizeOfArray(fontDef)-1; i>=0; --i){
		buf[i] = fontDef[i];
	}
}

void DialogueBox_GetFontDef_SmallProportional(int buf){
	int fontDef[] = {
		// Character widths, including any trailing space
		// ASCII characters 32 to 126
		
		// sp !  "  #  $  %  &  '  (  )  *  +  ,  -  .  /
		   3, 2, 4, 6, 6, 6, 5, 3, 3, 3, 6, 6, 3, 4, 2, 6,
		
		// 0  1  2  3  4  5  6  7  8  9
		   4, 3, 4, 4, 4, 4, 4, 4, 4, 4,
		
		// :  ;  <  =  >  ?  @
		   2, 3, 4, 4, 4, 4, 5,
		
		// A  B  C  D  E  F  G  H  I  J  K  L  M  N  O  P  Q  R  S  T  U  V  W  X  Y  Z
		   4, 4, 4, 4, 3, 3, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4,
		
		// [  \  ]  ^  _  `
		   3, 6, 3, 4, 6, 3,
		
		// a  b  c  d  e  f  g  h  i  j  k  l  m  n  o  p  q  r  s  t  u  v  w  x  y  z
		   4, 4, 4, 4, 3, 3, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4,
		
		// {  |  }  ~
		   4, 2, 4, 5,
		
		// Additional characters
		   6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6,
		   6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6,
		   6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6,
		   6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6,
		   6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6,
		   6, 6, 6, 6, 6, 6, 6, 6, 6
	};
	
	for(int i=SizeOfArray(fontDef)-1; i>=0; --i){
		buf[i] = fontDef[i];
	}
}

void DialogueBox_GetFontDef_SS3(int buf){
	int fontDef[] = {
		// Character widths, including any trailing space
		// ASCII characters 32 to 126
		
		// sp !  "  #  $  %  &  '  (  )  *  +  ,  -  .  /
		   3, 3, 6, 8, 8, 9, 7, 3, 5, 5, 6, 7, 4, 6, 4, 7,
		
		// 0  1  2  3  4  5  6  7  8  9
		   6, 4, 6, 6, 6, 6, 6, 6, 6, 6,
		
		// :  ;  <  =  >  ?  @
		   3, 3, 6, 6, 6, 6, 9,
		
		// A  B  C  D  E  F  G  H  I  J  K  L  M  N  O  P  Q  R  S  T  U  V  W  X  Y  Z
		   6, 6, 6, 6, 6, 6, 6, 6, 6, 5, 6, 6, 9, 7, 6, 6, 6, 6, 6, 5, 6, 6, 9, 6, 7, 6,
		
		// [  \  ]  ^  _  `
		   4, 7, 4, 6, 6, 4,
		
		// a  b  c  d  e  f  g  h  i  j  k  l  m  n  o  p  q  r  s  t  u  v  w  x  y  z
		   6, 6, 6, 6, 6, 6, 6, 6, 6, 5, 6, 6, 9, 7, 6, 6, 6, 6, 6, 5, 6, 6, 9, 6, 7, 6,
		
		// {  |  }  ~
		   5, 3, 5, 8,
		
		// Additional characters
		   6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6,
		   6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6,
		   6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6,
		   6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6,
		   6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6,
		   6, 6, 6, 6, 6, 6, 6, 6, 6
	};

	for(int i=SizeOfArray(fontDef)-1; i>=0; --i){
		buf[i] = fontDef[i];
	}
}

//Internal function to get the width and height of the selection box and store it in an array
void DialogueBox_GetDimensions(int strings, int numStrings, int dimensions, int font){
	int fontDef[512];
	DialogueBox_GetFontDef(fontDef, font);
	
	int width;
	int lineCount;
	int xyTemp[2];
	for(int i=0; i<numStrings; i++){
		//height += DialogueBox_GetStringHeight(font)+2;
		if(strings[i]<0){
			int str[256];
			Game->GetMessage(Abs(strings[i]), str);
			String_Cap(str);
			//String drawing function repurposed for measuring lengths when ending with false
			DialogueBox_DrawStrings(0, 0, 0, font, 0, 0, 0, DIALOGUEBOX_MAX_LINEWIDTH, 0, str, 128, fontDef, xyTemp, false);
			if(xyTemp[0]>width)
				width = xyTemp[0];
			lineCount += xyTemp[1];
		}
		else if(strings[i]>0){
			int str = strings[i];
			//String drawing function repurposed for measuring lengths when ending with false
			DialogueBox_DrawStrings(0, 0, 0, font, 0, 0, 0, DIALOGUEBOX_MAX_LINEWIDTH, 0, str, 128, fontDef, xyTemp, false);
			if(xyTemp[0]>width)
				width = xyTemp[0];
			lineCount += xyTemp[1];
		}
	}
	dimensions[0] = width;
	dimensions[1] = lineCount;
}

//Function works like ZC's DrawString but converts a ZQuest string first
int DialogueBox_DrawZScriptString(int layer, int x, int y, int font, int c, int c2, int tf, int strid, int op){
	int str[256];
	Game->GetMessage(strid, str);
	String_Cap(str);
	Screen->DrawString(layer, x, y, font, c, c2, tf, str, op);
}

//Function to draw multiple strings or get the length of multiple strings
int DialogueBox_DrawStrings(int layer, int x, int y, int font, int clr1, int clr2, int format, int lineWidth, int lineHeight, int ptr, int op, int fontDef, int xyBuffer, bool actuallyDraw){
	lineHeight += DIALOGUEBOX_LINE_SPACING;
	int strBuf[512];
	int pos;
	int wordPos; //The index for the start of a word
	int endPos; //The index for the end of the line being drawn
	int linePos; //The index for the start of the line being drawn
	int bufPos; //The index for the position in the buffer for the current line
	int width;
	int yoff;
	int maxLen;
	int lineCount;
	while(ptr[pos]!=0){
		linePos = pos;
		width = 0;
		bufPos = 0;
		while((width<lineWidth||ptr[pos]==' ')&&ptr[pos]!=0){
			if(ptr[pos]>=' ')
				width += fontDef[ptr[pos]-' ']; //Font definition starts at the space character
			if(ptr[pos]==' '&&ptr[pos+1]!=' ')
				wordPos = pos+1;
			strBuf[bufPos] = ptr[pos];
			++pos;
			++bufPos;
		}
		if(wordPos!=linePos&&ptr[pos]!=0)
			endPos = wordPos;
		else
			endPos = pos;
		strBuf[endPos-linePos] = 0;
		int spaceEraser = endPos-linePos-1;
		while(strBuf[spaceEraser]==' '&&spaceEraser>0){
			strBuf[spaceEraser] = 0;
			--spaceEraser;
		}
		int strLen = DialogueBox_GetStringLengthFromDef(strBuf, fontDef);
		if(strLen>=maxLen){
			maxLen = strLen;
		}
		if(actuallyDraw)
			Screen->DrawString(layer, x, y+yoff, font, clr1, clr2, format, strBuf, op);
		pos = endPos;
		yoff += lineHeight;
		++lineCount;
		if(lineCount>100)
			break;
	}
	if(xyBuffer>0){
		xyBuffer[0] = maxLen;
		xyBuffer[1] = lineCount;
	}
}

//The basic function for the dialogue box. 
//Will take over until it finishes and then return the index of the option chosen.

//   int x,y - Center position of the box
//   int strings - An array of any size containing all the string pointers for the dialogue box.
//   				If the values in the array are negative, they'll be treated as ZQuest strings instead.
//   int tileDB - First of 8 tiles used to form the dialogue box background
//   int csDB - CSet for the background
//   int colorDB - Color used to fill in the middle of the background
//   int font - Font used by the options. See FONT_ in std_constants.zh
//   int cFont - Color of the options
//   int tileArrow - Tile of the selection arrow. Should be an 8x8 minitile in the upper left corner.
//   int csArrow - The CSet of the selection arrow
int DialogueBox_Run(int x, int y, int strings, int tileDB, int csDB, int colorDB, int font, int cFont, int tileArrow, int csArrow){
	int trueStrings[16];
	int numStrings;
	for(int i=0; i<SizeOfArray(strings); i++){
		if(strings[i]!=0){
			trueStrings[numStrings] = strings[i];
			numStrings++;
		}
	}
	
	int tempX; int tempY;
	int dimensions[2];
	int xyTemp[2];
	int strHeight = DialogueBox_GetStringHeight(font);
	DialogueBox_GetDimensions(trueStrings, numStrings, dimensions, font);
	int fontDef[512];
	DialogueBox_GetFontDef(fontDef, font);
	
	int boxWidth = dimensions[0]+DIALOGUEBOX_WIDTH_SPACING;
	int boxHeight = dimensions[1]*(strHeight+DIALOGUEBOX_LINE_SPACING)+(numStrings-1)*DIALOGUEBOX_OPTION_SPACING+DIALOGUEBOX_HEIGHT_SPACING;
	Game->PlaySound(SFX_DB_OPEN);
	//Open the dialogue box
	for(int i=0; i<24; i++){
		DialogueBox_DrawBox(6, x, y, tileDB, csDB, colorDB, Round(boxWidth*(i/24)), Round(boxHeight*(i/24)));
		WaitNoAction();
	}
	int selection;
	int upCounter; int downCounter;
	int alignmentXOff;
	if(DIALOGUEBOX_TEXT_ALIGNMENT==TF_NORMAL)
		alignmentXOff = -(boxWidth-DIALOGUEBOX_WIDTH_SPACING)/2;
	else if(DIALOGUEBOX_TEXT_ALIGNMENT==TF_RIGHT)
		alignmentXOff = (boxWidth-DIALOGUEBOX_WIDTH_SPACING)/2;
	int cursorCenterYOff;
	if(DIALOGUEBOX_CENTER_CURSOR_VERTICALLY)
		cursorCenterYOff = (strHeight*0.5);
	//Wait until a selection is made
	while(!Link->PressA){
		DialogueBox_DrawBox(6, x, y, tileDB, csDB, colorDB, boxWidth, boxHeight);
		tempY = y-(boxHeight-DIALOGUEBOX_HEIGHT_SPACING)/2;
		for(int i=0; i<numStrings; i++){
			tempX = x;
			if(trueStrings[i]>0){
				int str = trueStrings[i];
				DialogueBox_DrawStrings(6, tempX+alignmentXOff, tempY, font, cFont, -1, DIALOGUEBOX_TEXT_ALIGNMENT, DIALOGUEBOX_MAX_LINEWIDTH, strHeight, str, 128, fontDef, xyTemp, true);
				int selX = tempX-xyTemp[0]/2-10;
				int selY = tempY+(strHeight/2)-5+cursorCenterYOff*(xyTemp[1]-1);
				if(DIALOGUEBOX_TEXT_ALIGNMENT==TF_NORMAL)
					selX = tempX-(boxWidth-DIALOGUEBOX_WIDTH_SPACING)/2-10;
				if(DIALOGUEBOX_TEXT_ALIGNMENT==TF_RIGHT)
					selX = tempX+(boxWidth-DIALOGUEBOX_WIDTH_SPACING)/2-xyTemp[0]-12;
				if(selection==i)
					Screen->FastTile(6, selX, selY, tileArrow, csArrow, 128);
				tempY += (xyTemp[1])*(strHeight+DIALOGUEBOX_LINE_SPACING);
			}
			else if(trueStrings[i]<0){
				int str[256];
				Game->GetMessage(Abs(trueStrings[i]), str);
				String_Cap(str);
				DialogueBox_DrawStrings(6, tempX+alignmentXOff, tempY, font, cFont, -1, DIALOGUEBOX_TEXT_ALIGNMENT, DIALOGUEBOX_MAX_LINEWIDTH, strHeight, str, 128, fontDef, xyTemp, true);
				int selX = tempX-xyTemp[0]/2-10;
				int selY = tempY+(strHeight/2)-5+cursorCenterYOff*(xyTemp[1]-1);
				if(DIALOGUEBOX_TEXT_ALIGNMENT==TF_NORMAL)
					selX = tempX-(boxWidth-DIALOGUEBOX_WIDTH_SPACING)/2-10;
				if(DIALOGUEBOX_TEXT_ALIGNMENT==TF_RIGHT)
					selX = tempX+(boxWidth-DIALOGUEBOX_WIDTH_SPACING)/2-xyTemp[0]-12;
				if(selection==i)
					Screen->FastTile(6, selX, selY, tileArrow, csArrow, 128);
				tempY += (xyTemp[1])*(strHeight+DIALOGUEBOX_LINE_SPACING);
			}
			tempY += DIALOGUEBOX_OPTION_SPACING;
		}
		if(Link->InputUp)
			upCounter++;
		else
			upCounter = 0;
		if(Link->InputDown)
			downCounter++;
		else
			downCounter = 0;
		if(Link->PressUp||upCounter>16){
			upCounter = 0;
			downCounter = 0;
			Game->PlaySound(SFX_DB_MOVECURSOR);
			selection--;
			if(selection<0)
				selection = numStrings-1;
		}
		else if(Link->PressDown||downCounter>16){
			upCounter = 0;
			downCounter = 0;
			Game->PlaySound(SFX_DB_MOVECURSOR);
			selection++;
			if(selection>numStrings-1)
				selection = 0;
		}
		WaitNoAction();
	}
	Game->PlaySound(SFX_DB_CONFIRM);
	//Brief pause before closing
	for(int j=0; j<12; j++){
		DialogueBox_DrawBox(6, x, y, tileDB, csDB, colorDB, boxWidth, boxHeight);
		tempY = y-(boxHeight-DIALOGUEBOX_HEIGHT_SPACING)/2;
		for(int i=0; i<numStrings; i++){
			tempX = x;
			if(trueStrings[i]>0){
				int str = trueStrings[i];
				DialogueBox_DrawStrings(6, tempX+alignmentXOff, tempY, font, cFont, -1, DIALOGUEBOX_TEXT_ALIGNMENT, DIALOGUEBOX_MAX_LINEWIDTH, strHeight, str, 128, fontDef, xyTemp, true);
				int selX = tempX-xyTemp[0]/2-10;
				int selY = tempY+(strHeight/2)-5+cursorCenterYOff*(xyTemp[1]-1);
				if(DIALOGUEBOX_TEXT_ALIGNMENT==TF_NORMAL)
					selX = tempX-(boxWidth-DIALOGUEBOX_WIDTH_SPACING)/2-10;
				if(DIALOGUEBOX_TEXT_ALIGNMENT==TF_RIGHT)
					selX = tempX+(boxWidth-DIALOGUEBOX_WIDTH_SPACING)/2-xyTemp[0]-12;
				if(selection==i&&j%4<2)
					Screen->FastTile(6, selX, selY, tileArrow, csArrow, 128);
				tempY += xyTemp[1]*(strHeight+DIALOGUEBOX_LINE_SPACING);
			}
			else if(trueStrings[i]<0){
				int str[256];
				Game->GetMessage(Abs(trueStrings[i]), str);
				String_Cap(str);
				DialogueBox_DrawStrings(6, tempX+alignmentXOff, tempY, font, cFont, -1, DIALOGUEBOX_TEXT_ALIGNMENT, DIALOGUEBOX_MAX_LINEWIDTH, strHeight, str, 128, fontDef, xyTemp, true);
				int selX = tempX-xyTemp[0]/2-10;
				int selY = tempY+(strHeight/2)-5+cursorCenterYOff*(xyTemp[1]-1);
				if(DIALOGUEBOX_TEXT_ALIGNMENT==TF_NORMAL)
					selX = tempX-(boxWidth-DIALOGUEBOX_WIDTH_SPACING)/2-10;
				if(DIALOGUEBOX_TEXT_ALIGNMENT==TF_RIGHT)
					selX = tempX+(boxWidth-DIALOGUEBOX_WIDTH_SPACING)/2-xyTemp[0]-12;
				if(selection==i&&j%4<2)
					Screen->FastTile(6, selX, selY, tileArrow, csArrow, 128);
				tempY += xyTemp[1]*(strHeight+DIALOGUEBOX_LINE_SPACING);
			}
			tempY += DIALOGUEBOX_OPTION_SPACING;
		}
		WaitNoAction();
	}
	Game->PlaySound(SFX_DB_CLOSE);
	//Close the dialogue box
	for(int i=12; i>0; i--){
		DialogueBox_DrawBox(6, x, y, tileDB, csDB, colorDB, Round(boxWidth*(i/12)), Round(boxHeight*(i/12)));
		WaitNoAction();
	}
	return selection;
}

//A slightly more complex version of the dialogue box that runs every frame.
//You'll want this if your script has to do other things while the dialogue box is running.
//To use this function, either call it in a while() loop and it will terminate when done, or use while(handler[1]==0)
//To get the output afterwards, check handler[0]

//   int handler[6] - An empty array that handles the data between frames. Be sure to declare it before the dialogue box's while loop.
//   int x,y - Center position of the box
//   int strings - An array of any size containing all the string pointers for the dialogue box.
//   				If the values in the array are negative, they'll be treated as ZQuest strings instead.
//   int tileDB - First of 8 tiles used to form the dialogue box background
//   int csDB - CSet for the background
//   int colorDB - Color used to fill in the middle of the background
//   int font - Font used by the options. See FONT_ in std_constants.zh
//   int cFont - Color of the options
//   int tileArrow - Tile of the selection arrow. Should be an 8x8 minitile in the upper left corner.
//   int csArrow - The CSet of the selection arrow
bool DialogueBox_RunSingleFrame(int handler, int x, int y, int strings, int tileDB, int csDB, int colorDB, int font, int cFont, int tileArrow, int csArrow){
	int trueStrings[16];
	int numStrings;
	for(int i=0; i<SizeOfArray(strings); i++){
		if(strings[i]!=0){
			trueStrings[numStrings] = strings[i];
			numStrings++;
		}
	}
	
	int SELECTION = 0;
	int DONE = 1;
	int TIMER = 2;
	int PHASE = 3;
	int UPCOUNT = 4;
	int DOWNCOUNT = 5;
	int tempX; int tempY;
	int dimensions[2];
	int xyTemp[2];
	int strHeight = DialogueBox_GetStringHeight(font);
	DialogueBox_GetDimensions(trueStrings, numStrings, dimensions, font);
	int fontDef[512];
	DialogueBox_GetFontDef(fontDef, font);
	
	int boxWidth = dimensions[0]+DIALOGUEBOX_WIDTH_SPACING;
	int boxHeight = dimensions[1]*(strHeight+DIALOGUEBOX_LINE_SPACING)+(numStrings-1)*DIALOGUEBOX_OPTION_SPACING+DIALOGUEBOX_HEIGHT_SPACING;
	
	int alignmentXOff;
	if(DIALOGUEBOX_TEXT_ALIGNMENT==TF_NORMAL)
		alignmentXOff = -(boxWidth-DIALOGUEBOX_WIDTH_SPACING)/2;
	else if(DIALOGUEBOX_TEXT_ALIGNMENT==TF_RIGHT)
		alignmentXOff = (boxWidth-DIALOGUEBOX_WIDTH_SPACING)/2;
	int cursorCenterYOff;
	if(DIALOGUEBOX_CENTER_CURSOR_VERTICALLY)
		cursorCenterYOff = (strHeight*0.5);
	
	//Open the dialogue box
	if(handler[PHASE]==0){
		if(handler[TIMER]==0)
			Game->PlaySound(SFX_DB_OPEN);
		DialogueBox_DrawBox(6, x, y, tileDB, csDB, colorDB, Round(boxWidth*(handler[TIMER]/24)), Round(boxHeight*(handler[TIMER]/24)));
		handler[TIMER]++;
		if(handler[TIMER]>=24){
			handler[PHASE] = 1;
		}
	}
	//Wait until a selection is made
	else if(handler[PHASE]==1){
		DialogueBox_DrawBox(6, x, y, tileDB, csDB, colorDB, boxWidth, boxHeight);
		tempY = y-(boxHeight-DIALOGUEBOX_HEIGHT_SPACING)/2;
		for(int i=0; i<numStrings; i++){
			tempX = x;
			if(trueStrings[i]>0){
				int str = trueStrings[i];
				DialogueBox_DrawStrings(6, tempX+alignmentXOff, tempY, font, cFont, -1, DIALOGUEBOX_TEXT_ALIGNMENT, DIALOGUEBOX_MAX_LINEWIDTH, strHeight, str, 128, fontDef, xyTemp, true);
				int selX = tempX-xyTemp[0]/2-10;
				int selY = tempY+(strHeight/2)-5+cursorCenterYOff*(xyTemp[1]-1);
				if(DIALOGUEBOX_TEXT_ALIGNMENT==TF_NORMAL)
					selX = tempX-(boxWidth-DIALOGUEBOX_WIDTH_SPACING)/2-10;
				if(DIALOGUEBOX_TEXT_ALIGNMENT==TF_RIGHT)
					selX = tempX+(boxWidth-DIALOGUEBOX_WIDTH_SPACING)/2-xyTemp[0]-12;
				if(handler[SELECTION]==i)
					Screen->FastTile(6, selX, selY, tileArrow, csArrow, 128);
				tempY += (xyTemp[1])*(strHeight+DIALOGUEBOX_LINE_SPACING);
			}
			else if(trueStrings[i]<0){
				int str[256];
				Game->GetMessage(Abs(trueStrings[i]), str);
				String_Cap(str);
				DialogueBox_DrawStrings(6, tempX+alignmentXOff, tempY, font, cFont, -1, DIALOGUEBOX_TEXT_ALIGNMENT, DIALOGUEBOX_MAX_LINEWIDTH, strHeight, str, 128, fontDef, xyTemp, true);
				int selX = tempX-xyTemp[0]/2-10;
				int selY = tempY+(strHeight/2)-5+cursorCenterYOff*(xyTemp[1]-1);
				if(DIALOGUEBOX_TEXT_ALIGNMENT==TF_NORMAL)
					selX = tempX-(boxWidth-DIALOGUEBOX_WIDTH_SPACING)/2-10;
				if(DIALOGUEBOX_TEXT_ALIGNMENT==TF_RIGHT)
					selX = tempX+(boxWidth-DIALOGUEBOX_WIDTH_SPACING)/2-xyTemp[0]-12;
				if(handler[SELECTION]==i)
					Screen->FastTile(6, selX, selY, tileArrow, csArrow, 128);
				tempY += (xyTemp[1])*(strHeight+DIALOGUEBOX_LINE_SPACING);
			}
			tempY += DIALOGUEBOX_OPTION_SPACING;
		}
		if(Link->InputUp)
			handler[UPCOUNT]++;
		else
			handler[UPCOUNT] = 0;
		if(Link->InputDown)
			handler[DOWNCOUNT]++;
		else
			handler[DOWNCOUNT] = 0;
		if(Link->PressUp||handler[UPCOUNT]>16){
			handler[UPCOUNT] = 0;
			handler[DOWNCOUNT] = 0;
			Game->PlaySound(SFX_DB_MOVECURSOR);
			handler[SELECTION]--;
			if(handler[SELECTION]<0)
				handler[SELECTION] = numStrings-1;
		}
		else if(Link->PressDown||handler[DOWNCOUNT]>16){
			handler[UPCOUNT] = 0;
			handler[DOWNCOUNT] = 0;
			Game->PlaySound(SFX_DB_MOVECURSOR);
			handler[SELECTION]++;
			if(handler[SELECTION]>numStrings-1)
				handler[SELECTION] = 0;
		}
		else if(Link->PressA){
			handler[PHASE] = 2;
			handler[TIMER] = 0;
			Game->PlaySound(SFX_DB_CONFIRM);
		}
	}
	//Brief pause before closing
	else if(handler[PHASE]==2){
		DialogueBox_DrawBox(6, x, y, tileDB, csDB, colorDB, boxWidth, boxHeight);
		tempY = y-(boxHeight-DIALOGUEBOX_HEIGHT_SPACING)/2;
		for(int i=0; i<numStrings; i++){
			tempX = x;
			if(trueStrings[i]>0){
				int str = trueStrings[i];
				DialogueBox_DrawStrings(6, tempX+alignmentXOff, tempY, font, cFont, -1, DIALOGUEBOX_TEXT_ALIGNMENT, DIALOGUEBOX_MAX_LINEWIDTH, strHeight, str, 128, fontDef, xyTemp, true);
				int selX = tempX-xyTemp[0]/2-10;
				int selY = tempY+(strHeight/2)-5+cursorCenterYOff*(xyTemp[1]-1);
				if(DIALOGUEBOX_TEXT_ALIGNMENT==TF_NORMAL)
					selX = tempX-(boxWidth-DIALOGUEBOX_WIDTH_SPACING)/2-10;
				if(DIALOGUEBOX_TEXT_ALIGNMENT==TF_RIGHT)
					selX = tempX+(boxWidth-DIALOGUEBOX_WIDTH_SPACING)/2-xyTemp[0]-12;
				if(handler[SELECTION]==i&&handler[TIMER]%4<2)
					Screen->FastTile(6, selX, selY, tileArrow, csArrow, 128);
				tempY += xyTemp[1]*(strHeight+DIALOGUEBOX_LINE_SPACING);
			}
			else if(trueStrings[i]<0){
				int str[256];
				Game->GetMessage(Abs(trueStrings[i]), str);
				String_Cap(str);
				DialogueBox_DrawStrings(6, tempX+alignmentXOff, tempY, font, cFont, -1, DIALOGUEBOX_TEXT_ALIGNMENT, DIALOGUEBOX_MAX_LINEWIDTH, strHeight, str, 128, fontDef, xyTemp, true);
				int selX = tempX-xyTemp[0]/2-10;
				int selY = tempY+(strHeight/2)-5+cursorCenterYOff*(xyTemp[1]-1);
				if(DIALOGUEBOX_TEXT_ALIGNMENT==TF_NORMAL)
					selX = tempX-(boxWidth-DIALOGUEBOX_WIDTH_SPACING)/2-10;
				if(DIALOGUEBOX_TEXT_ALIGNMENT==TF_RIGHT)
					selX = tempX+(boxWidth-DIALOGUEBOX_WIDTH_SPACING)/2-xyTemp[0]-12;
				if(handler[SELECTION]==i&&handler[TIMER]%4<2)
					Screen->FastTile(6, selX, selY, tileArrow, csArrow, 128);
				tempY += xyTemp[1]*(strHeight+DIALOGUEBOX_LINE_SPACING);
			}
			tempY += DIALOGUEBOX_OPTION_SPACING;
		}
		handler[TIMER]++;
		if(handler[TIMER]>=12){
			handler[PHASE] = 3;
			handler[TIMER] = 12;
			Game->PlaySound(SFX_DB_CLOSE);
		}
	}
	//Close the dialogue box
	else if(handler[PHASE]==3){
		DialogueBox_DrawBox(6, x, y, tileDB, csDB, colorDB, Round(boxWidth*(handler[TIMER]/12)), Round(boxHeight*(handler[TIMER]/12)));
		handler[TIMER]--;
		if(handler[TIMER]<=0){
			handler[PHASE] = 4;
			handler[TIMER] = 0;
			handler[DONE] = 1;
			return false;
		}
	}
	return true;
}

//x-----------------------x
//|   String Functions    |
//x-----------------------x
//Why yes, I could have just used string.zh, but you see, I am a rebel.
//Fuck the police!


//Removes trailing spaces on a string
void String_Cap(int str){
	for(int i=SizeOfArray(str)-1; i>=0; i--){
		if(str[i]>32){
			str[i+1] = 0;
			return;
		}
	}
}

//Makes a string uppercase
void String_ToUppercase(int str){
	int size = SizeOfArray(str);
	for(int i=0; i<size&&str[i]!=0; i++){
		if(str[i]>='a'&&str[i]<='z'){
			str[i]-=32;
		}
	}
}

//Makes a string not uppercase
void String_ToLowercase(int str){
	int size = SizeOfArray(str);
	for(int i=0; i<size&&str[i]!=0; i++){
		if(str[i]>='A'&&str[i]<='Z'){
			str[i]+=32;
		}
	}
}

//Writes over part of a string with another string. Poor man's strcat.
void String_WriteOver(int str, int index, int str2){
	int size = SizeOfArray(str);
	int size2 = SizeOfArray(str2);
	int i;
	for(i=index; i<size&&i<index+size2; i++){
		str[i] = str2[i-index];
	}
	str[i] = 0;
}

//Check if a string contains another string at the start
bool String_StartsWith(int str, int subStr){
	for(int i=0; subStr[i]!=0; i++){
		if(subStr[i]!=str[i])
			return false;
	}
	return true;
}

//Find the length of a string
int String_Length(int str){
	int size = SizeOfArray(str);
	for(int i=size-1; i>0; i--){
		if(str[i]==0){
			return i;
		}
	}
}

//Check if a string contains another string
bool String_Contains(int str, int subStr){
	int length = String_Length(subStr);
	int size = SizeOfArray(str);
	for(int i=0; i<size&&str[i]!=0; i++){
		if(str[i]==subStr[0]){
			int j;
			for(j=1; j<length; j++){
				if(subStr[j]!=str[i+j])
					break;
			}
			if(j==length)
				return true;
		}
	}
	return false;
}

//Find the nth instance of a character in a string from startIndex to endIndex
//Returns -1 if not found
int String_FindChar(int str, int startIndex, int endIndex, int char, int count){
	int size = SizeOfArray(str);
	if(endIndex<=0)
		endIndex = 9999;
	for(int i=startIndex; i<size&&str[i]!=0&&i<endIndex; i++){
		if(str[i]==char){
			count--;
			if(count<=0){
				return i;
			}
		}
	}
	return -1;
}

//Find the nth instance of a string in a string from startIndex to endIndex
//Returns -1 if not found
int String_FindStr(int str, int startIndex, int endIndex, int subStr, int count){
	int length = String_Length(subStr);
	int size = SizeOfArray(str);
	if(endIndex<=0)
		endIndex = 9999;
	for(int i=startIndex; i<size&&str[i]!=0&&i<endIndex; i++){
		if(str[i]==subStr[0]){
			int j;
			for(j=1; j<length; j++){
				if(subStr[j]!=str[i+j])
					break;
			}
			if(j==length){
				count--;
				if(count<=0){
					return i;
				}
			}
		}
	}
	return -1;
}

//Find the nth instance of an integer in a string from startIndex to endIndex
//Returns -1 if not found
int String_FindInt(int str, int startIndex, int endIndex, int count){
	int size = SizeOfArray(str);
	if(endIndex<=0)
		endIndex = 9999;
	for(int i=startIndex; i<size&&str[i]!=0&&i<endIndex; i++){
		if(str[i]>='0'&&str[i]<='9'){
			int j;
			for(j=i; j<size&&str[j]>='0'&&str[j]<='9'; j++){ //for(j=1; str[i+j]>='0'&&str[i+j]<='9'; j++){
				//Wow, it's nothing!
			}
			count--;
			if(count<=0){
				return i;
			}
			i = j;
		}
	}
	return -1;
}

//Find the value of an integer that has been found in a string
int String_LoadInt(int str, int startIndex){
	int digits[5];
	int numDigits;
	for(int i=0; str[i+startIndex]>='0'&&str[i+startIndex]<='9'&&numDigits<5; i++){
		digits[numDigits] = str[i+startIndex]-'0';
		numDigits++;
	}
	int val;
	for(int i=numDigits-1; i>=0; i--){
		//This is ugly, but the alternative was the power function which apparently cannot be trusted
		int j = numDigits-1-i;
		if(j==0)
			val += digits[i];
		else if(j==1)
			val += digits[i]*10;
		else if(j==2)
			val += digits[i]*100;
		else if(j==3)
			val += digits[i]*1000;
		else if(j==4)
			val += digits[i]*10000;
	}
	return val;
}

//Find and load an integer all at once
//Returns -1 if it fails to find it
int String_FindLoadInt(int str, int startIndex, int endIndex, int count){
	int i = String_FindInt(str, startIndex, endIndex, count);
	if(i>0){
		return String_LoadInt(str, i);
	}
	return -1;
}