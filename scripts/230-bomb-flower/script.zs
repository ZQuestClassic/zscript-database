import "std.zh"  // Only include this once in youre Main Script File

/////////////////////////////////////////////////////////////////////////////////////////
// FFC Script Bomb Flower                                                              //
//                                                                                     //
// A Script that will create a explosion where this FFC was placed when it got hit by  //
// something (Link's Bomb hurt Links need to be checked in the Quest Rules).           //
// You need to create a Dummy Enemy in the Enemy Editor and set the dummy constant to  //
// the Enemy ID. It should use an invisible Tile, should be Type Other with 1 HP and   //
// should not make any noise when it dies. Doesn't count as beatable Enemy should also //
// be checked. Set up it's defenses and it's ready for use (look at the Demo Quest for //
// more).                                                                              //
// Place an FFC with this Script attached over a Combo on youre Screen that should act //
// as a Bomb Flower. The explosion it creates will damage Link and Enemys.             //
//                                                                                     //
// D0: Set this to 1 if you want a Power Bomb Flower, otherwise it will be a normal    //
//     Bomb.                                                                           //
// D1: Set this to the Combo that should appear after the explosion.                   //
// D2: The amount of Damage Link takes from the explosion in full hearts.              //
/////////////////////////////////////////////////////////////////////////////////////////

const int dummy = 177;  // Dummy Enemy for collision detection

ffc script Bomb_Flower {
  void run(int explosiontype, int newcombo, int damage) {
    npc dm = CreateNPCAt(dummy, this -> X, this -> Y);
    dm -> HitHeight = 10;
    while(dm -> HP > 0) {
      Waitframe();
    }
    if(explosiontype == 1) {
      lweapon bomb = CreateLWeaponAt(LW_SBOMBBLAST, this -> X, this -> Y);
      bomb -> Damage = damage;
    } else {
      lweapon bomb = CreateLWeaponAt(LW_BOMBBLAST, this -> X, this -> Y);
      bomb -> Damage = damage;
    }
    Screen -> ComboD[ComboAt(this -> X, this -> Y)] = newcombo;
  }
}