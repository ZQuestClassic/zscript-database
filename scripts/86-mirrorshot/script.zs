//import "std.zh"

const int LW_MIRRORSHOT = 31; //The LWeapon used for the Mirrorshot. It currently uses the Script1 LWeapon.
const int LW_REFWEAPON = 36; //The LWeapon used for the reflected EWeapons.

//Reflect Flags. Sum up the following values in the comments to determine what the Mirrorshot will reflect.
const int REF_ROCK =		 0000000000000001b; //1.
const int REF_ARROW =		0000000000000010b; //2.
const int REF_BOOMERANG =	0000000000000100b; //4.
const int REF_FIREBALL =	 0000000000001000b; //8.
const int REF_BEAM =		 0000000000010000b; //16.
const int REF_MAGIC =		0000000000100000b; //32.
const int REF_FIRE =		 0000000001000000b; //64.
const int REF_ICE =		  0000000010000000b; //128. Implement it yourself with EW_SCRIPT6 or wait until ZC 3.0 to use.
const int REF_FIREBALL2 =	0000000100000000b; //256.
const int REF_BOMB =		 0000001000000000b; //512.
const int REF_SBOMB =		0000010000000000b; //1024.
const int REF_SCRIPT1 =	  0000100000000000b; //2048.
const int REF_SCRIPT2 =	  0001000000000000b; //4096.
const int REF_SCRIPT3 =	  0010000000000000b; //8192.
const int REF_SCRIPT4 =	  0100000000000000b; //16384.
const int REF_SCRIPT5 =	  1000000000000000b; //32768.
const int REF_DEFSMALLSBLK = 0000000000000111b; //7. What the Small Shield would block by default.
const int REF_DEFMAGICSBLK = 0000000000111111b; //63. What the Magic Shield would block by default.
const int REF_DEFMIRRORBLK = 0000000001111111b; //127. What the Mirror Shield would block by default.
const int REF_DEFMIRRORREF = 0000000000101000b; //40. What the Mirror Shield would reflect by default.
const int REF_ALL =		  1111111111111111b; //65535. Reflects all.

int MS_counter;
int MS_magazine;
int MS_SFX;
int MS_damage;
int MS_step;
int MS_sprite;
int MS_cset;
int MS_reflect;
int MS_Mirrorshot = 0; //Don't change this!

global script slot_2{
	void run(){
		while(true){
		Mirrorshotuse(); //Put this function in the while loop your global script to use the script after you copy all of the code.
		Waitframe();
		}
	}
	void Mirrorshotuse(){ //The actual Mirrorshot script.
		if(Game->Counter[MS_counter] >= MS_magazine && MS_Mirrorshot == 1){ //Checks if you have enough of the specififed counter, determined by the D0 and D1 variables in the item.
			Game->Counter[MS_counter] -= MS_magazine;
			Link->Action = LA_ATTACKING;
			Game->PlaySound(MS_SFX); //Plays the weapon's SFX, determined by the D2 variable.
			lweapon Shot = CreateLWeaponAt(LW_MIRRORSHOT, Link->X, Link->Y); //Creates the projectile.
			Shot->Damage = MS_damage; //Sets it's damage to the D3 variable in the item.
			Shot->Dir = Link->Dir; //Sends the weapon flying in front of Link.
			Shot->Step = MS_step; //Sets it's speed, in pixels per second, to the D4 variable in the item.
			Shot->Tile = MS_sprite + Shot->Dir; //Adjusts it's sprite, determined by the D5 variable in the item, to what direction it is fired in.
			Shot->CSet = MS_cset; //Sets it's CSet to the D6 variable in the item.
			while(Shot->isValid()){ //Where the reflective properites if the LWeapon come into play.
				for(int i; i <= Screen->NumEWeapons(); i ++){ //Cycle through all EWeapons on the screen...
					eweapon ewpn = Screen->LoadEWeapon(i);
					if(IsReflectable(ewpn, MS_reflect)){
						if(Collision(Shot, ewpn) && ewpn->Step != 0){ //Check if any collides with the LWeapon...
							ewpn->Dir = OppositeDir(ewpn->Dir);
							ewpn->Angle = -(ewpn->Angle*2);
							ChangeToLWeapon(ewpn, ReflectedWeaponTypes(ewpn)); //If any does, replace it with with a LWeapon and send it flying in the other direction.
							Game->PlaySound(SFX_CLINK);
						}
						else if(Collision(Shot, ewpn) && ewpn->Step == 0){ //If the LWeapon collides with a stationary EWeapon...
							ewpn->DeadState = 0; //The EWeapon gets destroyed.
						}
					}
				}
				Waitframe();
			}
			MS_Mirrorshot --;
		}
	}
}

