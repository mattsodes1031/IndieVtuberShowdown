package;

import openfl.filters.ShaderFilter;

class ShadersHandler
{
	public static var colorDistortion:ShaderFilter;
	
	public static function createChrome():Void
	{
		colorDistortion = new ShaderFilter(new ColorDistortion());
	}
	
	public static function setChrome(chromeOffset:Float):Void
	{
		colorDistortion.shader.data.rOffset.value = [chromeOffset];
		colorDistortion.shader.data.gOffset.value = [0.0];
		colorDistortion.shader.data.bOffset.value = [chromeOffset * -1];
	}
}