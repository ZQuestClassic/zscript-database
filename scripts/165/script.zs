import "std.zh"         // only need this once
import "ffcscript.zh"   // only need this once

///////////////////////////////////////////////////////////////////////////////////////////////////
// Bait weapons
// 
// Setup:
// 1.  Set the following constants.
// 1a. Potentially remove the common isSolid function at the bottom of the script, if you already have it in your script file.
// 2.  Import the script file.  
// 3.  Slot all the item scripts you are using, and all the corresponding ffc scripts.
//     If using a regular bait item in your quest as well, you do also need the I_ACT_BaitNormal to prevent a bug where the other baits will just modify an already placed normal bait.
//     ie. if using only the poison bait and normal bait in your quest, you will need to slot the I_ACT_BaitPoison, FFC_BaitPoison, and the I_ACT_BaitNormal.
// 
// 4.  Setup your new bait items to your liking.  Attach the I_ACT scripts to your bait items.  Set the script arguments to your liking.
//     Under Quest->Graphics->Sprites->Weapons/Misc, create new bait sprites for when they are placed, and set that as the Bait sprite on the item action tab.
//     Remember the normal bait needs the BaitNormal attached as well.
//     For the baitchu item.  The sprite is intended to be directional, and can be animated.  Set up your tiles - up, down, left, right.  Select the first up tile in the sprite editor.
//
// 5.  You don't need to place the ffcs on the screen, they are created by the item scripts.
//


// Bait - Poison arguments (I_ACT_BaitPoison)
//
// D0 = poison damage - HP amount it deals to affected enemy every D1 frames
// D1 = poison rate - how often the D0 damage is dealt to affected enemy
// D2 = poison duration - number of times the D0 damage will be inflicted.
// D3 = hunger threshold - only affects enemies with a hunger number >= this.  Range from 0 - 4.


// Bait - Sleep arguments (I_ACT_BaitSleep)

// D0 = sleep delay - number of frames before the enemy is affected by the sleep
// D2 = sleep duration - number of frames the enemy will be asleep
// D3 = hunger threshold - only affects enemies with a hunger number >= this.  Range from 0 - 4.


// Bait - Mine arguments (I_ACT_BaitMine)
//
// D0 = explosion damage - HP amount the bait mine does when it explodes
// D1 = explosion delay - how many frames after being triggered it takes for the explosion to happen
// D2 = hunger threshold - only triggered by enemies with a hunger number >= this.  Range from 0 - 4.
// D3 = number of enemies to trigger - number of enemies required to activate the mine.  leaving at 0 is the same as 1 enemy.
// D4 = display countdown to explosion text.  only displays is countdown>0 and delay>0.  the countdown is displayed as D1/D4 rounded down.


// Baitchu arguments (I_ACT_Baitchu)
//
// D0 = speed - baitchu will travel away from Link in the direction he was facing when he placed it at this speed.  number of pixels per frame. decimal accepted.


// Constants to set

const int COMBO_POISON            = 900;  // combo# of the graphic to display over poisoned enemy.  leave at 0 if not using.  can be animated.
const int COMBO_POISON_CSET       = 8;    // cset# of above combo
const int COMBO_POISON_YOFFSET    = 0;    // yoffset.  to change the position of the poison graphic.  negative numbers will be above the enemy.

const int COMBO_SLEEP             = 0;    // as above, for enemies affected by bait sleep
const int COMBO_SLEEP_CSET        = 0;
const int COMBO_SLEEP_YOFFSET     = 0;

// if using bait->mine delay, can show a countdown over the activated bait.
const int MINECOUNTDOWN_FONT      = 0;    // FONT_Z1, other font values found in std_contants.zh
const int MINECOUNTDOWN_FONTCOLOR = 0x01; // white in classic set
const int MINECOUNTDOWN_FONTBG    = 0x00; // black in classic set, set to -1 for transparent
const int MINECOUNTDOWN_YOFFSET   = -8;   // yoffset for countdown over bait sprite, negative numbers will be above bait

// index to npc->Misc arrays, use value that are unused by other scripts.  if using both poison and sleep baits, these do have to be different values.
const int E_MISC_POISON    = 0;   
const int E_MISC_SLEEP     = 1;

const int LW_MISC_BAITTYPE = 0;  // index to lweapon->Misc[] array.  use a value unused by other scripts for the LW_BAIT type. the scripts need to track baits on screen to prevent bugs.


// Item scripts

item script I_ACT_BaitPoison
{
   void run(int damage, int rate, int duration, int hunger)
   {
      if( NumLWeaponsOf(LW_BAIT) != 1) Quit();
      lweapon bait = LoadLWeaponOf(LW_BAIT);
      if(bait->Misc[LW_MISC_BAITTYPE] == BT_UNMARKED) bait->Misc[LW_MISC_BAITTYPE] = BT_POISON;
      else Quit();
      
      int ffcScriptName[] = "FFC_BaitPoison";
      int ffcScriptNum = Game->GetFFCScript(ffcScriptName);
      int args[] = {damage, rate, duration, hunger};
      RunFFCScript(ffcScriptNum, args);
   }
}

