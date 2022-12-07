//Script to create an item that activates the 1/2 magic attribute for Link on pick up rather than use the room type

item script HalfMagic
{
	void run (int m)
	{
	Game->Generic[GEN_MAGICDRAINRATE] = 1;
	Screen->Message(m);
	}

}