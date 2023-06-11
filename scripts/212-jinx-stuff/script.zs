import "std.zh" // only need this once

// !!!!!! these will need setting based on your needs
const int JINX_CARRYOVER = 1;   // have temp jinxes carryover onto new screens:  0 = no, 1 = yes
const int JINX_COMBINE   = 1;   // while temp jinxed getting hit by another jinx will add to duration: 0 = no, 1 = yes


// !!!!!! this should be ignored, unless you want to expand this array for other purposes.
int LinkVars[] = {0,0};    // array so as to not use too many global variables
const int LV_SWORDJINX = 0;
const int LV_ITEMJINX  = 1;


// !!!!!! sample global script.
global script Slot2
{
 void run()
 {
  while(true)
  {
   JinxStuff();  // if using Carryover or Combine add this before Waitdraw();
   JinxCounter();  // if using the Counter add this before Waitdraw();
   Waitdraw();
   Waitframe();
  }
 }
}


void JinxStuff()
{
 if ( Link->Action == LA_SCROLLING ) return;

 if ( LinkVars[LV_SWORDJINX] == 0 )
 {
  if ( Link->SwordJinx > 0 ) LinkVars[LV_SWORDJINX] = Link->SwordJinx;
 }
 else
 {
  LinkVars[LV_SWORDJINX]--;
  if ( JINX_CARRYOVER == 1 && Link->SwordJinx == 0 )
  {
   if ( LinkVars[LV_SWORDJINX] > 0 ) Link->SwordJinx = LinkVars[LV_SWORDJINX];
  }
  else if ( JINX_COMBINE == 1 )
  {
   if ( Link->SwordJinx > LinkVars[LV_SWORDJINX] ) 
   {
    Link->SwordJinx += LinkVars[LV_SWORDJINX];
    LinkVars[LV_SWORDJINX] = Link->SwordJinx;
   }
  }
 } 

 if ( LinkVars[LV_ITEMJINX] == 0 )
 {
  if ( Link->ItemJinx > 0 ) LinkVars[LV_ITEMJINX] = Link->ItemJinx;
 }
 else
 {
  LinkVars[LV_ITEMJINX]--;
  if ( JINX_CARRYOVER == 1 && Link->ItemJinx == 0 )
  {
   if ( LinkVars[LV_ITEMJINX] > 0 ) Link->ItemJinx = LinkVars[LV_ITEMJINX];
  }
  else if ( JINX_COMBINE == 1 )
  {
   if ( Link->ItemJinx > LinkVars[LV_ITEMJINX] ) 
   {
    Link->ItemJinx += LinkVars[LV_ITEMJINX];
    LinkVars[LV_ITEMJINX] = Link->ItemJinx;
   }
  }
 } 
}


// !!!!!! these constants need to be set if using JinxCounter, otherwise ignore or delete the rest of script file
const int JINXCOUNTER_SWORD_X = 0;    // the x pos you want the Temp Sword Jinx Counter to display
const int JINXCOUNTER_SWORD_Y = 0;    // the y pos
const int JINXCOUNTER_ITEM_X = 0;     // the x pos of the Temp Item Jinx Counter
const int JINXCOUNTER_ITEM_Y = 16;     // the y pos
const int JINXCOUNTER_FONT = 0;       // the font you wish to use, values in std_constants.zh as FONT_
const int JINXCOUNTER_COLOR = 0;      // the color, values are 0-15 in each CSET + CSET#x16
const int JINXCOUNTER_BGCOLOR = -1;   // background color, -1 is transparent, or as above

void JinxCounter()
{
 if ( Link->SwordJinx > 0 )
 {
  int js_count = Ceiling(Link->SwordJinx * 0.0167);
  Screen->DrawInteger ( 7, JINXCOUNTER_SWORD_X, JINXCOUNTER_SWORD_Y, JINXCOUNTER_FONT, JINXCOUNTER_COLOR, JINXCOUNTER_BGCOLOR, 0, 0, js_count, 0, OP_OPAQUE);
 }
 
 if ( Link->ItemJinx > 0 )
 {
  int ji_count = Ceiling(Link->ItemJinx * 0.0167);
  Screen->DrawInteger ( 7, JINXCOUNTER_ITEM_X, JINXCOUNTER_ITEM_Y, JINXCOUNTER_FONT, JINXCOUNTER_COLOR, JINXCOUNTER_BGCOLOR, 0, 0, ji_count, 0, OP_OPAQUE);
 }
}