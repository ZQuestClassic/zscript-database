const int SPR_MONARCHDUST = 88; //Sprite used for the dust particles
const int SPR_MONARCHWINDSPEAR = 89; //Sprite used for the wind spears

const int SFX_MONARCHDUST = 59; //Sound when the boss sprinkles dust
const int SFX_MONARCHSLIDE = 65; //Sound when the boss slides along the ground
const int SFX_MONARCHCAST = 56; //Sound when the boss casts a spell
const int SFX_MONARCHWINDSPEAR = 66; //Sound when the boss fires a wind spear
const int SFX_MONARCHCOCOON = 21; //Sound when the boss creates a cocoon

npc script MonarchAscendant{
	using namespace NPCAnim;
	using namespace NPCAnim::Legacy;
	
	enum{
		V_FLYING,
		V_LAZYCHASE, 
		V_Z,
		V_TX,
		V_TY,
		V_VX,
		V_VY,
		V_HOVERT,
		V_PHASE2PERCENTAGE,
		V_INITHP,
		V_PHASE2FLAG
	};
	
	enum Animations{
		STANDING,
		WALKING,
		CASTING,
		FLYING,
		FLYCASTING,
		LANDINGLEFT,
		LANDINGRIGHT
	};
		
	void run(){
		AnimHandler aptr = new AnimHandler(this);
		
		SetFakeShadow(this, this->ShadowSprite, 1, 1, 0);
		
		AddAnim(aptr, STANDING, 12, 1, 1, ADF_NOLOOP);
		AddAnim(aptr, WALKING, 12, 4, 16, 0);
		AddAnim(aptr, CASTING, 40, 1, 16, ADF_NOLOOP);
		AddAnim(aptr, FLYING, 0, 2, 4, 0);
		AddAnim(aptr, FLYCASTING, 4, 2, 4, 0);
		AddAnim(aptr, LANDINGLEFT, 8, 1, 16, ADF_NOLOOP);
		AddAnim(aptr, LANDINGRIGHT, 10, 1, 16, ADF_NOLOOP);
		
		SetAnimSpriteHitbox(this, 2, 2, 4, 4, 6, 6);
		SetAnimMovementHitbox(this, 4, 4, 16, 6);
		
		int initHP = this->HP;
		int phase2Percentage = this->Attributes[0];
		if(phase2Percentage==0)
			phase2Percentage = 50;
		int spawnID = this->Attributes[1];
		int spawnDelay = this->Attributes[2];
		if(spawnDelay==0)
			spawnDelay = 40;
		
		untyped vars[16];
		
		this->X = 112;
		this->Y = 16;
		PlayAnim(this, STANDING);
		MA_Waitframe(this, vars, 32);
		PlayAnim(this, CASTING);
		MA_Waitframe(this, vars, 32);
		MA_TakeOff(this, vars);
		vars[V_LAZYCHASE] = 1;
		vars[V_TX] = this->X+Rand(-16, 16);
		vars[V_TY] = this->Y+48;
		vars[V_INITHP] = this->HP;
		vars[V_PHASE2PERCENTAGE] = phase2Percentage;
		while(true){
			int counterCooldown = 0;
			int whirlwindChance = 900;
			for(int i=0; i<600&&vars[V_PHASE2FLAG]!=1; ++i){
				int hit = this->HitBy[2]; //lweapon
				if(hit){
					whirlwindChance  = Max(whirlwindChance-120, 60);
				}
					
				if(counterCooldown)
					--counterCooldown;
				else{
					if(hit){
						counterCooldown = 120;
						MA_CounterDive(this, vars);
					}
				}
				
				if(Rand(whirlwindChance)==0){
					for(int j=0; j<3; ++j){
						vars[V_TX] = Link->X-8;
						vars[V_TY] = Link->Y-8;
						
						for(int k=0; k<90; ++k){
							vars[V_TX] = Link->X-8;
							vars[V_TY] = Link->Y-8;
							if(i<600-90)
								++i;
							MA_Waitframe(this, vars);
						}
						PlayAnim(this, FLYCASTING, true);
						Game->PlaySound(SFX_MONARCHCAST);
						MA_Waitframe(this, vars, 16);
						for(int k=-3; k<=3; ++k){
							int x = this->X+8+40*k;
							if(Abs(k)==2)
								x -= Sign(k)*8;
							else if(Abs(k)==3)
								x -= Sign(k)*40;
							MA_FireProjectile(x, 0, 90, 400-Abs(k)*25, this->WeaponDamage, 3, {8});
						}
						MA_Waitframe(this, vars, 16);
						PlayAnim(this, FLYING, true);
					}
					whirlwindChance = 900;
				}
				
				if(i%90==0&&i>0){
					vars[V_TX] = Rand(16, 208);
					vars[V_TY] = Rand(16, 64);
				}
				if(i%30==0){
					MA_FireProjectile(this->X+8+Rand(-16, 16), this->Y+16-this->FakeZ, 90, 0, this->WeaponDamage, 0, 0);
				}
				MA_Waitframe(this, vars);
			}
			if(vars[V_PHASE2FLAG]==1&&spawnID)
				MA_SuperAttack(this, vars, spawnID, spawnDelay);
			MA_Dive(this, vars, Link->X-8, Link->Y-16);
			PlayAnim(this, vars[V_VX]<0?LANDINGLEFT:LANDINGRIGHT);
			int angle = Angle(Link->X, Link->Y, this->X+8, this->Y+8);
			for(int i=0; i<12; ++i){
				MA_FireProjectile(this->X+8+Rand(-4, 4), this->Y+8+Rand(-4, 4), angle+30*i, 300, this->WeaponDamage, 1, {32});
				MA_Waitframe(this, vars, 4);
			}
			PlayAnim(this, WALKING);
			int windSpearCooldown = 24;
			for(int i=0; i<300&&vars[V_PHASE2FLAG]!=1; ++i){
				if(i>0&&(i%120==0||Rand(180)==0)){
					PlayAnim(this, CASTING);
					Game->PlaySound(SFX_MONARCHCAST);
					MA_Waitframe(this, vars, 16);
					for(int i=0; i<8; ++i){
						MA_FireProjectile(this->X+8+Rand(-8, 8), this->Y+8+Rand(-8, 8), Rand(360), Rand(150, 300), this->WeaponDamage, 2, {this->UID, 24});
						MA_Waitframe(this, vars, 4);
					}
					MA_TakeOff(this, vars);
					vars[V_LAZYCHASE] = 1;
					MA_Dive(this, vars, Link->X-8, Link->Y-16);
					i = Min(i+30, 300-60);
				}
				if(Abs(this->X+8-Link->X)<16||Link->Y<this->Y+8){
					if(windSpearCooldown)
						--windSpearCooldown;
					else{
						MA_TakeOff(this, vars);
						vars[V_LAZYCHASE] = 1;
						MA_Dive(this, vars, Link->X-8, 48);
						PlayAnim(this, CASTING);
						Game->PlaySound(SFX_MONARCHCAST);
						MA_Waitframe(this, vars, 16);
						for(int i=0; i<16; ++i){
							MA_FireProjectile(this->X+8+Rand(-48, 48), 0, 90, 400, this->WeaponDamage, 3, {24});
							MA_Waitframe(this, vars, 8);
						}
						PlayAnim(this, WALKING);
						windSpearCooldown = 128;
					}
					i = Min(i+120, 300-60);
				}
				int angle = Angle(this->X+8, this->Y+16, Link->X, Link->Y);
				MoveXY(this, VectorX(0.4, angle), VectorY(0.4, angle), AM_NONE);
				MA_Waitframe(this, vars);
			}
			if(vars[V_PHASE2FLAG]==1&&spawnID)
				MA_SuperAttack(this, vars, spawnID, spawnDelay);
			if(!vars[V_FLYING])
				MA_TakeOff(this, vars);
			vars[V_LAZYCHASE] = 1;
		}
	}
	void MA_TakeOff(npc this, untyped vars){
		PlayAnim(this, FLYING);
		vars[V_FLYING] = 1;
		for(int i=0; i<16; ++i){
			vars[V_Z] = Lerp(0, 12, i/15);
			MA_Waitframe(this, vars);
		}
	}
	void MA_Dive(npc this, untyped vars, int tX, int tY){
		int startX = this->X;
		int startY = this->Y;
		vars[V_TX] = tX;
		vars[V_TY] = tY;
		int distStart = Distance(this->X, this->Y, vars[V_TX], vars[V_TY]);
		while(Distance(this->X, this->Y, startX, startY)<distStart*0.8){
			vars[V_Z] = Lerp(12, 0, Distance(this->X, this->Y, startX, startY)/distStart);
			MA_Waitframe(this, vars);
		}
		vars[V_Z] = 0;
		vars[V_LAZYCHASE] = 0;
		vars[V_FLYING] = 0;
		this->FakeZ = 0;
		Game->PlaySound(SFX_MONARCHSLIDE);
		PlayAnim(this, vars[V_VX]<0?LANDINGLEFT:LANDINGRIGHT);
		for(int i=0; i<48; ++i){
			if(!CanPlace(this, this->X, this->Y, AM_NONE)){
				MoveTowardPoint(this, 112+(this->X<112?-80:80), 96, 1, AM_IGNOREALLOFFSCREEN);
			}
			else
				break;
		}
		int angle = Angle(0, 0, vars[V_VX], vars[V_VY]);
		int step = Distance(0, 0, vars[V_VX], vars[V_VY]);
		for(int i=0; i<32; ++i){
			int step2 = Lerp(step, 0, i/31);
			MoveXY(this, VectorX(step2, angle), VectorY(step2, angle), AM_NONE);
			MA_Waitframe(this, vars);
		}
		PlayAnim(this, WALKING);
	}
	void MA_CounterDive(npc this, untyped vars){
		int startX = this->X;
		int startY = this->Y;
		vars[V_TX] = Link->X;
		vars[V_TY] = Link->Y;
		int distStart = Distance(this->X, this->Y, vars[V_TX], vars[V_TY]);
		int angle = Angle(this->X, this->Y, vars[V_TX], vars[V_TY]);
		if(distStart<64){
			distStart += 64;
			vars[V_TX] += VectorX(64, angle);
			vars[V_TY] += VectorY(64, angle);
		}
		int i;
		while(Distance(this->X, this->Y, startX, startY)<distStart*0.8){
			++i;
			if(i%8==0){
				MA_FireProjectile(this->X+8+Rand(-4, 4), this->Y+8+Rand(-4, 4)-this->FakeZ, Angle(this->X, this->Y, startX, startY)+Rand(-20, 20), Rand(200, 300), this->WeaponDamage, 2, {this->UID, 24});
			}
			MA_Waitframe(this, vars);
		}
	}
	void MA_SuperAttack(npc this, untyped vars, int spawnID, int spawnDelay){
		bool wasFlying;
		if(!vars[V_FLYING]){
			MA_TakeOff(this, vars);
		}
		vars[V_LAZYCHASE] = 0;
		while(Distance(this->X, this->Y, 112, 16)>1){
			MoveTowardPoint(this, 112, 16, 1, AM_IGNOREALLOFFSCREEN);
			MA_Waitframe(this, vars);
		}
		PlayAnim(this, FLYCASTING);
		Game->PlaySound(SFX_MONARCHCAST);
		int spawnOrder[12];
		for(int i=0; i<12; ++i){
			spawnOrder[i] = i;
		}
		Shuffle(spawnOrder);
		
		int orbitAng = Rand(360);
		eweapon cocoons[12];
		for(int i=0; i<12; ++i){
			int delay = spawnOrder[i]*5;
			int dist = 32;
			int angle = orbitAng+90*i;
			int rotate = 1;
			int endDelay = spawnOrder[i]*spawnDelay;
			if(i>3){
				dist = 56;
				angle = orbitAng+45*i;
				rotate = -1;
			}
			cocoons[i] = MA_FireProjectile(this->X+8, this->Y-8, 0, 0, this->Damage, 4, {spawnID, delay, angle, dist, rotate, endDelay});
		}
		MA_Waitframe(this, vars, 16);
		int count = 12;
		while(count){
			count = 0;
			for(int i=0; i<12; ++i){
				if(cocoons[i]->isValid())
					++count;
			}
			MA_Waitframe(this, vars);
		}
		PlayAnim(this, FLYING);
		vars[V_LAZYCHASE] = 1;
		vars[V_PHASE2FLAG] = 2;
	}
	eweapon MA_FireProjectile(int x, int y, int angle, int step, int damage, int type, int args){
		eweapon e = CreateEWeaponAt(EW_SCRIPT10, x, y);
		if(type==4){
			e->DrawXOffset = -1000;
			e->DrawYOffset = -1000;
		}
		else if(type==3){
			e->UseSprite(SPR_MONARCHWINDSPEAR);
			e->Extend = 3;
			e->TileWidth = 1;
			e->TileHeight = 3;
			e->HitWidth = 16;
			e->HitHeight = 48;
			e->DrawYOffset = -48;
			e->HitYOffset = -40;
		}
		else{
			Game->PlaySound(SFX_MONARCHDUST);
			e->UseSprite(SPR_MONARCHDUST);
		}
		e->Angular = true;
		e->Angle = DegtoRad(angle);
		e->Step = step;
		e->Damage = damage;
		e->Unblockable = UNBLOCK_ALL;
		
		int scr = Game->GetEWeaponScript("MonarchAscendantWeapons");
		e->Script = scr;
		e->InitD[0] = type;
		if(IsValidArray(args)){
			int size = SizeOfArray(args);
			for(int i=0; i<size; ++i){
				e->InitD[1+i] = args[i];
			}
		}
		return e;
	}
	void MA_Waitframe(npc this, untyped vars){
		if(vars[V_PHASE2FLAG]==0){
			if(this->HP<=vars[V_INITHP]*(vars[V_PHASE2PERCENTAGE]/100)){
				vars[V_PHASE2FLAG] = 1;
			}
		}
		if(vars[V_FLYING]){
			vars[V_HOVERT] = (vars[V_HOVERT]+1)%360;
			this->FakeJump = 0;
			this->FakeZ = vars[V_Z]+vars[V_Z]*0.3333+Sin(vars[V_HOVERT]*4); 
			
			if(vars[V_LAZYCHASE]){
				int accel = 0.05;
				if(Distance(this->X, this->Y, vars[V_TX], vars[V_TY])>64){
					accel = 0.1;
				}
				else if(Distance(this->X, this->Y, vars[V_TX], vars[V_TY])>32){
					accel = 0.075;
				}
				
				vars[V_VX] = Clamp(vars[V_VX]+Sign(vars[V_TX]-this->X)*accel, -1.5, 1.5);
				vars[V_VY] = Clamp(vars[V_VY]+Sign(vars[V_TY]-this->Y)*accel, -1.5, 1.5);
				MoveXY(this, vars[V_VX], vars[V_VY], AM_IGNOREALLOFFSCREEN);
			}
			
			this->X = Clamp(this->X, -48, 256+16);
			this->Y = Clamp(this->Y, -48, 176+16);
		}
		if(this->HP<=0){
			PlayDeathAnim(this);
		}
		UpdateAnims(this);
		Waitframe();
	}
	void MA_Waitframe(npc this, untyped vars, int frames){
		for(int i=0; i<frames; ++i){
			MA_Waitframe(this, vars);
		}
	}
}

