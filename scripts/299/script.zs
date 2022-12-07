//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

//Simulates beams of light which are reflected by mirrors, including the Mirror Shield.                                                     //

//D0: Combo number to use on transparent layer to simulate Light.                                                                           //

//D1: Layer to place light combos on. Should be a transparent layer.                                                                        //

//D2: Set to how many tiles from the edge of the screen should be immune to light (EX: if set to 1, light will not hit the screen edge.     //

//D3: Set to 1 if you want the light to stop when it hits a solid, or 0 to pass through solids.                                             //

//D4: Set to 1 if you want the light to be a beam of light from the side rather than from the ceiling.                                      //

//D5: If D4 is set to 1, this is the direction it will travel. 0=up, 1=down, 2=left, 3=right.                                               //

// AUTHOR: Emily                                                  //                                               VERSION: 1.0 (1/28/2018) //

//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

const int LIGHT_TRANSPARENT = 1;//Combo number for transparent combo.

const int LIGHT_COMBO = 0;//Combo number for light on a transparent layer, default. Overridden by the D0 value if it is not 0.

const int LIGHT_LAYER = 5;//Default layer number. Should not ever be 0.

const int LIGHT_MAX_CONSEC = 25; //Max repeats in a row before the script gives up. If you find your light beams ending prematurely, increase this number.

//It should be as low as possible without interfering with your puzzle, as higher numbers increase lag. Too large a number can crash the script.

const int LIGHT_DRmirror = 0; //Combo number for mirror that reflects between Down and Right

const int LIGHT_DLmirror = 0; //Combo number for mirror that reflects between Down and Left

const int LIGHT_URmirror = 0; //Combo number for mirror that reflects between Up and Right

const int LIGHT_ULmirror = 0; //Combo number for mirror that reflects between Up and Left

const int LIGHT_StrMIRROR = 0; //Combo number for mirror that reflects back in any direction

const int LIGHT_4WayPrism = 0; //Combo number for prism that reflects in 4 directions

const int LIGHT_3WayPrism = 0; //Combo number for prism that reflects in 3 directions

const int LIGHT_GLASS = 0; //Combo number for a solid combo light should be allowed to pass through regardless of D3's value.

