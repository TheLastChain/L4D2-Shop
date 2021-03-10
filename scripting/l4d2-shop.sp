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
	version = "1.6.0", 
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
	RegConsoleCmd("sm_buy", HinT);
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
    menu.SetTitle("Shop - Your money: %d", g_iCredits[client]);

    menu.AddItem("option1", "Melee");
	menu.AddItem("option2", "Pistols");
	menu.AddItem("option3", "Shotguns");
	menu.AddItem("option4", "Submachine Guns");
	menu.AddItem("option5", "Rifles");
	menu.AddItem("option6", "Sniper Rifles");
    menu.AddItem("option7", "Special Weapons");
	menu.AddItem("option8", "Grenades");
	menu.AddItem("option9", "Healing Items");
    menu.AddItem("option10", "Misc/Upgrades");
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
				Menu mmenu = new Menu(Melee_Menu_Handle, MenuAction_Select | MenuAction_Cancel | MenuAction_End);
				mmenu.SetTitle("Shop - Melee (Your money: %i)", g_iCredits[param1]);

			    mmenu.AddItem("option1", "Fire Axe (800$)");
			    mmenu.AddItem("option2", "Frying Pan (500$)");
			    mmenu.AddItem("option3", "Crowbar (200$)");
			    mmenu.AddItem("option4", "Chainsaw (800$)");
			    mmenu.AddItem("option5", "Cricket Bat (400$)");
			    mmenu.AddItem("option6", "Baseball Bat (400$)");
			    mmenu.AddItem("option7", "Electric Guitar (500$)");
                mmenu.AddItem("option8", "Nightstick (400$)");
                mmenu.AddItem("option9", "Katana (600$)");
                mmenu.AddItem("option10", "Machete (500$)");
                mmenu.AddItem("option11", "Golf Club (600$)");
                mmenu.AddItem("option12", "Combat Knife (300$)");
                mmenu.AddItem("option13", "Pitchfork (300$)");
                mmenu.AddItem("option14", "Shovel (300$)");
				mmenu.ExitButton = true;

				mmenu.Display(param1, MENU_TIME_FOREVER);
			}

			if (StrEqual(item, "option2"))
			{
				Menu pmenu = new Menu(Pistol_Menu_Handle, MenuAction_Select | MenuAction_Cancel | MenuAction_End);
				pmenu.SetTitle("Shop - Pistols (Your money: %i)", g_iCredits[param1]);

			    pmenu.AddItem( "option1", "Pistol (200$)");
                pmenu.AddItem( "option2", "Magnum Pistol (600$)");
				pmenu.ExitButton = true;

				pmenu.Display(param1, MENU_TIME_FOREVER);
			}

			if (StrEqual(item, "option3"))
			{
				Menu smenu = new Menu(Shotgun_Menu_Handle, MenuAction_Select | MenuAction_Cancel | MenuAction_End);
				smenu.SetTitle("Shop - Shotguns (Your money: %i)", g_iCredits[param1]);

			    smenu.AddItem( "option1", "Pump Shotgun (500$)");
                smenu.AddItem( "option2", "Chrome Shotgun (500$)");
				smenu.AddItem( "option3", "Auto Shotgun (800$)");
                smenu.AddItem( "option4", "Combat Shotgun (800$)");
				smenu.ExitButton = true;

				smenu.Display(param1, MENU_TIME_FOREVER);
			}

			if (StrEqual(item, "option4"))
			{
				Menu gmenu = new Menu(SMG_Menu_Handle, MenuAction_Select | MenuAction_Cancel | MenuAction_End);
				gmenu.SetTitle("Shop - Submachine Guns (Your money: %i)", g_iCredits[param1]);

			    gmenu.AddItem( "option1", "Submachine Gun (400$)");
				gmenu.AddItem( "option2", "Silenced SMG (600$)");
                gmenu.AddItem( "option3", "MP5 (500$)");
				gmenu.ExitButton = true;

				gmenu.Display(param1, MENU_TIME_FOREVER);
			}

			if (StrEqual(item, "option5"))
			{
				Menu rmenu = new Menu(Rifle_Menu_Handle, MenuAction_Select | MenuAction_Cancel | MenuAction_End);
				rmenu.SetTitle("Shop - Rifles (Your money: %i)", g_iCredits[param1]);

			    rmenu.AddItem( "option1", "M16 Assault Rifle(750$)");
                rmenu.AddItem( "option2", "AK-47 (900$)");
                rmenu.AddItem( "option3", "Combat Rifle (700$)");
				rmenu.AddItem( "option4", "SG552 (850$)");
				rmenu.ExitButton = true;

				rmenu.Display(param1, MENU_TIME_FOREVER);
			}

			if (StrEqual(item, "option6"))
			{
				Menu emenu = new Menu(SRifle_Menu_Handle, MenuAction_Select | MenuAction_Cancel | MenuAction_End);
				emenu.SetTitle("Shop - Sniper Rifles (Your money: %i)", g_iCredits[param1]);

			    emenu.AddItem( "option1", "Hunting Rifle (600$)");
                emenu.AddItem( "option2", "Sniper Rifle (900$)");
				emenu.AddItem( "option3", "Scout (700$)");
                emenu.AddItem( "option4", "AWP (750$)");
				emenu.ExitButton = true;

				emenu.Display(param1, MENU_TIME_FOREVER);
			}

			if (StrEqual(item, "option7"))
			{
				Menu cmenu = new Menu(Special_Menu_Handle, MenuAction_Select | MenuAction_Cancel | MenuAction_End);
				cmenu.SetTitle("Shop - Special Weapons (Your money: %i)", g_iCredits[param1]);

			    cmenu.AddItem( "option1", "Grenade Launcher (1500$)");
                cmenu.AddItem( "option2", "M60 Machine Gun (2000$)");
				cmenu.ExitButton = true;

				cmenu.Display(param1, MENU_TIME_FOREVER);
			}

			if (StrEqual(item, "option8"))
			{
				Menu nmenu = new Menu(Grenade_Menu_Handle, MenuAction_Select | MenuAction_Cancel | MenuAction_End);
				nmenu.SetTitle("Shop - Grenades (Your money: %i)", g_iCredits[param1]);

			    nmenu.AddItem("option1", "Pipebomb (200$)");
				nmenu.AddItem("option2", "Molotov (400$)");
                nmenu.AddItem("option3", "Boomer Bile (100$)");
				nmenu.ExitButton = true;

				nmenu.Display(param1, MENU_TIME_FOREVER);
			}

			if (StrEqual(item, "option9"))
			{
				Menu lmenu = new Menu(Heal_Menu_Handle, MenuAction_Select | MenuAction_Cancel | MenuAction_End);
				lmenu.SetTitle("Shop - Healing Items (Your money: %i)", g_iCredits[param1]);

			    lmenu.AddItem("option1", "First Aid Kit (400$)");
                lmenu.AddItem("option2", "Defibrillator (1200$)");
				lmenu.AddItem("option3", "Pain Pills (200$)");
				lmenu.AddItem("option4", "Adrenaline Shot (200$)");
				lmenu.ExitButton = true;

				lmenu.Display(param1, MENU_TIME_FOREVER);
			}

			if (StrEqual(item, "option10"))
			{
				Menu imenu = new Menu(Misc_Menu_Handle, MenuAction_Select | MenuAction_Cancel | MenuAction_End);
				imenu.SetTitle("Shop - Misc/Upgrades (Your money: %i)", g_iCredits[param1]);

			    imenu.AddItem("option1", "Refill Ammo (400$)");
                imenu.AddItem("option2", "Incendiary Ammo (800$)");
                imenu.AddItem("option3", "Explosive Ammo (800$)");
				imenu.ExitButton = true;

				imenu.Display(param1, MENU_TIME_FOREVER);
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
			if (g_iCredits[client] >= 800)
			{
				FakeClientCommand(client, "give fireaxe");
				g_iCredits[client] -= 800;
			}
			else
			{
				PrintToChat(client, "[Shop] You don't have enough money! You need 800 but you only have %i", g_iCredits[client]);
			}
		}
		if (StrEqual(Item, "option2"))
		{
			if (g_iCredits[client] >= 500)
			{
				FakeClientCommand(client, "give frying_pan");
				g_iCredits[client] -= 500;
			}
			else
			{
				PrintToChat(client, "[Shop] You don't have enough money! You need 500 but you only have %i", g_iCredits[client]);
			}
		}
		if (StrEqual(Item, "option3"))
		{
			if (g_iCredits[client] >= 200)
			{
				FakeClientCommand(client, "give crowbar");
				g_iCredits[client] -= 200;
			}
			else
			{
				PrintToChat(client, "[Shop] You don't have enough money! You need 200 but you only have %i", g_iCredits[client]);
			}
		}
        if (StrEqual(Item, "option4"))
		{
			if (g_iCredits[client] >= 800)
			{
				FakeClientCommand(client, "give chainsaw");
				g_iCredits[client] -= 800;
			}
			else
			{
				PrintToChat(client, "[Shop] You don't have enough money! You need 800 but you only have %i", g_iCredits[client]);
			}
		}
        if (StrEqual(Item, "option5"))
		{
			if (g_iCredits[client] >= 400)
			{
				FakeClientCommand(client, "give cricket_bat");
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
				FakeClientCommand(client, "give baseball_bat");
				g_iCredits[client] -= 400;
			}
			else
			{
				PrintToChat(client, "[Shop] You don't have enough money! You need 400 but you only have %i", g_iCredits[client]);
			}
		}
        if (StrEqual(Item, "option7"))
		{
			if (g_iCredits[client] >= 500)
			{
				FakeClientCommand(client, "give electric_guitar");
				g_iCredits[client] -= 500;
			}
			else
			{
				PrintToChat(client, "[Shop] You don't have enough money! You need 500 but you only have %i", g_iCredits[client]);
			}
		}
        if (StrEqual(Item, "option8"))
		{
			if (g_iCredits[client] >= 400)
			{
				FakeClientCommand(client, "give tonfa");
				g_iCredits[client] -= 400;
			}
			else
			{
				PrintToChat(client, "[Shop] You don't have enough money! You need 400 but you only have %i", g_iCredits[client]);
			}
		}
        if (StrEqual(Item, "option9"))
		{
			if (g_iCredits[client] >= 600)
			{
				FakeClientCommand(client, "give katana");
				g_iCredits[client] -= 600;
			}
			else
			{
				PrintToChat(client, "[Shop] You don't have enough money! You need 600 but you only have %i", g_iCredits[client]);
			}
		}
        if (StrEqual(Item, "option10"))
		{
			if (g_iCredits[client] >= 500)
			{
				FakeClientCommand(client, "give machete");
				g_iCredits[client] -= 500;
			}
			else
			{
				PrintToChat(client, "[Shop] You don't have enough money! You need 500 but you only have %i", g_iCredits[client]);
			}
		}
        if (StrEqual(Item, "option11"))
		{
			if (g_iCredits[client] >= 600)
			{
				FakeClientCommand(client, "give golfclub");
				g_iCredits[client] -= 600;
			}
			else
			{
				PrintToChat(client, "[Shop] You don't have enough money! You need 600 but you only have %i", g_iCredits[client]);
			}
		}
        if (StrEqual(Item, "option12"))
		{
			if (g_iCredits[client] >= 300)
			{
				FakeClientCommand(client, "give knife");
				g_iCredits[client] -= 300;
			}
			else
			{
				PrintToChat(client, "[Shop] You don't have enough money! You need 300 but you only have %i", g_iCredits[client]);
			}
		}
        if (StrEqual(Item, "option13"))
		{
			if (g_iCredits[client] >= 300)
			{
				FakeClientCommand(client, "give pitchfork");
				g_iCredits[client] -= 300;
			}
			else
			{
				PrintToChat(client, "[Shop] You don't have enough money! You need 300 but you only have %i", g_iCredits[client]);
			}
		}
        if (StrEqual(Item, "option14"))
		{
			if (g_iCredits[client] >= 300)
			{
				FakeClientCommand(client, "give shovel");
				g_iCredits[client] -= 300;
			}
			else
			{
				PrintToChat(client, "[Shop] You don't have enough money! You need 300 but you only have %i", g_iCredits[client]);
			}
		}
	}
	SetCommandFlags("give", flagszspawn | FCVAR_CHEAT);
}

