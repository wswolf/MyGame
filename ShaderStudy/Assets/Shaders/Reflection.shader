Shader "YuriStudy/Reflection"
{
	Properties
	{
		_Color("color Tint",Color) = (1,1,1,1)
		_Reflection("Reflect Color",Color) = (1,1,1,1)
		_ReflectAmount("Reflect Amount",Range(0,1)) =1
		_CubeMap("Cuba Map",Cube) = "_SkyBox"{}
    }
    SubShader
    {
		Tags{"RenderType"="Opaque" "Queue"="Geometry"}
		pass
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
			fixed4 _Reflection;
			fixed _ReflectAmount;
			samplerCUBE _CubeMap;
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
				float3 worldView:TEXCOORD2;
				float3 worldReflect:TEXCOORD3;
				SHADOW_COORDS(4)
			};
			v2f vert(appdata v)
			{
				v2f o;
				o.pos = UnityObjectToClipPos(v.vertex);
				o.worldNormal = UnityObjectToWorldNormal(v.normal);
				o.worldPos = mul(unity_ObjectToWorld,v.vertex);
				o.worldView = UnityWorldSpaceViewDir(o.worldPos);
				o.worldReflect = reflect(-o.worldView, o.worldNormal);
				TRANSFER_SHADOW(o);
				return o;
			}
			fixed4 frag(v2f i):SV_Target
			{
				fixed3 worldNormal = normalize(i.worldNormal);
				fixed3 worldLight = normalize(UnityWorldSpaceLightDir(i.worldPos));
				fixed3 worldView = normalize(i.worldView);
				fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz;
				fixed3 diffuse = _LightColor0.rgb*_Color.rgb*max(0, dot(worldNormal,worldLight));
				fixed3 reflect = texCUBE(_CubeMap, i.worldReflect).xyz*_Reflection.rgb;
				UNITY_LIGHT_ATTENUATION(atten, i, i.worldPos);
				//schlick Fresnel
				fixed fresnel = _ReflectAmount + (1 - _ReflectAmount)*pow(1-dot(worldView,worldNormal) , 5);
				fixed3 target = fixed3(ambient+lerp(diffuse,reflect,saturate(fresnel))*atten);
				return fixed4(target, 1.0);
			}
			ENDCG
		}
    }
}
