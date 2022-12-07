ffc script TriumphForksCheck{
        void run(int number){
                if(number <= NumTriforcePieces() && (Screen->State[ST_SECRET]!= true)){
                        Screen->TriggerSecrets();
                        Screen->State[ST_SECRET]=true;
                }
        }
}
//D0 is the number of triforces you want to check for.