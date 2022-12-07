ffc script EnemyMusic
{
	void run(int bmidi, int nmidi)
	{
		while(true)
		{
			if (Screen->NumNPCs() != 0)
			{
				Game->PlayMIDI(bmidi);
			}
			else
			{
				Game->PlayMIDI(nmidi);
			}
			Waitframe();
		}
	}
}