public int Pistol_Menu_Handle(Menu pmenu, MenuAction action, int client, int Position)
{
	int flagszspawn = GetCommandFlags("give");
	SetCommandFlags("give", flagszspawn & ~FCVAR_CHEAT);

	if (action == MenuAction_Select)
	{
		char Item[32];
		pmenu.GetItem(Position, Item, sizeof(Item));
		pmenu.DisplayAt(client, GetMenuSelectionPosition(), MENU_TIME_FOREVER);

		if (StrEqual(Item, "option1"))
		{
			if (g_iCredits[client] >= 200)
			{
				FakeClientCommand(client, "give pistol");
				g_iCredits[client] -= 200;
			}
			else
			{
				PrintToChat(client, "[Shop] You don't have enough money! You need 200 but you only have %i", g_iCredits[client]);
			}
		}
        if (StrEqual(Item, "option2"))
		{
			if (g_iCredits[client] >= 600)
			{
				FakeClientCommand(client, "give pistol_magnum");
				g_iCredits[client] -= 600;
			}
			else
			{
				PrintToChat(client, "[Shop] You don't have enough money! You need 600 but you only have %i", g_iCredits[client]);
			}
		}
	}
	SetCommandFlags("give", flagszspawn | FCVAR_CHEAT);
}

public int Shotgun_Menu_Handle(Menu smenu, MenuAction action, int client, int Position)
{
	int flagszspawn = GetCommandFlags("give");
	SetCommandFlags("give", flagszspawn & ~FCVAR_CHEAT);

	if (action == MenuAction_Select)
	{
		char Item[32];
		smenu.GetItem(Position, Item, sizeof(Item));
		smenu.DisplayAt(client, GetMenuSelectionPosition(), MENU_TIME_FOREVER);

		if (StrEqual(Item, "option1"))
		{
			if (g_iCredits[client] >= 500)
			{
				FakeClientCommand(client, "give pumpshotgun");
				g_iCredits[client] -= 500;
			}
			else
			{
				PrintToChat(client, "[Shop] You don't have enough money! You need 500 but you only have %i", g_iCredits[client]);
			}
		}
        if (StrEqual(Item, "option2"))
		{
			if (g_iCredits[client] >= 500)
			{
				FakeClientCommand(client, "give shotgun_chrome");
				g_iCredits[client] -= 500;
			}
			else
			{
				PrintToChat(client, "[Shop] You don't have enough money! You need 500 but you only have %i", g_iCredits[client]);
			}
		}
        if (StrEqual(Item, "option3"))
		{
			if (g_iCredits[client] >= 800)
			{
				FakeClientCommand(client, "give autoshotgun");
				g_iCredits[client] -= 800;
			}
			else
			{
				PrintToChat(client, "[Shop] You don't have enough money! You need 800 but you only have %i", g_iCredits[client]);
			}
		}
        if (StrEqual(Item, "option4"))
		{
			if (g_iCredits[client] >= 800)
			{
				FakeClientCommand(client, "give shotgun_spas");
				g_iCredits[client] -= 800;
			}
			else
			{
				PrintToChat(client, "[Shop] You don't have enough money! You need 800 but you only have %i", g_iCredits[client]);
			}
		}
	}
	SetCommandFlags("give", flagszspawn | FCVAR_CHEAT);
}

