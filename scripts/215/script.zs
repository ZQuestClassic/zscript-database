import "std.zh"
import "screen_change.zh"

int Pots[176];
int nPots;

//Constants used to configure the script
const int PS_HEIGHT      = 2;          //hight of sprite
const int PS_WIDTH       = 2;          //width of sprite
const int PS_AFRAMES     = 8;          //number of animation sprites used
const int PS_SPEED       = 3;          //speed of the animation: smaller = faster, don't use 0!
const int PS_CSET        = 7;          //cset to be used
const int PS_LAYER       = 3;          //layer to be displayed on
const int PS_ANIMATION   = 1300;       //the combo ID of the top left of the first frame on the tiles page
const int PS_SFX         = 62;         //sound effect to be used
const int PS_CFLAG       = 130;        //combo type flag that identifies pots (130 = Slash->Next (Item))
                                       //see std_constants.zh for other type flags

void Pot_Script(){
  int w; int h;
  int i; int n; 
  int timer = PS_SPEED * PS_AFRAMES;   //note that the max is 255 (~4 seconds)
  int x; int y; int aframe;
  int OffsetX = PS_WIDTH * 8 - 8;      //center the sprite according to height and width
  int OffsetY = PS_HEIGHT * 8 - 8;     //center the sprite according to height and width

  //initialize pots array, the first 8 bits store the position and the second 8 bits store the timer
  if(ScreenChanged){
    i = 0;
    for(n = 0; n < 176; n++)
      if(Screen->ComboT[n] == PS_CFLAG) Pots[i++] = n;
    nPots = i;
    return;
  }

  //scan for broken pots..
  for(n = 0; n < nPots; n++){ 
    if(Screen->ComboT[Pots[n] & 0xff] == PS_CFLAG) 
      continue;

    //we found one! if its timer isn't set, set it and play sound
    if((Pots[n] & 0xff00) == 0){
      Game->PlaySound(PS_SFX);
      Pots[n] |= (timer << 8);
    }


    //now figure out where we are in the animation cycle
    aframe = PS_ANIMATION + PS_WIDTH * Floor((timer - (Pots[n] >> 8)) / PS_SPEED);  

    //display tiles
    x = ComboX(Pots[n] & 0xff) - OffsetX;
    y = ComboY(Pots[n] & 0xff) - OffsetY;
    for(w = 0; w < PS_WIDTH; w++){
      for(h = 0; h < PS_HEIGHT; h++){
        Screen->FastTile(PS_LAYER, x + 16 * w, y + 16 * h, aframe + w + 20 * h, PS_CSET, 255);
      }
    }

    //subtract 1 from the timer and remove pot from the array when timer = 0
    Pots[n] -= 0x100;                                     
    if((Pots[n] & 0xff00) == 0) Pots[n] = Pots[--nPots];  
  }
}

global script Main_Loop{
  void run(){

    while(true){     
      Waitframe();
      ScreenChange_Update();
      Pot_Script();
    }
  }
}

//force ScreenChange to be ture if player dies or F6 continues (ScreenChanged = true; doesn't work)
//put this into the "onExit" slot
global script reset{
  void run(){
    LastDScreen = -1;
  }
}