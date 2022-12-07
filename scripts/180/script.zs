// stdCombos MERGED v1.1 and 2.0 and 3.0 + 3.1

//stdCombos.zh
//
//This header is used to detect collision between various in-game objects and combos.
//Return INT means return location of first combo that has tripped collision.
//
//v1.1 BETA

//If you want just to check if an object collides with any combo with specific flag/type, use
//piece of code like this:
//
// if (ComboTypeCollision (type, ffc)>=0){
//   foo
//   }
//

// Returns TRUE if there is a collision between the combo and an arbitrary rectangle.
bool ComboCollision (int loc, int x1, int y1, int x2, int y2){
	return RectCollision( ComboX(loc), ComboY(loc), (ComboX(loc)+15), (ComboY(loc)+15), x1, y1, x2, y2);
}

// Returns TRUE if there is a collision between FFC and the combo on screen.
bool ComboCollision (int loc, ffc f){
	int ax = (f->X);
	int ay = (f->Y);
	int bx = ax+(f->EffectWidth)-1;
	int by = ay+(f->EffectHeight)-1;
	int cx = ComboX(loc);
	int cy = ComboY(loc);
	int dx = ComboX(loc)+15;
	int dy = ComboY(loc)+15;
	return RectCollision( cx, cy, dx, dy, ax, ay, bx, by);
}

// Returns INT if FFC collides with a combo of specific type
int ComboTypeCollision (int type, ffc f){
	for (int i=0; i<176; i++){
		if (Screen->ComboT[i]==type){
			if (ComboCollision(i, f)) return i;
		}
	}
	return -1;
}


// Returns INT if FFC collides with a combo which has specific placed flag
int ComboFlagCollision (int flag, ffc f){
	for (int i = 0; i<176; i++){
		if (Screen->ComboF[i]==flag){
			if (ComboCollision(i, f)) return i;
		}
	}
	return -1;
}


// Returns INT if FFC collides with a combo which has specific inherent flag. 
int ComboIFlagCollision (int flag, ffc f){
	for (int i = 0; i<176; i++){
		if (Screen->ComboI[i]==flag){
			if (ComboCollision(i, f)) return i;
		}
	}
	return -1;
}


// Returns INT if FFC collides with a combo which has specific either inherent or placed flag.
int ComboAnyFlagCollision (int flag, ffc f){
	for (int i = 0; i<176; i++){
		if (ComboFI(i, flag)){
			if (ComboCollision(i, f)) return i;
		}
	}
	return -1;
}


// Returns TRUE if there is a collision between Lweapon and the combo on screen.
bool ComboCollision (int loc, lweapon f){
	if (!(f->CollDetection)) return false;
	int ax = (f->X)+f->HitXOffset;
	int ay = (f->Y)+f->HitYOffset;
	int bx = ax+f->HitWidth -1;
	int by = ay+f->HitHeight -1;
	int cx = ComboX(loc);
	int cy = ComboY(loc);
	int dx = ComboX(loc)+15;
	int dy = ComboY(loc)+15;
	return RectCollision( cx, cy, dx, dy, ax, ay, bx, by);
}

// Returns INT if Lweapon collides with a combo of specific type
int ComboTypeCollision (int type, lweapon f){
	for (int i=0; i<176; i++){
		if (Screen->ComboT[i]==type){
			if (ComboCollision(i, f)) return i;
		}
	}
	return -1;
}


// Returns INT if Lweapon collides with a combo which has specific placed flag
int ComboFlagCollision (int flag, lweapon f){
	for (int i = 0; i<176; i++){
		if (Screen->ComboF[i]==flag){
			if (ComboCollision(i, f)) return i;
		}
	}
	return -1;
}


// Returns INT if Lweapon collides with a combo which has specific inherent flag. 
int ComboIFlagCollision (int flag, lweapon f){
	for (int i = 0; i<176; i++){
		if (Screen->ComboI[i]==flag){
			if (ComboCollision(i, f)) return i;
		}
	}
	return -1;
}


// Returns INT if Lweapon collides with a combo which has specific either inherent or placed flag.
int ComboAnyFlagCollision (int flag, lweapon f){
	for (int i = 0; i<176; i++){
		if (ComboFI(i, flag)){
			if (ComboCollision(i, f)) return i;
		}
	}
	return -1;
}


// Returns TRUE if there is a collision between Eweapon and the combo on screen.
bool ComboCollision (int loc, eweapon f){
	int ax = (f->X)+(f->HitXOffset);
	int ay = (f->Y)+(f->HitYOffset);
	int bx = ax+(f->HitWidth)-1;
	int by = ay+(f->HitHeight)-1;
	if (!(f->CollDetection)) return false;
	int cx = ComboX(loc);
	int cy = ComboY(loc);
	int dx = ComboX(loc)+15;
	int dy = ComboY(loc)+15;
	return RectCollision( cx, cy, dx, dy, ax, ay, bx, by);
}

// Returns INT if EWeapon collides with a combo of specific type
int ComboTypeCollision (int type, eweapon f){
	for (int i=0; i<176; i++){
		if (Screen->ComboT[i]==type){
			if (ComboCollision(i, f)) return i;
		}
	}
	return -1;
}


// Returns INT if EWeapon collides with a combo which has specific placed flag
int ComboFlagCollision (int flag, eweapon f){
	for (int i = 0; i<176; i++){
		if (Screen->ComboF[i]==flag){
			if (ComboCollision(i, f)) return i;
		}
	}
	return -1;
}


// Returns INT if EWeapon collides with a combo which has specific inherent flag.
int ComboIFlagCollision (int flag, eweapon f){
	for (int i = 0; i<176; i++){
		if (Screen->ComboI[i]==flag){
			if (ComboCollision(i, f)) return i;
		}
	}
	return -1;
}

// Returns INT if EWeapon collides with a combo which has specific either inherent or placed flag.
int ComboAnyFlagCollision (int flag, eweapon f){
	for (int i = 0; i<176; i++){
		if (ComboFI(i, flag)){
			if (ComboCollision(i, f)) return i;
		}
	}
	return -1;
}

// Returns TRUE if there is a collision between NPC and the combo on screen.
bool ComboCollision (int loc, npc f){
	int ax = (f->X)+(f->HitXOffset);
	int ay = (f->Y)+(f->HitYOffset);
	int bx = ax+(f->HitWidth)-1;
	int by = ay+(f->HitHeight)-1;
	if (!(f->CollDetection)) return false;
	int cx = ComboX(loc);
	int cy = ComboY(loc);
	int dx = ComboX(loc)+15;
	int dy = ComboY(loc)+15;
	return RectCollision( cx, cy, dx, dy, ax, ay, bx, by);
}

