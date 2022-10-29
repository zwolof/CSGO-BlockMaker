public Action Command_BM(int client, int args) {
	Menus_CreateMainMenu(client);
	ReplyToCommand(client, "Menu created.");

	return Plugin_Handled;
}
public Action Command_Blocks(int client, int args) {
	ReplyToCommand(client, "Blocks: \x10%d", g_smBlocks.Size);

	return Plugin_Handled;
}

public void Menus_CreateMainMenu(int client) {
	Menu menu = new Menu(Menus_MainMenuHandler);
	menu.SetTitle("BlockMaker V1.0\n ");

	char buffer[128];

	// Current Selected Block
	// Block block;
	// g_smBlocks.GetValue(g_szCurrentBlockType[client], block);
	// block.GetString("name", buffer, sizeof(buffer));

	Format(buffer, sizeof(buffer), "Selected: \n    %s\n ", g_szCurrentBlockType[client]);
	menu.AddItem("current_block", buffer);

	// Block Actions
	menu.AddItem("create_block", "Create Block");
	menu.AddItem("rotate_block", "Rotate Block");
	menu.AddItem("convert_block", "Convert Block");
	menu.AddItem("delete_block", "Delete Block");

	BlockSize size = g_BlockSize[client];

	// Size
	Format(buffer, sizeof(buffer), "Size: \n    %s\n ", g_sBlockSizes[size][0]);
	menu.AddItem("block_size", buffer);

	// Inject Exit Button
	INJECT_MENU_BUTTONS(menu);

	menu.Display(client, MENU_TIME_FOREVER);
}

public int Menus_MainMenuHandler(Menu menu, MenuAction action, int client, int option) {
	char sChosenItem[128];
	menu.GetItem(option, sChosenItem, sizeof(sChosenItem));
	
	switch (action) {
		case MenuAction_Select: {
			if(StrEqual(sChosenItem, "current_block", false)) {
				Menus_CreateBlockSelectionMenu(client);
			}
			else if(StrEqual(sChosenItem, "create_block", false)) {
				BlockData data;
				g_smBlocks.GetArray(g_szCurrentBlockType[client], data, sizeof(BlockData));

				char blockModel[128];
				data._Params.GetModel(blockModel, sizeof(blockModel));
				BlockManager.Create(data, blockModel, client);

				BlockMaker.PrintToChat(client, "Menu - Block created - \x10%s", blockModel);
				
				Menus_CreateMainMenu(client);
			}
			// else if(StrEqual(sChosenItem), "rotate_block", false) {
			// 	// _BlockManager.Rotate(client);
			// }
			// else if(StrEqual(sChosenItem), "convert_block", false) {
			// 	// _BlockManager.Convert(client);
			// }
			else if(StrEqual(sChosenItem, "delete_block", false)) {
				// _BlockManager.Delete(client);
				int iEnt = GetClientAimTarget(client, false);

				GameBlock gBlock;
				char sEntIndex[128]; IntToString(iEnt, sEntIndex, sizeof(sEntIndex));
				g_smSpawnedBlocks.GetArray(sEntIndex, gBlock, sizeof(gBlock));

				if(gBlock.entity == iEnt) {
					BlockManager.Destroy(iEnt);

					BlockMaker.PrintToChat(client, "Block deleted.");
				}
			}
			else if(StrEqual(sChosenItem, "block_size", false)) {
				BlockSize size = g_BlockSize[client];

				if(size == BlockSize_Pole) {
					g_BlockSize[client] = BlockSize_Small;
				}
				else if(size == BlockSize_Small) {
					g_BlockSize[client] = BlockSize_Normal;
				}
				else if(size == BlockSize_Normal) {
					g_BlockSize[client] = BlockSize_Large;
				}
				else if(size == BlockSize_Large) {
					g_BlockSize[client] = BlockSize_Small;
				}
				Menus_CreateMainMenu(client);
			}
		}
		case MenuAction_End: {
			delete menu;
		}
	}
	return 0;
}