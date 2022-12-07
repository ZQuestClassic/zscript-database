import "std.zh" // Make sure this line exists only once in your code

const int ICE_BLOCK_SCRIPT = 1; // Slot number that the ice_block script is assigned to
const int ICE_BLOCK_SENSITIVITY = 8; // Number of frames the blocks need to be pushed against to start moving

ffc script ice_block {
void run() {
int undercombo;
int framecounter = 0;

Waitframe();
undercombo = Screen->ComboD[this->Y + (this->X >> 4)];
Screen->ComboD[this->Y + (this->X >> 4)] = this->Data;

while(true) {
// Check if Link is pushing against the block
if((Link->X == this->X - 16 && (Link->Y < this->Y + 1 && Link->Y > this->Y - 12) && Link->InputRight && Link->Dir == DIR_RIGHT) || // Right
(Link->X == this->X + 16 && (Link->Y < this->Y + 1 && Link->Y > this->Y - 12) && Link->InputLeft && Link->Dir == DIR_LEFT) || // Left
(Link->Y == this->Y - 16 && (Link->X < this->X + 4 && Link->X > this->X - 4) && Link->InputDown && Link->Dir == DIR_DOWN) || // Down
(Link->Y == this->Y + 8 && (Link->X < this->X + 4 && Link->X > this->X - 4) && Link->InputUp && Link->Dir == DIR_UP)) { // Up
framecounter++;
}
else {
// Reset the frame counter
framecounter = 0;
}
// Once enough frames have passed, move the block
if(framecounter >= ICE_BLOCK_SENSITIVITY) {
// Check the direction
if(Link->Dir == DIR_RIGHT) {
while(this->X < 240 && // Not at the edge of the screen
!ComboFI(this->X + 16, this->Y, CF_NOBLOCKS) && // Not "No Push Block"
Screen->ComboS[this->Y + ((this->X + 16) >> 4)] == 0000b) { // Is walkable
Screen->ComboD[this->Y + (this->X >> 4)] = undercombo;
this->Vx = 2;
WaitNoAction(8);
undercombo = Screen->ComboD[this->Y + (this->X >> 4)];
}
this->Vx = 0;
Screen->ComboD[this->Y + (this->X >> 4)] = this->Data;
}
else if(Link->Dir == DIR_LEFT) {
while(this->X > 0 && // Not at the edge of the screen
!ComboFI(this->X - 1, this->Y, CF_NOBLOCKS) && // Not "No Push Block"
Screen->ComboS[this->Y + ((this->X - 16) >> 4)] == 0000b) { // Is walkable
Screen->ComboD[this->Y + (this->X >> 4)] = undercombo;
this->Vx = -2;
WaitNoAction(8);
undercombo = Screen->ComboD[this->Y + (this->X >> 4)];
}
this->Vx = 0;
Screen->ComboD[this->Y + (this->X >> 4)] = this->Data;
}
else if(Link->Dir == DIR_DOWN) {
while(this->Y < 160 && // Not at the edge of the screen
!ComboFI(this->X, this->Y + 16, CF_NOBLOCKS) && // Not "No Push Block"
Screen->ComboS[(this->Y + 16) + (this->X >> 4)] == 0000b) { // Is walkable
Screen->ComboD[this->Y + (this->X >> 4)] = undercombo;
this->Vy = 2;
WaitNoAction(8);
undercombo = Screen->ComboD[this->Y + (this->X >> 4)];
}
this->Vy = 0;
Screen->ComboD[this->Y + (this->X >> 4)] = this->Data;
}
else if(Link->Dir == DIR_UP) {
while(this->Y > 0 && // Not at the edge of the screen
!ComboFI(this->X, this->Y - 1, CF_NOBLOCKS) && // Not "No Push Block"
Screen->ComboS[(this->Y - 16) + (this->X >> 4)] == 0000b) { // Is walkable
Screen->ComboD[this->Y + (this->X >> 4)] = undercombo;
this->Vy = -2;
WaitNoAction(8);
undercombo = Screen->ComboD[this->Y + (this->X >> 4)];
}
this->Vy = 0;
Screen->ComboD[this->Y + (this->X >> 4)] = this->Data;
}
// Reset the frame counter
framecounter = 0;
}
Waitframe();
}
}
}

// Ice trigger script
ffc script ice_trigger {
void run() {
ffc blocks[31];
int triggerx[31];
int triggery[31];
int num_ice_blocks = 0;
int num_triggers = 0;
int good_counter = 0;

for(int i = 0; i < 176 && num_triggers < 31; i++) {
if(Screen->ComboF[i] == CF_BLOCKTRIGGER || Screen->ComboI[i] == CF_BLOCKTRIGGER) {
triggerx[num_triggers] = (i % 16) * 16;
triggery[num_triggers] = Floor(i / 16) * 16;
num_triggers++;
}
}
if(num_triggers == 0) Quit();

for(int i = 1; i <= 32; i++) {
ffc temp = Screen->LoadFFC(i);
if(temp->Script == ICE_BLOCK_SCRIPT) {
blocks[num_ice_blocks] = temp;
num_ice_blocks++;
}
}
if(num_ice_blocks == 0) Quit();

while(true) {
for(int i = 0; i < num_ice_blocks; i++) {
//Check if blocks are on switches and not moving
for(int j = 0; j < num_triggers; j++) {
if(blocks[i]->X == triggerx[j] && blocks[i]->Y == triggery[j] && blocks[i]->Vx == 0 && blocks[i]->Vy == 0) {
good_counter++;
break;
}
}
}
if(good_counter == num_triggers) {
Game->PlaySound(SFX_SECRET);
Screen->TriggerSecrets();
if((Screen->Flags[SF_SECRETS] & 2) == 0) Screen->State[ST_SECRET] = true;
Quit();
}
good_counter = 0;
Waitframe();
}
}
}