eweapon script MonarchAscendantWeapons{
	void run(int type, int d1, int d2, int d3, int d4, int d5, int d6, int d7){
		int xy[2] = {this->X, this->Y};
		int t[1];
		switch(type){
			case 0: //Dust when flying
				for(int i=0; i<48; ++i){
					this->DrawXOffset = i%4<2?-1000:0;
					this->Step = Lerp(0, 80, i/47);
					SineMotion(this, xy, t, 4, Lerp(0, 8, i/47));
					Waitframe();
				}
				while(true){
					SineMotion(this, xy, t, 4, 8);
					Waitframe();
				}
				break;
			case 1: //Dust swirl when landing
				int step = this->Step;
				int moveTime = d1;
				for(int i=0; i<moveTime; ++i){
					this->Step = Lerp(step, 0, i/moveTime);
					SineMotion(this, xy, t, 16, 4);
					Waitframe();
				}
				for(int i=0; i<16; ++i){
					this->DrawXOffset = i%4<2?-1000:0;
					SineMotion(this, xy, t, 16, 4);
					Waitframe();
				}
				this->DeadState = 0;
				break;
			case 2: //Jittering dust
				int step = this->Step;
				npc parent;
				if(d1)
					parent = Screen->LoadNPCByUID(d1);
				int moveTime = d2;
				for(int i=0; i<moveTime; ++i){
					this->Step = Lerp(step, 0, i/moveTime);
					SineMotion(this, xy, t, 16, 4);
					Waitframe();
				}
				const int DUST_LIFESPAN = 360;
				for(int i=0; i<DUST_LIFESPAN; ++i){
					this->X += Rand(-1, 1);
					this->Y += Rand(-1, 1);
					if(Distance(Link->X, Link->Y, this->X, this->Y)<48){
						if(Rand(4)==0){
							int tX = Link->X+Rand(-24, 24);
							int tY = Link->Y+Rand(-24, 24);
							this->X += Sign(tX-this->X);
							this->Y += Sign(tY-this->Y);
						}
					}
					else if(parent->isValid()){
						if(Rand(4)==0){
							int tX = parent->X+8+Rand(-24, 24);
							int tY = parent->Y+8+Rand(-24, 24);
							this->X += Sign(tX-this->X);
							this->Y += Sign(tY-this->Y);
						}
					}
					if(i>DUST_LIFESPAN-60)
						this->DrawXOffset = i%4<2?-1000:0;
					Waitframe();
				}
				this->DeadState = 0;
				break;
			case 3: //Vortex Spear
				this->Unblockable = UNBLOCK_ALL;
				this->DrawYOffset = -48;
				this->HitYOffset = -48;
				int step = this->Step;
				this->Step = 0;
				Waitframes(d1);
				Game->PlaySound(SFX_MONARCHWINDSPEAR);
				int yOff = this->DrawYOffset;
				while(this->Y+this->HitYOffset<176){
					yOff += step/100;
					this->DrawYOffset = yOff;
					this->HitYOffset = yOff;
					
					Waitframe();
				}
				break;
			case 4: //Cocoon
				this->DrawYOffset = -1000;
				this->CollDetection = false;
				
				int spawnID = d1;
				int delay = d2;
				int angle = d3;
				int dist = d4;
				int rotate = d5;
				int endDelay = d6;
				int curDist;
				
				if(delay){
					for(int i=0; i<delay; ++i){
						angle = WrapDegrees(angle+rotate);
						Waitframe();
					}
				}
				Game->PlaySound(SFX_MONARCHCOCOON);
				npc spawn = CreateNPCAt(spawnID, this->X, this->Y); 
				int scriptSlot = Game->GetNPCScript("MonarchSpawn");
				spawn->Script = scriptSlot;
				spawn->InitD[0] = 0;
				for(int i=0; i<16; ++i){
					curDist = Lerp(0, dist, i/15);
					angle = WrapDegrees(angle+rotate);
					if(spawn->isValid()&&spawn->HP>0){
						spawn->X = Clamp(this->X+VectorX(curDist, angle), -32, 256+16);
						spawn->Y = Clamp(this->Y+VectorY(curDist, angle), -32, 176+16);
					}
					else{
						this->DeadState = 0;
						Quit();
					}
					Waitframe();
				}
				int waitBreak;
				for(int i=0; i<240+endDelay-delay||waitBreak>0; ++i){
					angle = WrapDegrees(angle+rotate);
					if(spawn->isValid()&&spawn->HP>0){
						spawn->X = Clamp(this->X+VectorX(curDist, angle), -32, 256+16);
						spawn->Y = Clamp(this->Y+VectorY(curDist, angle), -32, 176+16);
					}
					else{
						this->DeadState = 0;
						Quit();
					}
					if(spawn->X<0||spawn->X>240||spawn->Y<0||spawn->Y>160)
						waitBreak = Rand(16, 24);
					if(waitBreak)
						--waitBreak;
					Waitframe();
				}
				spawn->InitD[0] = 1;
				this->DeadState = 0;
				Quit();
				break;
		}
	}
	void SineMotion(eweapon this, int xy, int t, int speed, int amp){
		xy[0] += VectorX(this->Step/100, RadtoDeg(this->Angle));
		xy[1] += VectorY(this->Step/100, RadtoDeg(this->Angle));
		
		t[0] = (t[0]+1)%360;
		this->X = xy[0]+amp*Sin(t[0]*speed);
		this->Y = xy[1];
	}
}

