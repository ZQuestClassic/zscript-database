item script CombiningItems{
    void run(int message, int checkeditem, int secondpickupstring, int combineditem){
        if(Link->Item[checkeditem]){                //Checks to see if Link has the item
            Link->Item[combineditem] = true;        //Gives Link the new item
            Screen->Message(secondpickupstring);    //Applies new pickup string to go with new item
        }
        else{                                        //If Link doesn't have the item...
            Screen->Message(message);                //Plays alternate string
        }
    }
}