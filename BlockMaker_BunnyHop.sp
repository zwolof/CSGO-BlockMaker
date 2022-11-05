#include <sdkhooks>
#include <sdktools>
#include <blockmaker>

bool g_bBlockIsTriggered = false;

// We need to register the block with the blockmaker system
public void BM_OnLoaded() {
	BlockParams params = new BlockParams();

	params.SetName("BunnyHop");
	params.SetModel("bunnyhop");
	params.SetBlockType(BlockType_BunnyHop);
	params.SetDescription("This is my block");
	params.SetColor(255, 255, 255, 255);

	BlockProps props = new BlockProps();

	BlockMaker_RegisterBlock(params, props);
}

public void OnMapStart() {
	// BlockMaker_DownloadModelsAndMaterials("bunnyhop");
}

// This is called when the block is touched
// forward void BM_OnBlockTouchEnd(int client, GameBlock block)

public void BM_OnBlockTouchStart(int client, int entity, GameBlock block) {

	if(!block.data._Params.GetBlockType() & BlockType_BunnyHop) {
		return;
	}

	if(g_bBlockIsTriggered) {
		return;
	}
	g_bBlockIsTriggered = true;

	// Set the block to triggered and set collision to false
	PrintToChatAll("BunnyHop block triggered!");

	// We get the property "time" from the block in the core plugin
	// float fTime = BlockMaker_GetPropertyFloat(entity, "time");
	CreateTimer(0.1, Timer_StartNoblock, EntIndexToEntRef(block.entity), TIMER_FLAG_NO_MAPCHANGE);
}

public Action Timer_StartNoblock(Handle timer, any ent) {
	int entity = EntRefToEntIndex(ent);

	// Reset collision
	BlockMaker_SetBlockCollision(entity, false);

	// Reset block
	CreateTimer(1.5, Timer_ResetBlock, EntIndexToEntRef(entity), TIMER_FLAG_NO_MAPCHANGE);

	return Plugin_Stop;
}

// Timer to reset the block collision after a certain amount of time
public Action Timer_ResetBlock(Handle timer, any ent) {
	int entity = EntRefToEntIndex(ent);

	// Reset collision
	BlockMaker_SetBlockCollision(entity, true);
	g_bBlockIsTriggered = false;

	return Plugin_Stop;
}

// Don't need this anymore, unstuck handled by the core
// public void BunnyHop_OnBlockTouchEnd(int block, int client) { }
