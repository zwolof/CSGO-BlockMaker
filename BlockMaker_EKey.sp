#include <sdkhooks>
#include <sdktools>
#include <smlib>
#include <blockmaker>

bool g_bFeatureEnabled = false;

// We need to register the block with the blockmaker system
public void BM_OnLoaded() {
	g_bFeatureEnabled = true;
}

enum Sprites {
	Sprites_LaserBeam = 0,
	Sprites_Halo = 1,
}

int g_iSpriteMaterials[Sprites] = {-1, ...}
int g_iOldButtons[MAXPLAYERS+1];
int g_iCurrentGrabbedEnt[MAXPLAYERS+1] = {-1, ...};
float g_fGrabOffset[MAXPLAYERS+1][3];
float g_fDistance[MAXPLAYERS+1] = {100.0, ...};

public void OnPluginStart() {
	RegConsoleCmd("+grab", Command_GrabEntity);
	RegConsoleCmd("-grab", Command_UnGrabEntity);
}

public Action Command_GrabEntity(int client, int iArgs) {
	if(g_iCurrentGrabbedEnt[client] == -1) {
		
		float vAngles[3], fOrigin[3];
		GetClientEyePosition(client,fOrigin);
		GetClientEyeAngles(client, vAngles);

		int iEnt = GetClientAimTarget(client, false);
		
		if(IsValidEntity(iEnt)) {
			float fOrg[2][3];
			SetEntGrabbed(client, iEnt);
			
			Entity_GetAbsOrigin(iEnt, fOrg[0]);
			GetClientEyePosition(client,  fOrg[1]);

			for(int i = 0; i < 3; i++) {
				fOrg[0][i] -= g_fGrabOffset[client][i];
			}
			
			g_fDistance[client] = GetVectorDistance(fOrg[0], fOrg[1]);
			g_iCurrentGrabbedEnt[client] = iEnt;
		}
	}
	return Plugin_Handled;
}	

public Action Command_UnGrabEntity(int client, int args) {
	g_iCurrentGrabbedEnt[client] = -1;

	return Plugin_Handled;
}

public void SetEntGrabbed(int client, int iEnt){
	float fpOrigin[3], fbOrigin[3], iAiming[3], bOrigin[3];
	GetClientEyePosition(client, bOrigin);
	GetAimOrigin(client, iAiming);
	Entity_GetAbsOrigin(client, fpOrigin);
	Entity_GetAbsOrigin(iEnt, fbOrigin);
	
	for(int i = 0; i < 3; i++) {
		g_fGrabOffset[client][i] = fbOrigin[i] - iAiming[i];
	}
}

public void OnMapStart() {
	// BlockMaker_DownloadModelsAndMaterials("bunnyhop");
	char sprites[Sprites][32] = {
		"materials/sprites/laserbeam.vmt",
		"materials/sprites/halo.vmt",
	}

	char buffer[128];
	for(int i = 0; i < 2; i++) {
		FormatEx(buffer, sizeof(buffer), sprites[i]);
		AddFileToDownloadsTable(buffer);
		g_iSpriteMaterials[view_as<Sprites>(i)] = PrecacheModel(buffer);
	}
}

public void OnClientPostAdminCheck(int client) {
	g_fDistance[client] = 100.0;
	g_iCurrentGrabbedEnt[client] = -1;
}

public Action OnPlayerRunCmd(int client, int &buttons, int &impulse, float vel[3], float angles[3], int &weapon) {

	if ((g_iOldButtons[client] & IN_USE) && !(buttons & IN_USE) && g_bFeatureEnabled && g_iCurrentGrabbedEnt[client] == -1) {
		int iEnt = GetClientAimTarget(client, false);

		if(IsValidEntity(iEnt)) {
			ShowBlockBoxNew(iEnt, client);
		}
		g_iOldButtons[client] = buttons;

		return Plugin_Continue;
	}

	if(g_iCurrentGrabbedEnt[client] > -1) {
		if (buttons & IN_ATTACK)  {
			if(g_fDistance[client] <= 800.0) {
				g_fDistance[client] += 1.0;
			}
		}
		else if(buttons & IN_ATTACK2) {
			if(g_fDistance[client] >= 72.0) {
				g_fDistance[client] -= 1.0;
			}
		}

		if(IsValidEdict(g_iCurrentGrabbedEnt[client])) {
			MoveBlock(client);
		}

		g_iOldButtons[client] = buttons;
		
		return Plugin_Continue;
	}

	g_iOldButtons[client] = buttons;
}

