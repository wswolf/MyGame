Shader "YuriStudy/MotionBlurWithDepth"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
		_BlurSize("Blur Size",Float) = 1.0
	}
	SubShader
	{
		Tags{}
		CGINCLUDE
	#include "UnityCG.cginc"
		sampler2D _MainTex;
		float4 _MainTex_TexelSize;
		sampler2D _CameraDepthTexture;
		float4x4 _PreVPMarix;
		float4x4 _CurVPMarixInverse;
		float _BlurSize;

		struct appdata
		{
			float4 vertex:POSITION;
			half2 texcoord:TEXCOORD0;
		};
		struct v2f
		{
			float4 pos:SV_POSITION;
			half2 uv:TEXCOORD0;
			half2 uv_Depth:TEXCOORD1;
		};
		v2f vert(appdata v)
		{
			v2f o;
			o.pos = UnityObjectToClipPos(v.vertex);
			o.uv = v.texcoord;
			o.uv_Depth = v.texcoord;
#if UNITY_UV_STARTS_AT_TOP
			if (_MainTex_TexelSize.y < 0)
				o.uv_Depth.y = 1 - o.uv_Depth.y;
#endif
			return o;
		}

		fixed4 frag(v2f i):SV_Target
		{
			float depth = SAMPLE_DEPTH_TEXTURE(_CameraDepthTexture,i.uv_Depth);
			float4 H = float4(i.uv * 2 - 1, depth * 2 - 1, 1);
			float4 worldPos = mul(_CurVPMarixInverse,H);
			worldPos = worldPos / worldPos.w;
			float4 curPos = H;
			float4 prePos = mul(_PreVPMarix,worldPos);
			prePos = prePos / prePos.w;
			float2 velocity = (curPos.xy - prePos.xy) / 2.0;
			half2 uv = i.uv;
			fixed4 col = tex2D(_MainTex, uv);
			uv = uv + velocity * _BlurSize;
			col += tex2D(_MainTex, uv);
			uv = uv + velocity * _BlurSize;
			col += tex2D(_MainTex, uv);
			col /= 3;
			return fixed4(col.rgb, 1.0);
		}
		ENDCG
		pass
		{
			ZTest Always
			Cull Off
			ZWrite Off
			CGPROGRAM
#pragma vertex vert
#pragma fragment frag
			ENDCG
		}
    }
	FallBack Off
}
