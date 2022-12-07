// [ITEM] PEGASUS BOOTS -------------------------------------------------------------------------------------------------------------------------------------------
// (original: Joe123, edits: Zepinho, justin ...................................................................................................................................

import "std.zh"     // only need this once


// -------------------------------------------------------------------------------
// SETUP
//
// 1. Add the necessary tiles to your quest file.  Dust animation. SFX. etc.
// 2. Set the following constants
// 3. Set the size of the Dust_Array in the Global variable section.  The formula is provided.
//    Leave the rest of the global variables alone.
// 4. Create your Pegasus Boot item, custom item class, attach the PegasusBoots item script to the active slot.
// 5. If you have no other global scripts, ignore this step.
//    If you do, Scroll down to bottom of this script and read instructions on how to add the necessary global functions to your script.
// 6. Make sure there are no functions / variables you're trying to include twice.  
//    constant BIG_LINK come to mind.  Marked with !!!!!!!!!!!!!!!


// Optional setup stuff
// Jump related - Roc Items, and otherwise
// 1. If not using can select both A and B button items, OR if not using Roc's feather you should set I_ROCSFEATHER_INCREASER to 0.
// 2. If using Roc's Feather item setup a second Roc Feather item, and can select A/B items.
//    Roc item class. Equipment item. Height multiplier = a number greater than your Roc feather height. 2 works well if standard Roc Feather HM = 1.
//    Give it the same sprite and SFX as Roc Feather.  or can make them different if you'd like.
//    Make note of the item# of the Increaser item, so you can set the constant below.
//    The PegasusBoots script gives and takes the Increaser item automatically, so don't give it in your quest.
//    If already using multiple levels of Roc Item, or if your Roc Feather is NOT the default item number (91), you'll need to modify the script.
// 3. If you're just keying jumping to another button L/R/EX1/etc, the Roc Increaser won't function.  You'll need to modify the script.
//
// Swords - extra swords, and non default sword item#s
// 1. More swords can be added by adding new constants with their item numbers, and sprites.  
//    And adding more to the if statement that uses the I_SWORD constants in the PegasusDash function.
// 2. The script currently uses the default item numbers for swords.  If you change those, you'll have to replace the corresponding I_SWORD constant.
// 3. Dash sword will draw an animated sword if the sprite is animated. EXCEPT when scrolling.
//
// Dash Slash related - cutting tall grass, bushes, etc while dashing
// 1. By default things combo types - Grass, Flowers, Bush, and next versions are set to use the sprites you define.  And their default item drop set. (IS_COMBOS = 12)
// 2. Slash combo types don't have a default sprite, and use the default item sets (IS_COMBOS = 12).  Slash->Item which uses its default item set (IS_MAGICLIFE = 10).
// 3. Continous combo types accounted for at all.
// 4. The SFX is the same for all of them.
// 5. If you want to change any of this, find the function DoDashSlash.  Easy to find with a row of !!!!!!!!!! above.
//    Edit to your liking.
// 6. If using any of the Slash combo type with solid combo, you'll have a bug where you can't initiate a dashslash while standing beside it.
//    You can edit the function CanDashSlash to fix it.  It is marked by a row of !!!!!!!!!!!!!!!!!
//
// Dust drawing related
// 1. If using the "No screen scrolling" quest rule.  You can switch to the old dust drawing code if you wish, and clear up some variables and functions.
//    Uncomment DustDrawLW, and remove DustDrawTile.  The ScrollFix function can be removed, with its associated global variables.
//    Dust_Array, the DustDrawTile function, the dashSword while scrolling code, and the dashSword variables can all be safely removed in this case.


                                                // !!!!!!! this is also used by other scripts, only needs to be included in script file once
const int BIG_LINK                  = 0;   	// Set this constant to 1 if using the Large Link Hit Box feature.

// Pegasus Boots Constants
const int CF_DASH                   = 100;      // CF_Script3, ComboFlag that Link can't dash through if walkable, and will break if solid
                                                // Could be reused for situations where dash is impossible.