bool IsReflectable(eweapon wpn, int ref){
	if(wpn->ID == EW_ROCK && (ref & REF_ROCK) != 0){
		return true;
	}
	else if(wpn->ID == EW_ARROW && (ref & REF_ARROW) != 0){
		return true;
	}
	else if(wpn->ID == EW_BRANG && (ref & REF_BOOMERANG) != 0){
		return true;
	}
	else if(wpn->ID == EW_FIREBALL && (ref & REF_FIREBALL) != 0){
		return true;
	}
	else if(wpn->ID == EW_BEAM && (ref & REF_BEAM) != 0){
		return true;
	}
	else if(wpn->ID == EW_MAGIC && (ref & REF_MAGIC) != 0){
		return true;
	}
	else if((wpn->ID == EW_FIRE || wpn->ID == EW_FIRE2 || wpn->ID == EW_FIRETRAIL)  && (ref & REF_FIRE) != 0){
		return true;
	}
	else if(wpn->ID == EW_SCRIPT6 && (ref & REF_ICE) != 0){
		return true;
	}
	else if(wpn->ID == EW_FIREBALL2 && (ref & REF_FIREBALL2) != 0){
		return true;
	}
	else if(wpn->ID == EW_BOMB && (ref & REF_BOMB) != 0){
		return true;
	}
	else if(wpn->ID == EW_SBOMB && (ref & REF_SBOMB) != 0){
		return true;
	}
	else if(wpn->ID == EW_SCRIPT1 && (ref & REF_SCRIPT1) != 0){
		return true;
	}
	else if(wpn->ID == EW_SCRIPT2 && (ref & REF_SCRIPT2) != 0){
		return true;
	}
	else if(wpn->ID == EW_SCRIPT3 && (ref & REF_SCRIPT3) != 0){
		return true;
	}
	else if(wpn->ID == EW_SCRIPT4 && (ref & REF_SCRIPT4) != 0){
		return true;
	}
	else if(wpn->ID == EW_SCRIPT5 && (ref & REF_SCRIPT5) != 0){
		return true;
	}
	else{
		return false;
	}
}

int ReflectedWeaponTypes(eweapon wpn){
	if(wpn->ID == EW_FIREBALL || wpn->ID == EW_FIREBALL2){
		return LW_REFFIREBALL;
	}
	else if(wpn->ID == EW_MAGIC){
		return LW_REFMAGIC;
	}
	else if(wpn->ID == EW_BEAM){
		return LW_REFBEAM;
	}
	else if(wpn->ID == EW_ROCK){
		return LW_REFROCK;
	}
	else{
		return LW_REFWEAPON;
	}
}

void ChangeToLWeapon(eweapon a, int c){ //Replaces an EWeapon with a LWeapon. Based on the Duplicate function in std.zh.
	lweapon b = Screen->CreateLWeapon(c);
	b->X = a->X;
	b->Y = a->Y;
	b->Z = a->Z;
	b->Jump = a->Jump;
	b->Extend = a->Extend;
	b->TileWidth = a->TileWidth;
	b->TileHeight = a->TileHeight;
	b->HitWidth = a->HitWidth;
	b->HitHeight = a->HitHeight;
	b->HitZHeight = a->HitZHeight;
	b->HitXOffset = a->HitXOffset;
	b->HitYOffset = a->HitYOffset;
	b->DrawXOffset = a->DrawXOffset;
	b->DrawYOffset = a->DrawYOffset;
	b->DrawZOffset = a->DrawZOffset;
	b->Tile = a->Tile;
	b->CSet = a->CSet;
	b->DrawStyle = a->DrawStyle;
	b->Dir = a->Dir;
	b->OriginalTile = a->OriginalTile;
	b->OriginalCSet = a->OriginalCSet;
	b->FlashCSet = a->FlashCSet;
	b->NumFrames = a->NumFrames;
	b->Frame = a->Frame;
	b->ASpeed = a->ASpeed;
	b->Damage = a->Damage;
	b->Step = a->Step;
	b->Angle = a->Angle;
	b->Angular = a->Angular;
	b->CollDetection = a->CollDetection;
	b->DeadState = a->DeadState;
	b->Flash = a->Flash;
	b->Flip = a->Flip;
	for (int i = 0; i < 16; i++){
		b->Misc[i] = a->Misc[i];
	}
	a->DeadState = 0;
}

//This script used with the global script creates a new weapon called the MirrorShot
//The MirrorShot fires a shot that reflects EWeapons that it touches.
//It isn't very useful in most combat situations, as you can only currently have
//one projectile on the screen at a time.
//It is a handy tool to use in puzzles, though.
//Variables:
//D0: The Counter used for this weapon.
//D1: The amount of [D0] counter it detracts from.
//D2: The SFX played when firing it.
//D3: The amount of damage it deals. 2 = Wooden Sword damage.
//D4: The step speed of the weapon.
//D5: The tile that the projectile uses. Applies to the upward-facing tile. The
//tiles should be going in this order: UP, DOWN, LEFT, RIGHT.
//D6: The CSet that the projectile uses.
//D7: The reflection flags that the projectile uses. See the constants at the top for the list of flags.
item script MirrorShot{
	void run(int ctr, int mag, int sfx, int dmg, int stp, int spt, int cset, int ref){
		MS_counter = ctr;
		MS_magazine = mag;
		MS_SFX = sfx;
		MS_damage = dmg;
		MS_step = stp;
		MS_sprite = spt;
		MS_cset = cset;
		MS_reflect = ref;
		if(Game->Counter[ctr] >= mag && MS_Mirrorshot == 0){ //Checks if the weapon is not in use.
			MS_Mirrorshot = 1; //... If not, run the global fuction of the script.
		}
	}
}