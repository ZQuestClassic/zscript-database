item script RedPotion{
	void run(int sfx){
		if(sfx == 0) sfx = SFX_REFILL;
		Game->PlaySound(sfx);
		Link->HP+= Link->MaxHP;
	}
}

item script GreenPotion{
	void run(int sfx){
		if(sfx == 0) sfx = SFX_REFILL;
		Game->PlaySound(sfx);
		Link->MP+= Link->MaxMP;
	}
}

item script BluePotion{
	void run(int sfx){
		if(sfx == 0) sfx = SFX_REFILL;
		Game->PlaySound(sfx);
		Link->HP = Link->MaxHP;
		Link->MP = Link->MaxMP;
	}
}