dofile( "resources/default/server/classes/CPlayer.nut" );
dofile( "resources/default/server/classes/CVehicle.nut" );
dofile( "resources/default/server/classes/CMysql.nut" );
dofile( "resources/default/server/events/event.nut" );
dofile( "resources/default/server/includes/d_Each.nut" );
dofile( "resources/default/server/functions/function.nut" );


/*Local*/
local player = { };
local iVehicle = { };

local mysql = CMySQL( );
local gAccount = array( getMaxPlayers() ) ;
local playerData = { };

/*Const*/
const scriptName 	= "The Godfather";
const youCanNot 	= "��� ���������� ������ �������.";

const SQL_HOST		= "localhost";
const SQL_DB		= "m2mp";
const SQL_USER		= "root";
const SQL_PASS		= "";

addEventHandler( "onScriptInit",
	function() {
		log( scriptName + " Loaded!" );
		setGameModeText( "The Godfather v 0.1" );
		setMapName( "Empire Bay" );
		
		mysql.connect( SQL_HOST, SQL_USER, SQL_PASS, SQL_DB ) ;
		
		 timer ( 
			function( ) {
				dIter (
					function ( id ) {
						if ( isPlayerSpawned( id ) )  {
							local health = player[ id ].getHealth( );
							health < 250.0  && player[ id ].message( "�� �������������. ��� ������ ����� ������!" ), player[ id ].setHealth( --health ) ;
						}
					}
				);
			}
			, 60000
			, -1 
		);
	}
);

addEventHandler ( "onScriptExit",
	function() {
	
	}
);

addEventHandler( "onPlayerConnect",
	function( playerid, name, ip, serial ) {
		player[ playerid ] <- { };
		player[ playerid ] <- CPlayer( playerid ) ;
		
		playerData[ playerid ] 			<- { };
		playerData[ playerid ].Logged 	<- 0;
		playerData[ playerid ].Admin 	<- 0;
		playerData[ playerid ].Skin 	<- 1;
		
		sendPlayerMessageToAll( "~ " + player[ playerid ].getName() + " �������������. ������ ������� �� �������: " + getPlayerCount() + "/" + getMaxPlayers(), 0, 255, 0 );
		
		player[ playerid ].message( "����� ���������� �� " + scriptName );
		player[ playerid ].message( "����� �������� ������� ������ ������� ������� F10" );
		
		if ( mysql.AccountExists( playerid ) ) {
			player[ playerid ].message( "��� ������� ���������������, �������� ������� ����������� ��������� /login password.", 255, 204, 0 );
			gAccount[ playerid ] = 1;
		} else {
			player[ playerid ].message( "���� ������� �� ���������������, �������� ������� ����������� ��������� /register password.", 255, 204, 0 );
			gAccount[ playerid ] = 0;
		}
	}
);

addEventHandler( "onPlayerDisconnect",
	function( playerid, reason ) {
		playerSave( playerid ) ;
		sendPlayerMessageToAll( "~ " + player[ playerid ].getName( ) + " ����������.", 255, 0, 23 );
		delete player[ playerid ] ;
		delete playerData[ playerid ] ;
	}
);

addEventHandler( "onPlayerSpawn",
	function( playerid ) {
		player[ playerid ].toggleControl( false ) ;
		player[ playerid ].setPosition( -1551.560181, -169.915466, -19.672523 );
		player[ playerid ].setHealth( 500.0 );
		player[ playerid ].setColor( 0xFFFFFFFF );
	}
);

addEventHandler( "onPlayerChat",
	function( playerid, chattext ) {
		local pos = player[ playerid ].getPosition( );
		return sendMessageToAllInRadius( "- " + player[ playerid ].getName() + " ������: " + chattext, pos[ 0 ], pos[ 1 ], pos[ 2 ] );
	}
);

addEventHandler( "onPlayerDeath",
	function( playerid, killerid ) {
	
	}
);

/*Functions*/

