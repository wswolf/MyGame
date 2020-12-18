Shader "YuriStudy/EdgeDetectShader"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
		_EdgeOnly("EdgeOnly",Float) = 1.0
		_EdgeColor("Edge Color",Color) = (1,1,1,1)
		_bgColor("Background Color",Color) = (0,0,0,1)
	}
	SubShader
	{
		Pass
		{
		ZTest Always
		ZWrite Off
		Cull Off

		CGPROGRAM
	#pragma vertex vert
	#pragma fragment frag
	#include "UnityCG.cginc"

		sampler2D _MainTex;
		uniform half4 _MainTex_TexelSize;
		uniform half _EdgeOnly;
		fixed4 _EdgeColor;
		fixed4 _bgColor;

		struct app_data
		{
			float4 vertex:POSITION;
			float4 texcoord:TEXCOORD0;
		};

		struct v2f
		{
			float4 pos : SV_POSITION;
			half2 uv[9]:TEXCOORD0;
		};

		v2f vert(app_data v)
		{
			v2f o;
			o.pos = UnityObjectToClipPos(v.vertex);
			half2 uv = v.texcoord;
			o.uv[0] = uv + _MainTex_TexelSize.xy*half2(-1, -1);
			o.uv[1] = uv + _MainTex_TexelSize.xy*half2(0, -2);
			o.uv[2] = uv + _MainTex_TexelSize.xy*half2(1, -1);
			o.uv[3] = uv + _MainTex_TexelSize.xy*half2(-2, 0);
			o.uv[4] = uv + _MainTex_TexelSize.xy*half2(0, 0);
			o.uv[5] = uv + _MainTex_TexelSize.xy*half2(2, 0);
			o.uv[6] = uv + _MainTex_TexelSize.xy*half2(-1, 1);
			o.uv[7] = uv + _MainTex_TexelSize.xy*half2(0, 2);
			o.uv[8] = uv + _MainTex_TexelSize.xy*half2(1, 1);
			return o;
		}

		fixed lumiance(fixed3 c)
		{
			return dot(c,fixed3(0.2125,0.7154,0.0721));
		}
		fixed Sobel(v2f i)
		{
			const half Gx[9] = { -1,0,-1,-2,0,2,1,0,1 };
			const half Gy[9] = { -1,-2,-1,0,0,0,1,2,1 };
			fixed edge;
			half edgeX = 0;
			half edgeY = 0;
			for (int it = 0; it < 9; it++)
			{
				edge = lumiance(tex2D(_MainTex, i.uv[it]));
				edgeX = edgeX + edge * Gx[it];
				edgeY = edgeY + edge * Gy[it];
			}
			edge = 1 - abs(edgeX) - abs(edgeY);
			return edge;
		}
		fixed4 frag(v2f i) :SV_Target
		{
			fixed edge = Sobel(i);
			fixed4 withEdgeColor = lerp(_EdgeColor,tex2D(_MainTex,i.uv[4]),edge);
			fixed4 onlyEdgeColor = lerp(_EdgeColor, _bgColor, edge);
			return lerp(withEdgeColor, onlyEdgeColor, _EdgeOnly);
		}
		ENDCG
			}
    }
	FallBack Off
}
