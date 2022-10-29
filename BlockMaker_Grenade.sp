#include <sdkhooks>
#include <sdktools>
#include <blockmaker>

bool g_bBlockIsTriggered = false;
#define MAX_ENTITIES 2048

bool g_bBlockTaken[MAXPLAYERS+1][MAX_ENTITIES];
bool g_bHasReceivedTakenMessage[MAXPLAYERS+1][MAX_ENTITIES];

// We need to register the block with the blockmaker system
public void BM_OnLoaded() {
	BlockParams params = new BlockParams();

	params.SetName("Grenade");
	params.SetModel("grenade");
	params.SetBlockType(BlockType_Grenade);
	params.SetDescription("This is my block");
	params.SetColor(255, 255, 255, 255);

	BlockProps props = new BlockProps();
	props.SetPropString("grenade", "weapon_flashbang");
	props.SetPropInt("grenade_count", 2);

	BlockMaker_RegisterBlock(params, props);

	HookEvent("round_start", Event_OnRoundStart);
}

public void OnMapStart() {
	// BlockMaker_DownloadModelsAndMaterials("grenade");
}

public void OnClientPostAdminCheck(int client) {
	for(int j = 0; j < MAX_ENTITIES; j++) {
		if(IsClientInGame(client)) {
			g_bBlockTaken[client][j] = false;
			g_bHasReceivedTakenMessage[client][j] = false;
		}
	}
}

public void Event_OnRoundStart(Event event, const char[] name, bool ignore) {
	for(int i = 1; i <= MaxClients; i++) {
		for(int j = 0; j < MAX_ENTITIES; j++) {
			if(IsClientInGame(i)) {
				g_bBlockTaken[i][j] = false;
				g_bHasReceivedTakenMessage[i][j] = false;
			}
		}
	}
}

public void BM_OnBlockTouchStart(int client, int entity, GameBlock block) {
	if (block.data._Params.GetBlockType() & BlockType_Grenade) {

		if(g_bBlockTaken[client][entity]) {
			if(!g_bHasReceivedTakenMessage[client][entity]) {
				BlockMaker.PrintToChat(client, "You have already taken this block!");
				g_bHasReceivedTakenMessage[client][entity] = true;

				return;
			}
			g_bHasReceivedTakenMessage[client][entity] = true;
			return;
		}

		BlockMaker.PrintToChat(client, "Grenade Block Triggered! Ent: \x10%d", entity);

		char sNade[128];
		block.data._Props.GetString("grenade", sNade, sizeof(sNade));

		int count = block.data._Props.GetPropInt("grenade_count");

		for(int i = 0; i < count; i++) {
			GivePlayerItem(client, sNade);
		}
		g_bBlockTaken[client][entity] = true;
	}
}
