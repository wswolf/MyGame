Shader "YuriStudy/Dissolve"
{
    Properties
    {
        _MainTex("Color Tint",2D)="white" {}
        _BlurAmount("Blur Amount",Range(0.0,1.0))=0.3
        _Bump("Bump",2D)="white"{}
        _BlurMap("Blur Map",2D)="white"{}
        _LineWidth("LineWidth",Range(0.0,0.3))=0.15
        _BlurFirstColor("BlurFirstColor",Color)=(1,0,0,1)
        _BlurSecondColor("BlurSecondColor",Color)=(1,0,0,1)
    }

    SubShader
    {
        Tags{"Queue"="Geometry" "RenderType"="Opaque"}
        LOD 200
        Pass
        {
            Tags{"LightMode"="ForwardBase"}
            Cull Off

            CGPROGRAM
            #include "UnityCG.cginc"
            #include "AutoLight.cginc"
            #include "Lighting.cginc"

            sampler2D _MainTex;
            fixed4 _MainTex_ST;
            float _BlurAmount;
            sampler2D _Bump;
            float4 _Bump_ST;
            sampler2D _BlurMap;
            float4 _BlurMap_ST;
            float _LineWidth;
            fixed4 _BlurFirstColor;
            fixed4 _BlurSecondColor;

            #pragma vertex vert
            #pragma fragment frag
            #pragma multi_compile_fwdbase

            struct a2f
            {
                float4 vertex:POSITION;
                float3 normal:NORMAL;
                float3 tangent:TANGENT;
                half2 texcoord:TEXCOORD0;
            };

            struct v2f
            {
                float4 pos:SV_POSITION;
                half2 bumpUV:TEXCOORD0;
                half2 blurMapUV:TEXCOORD1;
                //float3 tanNormal:TEXCOORD2;
                float3 tanLightDir:TEXCOORD3;
                float3 worldPos:TEXCOORD2;
                half2 uv:TEXCOORD5;
                SHADOW_COORDS(4)
            };

            v2f vert(a2f v)
            {
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);
                float3 binormal=cross(normalize(v.normal),normalize(v.tangent.xyz));
                float3x3 rotation=float3x3(v.tangent.xyz,binormal,v.normal);
                // or TANGENT_SPACE_ROTATION
                o.tanLightDir=mul(rotation,ObjSpaceLightDir(v.vertex));

                o.bumpUV=TRANSFORM_TEX(v.texcoord,_Bump);
                o.blurMapUV=TRANSFORM_TEX(v.texcoord,_BlurMap);
                o.uv=TRANSFORM_TEX(v.texcoord,_MainTex);
                o.worldPos = mul(unity_ObjectToWorld,v.vertex);
                TRANSFER_SHADOW(o);
                return o;
            }

            fixed4 frag(v2f i):SV_Target
            {
                fixed3 burn=tex2D(_BlurMap,i.blurMapUV).rgb;
                clip(burn.r-_BlurAmount);

                fixed3 albedo=tex2D(_MainTex,i.uv).rgb;

                fixed3 ambient=UNITY_LIGHTMODEL_AMBIENT.xyz*albedo;

                float3 tanNormal=UnpackNormal(tex2D(_Bump,i.bumpUV));
                float3 lightDir = normalize(i.tanLightDir);

                fixed3 diffuse = _LightColor0.rgb*albedo*max(0,dot(lightDir,tanNormal));

                UNITY_LIGHT_ATTENUATION(atten,i,i.worldPos);
                fixed3 baseCol = ambient+diffuse*atten;

                fixed t=smoothstep(0.0,_LineWidth,burn.r-_BlurAmount);
                fixed4 burnCol=lerp(_BlurFirstColor,_BlurSecondColor,1-t);

                burnCol = pow(burnCol,5);
                fixed4 finalcolor=lerp(fixed4(baseCol,1.0),burnCol,1-t);
                return finalcolor;
            }
            ENDCG
        }

        Pass
        {
            Tags{"LightMode"="ShadowCaster"}
            CGPROGRAM
            #pragma vertex vertShadowCaster
            #pragma fragment fragShadowCaster

            #pragma multi_compile_shadowcaster
            #include "UnityCG.cginc"

            float _BlurAmount;
            sampler2D _BlurMap;
            float4 _BlurMap_ST;
            struct v2f
            {
                V2F_SHADOW_CASTER;
                half2 uvBlurMap:TEXCOORD0;
            };

            v2f vertShadowCaster(appdata_base v)
            {
                v2f o;
                o.uvBlurMap=v.texcoord;
                TRANSFER_SHADOW_CASTER_NORMALOFFSET(o)
                return o;
            }
            fixed4 fragShadowCaster(v2f i):SV_Target
            {
                fixed4 burn=tex2D(_BlurMap,i.uvBlurMap);
                clip(burn.r-_BlurAmount);
                SHADOW_CASTER_FRAGMENT(i)
            }
            ENDCG
        }
    }
    //FallBack "Diffuse"
}