const int INV_COMBO_ID 		    = 14;	// Solid DashCombos will break into this

const int DashSFXLength        	    = 9;        // Time between repeating Dash SFX
const int SFX_DASH            	    = 64;       // Dashing SFX
const int SFX_HITWALL        	    = 137;      // Hitting a wall
const int SFX_PEGASUSBREAK    	    = 66;       // SFX to play when breaking a Pegasus Boot block

const int T_DUST            	    = 27420;    // Dust Kick-up tile
const int DustAFrames        	    = 2;        // Dust Kick-up animation frames
const int DustASpeed        	    = 4;        // Dust Kick-up animation speed
const int DustCSet            	    = 2;        // Dust Kick-up CSet

const int I_ROCSFEATHER_INCREASER   = 124; 	// Roc's feather upgrade, to automatically give to Link when using Pegasus Boots

const int DASH_SWORD_DMG            = 8;        // Dash sword deals this regardless of sword damage.
const int DASH_SWORD_MULT           = 0;        // Dash sword deals equipped sword damage times this.  0 uses above value. >0 uses this.
const int SPRITE_SWORD1 	    = 0;        // Set these to the sprite number used by that sword level
const int SPRITE_SWORD2 	    = 1;
const int SPRITE_SWORD3 	    = 2;
const int SPRITE_SWORD4 	    = 3;

const int NPC_ITEMSET               = 177;     	// ID of a dummy enemy with type different from "none", hp0, itemset overridden by script


const int SPRITE_BUSH_CUT           = 52;       // set these to whatever sprites they should correspond to     
const int SPRITE_FLOWER_CUT         = 53;       // sprites with 0 for either NumFrames or AniSpeed will not show.
const int SPRITE_GRASS_CUT          = 54;

const int CanDrown                  = 1;        // 0 makes Link stop beside water combos regardless of quest rule, and their walkability
                                                // Set 0 if not using drownable water, or if you don't want Link to dash into water.
                                                // Set 1 if using drownable water, and want Link to dash in and either drown or swim.

//END Pegasus Boots constants


// -------------------------------------------------------------------------------
// Global Variables

// to draw while Scrolling
int scrollDir;
int scrollCounter;
int drawX;
int drawY;

//Pegasus Boots Global variables
int PegasusDash = -1;
bool PegasusCollision;
int DashCounter;
int StoreInput;
int StoreHP;

int dashSwordTile = 0; // for drawing dashsword while scrolling, script sets these.
int dashSwordCSet = 0; 

                              //!!!!!!!!!!!!! this array size needs to be set, the number inside the []
int Dust_Array[2];            // Array size should be max number of dust animations active at one time
                              // Formula is ( (DustAFrames*DustASpeed) / 4 )

//END Pegasus Boots global variables



// -------------------------------------------------------------------------------
// Pegasus Boots functions

item script PegasusBoots{
   void run(){

      if(ComboFI(Link->X+8,Link->Y + Cond(BIG_LINK==0, 12, 8),CF_DASH)) Quit();  // can't dash on non-solid dash combos

      if(CanDrown == 0 && IsWater(TouchedComboLoc()) ) Quit();  // stop beside non-drownable water
                
      if(Link->Action == LA_SWIMMING || Link->Action == LA_DROWNING) Quit();  // can't use dash when in water

      if(IsJumping()) Quit();  // can't initiate dash while jumping

      // Link won't dash if facing up or down in sideview 
      if(IsSideview()){
         if(Link->Dir == DIR_UP || Link->Dir == DIR_DOWN) Quit();
      }

      PegasusDash = Link->Dir;

      if(Link->InputB && !Link->InputA) StoreInput = 2;
      else if(Link->InputA && !Link->InputB) StoreInput = 1;
   }
}


// Stops dashing, no collision.  Easy for other scripts to call.
void StopDash(){
   PegasusDash = -1;
   DashCounter = 0;
}


