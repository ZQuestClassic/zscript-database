//Solid moving wall trap. Instant-kills if completely closes in, but crushing against random stuff inside arena is like normal solid FFC crusher.
//Can be any size, even beyond 4*4. Uses custom rendering. Trigger secrets to blow up the Demon Wall.

//Requires Solid FFCs.zh and all it`s dependencies. Global script example uses combination of default classic.zh global, LinkMovement, needed for SolidFFFC, and Solid FFC.
//Set up 3*3 tiles for wall rendering
//Set up SolidFFCs.zh and all his dependencies
//Place FFC at top Left Corner of initial position of trap. Set velocity for movement.
//D0 NPC slot to keep track for weak spot. If you use enemy that has ghosted death animation, set D0 to it`s enemy slot so the wall will stop and don`t crush Link during death animation.
//D1 - X size of the wall, in tiles.
//D2 - Y size of the wall, in tiles.
//D3 - Top left corner of tile setup from step 1.
//D4 - death sprite, draw for each tile in wall. 0 for sbomb explosion at center.

ffc script DemonWall{
	void run(int npcslot, int sizex, int sizey, int tile, int deathspr){
		this->Data=FFCS_INVISIBLE_COMBO;
		if (Screen->State[ST_SECRET])Quit();
		int respx=-1;
		int respy=-1;
		int drawx=0;
		int drawy=0;
		int xoffset=0;
		int yoffset=0;
		lweapon explosion;
		int boomcounter=16;
		Waitframes(4);
		SolidObjects[__SOLIDOBJ_FORCERESPAWNCOUNTER]=0;
		npc en;
		if (npcslot>0)en = Screen->LoadNPC(npcslot);
		while(!Screen->State[ST_SECRET]){
			if(en->isValid()){
				if (en->HP>1){
					//Your custom behaviour while enemy is alive goes here.
				}
				else{
					this->Vx=0;
					this->Vy=0;
					boomcounter--;
					if (boomcounter==0){
						explosion=Screen->CreateLWeapon(LW_BOMBBLAST);
						explosion->X=this->X+Rand(16*sizex)-8;
						explosion->Y=this->Y+Rand(16*sizey)-8;
						explosion->CollDetection=false;
						boomcounter=16;
					}
				}
			}
			for (int w=0; w<sizex; w++){
				drawx = this->X+16*w;
				xoffset=0;
				if (w>0)xoffset=1;
				if (w==sizex-1) xoffset=2;
				for (int h=0; h<sizey; h++){
					drawy = this->Y+16*h;
					yoffset=0;
					if (h>0)yoffset=1;
					if (h==sizey-1) yoffset=2;
					Screen->FastTile(1, drawx, drawy, tile +xoffset+20*yoffset, this->CSet, OP_OPAQUE);
				}
			}
			SolidObjects_Add(FFCNum(this), this->X, this->Y, sizex*16, sizey*16, this->Vx, this->Vy, 2);
			if (SolidObjects[__SOLIDOBJ_FORCERESPAWNCOUNTER]>0 && SolidObjects[__SOLIDOBJ_CRUSHCOUNTER]>0){
				Link->HP=0; //Kill Link Instantly, if DemonWall hits respawn spot.
			}
			Waitframe();
		}
		if (deathspr==0){
			explosion=Screen->CreateLWeapon(LW_SBOMBBLAST);
			explosion->X=this->X+sizex*8;
			explosion->Y=this->Y+sizey*8;
			explosion->CollDetection=false;
		}
		else{
			for (int w=0; w<sizex; w++){
				drawx = this->X+16*w;
				xoffset=0;
				if (w>0)xoffset=1;
				if (w==sizex-1) xoffset=2;
				for (int h=0; h<sizey; h++){
					drawy = this->Y+16*h;
					yoffset=0;
					if (h>0)yoffset=1;
					if (h==sizey-1) yoffset=2;
					explosion=Screen->CreateLWeapon(LW_SPARKLE);
					explosion->X=drawx;
					explosion->Y=drawy;
					explosion->UseSprite(deathspr);
					explosion->CollDetection=false;
				}
			}
		}
	}
}

global script DemonWallActive{
	void run(){
		StartGhostZH();
		Tango_Start();
		__classic_zh_InitScreenUpdating();
		LinkMovement_Init();
		SolidObjects_Init();
		while(true)	{
			SolidObjects_Update1();
			LinkMovement_Update1();
			UpdateGhostZH1();
			__classic_zh_UpdateScreenChange1();
			Tango_Update1();
			__classic_zh_do_z2_lantern();
			if ( __classic_zc_internal[__classic_zh_SCREENCHANGED] )
			{
				__classic_zh_CompassBeep();
				__classic_zh_ResetScreenChange();
			}
			Waitdraw();
			SolidObjects_Update2();
			LinkMovement_Update2();
			UpdateGhostZH2();
			Tango_Update2();
			Waitframe();
		}
	}
}