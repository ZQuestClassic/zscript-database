const int SFX_BUTTONPRESSED = 61;

ffc script PressTrigger{
	void run(int Perm, int PressedCombo, int Type, int Sound, int Activate){
		int BaseCombo=Screen->ComboD[ComboAt(this->X+8, this->Y+8)];
		int SFX = Sound;
		this->Flags[FFCF_ETHEREAL] = true;
		if(SFX==0)SFX=SFX_BUTTONPRESSED;
		while(true){
			Screen->ComboD[ComboAt(this->X+8, this->Y+8)]=BaseCombo;
			while(!Pressed(this, 0, BaseCombo, PressedCombo, Type)){
				Waitframe();
			}
			this->Misc[0]=1;
			Game->PlaySound(SFX);
			if(Activate==0){
				Screen->TriggerSecrets();
				if(Perm!=0)Screen->State[ST_SECRET]=true;
			}
			if(Screen->ComboD[ComboAt(this->X+8, this->Y+8)]==BaseCombo)Screen->ComboD[ComboAt(this->X+8, this->Y+8)]=PressedCombo;
			Waitframes(16);
			while(Pressed(this, 6, BaseCombo, PressedCombo, Type)){
				Waitframe();
			}
			Screen->ComboD[ComboAt(this->X+8, this->Y+8)]=BaseCombo;
			this->Misc[0]=0;
		}
	}
	bool Pressed(ffc this, int distmod, int BaseCombo, int PressedCombo, int Type){
		
		bool result = false;
		if(Type==0|| Type==1){
			if(Distance(this->X, this->Y, Link->X, Link->Y)<8+distmod || Link->Action==LA_FROZEN)result = true;
		}
		if(Type==0||Type==2){
			if(Screen->ComboD[ComboAt(this->X+8, this->Y+8)]!=BaseCombo && Screen->ComboD[ComboAt(this->X+8, this->Y+8)]!=PressedCombo)result = true;
		}
		return result;
	}
}