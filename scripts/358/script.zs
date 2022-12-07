//Spawn Specific Item (CREDIT: Justin) (Slash Item FFC)

// Watches for the combo under the FFC to change, and generates an item and lweapon on a slashable combo.

//YOU NEED 1 FFC FOR EACH SLASHABLE COMBO that you want this script to work with, and the FFC must sit on top of that combo.
//This technically will work for ANY combo that changes, not just slashables.
//You could, for example, put this on a tile that changes on secret triggers, which would add an effect on secret trigger
//like a door that has a puff of smoke when it vanishes.
//This even works for LWeapons that you create yourself.

// D0 = The itemset from which a random item will drop. 0 = None
// D1 = LWeapon to display on slash.
// D2 = Sound to play on slash.

//This works for: Jars, New Bushes with different leaves, "Poof" effects for magic, literally any effect you need on a tile that changes.

//import "std.zh"
 
ffc script Slash_FX
{
   void run(int itemset, int weapon, int sfx)
   {
      int loc = ComboAt(this->X,this->Y);
      int c = Screen->ComboD[loc];
 
      while(true)
      {
         if(Screen->ComboD[loc] != c)
         {
           //Create a npc (enemyfire) that dies immediately, and makes no sound doing so.
           //Npc drops itemset chosen in D0.
           Game->PlaySound(sfx);
           npc dropper = CreateNPCAt(NPC_ENEMYFIRE, ComboX(loc), ComboY(loc));
           dropper->ItemSet = itemset;
           dropper->HP = HP_SILENT;
           dropper->DrawXOffset = -1000;
           
           //Create breaking effect, then destroy it after 20 frames.
           lweapon jarvis = CreateLWeaponAt(LW_SPARKLE, ComboX(loc), ComboY(loc));
           jarvis->UseSprite(weapon);
           //for (int i = 0; i < 20; i++) {
           //	WaitNoAction();
           //}
           //jarvis->DeadState = WDS_DEAD;
           
            Quit();
         }
 
         Waitframe();
      }
   }
}