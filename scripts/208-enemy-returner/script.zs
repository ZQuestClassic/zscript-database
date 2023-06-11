import "std.zh"

const int ERETURNER_ENEMY   = 85;  // set to unmobile enemy#.  85 is Fire in Classic set
const int ERETURNER_SCREEND = 0;  // what Screen->D[] slot to use for Enemy Returner script. Pick a unique number 0-7 unused by other scripts.

const int ERETURNER_NUMVISITS = 3;  // number of visit threshold for global version

const int ERETURNER_SFMISCGS = 4;  
// global version won't run on screens with this Screen Flag set
// the default in General Use 1 flag (4 or 100b) under Screen->Flags->Misc (page2)
// General Use 2 = 8, General Use 3 = 16, General Use 4 = 32, General Use 5 = 64
// Only need to change if your quest uses these General Use Script Flags for other things

// global variable array and index values (the constants) used by the Enemy Returner Script.
int EReturnerVars[] = {0,0,0};
const int ERVar_CURSRN = 0;
const int ERVar_CURMAP = 1;
const int ERVar_FRMCNT = 2;


// Sample global script. Just plop glb_EReturner(); somewhere before the Waitframe();
global script active
{
 void run()
 {
  while(true)
  {
   glb_EReturner();

   Waitdraw();
   Waitframe();
  }
 }
}


void glb_EReturner()
{
 if(Link->Action == LA_SCROLLING) return;

 //-------------------------------------------------------------------
 // this first part will run every frame
 // unless the screen flag is set

 if((Screen->Flags[SF_MISC] & ERETURNER_SFMISCGS) != 0) return;

 if ( Game->GetCurScreen() != EReturnerVars[ERVar_CURSRN] 
   || Game->GetCurMap() != EReturnerVars[ERVar_CURMAP] )
 {
  // different screen
  EReturnerVars[ERVar_CURSRN] = Game->GetCurScreen();
  EReturnerVars[ERVar_CURMAP] = Game->GetCurMap();
  EReturnerVars[ERVar_FRMCNT] = 0;
 }
 else
 {
  if(EReturnerVars[ERVar_FRMCNT] < 5) EReturnerVars[ERVar_FRMCNT]++;
 }

 if(EReturnerVars[ERVar_FRMCNT] != 5) return;
 //-----------------------------------------------------------------------
 // remainder of script only runs in the frame enemies spawned.

 if( Screen->D[ERETURNER_SCREEND] == 0 )
 {
  // this screen hasn't been marked yet
  // there should be enemies by now

  if( Game->GuyCount[EReturnerVars[ERVar_CURSRN]] > 0)
  {
   // save original number of enemies
   Screen->D[ERETURNER_SCREEND] = (Game->GuyCount[EReturnerVars[ERVar_CURSRN]] << 8) | 1;
  }
 }
 else  // screen has been marked
 {
  int origEnemNum = Screen->D[ERETURNER_SCREEND] >> 8;
  int curEnemNum = Game->GuyCount[EReturnerVars[ERVar_CURSRN]];
  int numVisits = Screen->D[ERETURNER_SCREEND] & 0xFF;

  if( curEnemNum == origEnemNum )
  {
   numVisits = 1;
  }
  else if( curEnemNum < origEnemNum )
  {
   if( numVisits >= ERETURNER_NUMVISITS -1 )
   {
    // we are over our visit threshold
    // lets create some enemies and hide them offscreen
    npc e;
    for (int i = origEnemNum - curEnemNum; i > 0; i--)
    {
     e = Screen->CreateNPC(ERETURNER_ENEMY);
     e->X = 0;  e->Y = 0;
     e->DrawXOffset = -100;
     e->HitXOffset = -100;
     e->CollDetection = false;
    }

    // need to adjust GuyCount so ZC spawns more enemies next time
    Game->GuyCount[EReturnerVars[ERVar_CURSRN]] = origEnemNum;
    numVisits = 1;
   }
   else // visit count is under threshold
   {
    numVisits++;
   }
   //end visit if
  }
  //end enemy count if

  // still in marked screen if bracket
  Screen->D[ERETURNER_SCREEND] = (origEnemNum << 8) | numVisits;
 }
 //end marked screen if

 EReturnerVars[ERVar_FRMCNT] = 6; // whole script only runs for the 1 frame after enemies spawned
}


// Enemy Returner Script FFC
// Tired of players leaving just 1 enemy on the screen so they don't reset, well screw them!
// Can also be used to make enemies return faster without being "Always Return"
//
// D0 = Number of enemies the script should reset to. ie The number of enemies originally on screen.
// D1 = Number of visits to the screen for it to be reset.
// D2 = set to 1 to not run if no enemies on screen (let ZC do its normal respawning in this case)
//    = leave at 0 otherwise

ffc script EReturner
{
 void run(int numEnemies, int numVisits, int alwaysRun)  
 {
  Waitframes(5); // wait for enemies to spawn

  // lets not count if enemy count is over our enemy threshold
  // or if enemy count is zero and we don't want script to run
  if(Screen->NumNPCs() >= numEnemies || (alwaysRun != 0 && Screen->NumNPCs() == 0) ) 
  {
   Screen->D[ERETURNER_SCREEND] = 0;
   Quit();
  }
  if(Screen->D[ERETURNER_SCREEND] < 0) Screen->D[ERETURNER_SCREEND] = 0; // prevent oddstuff?
  
  Screen->D[ERETURNER_SCREEND]++;  // save our new screen visit count

  if(Screen->D[ERETURNER_SCREEND] < numVisits) Quit();  // less than our visit threshold

  // if still here we have met or exceeded our visit threshold

  Screen->D[ERETURNER_SCREEND] = 0;  // reset this

  // lets create some enemies and hide them offscreen
  npc e;
  for (int i = numEnemies - Screen->NumNPCs(); i > 0; i--)
  {
   e = Screen->CreateNPC(ERETURNER_ENEMY);
   e->X = 0;  e->Y = 0;
   e->DrawXOffset = -100;
   e->HitXOffset = -100;
   e->CollDetection = false;
  }

  // need to adjust GuyCount so ZC spawns more enemies next time
  Game->GuyCount[Game->GetCurScreen()] = Screen->NumNPCs();
 }
}