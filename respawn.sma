/*
*	___________
*
*	Auto Respawn v1.0
*		
*	Author: ALGHTRYER 
*	e: alghtryer@gmail.com w: alghtryer.github.io 	
*	___________
*
*	Auto Respawn when player join on server and after player killed.  	
*/

#include < amxmodx >
#include < hamsandwich >
#include < cstrike >

public plugin_init( ) 
{
	register_plugin
	(
		"Auto Respawn",		
		"1.0",	
		"ALGHTRYER"
	);

	register_cvar( "arw_version", "1.0" , FCVAR_SERVER|FCVAR_UNLOGGED );
	
	RegisterHam( Ham_Killed, "player", "PlayerKilled", 1 );
	register_event( "TeamInfo", "join_team", "a" );
}
public PlayerKilled( Victim )
{
	if ( !is_user_alive( Victim ) )
		set_task( 1.0, "PlayerRespawn", Victim );
}
public PlayerRespawn( id )
{
	if ( !is_user_alive(id) && CS_TEAM_T <= cs_get_user_team( id ) <= CS_TEAM_CT )
	{
		ExecuteHamB( Ham_CS_RoundRespawn, id );
	}
}
public join_team( )
{
	
	new Client = read_data( 1 ); 
	static user_team[ 32 ]; 
	
	read_data( 2, user_team, 31 ); 
	
	if(!is_user_connected( Client ) ) 
		return PLUGIN_HANDLED; 
	
	switch( user_team[ 0 ] ) 
	{
		case 'C':  
		{
			if( !is_user_alive( Client ) )
				set_task( 1.0,"spawnning",Client );
		}
		
		case 'T':
		{ 
			if( !is_user_alive( Client) )
				set_task( 1.0,"spawnning",Client ); 
		}
		
		case 'S':  
		{
			client_print( Client, print_chat, "You have to join CT or Terrorist to respawn" );
		}
	}
	return 0;
}
public spawnning( Client ) 
{
	ExecuteHamB( Ham_CS_RoundRespawn, Client );
	client_print( Client, print_chat, "You have been respawned" );
	remove_task( Client );
}
public client_disconnect( id )
{
	remove_task( id );
	return PLUGIN_HANDLED;
}
