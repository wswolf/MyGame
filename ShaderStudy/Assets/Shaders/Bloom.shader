Shader "YuriStudy/Bloom"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
		_Bloom("Bloom",2D) = "white"{}
		_BlurSize("Blur Size",Float) = 1.0
		_LuminanceThreshold("Luminance Threshold",Float) = 1.0
	}
	SubShader
	{
		CGINCLUDE
	#include "UnityCG.cginc"
		uniform sampler2D _MainTex;
		float4 _MainTex_TexelSize;
		uniform sampler2D _Bloom;
		uniform float _BlurSize;
		uniform float _LuminanceThreshold;

		struct v2f {
			float4 pos:SV_POSITION;
			half4 uv:TEXCOORD0;
		};

		v2f vert(appdata_img v)
		{
			v2f o;
			o.pos = UnityObjectToClipPos(v.vertex);
			o.uv = half4(v.texcoord, 1.0, 1.0);
			return o;
		}

		fixed luminance(fixed4 col)
		{
			return dot(col.rgb,fixed3(0.2125,0.7154,0.0721));
		}

		fixed4 frag(v2f i):SV_Target
		{
			fixed4 c = tex2D(_MainTex,i.uv.xy);
			fixed val = clamp(luminance(c)-_LuminanceThreshold,0.0,1.0);
			return c*val;
		}

		v2f vertBloom(appdata_img v)
		{
			v2f o;
			o.pos = UnityObjectToClipPos(v.vertex);
			o.uv = half4(v.texcoord, v.texcoord);

#if UNITY_UV_STARTS_AT_TOP
			if (_MainTex_TexelSize.y < 0)
				o.uv.w = 1.0 - o.uv.w;
#endif
			return o;
		}
		fixed4 fragBloom(v2f i):SV_Target
		{
			fixed4 col = tex2D(_MainTex,i.uv.xy);
			fixed4 colBloom = tex2D(_Bloom, i.uv.zw);
			return col + colBloom;
		}
		ENDCG
		
		ZTest Always
		ZWrite Off
		Cull Off
		pass
		{
			CGPROGRAM
#pragma vertex vert
#pragma fragment frag
			ENDCG
		}
		UsePass "YuriStudy/GuassianBlur/GAUSSIAN_BLUR_VERTICAL"
		UsePass "YuriStudy/GuassianBlur/GAUSSIAN_BLUR_HORZONTAL"
		pass
		{
			CGPROGRAM
#pragma vertex vertBloom
#pragma fragment fragBloom
			ENDCG
		}
    }
}