public int SMG_Menu_Handle(Menu gmenu, MenuAction action, int client, int Position)
{
	int flagszspawn = GetCommandFlags("give");
	SetCommandFlags("give", flagszspawn & ~FCVAR_CHEAT);

	if (action == MenuAction_Select)
	{
		char Item[32];
		gmenu.GetItem(Position, Item, sizeof(Item));
		gmenu.DisplayAt(client, GetMenuSelectionPosition(), MENU_TIME_FOREVER);

		if (StrEqual(Item, "option1"))
		{
			if (g_iCredits[client] >= 400)
			{
				FakeClientCommand(client, "give smg");
				g_iCredits[client] -= 400;
			}
			else
			{
				PrintToChat(client, "[Shop] You don't have enough money! You need 400 but you only have %i", g_iCredits[client]);
			}
		}
        if (StrEqual(Item, "option2"))
		{
			if (g_iCredits[client] >= 600)
			{
				FakeClientCommand(client, "give smg_silenced");
				g_iCredits[client] -= 600;
			}
			else
			{
				PrintToChat(client, "[Shop] You don't have enough money! You need 600 but you only have %i", g_iCredits[client]);
			}
		}
        if (StrEqual(Item, "option3"))
		{
			if (g_iCredits[client] >= 500)
			{
				FakeClientCommand(client, "give smg_mp5");
				g_iCredits[client] -= 500;
			}
			else
			{
				PrintToChat(client, "[Shop] You don't have enough money! You need 500 but you only have %i", g_iCredits[client]);
			}
		}
	}
	SetCommandFlags("give", flagszspawn | FCVAR_CHEAT);
}

