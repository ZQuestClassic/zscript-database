////////////////////////////
//			  //
//   ScreenCornerDebug    //
//        by Bagu	  //
//			  //
////////////////////////////



//...not much to say...
//Put the function declaration anywhere in your script or imported/included header.
// and place "ScreenCornerDebug();" in the "while(true)" loop 
//of your active global- or hero script.

// It will check Links pxl position on the screen
//and the relevant button inputs if you are to far Up/Left, Up/Right, Down/Left, Down/Right.
//to avoid scrolling crashes.




//function

void ScreenCornerDebug()
{
    if(Hero->X <=4 && Hero->Y <= 4){Hero->InputUp = false; Hero->PressUp = false; Hero->InputLeft = false; Hero->PressLeft = false;}
    else if(Hero->X >=239 && Hero->Y <= 4){Hero->InputUp = false; Hero->PressUp = false; Hero->InputRight = false; Hero->PressRight = false;}
    else if(Hero->X <=4 && Hero->Y >= 159){Hero->InputDown = false; Hero->PressDown = false; Hero->InputLeft = false; Hero->PressLeft = false;}
    else if(Hero->X >=239 && Hero->Y >= 159){Hero->InputDown = false; Hero->PressDown = false; Hero->InputRight = false; Hero->PressRight = false;}
}



//example global-/hero- scripts ...assign to "´Active" slot.

global script DebuggedCorners
{
    void run()
    {
	while(true)
	{
	    ScreenCornerDebug();
	    Waitdraw();
	    Waitframe();
	}
    }
}

hero script CornerDbug
{
    void run()
    {
	while(true)
	{
	    ScreenCornerDebug();
	    Waitdraw();
	    Waitframe();
	}
    }
}