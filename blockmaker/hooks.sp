public void OnPluginStart() {
	RegConsoleCmd("sm_bm", Command_BM);
	RegConsoleCmd("sm_blocks", Command_Blocks);

	g_fwOnBMLoaded = new GlobalForward("BM_OnLoaded", ET_Ignore);
	g_fwOnBlockTouchStart = new GlobalForward("BM_OnBlockTouchStart", ET_Ignore, Param_Cell, Param_Cell, Param_Array);
	g_fwOnBlockTouchEnd = new GlobalForward("BM_OnBlockTouchEnd", ET_Ignore, Param_Cell, Param_Cell, Param_Array);
}

public void OnMapStart() {
	g_smBlocks = new StringMap();
	g_smSpawnedBlocks = new StringMap();

	char modelEndings[4][16] = {".mdl", ".phy", ".dx90.vtx", ".vvd"};
	char sFilePathBuffer[PLATFORM_MAX_PATH];

	for (int i = 0; i < 4; i++) {
		for (int j = 0; j < 4; j++) {
			Format(sFilePathBuffer, sizeof(sFilePathBuffer), "models/blockmaker_ultimate/%s%s", g_sBlockSizes[j][1], modelEndings[i]);
			
			if(j == 0) {
				PrecacheModel(sFilePathBuffer);
			}
			AddFileToDownloadsTable(sFilePathBuffer);
			PrintToServer("Downloading[%i][%i]: %s", i, j, sFilePathBuffer);
		}
	}

	Call_StartForward(g_fwOnBMLoaded);
    Call_Finish();
}

public void OnMapEnd() {
	delete g_smBlocks;
	delete g_smSpawnedBlocks;
}

public void SDK_OnBlockTouchStart(int block, int client) {
	char sEntIdx[32];
	IntToString(block, sEntIdx, sizeof(sEntIdx));
	
	GameBlock gBlock;
	g_smSpawnedBlocks.GetArray(sEntIdx, gBlock, sizeof(GameBlock));

	Call_StartForward(g_fwOnBlockTouchStart);
	Call_PushCell(client);
	Call_PushCell(block);
	Call_PushArray(gBlock, sizeof(GameBlock));
	Call_Finish();

	// PrintToChatAll("Block touched: \x10%d", gBlock.creator);
}

public void SDK_OnBlockTouchEnd(int block, int client) {
	char sEntIdx[32];
	IntToString(block, sEntIdx, sizeof(sEntIdx));
	
	GameBlock gBlock;
	g_smSpawnedBlocks.GetArray(sEntIdx, gBlock, sizeof(GameBlock));
	
	Call_StartForward(g_fwOnBlockTouchEnd);
	Call_PushCell(client);
	Call_PushCell(block);
	Call_PushArray(gBlock, sizeof(GameBlock));
	Call_Finish();

	// PrintToChatAll("Block touched: \x10%d", gBlock.creator);
}

// public void OnMapStart() {
// 	g_BlockList = new ArrayList(sizeof(Block));

// 	char path[PLATFORM_MAX_PATH];
// 	BuildPath(Path_SM, path, sizeof(path), "data/blockmaker/blocks.json");

// 	// Create array of blockmakerdata
// 	JSONObject blockmakerDataObject = JSONObject.FromFile(path); 

// 	if(blockmakerDataObject == null) {
// 		PrintToServer("Error: Could not load blockmaker data");
// 		delete blockmakerDataObject;

// 		return;
// 	}

// 	// Get array of blocks
// 	if(blockmakerDataObject.HasKey("blocks")) {
// 		JSONArray blockArray = blockmakerDataObject.Get("blocks");

// 		int length = blockArray.Length;

// 		// loop over all blocks
// 		Block _block;
// 		for(int i = 0; i < length; i++) {
// 			_block.blockName = blockArray[i].Get("name");
// 			_block.blockModel = blockArray[i].Get("model");
// 		}

// 		// Clean up blocks object
// 		delete blockArray;
// 	}

// 	// Clean up the handles
// 	delete blockmakerDataObject;
// }

public APLRes AskPluginLoad2(Handle myself, bool late, char[] error, int err_max) {
	RegPluginLibrary("BlockMaker");

	// General BM hooks
	CreateNative("BlockMaker_RegisterBlock", Native_BlockMaker_RegisterBlock);
	CreateNative("BlockMaker_SetBlockCollision", Native_BlockMaker_SetBlockCollision);
	CreateNative("BlockMaker_DownloadModelsAndMaterials", Native_BlockMaker_DownloadModelsAndMaterials);
	CreateNative("BlockMaker_GetBlockSizeByEntIndex", Native_BlockMaker_GetBlockSizeByEntIndex);
	// CreateNative("BlockMaker_UpdateBlockPosition", Native_BlockMaker_UpdateBlockPosition);
	// CreateNative("BlockMaker_UpdateBlockRotation", Native_BlockMaker_UpdateBlockRotation);

	// Get props
	CreateNative("BlockMaker_GetPropertyFloat", Native_BlockMaker_GetPropertyFloat);
	// CreateNative("BlockMaker_GetPropertyInt", Native_BlockMaker_GetPropertyInt);
	// CreateNative("BlockMaker_GetPropertyString", Native_BlockMaker_GetPropertyString);

    return APLRes_Success;
}