// Returns INT if NPC collides with a combo of specific type
int ComboTypeCollision (int type, npc f){
	for (int i=0; i<176; i++){
		if (Screen->ComboT[i]==type){
			if (ComboCollision(i, f)) return i;
		}
	}
	return -1;
}

// Returns INT if NPC collides with a combo which has specific placed flag.
int ComboFlagCollision (int flag, npc f){
	for (int i = 0; i<176; i++){
		if (Screen->ComboF[i]==flag){
			if (ComboCollision(i, f)) return i;
		}
	}
	return -1;
}

// Returns INT if NPC collides with a combo which has specific inherent flag.
int ComboIFlagCollision (int flag, npc f){
	for (int i = 0; i<176; i++){
		if (Screen->ComboI[i]==flag){
			if (ComboCollision(i, f)) return i;
		}
	}
	return -1;
}

// Returns INT if NPC collides with a combo which has specific either inherent or placed flag.
int ComboAnyFlagCollision (int flag, npc f){
	for (int i = 0; i<176; i++){
		if (ComboFI(i, flag)){
			if (ComboCollision(i, f)) return i;
		}
	}
	return -1;
}

//Returns TRUE if there is a collision between the combo and dropped item.
bool ComboCollision (int loc, item f){
	int ax = (f->X)+(f->HitXOffset);
	int ay = (f->Y)+(f->HitYOffset);
	int bx = ax+(f->HitWidth)-1;
	int by = ay+(f->HitHeight)-1;
	int cx = ComboX(loc);
	int cy = ComboY(loc);
	int dx = ComboX(loc)+15;
	int dy = ComboY(loc)+15;
	return RectCollision( cx, cy, dx, dy, ax, ay, bx, by);
}

//Returns INT if dropped item collides with a combo of specific type
int ComboTypeCollision (int type, item f){
	for (int i=0; i<176; i++){
		if (Screen->ComboT[i]==type){
			if (ComboCollision(i, f)) return i;
		}
	}
	return -1;
}

//Returns INT if dropped item collides with a combo which has specific placed flag.
int ComboFlagCollision (int flag, item f){
	for (int i=0; i<176; i++){
		if (Screen->ComboF[i]==flag){
			if (ComboCollision(i, f)) return i;
		}
	}
	return -1;
}

//Returns INT if dropped item collides with a combo which has specific inherent flag.
int ComboIFlagCollision (int flag, item f){
	for (int i=0; i<176; i++){
		if (Screen->ComboI[i]==flag){
			if (ComboCollision(i, f)) return i;
		}
	}
	return -1;
}

//Returns INT if dropped item collides with a combo which has specific either interent or placed flag.
int ComboAnyFlagCollision (int flag, item f){
	for (int i = 0; i<176; i++){
		if (ComboFI(i, flag)){
			if (ComboCollision(i, f)) return i;
		}
	}
	return -1;
}



//Link-to-Combo interaction functions
//
//All these functions use the so called "sensivity" which works like "Damage combo sensivity"
//value in "Screen Data" window in ZQuest. 

//Returns TRUE if Link touches the combo.
bool LinkComboCollision(int loc, int sens){
	int ax = Link->X;
	int ay = Link->Y;
	int bx = (Link->X)+(Link->HitWidth)-1;
	int by = (Link->Y)+(Link->HitHeight)-1;
	if(!(RectCollision( ComboX(loc), ComboY(loc), (ComboX(loc)+15), (ComboY(loc)+15), ax, ay, bx, by))) return false;
	else if (!(Distance(CenterLinkX(), CenterLinkY(), (ComboX(loc)+8), (ComboY(loc)+8)) < (sens+8))) return false;
	else return true;
}

//Returns TRUE if Link touches the combo.
bool LinkComboCollision(int loc, int sens, int size){
	int ax = Link->X;
	int ay = Link->Y;
	int bx = (Link->X)+(Link->HitWidth)-1;
	int by = (Link->Y)+(Link->HitHeight)-1;
	if(!(RectCollision( ComboX(loc), ComboY(loc), (ComboX(loc)+size), (ComboY(loc)+size), ax, ay, bx, by))) return false;
	else if (!(Distance(CenterLinkX(), CenterLinkY(), (ComboX(loc)+(size/2)), (ComboY(loc)+(size/2))) < (sens+(size/2)))) return false;
	else return true;
}

//Same as LinkComboCollision, but only bottom half is checked (Link "steps" on the combo).
bool LinkComboStepped(int loc, int sens){
	int ax = Link->X;
	int ay = (Link->Y)+8;
	int bx = (Link->X)+(Link->HitWidth)-1;
	int by = (Link->Y)+((Link->HitHeight)/2);
	if(!(RectCollision( ComboX(loc), ComboY(loc), (ComboX(loc)+15), (ComboY(loc)+15), ax, ay, bx, by))) return false;
	else if (!(Distance(CenterLinkX(), CenterLinkY(), (ComboX(loc)+8), (ComboY(loc)+8)) < (sens+8))) return false;
	else return true;
}

//Returns INT if Link touches any combo of specific type.
int LinkComboTypeCollision(int type, int sens){
	for(int i = 0; i < 176; i++){
		if (Screen->ComboT[i]==type){
			if (LinkComboCollision(i, sens)) return i;
		}
	}
	return -1;
}

//Returns INT if Link touches any combo of specific type.
int LinkComboTypeCollision(int type, int sens, int size){
	for(int i = 0; i < 176; i++){
		if (Screen->ComboT[i]==type){
			if (LinkComboCollision(i, sens,size)) return i;
		}
	}
	return -1;
}

//Returns INT if Link steps on any combo of specific type.
int LinkComboTypeStepped(int type, int sens){
	for(int i = 0; i < 176; i++){
		if (Screen->ComboT[i]==type){
			if (LinkComboStepped(i, sens)) return i;
		}
	}
	return -1;
}


//Returns INT if Link touches any combo with specific placed flag.
int LinkComboFlagCollision(int flag, int sens){
	for(int i = 0; i < 176; i++){
		if (Screen->ComboF[i]==flag){
			if (LinkComboCollision(i, sens)) return i;
		}
	}
	return -1;
}

//Returns INT if Link steps on any combo with specific placed flag.
int LinkComboFlagStepped(int flag, int sens){
	for(int i = 0; i < 176; i++){
		if (Screen->ComboF[i]==flag){
			if (LinkComboStepped(i, sens)) return i;
		}
	}
	return -1;
}

