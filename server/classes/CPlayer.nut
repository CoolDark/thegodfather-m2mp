class CPlayer { 
	m_iID = -1;
	name = "";
	
	constructor( iPlayerID ) {
		this.m_iID = iPlayerID;
		this.name = getPlayerName ( iPlayerID );
	}
	
	function message ( sText, iRed = 255, iGreen = 255, iBlue = 255 ) {
		return sendPlayerMessage ( this.m_iID, sText, iRed, iGreen, iBlue );
	}
	
	function toggleControl( toggle ) {
		togglePlayerControls( this.m_iID, toggle );
	}
	
	function getPosition ( ) {
		return getPlayerPosition( this.m_iID )
	}
	
	function setPosition ( ... ) {
		return setPlayerPosition ( this.m_iID, vargv[ 0 ].tofloat(), vargv[ 1 ].tofloat(), vargv[ 2 ].tofloat() );
	}
	
	function setRotation ( ... ) {
		return setPlayerRotation ( this.m_iID, vargv[ 0 ].tofloat(), vargv[ 1 ].tofloat(), vargv[ 2 ].tofloat() );
	}
	
	function getHealth ( ) {
		return getPlayerHealth ( this.m_iID );
	}
	
	function setHealth ( sHealth ) {
		return setPlayerHealth ( this.m_iID, sHealth.tofloat() );
	}
	
	function getModel ( ) {
		return getPlayerModel( this.m_iID ) ;
	}
	
	function setModel ( sModel ) {
		if ( this.getModel( ) == sModel.tointeger( ) ) return 0;
		return setPlayerModel ( this.m_iID, sModel.tointeger() );
	}
	
	function giveWeapon ( iWeapon, iAmmo ) {
		return givePlayerWeapon ( this.m_iID, iWeapon, iAmmo );
	}
	
	function removeWeapon ( iWeapon ) {
		return removePlayerWeapon ( this.m_iID, iWeapon );
	}
	
	function getSerial ( ) {
		return getPlayerSerial ( this.m_iID );
	}
	
	function getName ( ) {
		return name;
	}
	
	function getNetStat ( ) {
		return getPlayerNetworkStats( tihs.m_iID ) ;
	}
	
	function getVehicle ( ) {
		return getPlayerVehicle ( this.m_iID );
	}
	
	function getPing ( ) {
		return getPlayerPing ( this.m_iID );
	}
	
	function setColor ( sColor ) {
		return setPlayerColour( this.m_iID, sColor );
	}
	function kick ( ) {
		return kickPlayer ( this.m_iID );
	}
};
