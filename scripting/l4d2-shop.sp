#pragma semicolon 1
#pragma newdecls required
#include <sourcemod>
#include <sdktools>
#include <sdkhooks>

public Plugin myinfo = 
{
	name = "Shop", 
	author = "Explait, BloodyBlade, Ah_Roon", 
	description = "Allows you to buy items on the shop", 
	version = "1.5.0", 
	url = "https://ahroonsparadise.github.io/"
}

int g_iCredits[MAXPLAYERS + 1], 
	cooldownTimes[MAXPLAYERS + 1] = {-1, ...}, 
	ZombieKilled = 1, 
	InfectedKilled = 3,
	WitchKilled = 5,
	TankKilled = 10;

public void OnPluginStart()
{
	RegConsoleCmd("sm_shop", HinT);
	RegConsoleCmd("sm_pay", Pay);
	HookEvent("witch_killed", witch_killed);
	HookEvent("infected_death", infected_death);
	HookEvent("player_death", player_death);
	RegAdminCmd("sm_givemoney", GiveMoney, ADMFLAG_SLAY);
	HookEvent("tank_killed", tank_killed);
}

public void OnClientPutInServer(int client)
{
    cooldownTimes[client] = -1;
}

public Action HinT(int client, int args)
{
        // Timer
    int currentTime = GetTime();
    if (cooldownTimes[client] != -1 && cooldownTimes[client] > currentTime)
    {
        ReplyToCommand(client, "[Shop] Please wait few more seconds before using Shop again");
        return Plugin_Handled;
    }
    
    cooldownTimes[client] = currentTime + 5;
    //End Timer

    Menu menu = new Menu(MeleeMenuHandler);
    menu.SetTitle("Your money: %d", g_iCredits[client]);

    menu.AddItem("option1", "Weapons");
    menu.AddItem("option2", "Melee Weapons");
    menu.AddItem("option3", "Misc Items");
    menu.Display(client, MENU_TIME_FOREVER);
    menu.ExitButton = true;

    return Plugin_Handled;
}

public Action GiveMoney(int client, int args)
{
	char arg1[32], arg2[32];
	GetCmdArg(1, arg1, sizeof(arg1));
	GetCmdArg(2, arg2, sizeof(arg2));
	int target = FindTarget(client, arg1), money = 0;
	money = StringToInt(arg2);

	if (args != 2)
	{
		PrintToChat(client, "[Shop] Usage: !givemoney <player> <money>");
	}

	g_iCredits[target] += money;
	char name[MAX_NAME_LENGTH];
	GetClientName(target, name, sizeof(name));
	PrintToChat(client, "[Shop] You gave %i to %s", money, name);
}

public void witch_killed(Event event, const char[] name, bool dontBroadcast)
{
	int client = GetClientOfUserId(event.GetInt("userid"));
	char sname[32];
	GetClientName(client, sname, 32);
	g_iCredits[client] += WitchKilled;
}

public void player_death(Event event, const char[] name, bool dontBroadcast)
{
	int attacker = GetClientOfUserId(event.GetInt("attacker"));
	g_iCredits[attacker] += InfectedKilled;
}

public void infected_death(Event event, const char[] name, bool dontBroadcast)
{
	int attacker = GetClientOfUserId(event.GetInt("attacker"));
	g_iCredits[attacker] += ZombieKilled;
}

public void tank_killed(Event event, const char[] name, bool dontBroadcast)
{
	int client = GetClientOfUserId(event.GetInt("userid"));
	char nname[32];
	GetClientName(client, nname, 32);
	g_iCredits[client] += TankKilled;
}

