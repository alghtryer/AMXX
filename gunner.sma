/*
*	___________
*
*	Gunner for PB v1.0
*		
*	Author: ALGHTRYER 
*	e: alghtryer@gmail.com w: alghtryer.github.io 	
*	___________
*
*	Gunner for Paintball Mod.
*/

#include < amxmodx > 
#include < hamsandwich  >
#include < fun >
#include < fakemeta >
#include < cstrike >

#define GUNNER_FLAG ADMIN_VOTE 

const m_pPlayer     = 41
const m_pActiveItem = 373
const XoWeapon      = 4
const XoPlayer      = 5

new const iModel[ ] = "models/v_pbgunner.mdl"
new const iModelp[ ] = "models/p_pbgunner.mdl"


public plugin_init( ) 
{ 
	register_plugin
	(
		"Gunner for PB",		
		"1.0",	
		"ALGHTRYER"
	);

	RegisterHam( Ham_Item_Deploy, "weapon_p90", "CBasePlayer_ItemDeploy", true )
	RegisterHam( Ham_Spawn, "player", "fwHamPlayerSpawnPost", 1 )
	
} 
public plugin_precache( ) 
{ 
	precache_model( iModel ) 
	precache_model( iModelp ) 
} 
public CBasePlayer_ItemDeploy( const entity )
{
	if( pev_valid( entity ) )
	{
		new id = get_pdata_cbase( entity, m_pPlayer, XoWeapon )

		if( is_user_alive( id ) && get_user_flags( id ) & GUNNER_FLAG )
		{
			new entityClassName[ 32 ]
			pev( entity, pev_classname, entityClassName, charsmax( entityClassName ) )
			
			if( equal( entityClassName, "weapon_p90" ) )
			{
				set_pev( id, pev_viewmodel2, iModel )
				set_pev( id, pev_weaponmodel2, iModelp )
			}
		}
	}
}

public fwHamPlayerSpawnPost( id ) 
{
	if ( is_user_alive(id) && get_user_flags( id ) & GUNNER_FLAG ) 
	{
		set_task( 2.0, "give_p90", id );
	}
}  

public give_p90( id ) 
{
	if ( is_user_alive( id ) && get_user_flags( id ) & GUNNER_FLAG ) 
	{
		give_item( id, "weapon_p90"  ) 
		cs_set_user_bpammo( id, CSW_P90, 100 )
		remove_task( id );
	}
}
public client_disconnect( id )
{
	if( task_exists( id ) )
	{
		remove_task( id );
	}
}
