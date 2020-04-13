/*
*	___________
*
*	Simple Public VIP v1.0
*		
*	Author: ALGHTRYER 
*	e: alghtryer@gmail.com w: alghtryer.github.io 	
*	___________
*	
*      	VIP Player ( flag t ) have several privileges, which will not give much advantage over other players. 
*	You can adjust everything with cvar.
*
*	Features:
*	- Free he, smoke and flash bomb.
*	- Kevlar and Helmet 
*	- Defuse for CT 
*	- Menu with free weapon	( ak47/m4a1 + deagle ). Menu will be remove after 15 ( cvar ) seconds.  
*	- Only VIP can buy AWP. 
*	- Show damage.
*	- Happy Hour.
*
*	How set VIP?
* 	- Put flag "t" on player STEAM ID, IP or NAME.
*
*	Cvars : 
*	// 0 = off / 1 = on 
*	- spv_menu 1 = Show Menu
*	- spv_awp 1 = Only VIP can buy Awp
*	- spv_menuremove 15 = Remove Menu after seconds
*	- spv_he 1 = Give He
*	- spv_smoke 1 = Give Smoke
*	- spv_fb 1 = Give flash
*	- spv_fb2 1 = Give flash
*	- spv_armor 1 = Give Armor ( Kevlar and Helmet )
*	- spv_def 1 = Give defuse fot ct player
*	- spv_damage 1 = Show damage
*	- spv_hh 1 = Happy Hour
*	- spv_infohud 1 = Show hud about happy hour 
*	- spv_start 23 = When Start Happy Hour 2 = 2 am and 14 = 2 pm
*	- spv_end 9 = When End Happy Hour 2 = 2 am and 14 = 2 pm	
*	- spv_roundsmenu 3 = Menu with free weapon will be show on third ( cvar ) round
*
*	
*	Changelog:
*	- v1.0 [13. Apr 2020] : First release.
*
*/

#include < amxmodx >
#include < cstrike >
#include < fun >
#include < engine >
#include < fakemeta >
#include < hamsandwich >


new const
// _________________________________________
    
	PLUGIN [ ] = "Simple Public VIP",
   	VERSION[ ] = "1.0",
      	AUTHOR [ ] = "ALGHTRYER";
// _________________________________________


new bool:bHappyHour;

new CvarMenu;
new CvarAwp;
new CvarMenuRemove;
new CvarHe;
new CvarSmoke;
new CvarFb;
new CvarFb2;
new CvarArmor;
new CvarDef;
new CvarHappyHour;
new CvarInfoHud;
new CvarStart;
new CvarEnd; 
new CvarDamage;
new CvarRoundsMenu;

new gRounds;

new SyncInfoHud;
new SyncDamage;

enum /* Weapon types */
{
	Primary = 1
	, Secondary
	, Knife
	, Grenades
	, C4
};

public plugin_init( ) 
{
	register_plugin
	(
		PLUGIN,		//: Simple Public VIP 
		VERSION,	//: 1.0
		AUTHOR		//: ALGHTRYER <alghtryer.github.io>
	);

	register_cvar( "spv_version", VERSION, FCVAR_SERVER|FCVAR_UNLOGGED );

	CvarMenu			= register_cvar( "spv_menu", "1" );
	CvarAwp				= register_cvar( "spv_awp", "1" );
	CvarMenuRemove			= register_cvar( "spv_menuremove", "15" );
	CvarHe				= register_cvar( "spv_he", "1" );
	CvarSmoke			= register_cvar( "spv_smoke", "1" );
	CvarFb				= register_cvar( "spv_fb", "1" );
	CvarFb2				= register_cvar( "spv_fb2", "1" );
	CvarArmor			= register_cvar( "spv_armor", "1" );
	CvarDef				= register_cvar( "spv_def", "1" );
	CvarDamage			= register_cvar( "spv_damage", "1" );
	CvarHappyHour			= register_cvar( "spv_hh", "1" );
	CvarInfoHud			= register_cvar( "spv_infohud", "1" );
	CvarStart 			= register_cvar( "spv_start", "23" );
	CvarEnd 			= register_cvar( "spv_end", "9" );
	CvarRoundsMenu			= register_cvar( "spv_roundsmenu", "3" );

	SyncInfoHud			= CreateHudSyncObj( );
	SyncDamage			= CreateHudSyncObj( );

        register_logevent( "OnRoundStart", 2, "1=Round_Start" ); 
	register_event("HLTV", "CheckHappyHour", "a", "1=0", "2=0") 

	register_event( "TextMsg", "RestartGame", "a", "2&#Game_C","2&#Game_w" );

	register_event( "Damage", "Event_Damage", "b", "2>0", "3=0" );

	register_clcmd( "awp", "BuyAwp" );
	register_clcmd( "magnum" ,"BuyAwp" );

}