public int MeleeMenuHandler(Menu menu, MenuAction action, int param1, int param2)
{
	switch (action)
	{
		case MenuAction_Select:
		{
			char item[64];
			menu.GetItem(param2, item, sizeof(item));

			if (StrEqual(item, "option1"))
			{
				Menu wmenu = new Menu(Weapon_Menu_Handle, MenuAction_Select | MenuAction_Cancel | MenuAction_End);
				wmenu.SetTitle("Weapons (Your money: %i)", g_iCredits[param1]);

				wmenu.AddItem( "option1", "Pistol (50$)");
                wmenu.AddItem( "option2", "Magnum Pistol (150$)");
                wmenu.AddItem( "option3", "Pump Shotgun (250$)");
                wmenu.AddItem( "option4", "Chrome Shotgun (250$)");
				wmenu.AddItem( "option5", "Auto Shotgun (400$)");
                wmenu.AddItem( "option6", "Combat Shotgun (400$)");
				wmenu.AddItem( "option7", "Submachine Gun (220$)");
				wmenu.AddItem( "option8", "Silenced SMG (270$)");
                wmenu.AddItem( "option9", "MP5 (250$)");
				wmenu.AddItem( "option10", "M16 Assault Rifle(400$)");
                wmenu.AddItem( "option11", "AK-47 (460$)");
                wmenu.AddItem( "option12", "SCAR-L Combat Rifle (320$)");
				wmenu.AddItem( "option13", "SG552 (420$)");
				wmenu.AddItem( "option14", "Hunting Rifle (300$)");
                wmenu.AddItem( "option15", "Sniper Rifle (400$)");
				wmenu.AddItem( "option16", "Scout (350$)");
                wmenu.AddItem( "option17", "AWP (400$)");
				wmenu.AddItem( "option18", "Grenade Launcher (750$)");
                wmenu.AddItem( "option19", "M60 Machine Gun (1000$)");
				wmenu.ExitButton = true;

				wmenu.Display(param1, MENU_TIME_FOREVER);
			}
			if (StrEqual(item, "option2"))
			{
			    Menu mmenu = new Menu(Melee_Menu_Handle, MenuAction_Select | MenuAction_Cancel | MenuAction_End);
			    mmenu.SetTitle("Melee Weapons (Your money: %i)", g_iCredits[param1]);
			    mmenu.AddItem("option1", "Fire Axe (400$)");
			    mmenu.AddItem("option2", "Frying Pan (250$)");
			    mmenu.AddItem("option3", "Crowbar (120$)");
			    mmenu.AddItem("option4", "Chainsaw (400$)");
			    mmenu.AddItem("option5", "Cricket Bat (200$)");
			    mmenu.AddItem("option6", "Baseball Bat (200$)");
			    mmenu.AddItem("option7", "Electric Guitar (250$)");
                mmenu.AddItem("option8", "Nightstick (200$)");
                mmenu.AddItem("option9", "Katana (300$)");
                mmenu.AddItem("option10", "Machete (250$)");
                mmenu.AddItem("option11", "Golf Club (300$)");
                mmenu.AddItem("option12", "Combat Knife (150$)");
                mmenu.AddItem("option13", "Pitchfork (150$)");
                mmenu.AddItem("option14", "Shovel (150$)");
			    mmenu.ExitButton = true;

			    mmenu.Display(param1, MENU_TIME_FOREVER);
			}
			if (StrEqual(item, "option3"))
			{
				Menu omenu = new Menu(Other_Menu_Handle, MenuAction_Select | MenuAction_Cancel | MenuAction_End);
				omenu.SetTitle("Misc Items (Your money: %i)", g_iCredits[param1]);
				omenu.AddItem("option1", "First Aid Kit (100$)");
                omenu.AddItem("option2", "Defibrillator (500$)");
				omenu.AddItem("option3", "Pain Pills (50$)");
				omenu.AddItem("option4", "Adrenaline Shot (50$)");
				omenu.AddItem("option5", "Pipebomb (100$)");
				omenu.AddItem("option6", "Molotov (120$)");
                omenu.AddItem("option7", "Boomer Bile (80$)");
                omenu.AddItem("option8", "Incendiary Ammo (300$)");
                omenu.AddItem("option9", "Explosive Ammo (300$)");
                omenu.AddItem("option10", "Refill Ammo (200$)");
				omenu.ExitButton = true;

				omenu.Display(param1, MENU_TIME_FOREVER);
			}
		}
	}
}

public Action Pay(int client, int args)
{
	char arg1[32], arg2[32];
	GetCmdArg(1, arg1, sizeof(arg1));
	GetCmdArg(2, arg2, sizeof(arg2));
	int paymoney = 0;
	paymoney = StringToInt(arg2);
	int target = FindTarget(client, arg1);
	if (target == -1) return Plugin_Handled;
	if (args != 2) ReplyToCommand(client, "[Shop] Usage: !pay <name> <money>");

	g_iCredits[target] += paymoney;
	g_iCredits[client] -= paymoney;
	PrintToChat(target, "[Shop] %s gave you %i", client, paymoney);
	PrintToChat(client, "[Shop] You gave %i to player", paymoney);
	return Plugin_Handled;
}

