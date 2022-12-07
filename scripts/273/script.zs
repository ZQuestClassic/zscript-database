import "std.zh"

ffc script WarpLinkUponDeath{
	void run(int autowarp){
		while(true){
			if ( Link->HP <= 0 ) {
				Link->HP = Link->MaxHP;
				this->Data = autowarp;
				Quit();
			}
			Waitframe();
		}
	}
}