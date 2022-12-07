//D0: The timer between shivering
//D1:  How much damage (in quarter hearts) for each shiver
//D2:  A safety item.  If Link acquires this item, he'll no longer shiver and receive damage from this screen's pool of water
//D3:  Shiver sound:  A sound Link makes every time he shivers
//D4:  Shiver sprite:  This FFC combo will change to this combo (instead of from an invisible one).  Should be made to look like Link shivering water.
//D5:  Shiver Duration:  How long Link will shiver & remain frozen in place for (60 tics is a good length)

ffc script poison_water{
	void run(int timer, int damage, int safety_item, int shiver_sound, int shiver_sprite, int shiver_duration){
	Waitframes(2);
	while(true){
		Waitframes(timer);
		if(Link->Action == LA_SWIMMING || Link->Action == LA_DIVING){
		Waitframes(1);
			if(Link->Item[safety_item] == false){
			Link->HP = Link->HP - damage;
			Game->PlaySound(shiver_sound);
			Link->CollDetection = false;
			Link->Invisible = true;
			this->Data = shiver_sprite + Link->Dir;
			this->X = Link->X;
			this->Y = Link->Y;
			WaitNoAction(shiver_duration);
			Link->CollDetection = true;
			Link->Invisible = false;
			this->Data = 0;
				}
			}
		}
	}
}