public int Rifle_Menu_Handle(Menu rmenu, MenuAction action, int client, int Position)
{
	int flagszspawn = GetCommandFlags("give");
	SetCommandFlags("give", flagszspawn & ~FCVAR_CHEAT);

	if (action == MenuAction_Select)
	{
		char Item[32];
		rmenu.GetItem(Position, Item, sizeof(Item));
		rmenu.DisplayAt(client, GetMenuSelectionPosition(), MENU_TIME_FOREVER);

		if (StrEqual(Item, "option1"))
		{
			if (g_iCredits[client] >= 750)
			{
				FakeClientCommand(client, "give rifle");
				g_iCredits[client] -= 750;
			}
			else
			{
				PrintToChat(client, "[Shop] You don't have enough money! You need 750 but you only have %i", g_iCredits[client]);
			}
		}
        if (StrEqual(Item, "option2"))
		{
			if (g_iCredits[client] >= 900)
			{
				FakeClientCommand(client, "give rifle_ak47");
				g_iCredits[client] -= 900;
			}
			else
			{
				PrintToChat(client, "[Shop] You don't have enough money! You need 900 but you only have %i", g_iCredits[client]);
			}
		}
        if (StrEqual(Item, "option3"))
		{
			if (g_iCredits[client] >= 700)
			{
				FakeClientCommand(client, "give rifle_desert");
				g_iCredits[client] -= 700;
			}
			else
			{
				PrintToChat(client, "[Shop] You don't have enough money! You need 700 but you only have %i", g_iCredits[client]);
			}
		}
        if (StrEqual(Item, "option4"))
		{
			if (g_iCredits[client] >= 850)
			{
				FakeClientCommand(client, "give rifle_sg552");
				g_iCredits[client] -= 850;
			}
			else
			{
				PrintToChat(client, "[Shop] You don't have enough money! You need 850 but you only have %i", g_iCredits[client]);
			}
		}
	}
	SetCommandFlags("give", flagszspawn | FCVAR_CHEAT);
}