public int Weapon_Menu_Handle(Menu wmenu, MenuAction action, int client, int Position)
{
	int flagszspawn = GetCommandFlags("give");
	SetCommandFlags("give", flagszspawn & ~FCVAR_CHEAT);

	if (action == MenuAction_Select)
	{
		char Item[32];
		wmenu.GetItem(Position, Item, sizeof(Item));
		wmenu.DisplayAt(client, GetMenuSelectionPosition(), MENU_TIME_FOREVER);
		if (StrEqual(Item, "option1"))
		{
			if (g_iCredits[client] >= 50)
			{
				FakeClientCommand(client, "give pistol");
				g_iCredits[client] -= 50;
			}
			else
			{
				PrintToChat(client, "[Shop] You don't have enough money! You need 50 but you only have %i", g_iCredits[client]);
			}
		}
        if (StrEqual(Item, "option2"))
		{
			if (g_iCredits[client] >= 150)
			{
				FakeClientCommand(client, "give pistol_magnum");
				g_iCredits[client] -= 150;
			}
			else
			{
				PrintToChat(client, "[Shop] You don't have enough money! You need 150 but you only have %i", g_iCredits[client]);
			}
		}
        if (StrEqual(Item, "option3"))
		{
			if (g_iCredits[client] >= 250)
			{
				FakeClientCommand(client, "give pumpshotgun");
				g_iCredits[client] -= 250;
			}
			else
			{
				PrintToChat(client, "[Shop] You don't have enough money! You need 250 but you only have %i", g_iCredits[client]);
			}
		}
        if (StrEqual(Item, "option4"))
		{
			if (g_iCredits[client] >= 250)
			{
				FakeClientCommand(client, "give shotgun_chrome");
				g_iCredits[client] -= 250;
			}
			else
			{
				PrintToChat(client, "[Shop] You don't have enough money! You need 250 but you only have %i", g_iCredits[client]);
			}
		}
        if (StrEqual(Item, "option5"))
		{
			if (g_iCredits[client] >= 400)
			{
				FakeClientCommand(client, "give autoshotgun");
				g_iCredits[client] -= 400;
			}
			else
			{
				PrintToChat(client, "[Shop] You don't have enough money! You need 400 but you only have %i", g_iCredits[client]);
			}
		}
        if (StrEqual(Item, "option6"))
		{
			if (g_iCredits[client] >= 400)
			{
				FakeClientCommand(client, "give shotgun_spas");
				g_iCredits[client] -= 400;
			}
			else
			{
				PrintToChat(client, "[Shop] You don't have enough money! You need 400 but you only have %i", g_iCredits[client]);
			}
		}
        if (StrEqual(Item, "option7"))
		{
			if (g_iCredits[client] >= 220)
			{
				FakeClientCommand(client, "give smg");
				g_iCredits[client] -= 220;
			}
			else
			{
				PrintToChat(client, "[Shop] You don't have enough money! You need 220 but you only have %i", g_iCredits[client]);
			}
		}
        if (StrEqual(Item, "option8"))
		{
			if (g_iCredits[client] >= 270)
			{
				FakeClientCommand(client, "give smg_silenced");
				g_iCredits[client] -= 270;
			}
			else
			{
				PrintToChat(client, "[Shop] You don't have enough money! You need 270 but you only have %i", g_iCredits[client]);
			}
		}
        if (StrEqual(Item, "option9"))
		{
			if (g_iCredits[client] >= 250)
			{
				FakeClientCommand(client, "give smg_mp5");
				g_iCredits[client] -= 250;
			}
			else
			{
				PrintToChat(client, "[Shop] You don't have enough money! You need 250 but you only have %i", g_iCredits[client]);
			}
		}
        if (StrEqual(Item, "option10"))
		{
			if (g_iCredits[client] >= 400)
			{
				FakeClientCommand(client, "give rifle");
				g_iCredits[client] -= 400;
			}
			else
			{
				PrintToChat(client, "[Shop] You don't have enough money! You need 400 but you only have %i", g_iCredits[client]);
			}
		}
        if (StrEqual(Item, "option11"))
		{
			if (g_iCredits[client] >= 460)
			{
				FakeClientCommand(client, "give rifle_ak47");
				g_iCredits[client] -= 460;
			}
			else
			{
				PrintToChat(client, "[Shop] You don't have enough money! You need 460 but you only have %i", g_iCredits[client]);
			}
		}
        if (StrEqual(Item, "option12"))
		{
			if (g_iCredits[client] >= 320)
			{
				FakeClientCommand(client, "give rifle_desert");
				g_iCredits[client] -= 320;
			}
			else
			{
				PrintToChat(client, "[Shop] You don't have enough money! You need 320 but you only have %i", g_iCredits[client]);
			}
		}
        if (StrEqual(Item, "option13"))
		{
			if (g_iCredits[client] >= 420)
			{
				FakeClientCommand(client, "give rifle_sg552");
				g_iCredits[client] -= 420;
			}
			else
			{
				PrintToChat(client, "[Shop] You don't have enough money! You need 420 but you only have %i", g_iCredits[client]);
			}
		}
        if (StrEqual(Item, "option14"))
		{
			if (g_iCredits[client] >= 300)
			{
				FakeClientCommand(client, "give hunting_rifle");
				g_iCredits[client] -= 300;
			}
			else
			{
				PrintToChat(client, "[Shop] You don't have enough money! You need 300 but you only have %i", g_iCredits[client]);
			}
		}
        if (StrEqual(Item, "option15"))
		{
			if (g_iCredits[client] >= 400)
			{
				FakeClientCommand(client, "give sniper_military");
				g_iCredits[client] -= 400;
			}
			else
			{
				PrintToChat(client, "[Shop] You don't have enough money! You need 400 but you only have %i", g_iCredits[client]);
			}
		}
        if (StrEqual(Item, "option16"))
		{
			if (g_iCredits[client] >= 350)
			{
				FakeClientCommand(client, "give sniper_scout");
				g_iCredits[client] -= 350;
			}
			else
			{
				PrintToChat(client, "[Shop] You don't have enough money! You need 350 but you only have %i", g_iCredits[client]);
			}
		}
        if (StrEqual(Item, "option17"))
		{
			if (g_iCredits[client] >= 400)
			{
				FakeClientCommand(client, "give sniper_awp");
				g_iCredits[client] -= 400;
			}
			else
			{
				PrintToChat(client, "[Shop] You don't have enough money! You need 400 but you only have %i", g_iCredits[client]);
			}
		}
        if (StrEqual(Item, "option18"))
		{
			if (g_iCredits[client] >= 750)
			{
				FakeClientCommand(client, "give weapon_grenade_launcher");
				g_iCredits[client] -= 750;
			}
			else
			{
				PrintToChat(client, "[Shop] You don't have enough money! You need 750 but you only have %i", g_iCredits[client]);
			}
		}
        if (StrEqual(Item, "option19"))
		{
			if (g_iCredits[client] >= 1000)
			{
				FakeClientCommand(client, "give rifle_m60");
				g_iCredits[client] -= 1000;
			}
			else
			{
				PrintToChat(client, "[Shop] You don't have enough money! You need 1000 but you only have %i", g_iCredits[client]);
			}
		}
	}
	SetCommandFlags("give", flagszspawn | FCVAR_CHEAT);
}