// takes care of all the PegasusBoots functions
// call it in your global while loop, above the waitdraw and waitframe.
void PegasusBoots(){
    lweapon mysword;

    int loc = ComboAt(Link->X+8,Link->Y + Cond(BIG_LINK==0, 12, 8));

    // this fixes the bug that makes Link dive immediately after dashing into water with flippers
    if(DashCounter < 0){
        DashCounter++;

        if(Link->Action == LA_SWIMMING){
            Link->InputA = false;
        }else if(Link->Action == LA_DIVING){
            Link->Action == LA_SWIMMING;
            Link->InputA = false;
	}else{
            DashCounter = 0;
        }
    }

    // fixs a bug with drownable water and diagonal movement off
    if(CanDrown == 1 && IsWater(loc) 
       && Link->Action != LA_SWIMMING && Link->Action != LA_DROWNING && Link->Action != LA_DIVING){

        if(Link->Dir == DIR_UP) Link->InputUp = true;
        else if(Link->Dir == DIR_DOWN) Link->InputDown = true;
        else if(Link->Dir == DIR_LEFT) Link->InputLeft = true;
        else if(Link->Dir == DIR_RIGHT) Link->InputRight = true;
    }


    if(PegasusDash >= 0){
        if(!PegasusCollision){
            if( (Link->Action != LA_SCROLLING && ((StoreInput == 1 && !Link->InputA) || (StoreInput == 2 && !Link->InputB)))
                || StoreHP > Link->HP || Link->Action == LA_RAFTING
                || Link->Action == LA_DROWNING || Link->Action == LA_SWIMMING || Link->Action == LA_DIVING
                || (CanDrown == 0 && IsWater(TouchedComboLoc())) || (CanDrown == 1 && IsWater(loc)) ){

                    StopDash();

                    if(Link->Action == LA_SWIMMING) DashCounter = -20;
            }

            if(!UsingItem(I_ROCSFEATHER_INCREASER))
               NoAction();

            if(Link->Item[I_ROCSFEATHER] && !Link->Item[I_ROCSFEATHER_INCREASER]){
               Link->Item[I_ROCSFEATHER_INCREASER]=true;
            }

            // Link runs on spot for 10 frames before dash happens
            if(Link->Action != LA_SCROLLING && DashCounter > 10){
                if(PegasusDash == DIR_UP && DashCheck(Link->X+8,Link->Y+6,true) != 2){
                    Link->Y--;
                    drawY--;
                    Link->InputUp = true;
                }
                else if(PegasusDash == DIR_DOWN && DashCheck(Link->X+8,Link->Y+17,true) != 2){
                    Link->Y++;
                    drawY++;
                    Link->InputDown = true;
                }
                else if(PegasusDash == DIR_LEFT && DashCheck(Link->X,Link->Y+12,false) != 2){
                    Link->X--;
                    drawX--;
                    Link->InputLeft = true;
                }
                else if(PegasusDash == DIR_RIGHT && DashCheck(Link->X+16,Link->Y+12,false) != 2){
                    Link->X++;
                    drawX++;
                    Link->InputRight = true;
                }
                else{
                    PegasusCollision = true;
                    DashCounter = 0;
                }
            }//end DashCounter if

            // do stuff if not jumping
            if( !IsJumping() ){

               // handles breaking of solid Pegasus combos
               if(ComboFI(loc,CF_DASH) && Screen->ComboS[loc] == 1111b){
                   Screen->ComboD[loc]=INV_COMBO_ID;
                   if(Screen->ComboF[loc] == CF_DASH) Screen->ComboF[loc] = 0;
                   Game->PlaySound(SFX_PEGASUSBREAK);
               }

               DustDrawTile();  // use new dust draw code that works while scrolling
               // DustDrawLW(); // use old dust draw code that doesn't work while scrolling (quest rule "no screen scrolling" on)

               if(DashCounter%DashSFXLength == 0) Game->PlaySound(SFX_DASH);
            } 

            // draws dashSword when scrolling
            if(Link->Action == LA_SCROLLING && dashSwordTile > 0){

                 if(PegasusDash == DIR_UP)
                    Screen->DrawTile(0,drawX+InFrontX(DIR_UP,6),drawY+InFrontY(DIR_UP,6),
                                     dashSwordTile,1,1,dashSwordCSet,-1,-1,0,0,0,0,true,128);
                 else if(PegasusDash == DIR_DOWN)
                    Screen->DrawTile(0,drawX+InFrontX(DIR_DOWN,6),drawY+InFrontY(DIR_DOWN,6),
                                     dashSwordTile,1,1,dashSwordCSet,-1,-1,0,0,0,3,true,128);
                 else if(PegasusDash == DIR_LEFT)
                    Screen->DrawTile(0,drawX+InFrontX(DIR_LEFT,6),drawY+InFrontY(DIR_LEFT,6)+3,
                                     dashSwordTile,1,1,dashSwordCSet,-1,-1,0,0,0,1,true,128);
                 else if(PegasusDash == DIR_RIGHT)
                    Screen->DrawTile(0,drawX+InFrontX(DIR_RIGHT,6),drawY+InFrontY(DIR_RIGHT,6)+3,
                                     dashSwordTile,1,1,dashSwordCSet,-1,-1,0,0,0,0,true,128);
            }

            int swordEquip = LinkSwordEquip();

            if(swordEquip > -1 && DashCounter>10){
                // draws dashSword when not scrolling

                mysword = LoadLWeaponOf(LW_SCRIPT3);
                if(!mysword->isValid()) mysword = Screen->CreateLWeapon(LW_SCRIPT3);

                if(swordEquip==I_SWORD4){
                   mysword->UseSprite(SPRITE_SWORD4);
                }else if(swordEquip==I_SWORD3){
                   mysword->UseSprite(SPRITE_SWORD3);
                }else if(swordEquip==I_SWORD2){
                   mysword->UseSprite(SPRITE_SWORD2);
                }else{
                   mysword->UseSprite(SPRITE_SWORD1);
                }//end sprite if

                if(DASH_SWORD_MULT > 0){
                   itemdata itm = Game->LoadItemData(swordEquip);
                   mysword->Damage = itm->Power * DASH_SWORD_MULT;
                }
                else mysword->Damage = DASH_SWORD_DMG;

                mysword->X = Link->X+InFrontX(PegasusDash, 6);
                mysword->Y = Link->Y+InFrontY(PegasusDash, 6);

                mysword->Dir = PegasusDash;
                if(mysword->Dir < 2){ //dir is up or down
                   if(mysword->Dir == DIR_DOWN) mysword->Flip = 3;
                }
                else{ //dir is left or right
                   mysword->OriginalTile += 1;
                   mysword->Tile = mysword->OriginalTile;
                   if(mysword->Dir == DIR_LEFT) mysword->Flip = 1;
                   mysword->Y += 3;
                }//end dir if
 
                // save our sword sprite for when scrolling
                dashSwordTile = mysword->Tile;
                dashSwordCSet = mysword->OriginalCSet;

                // slash stuff while dashing with sword
                DoDashSlash(ComboAt(TouchedX()+InFrontX(mysword->Dir,4),TouchedY()+InFrontY(mysword->Dir,4)));
            }
            else{ // we don't have dashSword

                mysword = LoadLWeaponOf(LW_SCRIPT3);
                Remove(mysword);

                dashSwordTile = 0;
                dashSwordCSet = 0;
            }//end mysword if

        }//end !PegasusCollision if

        else{ //is PegasusCollision, DashCounter has been reset to 0.
            NoAction();

            // knockback code
            if(PegasusDash == DIR_UP && DashCheck(Link->X+8,Link->Y+18,true) == 0) Link->Y++;
            else if(PegasusDash == DIR_DOWN && DashCheck(Link->X+8,Link->Y+6,true) == 0) Link->Y--;
            else if(PegasusDash == DIR_LEFT && DashCheck(Link->X+18,Link->Y+8,false) == 0) Link->X++;
            else if(PegasusDash == DIR_RIGHT && DashCheck(Link->X-2,Link->Y+8,false) == 0) Link->X--;

            if(DashCounter == 1){
                 Screen->ClearSprites(SL_LWPNS);
                 Game->PlaySound(SFX_HITWALL);
                 Screen->Quake = 10;
            }
            else if(DashCounter == 10){
                 StopDash();
                 PegasusCollision = false;
            }

            if(DashCounter < 5) Link->Z++;
        }// end PegasusCollision if/else
        
        DashCounter++; 
     }// end PegasusDash if

    else{ // !PegasusDash
        mysword = LoadLWeaponOf(LW_SCRIPT3);
        Remove(mysword);

        dashSwordTile = 0;
        dashSwordCSet = 0;

        if(Link->Item[I_ROCSFEATHER_INCREASER]) Link->Item[I_ROCSFEATHER_INCREASER]=false;
    }//end PegasusDash if/else

    StoreHP = Link->HP;
}//end function


