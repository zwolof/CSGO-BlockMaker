stock bool GetAimOriginDist(int client, float hOrigin[3], float fDist=100.0) {
	float vAngles[3], fOrigin[3];
	GetClientEyePosition(client, fOrigin);
	GetClientEyeAngles(client, vAngles);
	
	float fFw[3];
	GetAngleVectors(vAngles, fFw, NULL_VECTOR, NULL_VECTOR);
	NormalizeVector(fFw, fFw);
	ScaleVector(fFw, fDist);
	
	AddVectors(hOrigin, fOrigin, hOrigin);
	AddVectors(hOrigin, fFw, hOrigin);

	Handle trace = TR_TraceRayFilterEx(fOrigin, hOrigin, MASK_SHOT, RayType_EndPoint, trNoPlayers);

	if(TR_DidHit(trace)) {
		TR_GetEndPosition(hOrigin, trace);
		CloseHandle(trace);
		return true;
	}

	CloseHandle(trace);
	return false;
}

public bool trNoPlayers(int iEnt, int iBitMask, any iData) {
	return !(iEnt == iData ||1 <= iEnt <= MaxClients);
}