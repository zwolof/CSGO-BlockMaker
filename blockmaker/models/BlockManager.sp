ArrayList g_alBlocks = null;

methodmap BlockManager __nullable__ {
    // public BlockManager() {
    //     return view_as<BlockManager>(this);
    // }

	public static int Create(BlockData data, const char[] blockType, int creator = 0, float fPosition[3] = { 0.0, 0.0, 0.0 }, float fAngles[3] = { 0.0, 0.0, 0.0 }) {
        int entity = CreateEntityByName("prop_physics_override");

		if (entity == -1) {
			LogError("Failed to create entity");
			return -1;
		}

		GameBlock gameBlock;
		gameBlock.creator = creator;
		gameBlock.entity = entity;
		gameBlock.data = data;

		gameBlock.data._Params.SetSize(g_BlockSize[creator]);
		gameBlock.type ^= BlockType_BunnyHop;

		if(creator) {
			GetAimOriginDist(creator, fPosition, 100.0);
		}

		// Disable shadows
		DispatchKeyValue(entity, "disablereceiveshadows", "1");
		DispatchKeyValue(entity, "disableshadows", "1");
		DispatchKeyValue(entity, "disableshadowdepth", "1");
		DispatchKeyValue(entity, "model", "models/blockmaker_ultimate/bunnyhop.mdl");
		// DispatchKeyValue(entity, "skin", "1");

		// Teleport to position
		TeleportEntity(entity, fPosition, fAngles, NULL_VECTOR);

		// Spawn the block
		DispatchSpawn(entity);

		// Disable Movement
		SetEntityMoveType(entity, MOVETYPE_NONE);
		AcceptEntityInput(entity, "disablemotion");

		// Hooks
		SDKHook(entity, SDKHook_Touch, SDK_OnBlockTouchStart);
		SDKHook(entity, SDKHook_EndTouchPost, SDK_OnBlockTouchEnd);

		// Set Collision Group and SolidType
		SetEntProp(entity, Prop_Send, "m_nSolidType", SOLID_VPHYSICS);
		SetEntProp(entity, Prop_Data, "m_CollisionGroup", 0);
		SetEntityRenderMode(entity, RENDER_TRANSALPHA);

		BlockMaker.PrintToChat(creator, "Block created[%d] \x04%s\x01", entity, blockType);

		char sEntIdx[32];
		IntToString(entity, sEntIdx, sizeof(sEntIdx));
		g_smSpawnedBlocks.SetArray(sEntIdx, gameBlock, sizeof(GameBlock));

		return entity;
    }

	public static void Destroy(int iEntity) {
		if (iEntity == -1) {
			LogError("Failed to destroy entity");
			return;
		}

		char sEntIdx[32];
		IntToString(iEntity, sEntIdx, sizeof(sEntIdx));
		g_smSpawnedBlocks.Remove(sEntIdx);

		AcceptEntityInput(iEntity, "Kill");
	}
}

// enum struct BlockData {
// 	BlockParams _Params;
// 	BlockSize _Size;
// 	BlockProps _Props;

// 	SDKHookCB _OnStartTouch;
// 	SDKHookCB _OnEndTouch;
// }


// BlockManager _BlockManager = new BlockManager(); 