// next two functions draw dust when dashing.  first one allows drawing during scrolling. the second is the old code, and currently unused.
void DustDrawTile(){
   if(PegasusDash < 0) return;

   int dX;
   int dY;

   if(DashCounter%4 == 0){
      for(int i = 0; i < SizeOfArray(Dust_Array); i++){
         if(Dust_Array[i] == 0){
            Dust_Array[i] = 1;
            break;   
         }
      }
   }

   for(int i = 0; i < SizeOfArray(Dust_Array); i++){
      if(Dust_Array[i]==0) continue;

      if(PegasusDash == DIR_UP){                        
         dX = drawX;
         if(Dust_Array[i] < 4) dY = drawY+8;
         else dY = drawY+8+3+(Dust_Array[i]-1);

      }else if(PegasusDash == DIR_DOWN){
         dX = drawX;

         if(Dust_Array[i] < 4) dY = drawY;
         else dY = drawY-3-(Dust_Array[i]-1);

      }else if(PegasusDash == DIR_LEFT){

         if(Dust_Array[i] < 4) dX = drawX;
         else dX = drawX+3+(Dust_Array[i]-1);

         dY = drawY+8;

      }else if(PegasusDash == DIR_RIGHT){

         if(Dust_Array[i] < 4) dX = drawX;
         else dX = drawX-3-(Dust_Array[i]-1);

         dY = drawY+8;
      }

      Screen->FastTile(0, dX, dY, T_DUST+ Floor(Dust_Array[i]/DustASpeed), DustCSet, 128);

      if(Dust_Array[i] == DustAFrames*DustASpeed) Dust_Array[i] = 0;
      else Dust_Array[i]++;
   }
}