public int SRifle_Menu_Handle(Menu emenu, MenuAction action, int client, int Position)
{
	int flagszspawn = GetCommandFlags("give");
	SetCommandFlags("give", flagszspawn & ~FCVAR_CHEAT);

	if (action == MenuAction_Select)
	{
		char Item[32];
		emenu.GetItem(Position, Item, sizeof(Item));
		emenu.DisplayAt(client, GetMenuSelectionPosition(), MENU_TIME_FOREVER);

		if (StrEqual(Item, "option1"))
		{
			if (g_iCredits[client] >= 600)
			{
				FakeClientCommand(client, "give hunting_rifle");
				g_iCredits[client] -= 600;
			}
			else
			{
				PrintToChat(client, "[Shop] You don't have enough money! You need 600 but you only have %i", g_iCredits[client]);
			}
		}
        if (StrEqual(Item, "option2"))
		{
			if (g_iCredits[client] >= 900)
			{
				FakeClientCommand(client, "give sniper_military");
				g_iCredits[client] -= 900;
			}
			else
			{
				PrintToChat(client, "[Shop] You don't have enough money! You need 900 but you only have %i", g_iCredits[client]);
			}
		}
        if (StrEqual(Item, "option3"))
		{
			if (g_iCredits[client] >= 700)
			{
				FakeClientCommand(client, "give sniper_scout");
				g_iCredits[client] -= 700;
			}
			else
			{
				PrintToChat(client, "[Shop] You don't have enough money! You need 700 but you only have %i", g_iCredits[client]);
			}
		}
        if (StrEqual(Item, "option4"))
		{
			if (g_iCredits[client] >= 750)
			{
				FakeClientCommand(client, "give sniper_awp");
				g_iCredits[client] -= 750;
			}
			else
			{
				PrintToChat(client, "[Shop] You don't have enough money! You need 750 but you only have %i", g_iCredits[client]);
			}
		}
	}
	SetCommandFlags("give", flagszspawn | FCVAR_CHEAT);
}