this.playerSave <- function( playerid ) {
	if ( playerData[ playerid ].Logged == 1 ) {
		mysql.query( "UPDATE `accounts` SET `Admin` = '" + playerData[ playerid ].Admin + "', `Skin` = '" + playerData[ playerid ].Skin + "' WHERE `Name` = '" + player[ playerid ].getName( ) + "'" ) ;
	}
    
    return 1 ;
}

/*Commands*/

addCommandHandler( "w",
	function( playerid, ... ) {
		if ( vargv.len( ) < 1 ) return sendPlayerMessage( playerid, "����������� /w [id ������] [�����]",205, 85, 85 );
		local text = "";
		for ( local i = 0; i < vargv.len( ); i++ ){
			text = text + " " + vargv[ i ];
		}
		if ( !isPlayerConnected( vargv[ 0 ].tointeger( ) ) ) return player[ playerid ].message( "����� " + vargv[ 0 ].tointeger() + " �� � ����" );
		player[ vargv[ 0 ].tointeger( ) ].message(  "�� " + player[ playerid ].getName( ) + " [" + playerid + "]: " + text );
		player[ playerid ].message( "� " + player[ vargv[ 0 ].tointeger( ) ].getName( ) + " [" + vargv[ 0 ].tointeger( ) + "]: " + text );
	}
);

addCommandHandler( "s",
	function( playerid, ... ) {
		if ( vargv.len( ) < 1 ) return sendPlayerMessage( playerid, "����������� /s [�����]",205, 85, 85 );
		local text = "";
		for ( local i = 0; i < vargv.len( ); i++ ){
			text = text + " " + vargv[ i ];
		}
		local position = player[ playerid ].getPosition( );
		sendMessageToAllInRadius( "- " + player[ playerid ].getName( ) + " �������: " + text, position[ 0 ], position[ 1 ], position[ 2 ], 40.0 );
	}
);

addCommandHandler( "register",
	function( playerid, password ) {
		if( playerData[ playerid ].Logged == 0 ) {
			if ( password.len( ) < 1 ) return sendPlayerMessage( playerid, "����������� /register password",205, 85, 85 );
			if ( gAccount[ playerid ] == 1 ) return player[ playerid ].message( "���� ������� ��� ���������������!" ) ;
			mysql.RegisterPlayer( playerid, password );
			player[ playerid ].message( "�� ������� ������������������." ) ;
			player[ playerid ].toggleControl( true ) ;
		} else {
			player[ playerid ].message( "�� ��� ������������.");
		}
	}
);

addCommandHandler( "login",
	function( playerid, password ) {
		if( playerData[ playerid ].Logged == 0 ) {
			if ( gAccount[ playerid ] == 0 ) return player[ playerid ].message( "������ �������� �� ����������!" ) ;
			if ( password.len( ) < 1 ) return sendPlayerMessage( playerid, "����������� /login password",205, 85, 85 );
			if ( mysql.CheckLogin ( playerid, password ) ) {
				playerData[ playerid ].Skin 	= mysql.fetchEx( 3 );
				playerData[ playerid ].Admin 	= mysql.fetchEx( 4 );
				playerData[ playerid ].Logged 	= 1;
				
				player[ playerid ].message( "�� ������� ��������������." );
				player[ playerid ].setModel( playerData[ playerid ].Skin );
				player[ playerid ].toggleControl( true ) ;
			} else {
				player[ playerid ].message( "�� ����� �������� ������." );
			}
			mysql.free( ) ;
		} else {
			player[ playerid ].message( "�� ��� ������������." );
		}
	}
);

