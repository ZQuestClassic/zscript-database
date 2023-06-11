///////////////////////////
//   Confusion Feature   //
//    meant for active   //
//    Global- or Hero-   //
//	   Scripts	 //
///////////////////////////


/////////////////////////////////////
///Constants Variables & Functions///
/////////////////////////////////////


///Constants:

const int CONFUSION_DURANCE	= 666;//11,1 seconds, by default

const int CONFUSION_CYCLE	= 222;//Duration divided by "3",so 3 State Cycles
				      //within Confusion Durance.







///Variables
//(just for Declaration,leave the following four lines untouched)

int confused;//used to call and detect the "Confusion" Effect
int confused_cnt_dwn;//used for Confusion Effect Timer

int ctrl_sw;//used to call and detect various "Confusion" States
int switch_t;//used for Confusion Cycle Timer






///Functions


void InitConfusion()
{
    ctrl_sw		= 1;
    confused		= 0;
    confused_cnt_dwn 	= CONFUSION_DURANCE;
    switch_t		= CONFUSION_CYCLE; 
}


void Confuse()//Checks the state of the variable identifier "confused"
	       //and calls the Confusion(), weird Control Cycle
	       //if "confused" is = "1"
	       //...if it is = "0" it will reset the Confusion Effect Durance

	       //The "cofused" state can be switched (activated) by Enemies, 
	       //which are using the "Confusor" NPC Script.
{
    if(confused == 1){
	Confusion();
    }
    else if(confused == 0){
	confused_cnt_dwn = CONFUSION_DURANCE;
    }
}




void Confusion()//Starts and resets the general Confusion Timer
		//"CONFUSION_DURANCE"
		//
	        //Handles 4 different Confusion Control Types
		//randomly switched after a constant cycle durance
		//"CONFUSION_CYCLE"

{
    confused_cnt_dwn --;
    if(ctrl_sw == 1){
	if(Link->InputUp){
	    Link->InputUp = false;
	    Link->InputLeft = true;
	}
	else if(Link->InputDown){
	    Link->InputDown = false;
	    Link->InputUp = true;
	}
	else if(Link->InputLeft){		
	    Link->InputLeft = false;
	    Link->InputRight = true;
	}
	else if(Link->InputRight){
	    Link->InputRight = false;
	    Link->InputDown = true;
	}
    }
    else if(ctrl_sw == 2){
	if(Link->InputUp){
	    Link->InputUp = false;
	    Link->InputRight = true;
	}
	else if(Link->InputDown){
	    Link->InputDown = false;
	    Link->InputLeft = true;
	}
	else if(Link->InputLeft){		
	    Link->InputLeft = false;
	    Link->InputDown = true;
	}
	else if(Link->InputRight){
	    Link->InputRight = false;
	    Link->InputUp = true;
	}
    }
    else if(ctrl_sw == 3){
	if(Link->InputUp){
	    Link->InputUp = false;
	    Link->InputDown = true;
	}
	else if(Link->InputDown){
	    Link->InputDown = false;
	    Link->InputUp = true;
	}
	else if(Link->InputLeft){		
	    Link->InputLeft = false;
	    Link->InputRight = true;
	}
	else if(Link->InputRight){
	    Link->InputRight = false;
	    Link->InputLeft = true;
	}
    }
    else if(ctrl_sw == 4){
	if(Link->InputUp){
	    Link->InputUp = false;
	    Link->InputLeft = true;
	}
	else if(Link->InputDown){
	    Link->InputDown = false;
	    Link->InputRight = true;
	}
	else if(Link->InputLeft){		
	    Link->InputLeft = false;
	    Link->InputUp = true;
	}
	else if(Link->InputRight){
	    Link->InputRight = false;
	    Link->InputDown = true;
	}
    }
    if(confused_cnt_dwn == 0){confused = 0;}
}



void UpdateConfusion()//This Function starts and resets the Confusion Cycle
		      //Timer, to switch Confusion States
		      //
		      //The number of (random) Cycles depends on the Cycle Duration
		      //and general Confusion -Duration.
		      //Short cycles, long duration = many cycles
		      //by default it three "222" frame cycles, within a "666" frame
		      //(11,1 sec) Confusion Effect Length

{
    if(confused == 1){   
	switch_t --;
        if(switch_t == 0){ 
            ctrl_sw += Rand(3);
	    if(ctrl_sw > 4){ctrl_sw = 1;}
	    switch_t = CONFUSION_CYCLE;
	}
    }
    else if(confused == 0){switch_t = CONFUSION_CYCLE; ctrl_sw = 1;}
}



void StunEnemies(int stun_dur)

// This Shortcut "StunEnemies(stun_dur)" will allow you
// to stun all Screen Enemies for a certain 
// time.
//
// It's more or less "extracted" from "Moosh Pit"
// ...but with a double-secure duration