void DustDrawLW(){
   if(PegasusDash < 0) return;

   lweapon Dust;
   if(DashCounter%4 == 0){
      for(int j=1;j<=Screen->NumLWeapons();j++){
         Dust = Screen->LoadLWeapon(j);
         if(Dust->ID != LW_SCRIPT10) continue;
         if(PegasusDash < 1) Dust->Y-=3;
         else if(PegasusDash < 2) Dust->Y+=3;
         else if(PegasusDash < 3) Dust->X-=3;
         else if(PegasusDash < 4) Dust->X+=3;
      }//end for loop

      Dust = Screen->CreateLWeapon(LW_SCRIPT10);
      Dust->OriginalTile = T_DUST;
      Dust->CSet = DustCSet;
      Dust->Y = Link->Y+8;
      Dust->X = Link->X;
      Dust->NumFrames = DustAFrames;
      Dust->ASpeed = DustASpeed;
      Dust->DeadState = DustAFrames*DustASpeed;
   }//end dust if
}


// Check whether Link can dash onto a combo
int DashCheck(int x, int y, bool xy){
    int xoffset; int yoffset;
    bool Solid;
    
    if(xy) xoffset = 4;
    else yoffset = 3;

    if(Screen->isSolid(x-xoffset,y-yoffset) || Screen->isSolid(x+xoffset,y+yoffset)) Solid = true;

    if(Solid && CanDashSlash(x,y) ) Solid = false;

    //Not solid and not a Dash combo return 0
    if(!Solid && !ComboFI(x-xoffset,y-yoffset,CF_DASH) && !ComboFI(x+xoffset,y+yoffset,CF_DASH)) return 0;
    
    //Is solid and is a Dash combo return 1
    else if(Solid && (ComboFI(x-xoffset,y-yoffset,CF_DASH) || ComboFI(x+xoffset,y+yoffset,CF_DASH))) return 1;
    
    //Is either solid without a Dash combo, or not solid with a Dash combo
    else return 2;
}


