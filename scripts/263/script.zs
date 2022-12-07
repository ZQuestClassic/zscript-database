int SecretArray[65536];//Array for the secrets that are Linked.

//Each switch that sets off multiple secrets must share the same value.

//There is no limit to the number of multiple screens that can be affected this way.











ffc script Linked_Secrets{

	void run(bool first, int type,int Trigger, int index, int secret_offset,int sfx){

		bool isHit = false;

		int ComboD[176];

		if(type ==0){

			for(int i=0; i<176; i++){

				if(Screen->ComboD[i]==Trigger)ComboD[i] = Screen->ComboD[i];

			}

		}

		//Wait for it to be triggered.

		if(first){

			if(SecretArray[index])

				isHit = true;

			while(!isHit){

				if(type ==0){

					for(int i=0; i<176; i++){

						if(Screen->ComboD[i]!=Trigger && ComboD[i]==Trigger)isHit = true;

					}

				}

				else if(type !=0){

					 //Scan lweapons and wait for right one to impact.

					for (int i = 1; i <= Screen->NumLWeapons(); i++){

						lweapon w = Screen->LoadLWeapon(i);

						if (w->ID == type && Collision(this, w))isHit = true;

					}

				}

				Waitframe();

			}

		}

		else{

			while(SecretArray[index]==0){

				Waitframe();

			}

		}

		//Play secret sound.

		if(sfx!=0 && !SecretArray[index])

			Game->PlaySound(sfx);

		if(!SecretArray[index])

			SecretArray[index]=1;

		//Change all flagged combos by offset amount.

		if(type!=0){

			for (int i = 0; i < 175; i++ ){

				if(ComboFI(i,Trigger)){

					Screen->ComboD[i]+=secret_offset;

					Screen->ComboF[i] = 0;

					Screen->ComboI[i] = 0;

				}

			}

		}

		else{	

			Screen->TriggerSecrets();

			Screen->State[ST_SECRET]= true;

		}

	}

}