public int Melee_Menu_Handle(Menu mmenu, MenuAction action, int client, int Position)
{
	int flagszspawn = GetCommandFlags("give");
	SetCommandFlags("give", flagszspawn & ~FCVAR_CHEAT);

	if (action == MenuAction_Select)
	{
		char Item[32];
		mmenu.GetItem(Position, Item, sizeof(Item));
		mmenu.DisplayAt(client, GetMenuSelectionPosition(), MENU_TIME_FOREVER);
		if (StrEqual(Item, "option1"))
		{
			if (g_iCredits[client] >= 400)
			{
				FakeClientCommand(client, "give fireaxe");
				g_iCredits[client] -= 400;
			}
			else
			{
				PrintToChat(client, "[Shop] You don't have enough money! You need 400 but you only have %i", g_iCredits[client]);
			}
		}
		if (StrEqual(Item, "option2"))
		{
			if (g_iCredits[client] >= 250)
			{
				FakeClientCommand(client, "give frying_pan");
				g_iCredits[client] -= 250;
			}
			else
			{
				PrintToChat(client, "[Shop] You don't have enough money! You need 250 but you only have %i", g_iCredits[client]);
			}
		}
		if (StrEqual(Item, "option3"))
		{
			if (g_iCredits[client] >= 120)
			{
				FakeClientCommand(client, "give crowbar");
				g_iCredits[client] -= 120;
			}
			else
			{
				PrintToChat(client, "[Shop] You don't have enough money! You need 120 but you only have %i", g_iCredits[client]);
			}
		}
        if (StrEqual(Item, "option4"))
		{
			if (g_iCredits[client] >= 400)
			{
				FakeClientCommand(client, "give chainsaw");
				g_iCredits[client] -= 400;
			}
			else
			{
				PrintToChat(client, "[Shop] You don't have enough money! You need 400 but you only have %i", g_iCredits[client]);
			}
		}
        if (StrEqual(Item, "option5"))
		{
			if (g_iCredits[client] >= 200)
			{
				FakeClientCommand(client, "give cricket_bat");
				g_iCredits[client] -= 200;
			}
			else
			{
				PrintToChat(client, "[Shop] You don't have enough money! You need 200 but you only have %i", g_iCredits[client]);
			}
		}
        if (StrEqual(Item, "option6"))
		{
			if (g_iCredits[client] >= 200)
			{
				FakeClientCommand(client, "give baseball_bat");
				g_iCredits[client] -= 200;
			}
			else
			{
				PrintToChat(client, "[Shop] You don't have enough money! You need 200 but you only have %i", g_iCredits[client]);
			}
		}
        if (StrEqual(Item, "option7"))
		{
			if (g_iCredits[client] >= 250)
			{
				FakeClientCommand(client, "give electric_guitar");
				g_iCredits[client] -= 250;
			}
			else
			{
				PrintToChat(client, "[Shop] You don't have enough money! You need 250 but you only have %i", g_iCredits[client]);
			}
		}
        if (StrEqual(Item, "option8"))
		{
			if (g_iCredits[client] >= 200)
			{
				FakeClientCommand(client, "give tonfa");
				g_iCredits[client] -= 200;
			}
			else
			{
				PrintToChat(client, "[Shop] You don't have enough money! You need 200 but you only have %i", g_iCredits[client]);
			}
		}
        if (StrEqual(Item, "option9"))
		{
			if (g_iCredits[client] >= 300)
			{
				FakeClientCommand(client, "give katana");
				g_iCredits[client] -= 300;
			}
			else
			{
				PrintToChat(client, "[Shop] You don't have enough money! You need 300 but you only have %i", g_iCredits[client]);
			}
		}
        if (StrEqual(Item, "option10"))
		{
			if (g_iCredits[client] >= 250)
			{
				FakeClientCommand(client, "give machete");
				g_iCredits[client] -= 250;
			}
			else
			{
				PrintToChat(client, "[Shop] You don't have enough money! You need 250 but you only have %i", g_iCredits[client]);
			}
		}
        if (StrEqual(Item, "option11"))
		{
			if (g_iCredits[client] >= 300)
			{
				FakeClientCommand(client, "give golfclub");
				g_iCredits[client] -= 300;
			}
			else
			{
				PrintToChat(client, "[Shop] You don't have enough money! You need 300 but you only have %i", g_iCredits[client]);
			}
		}
        if (StrEqual(Item, "option12"))
		{
			if (g_iCredits[client] >= 150)
			{
				FakeClientCommand(client, "give knife");
				g_iCredits[client] -= 150;
			}
			else
			{
				PrintToChat(client, "[Shop] You don't have enough money! You need 150 but you only have %i", g_iCredits[client]);
			}
		}
        if (StrEqual(Item, "option13"))
		{
			if (g_iCredits[client] >= 150)
			{
				FakeClientCommand(client, "give pitchfork");
				g_iCredits[client] -= 150;
			}
			else
			{
				PrintToChat(client, "[Shop] You don't have enough money! You need 150 but you only have %i", g_iCredits[client]);
			}
		}
        if (StrEqual(Item, "option14"))
		{
			if (g_iCredits[client] >= 150)
			{
				FakeClientCommand(client, "give shovel");
				g_iCredits[client] -= 150;
			}
			else
			{
				PrintToChat(client, "[Shop] You don't have enough money! You need 150 but you only have %i", g_iCredits[client]);
			}
		}
	}
	SetCommandFlags("give", flagszspawn | FCVAR_CHEAT);
}