item script I_ACT_BaitSleep
{
   void run(int delay, int duration, int hunger)
   {
      if( NumLWeaponsOf(LW_BAIT) != 1) Quit();
      lweapon bait = LoadLWeaponOf(LW_BAIT);
      if(bait->Misc[LW_MISC_BAITTYPE] == BT_UNMARKED) bait->Misc[LW_MISC_BAITTYPE] = BT_SLEEP;
      else Quit();

      int ffcScriptName[] = "FFC_BaitSleep";
      int ffcScriptNum = Game->GetFFCScript(ffcScriptName);
      int args[] = {delay, duration, hunger};
      RunFFCScript(ffcScriptNum, args);
   }
}

item script I_ACT_BaitMine
{
   void run(int damage, int delay, int hunger, int numenemies, int countdown)
   {
      if( NumLWeaponsOf(LW_BAIT) != 1) Quit();
      lweapon bait = LoadLWeaponOf(LW_BAIT);
      if(bait->Misc[LW_MISC_BAITTYPE] == BT_UNMARKED) bait->Misc[LW_MISC_BAITTYPE] = BT_MINE;
      else Quit();

      int ffcScriptName[] = "FFC_BaitMine";
      int ffcScriptNum = Game->GetFFCScript(ffcScriptName);
      int args[] = {damage, delay, hunger, numenemies, countdown};
      RunFFCScript(ffcScriptNum, args);
   }
}

item script I_ACT_Baitchu
{
   void run(int speed)
   {
      if( NumLWeaponsOf(LW_BAIT) != 1) Quit();
      lweapon bait = LoadLWeaponOf(LW_BAIT);
      if(bait->Misc[LW_MISC_BAITTYPE] == BT_UNMARKED) bait->Misc[LW_MISC_BAITTYPE] = BT_BCHU;
      else Quit();

      int ffcScriptName[] = "FFC_Baitchu";
      int ffcScriptNum = Game->GetFFCScript(ffcScriptName);
      int args[] = {speed};
      RunFFCScript(ffcScriptNum, args);
   }
}

item script I_ACT_BaitNormal
{
   void run()
   {
      if( NumLWeaponsOf(LW_BAIT) != 1) Quit();
      lweapon bait = LoadLWeaponOf(LW_BAIT);
      if(bait->Misc[LW_MISC_BAITTYPE] == BT_UNMARKED) bait->Misc[LW_MISC_BAITTYPE] = BT_NORMAL;
   }
}


// FFC scripts, called by the item scripts.

ffc script FFC_BaitPoison
{
   void run(int damage, int rate, int duration, int hunger)
   {
       bool poison;
       int counter = 0; 
       lweapon bait;
       npc e; 

       while(true)
       {
           bait = LoadLWeaponOf(LW_BAIT);
           if (!bait->isValid() && !poison) Quit();
           poison = false;

           for (int i = Screen->NumNPCs(); i > 0; i--) 
           {
              e = Screen->LoadNPC(i);

              if (e->Hunger < hunger) continue;

              if(bait->isValid())
              {
                 if (Collision(e,bait))
                 {
                    e->Misc[E_MISC_POISON] = duration;
                    e->Hunger = 0;
                 }
              }

              if (e->Misc[E_MISC_POISON] > 0)
              {
                 poison = true;
                 if(COMBO_POISON > 0) Screen->FastCombo(6,e->X,e->Y+COMBO_POISON_YOFFSET,COMBO_POISON,COMBO_POISON_CSET,OP_OPAQUE);

                 if(counter == 0)
                 {
                    e->Misc[E_MISC_POISON]--;                 
                    e->HP -= damage;
                 }
              }
           }                   

           counter = (counter +1) % rate;
           Waitframe();
       }
   }
}
 

ffc script FFC_BaitSleep
{
   void run(int delay, int duration, int hunger)
   {
       bool sleep;
       lweapon bait;
       npc e; 

       while(true)
       {
           bait = LoadLWeaponOf(LW_BAIT);
           if (!bait->isValid() && !sleep) Quit();
           sleep = false;

           for (int i = Screen->NumNPCs(); i > 0; i--) 
           {
              e = Screen->LoadNPC(i);

              if (e->Hunger < hunger) continue;

              if(e->Misc[E_MISC_SLEEP] == -1)
              {
                 if(e->Stun > 0)
                 {
                    Screen->FastCombo(6,e->X,e->Y+COMBO_SLEEP_YOFFSET,COMBO_SLEEP,COMBO_SLEEP_CSET,OP_OPAQUE);
                    sleep = true;
                    continue;
                 }
                 else e->Misc[E_MISC_SLEEP] = 0;
              }

              if (e->Misc[E_MISC_SLEEP] > 0)
              {
                 e->Misc[E_MISC_SLEEP]--;
                 if (e->Misc[E_MISC_SLEEP] == 0)
                 {
                    e->Stun = duration;
                    if(COMBO_SLEEP > 0) e->Misc[E_MISC_SLEEP] = -1;
                 }
                 sleep = true;
                 continue;
              }

              if (Collision(e,bait) && e->Stun == 0)
              {
                 if(delay == 0) e->Stun = duration;
                 else
                 {
                    e->Misc[E_MISC_SLEEP] = Max(1,delay);
                    sleep = true;
                 }
              }
           }                   
 
           Waitframe();
       }
   }
}


