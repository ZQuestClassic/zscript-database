//import "std.zh"

//This simple script simulates a lighting/flash effect (GB styled of course) by drawing a rectangle on a given layer and then simulating a flash effect. 
//There are two versions of this script. Version "A" only needs to be set once and then it's plug and play.
//Version "B" needs to be set everytime you want to use it per screen. Useful if you want to create different effects on different screens.
//The SFX can be set to "0" if you only want a flash effect to happen.


//VERSION A:

const int LIGHTNING_DELAY = 170;//Delay in frames until the effect repeats itself. 
const int LIGHTNING_SFX   = 67; //SFX to use. Self explanatory.
const int LIGHTNING_LAYER = 5;  //Layer to draw the rectangle to. (Needs to be used by the screen).
const int LIGHTNING_COLOR = 12; //The rectangle is drawn using the specified index into the entire 256-element palette: for instance, passing in a color of 17 would use color 1 of cset 1.

ffc script Lighting_Effect_A{
	void run(){
		while(true){
			Waitframes(LIGHTNING_DELAY);
			Game->PlaySound(LIGHTNING_SFX);
                        for(int i; i < 5; i++){
				Screen->Rectangle(LIGHTNING_LAYER, 0, 0, 256, 176, LIGHTNING_COLOR, 1, 0, 0, 0, true, OP_OPAQUE);
				Waitframes(5);
				Screen->Rectangle(LIGHTNING_LAYER, 0, 0, 256, 176, 0, 1, 0, 0, 0, true, OP_OPAQUE);
			}
		}
	}
}


//VERSION B

//The version that's not plug and play.
//Arguments are as follows:
//D0 is the delay in frames until the effect repeats itself. 
//D1 is the SFX to use. Self explanatory.
//D2 is the Layer to draw the rectangle to. (Needs to be used by the screen).
//D3 is the color of the rectangle using the specified index into the entire 256-element palette: for instance, passing in a color of 17 would use color 1 of cset 1.

ffc script Lighting_Effect_B{
	void run(int delay, int sfx, int layer, int color){
		while(true){
			Waitframes(delay);
			Game->PlaySound(sfx);
                        for(int i; i < 5; i++){
				Screen->Rectangle(layer, 0, 0, 256, 176, color, 1, 0, 0, 0, true, OP_OPAQUE);
				Waitframes(5);
				Screen->Rectangle(layer, 0, 0, 256, 176, 1, 0, 0, 0, 0, true, OP_OPAQUE);
			}
		}
	}
}