#if defined blockmakerincluded
	#endinput
#endif
#define blockmakerincluded


#define float(%1) view_as<float>(%1)
#define int(%1) view_as<float>(%1)
#define string(%1) (%1, sizeof(%1))

enum BlockSize {
	BlockSize_Pole = 0,
	BlockSize_Small,
	BlockSize_Normal,
	BlockSize_Large,
}

enum BlockType (<<=1) {
	BlockType_BunnyHop = 1,
	BlockType_Death,
	BlockType_Grenade
}

char g_sBlockSizes[BlockSize][2][32] = {
	{ "Pole", 	"bunnyhop" },
	{ "Small", 	"bunnyhop" },
	{ "Normal", "bunnyhop" },
	{ "Large", 	"bunnyhop" },
};

methodmap BlockMaker {
	public static void PrintToChat(int client, char[] message, any ...) {
		if(client && IsClientInGame(client) && !IsFakeClient(client)) {
			char szBuffer[PLATFORM_MAX_PATH], szNewMessage[PLATFORM_MAX_PATH];
			Format(szBuffer, sizeof(szBuffer), " \x01[\x04BM\x01] \x08%s", message);
			VFormat(szNewMessage, sizeof(szNewMessage), szBuffer, 3);

			Handle hBf = StartMessageOne("SayText2", client, USERMSG_RELIABLE | USERMSG_BLOCKHOOKS);
			if(hBf != null) {
				if(GetUserMessageType() == UM_Protobuf) {
					Protobuf hProtoBuffer = UserMessageToProtobuf(hBf);
					hProtoBuffer.SetInt("ent_idx", client);
					hProtoBuffer.SetBool("chat", true);
					hProtoBuffer.SetString("msg_name", szNewMessage);
					hProtoBuffer.AddString("params", "");
					hProtoBuffer.AddString("params", "");
					hProtoBuffer.AddString("params", "");
					hProtoBuffer.AddString("params", "");
				}
				else {
					BfWrite hBfBuffer = UserMessageToBfWrite(hBf);
					hBfBuffer.WriteByte(client);
					hBfBuffer.WriteByte(true);
					hBfBuffer.WriteString(szNewMessage);
				}
			}
			EndMessage();
		}
	}

	public static void HUDMessage(int client, char[] message, any ...) {

	}
}

methodmap BlockParams < StringMap {
	public BlockParams() {
        return view_as<BlockParams>(new StringMap());
    }

	public void SetName(const char[] name) {
		this.SetString("name", name);
	}

	public void GetName(char[] name, int maxlength) {
		this.GetString("name", name, maxlength);
	}

	public void SetModel(const char[] model) {
		this.SetString("model", model);
	}

	public void GetModel(char[] model, int maxlength) {
		this.GetString("model", model, maxlength);
	}

	public void SetSize(BlockSize size) {
		this.SetValue("size", size);
	}
	 
	public BlockSize GetSize() {
		BlockSize size; this.GetValue("size", size);
		return size;
	}


	public void SetDescription(const char[] description) {
		this.SetString("description", description);
	}

	public void GetDescription(char[] description, int maxlength) {
		this.GetString("description", description, maxlength);
	}

	public void SetBlockType(BlockType type) {
		this.SetValue("block_type", type);
	}

	public int GetBlockType() {
		BlockType type; this.GetValue("block_type", type);
		return type;
	}

	public void SetColor(int r, int g, int b, int a = 255) {
		char sColor[16];
		FormatEx(sColor, sizeof(sColor), "%d %d %d %d", r, g, b, a);

		this.SetString("color", sColor);
	}
}

methodmap BlockProps < StringMap {
	public BlockProps() {
        return view_as<BlockProps>(new StringMap());
    }

	public void SetPropString(const char[] prop, const char[] value) {
		this.SetString(prop, value);
	}

	public void SetPropInt(const char[] prop, int value) {
		this.SetValue(prop, value);
	}

	public void SetPropFloat(const char[] prop, float value) {
		this.SetValue(prop, value);
	}

	public int GetPropInt(const char[] prop) {
		int retVal;
		this.GetValue(prop, retVal);

		return retVal;
	}

	public float GetPropFloat(const char[] prop) {
		float retVal;
		this.GetValue(prop, retVal);

		return retVal;
	}
}

enum struct BlockData {
	BlockParams _Params;
	BlockProps _Props;
}


enum struct GameBlock {
	int entity;
	int creator;
	int group;

	BlockData data;
	BlockType type;
}


native void BlockMaker_RegisterBlock(BlockParams params, BlockProps props);
native void BlockMaker_DownloadModelsAndMaterials(const char[] sBlockName);
native void BlockMaker_SetBlockCollision(int block, bool enable);
native void BlockMaker_GetBlockSizeByEntIndex(int entity, BlockSize &blockSize);

forward void BM_OnLoaded();

forward void BM_OnBlockTouchStart(int client, int entity, GameBlock block)
forward void BM_OnBlockTouchEnd(int client, int entity, GameBlock block)