//Returns INT if Link touches any combo with specific inherent flag.
int LinkComboIFlagCollision(int flag, int sens){
	for(int i = 0; i < 176; i++){
		if (Screen->ComboI[i]==flag){
			if (LinkComboCollision(i, sens)) return i;
		}
	}
	return -1;
}

//Returns INT if Link steps on any combo with specific inherent flag.
int LinkComboIFlagStepped(int flag, int sens){
	for(int i = 0; i < 176; i++){
		if (Screen->ComboI[i]==flag){
			if (LinkComboStepped(i, sens)) return i;
		}
	}
	return -1;
}

//Returns INT if Link touches any combo with specific either inherent or placed flag.
int LinkComboAnyFlagCollision(int flag, int sens){
	for(int i = 0; i < 176; i++){
		if (ComboFI(i, flag)){
			if (LinkComboCollision(i, sens)) return i;
		}
	}
	return -1;
}

//Returns INT if Link steps on any combo with specific either inherent or placed flag.
int LinkComboAnyFlagStepped(int flag, int sens){
	for(int i = 0; i < 176; i++){
		if (ComboFI(i, flag)){
			if (LinkComboStepped(i, sens)) return i;
		}
	}
	return -1;
}

// The following set of 25 functions behaves exactly like previous functions 
// but has reversed order of arguments so you don`t have to remember the order of arguments.
int ComboTypeCollision (ffc f, int type){
	return ComboTypeCollision (type, f);
}

int ComboFlagCollision (ffc f, int flag){
	return ComboFlagCollision (flag, f);
}

int ComboIFlagCollision (ffc f, int flag){
	return ComboIFlagCollision (flag, f);
}

int ComboAnyFlagCollision (ffc f, int flag){
	return ComboAnyFlagCollision (flag, f);
}

int ComboTypeCollision (lweapon f, int type){
	return ComboTypeCollision (type, f);
}

int ComboFlagCollision (lweapon f, int flag){
	return ComboFlagCollision (flag, f);
}

int ComboIFlagCollision (lweapon f, int flag){
	return ComboIFlagCollision (flag, f);
}

int ComboAnyFlagCollision (lweapon f, int flag){
	return ComboAnyFlagCollision (flag, f);
}

int ComboTypeCollision (eweapon f, int type){
	return ComboTypeCollision (type, f);
}

int ComboFlagCollision (eweapon f, int flag){
	return ComboFlagCollision (flag, f);
}

int ComboIFlagCollision (eweapon f, int flag){
	return ComboIFlagCollision (flag, f);
}

int ComboAnyFlagCollision (eweapon f, int flag){
	return ComboAnyFlagCollision (flag, f);
}

int ComboTypeCollision (npc f, int flag){
	return ComboTypeCollision (flag, f);
}

int ComboFlagCollision (npc f, int flag){
	return ComboFlagCollision (flag, f);
}

int ComboIFlagCollision (npc f, int flag){
	return ComboIFlagCollision (flag, f);
}

int ComboAnyFlagCollision (npc f, int flag){
	return ComboAnyFlagCollision (flag, f);
}

int ComboTypeCollision (item f, int type){
	return ComboTypeCollision (type, f);
}

int ComboFlagCollision (item f, int flag){
	return ComboFlagCollision (flag, f);
}

int ComboIFlagCollision (item f, int flag){
	return ComboIFlagCollision (flag, f);
}

int ComboAnyFlagCollision (item f, int flag){
	return ComboAnyFlagCollision (flag, f);
}

bool ComboCollision (ffc f, int loc){
	return ComboCollision (loc, f);
}

bool ComboCollision (lweapon f, int loc){
	return ComboCollision (loc, f);
}

bool ComboCollision (eweapon f, int loc){
	return ComboCollision (loc, f);
}

bool ComboCollision (npc f, int loc){
	return ComboCollision (loc, f);
}

bool ComboCollision (item f, int loc){
	return ComboCollision (loc, f);
}

//stdCombos.zh
//
//This header is used to detect collision between various in-game objects and combos.
//Return INT means return location of first combo that has tripped collision.
//
//v2.0 BETA

//If you want just to check if an object collides with any combo with specific flag/type, use
//piece of code like this:
//
// if (ComboTypeCollision (type, ffc))>=0){
//   foo
//   }
//
//if "solidonly" boolean is TRUE, only solid portions of combos are used

// Returns TRUE if there is a collision between the combo and an arbitrary rectangle.
bool ComboCollision (int loc, int x1, int y1, int x2, int y2, bool solidonly){
	if (solidonly) return SolidComboCollision (loc, x1, y1, x2, y2);
	else return RectCollision( ComboX(loc), ComboY(loc), (ComboX(loc)+15), (ComboY(loc)+15), x1, y1, x2, y2);
}

// Returns TRUE if there is a collision between the solid portion of the combo and an arbitrary rectangle.
bool SolidComboCollision (int loc, int x1, int y1, int x2, int y2){
	int cx = ComboX(loc);
	int cy = ComboY(loc);
	int dx = cx+7;
	int dy = cy+7;
	if (Screen->isSolid(cx, cy)){
		if (RectCollision(x1, y1, x2, y2, cx, cy, dx, dy)) return true;
	}
	cx+=8;
	dx+=8;
	if (Screen->isSolid(cx, cy)){
		if (RectCollision(x1, y1, x2, y2, cx, cy, dx, dy)) return true;
	}
	cy+=8;
	dy+=8;
	if (Screen->isSolid(cx, cy)){
		if (RectCollision(x1, y1, x2, y2, cx, cy, dx, dy)) return true;
	}
	cx-=8;
	dx-=8;
	if (Screen->isSolid(cx, cy)){
		if (RectCollision(x1, y1, x2, y2, cx, cy, dx, dy)) return true;
	}
	return false;
}



// Returns TRUE if there is a collision between FFC and the combo on screen.
bool ComboCollision (int loc, ffc f, bool solidonly){
	int ax = (f->X);
	int ay = (f->Y);
	int bx = ax+(f->EffectWidth)-1;
	int by = ay+(f->EffectHeight)-1;
	int cx = ComboX(loc);
	int cy = ComboY(loc);
	int dx = ComboX(loc)+15;
	int dy = ComboY(loc)+15;
	if (solidonly) return SolidComboCollision (loc, ax, ay, bx, by);
	else return RectCollision( cx, cy, dx, dy, ax, ay, bx, by);
}

// Returns INT if FFC collides with a combo of specific type
int ComboTypeCollision (int type, ffc f, bool solidonly){
	for (int i=0; i<176; i++){
		if (Screen->ComboT[i]==type){
			if (ComboCollision(i, f, solidonly)) return i;
		}
	}
	return -1;
}


