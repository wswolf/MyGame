Shader "YuriStudy/Shadow"
{
	Properties
	{
		_Difuss("Difuss",Color) = (1,1,1,1)
		_Specular("Specular",Color) = (1,1,1,1)
		_Gloss("Gloss",Range(8.0,255)) = 20
	}
		SubShader
	{
		Tags { "RenderType" = "Opaque" }
		LOD 100

		Pass
		{
			Tags{"LightMode" = "ForwardBase"}
			CGPROGRAM
#pragma multi_compile_fwdbase
			#pragma vertex vert
			#pragma fragment frag

			#include "UnityCG.cginc"
			#include "AutoLight.cginc"
#include "Lighting.cginc"

			struct appdata
			{
				float4 vertex : POSITION;
				float3 normal : NORMAL;
			};

			struct v2f
			{
				float4 pos : SV_POSITION;
				float3 worldNormal:TEXCOORD0;
				float3 worldPos:TEXCOORD1;
				SHADOW_COORDS(2)
			};

			fixed4 _Difuss;
			fixed4 _Specular;
			float _Gloss;

			v2f vert(appdata v)
			{
				v2f o;
				o.pos = UnityObjectToClipPos(v.vertex);
				o.worldNormal = UnityObjectToWorldNormal(v.normal);
				o.worldPos = mul(unity_ObjectToWorld, v.vertex).xyz;
				TRANSFER_SHADOW(o)
				return o;
			}

			fixed4 frag(v2f i) : SV_Target
			{
				fixed3 worldNormal = normalize(i.worldNormal);
				fixed3 lightDir = normalize(_WorldSpaceLightPos0.xyz);
				fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz;
				fixed3 diffuse = (_LightColor0.rgb * _Difuss)*max(0, dot(worldNormal, lightDir));
				fixed3 viewDir = normalize(_WorldSpaceCameraPos.xyz - i.worldPos);
				fixed3 halfDir = normalize(viewDir + lightDir);
				fixed3 specular = (_LightColor0.rgb * _Specular)* pow(max(0,dot(worldNormal, halfDir)), _Gloss);
				fixed shadow = SHADOW_ATTENUATION(i);
				fixed atten = 1.0;
				return fixed4(ambient + (diffuse + specular)*atten*shadow, 1.0);
			}
			ENDCG
		}

		Pass
		{
			Tags{"LightMode" = "ForwardAdd"}
			Blend one one
			CGPROGRAM
#pragma multi_compile_fwdadd
#pragma vertex vert
#pragma fragment frag
#include "UnityCG.cginc"
#include "AutoLight.cginc"
#include "Lighting.cginc"
				struct appdata
			{
				float4 pos:POSITION;
				float3 normal:NORMAL;
};
			struct v2f
			{
				float4 pos:SV_POSITION;
				float3 worldNormal:TEXCOORD0;
				float3 worldPos:TEXCOORD1;
			};
			uniform fixed4 _Difuss;
			uniform fixed4 _Specular;
			uniform float _Gloss;
			v2f vert(appdata v)
			{
				v2f o;
				o.pos = UnityObjectToClipPos(v.pos);
				o.worldNormal = UnityObjectToWorldNormal(v.normal);
				o.worldPos = mul(unity_ObjectToWorld, v.pos).xyz;
				return o;
			}
			fixed4 frag(v2f i):SV_Target
			{
				fixed3 worldNormal = normalize(i.worldNormal);
#ifdef USING_DIRECTIONAL_LIGHT
			fixed3 worldLight = normalize(_WorldSpaceLightPos0.xyz);
#else
			fixed3 worldLight = normalize(_WorldSpaceLightPos0.xyz - i.worldPos);
#endif
			fixed3 diffuse = _LightColor0.rgb * _Difuss * max(0, dot(worldNormal,worldLight));
			fixed3 viewDir = normalize(_WorldSpaceCameraPos.xyz - i.worldPos);
			fixed3 halfDir = normalize(worldLight + viewDir);
			fixed3 specular = _LightColor0.rgb*_Specular*pow(max(0, dot(worldNormal,halfDir)),_Gloss);
#ifdef USING_DIRECTIONAL_LIGHT
			fixed atten = 1.0;
#else
#if defined (POINT)
			float3 lightcoord = mul(unity_WorldToLight, float4(i.worldPos, 1.0)).xyz;
			fixed atten= tex2D(_LightTexture0, dot(lightcoord,lightcoord).rr).UNITY_ATTEN_CHANNEL;
#elif defined (SPOT)
			float4 lightcoord = mul(unity_WorldToLight, float4(i.worldPos, 1.0));
			fixed atten = (lightcoord.z > 0)*tex2D(_LightTexture0, lightcoord.xy / lightcoord.w + 0.5).w*tex2D(_LightTextureB0, dot(lightcoord, lightcoord).rr).UNITY_ATTEN_CHANNEL;
#else
			fixed atten = 1.0;
#endif
#endif
			//fixed atten = 1.0;
			//atten and shadow
			//UNITY_LIGHT_ATTENUATION(atten, i, i.worldPos);
			return fixed4((diffuse + specular)*atten, 1.0);
			}
			ENDCG
		}
	}
	FallBack "Legacy Shaders/VertexLit"
}