{
	if(stun_dur == 0){stun_dur = 1;} 
	for(int i=Screen->NumNPCs(); i>=1; i--){
		npc n = Screen->LoadNPC(i);
		n->Stun = Max(n->Stun, stun_dur);

		//"stun_dur" is the stun effect duration, in frames
	}
}



//////////////
// Scripts  //
//////////////



///ENEMY////


npc script Confusor

// Add to Engine/Custom Enemies to create
// NPCs that will confuse (weird direct inputs) the Hero
// on Collision.
//
// by default, it's 3 Control Cycles, within a 11,1 seconds Effect Duration
//
// !!! REQUIRES HERO-,OR GLOBAL SCRIPT INTERACTION
// (I'd suggest Hero Scripts, to prevent issues with other Global Functions)
//
// Add "InitConfusion()" within the void run before while(true),
// "Confuse();" within in the while(true) loop, before the Waitdraw();
// and "UpdateConfusion();" after the Waitdraw(); of your active global-
// or hero Script, to intercact with this NPPC Script.
//


//D0 = Confusion SFX ID
//D1 = ID of an Item (can be passive, custom, dummy) used for permanent Confusion Protection
//D2 = "You are confused" String X Position
//D3 = "You are confused" String Y Position (use negative (-) Values, to display the String above the Passive Subscreen)
//D4 = "You are confused" Color
//D5 = "You are confused" String Display Duration

{
    void run(int sfx, int protector, int str_x, int str_y, int str_color, int string_dur)
    {
	int t = string_dur;
	int str = 1;//used to check the DrawString state.
		    //leave untouched


	if(confused == 0){str = 0;}
	if(Link->Item[protector]){Quit();}
	while(this->isValid()){
            if((Collision(this) && Hero->HitDir > -1) && confused == 0){
		if(Link->Action == LA_GOTHURTLAND){
		    confused = 1;
		    Audio->PlaySound(sfx);
		}
	    }
	    if(str == 2){
		Screen->DrawString(7, str_x, str_y, FONT_GAIA, str_color, 12, 60, "You are confused", 128);
									//Insert your Confusion Report String between the ""//
	    }
	    Waitdraw();
	    if(confused == 0){str = 0;}
	    else if(confused == 1 && str == 0){
		str = 2;
	    }
	    if(str == 2){
	        t--;
	        if(t < 1){t = string_dur; str = 1;}
	    }
	    Waitframe();
	}
    }
}



////Heal Item////


itemdata script ConfusionHeal

//
//
// will cure the confusion effect
// play a heal SFX and a "You've been healed" Message
// and decrease an assigned counter's value, by 1.
//
// if the counter value is lower than 1, the item removes itself
//
//
//Make the item pickup increasing the assigned counter (till a chosen max)
//Like Increase Max = 8, But Not Above 8)
//...and also let it increase the value).
//
// I'd suggest to use an item of class "zz..."
// ...don't worry,it can still use the chosen Counter, by this Script
//
//....the chosen counter should not show zero.
// Cause the Item instantly removes itself, when the Counter value is "0"
// ... and so it would leave a senseless Counter, showing "0" 
//
//
// you can also assign an individual protector item, in the variables
// of each scripted Confusor NPC   ...to permanently protect Link
// from the confusing effect, of that certain NPC.
//


{
    void run(int sfx, int msg)
    {
        const int CTR_CONFUSION_CURE = 7;//ID value of your chosen Counter
					 //Scripted/Custom Item Counter 1
					 //"CR_SCRIPT1", by default.

        int itm = this->ID;
        Audio->PlaySound(sfx);
        StunEnemies(12);
        confused = 0;
        WaitNoAction(3);
        Screen->Message(msg);
        Game->Counter[CTR_CONFUSION_CURE] -=1;
        StunEnemies(12);
        WaitNoAction(12);
        if(Game->Counter[CTR_CONFUSION_CURE] < 1){
            Link->Item[itm] = false;
            Waitframes(4);
            return;
        }
    }
}




/// Example Scripts /// Hero /// Global

//add the floowing contained function lines (from the top of this file)
// either to your active global or your active hero script.

// both will return same results, so decide on your own
//
// I tend to use player specific things like these in hero scripts
//...and to use global scripts only for general quest physics.



hero script HeroConfuse
{
    void run()
    {
	InitConfusion();

	while(true){

	    Confuse();

	    Waitdraw();
	    
	    UpdateConfusion();
	    
	    Waitframe();
	}
    }
}




global script GlobalConfuse
{
    void run()
    {
	InitConfusion();

	while(true){

	    Confuse();

	    Waitdraw();
	    
	    UpdateConfusion();
	    
	    Waitframe();
	}
    }
}


//have much fun//