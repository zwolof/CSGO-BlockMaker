public Native_BlockMaker_RegisterBlock(Handle plugin, int numParams) {

    BlockParams _Params = GetNativeCell(1);
    BlockProps _Props = GetNativeCell(2);
    // BlockParams _Params = CloneHandle(GetNativeCell(1));
    // BlockProps _Props = CloneHandle(GetNativeCell(2));

	// Callbacks
	// SDKHookCB BlockTouchStart = GetNativeCell(3);
	// SDKHookCB BlockTouchEnd = GetNativeCell(4);

	// Create a new block class
	BlockData blockData;
	// blockData._OnStartTouch = BlockTouchStart;
	// blockData._OnEndTouch = BlockTouchEnd;
	blockData._Params = _Params;
	blockData._Props = _Props;
	
	char blockName[32];
	blockData._Params.GetModel(blockName, sizeof(blockName));

	if(g_smBlocks == null) {
		g_smBlocks = new StringMap();
	}
	// Register the block
	g_smBlocks.SetArray(blockName, blockData, sizeof(BlockData));
}

public Native_BlockMaker_SetBlockCollision(Handle plugin, int numParams) {
	int iEntity = GetNativeCell(1);
	bool enable = GetNativeCell(2);

	int color[4];
	color[0] = enable ? 255 : 128;
	color[1] = enable ? 255 : 128;
	color[2] = enable ? 255 : 128;
	color[3] = enable ? 255 : 128;

	SetEntityRenderColor(iEntity, color[0], color[1], color[2], color[3]);

	SetEntProp(iEntity, Prop_Send, "m_nSolidType", enable ? SOLID_VPHYSICS : SOLID_NONE);

	PrintToChatAll("Block collision set to %s", enable ? "true" : "false");
}

public Native_BlockMaker_DownloadModelsAndMaterials(Handle plugin, int numParams) {
	char sBlockname[128];
	GetNativeString(1, sBlockname, sizeof(sBlockname));

	char sFilePathBuffer[PLATFORM_MAX_PATH];
	char materialEndings[2][8] = {".vmt", ".vtf"};

	for (int i = 0; i < 2; i++) {
		Format(sFilePathBuffer, sizeof(sFilePathBuffer), "materials/blockmaker_ultimate/blocks/%s%s", sBlockname, materialEndings[i]);
		AddFileToDownloadsTable(sFilePathBuffer);

		PrintToServer("Downloading[%i]: %s", i, sFilePathBuffer);
	}

	PrintToServer("====================================");	
}

public Native_BlockMaker_GetPropertyFloat(Handle plugin, int numParams) {
	// int iEntity = GetNativeCell(1);
	// int iMaxLen = GetNativeCell(3);

	// char prop[32];
	// GetNativeString(2, prop, iMaxLen);

	// float value = GetEntPropFloat(iEntity, Prop_Data, prop);
	// SetNativeCell(4, value);
}

public Native_BlockMaker_GetBlockSizeByEntIndex(Handle plugin, int numParams) {
	int iEntity = GetNativeCell(1);
	GameBlock gBlock;
	char sEntIndex[16];

	IntToString(iEntity, sEntIndex, sizeof(sEntIndex));
	g_smSpawnedBlocks.GetArray(sEntIndex, gBlock, sizeof(GameBlock));
	BlockSize size = gBlock.data._Params.GetSize();

	SetNativeCellRef(2, size);
}
