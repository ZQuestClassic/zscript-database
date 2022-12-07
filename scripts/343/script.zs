import "std.zh"

item script TieredItemPickup{
     void run(int lowTier, int secondTier, int thirdTier, int fourthTier, int fifthTier, int sixthTier, int highTier, int m){
             if (Link->Item[sixthTier]){
                   Link->Item[highTier] = true;
                   Screen->Message(m);
             }
             else if (Link->Item[fifthTier]){
                   Link->Item[sixthTier] = true;
                   Screen->Message(m);
              }
             else if (Link->Item[fourthTier]){
                   Link->Item[fifthTier] = true;
                   Screen->Message(m);
              }
             else if (Link->Item[thirdTier]){
                   Link->Item[fourthTier] = true;
                   Screen->Message(m);
              }
             else if (Link->Item[secondTier]){
                   Link->Item[thirdTier] = true;
                   Screen->Message(m);
              }
             else if (Link->Item[lowTier]){
                   Link->Item[secondTier] = true;
                   Screen->Message(m);
              }
             else {
                   Link->Item[lowTier]= true;
                   Screen->Message(m);
              }
        }
}