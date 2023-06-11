ffc script SpawnItem
{
	//Does what it says on the tin. Argument 1 is the item ID, argument 2 is x position and argument 3 is y (in pixels)
	//Leave args 1 and 2 at zero to have the item placed randomly on the screen.
	//Items can be placed at coordinates 0,0 through 240,160. Any higher than this can cause issues.
	
void run(int item1, int xpos, int ypos)
	{
	item AnItem;
	AnItem = Screen->CreateItem(item1);
	AnItem->X = xpos;
	AnItem->Y = ypos;
	if (xpos == 0) 
		{
		AnItem->X = Rand(0,240);
		}
	if (ypos == 0)
		{
		AnItem->Y = Rand(0,160);
		}
	Quit();
	}
}

ffc script SpawnItemAtFFC
{
	//Argument 1 is the item ID. Listens to FFC positioning instead of
        //randomly placing it or having to place it by pixel value.
	void run(int item1)
	{
	CreateItemAt(item1, this->X, this->Y);
	Quit();
	}
}