// Returns INT if FFC collides with a combo which has specific placed flag
int ComboFlagCollision (int flag, ffc f, bool solidonly){
	for (int i = 0; i<176; i++){
		if (Screen->ComboF[i]==flag){
			if (ComboCollision(i, f, solidonly)) return i;
		}
	}
	return -1;
}


// Returns INT if FFC collides with a combo which has specific inherent flag. 
int ComboIFlagCollision (int flag, ffc f, bool solidonly){
	for (int i = 0; i<176; i++){
		if (Screen->ComboI[i]==flag){
			if (ComboCollision(i, f, solidonly)) return i;
		}
	}
	return -1;
}


// Returns INT if FFC collides with a combo which has specific either inherent or placed flag.
int ComboAnyFlagCollision (int flag, ffc f, bool solidonly){
	for (int i = 0; i<176; i++){
		if (ComboFI(i, flag)){
			if (ComboCollision(i, f, solidonly)) return i;
		}
	}
	return -1;
}

// Returns INT if FFC collides with a specific combo.
int HardcodedComboCollision (int cmb, ffc f, bool solidonly){
	for (int i = 0; i<176; i++){
		if (Screen->ComboD[i]==cmb){
			if (ComboCollision(i, f, solidonly)) return i;
		}
	}
	return -1;
}

// Returns TRUE if there is a collision between Lweapon and the combo on screen.
bool ComboCollision (int loc, lweapon f, bool solidonly){
	if (!(f->CollDetection)) return false;
	int ax = (f->X)+f->HitXOffset;
	int ay = (f->Y)+f->HitYOffset;
	int bx = ax+f->HitWidth-1;
	int by = ay+f->HitHeight-1;
	int cx = ComboX(loc);
	int cy = ComboY(loc);
	int dx = ComboX(loc)+15;
	int dy = ComboY(loc)+15;
	if (solidonly) return SolidComboCollision (loc, ax, ay, bx, by);
	else return RectCollision( cx, cy, dx, dy, ax, ay, bx, by);
}

// Returns INT if Lweapon collides with a combo of specific type
int ComboTypeCollision (int type, lweapon f, bool solidonly){
	for (int i=0; i<176; i++){
		if (Screen->ComboT[i]==type){
			if (ComboCollision(i, f, solidonly)) return i;
		}
	}
	return -1;
}


// Returns INT if Lweapon collides with a combo which has specific placed flag
int ComboFlagCollision (int flag, lweapon f, bool solidonly){
	for (int i = 0; i<176; i++){
		if (Screen->ComboF[i]==flag){
			if (ComboCollision(i, f, solidonly)) return i;
		}
	}
	return -1;
}


// Returns INT if Lweapon collides with a combo which has specific inherent flag. 
int ComboIFlagCollision (int flag, lweapon f, bool solidonly){
	for (int i = 0; i<176; i++){
		if (Screen->ComboI[i]==flag){
			if (ComboCollision(i, f, solidonly)) return i;
		}
	}
	return -1;
}


// Returns INT if Lweapon collides with a combo which has specific either inherent or placed flag.
int ComboAnyFlagCollision (int flag, lweapon f, bool solidonly){
	for (int i = 0; i<176; i++){
		if (ComboFI(i, flag)){
			if (ComboCollision(i, f, solidonly)) return i;
		}
	}
	return -1;
}

// Returns INT if Lweapon collides with a specific combo.
int HardcodedComboCollision (int cmb, lweapon f, bool solidonly){
	for (int i = 0; i<176; i++){
		if (Screen->ComboD[i]==cmb){
			if (ComboCollision(i, f, solidonly)) return i;
		}
	}
	return -1;
}


// Returns TRUE if there is a collision between Eweapon and the combo on screen.
bool ComboCollision (int loc, eweapon f, bool solidonly){
	int ax = (f->X)+(f->HitXOffset);
	int ay = (f->Y)+(f->HitYOffset);
	int bx = ax+(f->HitWidth)-1;
	int by = ay+(f->HitHeight)-1;
	if (!(f->CollDetection)) return false;
	int cx = ComboX(loc);
	int cy = ComboY(loc);
	int dx = ComboX(loc)+15;
	int dy = ComboY(loc)+15;
	if (solidonly) return SolidComboCollision (loc, ax, ay, bx, by);
	else return RectCollision( cx, cy, dx, dy, ax, ay, bx, by);
}

// Returns INT if EWeapon collides with a combo of specific type
int ComboTypeCollision (int type, eweapon f, bool solidonly){
	for (int i=0; i<176; i++){
		if (Screen->ComboT[i]==type){
			if (ComboCollision(i, f, solidonly)) return i;
		}
	}
	return -1;
}


// Returns INT if EWeapon collides with a combo which has specific placed flag
int ComboFlagCollision (int flag, eweapon f, bool solidonly){
	for (int i = 0; i<176; i++){
		if (Screen->ComboF[i]==flag){
			if (ComboCollision(i, f, solidonly)) return i;
		}
	}
	return -1;
}


// Returns INT if EWeapon collides with a combo which has specific inherent flag.
int ComboIFlagCollision (int flag, eweapon f, bool solidonly){
	for (int i = 0; i<176; i++){
		if (Screen->ComboI[i]==flag){
			if (ComboCollision(i, f, solidonly)) return i;
		}
	}
	return -1;
}

// Returns INT if EWeapon collides with a combo which has specific either inherent or placed flag.
int ComboAnyFlagCollision (int flag, eweapon f, bool solidonly){
	for (int i = 0; i<176; i++){
		if (ComboFI(i, flag)){
			if (ComboCollision(i, f, solidonly)) return i;
		}
	}
	return -1;
}

// Returns INT if EWeapon collides with a specific combo.
int HardcodedComboCollision (int cmb, eweapon f, bool solidonly){
	for (int i = 0; i<176; i++){
		if (Screen->ComboD[i]==cmb){
			if (ComboCollision(i, f, solidonly)) return i;
		}
	}
	return -1;
}

// Returns TRUE if there is a collision between NPC and the combo on screen.
bool ComboCollision (int loc, npc f, bool solidonly){
	int ax = (f->X)+(f->HitXOffset);
	int ay = (f->Y)+(f->HitYOffset);
	int bx = ax+(f->HitWidth)-1;
	int by = ay+(f->HitHeight)-1;
	if (!(f->CollDetection)) return false;
	int cx = ComboX(loc);
	int cy = ComboY(loc);
	int dx = ComboX(loc)+15;
	int dy = ComboY(loc)+15;
	if (solidonly) return SolidComboCollision (loc, ax, ay, bx, by);
	else return RectCollision( cx, cy, dx, dy, ax, ay, bx, by);
}

