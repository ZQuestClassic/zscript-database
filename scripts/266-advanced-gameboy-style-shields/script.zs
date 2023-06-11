// -------------------------------------------

// --- Consumable Game-Boy Styled Shields  ---

// ---    with advanced defense options    ---

// ---     by justin, request gouanaco     ---

// --- based on Simplified GBShield Script ---

// ---  by MoscowModder and others         ---

// ---             ver 1.0                 ---

// -------------------------------------------

//

// Setup instructions

// 1. Check/set the constants below the instructions (sound SFXs, durability display, and eweapon->Misc[] index)

// 2. Combine global script with your existing slot2/active global, or if no existing global active, just use the example version

// 3. Compile/Import the script into your quest

// 3.1 set the global to its slot

// 3.2 set the item script gbshield to a slot

//

// 4. For every equipable/consumable/advanced shield you will need two items. Let's call them Item1 and Item2 for clarity with their particular setups.

//    Item1

//     The actual shield. Itemclass shield. Give this one a Link Tile Modifier to your tiles of Link carrying this shield.

//     This shield can still use normal shield block/reflect flags (see below) on the first page of the editor giving this script even more customization.

//     This shield can also take advantage of the consumable/advanced defense options by using the D values on the Scripts tab (you don't actually attach a script)

//     See, Item1 Options at end of these instructions for the standard block/reflect flags and all the D value options.

//

//    Item2

//     The "dummy" shield item. Itemclass custom. This is the item that will be usable on your A/B buttons. When used it gives the actual shield (Item1).

//     On the script tab, attach the gbshield script to the Action slot. Set the D values.

//      DO: "Real" shield item# to give

//      D1: Dummy shield item#, the item# that this script is attached to

//      D2: Durabilty save slot. If multiple consumable shields exist in the quest use this to save the current durabilty of each one. 

//          Give each individual shield a unique value between 0 and 4.

//          the script is hardwired to only save 5 durability values. expansion is possible by increasing the size of the CGBShieldVars[] array.

//          to increase the array size, see note at bottom of this script file.

//

// 5. That's it.

// ---------------------------

// 

// Item1 Options

// 

// Standard block/reflect flags - sum the numbers. eg: shield blocks - rock, arrow, fireball, script = 1+2+8+128 = 139

// 1 - rock

// 2 - arrow

// 4 - boomerang

// 8 - fireball

// 16 - sword beam

// 32 - magic

// 64 - fire

// 128 - script weapons

// 256 - boss fireball

//

// Advanced consumption and defense options for the Script Tab of Item1

// D0 = the shield's durability (HP)

// D1-D7 are for the highly customizable consumption/defense options. you don't need to set them all. this is their format.

// xxxxxxx.yy

// a positive x value means we want to use the standard block/reflect flags as above. (can be different than block/reflect on Data page)

// a negative x value means we want to use the advanced block/reflect flags below. ( NOT to be combined like standard block/reflect flags)

// the y value sets how the shield/Link handles the weapon(s) defined by x.

// 

// Negative X values ( NOT to be combined like standard block/reflect flags)

//  rock = 1            arrow = 2        boomerang = 3    fireball = 4     swordbeam = 5     magic = 6

//  fire = 7            gen.script = 8   fireball2 = 9    proj.bomb = 10   bombblast = 11    proj.supbomb = 12

//  supbombblast = 13   firetrail = 14   wind = 15        fire2 = 16       script1 = 17      script2 = 18

//  script3 = 19        script4 = 20     script5 = 21     script6 = 22     script7 = 23      script8 = 24

//  script9 = 25        script10 = 26

//

// Y Values (divided up between tens column and ones column)

//  Tens column

//   .0y == shield takes no damage

//   .1y == shield takes all the eweapon damage

//   .2y == shield takes half the eweapon damage

//   .3y == shield takes half the eweapon damage, and diminshes the strength of the eweapon by that amount

//   .4y == shield takes quarter the eweapon damage

//   .5y == shield takes quarter the eweapon damage, and diminshes the strength of the eweapon by that amount

//   .6y == shield takes double the eweapon damage

//   .7y == shield takes triple the eweapon damage

//   .8y == eweapon one-hit-kills shield

//  Ones column

//  .y0 == Regardless of above, Link will not be hurt (eweapon was destroyed by shield)

//  .y1 == If shield breaks, Link takes the extra damage left over. eg Shield durability = 10, weapon damage = 15, Link will lose 5HP and shield gone

//  .y2 == Reflect eweapon, Link will not be hurt. But shield may have been damaged in process

