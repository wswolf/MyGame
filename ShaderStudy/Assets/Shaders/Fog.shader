Shader "YuriStudy/Fog"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
		_FogDensity("Fog Density",Float) = 1.0
		_FogColor("Fog Color", Color) = (1,1,1,1)
		_FogStart("Fog start",Float) = 0.0
		_FogEnd("Fog End",Float) = 2.0
	}
	SubShader
	{
		CGINCLUDE
	#include "UnityCg.cginc"
		sampler2D _MainTex;
		float4 _MainTex_TexelSize;
		sampler2D _CameraDepthTexture;
		float _FogDensity;
		float _FogStart;
		float _FogEnd;
		fixed4 _FogColor;
		float4x4 _FrustumCornersRay;

		struct appdata
		{
			float4 vertex:POSITION;
			half2 texcoord:TEXCOORD0;
		};
		struct v2frag
		{
			float4 pos:SV_POSITION;
			half2 uv:TEXCOORD0;
			half2 uv_depth:TEXCOORD1;
			float4 interpolatedRay:TEXCOORD2;
		};
		v2frag vert(appdata v)
		{
			v2frag o;
			o.pos = UnityObjectToClipPos(v.vertex);
			o.uv = v.texcoord;
			o.uv_depth = v.texcoord;
			int index = 0;
			if (v.texcoord.x<0.5 && v.texcoord.y>0.5)
			{
				index = 0;
			}
			else if (v.texcoord.x > 0.5 && v.texcoord.y > 0.5)
			{
				index = 1;
			}
			else if (v.texcoord.x > 0.5 && v.texcoord.y < 0.5)
			{
				index = 2;
			}
			else
			{
				index = 3;
			}
#ifdef UNITY_UV_STARTS_AT_TOP
			if (_MainTex_TexelSize.y < 0)
				index = 3 - index;
#endif
			o.interpolatedRay = _FrustumCornersRay[index];
			return o;
		}
		fixed4 frag(v2frag i):SV_Target
		{
			float linearDepth = LinearEyeDepth(SAMPLE_DEPTH_TEXTURE(_CameraDepthTexture,i.uv_depth));
			float3 worldPos = _WorldSpaceCameraPos + linearDepth * i.interpolatedRay.xyz;
			float fogDensity = (_FogEnd - worldPos.y) / (_FogEnd - _FogStart);
			fogDensity = saturate(fogDensity*_FogDensity);
			fixed4 finalCol = tex2D(_MainTex, i.uv);
			fixed3 col = lerp(finalCol.rgb,_FogColor.rgb,fogDensity);
			return fixed4(col, finalCol.a);
		}
		ENDCG
		pass
		{
			ZTest Always
			ZWrite Off
			Cull Off
			CGPROGRAM
#pragma vertex vert
#pragma fragment frag
			ENDCG
		}
    }
	FallBack Off
}
