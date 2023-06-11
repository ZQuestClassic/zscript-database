//Sideview falling objects
//They can be stalactites, icicles or even chandeliers.

//These constants define object states. Don`t change them.
const int FALL_MODE_DORMANT = 0; // An object waits for Link to come near
const int FALL_MODE_WARNING = 1; // An objest is about to fall
const int FALL_MODE_ACTIVE = 2; // An object is in free-fall.

//These two constants can be changed.
const int WARNING_CSET = 8;  //Cset used for warning.
const int WARN_TIME = 30; // Warning time, in frames.


//A falling object that breaks into damaging partcles on hitting ground.
//
//D0: Damage done by hitting Link directly, in 1/16th of hearts.
//D1: Sound to play when hitting solid combo.
//D2: Sprite used by shards.
//D3: Damage dealt by shards. Leaving as 0 disables collision with shards.
//D4: Number of shards produced on hitting ground.
//D5: Eweapon type used for shards. Refer for std_constants.zh for which eweapon type to create.
//D6: Shards` flight speed.
ffc script SideviewFallingObject{
	void run(int damage, int crashsound, int shardsprite, int sharddamage, int numshards, int ewtype, int shardspeed) {
		if (!(IsSideview())) Quit();
		int mode = FALL_MODE_DORMANT;
		while (mode == FALL_MODE_DORMANT){
			if ((CenterLinkX() > this->X)&&(CenterLinkX()<(this->X + this->EffectWidth))){
				if (Link->Y > this->Y) mode = FALL_MODE_WARNING;
			}
			Waitframe();
		}
		this->CSet = WARNING_CSET;
		int OrigX = this->X;
		for (int i = 0; i<=WARN_TIME; i++){
			if (IsOdd(i)) this->X = OrigX-1;
			else this->X = OrigX+1;
			Waitframe();
		}
		this->X = OrigX;
		mode = FALL_MODE_ACTIVE;
		int mercy = 0;
		Game->PlaySound(SFX_FALL);
		while (!(Screen->isSolid((this->X+(this->EffectWidth/2)), (this->Y + this->EffectHeight)))){
			if ((LinkCollision(this))&&(mercy==0)){
				Game->PlaySound(SFX_OUCH);
				Link->HitDir = OppositeDir(Link->Dir);
				if (Link->Action==LA_SWIMMING)Link->Action = LA_GOTHURTWATER;
				else Link->Action = LA_GOTHURTLAND;
				Link->HP -= damage;
				mercy = 60;
			}
			if (this->Vy >= TERMINAL_VELOCITY){
				this->Vy = TERMINAL_VELOCITY;
				this->Ay = 0;
			}
			else this->Ay = GRAVITY;
			if (this->Y>176){
				this->Data=0;
				Quit();
			}
			if (mercy>0) mercy--;
			Waitframe();
		}
		Game->PlaySound(crashsound);
		this->Ay=0;
		this->Vy=0;
		float angle = -(PI/(numshards))/2;
		float anglediff = (PI/(numshards));
		eweapon shard;
		for (int i=1; i<=numshards; i++){

			shard = Screen->CreateEWeapon(ewtype);
			shard->X = (this->X + (this->EffectWidth)/2);
			shard->Y = (this->Y + (this->EffectHeight));
			shard->Damage = sharddamage;
			shard->UseSprite(shardsprite);
			if (sharddamage<=0) shard->CollDetection=false;
			shard->Angular = true;
			shard->Angle = angle;
			shard->Step=shardspeed;
			angle = angle - anglediff;
		}
		this->Data=0;
	}
}

//A simpler version of the script that ignores combo solidity.
//
//D0: Damage dealt to Link on direct hit.

ffc script SideviewFallingObjectSimple{
	void run(int damage) {
		if (!(IsSideview())) Quit();
		int mode = FALL_MODE_DORMANT;
		while (mode == FALL_MODE_DORMANT){
			if ((CenterLinkX() > this->X)&&(CenterLinkX()<(this->X + this->EffectWidth))){
				if (Link->Y > this->Y) mode = FALL_MODE_WARNING;
			}
			Waitframe();
		}
		this->CSet = WARNING_CSET;
		int OrigX = this->X;
		for (int i = 0; i<=WARN_TIME; i++){
			if (IsOdd(i)) this->X = OrigX-1;
			else this->X = OrigX+1;
			Waitframe();
		}
		this->X = OrigX;
		mode = FALL_MODE_ACTIVE;
		Game->PlaySound(SFX_FALL);
		int mercy = 0;
		while (true){
			if ((LinkCollision(this))&&(mercy==0)){
				Game->PlaySound(SFX_OUCH);
				Link->HitDir = OppositeDir(Link->Dir);
				if (Link->Action==LA_SWIMMING)Link->Action = LA_GOTHURTWATER;
				else Link->Action = LA_GOTHURTLAND;
				Link->HP -= damage;
				mercy = 45;
			}
			if (this->Vy >= TERMINAL_VELOCITY){
				this->Vy = TERMINAL_VELOCITY;
				this->Ay = 0;
			}
			else this->Ay = GRAVITY;
			if (mercy>0) mercy--;
			if (this->Y>176){
				this->Data=0;
				Quit();
			}
			Waitframe();
		}
	}
	
}