public plugin_cfg( ) 
{ 
	if( get_pcvar_num( CvarInfoHud ) )
		set_task( 1.0, "InfoHud", _, _, _, "b" );

}

public InfoHud( )
{
	set_hudmessage( 0, 212, 255, 0.57, 0.05, _, _, 1.0, _, _, 1 );
	ShowSyncHudMsg( 0, SyncInfoHud, "Free Vip from %dh to %dh", get_pcvar_num( CvarStart ), get_pcvar_num( CvarEnd ) );
}

public OnRoundStart( )
{
	gRounds ++

	new iPlayers[ 32 ] , iNum, id;
	get_players( iPlayers , iNum  );

	for ( new i = 0 ; i < iNum ; i++ )
	{
		id = iPlayers[ i ];

    		if( get_user_flags(id) & ADMIN_LEVEL_H || bHappyHour )
		{
			if( get_pcvar_num( CvarMenu ) && gRounds >= get_pcvar_num( CvarRoundsMenu ) )
			{
				CreateWeaponMenu( id );

				if( task_exists( id ) )
				{
					remove_task( id );
				}

				set_task( get_pcvar_float( CvarMenuRemove ), "RemoveMenu", id );
			}
			
			if( get_pcvar_num( CvarHe ) )
				give_item( id, "weapon_hegrenade" );

			if( get_pcvar_num( CvarSmoke ) )
				give_item( id, "weapon_smokegrenade" );

			if( get_pcvar_num( CvarFb ) )
				give_item( id, "weapon_flashbang" );

			if( get_pcvar_num( CvarFb2 ) )
				give_item( id, "weapon_flashbang" );

			if( get_pcvar_num( CvarArmor ) )
				cs_set_user_armor( id, 100, CS_ARMOR_VESTHELM );

			if ( get_pcvar_num( CvarDef ) && cs_get_user_team(id) == CS_TEAM_CT )
				cs_set_user_defuse( id, 1 );
		}
	}
}

public CreateWeaponMenu( id )
{
	new menu = menu_create( "\rWeapon Menu:", "weapon_menu" );
	menu_additem( menu, "\wAK47 + Deagle", "", 0 );
	menu_additem( menu, "\wM4A1 + Deagle", "", 0 );
    
	menu_setprop( menu, MPROP_EXIT, MEXIT_ALL );
    
	menu_display( id, menu, 0 );
    
}

public weapon_menu( id, menu, item )
{
	switch( item )
	{
		case 0:
		{
			if( !user_has_weapon( id, CSW_AK47))
			{ 
				StripWeapons( id, Primary );
				give_item( id, "weapon_ak47" ); 
			}
			else
				cs_set_weapon_ammo( find_ent_by_owner( -1, "weapon_ak47", id ), 30 );

			if( !user_has_weapon( id, CSW_DEAGLE))
        		{ 	
				StripWeapons( id, Secondary );
				give_item( id, "weapon_deagle" ); 
			}
			else
				cs_set_weapon_ammo( find_ent_by_owner( -1, "weapon_deagle", id ), 7 );

			cs_set_user_bpammo( id, CSW_AK47, 90 );
			cs_set_user_bpammo( id, CSW_DEAGLE, 35 );
       		}

        	case 1:
        	{
			if( !user_has_weapon( id, CSW_M4A1))
        		{ 
				StripWeapons( id, Primary );
				give_item( id, "weapon_m4a1" ); 
			}
			else
				cs_set_weapon_ammo( find_ent_by_owner( -1, "weapon_m4a1", id ), 30 );

			if( !user_has_weapon( id, CSW_DEAGLE))
        		{ 
				StripWeapons( id, Secondary );
				give_item( id, "weapon_deagle" ); 
			}
			else
				cs_set_weapon_ammo( find_ent_by_owner( -1, "weapon_deagle", id ), 7 );

			cs_set_user_bpammo( id, CSW_M4A1, 90 );
			cs_set_user_bpammo( id, CSW_DEAGLE, 35 );
		}
        	
		case MENU_EXIT:
        	{
            		client_print( id, print_chat, "You exited the menu..." );
 		}
	}

    	menu_destroy( menu );
    	return PLUGIN_HANDLED;
} 

public RemoveMenu( id )
{
	show_menu( id, 0, "^n", 1 );
}

public BuyAwp( id )
{
	if( get_pcvar_num( CvarAwp ) )
	{
	
		if( get_user_flags(id) & ADMIN_LEVEL_H || bHappyHour  )	
			return PLUGIN_CONTINUE;
		
        	client_print( id, print_center, "#Cstrike_TitlesTXT_Cannot_Buy_This" );
        	return PLUGIN_HANDLED;
 	}
	return PLUGIN_CONTINUE;			
}

public Event_Damage( iVictim )
{
	if( get_pcvar_num( CvarDamage) )
	{
		new id = get_user_attacker( iVictim );
		
		if( is_user_connected( id ) && get_user_flags(id) & ADMIN_LEVEL_H )
		{
			set_hudmessage( 0, 100, 200, -1.0, 0.55, 2, 0.1, 4.0, 0.02, 0.02, -1 );
			ShowSyncHudMsg( id, SyncDamage, "%d^n", read_data( 2 ) );
		}
	}
}

