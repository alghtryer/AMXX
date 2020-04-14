/*
*	___________
*
*	Smart Silencer v1.0
*		
*	Author: ALGHTRYER 
*	e: alghtryer@gmail.com w: alghtryer.github.io 	
*	___________
*
*	Remember do you player put silencer on m4a1.	
*/

#include < amxmodx > 
#include < hamsandwich > 
#include < cstrike >

const m_pPlayer = 41
const XO_WEAPON = 4
new szm4a1[ 33 ]

public plugin_init( ) 
{ 
	register_plugin
	(
		"Smart Silencer",		
		"1.0",	
		"ALGHTRYER"
	);

	register_cvar( "smartsilincer_version", VERSION, FCVAR_SERVER|FCVAR_UNLOGGED );

    	RegisterHam( Ham_Item_Deploy, "weapon_m4a1", "OnM4A1_Deploy", 1 ); 
    	RegisterHam( Ham_Weapon_SecondaryAttack, "weapon_m4a1", "OnM4A1_SecondaryAttack", 1 );
} 
public OnM4A1_Deploy( m4a1 ) 
{ 
	new id = get_pdata_cbase( m4a1, m_pPlayer, XO_WEAPON );

	if( szm4a1[ id ] )
		cs_set_weapon_silen( m4a1, 1, 0 );
}
public OnM4A1_SecondaryAttack( m4a1 ) 
{ 
    	new id = get_pdata_cbase( m4a1, m_pPlayer, XO_WEAPON );
	
	if( szm4a1[ id ] )
        	szm4a1[ id ] = false;
	else
		szm4a1[ id ] = true; 
}