//  .y3 == Despite shield, Link gets full weapon damage

//  .y4 == Despite shield, Link gets half weapon damage

//  .y5 == Despite shield, Link gets quarter weapon damage

//  .y6 == Despite shield, Link gets double weapon damage

//  .y7 == Despite shield, Link gets triple weapon damage

// the .y3 thru .y7 values allow for significant customization, for instance a 14 value gives a shield that takes full damage, but still gives Link half damage

// obviously some of the variations would be very mean if implimented, but who am I to decide...

//

// Example usage:

// D0 = 100  shield has 100 hp durability

// D1 = 38.21   shield will take half damage (.2y) from magic, boomr, arrow (32+4+2=38). If shield breaks (.y1) Link takes leftover damage from these weapons.

// D2 = -11.84  shield will be destroyed (.8y) by a bombblast (-11), but Link will only take half damage from the blast (.y4)

// D3 = 24.32    shield will take half damage (.3y) from fireball, swordbeam (8+16=24), and half dimished weapon will be reflected (.y2) 







import "std.zh" // only need this once in your entire scriptfile. 



int CGBShieldVars[37]; // a global array that stores all the variables used by this script. see the bottom of this script file for the index values.



// --------------------------------------

// constants you may wish/need to change



const int CGBS_DURADISPLAY = 1; // 0 = no display, 1 = set to counter, can be placed on subscreen

const int CGBS_DURACOUNTER = 7; // default 7 = CR_SCRIPT1 counter, change depending on the counter usage in your quest. 



const int SFX_GBSHIELD = 17; //Shield active SFX   (note: this is the Hookshot sound in the default Z1 tileset)

const int SFX_SHIELDBREAK = 0; // SFX to use when shield breaks, the default value of 0 means that none is set

// this script also uses the following sound effects which the quest designer may wish to change (do a search)

// SFX_CLINK, the standard shield collision sound

// SFX_OUCH, the standard Link hurt sound



const int EW_MISC_CGBS = 0; // an index to the eweapon->Misc[] array. if any other scripts use this array you might have to change this value.



// ----- end constants -----------------





// --------------------------------------

// Example global active script, if combining with an existing global active script add, before the Waitframe(); the following two lines without the // comment tags

// GB_Shield();

// if(CGBShieldVars[CGBS_shieldOn]==1) Consume_Shield();



global script active{

 void run(){

  while(true){



   // the following two lines run the button equipable Game-Boy styled shield, and the Consumable shield with advanced defense options

   GB_Shield();

   if(CGBShieldVars[CGBS_shieldOn]==1) Consume_Shield();



   Waitdraw();        //sometimes doesn't exist in a global active script, if it does, the shield code goes above it.

   Waitframe();       //Needed at bottom of while(true) loop

  }//end while

 }//end void run

}



// ------ end global -------------------





// ------- Item Script -----------------

// Item use script that checks use of dummy shield item and gives an actual shield item

// modified version of gbshield script by MoscowModder (who in turn credits others)



// Attach the script gbshield to the Action slot of the dummy shield item, and set the following arguments (D values)



//DO: "Real" shield item# to give

//D1: Dummy shield item#, the item# that this script is attached to

//D2: Durabilty save slot. If multiple consumable shields exist in the quest use this to save the current durabilty of each one. 

//    Give each individual shield a unique value between 0 and 4.

//    the script is hardwired to only save 5 durability values. expansion is possible by increasing the size of the CGBShieldVars[] array.

//    to increase the array size, see note at bottom of this script file.



item script gbshield{

 void run ( int shieldID, int dummyID, int duraSaveSlot ){

   if(CGBShieldVars[CGBS_curShieldItem] != shieldID)  // this dummy shield is connected to different real shield than we've already been using

   {

    itemdata dummy = Game->LoadItemData( CGBShieldVars[CGBS_dummyShield] ); // get the previous dummy shield

    CGBShieldVars[CGBS_DurSlot1 + dummy->InitD[3]] = CGBShieldVars[CGBS_curDur]; // save previous shield durability to its durability slot (connected to its dummy)

   

    for(int i=0;i<CGBS_DurSlot1;i++) CGBShieldVars[i]=0; // clear everything up to the saved durability slots



    CGBShieldVars[CGBS_curDur] = CGBShieldVars[CGBS_DurSlot1 + duraSaveSlot];  // get saved durability for this shield

    CGBShieldVars[CGBS_curShieldItem] = shieldID;  // set the new real shield item#

    CGBShieldVars[CGBS_dummyShield] = dummyID;     // save this dummy item#

    Set_ShieldConsume(shieldID);     // get the arguments attached to our real shield and put in our CGBShieldVars[] array

   }//endif

 

  if ( Link->PressB ) CGBShieldVars[CGBS_Button] = 1;   // shield is on B button

  else if ( Link->PressA ) CGBShieldVars[CGBS_Button] = 2;  // shield is on A button



  CGBShieldVars[CGBS_usedDummy] = 1;   // tells our global function to actually give us the real shield

 }//end voidrun

}//end itemscript gbshield



