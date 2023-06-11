/////////////////////
/// Bolt! Spell /////
//////////////////////////////////////////////////////////////////////////////////////////////
/// This item creates a flash on the screen, with a thundering sound, dealing damage to all //
/// enemies on the screen, while launching a projectile (lightning bolt) toward one target. //
//////////////////////////////////////////////////////////////////////////////////////////////
// D0: Damage to deal                                                                       //
// D1: Sprite to use for this item. Set in:                                                 //
//           Quest->Graphics->Sprites->Weapons/Misc.                                        //
// D2: Amount of MP to expend when using item.                                              //
// D3: Step Speed of the Projectile.                                                        //
// D4: Set this to the FFC slot number to which you assign the FlashScreen FFC script.      //
// D5: Colour of Flash (suggest 1).                                                         //
// D6: Duration of Flash (suggest 45)                                                       //
// D7: Screen-Wide Damage to Deal during Flash.                                             //
//////////////////////////////////////////////////////////////////////////////////////////////

const int BOLT_NOUSE = 0; //Set to the amount of time in frames that you wish to have as a delay between uses of this item.
const int ThunderSFX = 0; //Set to the sound in Quest->Audio->SFX Data to the sound you wish to use as a thunder effct (.wav option included in this package)
const int SFX_ERROR = 0; //Set to your global error sound effect, or any specific error SFX you wish from Quest->Audio->SFX Data.

item script BoltSpell{
    void run(int power, int arrowSprite, int magicCost, int speed, int Script_ID, int colour, int duration, int screenDamage){
	 if (Game->Counter[CR_MAGIC] >= magicCost) //Fill in the numbers for magic consumption and number of projectiles allowed on screen
        {
	 Screen->Wavy = 10; //Makes the screen waver slightly while screen flashes and bolt projectile emits.
	 Game->Counter[CR_MAGIC] -= magicCost; //Sets the MP cost for using the weapon.
	 int args[8] = {colour, duration}; //Sets the colour and duration of the flash in the FFC script.
 npc enemys; //Reads the enemies on screen...
   for(int i = 1; i<=Screen->NumNPCs(); i++) //Find out how many enemies are onscreen.
         {
         enemys = Screen->LoadNPC(i); //Targets those enemies.
         enemys->HP-=screenDamage; //Deals (value of D7) damage to all enemies on-screen during flash.
         }
        
	
		int startX; //the starting position of the LWeapon sprite (X-axis)
        int startY; //the starting position of the LWeapon sprite (Y-axis)
        int startHP = Link->HP; //Needed if you want to include an HP requirement.
        lweapon bolt; //Creates the LWeapon
        Game->PlaySound(ThunderSFX); //Makes the thunder SFX play.
        startX = Link->X+8; //Sets starting position of LWeapon based on Link's position (+8 pixels)
        startY = Link->Y+8; //Sets starting position of LWeapon based on Link's position (+8 pixels)
        Link->Action = LA_ATTACKING; //Produces Link attacking animation. 
        bolt = NextToLink(LW_ARROW, 8);  //Create in front of Link.
        bolt->UseSprite(arrowSprite); //Sets the sprite to use from Weapons->Misc.
        bolt->Damage = power; //Sets the damage of the projectile.
        bolt->Step = speed; //Sets the Step Speed of the projectile, suggest 200-240.
		RunFFCScript(Script_ID, args); //Runs the FFC script that makes the screen flash.
		Link->ItemJinx = BOLT_NOUSE;
		}
		else{
    Game->PlaySound(SFX_ERROR); //If out of MP, play ERROR Sound Effects.
    }
    }
}



//
ffc script FlashScreen{
    void run(int colour, int duration){
	
        while(duration > 0){
            if(duration % 2 == 0) Screen->Rectangle(6, 0, 0, 256, 172, colour, 1, 0, 0, 0, true, 64);
            duration--;
            Waitframe();
        }
    }
}