ffc script FFC_BaitMine
{
   void run(int damage, int delay, int hunger, int numenemies, int countdown)
   {
       lweapon bait;
       npc e; 
       int delaycount = -1;
       int ecount;

       while(true)
       {
           bait = LoadLWeaponOf(LW_BAIT);
           if (!bait->isValid()) Quit();

           ecount = 0;
           for (int i = Screen->NumNPCs(); i > 0; i--) 
           {
              if (delaycount >= 0) break;
              e = Screen->LoadNPC(i);

              if (e->Hunger < hunger) continue;
              if (Collision(e,bait))
              {
                 if (numenemies > 0) ecount++;
                 if (numenemies == ecount)
                 {
                    delaycount = delay;
                    break;
                 }
              }
           }

           if (delaycount>0)
           {
              delaycount--;
              if(countdown>0) Screen->DrawInteger(6, bait->X, bait->Y+MINECOUNTDOWN_YOFFSET, 
                                                  MINECOUNTDOWN_FONT, MINECOUNTDOWN_FONTCOLOR, MINECOUNTDOWN_FONTBG, 0, 0, Floor(delaycount/countdown), 0, OP_OPAQUE);
           }
           else if (delaycount == 0)
           {
              lweapon blast = CreateLWeaponAt(LW_BOMBBLAST,bait->X,bait->Y);
              blast->Damage = damage;
              bait->DeadState = WDS_DEAD;
              Quit();
           }

           Waitframe();
       }
   }
}


ffc script FFC_Baitchu
{
   void run(int speed)
   {
      lweapon bait = LoadLWeaponOf(LW_BAIT);
      if (!bait->isValid()) Quit();

      bait->Dir = Link->Dir;
      if      (bait->Dir == DIR_DOWN)  bait->OriginalTile += bait->NumFrames;
      else if (bait->Dir == DIR_LEFT)  bait->OriginalTile += bait->NumFrames*2;      
      else if (bait->Dir == DIR_RIGHT) bait->OriginalTile += bait->NumFrames*3;      

      bool stopped;
      float bx = bait->X;
      float by = bait->Y;

      while(true)
      {
         bait = LoadLWeaponOf(LW_BAIT);
         if (!bait->isValid()) Quit();

         if(!stopped)
         {
            int top = HitboxTop(bait);
            int bottom = HitboxBottom(bait);
            int left = HitboxLeft(bait);
            int right = HitboxRight(bait);

            if (bait->Dir == DIR_UP)
            {
               top -= speed;
               int loc = ComboAt(CenterX(bait),top);
               if(top < 0 || isSolid(left,top) || isSolid(right,top) || IsWater(loc) ) stopped = true;
               else by -= speed;

               if( Floor(by) != bait->Y) bait->Y = by;
            }
            else if (bait->Dir == DIR_DOWN)
            {
               bottom += speed;
               int loc = ComboAt(CenterX(bait),bottom);
               if(bottom > 176 || isSolid(left,bottom) || isSolid(right,bottom) || IsWater(loc) ) stopped = true;
               else by += speed;

               if( Floor(by) != bait->Y) bait->Y = by;
            }
            else if (bait->Dir == DIR_LEFT)
            {
               left -= speed;
               int loc = ComboAt(left,CenterY(bait));
               if(left < 0 || isSolid(left,top) || isSolid(left,bottom) || IsWater(loc) ) stopped = true;
               else bx -= speed;

               if( Floor(bx) != bait->X) bait->X = bx;
            }
            else if (bait->Dir == DIR_RIGHT)
            {
               right += speed;
               int loc = ComboAt(right,CenterY(bait));
               if(right > 256 || isSolid(right,top) || isSolid(right,bottom) || IsWater(loc) ) stopped = true;
               else bx += speed;

               if( Floor(bx) != bait->X) bait->X = bx;
            }
         }
    
         Waitframe();
      }
   }
}


// !!!!!!!!! This function is used by a lot of scripts.  Only need it once.
//returns true if the combo is solid at x/y
bool isSolid(int x, int y){
    if(x<0 || x>255 || y<0 || y>175) return false;
    int mask=1111b;
        if(x%16<8) mask&=0011b;
        else mask&=1100b;
            if(y%16<8) mask&=0101b;
            else mask&=1010b;
            return (!(Screen->ComboS[ComboAt(x, y)]&mask)==0);
}


// don't touch these contants.  they are the values of the lw->Misc[LW_MISC_BAITTYPE]
const int BT_UNMARKED = 0;
const int BT_NORMAL   = 1;
const int BT_POISON   = 2;
const int BT_SLEEP    = 3;
const int BT_MINE     = 4;
const int BT_BCHU     = 5;