public CheckHappyHour( )
{
	if( get_pcvar_num( CvarHappyHour ) )
	{
		static hour_str[ 3 ], get_hour, get_start, get_end;
	
		get_time( "%H", hour_str, 2 );
	
		get_hour	= str_to_num( hour_str );
	
		get_start	= get_pcvar_num( CvarStart );
		get_end		= get_pcvar_num( CvarEnd );

		if( get_start < get_end ? ( get_start <= get_hour && get_hour < get_end ) : ( get_start <= get_hour || get_hour < get_end ) )
			bHappyHour = true;
		else
			bHappyHour = false;
	}
}

public RestartGame( )
{
	gRounds = 0;
}

public client_disconnect( id )
{
	if( task_exists( id ) )
	{
		remove_task( id );
	}
}

// ***
// Start "stripsweapons.inc" <https://forums.alliedmods.net/showpost.php?p=1585138&postcount=9>

stock StripWeapons(id, Type, bool: bSwitchIfActive = true)
{
	new iReturn;
	
	if(is_user_alive(id))
	{
		new iEntity, iWeapon;
		while((iWeapon = GetWeaponFromSlot(id, Type, iEntity)) > 0)
			iReturn = ham_strip_user_weapon(id, iWeapon, Type, bSwitchIfActive);
	}
	
	return iReturn;
}
stock GetWeaponFromSlot( id , iSlot , &iEntity )
{
	if ( !( 1 <= iSlot <= 5 ) )
		return 0;
	
	iEntity = 0;
	const m_rgpPlayerItems_Slot0 = 367;
	const m_iId = 43;
	const XO_WEAPONS = 4;
	const XO_PLAYER = 5;
		
	iEntity = get_pdata_cbase( id , m_rgpPlayerItems_Slot0 + iSlot , XO_PLAYER );
	
	return ( iEntity > 0 ) ? get_pdata_int( iEntity , m_iId , XO_WEAPONS ) : 0;
}  
stock ham_strip_user_weapon(id, iCswId, iSlot = 0, bool:bSwitchIfActive = true)
{
	new iWeapon
	if( !iSlot )
	{
		static const iWeaponsSlots[] = {
			-1,
			2, //CSW_P228
			-1,
			1, //CSW_SCOUT
			4, //CSW_HEGRENADE
			1, //CSW_XM1014
			5, //CSW_C4
			1, //CSW_MAC10
			1, //CSW_AUG
			4, //CSW_SMOKEGRENADE
			2, //CSW_ELITE
			2, //CSW_FIVESEVEN
			1, //CSW_UMP45
			1, //CSW_SG550
			1, //CSW_GALIL
			1, //CSW_FAMAS
			2, //CSW_USP
			2, //CSW_GLOCK18
			1, //CSW_AWP
			1, //CSW_MP5NAVY
			1, //CSW_M249
			1, //CSW_M3
			1, //CSW_M4A1
			1, //CSW_TMP
			1, //CSW_G3SG1
			4, //CSW_FLASHBANG
			2, //CSW_DEAGLE
			1, //CSW_SG552
			1, //CSW_AK47
			3, //CSW_KNIFE
			1 //CSW_P90
		}
		iSlot = iWeaponsSlots[iCswId]
	}

	const XTRA_OFS_PLAYER = 5
	const m_rgpPlayerItems_Slot0 = 367

	iWeapon = get_pdata_cbase(id, m_rgpPlayerItems_Slot0 + iSlot, XTRA_OFS_PLAYER)

	const XTRA_OFS_WEAPON = 4
	const m_pNext = 42
	const m_iId = 43

	while( iWeapon > 0 )
	{
		if( get_pdata_int(iWeapon, m_iId, XTRA_OFS_WEAPON) == iCswId )
		{
			break
		}
		iWeapon = get_pdata_cbase(iWeapon, m_pNext, XTRA_OFS_WEAPON)
	}

	if( iWeapon > 0 )
	{
		const m_pActiveItem = 373
		if( bSwitchIfActive && get_pdata_cbase(id, m_pActiveItem, XTRA_OFS_PLAYER) == iWeapon )
		{
			ExecuteHamB(Ham_Weapon_RetireWeapon, iWeapon)
		}

		if( ExecuteHamB(Ham_RemovePlayerItem, id, iWeapon) )
		{
			user_has_weapon(id, iCswId, 0)
			ExecuteHamB(Ham_Item_Kill, iWeapon)
			return 1
		}
	}

	return 0
} 

// End "stripsweapons.inc" <https://forums.alliedmods.net/showpost.php?p=1585138&postcount=9>
// ***

/* 
	MADE BY ALGHTRYER.
*/
