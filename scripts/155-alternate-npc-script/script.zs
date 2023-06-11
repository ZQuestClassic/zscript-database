const int CMB_AUTOWARPD = 0; //Only include this once in the script file. Set to the number of an Autowarp-type combo you create, preferably transparent.

// FFC script for talking NPCs with different functions
// It's pretty much a sign you can approach from any side.
// d0: String number to be displayed
// D1: Set to anything other than zero. Tells the ffc that this NPC has more than one message. Use string control codes to determine what message to display. Use \3\x\y\z at the beginning of your string where X is Zero, Y is one and Z is the string to switch to.
// D2: If you want the NPC to warp you to another screen after you talk to it. Set to anything other than zero to activate. Uses Sidewarp D to set destination.
// D3: If you want the NPC to heal you fully after you talk to it. Set to anything other than zero to activate.
// D4: The counter to check for amount listed in D5. If requirements are met, screen secrets are triggered. Check std_constants for countertypes.
// D5: Used to test in-game counters. Can be used for collectibles, either existing or created. Set to Zero if this NPC doesn't require certain items.

ffc script altnpcscript
{
    void run(int message, int differentmessage, int warpoccurs, int healoccurs, int countertype, int amount)
    {
	// So that people don't have to be pixel perfect on placing npcs.
	this->X = Round(this->X / 8) * 8;
	this->Y = Round(this->Y / 8) * 8;
				
        while(true)
        {
		// Set up some values to make the if statement smaller.
		int LinkX = Link->X + 8;
		int LinkY = Link->Y + 8;
			
		int thisX = Round(this->X / 8) * 8;
		int thisY = Round(this->Y / 8) * 8;
			
		int centerX = thisX + this->EffectWidth / 2;
		int centerY = thisY + this->EffectHeight / 2;
			
		// If Link is on one of the sides of the NPC and facing it
		if( 
		    ((Abs(LinkX - centerX) < this->EffectWidth / 2 && Abs(LinkY - centerY) <= this->EffectHeight / 2 + 12 && LinkY < centerY && Link->Dir == DIR_DOWN) ||
		    (Abs(LinkX - centerX) < this->EffectWidth / 2 && Abs(LinkY - centerY) <= this->EffectHeight / 2 + 4 && LinkY > centerY && Link->Dir == DIR_UP) ||
		    (Abs(LinkY + 3 - centerY) < this->EffectHeight / 2 && Abs(LinkX - centerX) <= this->EffectWidth / 2 + 12 && LinkX < centerX && Link->Dir == DIR_RIGHT) ||
		    (Abs(LinkY + 3- centerY) < this->EffectHeight / 2 && Abs(LinkX - centerX) <= this->EffectWidth / 2 + 12 && LinkX > centerX && Link->Dir == DIR_LEFT)))
		    {
                    // If the player talks to the NPC. Automatically uses L to reduce arguments on NPCs. can be changed to the button of your choice.
		    if(Link->InputL)
		        {
                        // Show the message
                        int perm;//A variable which will be zero until you speak with the NPC.
                        //If this NPC says more than one thing, this code runs. 
                        if(differentmessage !=0 && Screen->D[perm] == 1){
                            Screen->Message(message);
                            //Check to see if you've spoken to this NPC and it wants a certain # of items.
                            if ( Game->Counter[countertype] >= amount && Screen->State[ST_SECRET] == false && Screen->D[perm] == 1  && amount != 0) {
                                Game->PlaySound(27);
                                Screen->TriggerSecrets();
                                Screen->State[ST_SECRET] = true;
                            }
                            //Heals Link if this NPC does that.
                            if(healoccurs != 0){
                                Link->HP = Link->MaxHP;
                                Link->MP = Link->MaxMP;
                            }
                            //Warps Link if this NPC does that.
                            if(warpoccurs != 0){
                                Waitframe();
                                this->Data = CMB_AUTOWARPD;
		            }
                        }
                        //All other NPC functions.
                        else{
                            Screen->Message(message);
                            if (Screen->D[perm]){
                                return;
                            }
                            else{
                                Waitframe();
                                Screen->D[perm] = 1;
                            }
                            //Heals Link if this NPC does that.
                            if(healoccurs != 0){
                                Link->HP = Link->MaxHP;
                                Link->MP = Link->MaxMP;
                            }
                            //Warps Link if this NPC does that.
                            if(warpoccurs != 0){
                                Waitframe();
                                this->Data = CMB_AUTOWARPD;
		            }
                        }
		     // Wait a bit before letting the npc trigger again.
		     Waitframes(30);
                     } // End of if Link triggered npc
                 } // End of Link positioning
		 Waitframe();   
            } // End of while(true)
    } // End of void run(int message)
} // End of ffc script altnpcscript