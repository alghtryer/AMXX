/*
*	___________
*
*	SnapShot v1.0s
*		
*	Author: ALGHTRYER 
*	e: alghtryer@gmail.com w: alghtryer.github.io 	
*	___________
*
*	Take ss on player. amx_ss 	
*/

#include < amxmodx >
#include < amxmisc >
 
new g_Seconds;
 
public plugin_init( ) 
{  
    register_plugin
	(
		"SnapShot",		
		"1.0s",	
		"ALGHTRYER"
	);
   
    register_cvar( "snapshot_version", "1.0s", FCVAR_SERVER | FCVAR_SPONLY );
    register_concmd( "amx_ss", "SnapShot", ADMIN_KICK, "amx_ss <player>" )
     
}
public SnapShot( id, level, cid )
{
    if ( !cmd_access(id, level, cid, 2))
        return PLUGIN_HANDLED      
   
    new arg[ 32 ]
    read_argv( 1, arg, 31 )
   
    new player = cmd_target( id, arg, 4 );
   
    if ( !player )
        return PLUGIN_HANDLED
   
    new adminname[ 32 ], name_player[ 32 ];
    get_user_name( player, name_player, 31 );
    get_user_name( id, adminname, 31 );

    ClientPrintColor(0, "!tADMIN !g^"%s^" !tused command SnapShot on !g^"%s^"." , adminname, name_player);
   
    g_Seconds = 3;

    set_task( 1.0, "snap", player, "", 0, "b" );

    return PLUGIN_HANDLED
}
public snap( player )
{
	new timer[ 32 ];
    	get_time( "%m/%d/%Y - %H:%M:%S", timer, 31 );
   
    	g_Seconds--;

    	switch( g_Seconds )
    	{
        	case 2: 
		{
            		ClientPrintColor( player, "!t- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - " );
            		ClientPrintColor( player, "!t- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - " );
            		ClientPrintColor( player,  "!gADMIN used command SnapShot on you! !t[%s]" ,timer);
            		ClientPrintColor( player, "!t- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - " );
            		ClientPrintColor( player, "!t- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - " );
        	}
        	case 1:
		{
            		client_cmd( player, "snapshot" );
        	}
        	case 0:
		{
            		remove_task( player );
        	}
    	}
}

public client_disconnect( id )
{
	if( task_exists( id ) )
	{
		remove_task( id );
	}
}
   
ClientPrintColor( id, String[ ], any:... )
{
	new szMsg[ 190 ]
	vformat( szMsg, charsmax( szMsg ), String, 3 )
   
	replace_all( szMsg, charsmax( szMsg ), "!n", "^1" )
	replace_all( szMsg, charsmax( szMsg ), "!t", "^3" )
	replace_all( szMsg, charsmax( szMsg ), "!g", "^4" )
   
	static msgSayText = 0
	static fake_user
   
    	if( !msgSayText )
    	{
       		msgSayText = get_user_msgid( "SayText" )
        	fake_user = get_maxplayers( ) + 1
    	}
   
    	message_begin( id ? MSG_ONE_UNRELIABLE : MSG_BROADCAST, msgSayText, _, id )
    	write_byte( id ? id : fake_user )
    	write_string( szMsg )
    	message_end( )
}