public void MoveBlock(int client) {
	float posent[3], playerpos[3], playerangle[3], final[3];
	Entity_GetAbsOrigin(g_iCurrentGrabbedEnt[client], posent);
	GetClientEyePosition(client, playerpos);
	GetClientEyeAngles(client, playerangle);
	AddInFrontOf(client, playerpos, playerangle, g_fDistance[client], final);
	
	TeleportEntity(g_iCurrentGrabbedEnt[client], final, NULL_VECTOR, NULL_VECTOR);
}

stock AddInFrontOf(int client, float fVecOrigin[3], float fVecAngle[3], float fUnits, float fOutput[3]) {
	float vecAngVectors[3];
	vecAngVectors = fVecAngle;
	GetAngleVectors(vecAngVectors, vecAngVectors, NULL_VECTOR, NULL_VECTOR);
	for (int i; i < 3; i++) fOutput[i] += fVecOrigin[i] + g_fGrabOffset[client][i] + (vecAngVectors[i] * fUnits);
}

// This is called when the block is touched
// forward void BM_OnBlockTouchEnd(int client, GameBlock block)

void ShowLine(int client, float start[3], float end[3]) {
	for(int i = 0; i < 3; i++) {
		TE_SetupBeamPoints(start, end, g_iSpriteMaterials[Sprites_LaserBeam], g_iSpriteMaterials[Sprites_Halo], 1, 60, 3.0, 2.0, 2.0, 1500, 0.0, {255, 0, 96, 22}, 500);
		TE_SendToClient(client);
				
		TE_SetupBeamPoints(start, end, g_iSpriteMaterials[Sprites_LaserBeam], g_iSpriteMaterials[Sprites_Halo], 1, 60, 3.0, 4.0, 4.0, 1500, 0.0, {64, 0, 255, 10}, 500);
		TE_SendToClient(client);
			
		TE_SetupBeamPoints(start, end, g_iSpriteMaterials[Sprites_LaserBeam], g_iSpriteMaterials[Sprites_Halo], 1, 60, 3.0, 0.4, 0.4, 0, 0.0, {0, 255, 255, 255}, 0);
		TE_SendToClient(client);
		TE_SetupBeamPoints(start, end, g_iSpriteMaterials[Sprites_LaserBeam], g_iSpriteMaterials[Sprites_Halo], 1, 60, 3.0, 0.75, 0.75, 0, 0.0, {32, 0, 255, 255}, 0);
		TE_SendToClient(client);
	}
}

void ShowBlockBoxNew(int blockId, int client) {
    float origin[3], size[3], angles[3];
    GetEntPropVector(blockId, Prop_Send, "m_vecOrigin", origin);
    GetEntPropVector(blockId, Prop_Data, "m_angRotation", angles);

	BlockSize blockSize; BlockMaker_GetBlockSizeByEntIndex(blockId, blockSize);
    GetDefaultBlockSize(blockSize, size);
   
    float width = size[0];
    float depth = size[1];
    float height = size[2];
   
    float top[4][3], bot[4][3];
    CreateEdgePoints(origin, top, height*0.5, width*0.5, depth*0.5);
    CreateEdgePoints(origin, bot, -height*0.5, width*0.5, depth*0.5);
   
    float newTop[4][3], newBot[4][3];
    for(int i = 0; i < 4; ++i) {
        for(int j = 0; j < 3; ++j) {
            top[i][j] = top[i][j] - origin[j];
            bot[i][j] = bot[i][j] - origin[j];
        }
    }
   
    float matrix[3][3];
    CreateAngleMatrix(angles, matrix);
	
    for(int i = 0; i < 4; ++i) {
        VectorRotate(top[i], matrix, newTop[i]);
        VectorRotate(bot[i], matrix, newBot[i]);
       
        for(int j = 0; j < 3; ++j) {
            top[i][j] = newTop[i][j] + origin[j];
            bot[i][j] = newBot[i][j] + origin[j];
        }
    }
   
    for(int i = 0; i < 4; ++i) {
        ShowLine(client, top[i], top[(i+1)%4]);
        ShowLine(client, bot[i], bot[(i+1)%4]);
        ShowLine(client, top[i], bot[i]);
    }
}

