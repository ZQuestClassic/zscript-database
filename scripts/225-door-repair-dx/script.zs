import "std.zh"

//D0 = message to play (leave at 0 if you don't need the script to play a message)
//D1 = screen D register to use (set to -1 if you don't want the script to work only once)
ffc script DoorRepairDX{
    void run(int m, int d){
        if ( Screen->D[d] == 0 || d < 0 ) {
            if ( d >= 0 ) Screen->D[d] = 1;
            int r = Game->Counter[CR_RUPEES];
            Game->DCounter[CR_RUPEES] -= r; //take rupees
            Game->Save(); //save game
            Screen->Message(m); //play message
        }
    }
}