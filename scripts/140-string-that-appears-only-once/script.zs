ffc script StringOnce{
     void run(int m, int delay, int d){
          if ( Screen->D[d] == 0 ) {
               Screen->D[d] = 1;
               Waitframes(delay);
               Screen->Message(m);
          }
     }
}