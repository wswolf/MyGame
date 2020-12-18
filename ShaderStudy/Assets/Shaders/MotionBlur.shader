Shader "YuriStudy/MotionBlur"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
		_BlurAmount("Blur Amount",Float) = 0.5
	}
		SubShader
		{
			CGINCLUDE
	#include "UnityCG.cginc"

			uniform sampler2D _MainTex;
		float _BlurAmount;

		struct v2f
		{
			float4 pos:SV_POSITION;
			half2 uv:TEXCOORD0;
		};
		v2f vert(appdata_img v)
		{
			v2f o;
			o.pos = UnityObjectToClipPos(v.vertex);
			o.uv = v.texcoord;
			return o;
		}
		fixed4 fragRBG(v2f i):SV_Target
		{
			fixed3 col = tex2D(_MainTex, i.uv).rgb;
			return fixed4(col, _BlurAmount);
		}
		fixed4 fragA(v2f i):SV_Target
		{
			return tex2D(_MainTex,i.uv);
		}
		ENDCG
        pass
		{
			Blend SrcAlpha OneMinusSrcAlpha
			ColorMask RBG
			CGPROGRAM
#pragma vertex vert
#pragma fragment fragRBG
            ENDCG
		}
		pass
		{
			Blend One Zero
			ColorMask A
			CGPROGRAM
#pragma vertex vert
#pragma fragment fragA
			ENDCG
		}
    }
}
