#pragma semicolon 1

#define DEBUG

#define PLUGIN_AUTHOR "xFlane"
#define PLUGIN_VERSION "1.00"

#include <sourcemod>
#include <sdktools>
#include <SteamWorks>
#include <webfix>

bool FirstTeamChoose[MAXPLAYERS + 1];

ConVar ConVarSteamGroupID;
ConVar ConVarSteamGroupURL;

int GroupID = 0;

#pragma newdecls required

public Plugin myinfo = 
{
	name = "[SM] Asks to join steam group", 
	author = PLUGIN_AUTHOR, 
	description = "asks player to join the steam group", 
	version = PLUGIN_VERSION, 
	url = "https://steamcommunity.com/id/xflane"
};

public void OnPluginStart()
{
	HookEvent("player_team", EventPlayerTeam);
	
	ConVarSteamGroupID = CreateConVar("sm_asksteam_group_id", "XXXXXX", "Steam group id");
	ConVarSteamGroupURL = CreateConVar("sm_asksteam_group_url", "http://steamcommunity.com/groups/XXXXXX", "Steam group url");
	
	AutoExecConfig(.name = "SteamGroup");
}

public void OnConfigsExecuted()
{
	char ID[16];
	ConVarSteamGroupID.GetString(ID, 16);
	GroupID = StringToInt(ID);
}

public void OnClientDisconnect(int client)
{
	FirstTeamChoose[client] = false;
}

public Action EventPlayerTeam(Handle event, const char[] name, bool dontBroadcast)
{
	int client = GetClientOfUserId(GetEventInt(event, "userid"));
	int team = GetEventInt(event, "team");
	
	if(team <= 1)
		return Plugin_Continue;
		
	if (!FirstTeamChoose[client])
	{
		FirstTeamChoose[client] = true;
		SteamWorks_GetUserGroupStatus(client, GroupID);
	}
	
	return Plugin_Continue;
}


public int SteamWorks_OnClientGroupStatus(int authid, int groupid, bool isMember, bool isOfficer)
{
	if (!isMember)
	{
		int client = GetUserAuthID(authid);
		
		Menu JoinGroup = new Menu(MenuHandler_MenuJoinGroup);
		JoinGroup.SetTitle("Do you want to join our steam group?");
		
		JoinGroup.AddItem("0", "Yes");
		JoinGroup.AddItem("0", "No");
		
		JoinGroup.Display(client, MENU_TIME_FOREVER);
	}
	return 0;
}

public int MenuHandler_MenuJoinGroup(Menu menu, MenuAction action, int client, int key)
{
	if (action == MenuAction_Select)
	{
		if (key == 0)
		{
			char URL[256];
			ConVarSteamGroupURL.GetString(URL, 256);
			
			WebFix_OpenUrl(client, "Join Steam Group", URL, false);
		}
	}
	else if (action == MenuAction_End)
	{
		delete menu;
	}
} 

int GetUserAuthID(int authid)
{
	char[] authchar = new char[64];
	IntToString(authid, authchar, 64);
	for (int i = 1; i <= MaxClients; i++)
	{
		if (!IsClientInGame(i)) return -1;
		
		char[] charauth = new char[64];
		GetClientAuthId(i, AuthId_Steam3, charauth, 64);
		if (StrContains(charauth, authchar) != -1) return i;
	}

	return -1;
}