// ------ end Item scripts -------------







// ------- Global functions -------------



// Function from gbshield script by MoscowModder (who in turn credits others)

void GB_Shield(){

 if( !CGBShieldVars[CGBS_shieldOn] && CGBShieldVars[CGBS_usedDummy]){   //Enable shield when using dummy

  CGBShieldVars[CGBS_shieldOn]=1;                  //Set shield state to on

  CGBShieldVars[CGBS_usedDummy]=0;

  Link->Item[ CGBShieldVars[CGBS_curShieldItem] ]=true;    //Give the shield

  Game->PlaySound(SFX_GBSHIELD);  //Play the sound

 }

 else if( ((CGBShieldVars[CGBS_Button] == 2 && !Link->InputA) || (CGBShieldVars[CGBS_Button] == 1 && !Link->InputB)) && CGBShieldVars[CGBS_shieldOn])

 { // button was released, so let's take the shield off. 

  Link->Item[ CGBShieldVars[CGBS_curShieldItem] ]=false;   //Remove shield

  CGBShieldVars[CGBS_shieldOn]=0;                  //Set shield state to off

 }

}



// Going to check for valid collisions with our shield, and handle the consumption

void Consume_Shield(){

 eweapon ew;



 for(int i=Screen->NumEWeapons(); i>0 ; i--)  // cycle thru every eweapon on screen

 {

  ew = Screen->LoadEWeapon(i);

  if( !CGBS_EWType(ew->ID) ) continue;  // eweapon type isn't something the shield cares about (normal collision, will not affect shield)



  ew->CollDetection = false; // turn off engine collisions so we can handle



  if( ShieldCollision(ew) )   // check for collision

  {

   if(ew->Misc[EW_MISC_CGBS] != 666)   // hasn't already hit Link/shield

   {

    Game->PlaySound(SFX_CLINK);

    Do_ConsumeShield(ew);

    ew->Misc[EW_MISC_CGBS] = 666;    // mark this eweapon with the sign of the beast

   }//if666

  }//ifcollision



  ew->CollDetection = true; // turn engine collisions back on in case it's hitting something else



 }//forloop ew cycle



 if(CGBS_DURADISPLAY == 1) Game->Counter[CGBS_DURACOUNTER] = CGBShieldVars[CGBS_curDur];

}//end Consume_Shield



// a function to check for collision between Link and eweapon, plus correlation between direction Link is facing and location of eweapon.

// it should return true if the eweapon would be hitting Link's shield

bool ShieldCollision(eweapon b)

{

  if( ((Link->Z + Link->HitZHeight >= b->Z) && (Link->Z <= b->Z + b->HitZHeight))==false) return false;



  int Lx1 = Link->X + Link->HitXOffset;

  int Lx2 = Lx1 + Link->HitWidth;

  int bx1 = b->X + b->HitXOffset;

  int bx2 = bx1 + b->HitWidth;



  if( Lx2 < bx1 ) return false;

  if( Lx1 > bx2 ) return false;



  int Ly1 = Link->Y + Link->HitYOffset;

  int Ly2 = Ly1 + Link->HitHeight;

  int by1 = b->Y + b->HitYOffset;

  int by2 = by1 + b->HitHeight;



  if( Ly2 < by1 ) return false;

  if( Ly1 > by2 ) return false;

  int a = AngleDir8(Angle( Link->X+8, Link->Y+8, CenterX(b), CenterY(b) ));

  if(a == Link->Dir) return true;

  return false;

}//end ShieldCollision



// we have a collision between the eweapon and our shield, so let's do the consumption junction and some other functions (advanced defense stuff)

void Do_ConsumeShield(eweapon ew)