void GetDefaultBlockSize(BlockSize blockSize, float size[3]) {
	float width, depth;

	float height = 8.0;
	switch(blockSize) {
		case BlockSize_Pole: {
			width = 8.0;
			depth = 64.0;
		}
		case BlockSize_Small: {
			width = 32.0;
			depth = 32.0;
		}
		case BlockSize_Normal: {
			width = 64.0;
			depth = 64.0;
		}
		case BlockSize_Large: {
			width = 128.0;
			depth = 128.0;
		}
	}
	size[0] = width;
	size[1] = depth;
	size[2] = height;
}

stock void VectorRotate(const float vec[3], const float matrix[3][3], float output[3]) {
    output[0] = matrix[0][0]*vec[0] + matrix[0][1]*vec[1] + matrix[0][2]*vec[2];
    output[1] = matrix[1][0]*vec[0] + matrix[1][1]*vec[1] + matrix[1][2]*vec[2];
    output[2] = matrix[2][0]*vec[0] + matrix[2][1]*vec[1] + matrix[2][2]*vec[2];
}

void CreateEdgePoints(const float origin[3], float output[4][3], float heightDifference, float width, float depth) {
    for(int i = 0; i < 4; ++i) {
        output[i][0] = origin[0];
        output[i][1] = origin[1];
        output[i][2] = origin[2] + heightDifference;
    }
    output[0][0] += width;
    output[0][1] += depth;
    output[1][0] -= width;
    output[1][1] += depth;
    output[2][0] -= width;
    output[2][1] -= depth;
    output[3][0] += width;
    output[3][1] -= depth;
}

stock void SinCos(float radian, float &sine, float &cosine) {
    sine = Sine(radian);
    cosine = Cosine(radian);
}
 
stock void CreateAngleMatrix(const float angles[3], float matrix[3][3]) {  
    float sinX, sinY, sinZ, cosX, cosY, cosZ;
    SinCos(DegToRad(angles[2]), sinX, cosX);
    SinCos(DegToRad(angles[0]), sinY, cosY);
    SinCos(DegToRad(angles[1]), sinZ, cosZ);
    
    matrix[0][0] = cosY*cosZ;
    matrix[0][1] = sinX*sinY*cosZ - cosX*sinZ;
    matrix[0][2] = sinX*sinZ + cosX*sinY*cosZ;
    matrix[1][0] = cosY*sinZ;
    matrix[1][1] = sinX*sinY*sinZ + cosX*cosZ;
    matrix[1][2] = cosX*sinY*sinZ - sinX*cosZ;
    matrix[2][0] = -sinY;
    matrix[2][1] = sinX*cosY;
    matrix[2][2] = cosX*cosY;
}


stock GetAimOrigin(int client, float hOrigin[3]) {
	float vAngles[3], fOrigin[3];
	GetClientEyePosition(client,fOrigin);
	GetClientEyeAngles(client, vAngles);
	
	Handle trace = TR_TraceRayFilterEx(fOrigin, vAngles, MASK_SHOT, RayType_Infinite, trNoPlayers);
	
	if(TR_DidHit(trace)) {
		TR_GetEndPosition(hOrigin, trace);
		CloseHandle(trace);
		return 1;
	}
	
	CloseHandle(trace);
	return 0;
}

public bool trNoPlayers(int iEnt, int iBitMask, any iData) {
	return !(iEnt == iData ||1 <= iEnt <= MaxClients);
}