import "std.zh"
import "ffcscript.zh"

ffc script Only_Move_With_Secrets{
	void run(int initial_x, int initial_y){
			initial_x = this->Vx;
			initial_y = this->Vy;
			this->Vx = 0;
			this->Vy = 0;
	while (!Screen->State[ST_SECRET]) Waitframe();
			this->Vx = initial_x;
			this->Vy = initial_y;
	}
}