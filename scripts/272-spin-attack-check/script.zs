import "std.zh"

ffc script SpinAttackCheck{
	void run(int sfx){
		if ( Screen->State[ST_SECRET] )
			Quit();
		bool spin;
		while(true){
			if ( Link->Action == LA_SPINNING )
				spin = true;
			if ( !Link->Action == LA_SPINNING && spin ) {
				if ( sfx == 0 )
					Game->PlaySound(27);
				if ( sfx > 0 )
					Game->PlaySound(sfx);
				Screen->TriggerSecrets();
				Screen->State[ST_SECRET] = true;
				Quit();
			}
			Waitframe();
		}
	}
}