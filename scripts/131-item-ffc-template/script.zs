item script FFCScript
{
	void run(int scriptSlot)
	{
		int args[8];
		args[0] = this->Power;
		for(int i = 1; i < 8; i++)
		{
			args[i] = this->InitD[i];
		}
		RunFFCScript(scriptSlot,args);
	}
}