{

 int weapon_type = EWType_to_ConsumeShieldType(ew->ID);

 int shieldHurt = Floor(CGBShieldVars[weapon_type] * 0.1);

 int linkHurt = CGBShieldVars[weapon_type] - (shieldHurt*10);

 int damageShield = 0;

 int damageLink = 0;



 // get the damage to the shield based on its defense to this threat

 if(shieldHurt>0){

  if     (shieldHurt == 1) damageShield = ew->Damage;

  else if(shieldHurt == 2 || shieldHurt == 3) damageShield = ew->Damage * 0.5;

  else if(shieldHurt == 4 || shieldHurt == 5) damageShield = ew->Damage * 0.25;

  else if(shieldHurt == 6) damageShield = ew->Damage * 2;

  else if(shieldHurt == 7) damageShield = ew->Damage * 3;



  if(shieldHurt == 3 || shieldHurt == 5) ew->Damage -= damageShield;

 }//ifShieldHurt>0



 CGBShieldVars[CGBS_curDur] -= damageShield;   // damage the shield



 // get the damage to Link based on his defense to this threat

 if(linkHurt==0){

  ew->DeadState = WDS_DEAD; // shield blocked this threat, kill the weapon

 }//ifLinkHurt==0



 else if(linkHurt==1){   // if shield is negative durability, give the extra damage to Link

  if(CGBShieldVars[CGBS_curDur] < 0) damageLink = Abs(CGBShieldVars[CGBS_curDur]);

  else ew->DeadState = WDS_DEAD;

  

  if(damageLink > ew->Damage){  // we don't want to hurt Link extra because of double damage to shield

   damageLink -= ew->Damage;

   if(damageLink > ew->Damage) damageLink -= ew->Damage; // we still don't want to hurt Link extra due to tripled damage to shield

  }//ifdamageLink

  if(shieldHurt == 3 || shieldHurt == 5) damageLink += ew->Damage;

 }//ifLinkHurt==1



 else if(linkHurt==2){  // reflect eweapon

  lweapon lw = Screen->CreateLWeapon( ReflectEWtype(ew->ID) );

  lw->X = ew->X;  lw->Y = ew->Y;  lw->Z = ew->Z;   lw->Jump = ew->Jump;

  lw->DrawStyle = ew->DrawStyle;  lw->OriginalTile = ew->OriginalTile;   lw->Tile = ew->Tile;

  lw->OriginalCSet = ew->OriginalCSet;   lw->CSet = ew->CSet;   lw->FlashCSet = ew->FlashCSet;

  lw->NumFrames = ew->NumFrames;   lw->Frame = ew->Frame;   lw->ASpeed = ew->ASpeed;

  lw->Damage = ew->Damage;   lw->Step = ew->Step;   lw->Angular = ew->Angular;   lw->Flash = ew->Flash;

  lw->DeadState = -1;  lw->Flip = ew->Flip;   lw->Extend = ew->Extend;   lw->TileWidth = ew->TileWidth;

  lw->TileHeight = ew->TileHeight;  lw->HitWidth = ew->HitWidth;   lw->HitHeight = ew->HitHeight;

  lw->Dir = reverseDir(ew->Dir);

  if(lw->Dir == DIR_UP) lw->Flip = 0;

  else if(lw->Dir == DIR_DOWN) lw->Flip = 2;

  else if(lw->Dir == DIR_RIGHT) lw->Flip = 0;

  else if(lw->Dir == DIR_LEFT) lw->Flip = 1;



  ew->DeadState = WDS_DEAD;  

 }//ifLinkHurt==2



 else if(linkHurt == 3) damageLink = ew->Damage;

 else if(linkHurt == 4) damageLink = ew->Damage * 0.5;

 else if(linkHurt == 5) damageLink = ew->Damage * 0.25;

 else if(linkHurt == 6) damageLink = ew->Damage * 2;

 else if(linkHurt == 7) damageLink = ew->Damage * 3;



 if(CGBShieldVars[CGBS_curDur] <= 0 || shieldHurt == 8) // shield destroyed (no durability left, or one-hit killed)

 {

  Game->PlaySound(SFX_SHIELDBREAK);

  Link->Item[ CGBShieldVars[CGBS_curShieldItem] ] = false;   //Remove real shield from Link inventory

  Link->Item[ CGBShieldVars[CGBS_dummyShield] ] = false;     //Remove dummy shield from Link inventory



  itemdata dummy = Game->LoadItemData( CGBShieldVars[CGBS_dummyShield] ); // get our dummy shield data

  CGBShieldVars[CGBS_DurSlot1 + dummy->InitD[3]] = 0; // clear this shield's durability slot (connected to its dummy)



  for(int i=0;i<CGBS_DurSlot1;i++) CGBShieldVars[i]=0; // clear everything up to the saved durability slots

 }//ifdestroyShield

 

 if(damageLink>0) // we have to hurt Link

 {

  Link->HP -= damageLink;

  Link->Action = LA_GOTHURTLAND;

  Link->HitDir = -1;

  Game->PlaySound(SFX_OUCH);

  ew->DeadState = WDS_DEAD;

 }//ifDamageLink>0

}//end Do_ConsumeShield



