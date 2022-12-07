screendata script MessageDisappear
{
	void run(int switchItem, int m)
	{
		if(Hero->Item[switchItem]) Quit();
		{
			Screen->Message(m);
		}
	}
}