//fixes a bug where you can't initiate a dash next to a slashable solid combo
bool CanDashSlash(int x, int y){
    if(LinkSwordEquip() == -1) return false;

    int loc;
    loc = ComboAt(x, y);

    // !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
    // can add more combo types here by adding     || Screen->ComboT[loc] == CT_ 
    // CT_ types you might consider CT_SLASH, CT_SLASHNEXT, CT_SLASHNEXTITEM if those are solid in your quest

    if(Screen->ComboT[loc] == CT_BUSH || Screen->ComboT[loc] == CT_BUSHNEXT ) 
         return true;

    return false;
}

// !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
// replaces the code in old Pegasus boots function for dash cutting through slashable combos.
// allows easier customization to suit your needs.

void DoDashSlash(int loc){
   int ctype = Screen->ComboT[loc];
   int sprite;
   int itmset = IS_COMBOS; // item set 12 (tall grass by default)
   
   bool playsound = false;
   
   // add sprites to certain types
   if(ctype == CT_BUSH || ctype == CT_BUSHNEXT) sprite = SPRITE_BUSH_CUT;
   else if(ctype == CT_TALLGRASS || ctype == CT_TALLGRASSNEXT) sprite = SPRITE_GRASS_CUT;
   else if(ctype == CT_FLOWERS) sprite = SPRITE_FLOWER_CUT;

   // no sprite is typically associated with Slash type combos, but it could be added.

   // itemset is changed here to the default for these types.  could add more item sets based on type
   if(ctype == CT_SLASHITEM || ctype == CT_SLASHNEXTITEM) itmset = 10; // default for these combo types

   //these types default to undercombo
   if(ctype == CT_BUSH || ctype == CT_TALLGRASS || ctype == CT_FLOWERS || ctype == CT_SLASH || ctype == CT_SLASHITEM){
      Screen->ComboD[loc] = Screen->UnderCombo;
      playsound = true;
   }

   //these types default to next combo
   if(ctype == CT_BUSHNEXT || ctype == CT_TALLGRASSNEXT || ctype == CT_FLOWERS || ctype == CT_SLASHNEXT || ctype == CT_SLASHNEXTITEM){
      Screen->ComboD[loc] += 1;
      playsound = true;
   }

   //no functionality added for Continuous type combos.

   if(playsound){
      CreateGraphicAt(sprite,ComboX(loc),ComboY(loc));

      Game->PlaySound(SFX_GRASSCUT); // could have different sounds for different types too by modifyng above.
      ItemSetAt(itmset,loc);
   }//end playsound if
}

// END Pegasus Boots functions



// .............................................................................................................................................................................
// Utility Functions used by Pegasus Boots and other scripts that might be useful for other things .......................................................................................


//returns the item# of an equipped sword.  checks and returns A button first, then B button.  returns -1 if no sword equipped.
int LinkSwordEquip(){
    itemdata itm = Game->LoadItemData( GetEquipmentA() );

    if(itm->Family==IC_SWORD) return GetEquipmentA();

    itm = Game->LoadItemData(GetEquipmentB());

    if(itm->Family==IC_SWORD) return GetEquipmentB();

    return -1;
}

// the combo that link is touching in the direction he's facing
int TouchedComboLoc(){
    int loc;
    loc = ComboAt( TouchedX(), TouchedY() );
    return loc;
}

// the x coord that link is touching in the direction he's facing
int TouchedX(){
    int x = 0;
    if(Link->Dir == DIR_UP || Link->Dir == DIR_DOWN) x = Link->X+8; 
    else if(Link->Dir == DIR_LEFT)  x = Link->X-1;
    else if(Link->Dir == DIR_RIGHT) x = Link->X+17;
    return x;
}