public int Other_Menu_Handle(Menu omenu, MenuAction action, int client, int Position)
{
	int flagszspawn = GetCommandFlags("give");
	SetCommandFlags("give", flagszspawn & ~FCVAR_CHEAT);

	if (action == MenuAction_Select)
	{
		char Item[32];
		omenu.GetItem(Position, Item, sizeof(Item));
		omenu.DisplayAt(client, GetMenuSelectionPosition(), MENU_TIME_FOREVER);
		if (StrEqual(Item, "option1"))
		{
			if (g_iCredits[client] >= 100)
			{
				FakeClientCommand(client, "give first_aid_kit");
				g_iCredits[client] -= 100;
			}
			else
			{
				PrintToChat(client, "[Shop] You don't have enough money! You need 100 but you only have %i", g_iCredits[client]);
			}
		}
        if (StrEqual(Item, "option2"))
		{
			if (g_iCredits[client] >= 500)
			{
				FakeClientCommand(client, "give defibrillator");
				g_iCredits[client] -= 500;
			}
			else
			{
				PrintToChat(client, "[Shop] You don't have enough money! You need 500 but you only have %i", g_iCredits[client]);
			}
		}
		if (StrEqual(Item, "option3"))
		{
			if (g_iCredits[client] >= 50)
			{
				FakeClientCommand(client, "give pain_pills");
				g_iCredits[client] -= 50;
			}
			else
			{
				PrintToChat(client, "[Shop] You don't have enough money! You need 50 but you only have %i", g_iCredits[client]);
			}
		}
        if (StrEqual(Item, "option4"))
		{
			if (g_iCredits[client] >= 50)
			{
				FakeClientCommand(client, "give adrenaline");
				g_iCredits[client] -= 50;
			}
			else
			{
				PrintToChat(client, "[Shop] You don't have enough money! You need 50 but you only have %i", g_iCredits[client]);
			}
		}
		if (StrEqual(Item, "option5"))
		{
			if (g_iCredits[client] >= 100)
			{
				FakeClientCommand(client, "give pipe_bomb");
				g_iCredits[client] -= 100;
			}
			else
			{
				PrintToChat(client, "[Shop] You don't have enough money! You need 100 but you only have %i", g_iCredits[client]);
			}
		}
		if (StrEqual(Item, "option6"))
		{
			if (g_iCredits[client] >= 120)
			{
				FakeClientCommand(client, "give molotov");
				g_iCredits[client] -= 120;
			}
			else
			{
				PrintToChat(client, "[Shop] You don't have enough money! You need 120 but you only have %i", g_iCredits[client]);
			}
		}
		if (StrEqual(Item, "option7"))
		{
			if (g_iCredits[client] >= 80)
			{
				FakeClientCommand(client, "give vomitjar");
				g_iCredits[client] -= 80;
			}
			else
			{
				PrintToChat(client, "[Shop] You don't have enough money! You need 80 but you only have %i", g_iCredits[client]);
			}
		}
        if (StrEqual(Item, "option8"))
		{
			if (g_iCredits[client] >= 300)
			{
				FakeClientCommand(client, "give upgradepack_incendiary");
				g_iCredits[client] -= 300;
			}
			else
			{
				PrintToChat(client, "[Shop] You don't have enough money! You need 300 but you only have %i", g_iCredits[client]);
			}
		}
		if (StrEqual(Item, "option9"))
		{
			if (g_iCredits[client] >= 300)
			{
				FakeClientCommand(client, "give upgradepack_explosive");
				g_iCredits[client] -= 300;
			}
			else
			{
				PrintToChat(client, "[Shop] You don't have enough money! You need 300 but you only have %i", g_iCredits[client]);
			}
		}
        if (StrEqual(Item, "option10"))
		{
			if (g_iCredits[client] >= 200)
			{
				FakeClientCommand(client, "give ammo");
				g_iCredits[client] -= 200;
			}
			else
			{
				PrintToChat(client, "[Shop] You don't have enough money! You need 200 but you only have %i", g_iCredits[client]);
			}
		}
	}
	SetCommandFlags("give", flagszspawn | FCVAR_CHEAT);
}