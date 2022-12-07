//Bossmaker script arguments:
// D0: Movement part enemy in the list.
// D1: Shooter part enemy in the list.
// D2: Collision part enemy in the list. Also known as "core" or "weak point"
// D3: Set to 1 if you want for boss` body not to damage Link on direct contact. 
//    Contact with re is always harmful.
// D4: Shooter`s X position offset.
// D5: Shooter`s Y position offset.
//     Use these arguments if you want to have boss shoot Eweapons from proper position.
//     For Collision part use BigEnemy script with HitBox offset argument
 
const int BOSS_INVISITILE = 50000; //Needed to render NPC invisible.
 
ffc script BossMaker{
void run(int Movement, int WeaponFire, int Collision, int Background_Boss, int Shooter_XOffset, int Shooter_YOffset){
Waitframes(4);

//DECLARE VARIABLES AND POINTERS
npc EnemyMove; //Pointer for Movement Enemy Data
npc EnemyFire; //Pointer for Weapon Enemy Data
npc EnemyColl; //Pointer for Collision Enemy Data
bool Dual_Enemy = true; //Variable for Dual Enemy Mode
bool Triple_Enemy = true; //Variable for Triple Enemy Mode
int FireOrigWeapon; //Declare 6 variables for backing up Weapon, tiles and CollDetection for Projectile and Collision parts
int FireOrigtile;
bool FireOrigCollDetection;
int CollOrigWeapon;
int CollOrigtile;
bool CollOrigCollDetection;
//DETERMINE HOW MANY ENEMIES ARE BEING USED IN THE SCRIPT
Dual_Enemy = true; //Initialize modes as true.
Triple_Enemy = true;
EnemyMove = Screen->LoadNPC(Movement);  //Load enemy data used for appearance and movement
if(!EnemyMove->isValid()){
 Quit(); //Use Enemy placement flags to set up stationary bosses.
 }
if(WeaponFire>0) EnemyFire = Screen->LoadNPC(WeaponFire);   //Load enemy data used for behavior and weapon fire
// if(EnemyFire->isValid()){ //If a second enemy exists
// Dual_Enemy = true; //Activate "Dual Enemy" mode
// }
if(!EnemyFire->isValid()){ //If a second enemy does not exist
 Dual_Enemy = false; //"Dual Enemy" mode does not activate
 }
 else{
     FireOrigWeapon = EnemyFire->Weapon; //Back up Weapon, Original tile and CollDetection for Projectile part.
    FireOrigtile = EnemyFire->OriginalTile;
    FireOrigCollDetection = EnemyFire->CollDetection;
 }
 
if (Collision>0) EnemyColl = Screen->LoadNPC(Collision);   //Load enemy data used for collision and touch effects
// if(EnemyColl->isValid()){ //If a third enemy exists
// Triple_Enemy = true; //Activate "Triple Enemy" mode
// }
if(!EnemyColl->isValid()){ //If a third enemy does not exist
 Triple_Enemy = false; //"Triple Enemy" mode does not activate
 }
 else{
     CollOrigWeapon = EnemyColl->Weapon; //Back up Weapon, Original tile and CollDetection for Collision part.
    CollOrigtile = EnemyColl->OriginalTile;
    CollOrigCollDetection = EnemyColl->CollDetection;
 }
 
while(EnemyMove->isValid()){ 
if((Dual_Enemy == true)&&(EnemyFire->isValid())||(Triple_Enemy == true)){  //SETTINGS FOR BOTH DUAL AND TRIPLE ENEMY MODES
EnemyFire->X = EnemyMove->X + Shooter_XOffset;   //Weapon enemy X-Coordinate attached to Movement enemy. Offset is applied to position.
EnemyFire->Y = EnemyMove->Y + Shooter_YOffset;   //Weapon enemy Y-Coordinate attached to Movement enemy. Offset is applied to position.
WizzrobeUpdate(EnemyMove, EnemyFire, FireOrigtile, FireOrigWeapon, FireOrigCollDetection);
if(Background_Boss>0){ //Check if the boss is not in the same plane as Link
                      //Set NPC`s all Defenses to "ignore" if you want for boss body not to take damage from Lweapons.
EnemyMove->CollDetection = false;  //Movement enemy collision detection turned off
EnemyFire->CollDetection = false;  //Shooter enemy collision is off
}
}
if((Dual_Enemy == true)&&(Triple_Enemy == false)){ //SETTINGS FOR DUAL ENEMY MODE ONLY
if(EnemyMove->HP <= 0){ //If movement enemy's HP reaches zero
EnemyFire->HP = 0;   //Set Weapon enemy's HP to zero
Quit();   //Boss is dead. Finita la comedia.
}
}
if((Triple_Enemy == true)&&(EnemyColl->isValid())){ //SETTINGS FOR TRIPLE ENEMY MODE ONLY
EnemyColl->X = EnemyMove->X; //Collision enemy X-Coordinate attached to Movement enemy
EnemyColl->Y = EnemyMove->Y; //Collision enemy Y-Coordinate attached to Movement enemy
WizzrobeUpdate(EnemyMove, EnemyColl, CollOrigtile, CollOrigWeapon, CollOrigCollDetection);
if(Background_Boss>0){  //Check if the boss is not in the same plane as Link
                       //Set NPC`s all Defenses to "ignore" if you want for boss body not to take damage from Lweapons.
EnemyMove->CollDetection = false; //Movement enemy collision detection turned off
if(EnemyFire->isValid()){  // Some bosses have no turrets but have cores
EnemyFire->CollDetection = false; //Shooter enemy collision is off
}
} 
if((EnemyColl->HP <= 0)||(EnemyMove->HP <=0 )){ //If Collision enemy's HP reaches zero or movement part is already destroyed. 
EnemyMove->HP = 0;   //Set Movement enemy's HP to zero
EnemyColl->HP = 0;   //Set Collision enemy`s HP to 0. 
                     //This is useful if the Triple boss is killed via chain reaction 
                     //if there are multiple Bossmaker scripts running in one screen.
if(EnemyFire->isValid()){
EnemyFire->HP = 0; //Set Weapon enemy's HP to zero
}
Quit();//Boss is dead. Finita la comedia.
}
}
Waitframe();
}
// This 2-line piece of code destroys Shooter and Collision parts if EnemyMove pointer
// is rendered invalid in the way other than killing enemy. 
// This is true if enemy splits(like Digdogger) or tribbles.   
if (EnemyFire->isValid()) EnemyFire->HP=0;
if (EnemyColl->isValid()) EnemyColl->HP=0;
}
}

//This function temporarily hides Shooter and Collision enemies if WizzRobe 
//(if he is Movement part of the boss) is currently teleporting.
void WizzrobeUpdate(npc carrier, npc part, int OrigTile, int OrigWeapon, bool OrigCollDetection ){
    if (carrier->Type==NPCT_WIZZROBE){
        if (carrier->HitXOffset >= 1000){
            part->CollDetection=false;
            part->OriginalTile=BOSS_INVISITILE;
            part->Weapon=WPN_NONE;
        }
        else {
            part->CollDetection=OrigCollDetection;
            part->OriginalTile=OrigTile;
            part->Weapon=OrigWeapon;
        }
    }
}