// Returns INT if NPC collides with a combo of specific type
int ComboTypeCollision (int type, npc f, bool solidonly){
	for (int i=0; i<176; i++){
		if (Screen->ComboT[i]==type){
			if (ComboCollision(i, f, solidonly)) return i;
		}
	}
	return -1;
}

// Returns INT if NPC collides with a combo which has specific placed flag.
int ComboFlagCollision (int flag, npc f, bool solidonly){
	for (int i = 0; i<176; i++){
		if (Screen->ComboF[i]==flag){
			if (ComboCollision(i, f, solidonly)) return i;
		}
	}
	return -1;
}

// Returns INT if NPC collides with a combo which has specific inherent flag.
int ComboIFlagCollision (int flag, npc f, bool solidonly){
	for (int i = 0; i<176; i++){
		if (Screen->ComboI[i]==flag){
			if (ComboCollision(i, f, solidonly)) return i;
		}
	}
	return -1;
}

// Returns INT if NPC collides with a combo which has specific either inherent or placed flag.
int ComboAnyFlagCollision (int flag, npc f, bool solidonly){
	for (int i = 0; i<176; i++){
		if (ComboFI(i, flag)){
			if (ComboCollision(i, f, solidonly)) return i;
		}
	}
	return -1;
}

// Returns INT if NPC collides with a specific combo.
int HardcodedComboCollision (int cmb, npc f, bool solidonly){
	for (int i = 0; i<176; i++){
		if (Screen->ComboD[i]==cmb){
			if (ComboCollision(i, f, solidonly)) return i;
		}
	}
	return -1;
}

//Returns TRUE if there is a collision between the combo and dropped item.
bool ComboCollision (int loc, item f, bool solidonly){
	int ax = (f->X)+(f->HitXOffset);
	int ay = (f->Y)+(f->HitYOffset);
	int bx = ax+(f->HitWidth)-1;
	int by = ay+(f->HitHeight)-1;
	int cx = ComboX(loc);
	int cy = ComboY(loc);
	int dx = ComboX(loc)+15;
	int dy = ComboY(loc)+15;
	if (solidonly) return SolidComboCollision (loc, ax, ay, bx, by);
	else return RectCollision( cx, cy, dx, dy, ax, ay, bx, by);
}

//Returns INT if dropped item collides with a combo of specific type
int ComboTypeCollision (int type, item f, bool solidonly){
	for (int i=0; i<176; i++){
		if (Screen->ComboT[i]==type){
			if (ComboCollision(i, f, solidonly)) return i;
		}
	}
	return -1;
}

//Returns INT if dropped item collides with a combo which has specific placed flag.
int ComboFlagCollision (int flag, item f, bool solidonly){
	for (int i=0; i<176; i++){
		if (Screen->ComboF[i]==flag){
			if (ComboCollision(i, f, solidonly)) return i;
		}
	}
	return -1;
}

//Returns INT if dropped item collides with a combo which has specific inherent flag.
int ComboIFlagCollision (int flag, item f, bool solidonly){
	for (int i=0; i<176; i++){
		if (Screen->ComboI[i]==flag){
			if (ComboCollision(i, f, solidonly)) return i;
		}
	}
	return -1;
}

//Returns INT if dropped item collides with a combo which has specific either interent or placed flag.
int ComboAnyFlagCollision (int flag, item f, bool solidonly){
	for (int i = 0; i<176; i++){
		if (ComboFI(i, flag)){
			if (ComboCollision(i, f, solidonly)) return i;
		}
	}
	return -1;
}

// Returns INT if dropped item collides with a specific combo.
int HardcodedComboCollision (int cmb, item f, bool solidonly){
	for (int i = 0; i<176; i++){
		if (Screen->ComboD[i]==cmb){
			if (ComboCollision(i, f, solidonly)) return i;
		}
	}
	return -1;
}


//Link-to-Combo interaction functions
//
//All these functions use the so called "sensivity" which works like "Damage combo sensivity"
//value in "Screen Data" window in ZQuest.
//If "solid only" boolean is set to TRUE, "sensivity" value is ignored.

//Returns TRUE if Link touches the combo.
bool LinkComboCollision(int loc, int sens, bool solidonly){
	int ax = Link->X;
	int ay = Link->Y;
	int bx = (Link->X)+(Link->HitWidth)-1;
	int by = (Link->Y)+(Link->HitHeight)-1;
	if (solidonly) return SolidComboCollision (loc, ax, ay, bx, by);
	if(!(RectCollision( ComboX(loc), ComboY(loc), (ComboX(loc)+15), (ComboY(loc)+15), ax, ay, bx, by))) return false;
	else if (!(Distance(CenterLinkX(), CenterLinkY(), (ComboX(loc)+8), (ComboY(loc)+8)) < (sens+8))) return false;
	else return true;
}

//Same as LinkComboCollision, but only bottom half is checked (Link "steps" on the combo).
bool LinkComboStepped(int loc, int sens, bool solidonly){
	int ax = Link->X;
	int ay = (Link->Y)+8;
	int bx = (Link->X)+(Link->HitWidth)-1;
	int by = (Link->Y)+((Link->HitHeight)/2);
	if (solidonly) return SolidComboCollision (loc, ax, ay, bx, by);
	if(!(RectCollision( ComboX(loc), ComboY(loc), (ComboX(loc)+15), (ComboY(loc)+15), ax, ay, bx, by))) return false;
	else if (!(Distance(CenterLinkX(), CenterLinkY(), (ComboX(loc)+8), (ComboY(loc)+8)) < (sens+8))) return false;
	else return true;
}

//Returns INT if Link touches any combo of specific type.
int LinkComboTypeCollision(int type, int sens, bool solidonly){
	for(int i = 0; i < 176; i++){
		if (Screen->ComboT[i]==type){
			if (LinkComboCollision(i, sens, solidonly)) return i;
		}
	}
	return -1;
}

//Returns INT if Link steps on any combo of specific type.
int LinkComboTypeStepped(int type, int sens, bool solidonly){
	for(int i = 0; i < 176; i++){
		if (Screen->ComboT[i]==type){
			if (LinkComboStepped(i, sens, solidonly)) return i;
		}
	}
	return -1;
}


//Returns INT if Link touches any combo with specific placed flag.
int LinkComboFlagCollision(int flag, int sens, bool solidonly){
	for(int i = 0; i < 176; i++){
		if (Screen->ComboF[i]==flag){
			if (LinkComboCollision(i, sens, solidonly)) return i;
		}
	}
	return -1;
}

