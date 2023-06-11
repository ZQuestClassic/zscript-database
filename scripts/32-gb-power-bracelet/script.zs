// GB power bracelet

import "std.zh"
import "string.zh"
import "ffcscript.zh"


// global constants

const int CF_PICK = 98; // SCRIPT1, bracelet

const int SCRIPT_POWERBRACELET = 9; // set this to the ffc script slot assigned to PowerBracelet script when compiling

const int LTM_CATCHING = 135; // LTM for Link catching a block with the Power Bracelet
const int LTM_PULLING = 136; // LTM for Link pulling a block with the Power Bracelet
const int LTM_HOLDING = 133; // LTM for Link holding a block with the Power Bracelet

const int BLOCK_VH=4; //thrown block/bush horizontal initial velocity
const int BLOCK_VV=0; //thrown block/bush vertical initial velocity
const int BLOCK_DMG=8; //damage dealt to enemies by thrown block/bush
const int LW_BLOCK = 31; //id of a lweapon to be used as thrown block
const float BLOCK_FALL = 0.5; //gravity acceleration for block in sideview screens
const int PB_PULL_TIME=15; // num of frames to wait for pickup with PB
const int PB_UNDERCOMBO=0; // combo to set after picking up a block; set a negative value to have a shift of the original combo

const int SFX_PICKUP_BLOCK = 64; // sfx played when link picks up the block
const int SFX_THROW_BLOCK = 65; // sfx played when the block is thrown
const int SFX_CRASH_BLOCK = 66; // sfx of a block crashing

const int INV_COMBO_ID = 25; // id af an invisible combo
const int INV_TILE_ID = 803; // id af an invisible tile
const int CRASH_SPR = 91; // sprite for a block crashing at ground
const int BUSH_SPR = 92; // sprite for a bush crashing at ground
const int LAYER_OVER = 3; // an overhead layer

const int NPC_ITEMSET = 196; // id of a dummy enemy with type different from "none"

// ------------------------------------------

// global variables
bool throw_disabled;
int holding_block;
bool holding_bush;
int link_catching;


// ------------------------------------------

// Example of Global Scripts (comment this out if using other global scripts in the quest)

global script Slot_2{
void run(){
holding_block = 0;
while(true){
PowerBracelet();
Waitframe();
}
}
}

global script Slot_3{
void run(){
Link->Item[LTM_CATCHING] = false;
Link->Item[LTM_HOLDING] = false;
Link->Item[LTM_PULLING] = false;
holding_block = 0;
holding_bush = false;
link_catching = 0;
}
}

// ------------------------------------------

// global function to add to the global script
void PowerBracelet(){
if(Link->Item[LTM_HOLDING]){
if(CountFFCsRunning(SCRIPT_POWERBRACELET)==0 && holding_block>0){
holding_block = 0;
Link->Item[LTM_HOLDING] = false;
Link->Item[LTM_CATCHING] = false;
Link->Item[LTM_PULLING] = false;
}
}
}

// ------------------------------------------

// Item script
item script PowerBracelet{
void run(){
// if(holding_block==0 && holding_item==0 && holding_bomb==0){
if(holding_block==0){ // use this line if not using GB_Shop and GB_Bombs
if(!link_catching && isSolid(TouchedX(),TouchedY())){
link_catching=1;
int args[] = {0,0,0,0,0,0,0,0};
int id = RunFFCScript(SCRIPT_POWERBRACELET, args);
}
}
}
}

// ------------------------------------------

