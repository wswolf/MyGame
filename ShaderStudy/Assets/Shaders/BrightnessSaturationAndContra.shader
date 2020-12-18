Shader "YuriStudy/BrightnessSaturationAndContra"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
		_Brightness("Brightness",float) = 1
		_Saturation("Saturation",float) = 1
		_Contrast("Contrast",float) = 1
	}
		SubShader
		{
			LOD 100
			ZTest Always
			Cull Off
			ZWrite Off
			Pass
			{
				CGPROGRAM
	#pragma vertex vert
	#pragma fragment frag
	#include "UnityCG.cginc"

				sampler2D _MainTex;
				uniform half _Brightness;
				uniform half _Saturation;
				uniform half _Contrast;

				struct appdata
				{
					float4 vertex:POSITION;
					half2 texcoord:TEXCOORD0;
				};
				struct v2f 
				{
					float4 pos:SV_POSITION;
					half2 uv:TEXCOORD0;
				};
				v2f vert(appdata v)
				{
					v2f o;
					o.pos = UnityObjectToClipPos(v.vertex);
					o.uv = v.texcoord;
					return o;
				}
				fixed4 frag(v2f i):SV_Target
				{
					fixed4 mainTexture = tex2D(_MainTex,i.uv);
					fixed3 finalColor = mainTexture.rgb * _Brightness;

					fixed luminance = 0.2125*mainTexture.r + 0.7154*mainTexture.b + 0.0721*mainTexture.b;
					fixed3 luminanceColor = fixed3(luminance, luminance, luminance);
					finalColor = lerp(luminanceColor, finalColor, _Saturation);

					fixed3 avgColor = fixed3(0.5, 0.5, 0.5);
					finalColor = lerp(avgColor, finalColor, _Contrast);

					return fixed4(finalColor, mainTexture.a);
				}
			ENDCG
		}
    }
}
