const int SFX_BS_GANON_FANFARE = 64; //Sound that plays when entering the room
const int SFX_BS_GANON_HIT = 63; //Looping hit sound during Ganon's death
const int SFX_BS_GANON_DEATH = 62; //Screen flash sound during Ganon's death
const int SFX_BS_GANON_TRIFORCE = 65; //Sound of the triforce appearing

const int MIDI_BS_GANON = 13; //MIDI that plays when you enter the screen with Ganon. I'm assuming you're using MIDI right? If not, make it negative for enhanced music. Can read it off a ZQuest string.
const int TRACK_BS_GANON = 0; //On the even rarer chance you're using trackers...

const int C_BS_GANON_FLASHYELLOW = 0xEB; //Yellow used for the hit animation
const int C_BS_GANON_FLASHWHITE = 0x01; //White for the fade out

npc script BSGanon{
	const int _THISPTR = 0;
	const int _OTILE = 1;
	const int _FLASHTILES = 2;
	const int _SILVERHIT = 3;
	void SetTile(untyped dat, int frame){
		npc this = dat[_THISPTR];
		int oTile = dat[_OTILE];
		bitmap flashTiles = dat[_FLASHTILES];
		bool silverHit = dat[_SILVERHIT];
		
		if(!silverHit)
			this->ScriptTile = oTile+frame*this->TileWidth;
	}
	void SetFlashingTile(untyped dat, int frame, int flashLevel){
		npc this = dat[_THISPTR];
		int oTile = dat[_OTILE];
		bitmap flashTiles = dat[_FLASHTILES];
		bool silverHit = dat[_SILVERHIT];
		
		int x = frame*32;
		int y = flashLevel*32;
		
		flashTiles->WriteTile(0, x, y, oTile+9*this->TileWidth, true, false);
		flashTiles->WriteTile(0, x+16, y, oTile+9*this->TileWidth+1, true, false);
		flashTiles->WriteTile(0, x, y+16, oTile+9*this->TileWidth+20, true, false);
		flashTiles->WriteTile(0, x+16, y+16, oTile+9*this->TileWidth+21, true, false);
		
		this->ScriptTile = oTile+9*this->TileWidth;
	}
	bool WaitArrowCollision(untyped dat, int frames){
		npc this = dat[_THISPTR];
		int oTile = dat[_OTILE];
		bitmap flashTiles = dat[_FLASHTILES];
		bool silverHit = dat[_SILVERHIT];
		for(int i=0; i<frames&&!silverHit; ++i){
			int hitby = this->HitBy[2]; //lweapon
			if(hitby){
				lweapon l = Screen->LoadLWeapon(hitby);
				Trace(l->ID);
				Trace(l->Level);
				if(l->ID==LW_ARROW&&l->Level>1){
					dat[_SILVERHIT] = true;
				}
			}
			Waitframe();
		}
	}
	//This teleport function is probably even janker than engine. Whoops
	void Teleport(npc this){
		int targetPos[] = {51, 59, 99, 107, 39, 119, 82, 92};
		int x; int y; int pos;
		//Loop over preset combo positions to find one suitably far from Link
		for(int i=0; i<24; ++i){
			pos = targetPos[Rand(8)];
			if(i>15)
				pos = targetPos[i-16];
			x = ComboX(pos);
			y = ComboY(pos);
			if(Distance(x+8, y+8, Link->X, Link->Y)>=96)
				break;
		}
		this->X = x;
		this->Y = y;
	}
	void run(int stunnedID){
		//If HP starts out at <0, this instance of the enemy was created to change the sprite palette
		if(this->HP<=0)
			Quit();
		
		//1 extra HP to account for health bar scripts
		++this->HP;
		
		//Store the enemy's defenses
		int defs[36];
		for(int i=0; i<36; ++i){
			defs[i] = this->Defense[i];
		}
		
		//Scale and position
		int oTile = this->Tile;
		this->Extend = 3;
		this->TileWidth = 2;
		this->TileHeight = 2;
		this->HitWidth = 32;
		this->HitHeight = 32;
		this->X = 112;
		this->Y = 80;
		
		//Create the bitmap used for drawing Ganon when flashing
		bitmap flashTiles = Game->CreateBitmap(320, 64);
		flashTiles->Clear(0);
		flashTiles->DrawTile(0, 0, 0, oTile, 20, 2, 14, -1, -1, 0, 0, 0, 0, false, 128);
		flashTiles->ReplaceColors(0, C_BS_GANON_FLASHYELLOW, 0xE1, 0xEF);
		flashTiles->DrawTile(0, 0, 32, oTile, 20, 2, 14, -1, -1, 0, 0, 0, 0, false, 128);
		flashTiles->Blit(0, flashTiles, 0, 0, 320, 32, 0, 32, 320, 32, 0, 0, 0, BITDX_TRANS, 0, true);
		flashTiles->Blit(0, flashTiles, 0, 0, 320, 32, 0, 32, 320, 32, 0, 0, 0, BITDX_TRANS, 0, true);
		flashTiles->Own();
		
		bitmap dissolve = Game->CreateBitmap(96, 32);
		dissolve->Clear(0);
		
		this->CollDetection = false;
		while(Link->X<32||Link->X>208||Link->Y<32||Link->Y>128){
			Waitframe();
		}
		
		untyped dat[] = {this, oTile, flashTiles, false};
		
		//Spawn in animation
		Game->PlayMIDI(0);
		Game->PlaySound(SFX_BS_GANON_FANFARE);
		WaitNoAction(64);
		SetTile(dat, 1);
		WaitNoAction(5);
		SetTile(dat, 2);
		WaitNoAction(5);
		SetTile(dat, 3);
		WaitNoAction(5);
		SetTile(dat, 4);
		WaitNoAction(5);
		SetTile(dat, 5);
		WaitNoAction(26);
		for(int i=0; i<7; ++i){
			SetTile(dat, 4);
			WaitNoAction(9);
			SetTile(dat, 5);
			WaitNoAction(9);
		}
		WaitNoAction(96);
		SetTile(dat, 3);
		WaitNoAction(5);
		SetTile(dat, 2);
		WaitNoAction(5);
		SetTile(dat, 1);
		WaitNoAction(5);
		SetTile(dat, 0);
		WaitNoAction(5);
		for(int i=0; i<6; ++i){
			this->DrawXOffset = -1000;
			WaitNoAction(2);
			this->DrawXOffset = 0;
			WaitNoAction(2);
		}
		Teleport(this);
		this->DrawXOffset = -1000;
		int shotTimer = 64;
		if(MIDI_BS_GANON>0)
			Game->PlayMIDI(MIDI_BS_GANON);
		else if(MIDI_BS_GANON<0){
			int str[512];
			Game->GetMessage(Abs(MIDI_BS_GANON), str);
			Game->PlayEnhancedMusic(str, TRACK_BS_GANON);
		}
		this->CollDetection = true;
		this->Immortal = true;
		this->NoSlide = true;
		int startHP = this->HP;
		int lastHP = this->HP;
		while(true){
			//Shoot a fireball every 64 frames
			if(shotTimer)
				--shotTimer;
			else{
				eweapon e = CreateEWeaponAt(EW_FIREBALL, this->X, this->Y);
				e->Angular = true;
				e->Dir = AngleDir4(Angle(e->X, e->Y, Link->X, Link->Y));
				e->Angle = DegtoRad(Angle(e->X, e->Y, Link->X, Link->Y));
				e->Step = 150;
				e->Damage = this->WeaponDamage;
				e->UseSprite(17);
				e->Unblockable = UNBLOCK_ALL;
				shotTimer = 64;
			}
			
			this->HP = Max(this->HP, 1);
			if(this->HP<lastHP){
				if(this->HP>1){ //Hit animation
					for(int i=0; i<36; ++i){
						if(i==NPCD_SWORD)
							this->Defense[i] = NPCDT_IGNORE;
						else
							this->Defense[i] = NPCDT_BLOCK;
					}
					this->DrawXOffset = 0;
					//Flash
					for(int i=0; i<5; ++i){
						SetTile(dat, 6);
						Waitframes(3);
						SetFlashingTile(dat, 6, 1);
						Waitframe();
						SetFlashingTile(dat, 6, 0);
						Waitframe();
						SetFlashingTile(dat, 6, 1);
						Waitframe();
					}
					SetTile(dat, 6);
					Waitframes(12);
					SetTile(dat, 5);
					Waitframes(7);
					SetTile(dat, 3);
					Waitframes(5);
					SetTile(dat, 2);
					Waitframes(5);
					SetTile(dat, 1);
					Waitframes(5);
					SetTile(dat, 0);
					Waitframes(5);
					//Flicker
					for(int i=0; i<6; ++i){
						this->DrawXOffset = -1000;
						Waitframes(2);
						this->DrawXOffset = 0;
						Waitframes(2);
					}
					this->DrawXOffset = -1000;
					for(int i=0; i<36; ++i){
						this->Defense[i] = defs[i];
					}
					Teleport(this);
				}
				else{ //Turn blue animation
					this->DrawXOffset = 0;
					//Create a new enemy to update the sprite palette, then instantly kill it. Hooray for jank
					npc n = CreateNPCAt(stunnedID, 120, -32);
					n->ItemSet = 0;
					n->HP = -1000;
					SetTile(dat, 5);
					WaitArrowCollision(dat, 32);
					for(int i=0; i<36; ++i){
						if(i==NPCD_ARROW)
							this->Defense[i] = NPCDT_NONE;
						else
							this->Defense[i] = NPCDT_IGNORE;
					}
					SetTile(dat, 4);
					WaitArrowCollision(dat, 9);
					SetTile(dat, 8);
					WaitArrowCollision(dat, 9);
					SetTile(dat, 6);
					for(int i=0; i<300; ++i){
						WaitArrowCollision(dat, 1);
					}
					WaitArrowCollision(dat, 9);
					SetTile(dat, 8);
					WaitArrowCollision(dat, 10);
					SetTile(dat, 4);
					WaitArrowCollision(dat, 8);
					SetTile(dat, 5);
					WaitArrowCollision(dat, 68);
					//Ganon was hit by a silver arrow, play death animation
					if(dat[_SILVERHIT]){
						//Randomize the order to dissolve pixels in
						int pixelOrder[1024];
						for(int i=0; i<1024; ++i){
							pixelOrder[i] = i;
						}
						for(int i=0; i<4096; ++i){
							int whichA = Rand(1024);
							int whichB = Rand(1024);
							int backup = pixelOrder[whichB];
							pixelOrder[whichB] = pixelOrder[whichA];
							pixelOrder[whichA] = backup;
						}
						this->CollDetection = false;
						flashTiles->Clear(0);
						flashTiles->DrawTile(0, 0, 0, this->ScriptTile, 2, 2, this->CSet, -1, -1, 0, 0, 0, 0, true, 128);
						Game->PlaySound(SFX_BS_GANON_DEATH);
						int erasedPixels;
						this->DrawXOffset = -1000;
						for(int i=0; i<240; ++i){
							if(i%32==0)
								Game->PlaySound(SFX_BS_GANON_HIT);
							if(i%2==0){
								this->HitXOffset = Rand(-1, 1);
								this->HitYOffset = Rand(-1, 1);
								if(i>32){
									for(int j=0; j<12; ++j){
										if(erasedPixels<1024){
											flashTiles->PutPixel(0, pixelOrder[erasedPixels]%32, Floor(pixelOrder[erasedPixels]/32), 0x00, 0, 0, 0, 128);
											++erasedPixels;
										}
									}
								}
							}
							flashTiles->Blit(2, RT_SCREEN, 0, 0, 32, 32, this->X+this->HitXOffset, this->Y+this->DrawYOffset+this->HitYOffset, 32, 32, 0, 0, 0, 0, 0, true);
							if(i>240*0.25)
								Screen->Rectangle(6, 0, 0, 255, 175, C_BS_GANON_FLASHWHITE, 1, 0, 0, 0, true, 64);
							if(i>240*0.5)
								Screen->Rectangle(6, 0, 0, 255, 175, C_BS_GANON_FLASHWHITE, 1, 0, 0, 0, true, 64);
							if(i>240*0.75)
								Screen->Rectangle(6, 0, 0, 255, 175, C_BS_GANON_FLASHWHITE, 1, 0, 0, 0, true, 128);
							WaitNoAction();
						}
						item triforce = CreateItemAt(I_TRIFORCEBIG, this->X+8, this->Y+8);
						triforce->Pickup = IP_DUMMY;
						item dust = CreateItemAt(I_DUST_PILE, this->X+8, this->Y+12);
						dust->HitXOffset = -1000;
						dust->Pickup = IP_DUMMY;
						Game->PlaySound(SFX_BS_GANON_TRIFORCE);
						for(int i=0; i<154; ++i){
							if(i<240*0.75)
								Screen->Rectangle(6, 0, 0, 255, 175, C_BS_GANON_FLASHWHITE, 1, 0, 0, 0, true, 64);
							if(i<240*0.5)
								Screen->Rectangle(6, 0, 0, 255, 175, C_BS_GANON_FLASHWHITE, 1, 0, 0, 0, true, 64);
							if(i<240*0.25)
								Screen->Rectangle(6, 0, 0, 255, 175, C_BS_GANON_FLASHWHITE, 1, 0, 0, 0, true, 128);
							WaitNoAction();
						}
						triforce->Pickup = 0;
						while(triforce->isValid()){
							Waitframe();
						}
						//Allow the enemy to die and shutters to open
						this->DrawXOffset = -1000;
						this->Immortal = false;
						this->ItemSet = 0;
						this->HP = -1000;
					}
					//Changing the sprite palette back. Ganon practices self harm
					n = CreateNPCAt(this->ID, 120, -32);
					n->ItemSet = 0;
					n->HP = -1000;
					for(int i=0; i<36; ++i){
						if(i==NPCD_SWORD)
							this->Defense[i] = NPCDT_IGNORE;
						else
							this->Defense[i] = NPCDT_BLOCK;
					}
					SetTile(dat, 3);
					Waitframes(5);
					SetTile(dat, 2);
					Waitframes(6);
					SetTile(dat, 1);
					Waitframes(4);
					SetTile(dat, 0);
					Waitframes(6);
					for(int i=0; i<10; ++i){
						this->DrawXOffset = -1000;
						Waitframes(2);
						this->DrawXOffset = 0;
						Waitframes(2);
					}
					this->DrawXOffset = -1000;
					for(int i=0; i<36; ++i){
						this->Defense[i] = defs[i];
					}
					this->HP = startHP;
					Teleport(this);
				}
			}
			lastHP = this->HP;
			
			this->ConstantWalk({this->Rate, this->Homing, 0});
			Waitframe();
		}
	}
}