//Returns INT if Link steps on any combo with specific placed flag.
int LinkComboFlagStepped(int flag, int sens, bool solidonly){
	for(int i = 0; i < 176; i++){
		if (Screen->ComboF[i]==flag){
			if (LinkComboStepped(i, sens, solidonly)) return i;
		}
	}
	return -1;
}

//Returns INT if Link touches any combo with specific inherent flag.
int LinkComboIFlagCollision(int flag, int sens, bool solidonly){
	for(int i = 0; i < 176; i++){
		if (Screen->ComboI[i]==flag){
			if (LinkComboCollision(i, sens, solidonly)) return i;
		}
	}
	return -1;
}

//Returns INT if Link steps on any combo with specific inherent flag.
int LinkComboIFlagStepped(int flag, int sens, bool solidonly){
	for(int i = 0; i < 176; i++){
		if (Screen->ComboI[i]==flag){
			if (LinkComboStepped(i, sens, solidonly)) return i;
		}
	}
	return -1;
}

//Returns INT if Link touches any combo with specific either inherent or placed flag.
int LinkComboAnyFlagCollision(int flag, int sens, bool solidonly){
	for(int i = 0; i < 176; i++){
		if (ComboFI(i, flag)){
			if (LinkComboCollision(i, sens, solidonly)) return i;
		}
	}
	return -1;
}

//Returns INT if Link steps on any combo with specific either inherent or placed flag.
int LinkComboAnyFlagStepped(int flag, int sens, bool solidonly){
	for(int i = 0; i < 176; i++){
		if (ComboFI(i, flag)){
			if (LinkComboStepped(i, sens, solidonly)) return i;
		}
	}
	return -1;
}

//Returns INT if Link touches a combo with specific hardcoded ID.
int LinkHardcodedComboCollision(int flag, int sens, bool solidonly){
	for(int i = 0; i < 176; i++){
		if (Screen->ComboD[i]==flag){
			if (LinkComboCollision(i, sens, solidonly)) return i;
		}
	}
	return -1;
}

//Returns INT if Link steps on a combo with specific hardcoded ID.
int LinkHardcodedComboStepped(int flag, int sens, bool solidonly){
	for(int i = 0; i < 176; i++){
		if (Screen->ComboD[i]==flag){
			if (LinkComboStepped(i, sens, solidonly)) return i;
		}
	}
	return -1;
}

// The following set of 30 functions behaves exactly like previous functions 
// but has reversed order of arguments so you don`t have to remember the order of arguments.
int ComboTypeCollision (ffc f, int type, bool solidonly){
	return ComboTypeCollision (type,f, solidonly);
}

int ComboFlagCollision (ffc f, int flag, bool solidonly){
	return ComboFlagCollision (flag,f, solidonly);
}

int ComboIFlagCollision (ffc f, int flag, bool solidonly){
	return ComboIFlagCollision (flag,f, solidonly);
}

int ComboAnyFlagCollision (ffc f, int flag, bool solidonly){
	return ComboAnyFlagCollision (flag,f, solidonly);
}

int HardcodedComboCollision (ffc f, int type, bool solidonly){
	return HardcodedComboCollision (type,f, solidonly);
}

int ComboTypeCollision (lweapon f, int type, bool solidonly){
	return ComboTypeCollision (type,f, solidonly);
}

int ComboFlagCollision (lweapon f, int flag, bool solidonly){
	return ComboFlagCollision (flag,f, solidonly);
}

int ComboIFlagCollision (lweapon f, int flag, bool solidonly){
	return ComboIFlagCollision (flag,f, solidonly);
}

int ComboAnyFlagCollision (lweapon f, int flag, bool solidonly){
	return ComboAnyFlagCollision (flag,f, solidonly);
}

int HardcodedComboCollision (lweapon f, int type, bool solidonly){
	return HardcodedComboCollision (type,f, solidonly);
}

int ComboTypeCollision (eweapon f, int type, bool solidonly){
	return ComboTypeCollision (type,f, solidonly);
}

int ComboFlagCollision (eweapon f, int flag, bool solidonly){
	return ComboFlagCollision (flag,f, solidonly);
}

int ComboIFlagCollision (eweapon f, int flag, bool solidonly){
	return ComboIFlagCollision (flag,f, solidonly);
}

int ComboAnyFlagCollision (eweapon f, int flag, bool solidonly){
	return ComboAnyFlagCollision (flag,f, solidonly);
}

int HardcodedComboCollision (eweapon f, int type, bool solidonly){
	return HardcodedComboCollision (type,f, solidonly);
}

int ComboTypeCollision (npc f, int flag, bool solidonly){
	return ComboTypeCollision (flag,f, solidonly);
}

int ComboFlagCollision (npc f, int flag, bool solidonly){
	return ComboFlagCollision (flag,f, solidonly);
}

int ComboIFlagCollision (npc f, int flag, bool solidonly){
	return ComboIFlagCollision (flag,f, solidonly);
}

int ComboAnyFlagCollision (npc f, int flag, bool solidonly){
	return ComboAnyFlagCollision (flag,f, solidonly);
}

int HardcodedComboCollision (npc f, int type, bool solidonly){
	return HardcodedComboCollision (type,f, solidonly);
}

int ComboTypeCollision (item f, int type, bool solidonly){
	return ComboTypeCollision (type,f, solidonly);
}

int ComboFlagCollision (item f, int flag, bool solidonly){
	return ComboFlagCollision (flag,f, solidonly);
}

int ComboIFlagCollision (item f, int flag, bool solidonly){
	return ComboIFlagCollision (flag,f, solidonly);
}

int ComboAnyFlagCollision (item f, int flag, bool solidonly){
	return ComboAnyFlagCollision (flag,f, solidonly);
}

int HardcodedComboCollision (item f, int type, bool solidonly){
	return HardcodedComboCollision (type,f, solidonly);
}

bool ComboCollision (ffc f, int loc, bool solidonly){
	return ComboCollision (loc,f, solidonly);
}

bool ComboCollision (lweapon f, int loc, bool solidonly){
	return ComboCollision (loc,f, solidonly);
}

bool ComboCollision (eweapon f, int loc, bool solidonly){
	return ComboCollision (loc,f, solidonly);
}

bool ComboCollision (npc f, int loc, bool solidonly){
	return ComboCollision (loc,f, solidonly);
}

bool ComboCollision (item f, int loc, bool solidonly){
	return ComboCollision (loc,f, solidonly);
}

//Zheight

