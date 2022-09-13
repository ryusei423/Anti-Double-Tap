#include <sourcemod>
#include <colors>
#include <sdkhooks>
#include <sdktools>
#include <cstrike>

public Plugin myinfo = 
{ 
	name = "Anti Double-Tap", 
	author = "Kiana1337", 
	description = "", 
	version = "0.1", 
	url = "https://steamcommunity.com/id/Kiana1337/" 
};

int last_shot[MAXPLAYERS+1];
char name[12];
char color[12];
ConVar dlshvh_max_allow_dt;
public void OnPluginStart(){
	LoadConfig();
	HookEvent("player_spawn", Event_PlayerSpawn);
	dlshvh_max_allow_dt = CreateConVar("dlshvh_max_allow_dt", "5", "玉山白雪飘零 燃烧少年的心", /*FCVAR_DONTRECORD | */FCVAR_PROTECTED );
}

public void OnClientPutInServer(int client){
	last_shot[client] = 0;
	//SDKHook(client, SDKHook_OnTakeDamage, OnTakeDamage);
}

public Action Event_PlayerSpawn(Event event, const char[] sName, bool bDontBroadcast){
	int client = GetClientOfUserId(event.GetInt("userid"));
	//should_remove[client] = false;
}

public Action OnPlayerRunCmd(int client, int& buttons, int& impulse, float vel[3], float angles[3], int& weapon, int& subtype, int& cmdnum, int& tickcount, int& seed, int mouse[2]){
	if (!IsPlayerAlive(client)) {
		return Plugin_Continue;
	}
	if(buttons & IN_ATTACK){
		int weapon = GetEntPropEnt(client, Prop_Data, "m_hActiveWeapon");
		if(GetEntPropFloat(weapon, Prop_Send, "m_flNextPrimaryAttack") <= (GetEntProp(client,Prop_Send,"m_nTickBase") * GetTickInterval()) && 
		GetEntPropFloat(client, Prop_Send, "m_flNextAttack") <= (GetEntProp(client,Prop_Send,"m_nTickBase") * GetTickInterval())&&
		GetEntProp(weapon, Prop_Send, "m_iClip1")){
			
			//CPrintToChatAll("%f",GetEntPropFloat(weapon, Prop_Send, "m_flNextPrimaryAttack"));
			//CPrintToChatAll("engine:%f",GetGameTime());
			if(last_shot[client] == 0){
			last_shot[client] = GetGameTickCount();
			return Plugin_Changed;
			}
			//CPrintToChatAll("%d", GetGameTickCount() - last_shot[client]);
			if(IsDTWeaponEx(client) && GetGameTickCount() - last_shot[client] < GetConVarInt(dlshvh_max_allow_dt)){
				CPrintToChat(client,"%s%s \x01 命令已被拒绝,不要尝试DT或者空放。", color,name);
				return Plugin_Handled;
			}
			
			last_shot[client] = GetGameTickCount();
			
			
		}
		
	}
	return Plugin_Continue;
}

stock bool IsDTWeaponEx(int client)
{
	char weapon[64];
	GetClientWeapon(client, weapon, sizeof(weapon));

	//只在沙鹰和连狙上移除
    if(StrEqual(weapon,"weapon_g3sg1",true)
		|| StrEqual(weapon,"weapon_scar20",true)
		/*|| StrEqual(weapon,"weapon_deagle",true))*/)return true;
		
		
	return false;
}

public void LoadConfig(){
	char sConfig[PLATFORM_MAX_PATH];
	BuildPath(Path_SM, sConfig, PLATFORM_MAX_PATH, "configs/dlshvhCommunity.cfg");
	if(!FileExists(sConfig)){
		SetFailState("File %s not found", sConfig);
	}
	
	KeyValues kv = CreateKeyValues("Chat");
	FileToKeyValues(kv, sConfig);
	
	
	KvGetString(kv, "name",name,12,"[德丽莎]")
	KvGetString(kv, "color",color,12,"{blue}")
	
	
	KvRewind(kv);
	
	delete kv;
	
}