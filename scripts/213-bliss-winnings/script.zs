import "std.zh"

item script BlissWinnings
{
	void run(int m)
	{
		Game->Cheat = 4;

		Link->HP = Link->MaxHP;
		Link->MP = Link->MaxMP;

		Game->PlaySound(SFX_BOMB);

		Screen->Message(m);
	}
}