// converts an eweapon type to an lweapon when reflected off shield. 

// does not currently include EW_SCRIPT#, EW_FIRE2. Could be added if desired. 

int ReflectEWtype( int ewType){

 if(ewType == EW_ARROW) return LW_ARROW;

 if(ewType == EW_BRANG) return LW_BRANG;

 if(ewType == EW_BEAM) return LW_REFBEAM;

 if(ewType == EW_ROCK) return LW_REFROCK;

 if(ewType == EW_MAGIC) return LW_REFMAGIC;

 if(ewType == EW_FIREBALL || ewType == EW_FIREBALL2) return LW_REFFIREBALL;

 if(ewType == EW_BOMB) return LW_BOMB;

 if(ewType == EW_BOMBBLAST) return LW_BOMBBLAST;

 if(ewType == EW_SBOMB) return LW_SBOMB;

 if(ewType == EW_SBOMBBLAST) return LW_SBOMBBLAST;

 if(ewType == EW_FIRE) return LW_FIRE;

 if(ewType == EW_WIND) return LW_WIND;

 return -1;

}



// convert an eweapon type value to the consumable shield values used by the CGBShieldVars[] array

int EWType_to_ConsumeShieldType(int ewType){

 if(ewType == EW_ARROW) return CGBS_arrow;

 if(ewType == EW_BRANG) return CGBS_boomr;

 if(ewType == EW_BEAM) return CGBS_swordb;

 if(ewType == EW_ROCK) return CGBS_rock;

 if(ewType == EW_MAGIC) return CGBS_magic;

 if(ewType == EW_FIREBALL) return CGBS_fireb;

 if(ewType == EW_FIREBALL2) return CGBS_boss;

 if(ewType == EW_BOMB) return CGBS_bomb;

 if(ewType == EW_BOMBBLAST) return CGBS_bombb;

 if(ewType == EW_SBOMB) return CGBS_sbomb;

 if(ewType == EW_SBOMBBLAST) return CGBS_sbombb;

 if(ewType == EW_FIRETRAIL) return CGBS_firet;

 if(ewType == EW_FIRE) return CGBS_fire;

 if(ewType == EW_WIND) return CGBS_wind;

 if(ewType == EW_FIRE2) return CGBS_fire2;

 if(ewType == EW_SCRIPT1) return CGBS_script1;

 if(ewType == EW_SCRIPT2) return CGBS_script2;

 if(ewType == EW_SCRIPT3) return CGBS_script3;

 if(ewType == EW_SCRIPT4) return CGBS_script4;

 if(ewType == EW_SCRIPT5) return CGBS_script5;

 if(ewType == EW_SCRIPT6) return CGBS_script6;

 if(ewType == EW_SCRIPT7) return CGBS_script7;

 if(ewType == EW_SCRIPT8) return CGBS_script8;

 if(ewType == EW_SCRIPT9) return CGBS_script9;

 if(ewType == EW_SCRIPT10) return CGBS_script10;



 return -1;

}//end EWType_to_ConsumeShieldType



// checks if our consumable shield cares about the eweapon type

bool CGBS_EWType( int ewType ){

 if( CGBShieldVars[ EWType_to_ConsumeShieldType(ewType) ] > 0) return true;

 return false;

}//end CGBS_EWType





// Grab the D values from the real shield item and sort them into the CGBShieldVars[] array for easier use

void Set_ShieldConsume(int shieldID)

