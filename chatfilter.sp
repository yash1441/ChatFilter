#pragma semicolon 1
#pragma newdecls required

#include <sourcemod>
#include <chat-processor>

#define PLUGIN_VERSION		"1.0"

ConVar ChatFilterEnabled;
char Path2Txt[PLATFORM_MAX_PATH];

public Plugin myinfo = 
{
	name = "Chat Filter",
	author = "Simon",
	description = "Block bad words from chat",
	version = PLUGIN_VERSION,
	url = "yash1441@yahoo.com"
};

public void OnPluginStart()
{
	LoadTranslations("common.phrases");	
	CreateConVar("sm_chatfilter_version", PLUGIN_VERSION, "Chat Filter Version", FCVAR_NOTIFY | FCVAR_DONTRECORD | FCVAR_CHEAT);
	ChatFilterEnabled = CreateConVar("sm_chatfilter_enabled", "1", "Enable/Disable Chat Filter Plugin (1/0)", 0, true, 0.0, true, 1.0);
	BuildPath(Path_SM, Path2Txt, sizeof(Path2Txt), "configs/chatfilter.txt");
}

public Action CP_OnChatMessage(int& author, ArrayList recipients, char[] flagstring, char[] name, char[] message, bool& processcolors, bool& removecolors)
{
	if (GetConVarBool(ChatFilterEnabled) == false)
		return Plugin_Continue;
	if(!FileExists(Path2Txt))
	{
		SetFailState("Configuration text file %s not found!", Path2Txt);
		return Plugin_Continue;
	}
	Handle rFile = OpenFile(Path2Txt, "r");
	char lBuffer[150];
	while (ReadFileLine(rFile, lBuffer, sizeof(lBuffer)))
	{
		ReplaceString(lBuffer, sizeof(lBuffer), "\n", "", false);
		if (!lBuffer[0] || lBuffer[0] == ';' || lBuffer[0] == '/' && lBuffer[1] == '/') 
			continue;
		if (StrContains(message, lBuffer, false) != -1)
		{
			return Plugin_Stop;
		}
	}
	CloseHandle(rFile);
	return Plugin_Changed;
}

stock bool IsValidClient(int client)
{
	if(client <= 0 ) return false;
	if(client > MaxClients) return false;
	if(!IsClientConnected(client)) return false;
	return IsClientInGame(client);
}