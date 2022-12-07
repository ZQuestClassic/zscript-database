import "std.zh"

//This script turns your mouse pointer into a fairy partner!
//Planned features include:
//	Plugins for strings on clicking monsters	<DONE>
//	Plugins for strings or visual effects on mousing over certain areas	<DONE>
//	Plugins for special item use.


//At the moment, this fairy script is purely cosmetic.


//Note that this is made for 1-tile fairies. 

const int FAIRY_COMBO 			= 34536;		//The first tile on the tilepage. Arrange these in UDLR order.
const int FAIRY_CSET 			= 7;			//The CSet you want to use.
const int FAIRY_ESTRING_OFFSET 	= 4;			//The first string tied to an enemy's ID.
const int FAIRY_TOTAL_ENEMIES		= 14;		//The total number of enemies to play messages for. Leave at 0 for no messages.


int FAIRY_ESTRINGS[] = {			//Set your strings up in the order of the enemies listed.
	
//Enemy,				string order
NPC_OCTOROCK1F,		
NPC_OCTOROCK1S,		
NPC_OCTOROCK2F,		
NPC_OCTOROCK2S,		
NPC_TEKTITE1,			
NPC_TEKTITE2,			
NPC_ROPE1,			
NPC_ROPE2,			
NPC_STALFOS1,			
NPC_STALFOS2,			
NPC_STALFOS3,			
NPC_KEESE1,			
NPC_AQUAMENTUSL,		
NPC_AQUAMENTUSR
};

int ax;
int ay;
int bx;
int by;
int FAIRY_DIR;




global script global2{
	void run(){
		Game->ClickToFreezeEnabled = false;
		while(true){
			FAIRY_INIT();
			Waitframe();
		}
	}
}

ffc script FAIRY_EMOTE_PLUGIN{
	void run(int tile, int cset){
		while(true){
			if(RectCollision(Link->InputMouseX, Link->InputMouseY, Link->InputMouseX, Link->InputMouseY, this->X, this->Y, this->X + (this->TileWidth * 16), this->Y + (this->TileHeight * 16))){
				Screen->DrawCombo(4, Link->InputMouseX - 8, Link->InputMouseY - 24, tile, 1, 1, cset, -1, -1, 0, 0, 0, 0, 0, true, 128);
			}
			Waitframe();
		}
	}
}




void FAIRY_INIT(){			//Draws the fairy in reference to its current direction
	
	FAIRY_CLICK();
	
	bx = Link->InputMouseX;		//Store the second set...
	by = Link->InputMouseY;

	if(ax > bx && Abs(ax-bx) > Abs(ay-by)){			//if the mouse is moving Left...
		FAIRY_DIR = DIR_LEFT;
	}
	else if(ax < bx && Abs(ax-bx) > Abs(ay-by)){		//if the mouse is moving right...
		FAIRY_DIR = DIR_RIGHT;
	}
	else if(ay > by && Abs(ax-bx) < Abs(ay-by)){		//if the mouse is moving Up...
		FAIRY_DIR = DIR_UP;
	}
	else if(ay < by && Abs(ax-bx) < Abs(ay-by)){		//if the mouse is moving down...
		FAIRY_DIR = DIR_DOWN;
	}


	Screen->DrawCombo(4, (Link->InputMouseX - 8), (Link->InputMouseY - 8), (FAIRY_COMBO + FAIRY_DIR), 1, 1, FAIRY_CSET, -1, -1, 0, 0, 0, 0, 0, true, 128);	//Draw the fairy...
	
	ax = Link->InputMouseX;		//and then store the first set.
	ay = Link->InputMouseY;
	
}

void FAIRY_CLICK(){
	if(Link->InputMouseB){
		int npcID=GetNpcAt(Link->InputMouseX - 8, Link->InputMouseY - 8);
		for(int i = 0; i < FAIRY_TOTAL_ENEMIES; i++){
			if(npcID == FAIRY_ESTRINGS[i]){
				int m = i + FAIRY_ESTRING_OFFSET;
				Screen->Message(m);
				return;
			}
		}
	}
}

int GetNpcAt(int x, int y){
	npc a;
	for(int i = 1; i <= Screen->NumNPCs(); i++){
		a = Screen->LoadNPC(i);
		if(RectCollision(x, y, x+15, y+15, a->X, a->Y, a->X+a->HitWidth, a->Y+a->HitHeight)){
			return a->ID;
		}
	}	
	return -1;
}

void FAIRY_CLICK_LOCATION(int lowx, int lowy, int hix, int hiy, int m){
	if(Link->InputMouseX >= lowx && Link->InputMouseX <= hix && Link->InputMouseY >= lowy && Link->InputMouseY <= hiy && Link->InputMouseB){
		Screen->Message(m);
		Link->InputMouseB = 0;
	}
}