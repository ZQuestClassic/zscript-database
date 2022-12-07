//Ice Lynel - An upgraded version of the Blue Lynel that gradually grows layers of ice over it that protect it from damage and increase the power of it's sword beams. These layers of ice break when they are hit by attacks and the layers do not protect against all forms of damage. Very dangerous in groups and are very difficult to kill if you don't hit them constantly. They also become invulnerable to all weapons except what the layers of ice don't protect against (determined by Misc Attribute 8) when they have 3 or more layers.
 
//Settings
//HP, Damage, Weapon Damage, Weapon, Step speed, Random Rate, Halt Rate and Homing: Works as usual.
//Misc Attribute 1: The velocity of the sword beam, in pixels per second, being fired at the player. Defaults to 300, which is 3 pixels per frame.
//Misc Attribute 2: The SFX played when Ice Lynel puts up an ice layer. Defaults to 44, which is the default Ice SFX
//Misc Attribute 3: The amount of damage each Ice Layer adds to the Lynel's beam attack, in quarter hearts. Defaults to 4, which is 1 Heart
//Misc Attribute 4: The number of ice layers the Lynel can get. Defaults to 2. 
//Misc Attribute 5: The delay, in frames, between each time the Lynel gains an ice layer. Defaults to 120, which is 2 seconds.
//Misc Attribute 6: The number of hits it takes to remove each layer. Defaults to 2.
//Misc Attribute 7: The number of layers the Ice Lynel starts off with. Defaults to 0.
//Misc Attribute 8: The flags determining what defenses the ice layer does not defend against. By default, the ice layer does not protect against Bombs, Super Bombs, Fires, Reflected Fireballs and Script LWeapons. Look up the Misc Attr Flags and std_constants.zh for more details of which flags correspond to which defense.
//Misc Attribute 9: The base tile for the ice layer. Set this to the tile of the first ice layer.
//Misc Attribute 10: The CSet for the ice layer. Default to 7.
//Misc Attribute 11: The starting combo the Lynel uses. Must be the combo that corresponds to its up-facing sprites
//Misc Attribute 12: The number of the FFC script the Lynel uses.
 
 
 ffc script IceLynel{
        void run(int enemyID){
		
        //Initializes the enemy.
        npc ghost;
        ghost = Ghost_InitAutoGhost(this, enemyID);
                           
		//Reads the Lynel's settings
        int ShotSpeed = Ghost_GetAttribute(ghost, 0, 300);
        int IceSFX = Ghost_GetAttribute(ghost, 1, 44);
        int IceBonus = Ghost_GetAttribute(ghost, 2, 4);
        int IceLayers = Ghost_GetAttribute(ghost, 3, 2);
        int IceDelay = Ghost_GetAttribute(ghost, 4, 120);
        int IceStrikes = Ghost_GetAttribute(ghost, 5, 2);
        int IceStart = Ghost_GetAttribute(ghost, 6, 0);
        int DefenseFlags = Ghost_GetAttribute(ghost, 7, 139286);
        int IceTile = Ghost_GetAttribute(ghost, 8, 0);
        int IceCSet = Ghost_GetAttribute(ghost, 9, 7);
        
        int turnTimer = ghost->Rate * 10; //The turning timer
        int curStep = ghost->Step; //Keep the original step speed in memory.
        int layers[1] = {0}; //The number of ice layers the Lynel has. Starts off at 0.
		layers[0] = IceStart;
        int layercounter[1] = {0}; //The counter used to determine when the Lynel can add another ice layer.
        int currlayer[1] = {0}; //The counter used to keep track of the Lynel's layers.
		currlayer[0] = IceStart;
		int layerhp[1] = {0}; //The counter used to keep track of the Lynel's layer hits.
		layerhp[0] = IceStrikes;
               
        //Sets its flags.
        Ghost_SetFlag(GHF_KNOCKBACK_4WAY);
        Ghost_SetFlag(GHF_SET_DIRECTION);
		Ghost_SetFlag(GHF_4WAY);
		
		Ghost_Data = GH_INVISIBLE_COMBO; //Make the combo on the FFC invisible.
		while(true){
			turnTimer = Ghost_HaltingWalk4(turnTimer, ghost->Step, ghost->Rate, ghost->Homing, 2, ghost->Haltrate, 48); //Move the Lynel
			if(turnTimer == 16){ //Halted for 32 frames, fire an icy sword beam at the player that deals little damage (initially).
				eweapon Beam = FireNonAngularEWeapon(WeaponTypeToID(ghost->Weapon), Ghost_X, Ghost_Y, Ghost_Dir, ShotSpeed, ghost->WeaponDamage+(IceBonus*layers[0]), -1, -1, EWF_ROTATE); //Fire the EWeapon
			}
			IceLynelWaitframe(this, ghost, IceSFX, IceLayers, IceDelay, IceStrikes, DefenseFlags, IceTile, IceCSet, layers, layercounter, currlayer, layerhp, turnTimer);
		}
	}
    void IceLynelWaitframe(ffc this, npc ghost, int icesfx, int icelayers, int icedelay, int icestrikes, int defenseflags, int icetile, int icecset, int layers, int layercounter, int currlayer, int layerhp, int turnTimer){
		do{ //Handles the Ice Lynel's ice layer updates. Note that this is a do-while loop, which allows it to loop while the Ice Lynel is stunned.
			if(layers[0] > 0 && Ghost_GotHit()){ //If the Lynel is hit and has an ice layer, subtract its HP and reset the layer counter.
				layerhp[0] --;
				layercounter[0] = 0; //Reset the layer counter
			}
			if(layers[0] > 0 && layerhp[0] == 0){ //Ice Layer HP is depleted, remove a layer
				layers[0] --; //Remove an ice layer.
				layercounter[0] = 0; //Reset the layer counter
				layerhp[0] = icestrikes;
			}
			Screen->FastCombo(2, Ghost_X, Ghost_Y-2, ghost->Attributes[10]+Ghost_Dir, this->CSet, OP_OPAQUE); //Draw the Lynel to the screen first.
			if(layers[0] > 0){ //Draw the ice tile over the Lynel if it has an ice layer active
				Screen->FastTile(2, Ghost_X, Ghost_Y-2, icetile + (layers[0] - 1), icecset, OP_TRANS); //Draw the ice tile over the Lynel
			}
			IceCheck(ghost, defenseflags, currlayer, layers); //Check the ice layers
			currlayer[0] = layers[0]; //Update the layer check.
			if(ghost->Stun > 0){ //Draw the Lynel and ice layer and then place a waitframe here that only runs while the Lynel is stunned.
				Ghost_Waitframe(this, ghost, true, true);
				if(ghost->Stun <= 0){
					return;
				}
			}
		}while(ghost->Stun > 0);
		
		
		//Effects that add ice layers. Placed after the do-while loop to stop them from running while the Lynel is stunned.
		if(layers[0] < icelayers && layercounter[0] == icedelay){ //If Lynel has fewer ice layers than it can have after Attribute 3 frames, create an ice layer.
			layers[0] ++; //Add an ice layer.
			layercounter[0] = 0; //Reset the layer counter
			layerhp[0] = icestrikes;
			Game->PlaySound(icesfx);
		}
		layercounter[0] += 1; //Increment the layer counter.
		
        Ghost_Waitframe(this, ghost, true, true);
    }
    void IceCheck(npc ghost, int flags, int prevlayer, int layer){ //Checks for the ice layers
		int layerdefense = layer[0];
		if(layerdefense > 2){ //If the layers go above 2, Lynel takes no damage from anything except what the ice doesn't protect against.
			layerdefense = NPCDT_BLOCK;
		}
			
        if(prevlayer[0] != layer[0]){ //Check to see if the Lynel has just added or lost a layer
            for(int i = 0; i <= 17; i ++){ //Set all defenses except the ice does not protect against.
                if(!AttributeFlagCheck(flags, i)){ //Check to see wherever it's defense is affected in the flags or not.
                    ghost->Defense[i] = layerdefense; //Sets the defenses it doesn't skip
                }
            }
        }
    }
}
 