// Returns TRUE if there is a collision between Lweapon and the combo on screen.
bool ComboCollision (int loc, lweapon f, bool solidonly, int Zheight){
	if ((Zheight != -1)&&(f->Z > Zheight)) return false;
	if (!(f->CollDetection)) return false;
	int ax = (f->X)+f->HitXOffset;
	int ay = (f->Y)+f->HitYOffset;
	int bx = ax+f->HitWidth-1;
	int by = ay+f->HitHeight-1;
	int cx = ComboX(loc);
	int cy = ComboY(loc);
	int dx = ComboX(loc)+15;
	int dy = ComboY(loc)+15;
	if (solidonly) return SolidComboCollision (loc, ax, ay, bx, by);
	else return RectCollision( cx, cy, dx, dy, ax, ay, bx, by);
}

// Returns INT if Lweapon collides with a combo of specific type.
int ComboTypeCollision (int type, lweapon f, bool solidonly, int Zheight){
	for (int i=0; i<176; i++){
		if (Screen->ComboT[i]==type){
			if (ComboCollision(i, f, solidonly, Zheight)) return i;
		}
	}
	return -1;
}


// Returns INT if Lweapon collides with a combo which has specific placed flag.
int ComboFlagCollision (int flag, lweapon f, bool solidonly, int Zheight){
	for (int i = 0; i<176; i++){
		if (Screen->ComboF[i]==flag){
			if (ComboCollision(i, f, solidonly, Zheight)) return i;
		}
	}
	return -1;
}


// Returns INT if Lweapon collides with a combo which has specific inherent flag. 
int ComboIFlagCollision (int flag, lweapon f, bool solidonly, int Zheight){
	for (int i = 0; i<176; i++){
		if (Screen->ComboI[i]==flag){
			if (ComboCollision(i, f, solidonly, Zheight)) return i;
		}
	}
	return -1;
}


// Returns INT if Lweapon collides with a combo which has specific either inherent or placed flag.
int ComboAnyFlagCollision (int flag, lweapon f, bool solidonly, int Zheight){
	for (int i = 0; i<176; i++){
		if (ComboFI(i, flag)){
			if (ComboCollision(i, f, solidonly, Zheight)) return i;
		}
	}
	return -1;
}

// Returns INT if Lweapon collides with a specific combo.
int HardcodedComboCollision (int cmb, lweapon f, bool solidonly, int Zheight){
	for (int i = 0; i<176; i++){
		if (Screen->ComboD[i]==cmb){
			if (ComboCollision(i, f, solidonly, Zheight)) return i;
		}
	}
	return -1;
}


// Returns TRUE if there is a collision between Eweapon and the combo on screen.
bool ComboCollision (int loc, eweapon f, bool solidonly, int Zheight){
	if ((Zheight != -1)&&(f->Z > Zheight)) return false;
	int ax = (f->X)+(f->HitXOffset);
	int ay = (f->Y)+(f->HitYOffset);
	int bx = ax+(f->HitWidth)-1;
	int by = ay+(f->HitHeight)-1;
	if (!(f->CollDetection)) return false;
	int cx = ComboX(loc);
	int cy = ComboY(loc);
	int dx = ComboX(loc)+15;
	int dy = ComboY(loc)+15;
	if (solidonly) return SolidComboCollision (loc, ax, ay, bx, by);
	else return RectCollision( cx, cy, dx, dy, ax, ay, bx, by);
}

// Returns INT if EWeapon collides with a combo of specific type.
int ComboTypeCollision (int type, eweapon f, bool solidonly, int Zheight){
	for (int i=0; i<176; i++){
		if (Screen->ComboT[i]==type){
			if (ComboCollision(i, f, solidonly, Zheight)) return i;
		}
	}
	return -1;
}


// Returns INT if EWeapon collides with a combo which has specific placed flag.
int ComboFlagCollision (int flag, eweapon f, bool solidonly, int Zheight){
	for (int i = 0; i<176; i++){
		if (Screen->ComboF[i]==flag){
			if (ComboCollision(i, f, solidonly, Zheight)) return i;
		}
	}
	return -1;
}


// Returns INT if EWeapon collides with a combo which has specific inherent flag.
int ComboIFlagCollision (int flag, eweapon f, bool solidonly, int Zheight){
	for (int i = 0; i<176; i++){
		if (Screen->ComboI[i]==flag){
			if (ComboCollision(i, f, solidonly, Zheight)) return i;
		}
	}
	return -1;
}

// Returns INT if EWeapon collides with a combo which has specific either inherent or placed flag.
int ComboAnyFlagCollision (int flag, eweapon f, bool solidonly, int Zheight){
	for (int i = 0; i<176; i++){
		if (ComboFI(i, flag)){
			if (ComboCollision(i, f, solidonly, Zheight)) return i;
		}
	}
	return -1;
}

// Returns INT if EWeapon collides with a specific combo.
int HardcodedComboCollision (int cmb, eweapon f, bool solidonly, int Zheight){
	for (int i = 0; i<176; i++){
		if (Screen->ComboD[i]==cmb){
			if (ComboCollision(i, f, solidonly, Zheight)) return i;
		}
	}
	return -1;
}

// Returns TRUE if there is a collision between NPC and the combo on screen.
bool ComboCollision (int loc, npc f, bool solidonly, int Zheight){
	if ((Zheight != -1)&&(f->Z > Zheight)) return false;
	int ax = (f->X)+(f->HitXOffset);
	int ay = (f->Y)+(f->HitYOffset);
	int bx = ax+(f->HitWidth)-1;
	int by = ay+(f->HitHeight)-1;
	if (!(f->CollDetection)) return false;
	int cx = ComboX(loc);
	int cy = ComboY(loc);
	int dx = ComboX(loc)+15;
	int dy = ComboY(loc)+15;
	if (solidonly) return SolidComboCollision (loc, ax, ay, bx, by);
	else return RectCollision( cx, cy, dx, dy, ax, ay, bx, by);
}

// Returns INT if NPC collides with a combo of specific type.
int ComboTypeCollision (int type, npc f, bool solidonly, int Zheight){
	for (int i=0; i<176; i++){
		if (Screen->ComboT[i]==type){
			if (ComboCollision(i, f, solidonly, Zheight)) return i;
		}
	}
	return -1;
}

// Returns INT if NPC collides with a combo which has specific placed flag.
int ComboFlagCollision (int flag, npc f, bool solidonly, int Zheight){
	for (int i = 0; i<176; i++){
		if (Screen->ComboF[i]==flag){
			if (ComboCollision(i, f, solidonly, Zheight)) return i;
		}
	}
	return -1;
}

// Returns INT if NPC collides with a combo which has specific inherent flag.
int ComboIFlagCollision (int flag, npc f, bool solidonly, int Zheight){
	for (int i = 0; i<176; i++){
		if (Screen->ComboI[i]==flag){
			if (ComboCollision(i, f, solidonly, Zheight)) return i;
		}
	}
	return -1;
}

