Shader "YuriStudy/NPR"
{
    Properties
    {
        _ColorTint("Color Tint",Color)=(1.0,1.0,1.0,1.0)
        _MainTex("Main Tex",2D)="white" {}
        _Bump("Bump",2D)="white"{}
        _OutLine("Outline",Float)=0.1
        _OutLineColor("Outline Color",Color)=(1.0,1.0,1.0,1.0)
        _SpecularCol("Specular Color",Color)=(1.0,1.0,1.0,1.0)
        _SpecularScale("Specular Scale",Range(0.0,0.1))=0.01
    }
    SubShader
    {
        Tags {"Queue"="Geometry" "RenderType"="Opaque"}
        Pass
        {
            Name "OUTLINE"
            Cull Front

            CGPROGRAM
            #include "UnityCG.cginc"

            float _OutLine;
            fixed4 _OutLineColor;

            #pragma vertex vert
            #pragma fragment frag
            struct a2v
            {
                float4 vertex:POSITION;
                float3 normal:NORMAL;
            };
            struct v2f
            {
                float4 pos:SV_POSITION;
            };

            v2f vert(a2v v)
            {
                v2f o;
                float4 worldPos = mul(UNITY_MATRIX_MV,v.vertex);
                float3 worldNormal = mul((float3x3)UNITY_MATRIX_IT_MV, v.normal);
                worldNormal.z=-0.5;
                worldPos=worldPos +float4(normalize(worldNormal),0.0)*_OutLine;
                o.pos = mul(UNITY_MATRIX_P, worldPos);
                return o;
            }
            fixed4 frag(v2f i):SV_Target
            {
                return fixed4(_OutLineColor.rgb,1.0);
            }
            ENDCG
        }

        Pass
        {
            Tags{"LightMode"="ForwardBase"}
            Cull Back
            CGPROGRAM
            #include "UnityCG.cginc"
            #include "Lighting.cginc"
            #include "AutoLight.cginc"

            fixed4 _ColorTint;
            sampler2D _MainTex;
            sampler2D _Bump;
            fixed4 _SpecularCol;
            half _SpecularScale;

            #pragma vertex vert
            #pragma fragment frag

            struct a2v
            {
                float4 vertex:POSITION;
                float3 normal:NORMAL;
                half2 texcoord:TEXCOORD0;
                float3 tangent:TANGENT;
            };
            struct v2f
            {
                float4 pos:SV_POSITION;
                half2 uv:TEXCOORD0;
                float3 worldNormal:TEXCOORD1;
                float3 worldPos:TEXCOORD2;
                TRANSFER_SHADOW(3)
            };

            v2f vert(a2v v)
            {
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);
                o.uv =v.texcoord;
                o.worldPos=mul(unity_ObjectToWorld,v.vertex);
                o.worldNormal=UnityObjectToWorldNormal(v.normal);
                return o;
            }
            fixed4 frag(v2f i):SV_Target
            {
                float3 worldNormal=normalize(i.worldNormal);
                float3 worldLightDir=normalize(UnityWorldSpaceLightDir(i.worldPos));
                float3 worldViewDir=normalize(UnityWorldSpaceViewDir(i.worldPos));
                float3 worldHalfDir=normalize(worldLightDir+worldViewDir);

                fixed3 albedo=tex2D(_MainTex,i.uv).rgb;
                albedo=albedo*_ColorTint.rgb;
                fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz*albedo;

                UNITY_LIGHT_ATTENUATION(atten,i,i.worldPos);
                fixed diff = dot(worldLightDir,worldNormal);
                diff = (diff*0.5+0.5)*atten;
                fixed3 diffuse=_LightColor0*albedo*tex2D(_Bump,half2(diff,diff)).rgb;

                fixed spec = dot(worldNormal,worldHalfDir);
                fixed w=fwidth(spec)*2.0;
                fixed3 specColor = _SpecularCol.rgb*lerp(0,1,smoothstep(-w,w,spec+_SpecularScale-1))*step(0.00001,_SpecularScale);
                return fixed4(ambient+diffuse+specColor,1.0);
            }
            ENDCG
        }
    }
}
