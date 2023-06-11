const int RT_GLASSWIPE = 1; //Offscreen bitmap to use for the wipe (RT_ constants in std_constants.zh)
const int C_GLASSWIPE_BG = 0x0F; //The color black. Used to draw the background for tilesets that use transparent tiles on layer 0

//D0: Which DMap to warp to
//D1: Y position of the screen to warp to. For example, 64 would be 6.
//D2: X position of the screen to warp to. For example, 64 would be 4. 6A would be 10.
//D3: Sound to play
//D4: How fast to expand the wipe radius from the center in pixels per frame (if 0, this is instant. 2 is my base testing speed)
//D5: Base speed for the glass shards in pixels per frame (if 0, defaults to 1)
//D6: The gravity of the shards (if 0, defaults to 0.6)
//D7: Set to 1 if the script doesn't handle the warp
ffc script Glasswipe_Warp{
	void run(int dmap, int screenY, int screenX, int sfx, int expansionSpeed, float shardSpeed, float gravity, int noWarp){
		Waitframes(this->Delay);
		
		int CPX[56];
		int CPY[56];
		int CPZ[56];
		int AngA[56];
		int AngB[56];
		int AngC[56];
		int DA[56];
		int DB[56];
		int DC[56];
		int BaseAngA[56];
		int BaseAngB[56];
		int RotA[56];
		int RotB[56];
		int VX[56];
		int VY[56];
		int shardState[56];
		
		int vars[] = {CPX, CPY, CPZ, AngA, AngB, AngC, DA, DB, DC, BaseAngA, BaseAngB, RotA, RotB, VX, VY, shardState, 56};
		
		GlassWipe_Init(RT_GLASSWIPE, vars);
		
		Game->PlaySound(sfx);
		
		int cx = this->X+8;
		int cy = this->Y+8;
		if(this->X==0&&this->Y==0){
			cx = 128;
			cy = 88;
		}
		
		int radius = 0;
		if(expansionSpeed==0)
			radius = 512;
		if(shardSpeed==0)
			shardSpeed = 1;
		if(gravity==0)
			gravity = 0.6;
		else if(gravity==0.0001)
			gravity = 0;
		
		int lastMap = Game->GetCurMap();
		int lastScreen = Game->GetCurScreen();
		
		int newMap = Game->DMapMap[dmap];
		int newScreen = (screenY*16+screenX)+Game->DMapOffset[dmap];
		while(vars[16]>0){	
			radius = Min(radius+expansionSpeed, 512);
		
			//Draw the new screen to the bitmap
			Screen->SetRenderTarget(RT_GLASSWIPE);
			Screen->Rectangle(6, 0, 0, 255, 175, C_GLASSWIPE_BG, 1, 0, 0, 0, true, 128);
			Screen->DrawScreen(6, newMap, newScreen, 0, 0, 0);
			
			//Draw the old screen to the screen
			Screen->SetRenderTarget(RT_SCREEN);
			Screen->Rectangle(6, 0, 0, 255, 175, C_GLASSWIPE_BG, 1, 0, 0, 0, true, 128);
			Screen->DrawScreen(6, lastMap, lastScreen, 0, 0, 0);
			
			//Erase the triangles from the bitmap
			GlassWipe_Update(6, RT_GLASSWIPE, cx, cy, radius, shardSpeed, gravity, vars);
			
			//Draw the bitmap to the screen
			Screen->DrawBitmap(6, RT_GLASSWIPE, 0, 0, 256, 176, 0, 0, 256, 176, 0, true);
			WaitNoAction();
		}
		if(noWarp==0){
			Link->Warp(dmap, screenY*16+screenX);
		}
		while(true){
			//Draw the new screen to the bitmap
			Screen->SetRenderTarget(RT_SCREEN);
			Screen->Rectangle(6, 0, 0, 255, 175, C_GLASSWIPE_BG, 1, 0, 0, 0, true, 128);
			Screen->DrawScreen(6, newMap, newScreen, 0, 0, 0);
			
			WaitNoAction();
		}
	}
	//Call once to initialize the wipe
	//rt - The bitmap to use (RT_ constants in std_constants.zh)
	//vars - An array with array pointers for all the data of the glass wipe. 15 in total, all size 56. The last index is 56.
	//			{CPX, CPY, CPZ, AngA, AngB, AngC, DA, DB, DC, BaseAngA, BaseAngB, RotA, RotB, VX, VY, shardState, 56}
	void GlassWipe_Init(int rt, int vars){
		int CPX = vars[0];
		int CPY = vars[1];
		int CPZ = vars[2];
		int AngA = vars[3];
		int AngB = vars[4];
		int AngC = vars[5];
		int DA = vars[6];
		int DB = vars[7];
		int DC = vars[8];
		
		int PointX[40];
		int PointY[40];
		int i;
		for(i=0; i<40; i++){
			PointX[i] = -48+48*(i%8)+(Floor(i/8)%2)*0.5*48;
			PointY[i] = -16+Floor(i/8)*48;
			PointX[i] += Rand(-8, 8);
			PointY[i] += Rand(-8, 8);
		}
		int TA[56];
		int TB[56];
		int TC[56];
		for(i=0; i<7; i++){
			TA[i] = i;
			TB[i] = i+1;
			TC[i] = i+8;
		}
		for(i=0; i<7; i++){
			TA[7+i] = i+1;
			TB[7+i] = 8+i;
			TC[7+i] = 8+i+1;
		}
		for(i=0; i<7; i++){
			TA[14+i] = 8+i;
			TB[14+i] = 8+i+1;
			TC[14+i] = 8+i+9;
		}
		for(i=0; i<7; i++){
			TA[21+i] = 8+i;
			TB[21+i] = 16+i;
			TC[21+i] = 16+i+1;
		}
		for(i=0; i<7; i++){
			TA[28+i] = 16+i;
			TB[28+i] = 16+i+1;
			TC[28+i] = 16+i+8;
		}
		for(i=0; i<7; i++){
			TA[35+i] = 16+i+1;
			TB[35+i] = 24+i;
			TC[35+i] = 24+i+1;
		}
		for(i=0; i<7; i++){
			TA[42+i] = 24+i;
			TB[42+i] = 24+i+1;
			TC[42+i] = 24+i+9;
		}
		for(i=0; i<7; i++){
			TA[49+i] = 24+i;
			TB[49+i] = 32+i;
			TC[49+i] = 32+i+1;
		}
		int BaseAngA[56];
		int BaseAngB[56];
		int RotA[56];
		int RotB[56];
		int VX[56];
		int VY[56];
		Screen->SetRenderTarget(rt);
		Screen->Rectangle(6, 0, 0, 255, 175, 0x0F, 1, 0, 0, 0, true, 128);
		Screen->SetRenderTarget(RT_SCREEN);
		for(i=0; i<56; i++){
			CPX[i] = (PointX[TA[i]]+PointX[TB[i]]+PointX[TC[i]])/3;
			CPY[i] = (PointY[TA[i]]+PointY[TB[i]]+PointY[TC[i]])/3;
			AngA[i] = Angle(CPX[i], CPY[i], PointX[TA[i]], PointY[TA[i]]);
			AngB[i] = Angle(CPX[i], CPY[i], PointX[TB[i]], PointY[TB[i]]);
			AngC[i] = Angle(CPX[i], CPY[i], PointX[TC[i]], PointY[TC[i]]);
			DA[i] = Distance(CPX[i], CPY[i], PointX[TA[i]], PointY[TA[i]])+1;
			DB[i] = Distance(CPX[i], CPY[i], PointX[TB[i]], PointY[TB[i]])+1;
			DC[i] = Distance(CPX[i], CPY[i], PointX[TC[i]], PointY[TC[i]])+1;
			VX[i] = VectorX(Distance(128, 88, CPX[i], CPY[i])/120, Angle(128, 88, CPX[i], CPY[i]));
			VY[i] = VectorY(Distance(128, 88, CPX[i], CPY[i])/80, Angle(128, 88, CPX[i], CPY[i]));
		}
	}
	//Erases triangles from the bitmap
	//Call every frame until vars[16] is less than or equal to 0.
	//Layer - The layer to draw to
	//rt - The bitmap to use (RT_ constants in std_constants.zh)
	//cx,cy - Center point for the shatter effect
	//radius - How far from the shatter point to activate shards
	//shardSpeed - How fast the shards should move in pixels per frame, not accounting for gravity
	void GlassWipe_Update(int layer, int rt, int cx, int cy, int radius, float shardSpeed, float gravity, int vars){
		int i;
		
		int CPX = vars[0];
		int CPY = vars[1];
		int CPZ = vars[2];
		int AngA = vars[3];
		int AngB = vars[4];
		int AngC = vars[5];
		int DA = vars[6];
		int DB = vars[7];
		int DC = vars[8];
		int BaseAngA = vars[9];
		int BaseAngB = vars[10];
		int RotA = vars[11];
		int RotB = vars[12];
		int VX = vars[13];
		int VY = vars[14];
		int shardState = vars[15];
		int numShards = 56;
		
		// Screen->Rectangle(Layer, -8, -8, 264, 184, 0x0F, 1, 0, 0, 0, true, 128);
		// Screen->DrawScreen(Layer, OldMap, OldScreen, 0, 0, 0);
		// Screen->DrawBitmap(Layer, rt, 0, 0, 256, 176, 0, 0, 256, 176, 0, true);
		// Screen->SetRenderTarget(rt);
		// Screen->Rectangle(6, -8, -8, 264, 184, 0x0F, 1, 0, 0, 0, true, 128);
		// Screen->DrawScreen(6, NewMap, NewScreen, 0, 0, 0);
		Screen->SetRenderTarget(rt);
		for(i=0; i<56; i++){
			if(shardState[i]==0&&Distance(CPX[i], CPY[i], cx, cy)<radius){
				shardState[i] = 1;
				int angle = Angle(cx, cy, CPX[i], CPY[i])+Rand(-30, 30);
				int step = shardSpeed*Rand(10, 20)/10;
				VX[i] = VectorX(step, angle);
				VY[i] = VectorY(step, angle);
				RotA[i] = Choose(-1, 1)*Rand(5, 50)/10;
				RotB[i] = Choose(-1, 1)*Rand(5, 50)/10;
			}
			if(shardState[i]==1){
				if(CPX[i]>-48&&CPX[i]<304&&CPY[i]>-48&&CPY[i]<224){
					CPX[i] += VX[i];
					CPY[i] += VY[i];
					VY[i] = Min(VY[i]+gravity, 3.2); //Gravity - 0.6
				}
				else{
					numShards--;
				}
				BaseAngA[i] += RotA[i];
				BaseAngB[i] += RotB[i];
			}
			
			int freshprinceofdickbutt = 90;
			//you tread upon the hall of the forbidden Mathemancy. Nobody knows how it works. Well someone might. But it isn't Moosh.
			int X[3];
			int Y[3];
			int Z[3];
			int x0; int y0; int z0; int xtmp;
			x0 = DA[i]*Sin(freshprinceofdickbutt)*Cos(AngA[i]);
			y0 = DA[i]*Sin(freshprinceofdickbutt)*Sin(AngA[i]);
			z0 = DA[i]*Cos(freshprinceofdickbutt);
			X[0] = x0;
			Y[0] = y0*Cos(BaseAngA[i])-z0*Sin(BaseAngA[i]);
			Z[0] = y0*Sin(BaseAngA[i])+z0*Cos(BaseAngA[i]);
			xtmp = X[0];
			X[0] = X[0]*Cos(BaseAngB[i])+Z[0]*Sin(BaseAngB[i]);
			Z[0] = -xtmp*Sin(BaseAngB[i])+Z[0]*Cos(BaseAngB[i]);
			
			x0 = DB[i]*Sin(freshprinceofdickbutt)*Cos(AngB[i]);
			y0 = DB[i]*Sin(freshprinceofdickbutt)*Sin(AngB[i]);
			z0 = DB[i]*Cos(freshprinceofdickbutt);
			X[1] = x0;
			Y[1] = y0*Cos(BaseAngA[i])-z0*Sin(BaseAngA[i]);
			Z[1] = y0*Sin(BaseAngA[i])+z0*Cos(BaseAngA[i]);
			xtmp = X[1];
			X[1] = X[1]*Cos(BaseAngB[i])+Z[1]*Sin(BaseAngB[i]);
			Z[1] = -xtmp*Sin(BaseAngB[i])+Z[1]*Cos(BaseAngB[i]);
			
			x0 = DC[i]*Sin(freshprinceofdickbutt)*Cos(AngC[i]);
			y0 = DC[i]*Sin(freshprinceofdickbutt)*Sin(AngC[i]);
			z0 = DC[i]*Cos(freshprinceofdickbutt);
			X[2] = x0;
			Y[2] = y0*Cos(BaseAngA[i])-z0*Sin(BaseAngA[i]);
			Z[2] = y0*Sin(BaseAngA[i])+z0*Cos(BaseAngA[i]);
			xtmp = X[2];
			X[2] = X[2]*Cos(BaseAngB[i])+Z[2]*Sin(BaseAngB[i]);
			Z[2] = -xtmp*Sin(BaseAngB[i])+Z[2]*Cos(BaseAngB[i]);
			
			if(shardState[i]==1)
				Screen->Triangle(6, CPX[i]+X[0], CPY[i]+Y[0]+1, CPX[i]+X[1], CPY[i]+Y[1]+1, CPX[i]+X[2], CPY[i]+Y[2]+1, 2, 2, 0x0F, 0, -1, PT_FLAT);
			else
				Screen->Triangle(6, CPX[i]+X[0], CPY[i]+Y[0]+1, CPX[i]+X[1], CPY[i]+Y[1]+1, CPX[i]+X[2], CPY[i]+Y[2]+1, 2, 2, 0x00, 0, -1, PT_FLAT);
			Screen->Triangle(6, CPX[i]+X[0], CPY[i]+Y[0], CPX[i]+X[1], CPY[i]+Y[1], CPX[i]+X[2], CPY[i]+Y[2], 1, 1, 0x00, 0, -1, PT_FLAT);
		}
		Screen->SetRenderTarget(RT_SCREEN);
		vars[16] = numShards;
	}
}