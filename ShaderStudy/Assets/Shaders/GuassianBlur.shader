Shader "YuriStudy/GuassianBlur"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
		_BlurSize("Blur Size",Float) = 1.0
	}
	SubShader
	{
		CGINCLUDE
	#include "UnityCG.cginc"
		uniform sampler2D _MainTex;
		float4 _MainTex_TexelSize;
		uniform float _BlurSize;

		struct v2f
		{
			float4 pos:SV_POSITION;
			half2 uv[5]:TEXCOORD0;
		};
		v2f vertVertical(appdata_img v)
		{
			v2f o;
			o.pos = UnityObjectToClipPos(v.vertex);
			o.uv[0] = v.texcoord;
			o.uv[1] = o.uv[0] + half2(0.0, _MainTex_TexelSize.y*1.0)*_BlurSize;
			o.uv[2] = o.uv[0] + half2(0.0, _MainTex_TexelSize.y*-1.0)*_BlurSize;
			o.uv[3] = o.uv[0] + half2(0.0, _MainTex_TexelSize.y*2.0)*_BlurSize;
			o.uv[4] = o.uv[0] + half2(0.0, _MainTex_TexelSize.y*-2.0)*_BlurSize;
			return o;
		}
		v2f vertHorzontal(appdata_img v)
		{
			v2f o;
			o.pos = UnityObjectToClipPos(v.vertex);
			o.uv[0] = v.texcoord;
			o.uv[1] = o.uv[0] + half2(_MainTex_TexelSize.x*1.0,0.0)*_BlurSize;
			o.uv[2] = o.uv[0] + half2(_MainTex_TexelSize.x*-1.0,0.0)*_BlurSize;
			o.uv[3] = o.uv[0] + half2(_MainTex_TexelSize.x*2.0,0.0)*_BlurSize;
			o.uv[4] = o.uv[0] + half2(_MainTex_TexelSize.x*-2.0,0.0)*_BlurSize;
			return o;
		}
		fixed4 frag(v2f i):SV_Target
		{
			float kernel[3] = {0.4026,0.2442,0.0545};
			fixed3 sum = tex2D(_MainTex, i.uv[0]).rgb*kernel[0];
			sum += tex2D(_MainTex, i.uv[1]).rgb*kernel[1];
			sum += tex2D(_MainTex, i.uv[2]).rgb*kernel[1];
			sum += tex2D(_MainTex, i.uv[3]).rgb*kernel[2];
			sum += tex2D(_MainTex, i.uv[4]).rgb*kernel[2];
			return fixed4(sum, 1.0);
		}
		ENDCG

		ZTest Always
		Cull Off
		ZWrite Off
		pass
		{
			NAME "GAUSSIAN_BLUR_VERTICAL"
				CGPROGRAM
#pragma vertex vertVertical
#pragma fragment frag
				ENDCG
		}
		pass
		{
			NAME "GAUSSIAN_BLUR_HORZONTAL"
				CGPROGRAM
#pragma vertex vertHorzontal
#pragma fragment frag
				ENDCG
		}
    }
}
