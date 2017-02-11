/**
* Show a configuration setting for a server
*/
component {
	
	property name='CFConfigService' inject='CFConfigService@cfconfig-services';
	property name='Util' inject='util@commandbox-cfconfig';
	
	/**
	* @property name of the property to view.  Empty for everything.
	* @from CommandBox server name, server home path, or CFConfig JSON file. Defaults to CommandBox server in CWD.
	* @fromFormat The format to read from. Ex: LuceeServer@5
	*/	
	function run( 
		string property,
		string from,
		string fromFormat
	 ) {
		arguments.property = arguments.property ?: '';
		arguments.from = arguments.from ?: '';
		arguments.fromFormat = arguments.fromFormat ?: '';
		
		try {
			var fromDetails = Util.resolveServerDetails( from, fromFormat );
		} catch( cfconfigException var e ) {
			error( e.message, e.detail ?: '' );
		}
			
		if( !fromDetails.path.len() ) {
			error( "The location for the server couldn't be determined.  Please check your spelling." );
		}
		
		if( !directoryExists( fromDetails.path ) && !fileExists( fromDetails.path ) ) {
			error( "The CF Home directory for the server doesn't exist.  [#fromDetails.path#]" );				
		}
		
		var oConfig = CFConfigService.determineProvider( fromDetails.format, fromDetails.version )
			.read( fromDetails.path );
		
		// Displaying a single property
		if( property.len() ) {
			var validProperties = oConfig.getConfigProperties();
			if( !validProperties.findNoCase( property ) ) {
				error( "[#property#] is not a valid property" );
			}
			var result = oConfig[ 'get#property#' ]();
			if( isNull( result ) ) {
				error( "Configuration for [#property#] doesn't exist in this server" );
			}
			print.line( result );
		// Displaying all properties
		} else {
			print.line( oConfig.toString() );
		}
	}
	
}