{

 float defenseTypes = 0;

 int defenseVal = 0;

 bool isNeg;



 itemdata shield = Game->LoadItemData(shieldID);

 // if we didn't have a saved durability for this shield, we get the durability for it being brand spankin new



 if( CGBShieldVars[CGBS_curDur] <= 0) CGBShieldVars[CGBS_curDur] = shield->InitD[0];  



 for(int i=1;i<8;i++)   // cycle the remaining arguments

 {

  defenseTypes = shield->InitD[i];

  if(defenseTypes==0) continue;   // no inputted value for the argument, move onto next



  isNeg = (defenseTypes<0);

  if(isNeg) defenseTypes = Abs(defenseTypes);

  // next two statements separate the integer and fraction from the argument into two variables  

  defenseVal = (defenseTypes - Floor(defenseTypes) ) * 100;

  defenseTypes = Floor(defenseTypes);



  if(isNeg) // we are using a speciality shield defense value

  {

   CGBShieldVars[defenseTypes] = defenseVal;

  }

  else // we are just using the standard shield defense bit flag values

  {

   for(int b=1;b<10;b++) // cycle through the bits of the shield defense argument

   {

    // if the bit is true (we have defense to that weapon) set the corresponding defense value to our CGBShieldVars[] array

    if( GetBit(defenseTypes,b) == true ) CGBShieldVars[b] = defenseVal;

   }//for loop

  }//else statement

 }//for loop

}//Set_ShieldConsume





//---------------------

// General functions



int SetBit(int vari, int bit, bool state){

 bit = bit-1;

 int r = vari;

    if(state)	r |= (1 << bit);

    else	r &= ~(1 << bit);

 return r;

}



bool GetBit(int vari, int bit){

 bit = bit-1;

    return (vari & (1 << bit)) != 0;

}



//from stdExtra.zh   remove this if you have stdExtra.zh imported.

//Returns the reverse of the given direction.

int reverseDir(int dir)

{

	if(dir != Clamp(dir, 0, 15)) return -1; //Invalid direction

	return Cond(dir<8, OppositeDir(dir), ((dir+4)%8)+8);

}



void TestInt(int num, int x, int y) {

   Screen->DrawInteger(0,x,y,0,0,-1,0,0,num,0,OP_OPAQUE);

}







// ---------------------------------------

// the following constants do not need to be changed. they are indexes to the variables of the CGBShieldVars[] array

// however, if your quest is using more than 5 consumable shields, you will need to increase the size of the array. see the bottom of this list for the formula.



const int CGBS_curDur = 0;   // index to current shield's current durability

const int CGBS_rock = 1;     // index to eweapon rock defenses

const int CGBS_arrow = 2;    // index to eweapon arrow defenses

const int CGBS_boomr = 3;    // index to eweapon boomerang defenses

const int CGBS_fireb = 4;    // index to eweapon fireball defenses

const int CGBS_swordb = 5;   // index to eweapon sword beam defenses

const int CGBS_magic = 6;    // index to eweapon magic defenses

const int CGBS_fire = 7;     // index to eweapon fire defenses

const int CGBS_script = 8;   // index to eweapon generic script defenses

const int CGBS_boss = 9;     // index to eweapon boss fireball defenses

const int CGBS_bomb = 10;    // index to eweapon projectile bomb defenses

const int CGBS_bombb = 11;   // index to eweapon bomb blast defenses

const int CGBS_sbomb = 12;   // index to eweapon projectile superbomb defenses

const int CGBS_sbombb = 13;  // index to eweapon superbomb blast defenses

const int CGBS_firet = 14;   // index to eweapon fire trail defenses

const int CGBS_wind = 15;    // index to eweapon wind defenses

const int CGBS_fire2 = 16;   // index to eweapon fire2 defenses

const int CGBS_script1 = 17; // index to eweapon script# defenses

const int CGBS_script2 = 18;

const int CGBS_script3 = 19;

const int CGBS_script4 = 20;

const int CGBS_script5 = 21;

const int CGBS_script6 = 22;

const int CGBS_script7 = 23;

const int CGBS_script8 = 24;

const int CGBS_script9 = 25;

const int CGBS_script10 = 26;



const int CGBS_curShieldItem = 27;  // index to current real shield item# being tracked

const int CGBS_dummyShield = 28;    // index to the dummy shield item# that controls the real shield

const int CGBS_Button = 29;         // index to a variable tracking the button press that actuates the shield (A==2, B==1)

const int CGBS_shieldOn = 30;       // index to a variable tracking the real shield is being used

const int CGBS_usedDummy = 31;      // index to a variable tracking the one-frame usage of the dummy item to tell the global script to give the real shield



const int CGBS_DurSlot1 = 32; // from this array value and up can be used to save durability of multiple shields

// DurSlot2 = 33, DurSlot3 = 34, DurSlot4 = 35, DurSlot5= 36

// if you need to save more than 5 shield durabilities increase the CGBShieldVars[] array using the following formula

// (total number of slots) + CGBS_DurSlot1

// eg currently  CGBShieldVars[37]   (number of slots = 5) + (CGBS_DurSlot1 = 32) = 37



// ------------------- end of script file -----------------------