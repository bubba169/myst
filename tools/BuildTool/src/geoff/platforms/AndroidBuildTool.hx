package geoff.platforms;
import geoff.helpers.TemplateHelper;
import sys.FileSystem;
import sys.io.File;
import geoff.helpers.DirectoryHelper;
import sys.io.Process;

/**
 * ...
 * @author Simon
 */
class AndroidBuildTool
{
	var projectDirectory : String;
	var binDirectory : String;
	var flags : Array<String>;
	var config : Dynamic;
	var versionCode : String;

	
	public function new( dir : String, flags : Array<String>, config : Dynamic, versionCode : String )
	{		
		this.projectDirectory = dir;
		this.flags = flags;
		this.config = config;
		this.binDirectory = projectDirectory + "bin/android/";
		this.versionCode = versionCode;
	}
	
	
	public function clean() : Int
	{
		if ( FileSystem.exists( projectDirectory + "build.hxml" ) ) FileSystem.deleteFile( projectDirectory + "build.hxml" );
			
		// clean any old builds
		if ( FileSystem.exists( binDirectory ) ) 
		{
			trace("Cleaning " + binDirectory );
			DirectoryHelper.removeDirectory( binDirectory );
		}
		
		return 0;
	}
	
	
	public function update( ) : Int
	{
		
		var buildHXML = "";
		var srcArray : Array<String> = config.project.src;
		for ( dir in srcArray ) {
			buildHXML += "-cp " + dir + "\n";
		}
		
		var libArray : Array<String> = config.project.haxelib;
		for ( lib in libArray ) {
			buildHXML += "-lib " + lib + "\n";
		}
		
		buildHXML += "-java bin/android/build\n";
		buildHXML += "-java-lib " + config.global.android.sdkpath + "platforms/android-" + config.project.android.version + "/android.jar\n";
		buildHXML += "-java-lib " + config.geoffpath + "template/android/libs/jorbis-oggdecoder-1.1.jar\n";
		buildHXML += "-D java-android\n";
		buildHXML += "-main " + config.project.main + "\n";
		
		if ( isDebugBuild() ) {
			buildHXML += "-debug\n";
		}
		
		buildHXML += "-D android\n";
		buildHXML += "-D geoff_java\n";
		buildHXML += "-D mobile\n";
		
		var defineArray : Array<String> = config.project.defines;
		for ( define in defineArray ) 
		{
			buildHXML += "-D " + define + "\n";
		}
		
		File.saveContent(  projectDirectory + "build.hxml", buildHXML );
		
		return 0;
	}
	
	
	public function build( ) : Int
	{
		var templateConstants = 
		[
			"Package" => config.project.packagename,
			"Main" => config.project.main,
			"VersionCode" => versionCode,
			"Version" => config.project.version,
			"ProjectName" => config.project.name,
			"AndroidSDKPath" => StringTools.replace(config.global.android.sdkpath, "\\", "\\\\" ),
			"AndroidSDKVersion" => config.project.android.version,
			"Orientation" => "sensor"
		];	
		
		if ( config.project.window.orientation == "landscape" )
		{
			templateConstants.set( "Orientation", "sensorLandscape" );
		}
		else if ( config.project.window.orientation == "portrait" )
		{
			templateConstants.set( "Orientation", "sensorPortrait" );
		}	
		
		trace("Looking for key", config.project.android.key );
		
		if ( config.project.android.key != null )
		{
			trace("Using release key");
			templateConstants.set( "AndroidKeyFile", config.project.android.key.file );
			templateConstants.set( "AndroidKeyPassword", config.project.android.key.keypass );
			templateConstants.set( "AndroidKeyAlias", config.project.android.key.alias );
			templateConstants.set( "AndroidKeyAliasPassword", config.project.android.key.aliaspass );
		}
		
		if ( flags.indexOf( "clean" ) > -1 ) {
			clean();
		}
		
		// Make the directory
		FileSystem.createDirectory( binDirectory + "project" );
		
		//Copy template files
		DirectoryHelper.copyDirectory( config.geoffpath + "template/android/", binDirectory + "project/" );
		
		trace("Processing templates");
		
		//Fill in values
		TemplateHelper.processTemplates( binDirectory + "project/", templateConstants );
		
		//Compile project to java
		if ( compileHaxe( ) != 0 )
		{
			trace("Haxe Compilation could not be completed!");
			return -1;
		}
		
		copyLibs( );
		copyAssets( );
		
		compileAndroid( );
		
		return 0;
		
	}
	
	
	function compileHaxe( ) : Int
	{
		Sys.setCwd( projectDirectory );
		return Sys.command( "haxe", [ "build.hxml"] );
	}
	
	function copyAssets( )
	{		
		trace("Looking for assets in " + config.project.haxelib );
		
		var libArray : Array<String> = config.project.haxelib;
		for ( lib in libArray ) {
			var libdir_assets = DirectoryHelper.getHaxelibDir(lib) + "assets";
			
			trace("Looking for assets in " + libdir_assets );
			
			if ( FileSystem.exists( libdir_assets ) && FileSystem.isDirectory( libdir_assets ) )
			{
				DirectoryHelper.copyDirectory( libdir_assets + "/", binDirectory + "/project/assets/" );
			}
		}
		
		if ( FileSystem.exists( projectDirectory + "assets" ) )
		{
			DirectoryHelper.copyDirectory( projectDirectory + "assets/", binDirectory + "/project/assets/" );
		}
		
		if ( config.project.android.key != null && FileSystem.exists( projectDirectory + "cert/" + config.project.android.key.file ) )
		{
			File.copy( projectDirectory + "cert/" + config.project.android.key.file, binDirectory + "/project/" + config.project.android.key.file );
		}
	}
	
	function copyLibs( ) : Void
	{
		var jarName : String = config.project.main;
		if ( jarName.indexOf(".") > -1 ) 
		{
			jarName = jarName.substr( jarName.lastIndexOf(".") + 1 );
		}
		if ( isDebugBuild() ) jarName += "-Debug";
		jarName += ".jar";
		FileSystem.createDirectory( binDirectory + "project/libs" );
		File.copy( binDirectory + "build/" + jarName, binDirectory + "/project/libs/" + jarName );
	}
	
	function compileAndroid( ) : Void 
	{
		var antDirectory = projectDirectory + "bin/android/project";
		trace("Running ant in " + antDirectory );
		
		Sys.setCwd( antDirectory );
		if ( isDebugBuild() )
		{
			Sys.command( config.global.android.antpath + "/bin/ant", [ "debug", "install" ] );
		}
		else
		{
			Sys.command( config.global.android.antpath + "/bin/ant", [ "release", "install" ] );
		}
	}	
	
	function isDebugBuild() : Bool
	{
		return flags.indexOf("debug") > -1;
	}
	
	public function run( ) : Int
	{
		return 0;
	}

}