// Returns INT if NPC collides with a combo which has specific either inherent or placed flag.
int ComboAnyFlagCollision (int flag, npc f, bool solidonly, int Zheight){
	for (int i = 0; i<176; i++){
		if (ComboFI(i, flag)){
			if (ComboCollision(i, f, solidonly, Zheight)) return i;
		}
	}
	return -1;
}

// Returns INT if NPC collides with a specific combo.
int HardcodedComboCollision (int cmb, npc f, bool solidonly, int Zheight){
	for (int i = 0; i<176; i++){
		if (Screen->ComboD[i]==cmb){
			if (ComboCollision(i, f, solidonly, Zheight)) return i;
		}
	}
	return -1;
}

//Link-to-Combo interaction functions
//
//All these functions use the so called "sensivity" which works like "Damage combo sensivity"
//value in "Screen Data" window in ZQuest.
//If "solid only" boolean is set to TRUE, "sensivity" value is ignored.

//Returns TRUE if Link touches the combo.
bool LinkComboCollision(int loc, int sens, bool solidonly, int Zheight){
	if (Zheight >= 0){
		if (Link->Z > Zheight) return false;
	}
	int ax = Link->X;
	int ay = Link->Y;
	int bx = (Link->X)+(Link->HitWidth)-1;
	int by = (Link->Y)+(Link->HitHeight)-1;
	
	//if ((Link->Dir==DIR_DOWN)&&(Link->InputDown)) by++;//
	//else if (IsSideview()) by++;
	if (solidonly) return SolidComboCollision (loc, ax, ay, bx, by);
	if(!(RectCollision( ComboX(loc), ComboY(loc), (ComboX(loc)+15), (ComboY(loc)+15), ax, ay, bx, by))) return false;
	else if (!(Distance(CenterLinkX(), CenterLinkY(), (ComboX(loc)+8), (ComboY(loc)+8)) < (sens+8))) return false;
	else return true;
}

//Same as LinkComboCollision, but only bottom half is checked (Link "steps" on the combo).
bool LinkComboStepped(int loc, int sens, bool solidonly, int Zheight){
	if (Zheight >= 0){
		if (Link->Z > Zheight) return false;
	}
	int ax = Link->X;
	int ay = (Link->Y)+8;
	int bx = (Link->X)+(Link->HitWidth)-1;
	int by = (Link->Y)+((Link->HitHeight)/2);
	//if ((Link->Dir==DIR_DOWN)&&(Link->InputDown)) by++;//
	//else if (IsSideview()) by++; 
	if (solidonly) return SolidComboCollision (loc, ax, ay, bx, by);
	if(!(RectCollision( ComboX(loc), ComboY(loc), (ComboX(loc)+15), (ComboY(loc)+15), ax, ay, bx, by))) return false;
	else if (!(Distance(CenterLinkX(), CenterLinkY(), (ComboX(loc)+8), (ComboY(loc)+8)) < (sens+8))) return false;
	else return true;
}

//Returns INT if Link touches any combo of specific type.
int LinkComboTypeCollision(int type, int sens, bool solidonly, int Zheight){
	for(int i = 0; i < 176; i++){
		if (Screen->ComboT[i]==type){
			if (LinkComboCollision(i, sens, solidonly, Zheight)) return i;
		}
	}
	return -1;
}

//Returns INT if Link steps on any combo of specific type.
int LinkComboTypeStepped(int type, int sens, bool solidonly, int Zheight){
	for(int i = 0; i < 176; i++){
		if (Screen->ComboT[i]==type){
			if (LinkComboStepped(i, sens, solidonly, Zheight)) return i;
		}
	}
	return -1;
}


//Returns INT if Link touches any combo with specific placed flag.
int LinkComboFlagCollision(int flag, int sens, bool solidonly, int Zheight){
	for(int i = 0; i < 176; i++){
		if (Screen->ComboF[i]==flag){
			if (LinkComboCollision(i, sens, solidonly, Zheight)) return i;
		}
	}
	return -1;
}

//Returns INT if Link steps on any combo with specific placed flag.
int LinkComboFlagStepped(int flag, int sens, bool solidonly, int Zheight){
	for(int i = 0; i < 176; i++){
		if (Screen->ComboF[i]==flag){
			if (LinkComboStepped(i, sens, solidonly, Zheight)) return i;
		}
	}
	return -1;
}

//Returns INT if Link touches any combo with specific inherent flag.
int LinkComboIFlagCollision(int flag, int sens, bool solidonly, int Zheight){
	for(int i = 0; i < 176; i++){
		if (Screen->ComboI[i]==flag){
			if (LinkComboCollision(i, sens, solidonly, Zheight)) return i;
		}
	}
	return -1;
}

//Returns INT if Link steps on any combo with specific inherent flag.
int LinkComboIFlagStepped(int flag, int sens, bool solidonly, int Zheight){
	for(int i = 0; i < 176; i++){
		if (Screen->ComboI[i]==flag){
			if (LinkComboStepped(i, sens, solidonly, Zheight)) return i;
		}
	}
	return -1;
}

//Returns INT if Link touches any combo with specific either inherent or placed flag.
int LinkComboAnyFlagCollision(int flag, int sens, bool solidonly, int Zheight){
	for(int i = 0; i < 176; i++){
		if (ComboFI(i, flag)){
			if (LinkComboCollision(i, sens, solidonly, Zheight)) return i;
		}
	}
	return -1;
}

//Returns INT if Link steps on any combo with specific either inherent or placed flag.
int LinkComboAnyFlagStepped(int flag, int sens, bool solidonly, int Zheight){
	for(int i = 0; i < 176; i++){
		if (ComboFI(i, flag)){
			if (LinkComboStepped(i, sens, solidonly, Zheight)) return i;
		}
	}
	return -1;
}

//Returns INT if Link touches a combo with specific hardcoded ID.
int LinkHardcodedComboCollision(int cmb, int sens, bool solidonly, int Zheight){
	for(int i = 0; i < 176; i++){
		if (Screen->ComboD[i]==cmb){
			if (LinkComboCollision(i, sens, solidonly, Zheight)) return i;
		}
	}
	return -1;
}

//Returns INT if Link steps on a combo with specific hardcoded ID.
int LinkHardcodedComboStepped(int cmb, int sens, bool solidonly, int Zheight){
	for(int i = 0; i < 176; i++){
		if (Screen->ComboD[i]==cmb){
			if (LinkComboStepped(i, sens, solidonly, Zheight)) return i;
		}
	}
	return -1;
}