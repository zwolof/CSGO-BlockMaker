#include <blockmaker>

bool g_bBlockIsTriggered = false;

// We need to register the block with the blockmaker system
public void OnPluginStart() {
	BlockMaker_RegisterBlock("BunnyHop", "bunnyhop", BunnyHop_OnBlockTouch, BunnyHop_OnBlockTouchEnd);
}

// This is called when the block is touched
public void BunnyHop_OnBlockTouch(int block, int client) {
	if (g_bBlockIsTriggered) {
		return;
	}

	// Set the block to triggered and set collision to false
	BlockMaker_SetBlockCollision(block, false);
	g_bBlockIsTriggered = true;

	// We get the property "time" from the block in the core plugin
	float fTime = BlockMaker_GetPropertyFloat(block, "time");

	// Since the block needs to reset to its original state, we create a timer and set the block to untriggered in the callback
	CreateTimer(fTime, Timer_ResetBlock, EntIndexToEntRef(block), TIMER_FLAG_NO_MAPCHANGE);
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
public void BunnyHop_OnBlockTouchEnd(int block, int client) { }