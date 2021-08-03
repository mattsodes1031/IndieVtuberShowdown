package;

#if sys
import Sys.sleep;
#end
#if discord_rpc
import discord_rpc.DiscordRpc;
#end

using StringTools;

class DiscordClient
{
	public function new()
	{
		#if discord_rpc
		trace("Discord Client starting...");
		DiscordRpc.start({
			clientID: haxe.crypto.Base64.decode(DiscordStrings.discordClientID).toString(), // change this to what ever the fuck you want lol
			onReady: onReady,
			onError: onError,
			onDisconnected: onDisconnected
		});
		trace("Discord Client started.");

		while (true)
		{
			DiscordRpc.process();
			#if sys
			sleep(2);
			#end
			//trace("Discord Client Update");
		}

		DiscordRpc.shutdown();
		#end
	}

	static function onReady()
	{
		#if discord_rpc
		DiscordRpc.presence({
			details: DiscordStrings.idlePresence,
			state: null,
			largeImageKey: 'icon',
			largeImageText: DiscordStrings.windowTitle + " Version " + CurrentVersion.get()
		});
		#end
	}

	static function onError(_code:Int, _message:String)
	{
		#if discord_rpc
		trace('Error! $_code : $_message');
		#end
	}

	static function onDisconnected(_code:Int, _message:String)
	{
		#if discord_rpc
		trace('Disconnected! $_code : $_message');
		#end
	}

	public static function initialize()
	{
		#if discord_rpc
		var DiscordDaemon = sys.thread.Thread.create(() ->
		{
			new DiscordClient();
		});
		trace("Discord Client initialized");
		#end
	}

	public static function changePresence(details:String, state:Null<String>, ?smallImageKey : String, ?hasStartTimestamp : Bool, ?endTimestamp: Float)
	{
		#if discord_rpc
		var startTimestamp:Float = if(hasStartTimestamp) Date.now().getTime() else 0;

		if (endTimestamp > 0)
		{
			endTimestamp = startTimestamp + endTimestamp;
		}

		DiscordRpc.presence({
			details: details,
			state: state,
			largeImageKey: 'icon',
			largeImageText: DiscordStrings.windowTitle + " Version " + CurrentVersion.get(),
			smallImageKey : smallImageKey,
			// Obtained times are in milliseconds so they are divided so Discord can use it
			startTimestamp : Std.int(startTimestamp / 1000),
            endTimestamp : Std.int(endTimestamp / 1000)
		});

		//trace('Discord RPC Updated. Arguments: $details, $state, $smallImageKey, $hasStartTimestamp, $endTimestamp');
		#end
	}
}