//Permanent Tiered Secrets Script
//D0: The Screen->D (0-7) to use to store the number of triggered secrets on the screen
//D1: If you want to use a layered combo to detect secrets being triggered, set this to the layer number
//D2: In an infinite looping tiered secret, set this to the number of states the secret can have
ffc script PermanentTieredSecrets{
	void run(int D, int Layer, int NumStates){
		//Triggers the number of screen secrets stored in Screen->D when you enter the screen
		if(Screen->D[D]>0){
			for(int i=0; i<Screen->D[D]; i++){
				Screen->TriggerSecrets();
			}
		}
		//Saves the combo position and combo under the FFC
		int ComboPos = ComboAt(this->X+8, this->Y+8);
		int Combo;
		if(Layer>0)
			Combo = GetLayerComboD(Layer, ComboPos);
		else if(Layer==0)
			Combo = Screen->ComboD[ComboPos];
		while(true){
			//Detects if the combo under the FFC changes and increases Screen->D
			if(Layer>0&&GetLayerComboD(Layer, ComboPos)!=Combo){
				Combo = GetLayerComboD(Layer, ComboPos);
				Screen->D[D]++;
			}
			else if(Layer==0&&Screen->ComboD[ComboPos]!=Combo){
				Combo = Screen->ComboD[ComboPos];
				Screen->D[D]++;
			}
			//Wraps Screen->D if NumStates is set, otherwise caps Screen->D at 100
			if(NumStates>0&&Screen->D[D]>=NumStates)
				Screen->D[D] -= NumStates;
			else if(NumStates==0&&Screen->D[D]>100){
				Screen->D[D] = 100;
			}
			Waitframe();
		}
	}
}