//These functions and constants can only be included in your script file once.
 
//Misc Attribute Flag constants.
const int MISC_ATTR_FLAG1 = 1;          //000000000000000001b
const int MISC_ATTR_FLAG2 = 2;          //000000000000000010b
const int MISC_ATTR_FLAG3 = 4;          //000000000000000100b
const int MISC_ATTR_FLAG4 = 8;          //000000000000001000b
const int MISC_ATTR_FLAG5 = 16;         //000000000000010000b
const int MISC_ATTR_FLAG6 = 32;         //000000000000100000b
const int MISC_ATTR_FLAG7 = 64;         //000000000001000000b
const int MISC_ATTR_FLAG8 = 128;        //000000000010000000b
const int MISC_ATTR_FLAG9 = 256;        //000000000100000000b
const int MISC_ATTR_FLAG10 = 512;       //000000001000000000b
const int MISC_ATTR_FLAG11 = 1024;      //000000010000000000b
const int MISC_ATTR_FLAG12 = 2048;      //000000100000000000b
const int MISC_ATTR_FLAG13 = 4096;      //000001000000000000b
const int MISC_ATTR_FLAG14 = 8192;      //000010000000000000b
const int MISC_ATTR_FLAG15 = 16384; 	//000100000000000000b
const int MISC_ATTR_FLAG16 = 32768; 	//001000000000000000b
const int MISC_ATTR_FLAG17 = 65536; 	//010000000000000000b
const int MISC_ATTR_FLAG18 = 131072;	//100000000000000000b
 