// the y coord that link is touching in the direction he's facing
int TouchedY(){
    int y = 0;
    if(Link->Dir == DIR_UP)         y = Link->Y+7;
    else if(Link->Dir == DIR_DOWN)  y = Link->Y+17;
    else if(Link->Dir == DIR_LEFT || Link->Dir == DIR_RIGHT)  y = Link->Y+8;
    return y;
}

// draws a sprite as a non-damaging eweapon
int CreateGraphicAt(int sprite, int x, int y){
    eweapon e = Screen->CreateEWeapon(EW_SCRIPT1);
    e->HitXOffset = 500;
    e->UseSprite(sprite);
    e->DeadState = Max(1,e->NumFrames*e->ASpeed);
    e->X = x;
    e->Y = y;
    return e->DeadState;
}

//creates and kills an enemy of type NPC_ITEMSET to fake an itemdropset.
void ItemSetAt(int itemset,int loc){
    npc e = Screen->CreateNPC(NPC_ITEMSET);
    e->ItemSet = itemset;
        if(e->isValid()){
        e->X = loc%16*16;
        e->Y = loc-loc%16;
        }
    e->HP = HP_SILENT;
}


// utility function returns true if Link is jumping, necessary because SideView gravity sucks
// might need tweaking depending on other SideView scripts you use.

bool IsJumping(){
  if(IsSideview()){
     if(Link->Action == LA_SWIMMING || Link->Action == LA_DIVING || Link->Action == LA_DROWNING) return false;
     if(Link->Jump != 0) return true;
     if(!OnSidePlatform(Link->X,Link->Y)) return true;
  }
  else{
     if(Link->Z > 0) return true;
  }

  return false;
}


// Allows drawing tiles to correct position on Link when scrolling
// Sets drawX/drawY either to Link X/Y when not scrolling, or the visual position when scrolling.
// currently only used by Pegasus Boots (which is also setting drawX/drawY to Link's new x/y as he dashes)

void ScrollFix(){
   //function by Saffith

   if(Link->Action==LA_SCROLLING){
       if(scrollDir==-1)
       {
           if(Link->Y>160)
           {
               scrollDir=DIR_UP;
               scrollCounter=45;
           }
           else if(Link->Y<0)
           {
               scrollDir=DIR_DOWN;
               scrollCounter=45;
           }
           else if(Link->X>240)
           {
               scrollDir=DIR_LEFT;
               scrollCounter=65;
           }
           else
           {
               scrollDir=DIR_RIGHT;
               scrollCounter=65;
           }
       }
    
       if(scrollDir==DIR_UP && scrollCounter<45 && scrollCounter>4)
           drawY+=4;
       else if(scrollDir==DIR_DOWN && scrollCounter<45 && scrollCounter>4)
           drawY-=4;
       else if(scrollDir==DIR_LEFT && scrollCounter<65 && scrollCounter>4)
           drawX+=4;
       else if(scrollDir==DIR_RIGHT && scrollCounter<65 && scrollCounter>4)
           drawX-=4;
    
       scrollCounter--;
   }
   else
   {
       drawX=Link->X;
       drawY=Link->Y;
       if(scrollDir!=-1)
           scrollDir=-1;
   }
}

//END Utility functions
// .............................................................................................................................................................................



// .............................................................................................................................................................................
// Sample global script using Pegasus Boots.
// If you aren't using any other global scripts, you can just import this as is.

//** If you have an existing global script, just add ScrollFix(); the top of the while loop
//** and PegasusBoots(); below that, but before the Waitdraw(); and Waitframe();
//** And remove, or comment this global script out.

global script Slot_2{
   void run(){
      while(true){

         ScrollFix();   // keep at top of while loop

         PegasusBoots();  // before waitdraw


         Waitdraw();
		
         Waitframe();

      }//end whileloop
   }//end run
}//end global slot2