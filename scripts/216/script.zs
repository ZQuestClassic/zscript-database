import "std.zh"

const int RupeeFlower_Item1 = 0; //item IDs of the items that rain down
const int RupeeFlower_Item2 = 1; //use -1 if you only need the first item
const int RupeeFlower_PercentageSecondItem = 15; //chance in percentage for how often the second item falls down instead of the first (ignore this if you only use 1 item)
const int RupeeFlower_RateMin = 25; //the minimum rate in frames at which items rain down
const int RupeeFlower_RateMax = 40; //the maximum rate in frames at which items rain down

int RupeeFlower_ActiveFrames = 0; //global variable required for the rupee flower

global script Active{
    void run(){
        RupeeFlower_ActiveFrames = 0;
        int RupeeFlower_RateCounter = 0;
        int RupeeFlower_Rate = 0;
        while(true){
            if ( RupeeFlower_ActiveFrames > 0 ) { //rupee flower active script
                RupeeFlower_RateCounter ++;
                if ( RupeeFlower_RateCounter >= RupeeFlower_Rate ) {
                    RupeeFlower_RateCounter = 0;
                    RupeeFlower_Rate = Rand(RupeeFlower_RateMin, RupeeFlower_RateMax);
                    item itemdrop;
                    int randomchance = Rand(1, 100);
                    if ( RupeeFlower_Item2 >= 0 && randomchance <= RupeeFlower_PercentageSecondItem )
                         itemdrop = Screen->CreateItem(RupeeFlower_Item2);
                    else
                         itemdrop = Screen->CreateItem(RupeeFlower_Item1);
                    SetItemPickup(itemdrop, IP_TIMEOUT, true);
                    itemdrop->X = Rand(240); itemdrop->Y = Rand(160);
                    while(Distance(itemdrop->X+8,itemdrop->Y+8,Link->X,Link->Y) > 50) {
                        itemdrop->X = Rand(240); itemdrop->Y = Rand(160);
                    }
                    itemdrop->Z = 80;
                }
                RupeeFlower_ActiveFrames --;
            }
            Waitframe();
        }
    }
}

//D0 is the time in frames for how long the item rain effect lasts
item script RupeeFlowerPickup{
    void run(int d0){
        RupeeFlower_ActiveFrames = d0;
    }
}