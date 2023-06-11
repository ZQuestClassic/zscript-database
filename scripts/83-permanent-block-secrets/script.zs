//import "std.zh"

//Instructions:
//1. Make a new combo with inherent flag 16 (or any secret flag)
//2. Set this FFC to the above combo
//3. When secrets are triggered by blocks, this script will make it permanent
ffc script blockPermSecrets{
	void run(){
		int thisCombo = this->Data;
		while(!Screen->State[ST_SECRET]){
			if(this->Data != thisCombo) Screen->State[ST_SECRET] = true;
			Waitframe();
		}
	}
}