addCommandHandler( "kick",
	function( playerid, ... ) {
		if ( playerData[ playerid ].Admin.tointeger( ) > 0 ) {
			if ( vargv.len( ) < 2 ) return player[ playerid ].message( "����������� /kick [id ������] [�������]",205, 85, 85 );
			if ( !isPlayerConnected( vargv[ 0 ].tointeger( ) ) ) return player[ playerid ].message( "����� " + vargv[ 0 ].tointeger() + " �� � ����" );
			local text = "";
			for ( local i = 0; i < vargv.len( ); i++ ){
				text = text + " " + vargv[ i ];
			}
			sendPlayerMessageToAll( "������������� '" + player[ playerid ].getName( ) + "' ������ '" + player[ vargv[ 0 ].tointeger( ) ].getName( ) + "'! �������: '" + text.tostring() + "'");
			player[ vargv[ 0 ].tointeger( ) ].kick ();
		}
	}
);

addCommandHandler( "getns",
	function( playerid, giveplayerid ) {
		if ( playerData[ playerid ].Admin.tointeger() > 0 ) {
			if ( giveplayerid.len( ) < 1 ) return sendPlayerMessage( playerid, "����������� /getns [id ������]",205, 85, 85 );
			if ( !isPlayerConnected( giveplayerid.tointeger( ) ) ) return player[ playerid ].message( "����� " + giveplayerid.tointeger() + " �� � ����" );
			player[ playerid ].message( "Network Stats ������ '" + player[ giveplayerid.tointeger( ) ].getName( ) + "' : " + player[ giveplayerid.tointeger( ) ].getNetStat( ).tostring( ) );
		}
	}
);

addCommandHandler( "setmodel",
	function( playerid, ... ) {
		if ( playerData[ playerid ].Admin.tointeger() > 0 ) {
			if ( vargv.len( ) < 2 ) return sendPlayerMessage( playerid, "����������� /setmodel [id ������] [skin]",205, 85, 85 );
			if ( !isPlayerConnected( vargv[ 0 ].tointeger( ) ) ) return player[ playerid ].message( "����� " + vargv[ 0 ].tointeger() + " �� � ����" );
			
			player[ playerid ].message( "�� ���������� ������ " + player[ vargv[ 0 ].tointeger( ) ].getName ( ) + " " + vargv[ 1 ].tointeger( ) + " ������" ) ;
			player[ vargv[ 0 ].tointeger( ) ].message( "������������� " + player[ playerid.tointeger( ) ].getName ( ) + " ��������� ��� " + vargv[ 1 ].tointeger( ) + " ������" ) ;
			playerData[ vargv[ 0 ].tointeger( ) ].Skin = vargv[ 1 ].tointeger( ) ;
			player[ vargv[ 0 ].tointeger( ) ].setModel( playerData[ vargv[ 0 ].tointeger( ) ].Skin );
		}
	}
);

addCommandHandler( "a",
	function( playerid, ... ) {
		if ( playerData[ playerid ].Admin.tointeger( ) > 0 ) {
			if ( vargv.len( ) < 1 ) return sendPlayerMessage( playerid, "����������� /a [�����]",205, 85, 85 );
			local text = "";
			for ( local i = 0; i < vargv.len( ); i++ ){
				text = text + " " + vargv[ i ];
			}
			dIter(
				function( id ) {
					if ( playerData[ id ].Admin.tointeger( ) > 0 ) {
						player[ id ].message( "[A] �������������: " + player[ playerid ].getName( ) + ": " + text.tostring() ) ;
					}
				}
			);
		}
	}
);

addCommandHandler( "goto",
    function( playerid, id ) {
        if ( playerData[ playerid ].Admin.tointeger() > 0 ) {
			if ( id.len( ) < 1 ) return sendPlayerMessage( playerid, "����������� /goto [id ������]",205, 85, 85 );
			if ( !isPlayerConnected( id.tointeger( ) ) ) return player[ playerid ].message( "����� " + id.tointeger( ) + " �� � ����" );
			
            local pos = player[ id ].getPosition( ) ;
			
            setPlayerPosition( playerid, ( pos[ 0 ] + 1 ).tofloat( ), ( pos[ 1 ] + 1 ).tofloat( ), ( pos[ 2 ] ).tofloat( ) );
            player[ playerid ].message( "�� ����������������� � " + player[ id ].getName( ) );
            player[ id.tointeger( ) ].message( "� ��� ���������������� ������������� " + player[ playerid ].getName( ) );
        } else {
            player[ playerid ].message( youCanNot );
        }
   }
);