ffc script lightPuzzle{

	void run(int lightCombo, int lightLayer, int screenEdge, bool stopSolid, bool isBeam, int dirBeam){

		if(lightLayer==0)lightLayer=LIGHT_LAYER;

		if(lightCombo==0)lightCombo=LIGHT_COMBO;

		int thisCombo = ComboAt(this->X+8,this->Y+8);

		SetLayerComboD(lightLayer, thisCombo, lightCombo);

		while(!isBeam){

			ClearLight(lightLayer,thisCombo);

			if(Link->Item[I_SHIELD3] && ComboAt(Link->X+8,Link->Y+8)==thisCombo){

				DrawLight(Link->Dir, lightCombo, lightLayer, screenEdge, thisCombo, stopSolid, 0);

			}

			Waitframe();

		}

		while(isBeam){

			ClearLight(lightLayer,thisCombo);

			DrawLightBeam(dirBeam,lightCombo,lightLayer,screenEdge,thisCombo,stopSolid, 0);

			Waitframe();

		}

	}

	

	void ClearLight(int lightLayer, int ffcCombo){

		for(int i = 0 ; i <= 175 ; i++){

			if(i!=ffcCombo){SetLayerComboD(lightLayer, i, LIGHT_TRANSPARENT);}

		}

	}

	

	//start DrawLight

	void DrawLight(int dir, int combo, int layer, int edge, int thisCombo, bool stopSolid, int consec){

		bool first = true;

		if(dir==0){

			for(int i = thisCombo;i>=(edge*16);i-=16){

				if(GetLayerComboD(layer,i)==combo){consec++;}else{consec=0;}

				if(consec>LIGHT_MAX_CONSEC)break;

				SetLayerComboD(layer, i, combo);

				if(!first){

					if(Screen->ComboD[i]==LIGHT_DRmirror){

						DrawLight(DIR_RIGHT, combo, layer, edge, i, stopSolid, consec);

						break;

					} else if(Screen->ComboD[i]==LIGHT_DLmirror){

						DrawLight(DIR_LEFT, combo, layer, edge, i, stopSolid, consec);

						break;

					} else if(Screen->ComboD[i]==LIGHT_StrMIRROR){

						DrawLight(DIR_DOWN, combo, layer, edge, i, stopSolid, consec);

						break;

					} else if(Screen->ComboD[i]==LIGHT_3WayPrism){

						DrawLight(DIR_UP, combo, layer, edge, i, stopSolid, consec);

						DrawLight(DIR_LEFT, combo, layer, edge, i, stopSolid, consec);

						DrawLight(DIR_RIGHT, combo, layer, edge, i, stopSolid, consec);

						break;

					} else if(Screen->ComboD[i]==LIGHT_4WayPrism){

						DrawLight(DIR_UP, combo, layer, edge, i, stopSolid, consec);

						DrawLight(DIR_DOWN, combo, layer, edge, i, stopSolid, consec);

						DrawLight(DIR_LEFT, combo, layer, edge, i, stopSolid, consec);

						DrawLight(DIR_RIGHT, combo, layer, edge, i, stopSolid, consec);

						break;

					}

					if(stopSolid && Screen->ComboS[i]>0 && Screen->ComboD[i]!=LIGHT_GLASS)break;

				}

				first = false;

			}

		} else if(dir==1){

			for(int i = thisCombo;i<=(175-(edge*16));i+=16){

				if(GetLayerComboD(layer,i)==combo){consec++;}else{consec=0;}

				if(consec>LIGHT_MAX_CONSEC)break;

				SetLayerComboD(layer, i, combo);

				if(!first){

					if(Screen->ComboD[i]==LIGHT_URmirror){

						DrawLight(DIR_RIGHT, combo, layer, edge, i, stopSolid, consec);

						break;

					} else if(Screen->ComboD[i]==LIGHT_ULmirror){

						DrawLight(DIR_LEFT, combo, layer, edge, i, stopSolid, consec);

						break;

					} else if(Screen->ComboD[i]==LIGHT_StrMIRROR){

						DrawLight(DIR_UP, combo, layer, edge, i, stopSolid, consec);

						break;

					} else if(Screen->ComboD[i]==LIGHT_3WayPrism){

						DrawLight(DIR_DOWN, combo, layer, edge, i, stopSolid, consec);

						DrawLight(DIR_LEFT, combo, layer, edge, i, stopSolid, consec);

						DrawLight(DIR_RIGHT, combo, layer, edge, i, stopSolid, consec);

						break;

					} else if(Screen->ComboD[i]==LIGHT_4WayPrism){

						DrawLight(DIR_UP, combo, layer, edge, i, stopSolid, consec);

						DrawLight(DIR_DOWN, combo, layer, edge, i, stopSolid, consec);

						DrawLight(DIR_LEFT, combo, layer, edge, i, stopSolid, consec);

						DrawLight(DIR_RIGHT, combo, layer, edge, i, stopSolid, consec);

						break;

					}

					if(stopSolid && Screen->ComboS[i]>0 && Screen->ComboD[i]!=LIGHT_GLASS)break;

				}

				first = false;

			}

		} else if(dir==2){

			for(int i = thisCombo;i>=(edge+thisCombo-(thisCombo%16));i--){

				if(GetLayerComboD(layer,i)==combo){consec++;}else{consec=0;}

				if(consec>LIGHT_MAX_CONSEC)break;

				SetLayerComboD(layer, i, combo);

				if(!first){

					if(Screen->ComboD[i]==LIGHT_URmirror){

						DrawLight(DIR_UP, combo, layer, edge, i, stopSolid, consec);

						break;

					} else if(Screen->ComboD[i]==LIGHT_DRmirror){

						DrawLight(DIR_DOWN, combo, layer, edge, i, stopSolid, consec);

						break;

					} else if(Screen->ComboD[i]==LIGHT_StrMIRROR){

						DrawLight(DIR_RIGHT, combo, layer, edge, i, stopSolid, consec);

						break;

					} else if(Screen->ComboD[i]==LIGHT_3WayPrism){

						DrawLight(DIR_DOWN, combo, layer, edge, i, stopSolid, consec);

						DrawLight(DIR_UP, combo, layer, edge, i, stopSolid, consec);

						DrawLight(DIR_LEFT, combo, layer, edge, i, stopSolid, consec);

						break;

					} else if(Screen->ComboD[i]==LIGHT_4WayPrism){

						DrawLight(DIR_UP, combo, layer, edge, i, stopSolid, consec);

						DrawLight(DIR_DOWN, combo, layer, edge, i, stopSolid, consec);

						DrawLight(DIR_LEFT, combo, layer, edge, i, stopSolid, consec);

						DrawLight(DIR_RIGHT, combo, layer, edge, i, stopSolid, consec);

						break;

					}

					if(stopSolid && Screen->ComboS[i]>0 && Screen->ComboD[i]!=LIGHT_GLASS)break;

				}

				first = false;

			}

		} else if(dir==3){

			for(int i = thisCombo;i<=(15-edge+thisCombo-(thisCombo%16));i++){

				if(GetLayerComboD(layer,i)==combo){consec++;}else{consec=0;}

				if(consec>LIGHT_MAX_CONSEC)break;

				SetLayerComboD(layer, i, combo);

				if(!first){

					if(Screen->ComboD[i]==LIGHT_ULmirror){

						DrawLight(DIR_UP, combo, layer, edge, i, stopSolid, consec);

						break;

					} else if(Screen->ComboD[i]==LIGHT_DLmirror){

						DrawLight(DIR_DOWN, combo, layer, edge, i, stopSolid, consec);

						break;

					} else if(Screen->ComboD[i]==LIGHT_StrMIRROR){

						DrawLight(DIR_LEFT, combo, layer, edge, i, stopSolid, consec);

						break;

					} else if(Screen->ComboD[i]==LIGHT_3WayPrism){

						DrawLight(DIR_DOWN, combo, layer, edge, i, stopSolid, consec);

						DrawLight(DIR_RIGHT, combo, layer, edge, i, stopSolid, consec);

						DrawLight(DIR_UP, combo, layer, edge, i, stopSolid, consec);

						break;

					} else if(Screen->ComboD[i]==LIGHT_4WayPrism){

						DrawLight(DIR_UP, combo, layer, edge, i, stopSolid, consec);

						DrawLight(DIR_DOWN, combo, layer, edge, i, stopSolid, consec);

						DrawLight(DIR_LEFT, combo, layer, edge, i, stopSolid, consec);

						DrawLight(DIR_RIGHT, combo, layer, edge, i, stopSolid, consec);

						break;

					}

					if(stopSolid && Screen->ComboS[i]>0 && Screen->ComboD[i]!=LIGHT_GLASS)break;

				}

				first = false;

			}

		}

	}

	//end DrawLight

	//start DrawLightBeam

	void DrawLightBeam(int dir, int combo, int layer, int edge, int thisCombo, bool stopSolid, int consec){

		bool first = true;

		int linkAt = ComboAt(Link->X+8,Link->Y+8);

		if(dir==0){

			for(int i = thisCombo;i>=(edge*16);i-=16){

				if(GetLayerComboD(layer,i)==combo){consec++;}else{consec=0;}

				if(consec>LIGHT_MAX_CONSEC)break;

				SetLayerComboD(layer, i, combo);

				if(Link->Item[I_SHIELD3] && i == linkAt){

					DrawLight(Link->Dir, combo, layer, edge, i, stopSolid, consec);

					break;

				}

				if(!first){

					if(Screen->ComboD[i]==LIGHT_DRmirror){

						DrawLightBeam(DIR_RIGHT, combo, layer, edge, i, stopSolid, consec);

						break;

					} else if(Screen->ComboD[i]==LIGHT_DLmirror){

						DrawLightBeam(DIR_LEFT, combo, layer, edge, i, stopSolid, consec);

						break;

					} else if(Screen->ComboD[i]==LIGHT_StrMIRROR){

						DrawLightBeam(DIR_DOWN, combo, layer, edge, i, stopSolid, consec);

						break;

					} else if(Screen->ComboD[i]==LIGHT_3WayPrism){

						DrawLightBeam(DIR_UP, combo, layer, edge, i, stopSolid, consec);

						DrawLightBeam(DIR_LEFT, combo, layer, edge, i, stopSolid, consec);

						DrawLightBeam(DIR_RIGHT, combo, layer, edge, i, stopSolid, consec);

						break;

					} else if(Screen->ComboD[i]==LIGHT_4WayPrism){

						DrawLightBeam(DIR_UP, combo, layer, edge, i, stopSolid, consec);

						DrawLightBeam(DIR_DOWN, combo, layer, edge, i, stopSolid, consec);

						DrawLightBeam(DIR_LEFT, combo, layer, edge, i, stopSolid, consec);

						DrawLightBeam(DIR_RIGHT, combo, layer, edge, i, stopSolid, consec);

						break;

					}

					if(stopSolid && Screen->ComboS[i]>0 && Screen->ComboD[i]!=LIGHT_GLASS)break;

				}

				first = false;

			}

		} else if(dir==1){

			for(int i = thisCombo;i<=(175-(edge*16));i+=16){

				if(GetLayerComboD(layer,i)==combo){consec++;}else{consec=0;}

				if(consec>LIGHT_MAX_CONSEC)break;

				SetLayerComboD(layer, i, combo);

				if(Link->Item[I_SHIELD3] && i == linkAt){

					DrawLight(Link->Dir, combo, layer, edge, i, stopSolid, consec);

					break;

				}

				if(!first){

					if(Screen->ComboD[i]==LIGHT_URmirror){

						DrawLightBeam(DIR_RIGHT, combo, layer, edge, i, stopSolid, consec);

						break;

					} else if(Screen->ComboD[i]==LIGHT_ULmirror){

						DrawLightBeam(DIR_LEFT, combo, layer, edge, i, stopSolid, consec);

						break;

					} else if(Screen->ComboD[i]==LIGHT_StrMIRROR){

						DrawLightBeam(DIR_UP, combo, layer, edge, i, stopSolid, consec);

						break;

					} else if(Screen->ComboD[i]==LIGHT_3WayPrism){

						DrawLightBeam(DIR_DOWN, combo, layer, edge, i, stopSolid, consec);

						DrawLightBeam(DIR_LEFT, combo, layer, edge, i, stopSolid, consec);

						DrawLightBeam(DIR_RIGHT, combo, layer, edge, i, stopSolid, consec);

						break;

					} else if(Screen->ComboD[i]==LIGHT_4WayPrism){

						DrawLightBeam(DIR_UP, combo, layer, edge, i, stopSolid, consec);

						DrawLightBeam(DIR_DOWN, combo, layer, edge, i, stopSolid, consec);

						DrawLightBeam(DIR_LEFT, combo, layer, edge, i, stopSolid, consec);

						DrawLightBeam(DIR_RIGHT, combo, layer, edge, i, stopSolid, consec);

						break;

					}

					if(stopSolid && Screen->ComboS[i]>0 && Screen->ComboD[i]!=LIGHT_GLASS)break;

				}

				first = false;

			}

		} else if(dir==2){

			for(int i = thisCombo;i>=(edge+thisCombo-(thisCombo%16));i--){

				if(GetLayerComboD(layer,i)==combo){consec++;}else{consec=0;}

				if(consec>LIGHT_MAX_CONSEC)break;

				SetLayerComboD(layer, i, combo);

				if(Link->Item[I_SHIELD3] && i == linkAt){

					DrawLight(Link->Dir, combo, layer, edge, i, stopSolid, consec);

					break;

				}

				if(!first){

					if(Screen->ComboD[i]==LIGHT_URmirror){

						DrawLightBeam(DIR_UP, combo, layer, edge, i, stopSolid, consec);

						break;

					} else if(Screen->ComboD[i]==LIGHT_DRmirror){

						DrawLightBeam(DIR_DOWN, combo, layer, edge, i, stopSolid, consec);

						break;

					} else if(Screen->ComboD[i]==LIGHT_StrMIRROR){

						DrawLightBeam(DIR_RIGHT, combo, layer, edge, i, stopSolid, consec);

						break;

					} else if(Screen->ComboD[i]==LIGHT_3WayPrism){

						DrawLightBeam(DIR_DOWN, combo, layer, edge, i, stopSolid, consec);

						DrawLightBeam(DIR_UP, combo, layer, edge, i, stopSolid, consec);

						DrawLightBeam(DIR_LEFT, combo, layer, edge, i, stopSolid, consec);

						break;

					} else if(Screen->ComboD[i]==LIGHT_4WayPrism){

						DrawLightBeam(DIR_UP, combo, layer, edge, i, stopSolid, consec);

						DrawLightBeam(DIR_DOWN, combo, layer, edge, i, stopSolid, consec);

						DrawLightBeam(DIR_LEFT, combo, layer, edge, i, stopSolid, consec);

						DrawLightBeam(DIR_RIGHT, combo, layer, edge, i, stopSolid, consec);

						break;

					}

					if(stopSolid && Screen->ComboS[i]>0 && Screen->ComboD[i]!=LIGHT_GLASS)break;

				}

				first = false;

			}

		} else if(dir==3){

			for(int i = thisCombo;i<=(15-edge+thisCombo-(thisCombo%16));i++){

				if(GetLayerComboD(layer,i)==combo){consec++;}else{consec=0;}

				if(consec>LIGHT_MAX_CONSEC)break;

				SetLayerComboD(layer, i, combo);

				if(Link->Item[I_SHIELD3] && i == linkAt){

					DrawLight(Link->Dir, combo, layer, edge, i, stopSolid, consec);

					break;

				}

				if(!first){

					if(Screen->ComboD[i]==LIGHT_ULmirror){

						DrawLightBeam(DIR_UP, combo, layer, edge, i, stopSolid, consec);

						break;

					} else if(Screen->ComboD[i]==LIGHT_DLmirror){

						DrawLightBeam(DIR_DOWN, combo, layer, edge, i, stopSolid, consec);

						break;

					} else if(Screen->ComboD[i]==LIGHT_StrMIRROR){

						DrawLightBeam(DIR_LEFT, combo, layer, edge, i, stopSolid, consec);

						break;

					} else if(Screen->ComboD[i]==LIGHT_3WayPrism){

						DrawLightBeam(DIR_DOWN, combo, layer, edge, i, stopSolid, consec);

						DrawLightBeam(DIR_RIGHT, combo, layer, edge, i, stopSolid, consec);

						DrawLightBeam(DIR_UP, combo, layer, edge, i, stopSolid, consec);

						break;

					} else if(Screen->ComboD[i]==LIGHT_4WayPrism){

						DrawLightBeam(DIR_UP, combo, layer, edge, i, stopSolid, consec);

						DrawLightBeam(DIR_DOWN, combo, layer, edge, i, stopSolid, consec);

						DrawLightBeam(DIR_LEFT, combo, layer, edge, i, stopSolid, consec);

						DrawLightBeam(DIR_RIGHT, combo, layer, edge, i, stopSolid, consec);

						break;

					}

					if(stopSolid && Screen->ComboS[i]>0 && Screen->ComboD[i]!=LIGHT_GLASS)break;

				}

				first = false;

			}

		}

	}

	//end DrawLightBeam

}

