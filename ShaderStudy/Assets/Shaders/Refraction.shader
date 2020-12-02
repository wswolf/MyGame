Shader "YuriStudy/Refraction"
{
    Properties
    {
        _Color("Color Tint",Color)=(1,1,1,1)
		_Refraction("Refract Color",Color)=(1,1,1,1)
		_RefractAmount("Refract Amount",Range(0,1))=1
		_RefracRation("Refraction Ration",float)=0.5
		_CubrMap("Cube Map",Cube)="_SkyBox"{}
	}
		SubShader
	{
		Tags { "RenderType" = "Opaque" "Queue" = "Geometry"}

		Pass
		{
			Tags{"LightMode" = "ForwardBase"}
			LOD 100
			CGPROGRAM
#pragma multi_compile_fwdbase
#pragma vertex vert
#pragma fragment frag
#include "AutoLight.cginc"
#include "Lighting.cginc"

			fixed4 _Color;
			fixed4 _Refraction;
			fixed _RefractAmount;
			fixed _RefracRation;
			samplerCUBE _CubrMap;

			struct appdata
			{
				float4 vertex:POSITION;
				float3 normal:NORMAL;
			};
			struct v2f 
			{
				float4 pos:SV_POSITION;
				float3 worldNormal:TEXCOORD0;
				float3 worldPos:TEXCOORD1;
				float3 worldViewDir:TEXCOORD2;
				float3 worldRefract:TEXCOORD3;
				SHADOW_COORDS(4)
			};
			v2f vert(appdata v)
			{
				v2f o;
				o.pos = UnityObjectToClipPos(v.vertex);
				o.worldNormal = UnityObjectToWorldNormal(v.normal);
				o.worldPos = mul(unity_ObjectToWorld, v.vertex);
				o.worldViewDir = UnityWorldSpaceViewDir(o.worldPos);
				o.worldRefract = refract(normalize(-o.worldViewDir),normalize(o.worldNormal),_RefracRation);
				TRANSFER_SHADOW(o);
				return o;
			}
			fixed4 frag(v2f i):SV_Target
			{
				fixed3 worldNormal = normalize(i.worldNormal);
				fixed3 worldLight = normalize(UnityWorldSpaceLightDir(i.worldPos));
				fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz;
				fixed3 diffuse = _LightColor0.rgb*_Color.rgb*max(0, dot(worldNormal,worldLight));
				fixed3 refraction = texCUBE(_CubrMap, i.worldRefract).rgb*_Refraction.rgb;
				UNITY_LIGHT_ATTENUATION(atten, i, i.worldPos);
				fixed3 target = ambient + lerp(diffuse, refraction, _RefractAmount)*atten;
				return fixed4(target, 1.0);
			}
			ENDCG
        }
    }
}