public int Special_Menu_Handle(Menu cmenu, MenuAction action, int client, int Position)
{
	int flagszspawn = GetCommandFlags("give");
	SetCommandFlags("give", flagszspawn & ~FCVAR_CHEAT);

	if (action == MenuAction_Select)
	{
		char Item[32];
		cmenu.GetItem(Position, Item, sizeof(Item));
		cmenu.DisplayAt(client, GetMenuSelectionPosition(), MENU_TIME_FOREVER);

		if (StrEqual(Item, "option1"))
		{
			if (g_iCredits[client] >= 1500)
			{
				FakeClientCommand(client, "give weapon_grenade_launcher");
				g_iCredits[client] -= 1500;
			}
			else
			{
				PrintToChat(client, "[Shop] You don't have enough money! You need 750 but you only have %i", g_iCredits[client]);
			}
		}
        if (StrEqual(Item, "option2"))
		{
			if (g_iCredits[client] >= 2000)
			{
				FakeClientCommand(client, "give rifle_m60");
				g_iCredits[client] -= 2000;
			}
			else
			{
				PrintToChat(client, "[Shop] You don't have enough money! You need 2000 but you only have %i", g_iCredits[client]);
			}
		}
	}
	SetCommandFlags("give", flagszspawn | FCVAR_CHEAT);
}

public int Grenade_Menu_Handle(Menu nmenu, MenuAction action, int client, int Position)
{
	int flagszspawn = GetCommandFlags("give");
	SetCommandFlags("give", flagszspawn & ~FCVAR_CHEAT);

	if (action == MenuAction_Select)
	{
		char Item[32];
		nmenu.GetItem(Position, Item, sizeof(Item));
		nmenu.DisplayAt(client, GetMenuSelectionPosition(), MENU_TIME_FOREVER);

		if (StrEqual(Item, "option1"))
		{
			if (g_iCredits[client] >= 200)
			{
				FakeClientCommand(client, "give pipe_bomb");
				g_iCredits[client] -= 100;
			}
			else
			{
				PrintToChat(client, "[Shop] You don't have enough money! You need 100 but you only have %i", g_iCredits[client]);
			}
		}
		if (StrEqual(Item, "option2"))
		{
			if (g_iCredits[client] >= 400)
			{
				FakeClientCommand(client, "give molotov");
				g_iCredits[client] -= 120;
			}
			else
			{
				PrintToChat(client, "[Shop] You don't have enough money! You need 120 but you only have %i", g_iCredits[client]);
			}
		}
		if (StrEqual(Item, "option3"))
		{
			if (g_iCredits[client] >= 100)
			{
				FakeClientCommand(client, "give vomitjar");
				g_iCredits[client] -= 80;
			}
			else
			{
				PrintToChat(client, "[Shop] You don't have enough money! You need 80 but you only have %i", g_iCredits[client]);
			}
		}
	}
	SetCommandFlags("give", flagszspawn | FCVAR_CHEAT);
}