npc script MonarchSpawn{
	using namespace NPCAnim;
	using namespace NPCAnim::Legacy;
	void run(int activate){
		enum Animations{
			FLYING
		};
		
		AnimHandler aptr = new AnimHandler(this);
		
		AddAnim(aptr, FLYING, 0, 2, 4, 0);
			
		while(this->InitD[0]==0){
			Waitframe(this);
		}
		
		int maxStep = Rand(10, 16)/10;
		int accel = maxStep/40;
		int angle = Angle(this->X, this->Y, Link->X, Link->Y)+Rand(-45, 45);
		int step = Rand(4, maxStep*10)/10;
		int vX = VectorX(step*0.5, angle);
		int vY = VectorY(step*0.5, angle);
		
		while(Distance(Link->X, Link->Y, this->X, this->Y)>16&&this->HP>0){
			if(Distance(Link->X, Link->Y, this->X, this->Y)<48){
				vX += Sign(Link->X-this->X)*accel*0.3333;
				vY += Sign(Link->Y-this->Y)*accel*0.3333;
			}
			else{
				vX += Sign(Link->X-this->X)*accel;
				vY += Sign(Link->Y-this->Y)*accel;
			}
			int dist = Distance(0, 0, vX, vY);
			int angle = Angle(0, 0, vX, vY);
			if(dist>maxStep){
				vX = VectorX(maxStep, angle);
				vY = VectorY(maxStep, angle);
			}
			MoveXY(this, vX, vY, AM_IGNOREALLOFFSCREEN);
			Waitframe(this);
		}
		if(this->HP>0){
			this->ItemSet = 0;
			this->HP = 0;
			for(int i=0; i<6; ++i){
				MonarchAscendant.MA_FireProjectile(this->X, this->Y, Rand(360), Rand(100, 150), this->WeaponDamage, 2, {0, 24});
			}
		}
	}
}