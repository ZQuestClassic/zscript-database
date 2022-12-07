import "std.zh"

//FIREBALL SHOOTER TRAP BY DEMONLINK
//A trap that fires a fireball towards your current position when you attack with an item (candle, bow, wand, etcetera).
//D0 is the value for a custom SFX. If it's 0, it will play the SFX_FIREBALL sound.
//D1 is the damage done in quarters of a heart. If the value is 0, it will deal one whole heart of damage.

ffc script fireball_shooter_trap{
     void run(int custom_SFX, int damage){
          while(true){
               if(Link->Action == LA_ATTACKING){                                        //If Link is attacking... (candle, wand, sword, etc.)
                    eweapon fireball = CreateEWeaponAt(EW_FIREBALL, this->X, this->Y);  //Create an enemy weapon named "Fireball" at the FFC's X and Y position.
                    if (custom_SFX == 0){                                               //If custom_SFX is equal to 0 (in this case, D0)...
                         Game->PlaySound(SFX_FIREBALL);                                 //Play the sfx SFX_FIREBALL
                    }
                    else{                                                               //Else if D0 is something different...
                         Game->PlaySound(custom_SFX);                                   //Play the custom sfx ID
                    }
                    if (damage == 0){                                                   //If damage is equal to 0 (in this case, D1)...
                         fireball->Damage = 4;                                          //The damage of the Fireball is one heart (4/4ths)
                    }
                    else{                                                               //Else if D1 is something different...
                         fireball->Damage = damage;                                     //The damage done by the Fireball is the value of D1
                    }
                    //The next lines define the angle to shoot the Fireball towards. (Credits to LinktheMaster's FFC shooter script)
                    fireball->Angular = true;
		    fireball->Angle = RadianAngle(this->X + this->EffectWidth/2 - 8, this->Y + this->EffectHeight/2 - 8, Link->X+8, Link->Y+8);
             	    fireball->Dir = RadianAngleDir8(fireball->Angle);
                    while(Link->Action == LA_ATTACKING){                                //Wait one frame while Link is attacking (Credits to MoscowModder for this fix).
                         Waitframe();
                    }
                }
          Waitframe();                                                                  //ALWAYS put a Waitframe(); in your loop, or quest freezes!!.
          }                                                                             //End of the Loop
     }                                                                                  //End of the Void Run
}                                                                                       //End of the FFC script


//CONSTANT FIREBALL SHOOTER TRAP BY DEMONLINK
//A trap that fires constant fireballs towards your current position when you attack with an item (candle, bow, wand, etcetera).
//D0 is the value for a custom SFX. If it's 0, it will play the SFX_FIREBALL sound.
//D1 is the damage done in quarters of a heart. If the value is 0, it will deal one whole heart of damage.
//D2 is the number of Fireballs you want to be shot. If the value is 0, it will shoot 5 fireballs.
//D3 are the frames to wait (or frequency) until the next fireball is shot. If left on 0, the default is 20 frames. 

ffc script fireball_shooter_trap_constant{
     void run(int custom_SFX, int damage, int Fireball_Counter, int frequency_frames){
          while(true){       
               if(Link->Action == LA_ATTACKING){
                    if(Fireball_Counter == 0){
                         for (int i = 0; i < 5; i++){
                              eweapon fireball = CreateEWeaponAt(EW_FIREBALL, this->X, this->Y);
                              if (custom_SFX == 0){
                                   Game->PlaySound(SFX_FIREBALL);
                              }
                              else{
                                   Game->PlaySound(custom_SFX);
                              }
                              if (damage == 0){ 
                                   fireball->Damage = 4;
                              }
                              else{
                                   fireball->Damage = damage;
                              }
                              fireball->Angular = true;
		              fireball->Angle = RadianAngle(this->X + this->EffectWidth/2 - 8, this->Y + this->EffectHeight/2 - 8, Link->X+8, Link->Y+8);
             	              fireball->Dir = RadianAngleDir8(fireball->Angle);
                              if(frequency_frames == 0){
                                   Waitframes(20);
                              }
                              else{
                                   Waitframes(frequency_frames);
                              }
                         }
                         while(Link->Action == LA_ATTACKING){          
                              Waitframe();
                         }
                    }
                    else{
                         for (int i = 0; i < Fireball_Counter; i++){
                              eweapon fireball = CreateEWeaponAt(EW_FIREBALL, this->X, this->Y);
                              if (custom_SFX == 0){
                                   Game->PlaySound(SFX_FIREBALL);
                              }
                              else{
                                   Game->PlaySound(custom_SFX);
                              }
                              if (damage == 0){ 
                                   fireball->Damage = 4;
                              }
                              else{
                                   fireball->Damage = damage;
                              }
                              fireball->Angular = true;
		              fireball->Angle = RadianAngle(this->X + this->EffectWidth/2 - 8, this->Y + this->EffectHeight/2 - 8, Link->X+8, Link->Y+8);
             	              fireball->Dir = RadianAngleDir8(fireball->Angle);
                              if(frequency_frames == 0){
                                   Waitframes(20);
                              }
                              else{
                                   Waitframes(frequency_frames);
                              }
                         }
                         while(Link->Action == LA_ATTACKING){          
                              Waitframe();
                         }
                    }          
               }
          Waitframe();
          }
     }
}