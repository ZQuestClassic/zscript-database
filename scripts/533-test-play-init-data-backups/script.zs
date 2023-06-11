namespace TestPlayInitData
{
	const int C_TESTPLAY_BLACK = 0x0F; // Used for backgrounds and dimming the screen
	const int C_TESTPLAY_WHITE = 0x01; // Used for text
	const int C_TESTPLAY_GRAY = 0x02; // Used for unused slots
	const int C_TESTPLAY_SELECTION = 0x04; // Used for the currently selected slot

	const bool TESTPLAY_WARP_TO_DMAP = false; // If true, selecting a test play slot also warps to  the dmap and screen
	
	enum Modes
	{
		MODE_SAVE,
		MODE_LOAD,
		MODE_ERASE
	};
		
	generic script TestPlayItems
	{
		void run()
		{
			this->ReloadState[GENSCR_ST_RELOAD] = true;
			genericdata gd = Game->LoadGenericData(Game->GetGenericScript("TestPlayItemsUI"));
			if(Debug->Testing)
			{
				gd->InitD[0] = MODE_LOAD;
				gd->InitD[1] = true;
				gd->RunFrozen();
			}
			while(true)
			{
				if(Debug->Testing && PressShift() && PressControl() && Input->Key[KEY_T])
				{
					gd->InitD[0] = MODE_LOAD;
					gd->InitD[1] = false;
					gd->RunFrozen();
				}
				Waitframe();
			}
		}
	}

	class TestPlayInitData
	{
		TestPlayInitData(int slot)
		{
			Slot = slot;
			sprintf(FilePath, "InitData/InitData%d.zinit", slot);
			LoadFromFile();
		}
		
		// Gets init data from the current file
		void GetInitData()
		{
			for(int i=0; i<256; ++i)
			{
				Items[i] = Link->Item[i];
			}
			for(int i=0; i<32; ++i)
			{
				Counters[i] = Game->Counter[i];
				MCounters[i] = Game->MCounter[i];
			}
			for(int i=0; i<512; ++i)
			{
				LKeys[i] = Game->LKeys[i];
				Map[i] = GetLevelItem(i, LI_MAP);
				Compass[i] = GetLevelItem(i, LI_COMPASS);
				BossKey[i] = GetLevelItem(i, LI_BOSSKEY);
				BossDead[i] = GetLevelItem(i, LI_BOSS);
				Triforce[i] = GetLevelItem(i, LI_TRIFORCE);
			}
			
			CanSlash = Game->Generic[GEN_CANSLASH];
			HeartPieces = Game->Generic[GEN_HEARTPIECES];
			MagicDrainRate = Game->Generic[GEN_MAGICDRAINRATE];
			
			SavedDMap = Game->GetCurDMap();
			SavedScreen = Game->GetCurScreen();
			
			Valid = true;
		}
		// Sets the current file's init data
		void SetInitData()
		{
			for(int i=0; i<256; ++i)
			{
				Link->Item[i] = Items[i];
			}
			for(int i=0; i<32; ++i)
			{
				Game->Counter[i] = Counters[i];
				Game->MCounter[i] = MCounters[i];
			}
			for(int i=0; i<512; ++i)
			{
				Game->LKeys[i] = LKeys[i];
				SetLevelItem(i, LI_MAP, Map[i]);
				SetLevelItem(i, LI_COMPASS, Compass[i]);
				SetLevelItem(i, LI_BOSSKEY, BossKey[i]);
				SetLevelItem(i, LI_BOSS, BossDead[i]);
				SetLevelItem(i, LI_TRIFORCE, Triforce[i]);
			}
			
			Game->Generic[GEN_CANSLASH] = CanSlash;
			Game->Generic[GEN_HEARTPIECES] = HeartPieces;
			Game->Generic[GEN_MAGICDRAINRATE] = MagicDrainRate;
			
			if(TESTPLAY_WARP_TO_DMAP)
			{
				Link->Warp(SavedDMap, SavedScreen);
			}
		}
		
		// Reads / writes to a file
		void LoadFromFile()
		{
			file f;
			if(!FileSystem->FileExists(FilePath))
			{
				return;
			}
			f->OpenMode(FilePath, "rb+");
			f->Own();
			// Valid
			{
				Valid = false;
				int bytes[1];
				f->ReadBytes(bytes);
				if(bytes[0])
					Valid = true;
			}
			// Items
			{
				int bytes[32];
				f->ReadBytes(bytes);
				for(int i=0; i<32; ++i)
				{
					int val = bytes[i];
					for(int j=0; j<8; ++j)
					{
						if(val & (1<<j))
							Items[i*8+j] = true;
						else
							Items[i*8+j] = false;
					}
				}
			}
			// Counter stuff
			{
				int ints[64];
				f->ReadInts(ints);
				for(int i=0; i<32; ++i)
				{
					Counters[i] = ints[i];
					MCounters[i] = ints[i+32];
				}
			}
			// LKeys
			{
				int ints[512];
				f->ReadInts(ints);
				for(int i=0; i<512; ++i)
				{
					LKeys[i] = ints[i];
				}
			}
			// LItems
			{
				int bytes[512];
				f->ReadBytes(bytes);
				for(int i=0; i<512; ++i)
				{
					int val = bytes[i];
					
					Map[i] = (val&0x1);
					Compass[i] = (val&0x2);
					BossKey[i] = (val&0x4);
					BossDead[i] = (val&0x8);
					Triforce[i] = (val&0x10);
				}
				f->WriteBytes(bytes);
			}
			// Generic
			{
				int bytes[3];
				f->ReadBytes(bytes);
				CanSlash = bytes[0];
				HeartPieces = bytes[1];
				MagicDrainRate = bytes[2];
			}
			// Continue
			{
				int ints[2];
				f->ReadInts(ints);
				SavedDMap = ints[0];
				SavedScreen = ints[1];
			}
			f->Free();
		}
		void SaveToFile()
		{
			file f;
			f->OpenMode(FilePath, "wb+");
			f->Own();
			// Valid
			{
				int bytes[1];
				bytes[0] = 1;
				f->WriteBytes(bytes);
			}
			// Items
			{
				int bytes[32];
				for(int i=0; i<32; ++i)
				{
					int val;
					for(int j=0; j<8; ++j)
					{
						if(Items[i*8+j])
							val |= 1<<j;
					}
					bytes[i] = val;
				}
				f->WriteBytes(bytes);
			}
			// Counter stuff
			{
				int ints[64];
				for(int i=0; i<32; ++i)
				{
					ints[i] = Counters[i];
					ints[i+32] = MCounters[i];
				}
				f->WriteInts(ints);
			}
			// LKeys
			{
				int ints[512];
				for(int i=0; i<512; ++i)
				{
					ints[i] = LKeys[i];
				}
				f->WriteInts(ints);
			}
			// LItems
			{
				int bytes[512];
				for(int i=0; i<512; ++i)
				{
					int val;
					if(Map[i])
						val |= 0x1;
					if(Compass[i])
						val |= 0x2;
					if(BossKey[i])
						val |= 0x4;
					if(BossDead[i])
						val |= 0x8;
					if(Triforce[i])
						val |= 0x10;
					bytes[i] = val;
				}
				f->WriteBytes(bytes);
			}
			// Generic
			{
				int bytes[3];
				bytes[0] = CanSlash;
				bytes[1] = HeartPieces;
				bytes[2] = MagicDrainRate;
				f->WriteBytes(bytes);
			}
			// Continue
			{
				int ints[2];
				ints[0] = SavedDMap;
				ints[1] = SavedScreen;
				f->WriteInts(ints);
			}
			f->Free();
		}
		// Erases a file
		void Erase()
		{
			if(FileSystem->FileExists(FilePath))
			{
				FileSystem->Remove(FilePath);
			}
			Valid = false;
		}
		
		// Draws the contents of a save (hearts, item, and dmap) to the screen
		void DrawToScreen(int x, int y)
		{
			if(!Valid)
			{
				Screen->DrawString(6, x+4, y+4, FONT_Z3SMALL, C_TESTPLAY_WHITE, -1, TF_NORMAL, "EMPTY", OP_OPAQUE, SHD_OUTLINED8, C_TESTPLAY_BLACK);
				return;
			}
			
			// Draw the name of the current dmap
			int nameBuf[512];
			Game->GetDMapName(SavedDMap, nameBuf);
			int nameBuf2[512];
			int hexBuf[8];
			sprintf(hexBuf, "%02X", SavedScreen);
			hexBuf[0] = hexBuf[2];
			hexBuf[1] = hexBuf[3];
			hexBuf[2] = 0;
			sprintf(nameBuf2, "%d:%s - %s", SavedDMap, hexBuf, nameBuf);
			Screen->DrawString(6, x+4, y+4, FONT_Z3SMALL, C_TESTPLAY_WHITE, -1, TF_NORMAL, nameBuf2, OP_OPAQUE, SHD_OUTLINED8, C_TESTPLAY_BLACK);
			
			bitmap collection = Game->CreateBitmap(256, 176);
			collection->Clear(0);
			bitmap collectionBG = Game->CreateBitmap(256, 176);
			
			// Draw the hearts
			bitmap heartIcn = Game->CreateBitmap(8, 8);
			heartIcn->Clear(0);
			heartIcn->FastTile(0, 0, 0, 0, 1, OP_OPAQUE);
			int numHearts = Min(Floor(MCounters[CR_LIFE]/16), 24);
			for(int i=0; i<numHearts; ++i)
			{
				heartIcn->Blit(0, collection, 0, 0, 8, 8, x+8*(i%8), y+16+8*Floor(i/8), 8, 8, 0, 0, 0, BITDX_NORMAL, 0, true);
			}
			heartIcn->Free();
			
			// Draw the obtained items
			int validItems;
			for(int i=0; i<256; ++i)
			{
				if(Items[i])
				{
					itemdata id = Game->LoadItemData(i);
					collection->FastTile(0, x+16*(validItems%15), y+16+32+16*Floor(validItems/15), id->Tile, id->CSet, 128);
					++validItems;
				}
			}
			
			// Draw the collected items to a second bitmap and fill with a background color
			collection->Blit(0, collectionBG, 0, 0, 256, 176, 0, 0, 256, 176, 0, 0, 0, BITDX_NORMAL, 0, false);
			collectionBG->ReplaceColors(0, C_TESTPLAY_BLACK, 0x01, 0xFF);
			
			// Draw the background 8 times to form an outline
			int offX[] = {0, 0, -1, 1, -1, 1, -1, 1};
			int offY[] = {-1, 1, 0, 0, -1, -1, 1, 1};
			for(int i=0; i<8; ++i)
			{
				collectionBG->Blit(6, RT_SCREEN, 0, 0, 256, 176, offX[i], offY[i], 256, 176, 0, 0, 0, BITDX_NORMAL, 0, true);
			}
			// Draw the collection in front of it
			collection->Blit(6, RT_SCREEN, 0, 0, 256, 176, 0, 0, 256, 176, 0, 0, 0, BITDX_NORMAL, 0, true);
			collection->Free();
			collectionBG->Free();
		}
		
		int Slot;
		int FilePath[32];
		
		bool Items[256];
		int Counters[32];
		int MCounters[32];
		
		int LKeys[512];
		bool Map[512];
		bool Compass[512];
		bool BossKey[512];
		bool BossDead[512];
		bool Triforce[512];
		
		int CanSlash;
		int HeartPieces;
		int MagicDrainRate;
		
		int SavedDMap;
		int SavedScreen;
		
		bool Valid;
	}

	generic script TestPlayItemsUI
	{
		void run(int mode, bool firstLoad)
		{
			int slot = GetLastSlot();
			
			TestPlayInitData slots[10];
			int validSlots;
			for(int i=0; i<10; ++i)
			{
				slots[i] = new TestPlayInitData(i);
				if(slots[i]->Valid)
					++validSlots;
			}
			
			if(firstLoad)
			{
				// If there's no slots to load to begin with, just quit automatically.
				if(validSlots == 0)
					Quit();
					
				slot = TryFindDMapSlot(slots, slot);
			}
			
			int sSave[] = "SAVE";
			int sLoad[] = "LOAD";
			int sErase[] = "ERASE";
			int modes[] = {sSave, sLoad, sErase};
			
			while(true)
			{
				Screen->Rectangle(6, 0, 0, 255, 175, C_TESTPLAY_BLACK, 1, 0, 0, 0, true, OP_TRANS);
				Screen->DrawString(6, 8, 8, FONT_ALLEGRO, C_TESTPLAY_WHITE, -1, TF_NORMAL, "SELECT A SLOT:", OP_OPAQUE, SHD_OUTLINED8, C_TESTPLAY_BLACK);
				
				for(int i=0; i<3; ++i)
				{
					int c = C_TESTPLAY_WHITE;
					if(mode==i)
						c = C_TESTPLAY_SELECTION;
					Screen->DrawString(6, 192, 8+12*i, FONT_ALLEGRO, c, -1, TF_NORMAL, modes[i], OP_OPAQUE, SHD_OUTLINED8, C_TESTPLAY_BLACK);
				}
				
				for(int i=0; i<10; ++i)
				{
					int buf[8];
					sprintf(buf, "%d", i);
					int c = C_TESTPLAY_WHITE;
					if(i==slot)
						c = C_TESTPLAY_SELECTION;
					else if(!slots[i]->Valid)
						c = C_TESTPLAY_GRAY;
					Screen->DrawString(6, 8+12*i, 20, FONT_ALLEGRO, c, -1, TF_NORMAL, buf, OP_OPAQUE, SHD_OUTLINED8, C_TESTPLAY_BLACK);
				}
				
				if(!firstLoad)
				{
					if(Link->PressUp)
					{
						--mode;
						if(mode<0)
							mode = 2;
						Game->PlaySound(SFX_CURSOR);
					}
					else if(Link->PressDown)
					{
						++mode;
						if(mode>2)
							mode = 0;
						Game->PlaySound(SFX_CURSOR);
					}
				}
				if(Link->PressLeft)
				{
					--slot;
					if(slot<0)
						slot = 9;
					Game->PlaySound(SFX_CURSOR);
				}
				else if(Link->PressRight)
				{
					++slot;
					if(slot>9)
						slot = 0;
					Game->PlaySound(SFX_CURSOR);
				}
				
				slots[slot]->DrawToScreen(8, 32);
				
				if(Link->PressA && (mode==MODE_SAVE || slots[slot]->Valid))
				{
					switch(mode)
					{
						case MODE_SAVE:
						{
							Game->PlaySound(SFX_CURSOR);
							slots[slot]->GetInitData();
							slots[slot]->SaveToFile();
							RecordLastSlot(slot);
							break;
						}
						case MODE_LOAD:
						{
							Game->PlaySound(SFX_CURSOR);
							slots[slot]->SetInitData();
							RecordLastSlot(slot);
							Quit();
							break;
						}
						case MODE_ERASE:
						{
							Game->PlaySound(SFX_OUCH);
							slots[slot]->Erase();
							break;
						}
					}
				}
				if(Link->PressB)
				{
					Game->PlaySound(SFX_OUCH);
					RecordLastSlot(slot);
					Quit();
				}
				
				Waitframe();
			}
		}
		int GetLastSlot()
		{
			file f;
			int slotfilename[] = "InitData/InitDataSlot";
			if(FileSystem->FileExists(slotfilename))
			{
				int b[1];
				f->OpenMode(slotfilename, "rb+");
				f->ReadBytes(b);
				f->Free();
				return b[0];
			}
			else{
				f->OpenMode(slotfilename, "wb+");
				f->WriteBytes({0});
				f->Free();
				return 0;
			}
		}
		void RecordLastSlot(int val)
		{
			file f;
			int slotfilename[] = "InitData/InitDataSlot";
			if(FileSystem->FileExists(slotfilename))
			{
				int b[1] = {val};
				f->OpenMode(slotfilename, "wb+");
				f->WriteBytes(b);
				f->Free();
			}
		}
		// When first loading the quest, try and find a slot on the current dmap to default to
		int TryFindDMapSlot(TestPlayInitData slots, int slot)
		{
			for(int i=0; i<10; ++i)
			{
				if(slots[i]->Valid&&slots[i]->SavedDMap==Game->GetCurDMap())
					return i;
			}
			return slot;
		}
	}
}