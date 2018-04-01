#pragma semicolon 1

#define DEBUG

#define PLUGIN_AUTHOR "xFlane"
#define PLUGIN_VERSION "1.00"

#define PREFIX "[SM]"

#include <sourcemod>
#include <sdktools>
#include <cstrike>
//#include <sdkhooks>

#pragma newdecls required

public Plugin myinfo = 
{
	name = "[SM] Set hp and gravity",
	author = PLUGIN_AUTHOR,
	description = "",
	version = PLUGIN_VERSION,
	url = ""
};

public void OnPluginStart()
{
	LoadTranslations("common.phrases");
	
	/* Commands */
	RegAdminCmd("sm_sethp", Command_SetHP, ADMFLAG_KICK);
	RegAdminCmd("sm_setgravity", Command_SetGravity, ADMFLAG_KICK);
}

/* Commands */

public Action Command_SetHP(int client, int args)
{
	if(args < 2)
	{
		PrintToChat(client, "%s Syntax error: sm_sethp <client> <amount>", PREFIX);
		return Plugin_Handled;
	}
	
	char Arg1[MAX_NAME_LENGTH];
	GetCmdArg(1, Arg1, MAX_NAME_LENGTH);
	
	int target = FindTarget(client, Arg1, .immunity = false);
	
	if(target == -1)
	{
		return Plugin_Handled;
	}
	
	char Arg2[16];
	GetCmdArg(2, Arg2, 16);
	
	int amount = StringToInt(Arg2);
	SetEntityHealth(target, amount);
	
	PrintToChat(client, "%s ADMIN: %N has changed %N health to %i.", PREFIX, client, target, amount);
	
	return Plugin_Handled;
}

public Action Command_SetGravity(int client, int args)
{
	if(args < 2)
	{
		PrintToChat(client, "%s Syntax error: sm_setgravity <client> <amount>", PREFIX);
		return Plugin_Handled;
	}
	
	char Arg1[MAX_NAME_LENGTH];
	GetCmdArg(1, Arg1, MAX_NAME_LENGTH);
	
	int target = FindTarget(client, Arg1, .immunity = false);
	
	if(target == -1)
	{
		return Plugin_Handled;
	}
	
	char Arg2[16];
	GetCmdArg(2, Arg2, 16);
	
	float amount = StringToFloat(Arg2);
	SetEntityGravity(target, amount);
	
	PrintToChat(client, "%s ADMIN: %N has changed %N gravity to %.2f.", PREFIX, client, target, amount);
	
	return Plugin_Handled;
}