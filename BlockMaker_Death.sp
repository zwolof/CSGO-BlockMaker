#include <sdkhooks>
#include <sdktools>

#include <blockmaker>

// We need to register the block with the blockmaker system
public void BM_OnLoaded() {
	BlockParams params = new BlockParams();

	params.SetName("Death");
	params.SetModel("death");
	params.SetBlockType(BlockType_Death);
	params.SetDescription("This is my block");
	params.SetColor(255, 255, 255, 255);

	BlockProps props = new BlockProps();
	props.SetPropFloat("delay", 0.0);

	BlockMaker_RegisterBlock(params, props);
}

public void OnMapStart() {
	BlockMaker_DownloadModelsAndMaterials("bunnyhop");
}

// This is called when the block is touched
public void BM_OnBlockTouchStart(int client, int entity, GameBlock block) {
	if(client < 0 || !IsPlayerAlive(client)) return;

	if(!block.data._Params.GetBlockType() & BlockType_Death) {
		return;
	}

	// Set the block to triggered and set collision to false
	PrintToChatAll("Death block triggered!");

	ForcePlayerSuicide(client);
}
