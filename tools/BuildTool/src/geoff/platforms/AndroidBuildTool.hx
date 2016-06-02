package geoff.platforms;
import geoff.helpers.TemplateHelper;
import sys.FileSystem;
import sys.io.File;
import geoff.helpers.DirectoryHelper;

/**
 * ...
 * @author Simon
 */
class AndroidBuildTool
{
	
	var projectDirectory : String;
	var flags : Array<String>;
	var config : Dynamic;
	var versionCode : String;

	public function new( dir : String, flags : Array<String>, config : Dynamic, versionCode : String )
	{
		this.projectDirectory = dir;
		this.flags = flags;
		this.config = config;
		this.versionCode = versionCode;
	}
		
	
	public function build( ) : Void
	{
		var binDirectory = projectDirectory + "bin/android/";
		var templateConstants = 
		[
			"Package" => config.project.packagename,
			"Main" => config.project.main,
			"VersionCode" => versionCode,
			"Version" => config.project.version,
			"ProjectName" => config.project.name,
			"AndroidSDKPath" => StringTools.replace(config.global.android.sdkpath, "\\", "\\\\" ),
			"AndroidSDKVersion" => config.project.android.version
		];	
		
		if ( flags.indexOf( "clean" ) > -1 ) {
			
		
		if ( FileSystem.exists( projectDirectory + "build.hxml" ) ) FileSystem.deleteFile( projectDirectory + "build.hxml" );
		
			// clean any old builds
			if ( FileSystem.exists( binDirectory ) ) 
			{
				trace("Cleaning " + binDirectory );
				DirectoryHelper.removeDirectory( binDirectory );
			}
			
			
		}
		
		// Make the directory
		FileSystem.createDirectory( binDirectory + "project" );
		
		//Copy template files
		DirectoryHelper.copyDirectory( config.geoffpath + "template/android/", binDirectory + "project/" );
		//DirectoryHelper.copyDirectory( config.geoffpath + "template/base/", binDirectory + "haxe/" );
		
		trace("Processing templates");
		
		//Fill in values
		TemplateHelper.processTemplates( binDirectory + "project/", templateConstants );
		//processTemplates( binDirectory + "haxe/", templateConstants );
		
		//Compile project to java
		compileHaxe( binDirectory + "build/" );
		
		//Copy lib to android template
		copyJar( binDirectory );
		copyAssets( binDirectory );
		
		//Compile with ant
		compileAndroid();
		
	}
		
	
	function compileHaxe( to : String )
	{
		
		var buildHXML = "";
		var srcArray : Array<String> = config.project.src;
		for ( dir in srcArray ) {
			buildHXML += "-cp " + dir + "\n";
		}
		buildHXML += "-cp " + config.geoffpath + "GeoffHaxe\n";
		var libArray : Array<String> = config.project.haxelib;
		for ( lib in libArray ) {
			buildHXML += "-lib " + lib + "\n";
		}
		buildHXML += "-java bin/android/build\n";
		buildHXML += "-java-lib " + config.global.android.sdkpath + "platforms/android-" + config.project.android.version + "/android.jar\n";
		buildHXML += "-D java-android\n";
		buildHXML += "-main " + config.project.main + "\n";
		
		if ( isDebugBuild() ) {
			buildHXML += "-debug\n";
		}
		
		buildHXML += "-D android\n";
		buildHXML += "-D geoff_java\n";
		buildHXML += "-D mobile\n";
		
		File.saveContent(  projectDirectory + "build.hxml", buildHXML );
		
		Sys.setCwd( projectDirectory );
		Sys.command( "haxe", [ "build.hxml"] );
		
	}
	
	
	function copyJar( binDirectory : String )
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
	
	function copyAssets( binDirectory : String )
	{
		if ( FileSystem.exists( projectDirectory + "assets" ) )
		{
			DirectoryHelper.copyDirectory( projectDirectory + "assets/", binDirectory + "/project/assets/" );
		}
	}
	
	
	function compileAndroid( )
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
}