//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

//Triggers changes on the screen when hit by light from the prior script.                                                                   //

//D0: Combo number to use on transparent layer to simulate Light. Must be same as prior script.                                             //

//D1: Layer to place light combos on. Should be a transparent layer. Must be same as prior script.                                          //

//D2: What set of triggers to use. Set multiple of the same to require hitting multiple at a time. Max 9, Min 0.                            //

//D3: How many light triggers are in the set listed in D2. Must be set for all triggers. Max 20 per set per screen.                         //

//D4: If set to 1, trigger will be permanent. Otherwise, must be re-solved each time the room is entered.                                   //

//D5: The flag number you wish to replace (Ex: 16 for Secret Flag 0)                                                                        //

//D6: The combo you wish to replace into the above flag.                                                                                    //

//D7: Number of trigger. First one placed should be 0, each consecutive should be 1 higher.                                                 //

//WARNING: Uses the first X Screen->D[] variables, X being the number of different D2 numbers are set on the same screen.                   //

// AUTHOR: Emily                                                  //                                               VERSION: 1.0 (1/28/2018) //

//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

ffc script lightTrigger{

	void run(int lightCombo, int lightLayer, int lightSet, int lightMax, bool perm, int flag, int combo, int triggerNum){

		Waitframes(2);

		int lightTriggers[20];

		lightTriggers = Link->Misc[6+lightSet];

		lightTriggers[triggerNum]=0;

		if(lightLayer==0)lightLayer=LIGHT_LAYER;

		if(lightCombo==0)lightCombo=LIGHT_COMBO;

		int thisCombo = ComboAt(this->X+8,this->Y+8);

		bool triggered = false;

		bool done = false;

		int inactiveCombo = Screen->ComboD[thisCombo];

		while(true){

			if(perm)checkTrigger(flag, combo);

			if(!triggered && GetLayerComboD(lightLayer, thisCombo)==lightCombo){

				triggered = true;

				lightTriggers[triggerNum]++;

				Screen->ComboD[thisCombo]=inactiveCombo+1;

			} else if(triggered && GetLayerComboD(lightLayer, thisCombo)!=lightCombo){

				triggered = false;

				lightTriggers[triggerNum]--;

				if(!done)Screen->ComboD[thisCombo]=inactiveCombo;

			}

			Waitframe();

			if(!done && checkLightTriggers(lightTriggers, lightMax)){

				triggerCombo(flag, combo, true, false, perm);

				done=true;

			}

			Waitframe();

		}

	}

	bool checkLightTriggers(int array, int size){

		for(int i = 0;i<size;i++){

			if(array[i]==0)return false;

		}

		return true;

	}

	void triggerCombo(int flag, int combo, bool secretSFX, bool fromCheck, bool perm){

		for(int i = 0;i<=175;i++){

			if(ComboFI(i,flag)){

				Screen->ComboD[i]=combo;

			}

		}

		if(secretSFX)Game->PlaySound(SFX_SECRET);

		if(fromCheck||!perm)return;

		for(int i = 0;i<8;i++){

			if(Screen->D[i]==0){

				Screen->D[i]=1000+flag;

				return;

			}

		}

		

	}

	

	void checkTrigger(int flag, int combo){

		for(int i = 0;i<8;i++){

			if(Screen->D[i]==(1000+flag)){

				triggerCombo(flag, combo, false, true, true);

				break;

			}

		}

	}

}



//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

//Must be placed on screen for the lightPuzzle && lightTrigger scripts to work.                                                             //

//D0: What set of light triggers to set up. Seperate set needed for each. 0-9 only.                                                         //

// AUTHOR: Emily                                                  //                                               VERSION: 1.0 (1/28/2018) //

//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

ffc script lightTriggerSetup{

	void run(int lightSet){

		int lightTriggers[20];

		Link->Misc[6+lightSet] = lightTriggers;

		while(true){Waitframe();}

	}

}