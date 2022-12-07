import "std.zh"   // only need this once per script buffer.

// RealMap 
//
// Adds screens to your spacebar map that you may not have visited yet when you pickup a "map" item.
// Setup is a bit complex as it requires working with arrays.
// 
// Setup
// 1. setup your mapScreens[] array.  Its been commented in table form to make it easier.
//    Enter each screen# on that map that you'll be able to see when you pickup the item.  You are working with maps here not DMaps.  So just enter the screen# as you see it in ZQuest.
//    The screen#s are in Hexidecimal, so enter them as 0x__, or convert them to decimal if you'd prefer.
//    Put a comma between each screen#.  And end each set (every group of screens for that map) with a -1,
//    The last value in the array should be a -1 (no comma).
//    You can add more rows to the array table, or change the spacing as long as you follow the rules above.
//
//    In the example array.  The first set of screens is 0x27, 0x37, 0x5a.  The next set starts in position 4 with 0x01.  The third set starts at position 13.
//    Notice how the last value is -1 (no comma)
//
// 2. Use the array table column and row labels to find the start index of each map set.  Input that number into the mapIndex[] array.  
//    The mapIndex[] array is in order with the map#s.  So map1 will be the first position, map2 the 2nd, etc.
//    If you have a map# that you aren't including in this, you still need to input a value, so input -1.
//    If you want to use multiple sets for one map, put the 2nd set at the end of all the maps you are actually using.  
//    so if the last map# used in your quest is 80, you can start putting doubles in position 81.
//    feel free to create a table to organize your mapIndex[] array as well.
//
//    In the example array.  The map1 index# is 0 (0x27 in the mapScreen[] array).  The map2 index# is 4 (0x01 in the mapScreen[] array).  
//    The map3 index# is -1 because map3 doesn't use this script.  And the map4 index# is 13 (0x20)
//
//
// 3. Compile the script.  And slot the item script I_PU_RealMap.
//
// 4. Attach the I_PU_RealMap script to the pickup slot for any item that you want to have the behavior.  Can be the standard map item.  Or a custom item.
//    D0 = mapnum, which mapnum this item is giving you.  Leave it at 0 if you want it to be the current map.
//    If attaching this to standard map item, you should leave D0 blank.  Use a custom item if setting a D0 value.


item script I_PU_RealMap
{
   void run(int mapnum)
   {
      int mapScreens[] = { // this is the start of the array, don't mess with this

      // 0      1      2      3      4      5      6      7      8      9
        0x27,  0x37,  0x5A,  -1,    0x01,  0x02,  0x03,  0x04,  0x05,  0x06,  //0
        0x07,  0x08,  -1,    0x20,  -1                                        //10
                                                                              //20
                                                                              //30
                                                                              //40
                                                                              //50

      }; // this is the end of the array, don't mess with this other than moving it down a line.

      int mapIndex[] = { 0, 4, -1, 13 };


      if(mapnum == 0) mapnum = Game->GetCurMap();
      if(mapnum > SizeOfArray(mapIndex)) Quit();
      int index = mapIndex[mapnum-1];
      if(index == -1) Quit();

      int mssize = SizeOfArray(mapScreens);

      while(true)
      {
         if(mapScreens[index] == -1) Quit();
         if(mapScreens[index] >= 0 && mapScreens[index] <= 0xFF) 
            Game->SetScreenState(mapnum, mapScreens[index], ST_VISITED, true);
         index++;
         if(index >= mssize) Quit();
      }
   }
}