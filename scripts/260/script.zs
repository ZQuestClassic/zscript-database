//Simple Step to Save Combos
//by Aslion

//D0 - SFX to play when triggered
//D1 - Combo number to use for the save point

//Triggers once per screen entry when Link steps on the designated (D1) save combo.

ffc script StepToSave{
    void run(int SaveSFX, int SaveCombo){

        int Saved = 0;

        while(true){

            if ( Screen->ComboD[ComboAt(Link->X+8, Link->Y+12)] == SaveCombo && Link->Z == 0 ) { //Checks if Link is on the save combo

			Game->PlaySound(SaveSFX); //Plays sound effect
			Game->Save(); //Saves the game

			Saved ++;

            }

            if ( Saved == 1 ) {             // Remove this line if you wish for save points to trigger multiple times on one visit.
			Quit(); }           // ^

            Waitframe();
        }
    }
}