public int Heal_Menu_Handle(Menu lmenu, MenuAction action, int client, int Position)
{
	int flagszspawn = GetCommandFlags("give");
	SetCommandFlags("give", flagszspawn & ~FCVAR_CHEAT);

	if (action == MenuAction_Select)
	{
		char Item[32];
		lmenu.GetItem(Position, Item, sizeof(Item));
		lmenu.DisplayAt(client, GetMenuSelectionPosition(), MENU_TIME_FOREVER);

		if (StrEqual(Item, "option1"))
		{
			if (g_iCredits[client] >= 400)
			{
				FakeClientCommand(client, "give first_aid_kit");
				g_iCredits[client] -= 400;
			}
			else
			{
				PrintToChat(client, "[Shop] You don't have enough money! You need 400 but you only have %i", g_iCredits[client]);
			}
		}
        if (StrEqual(Item, "option2"))
		{
			if (g_iCredits[client] >= 1200)
			{
				FakeClientCommand(client, "give defibrillator");
				g_iCredits[client] -= 1200;
			}
			else
			{
				PrintToChat(client, "[Shop] You don't have enough money! You need 1200 but you only have %i", g_iCredits[client]);
			}
		}
		if (StrEqual(Item, "option3"))
		{
			if (g_iCredits[client] >= 200)
			{
				FakeClientCommand(client, "give pain_pills");
				g_iCredits[client] -= 200;
			}
			else
			{
				PrintToChat(client, "[Shop] You don't have enough money! You need 200 but you only have %i", g_iCredits[client]);
			}
		}
        if (StrEqual(Item, "option4"))
		{
			if (g_iCredits[client] >= 200)
			{
				FakeClientCommand(client, "give adrenaline");
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

public int Misc_Menu_Handle(Menu imenu, MenuAction action, int client, int Position)
{
	int flagszspawn = GetCommandFlags("give");
	SetCommandFlags("give", flagszspawn & ~FCVAR_CHEAT);

	if (action == MenuAction_Select)
	{
		char Item[32];
		imenu.GetItem(Position, Item, sizeof(Item));
		imenu.DisplayAt(client, GetMenuSelectionPosition(), MENU_TIME_FOREVER);

		if (StrEqual(Item, "option1"))
		{
			if (g_iCredits[client] >= 400)
			{
				FakeClientCommand(client, "give ammo");
				g_iCredits[client] -= 400;
			}
			else
			{
				PrintToChat(client, "[Shop] You don't have enough money! You need 400 but you only have %i", g_iCredits[client]);
			}
		}
		if (StrEqual(Item, "option2"))
		{
			if (g_iCredits[client] >= 800)
			{
				FakeClientCommand(client, "give upgradepack_incendiary");
				g_iCredits[client] -= 800;
			}
			else
			{
				PrintToChat(client, "[Shop] You don't have enough money! You need 800 but you only have %i", g_iCredits[client]);
			}
		}
		if (StrEqual(Item, "option3"))
		{
			if (g_iCredits[client] >= 800)
			{
				FakeClientCommand(client, "give upgradepack_explosive");
				g_iCredits[client] -= 800;
			}
			else
			{
				PrintToChat(client, "[Shop] You don't have enough money! You need 800 but you only have %i", g_iCredits[client]);
			}
		}
	}
	SetCommandFlags("give", flagszspawn | FCVAR_CHEAT);
}