addCommandHandler( "get",
    function( playerid, id ) {
        if ( playerData[ playerid ].Admin.tointeger() > 0 ) {
			if ( id.len( ) < 1 ) return sendPlayerMessage( playerid, "����������� /get [id ������]",205, 85, 85 );
			if ( !isPlayerConnected( id.tointeger( ) ) ) return player[ playerid ].message( "����� " + id.tointeger( ) + " �� � ����" );
			
            local pos = player[ playerid ].getPosition( );
			
            setPlayerPosition( id.tointeger( ), ( pos[ 0 ] + 1 ).tofloat( ), ( pos[ 1 ] + 1 ).tofloat( ), ( pos[ 2 ] ).tofloat( ) );
            player[ playerid ].message( "�� ��������������� " + player[ id.tointeger( ) ].getName( ) + " � ����." );
            player[ id.tointeger( ) ].message( "��� �������������� ������������� " + player[ playerid ].getName( ) );
        } else {
            player[ playerid ].message( youCanNot );
        }
	}
);

addCommandHandler( "sethp",
    function( playerid, ... ) {
		if ( vargv.len( ) < 2 ) return sendPlayerMessage( playerid, "����������� /sethp [id ������] [hp]",205, 85, 85 );
        if ( playerData[ playerid ].Admin.tointeger() > 0 ) {
			if ( !isPlayerConnected( vargv[ 0 ].tointeger( ) ) ) return player[ playerid ].message( "����� " + id.tointeger( ) + " �� � ����" );
			
            player[ vargv[ 0 ].tointeger( ) ].setHealth( vargv[ 1 ].tofloat() );
        } else {
            player[ playerid ].message( youCanNot );
        }
    }
);

addCommandHandler( "ooc",
	function( playerid, ... ) {
		if ( vargv.len( ) < 1 ) return sendPlayerMessage( playerid, "����������� /ooc [�����]",205, 85, 85 );
		local text = "";
		for ( local i = 0; i < vargv.len( ); i++ ){
			text = text + " " + vargv[ i ];
		}
        if ( playerData[ playerid ].Admin.tointeger() > 0 ) {
            sendPlayerMessageToAll( "�������������: " + player[ playerid ].getName( ) + " [ " + playerid + " ]: " + text.tostring( ) );
        } else {
            player[ playerid ].message( youCanNot );
        }
	}
);

addCommandHandler( "vehicle",
    function( playerid, ... ) {
        if ( playerData[ playerid ].Admin.tointeger() > 0 ) {
   		local 	id 		= vargv[ 0 ] ,
				pos 	= getPlayerPosition( playerid ) ,
				vehicle = CreateVehicle( id.tointeger(), pos[0] + 2.0, pos[1], pos[2] + 1.0, 0.0, 0.0, 0.0 );
					
		setVehicleColour ( vehicle, 255, 0, 255, 0, 255, 255 );
        } else {
            player[ playerid ].message( youCanNot );
		}
    }
);

addCommandHandler( "setadmin",
    function( playerid, id ) {
        if ( playerData[ playerid ].Admin.tointeger() > 0 ) {
		if ( id.len( ) < 1 ) return sendPlayerMessage( playerid, "����������� /setadmin [id ������]",205, 85, 85 );
		if ( !isPlayerConnected( id.tointeger( ) ) ) return player[ playerid ].message( "����� " + id.tointeger( ) + " �� � ����" );
			
		playerData[ id.tointeger( ) ].Admin = 1;
		player[ id.tointeger( ) ].message( "������������� " + player[ playerid ].getName( ) + " �������� ��� ���������������!" );
		player[ playerid ].message( "�� ��������� ��������������� " + player[ id.tointeger( ) ].getName( ) );
        } else {
            player[ playerid ].message( youCanNot );
		}
    }
);