bool AttributeFlagCheck(int attribute, int flag){ //For use in for loops. Use in conjunction with misc or D variables as a shorthand way of setting flags.
    if((attribute&000000000000000001b) != 0 && flag == 0){ //1
        return true;
    }
    else if((attribute&000000000000000010b) != 0 && flag == 1){ //2
        return true;
    }
    else if((attribute&000000000000000100b) != 0 && flag == 2){ //4
        return true;
    }
    else if((attribute&000000000000001000b) != 0 && flag == 3){ //8
        return true;
    }
    else if((attribute&000000000000010000b) != 0 && flag == 4){ //16
        return true;
    }
    else if((attribute&000000000000100000b) != 0 && flag == 5){ //32
        return true;
    }
    else if((attribute&000000000001000000b) != 0 && flag == 6){ //64
        return true;
    }
    else if((attribute&000000000010000000b) != 0 && flag == 7){ //128
        return true;
    }
    else if((attribute&000000000100000000b) != 0 && flag == 8){ //256
        return true;
    }
    else if((attribute&000000001000000000b) != 0 && flag == 9){ //512
        return true;
    }
    else if((attribute&000000010000000000b) != 0 && flag == 10){ //1024
        return true;
    }
    else if((attribute&000000100000000000b) != 0 && flag == 11){ //2048
        return true;
    }
    else if((attribute&000001000000000000b) != 0 && flag == 12){ //4096
        return true;
    }
    else if((attribute&000010000000000000b) != 0 && flag == 13){ //8192
            return true;
    }
    else if((attribute&000100000000000000b) != 0 && flag == 14){ //16384
        return true;
    }
    else if((attribute&001000000000000000b) != 0 && flag == 15){ //32768
        return true;
    }
    else if((attribute&010000000000000000b) != 0 && flag == 16){ //65536
        return true;
    }
    else if((attribute&100000000000000000b) != 0 && flag == 17){ //131072
        return true;
    }
    else{
        return false;
    }
}