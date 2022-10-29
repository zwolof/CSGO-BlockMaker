#define INJECT_MENU_END(%1) case MenuAction_End: delete %1
#define INJECT_MENU_SELECT() case MenuAction_Select:
#define INJECT_MENU_BUTTONS(%1) %1.ExitButton = true
#define INJECT_MENU_GETITEM(%1, %2) char sChosenItem[32]; %1.GetItem(%2, sChosenItem, sizeof(sChosenItem));

public Plugin myinfo = {
	name = "BlockMaker",
	author = "zwolof",
	description = "A tool to create sick courses in csgo yee",
	version = "0.0.1",
	url = "www.efrag.gg"
};

char g_szCurrentBlockType[MAXPLAYERS+1][32];

BlockSize g_BlockSize[MAXPLAYERS+1] = {BlockSize_Normal, ...};

StringMap g_smBlocks = null;
StringMap g_smSpawnedBlocks = null;

GlobalForward g_fwOnBMLoaded;
GlobalForward g_fwOnBlockCreated;

GlobalForward g_fwOnBlockTouchStart;
GlobalForward g_fwOnBlockTouchEnd;