/**
* Delete a logger.  Identify the logger uniquely by the name.
* 
* {code}
* cfconfig logger delete application
* cfconfig logger delete application serverName
* cfconfig logger delete application /path/to/server/home
* {code}
*
*/
component {
	
	property name='CFConfigService' inject='CFConfigService@cfconfig-services';
	property name='Util' inject='util@commandbox-cfconfig';
	/**
	* @name The name of the logger
	* @to CommandBox server name, server home path, or CFConfig JSON file. Defaults to CommandBox server in CWD.
	* @toFormat The format to write to. Ex: LuceeServer@5
	*/	
	function run(
		required string name,
		string to,
		string toFormat
	) {		
		var to = arguments.to ?: '';
		var toFormat = arguments.toFormat ?: '';

		try {
			var toDetails = Util.resolveServerDetails( to, toFormat );
		} catch( cfconfigException var e ) {
			error( e.message, e.detail ?: '' );
		}
			
		if( !toDetails.path.len() ) {
			error( "The location for the server couldn't be determined.  Please check your spelling." );
		}
		
		// Read existing config
		var oConfig = CFConfigService.determineProvider( toDetails.format, toDetails.version )
			.read( toDetails.path );

		// Get the caches and remove the requested one
		var loggers = oConfig.getLoggers() ?: {};
		loggers.delete( name );	
		
		// Set remaining caches back and save
		oConfig.setLoggers( loggers )
			.write( toDetails.path );		
			
		print.greenLine( 'Logger [#name#] deleted.' );
	}
	
}