// FFC script (automatically called by the item script - you don't have to place any ffc on the screen for this)
ffc script UsePowerBracelet{
void run(int input){
// initialization
this->Data = INV_COMBO_ID;
this->X = -16;
this->Y = -16;
int counter = 0;

while(Link->InputA || Link->InputB){
// set link catching the wall / block / bush
if(!Link->Item[LTM_CATCHING]) Link->Item[LTM_CATCHING] = true;

// to fix a bug...
if(!isSolid(TouchedX(),TouchedY())) break;

// if pressing opposite direction, set link pulling
if(OppositeDir()){
if(!Link->Item[LTM_PULLING]) Link->Item[LTM_PULLING] = true;
counter ++;
}
else{
if(Link->Item[LTM_PULLING]) Link->Item[LTM_PULLING] = false;
counter = 0;
}

// if pulling a block or bush for 15 frames or more, pick it up
if(counter>PB_PULL_TIME){
int loc=TouchedComboLoc();
if(Screen->ComboF[loc]==CF_PICK || Screen->ComboI[loc]==CF_PICK){
link_catching = 0;
int combo = Screen->ComboD[loc];
int cset = Screen->ComboC[loc];
if(isBush(Screen->ComboT[loc])) holding_bush = true;
else holding_bush = false;
if(PB_UNDERCOMBO<0) Screen->ComboD[loc] += (-PB_UNDERCOMBO);
else Screen->ComboD[loc] = PB_UNDERCOMBO;
ItemSetAt(IS_DEFAULT,loc);
Game->PlaySound(SFX_PICKUP_BLOCK);
throw_disabled = true;

// mid-air block
for(int i=0;i<16;i++){
int blockX = (Link->X+ComboX(loc))/2;
int blockY = Link->Y-7;
Screen->FastCombo(LAYER_OVER, blockX, blockY, combo, cset, 128 );
WaitNoAction();
}

// set link holding
holding_block = 1;
if(!Link->Item[LTM_HOLDING]) Link->Item[LTM_HOLDING] = true;
while(throw_disabled || (!Link->InputA && !Link->InputB)){
if(!Link->InputA && !Link->InputB) throw_disabled = false;
Screen->FastCombo(LAYER_OVER, Link->X, Link->Y - 14, combo, cset, 128 );
if(Link->Invisible || (Link->Action != LA_NONE && Link->Action != LA_WALKING)) break; // break if falling in pit or water!
Waitframe();
}
if(Link->Invisible || (Link->Action != LA_NONE && Link->Action != LA_WALKING)) break; // break if falling in pit or water!
counter = 0;
holding_block = 0;
if(Link->Item[LTM_CATCHING]) Link->Item[LTM_CATCHING] = false;
if(Link->Item[LTM_PULLING]) Link->Item[LTM_PULLING] = false;
if(Link->Item[LTM_HOLDING]) Link->Item[LTM_HOLDING] = false;

// throw block
lweapon w = CreateLWeaponAt(LW_SCRIPT1,Link->X,Link->Y);
w->Damage = BLOCK_DMG;
w->OriginalTile = INV_TILE_ID;
w->NumFrames = 1;
w->Dir = Link->Dir;
w->Step = Floor(BLOCK_VH*100);
w->DrawYOffset = -14;
w->HitXOffset = -4;
w->HitYOffset = -4;
w->HitWidth = 16 + 8;
w->HitHeight = 16 + 8;
w->HitZHeight = 16 + 8;
Game->PlaySound(SFX_THROW_BLOCK);
while(w->DrawYOffset<0 && !isSolid(w->X+8,w->Y+ 8) && !isOutOfScreen(w->X,w->Y,16,16)){
if(counter<4) Link->Action = LA_ATTACKING;
w->DrawYOffset += Floor(counter*GRAVITY) - BLOCK_VV;
Screen->FastCombo(LAYER_OVER, w->X, w->Y + w->DrawYOffset, combo, cset, 128 );
Waitframe();
counter ++;
}
if(holding_bush) Game->PlaySound(SFX_GRASSCUT);
else Game->PlaySound(SFX_CRASH_BLOCK);
if(w->isValid()){
w->DeadState = WDS_DEAD;
if(holding_bush) CreateGraphicAt(BUSH_SPR,w->X,w->Y + w->DrawYOffset);
else CreateGraphicAt(CRASH_SPR,w->X,w->Y + w->DrawYOffset);
}
break;
}
}
NoMoveAction();
Waitframe();
}
link_catching = 0;
holding_block = 0;
counter = 0;
if(Link->Item[LTM_CATCHING]) Link->Item[LTM_CATCHING] = false;
if(Link->Item[LTM_PULLING]) Link->Item[LTM_PULLING] = false;
if(Link->Item[LTM_HOLDING]) Link->Item[LTM_HOLDING] = false;
this->Data = 0;
Quit();
}
}

// ------------------------------------------

// utility functions
bool isBush(int ct){
if(ct==CT_BUSH) return true;
if(ct==CT_BUSHC) return true;
if(ct==CT_BUSHNEXT) return true;
if(ct==CT_BUSHNEXTC) return true;
if(ct==CT_FLOWERS) return true;
if(ct==CT_FLOWERSC) return true;
return false;
}

// ------------------------------------------

// x touched by Link
int TouchedX(){
int x;
if(Link->Dir == DIR_UP) x = Link->X+8;
else if(Link->Dir == DIR_DOWN) x = Link->X+8;
else if(Link->Dir == DIR_LEFT) x = Link->X-2;
else if(Link->Dir == DIR_RIGHT) x = Link->X+18;
return x;
}

// y touched by Link
int TouchedY(){
int y;
if(Link->Dir == DIR_UP) y = Link->Y+6;
else if(Link->Dir == DIR_DOWN) y = Link->Y+18;
else if(Link->Dir == DIR_LEFT) y = Link->Y+8;
else if(Link->Dir == DIR_RIGHT) y = Link->Y+8;
return y;
}

// location of the touched combo
int TouchedComboLoc(){
int loc;
loc = ComboAt( TouchedX(), TouchedY() );
return loc;
}

// create a dummy npc and kill it, giving an item
void ItemSetAt(int itemset,int loc){
npc e = Screen->CreateNPC(NPC_ITEMSET);
e->ItemSet = itemset;
if(e->isValid()){
e->X = loc%16*16;
e->Y = loc-loc%16;
}
e->HP = HP_SILENT;
}

// function to test if (x,y) is out of the screen
bool isOutOfScreen(int x, int y, int dx, int dy){
if((x+dx) > 16*16) return true;
else if(x < 0) return true;
else if((y+dy) > 16*11) return true;
else if(y < 0) return true;
else return false;
}

// create a sprite
int CreateGraphicAt(int sprite, int x, int y){
eweapon e = Screen->CreateEWeapon(EW_SCRIPT1);
e->HitXOffset = 500;
e->UseSprite(sprite);
e->DeadState = e->NumFrames*e->ASpeed;
e->X = x;
e->Y = y;
return e->DeadState;
}

// inhibit all the movement actions
void NoMoveAction(){
Link->InputUp = false;
Link->InputDown = false;
Link->InputLeft = false;
Link->InputRight = false;
}

// this utility routine by Saffith checks for walkability of combos
bool isSolid(int x, int y){
if(x<0 || x>255 || y<0 || y>175) return false;
int mask=1111b;
if(x%16< 8) mask&=0011b;
else mask&=1100b;
if(y%16< 8) mask&=0101b;
else mask&=1010b;
return (!(Screen->ComboS[ComboAt(x, y)]&mask)==0);
}

// gives true if Link pushes the opposite direction of his facing direction
bool OppositeDir(){
if(Link->InputDown && Link->Dir==DIR_UP) return true;
if(Link->InputUp && Link->Dir==DIR_DOWN) return true;
if(Link->InputRight && Link->Dir==DIR_LEFT) return true;
if(Link->InputLeft && Link->Dir==DIR_RIGHT) return true;
else return false;
}

// ------------------------------------------