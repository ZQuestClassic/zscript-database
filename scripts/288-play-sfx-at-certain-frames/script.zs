ffc script sfxplay{
	void run(int s, int wait, int r){
		if (r == 0){
			Waitframes(wait);
			Game->PlaySound(s);
		}
		else{
			while(true){
			Waitframes(wait);
			Game->PlaySound(s);
			}
		}
	}
}