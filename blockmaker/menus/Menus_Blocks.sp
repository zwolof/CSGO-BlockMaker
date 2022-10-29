public void Menus_CreateBlockSelectionMenu(int client) {

	int stringMapSize = g_smBlocks.Size;

	if(stringMapSize == 0) {
		return;
	}

	Menu menu = new Menu(Menus_BlockSelectionMenuHandler);
	menu.SetTitle("BlockMaker V1.0\n ");

	menu.AddItem("bunnyhop", "BunnyHop");
	menu.AddItem("death", "Death");
	menu.AddItem("grenade", "Grenade");

	// Inject Exit Button
	INJECT_MENU_BUTTONS(menu);

	menu.Display(client, MENU_TIME_FOREVER);
}

public int Menus_BlockSelectionMenuHandler(Menu menu, MenuAction action, int client, int option) {
	char sChosenItem[128];
	menu.GetItem(option, sChosenItem, sizeof(sChosenItem));
	
	switch (action) {
		case MenuAction_Select: {
			strcopy(g_szCurrentBlockType[client], sizeof(g_szCurrentBlockType[]), sChosenItem);
			PrintToChat(client, "You chose \x04%s", g_szCurrentBlockType[client]);

			Menus_CreateMainMenu(client);
		}
		INJECT_MENU_END(menu);
	}
	return 0;
}