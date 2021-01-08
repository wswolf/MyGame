Shader "YuriStudy/Hatching"
{
    Properties
    {
        _ColorTint("Color Tint",Color)=(1.0,1.0,1.0,1.0)
        _TileFactor("Tile Factor",Float)=1.0
        _OutLine("Out Line",Float)=1.0
        _OutColor("Out Color",Color)=(0.0,0.0,0.0,1.0)
        _HatchTex0("Hatch Tex0",2D)="white"{}
        _HatchTex1("Hatch Tex1",2D)="white"{}
        _HatchTex2("Hatch Tex2",2D)="white"{}
        _HatchTex3("Hatch Tex3",2D)="white"{}
        _HatchTex4("Hatch Tex4",2D)="white"{}
        _HatchTex5("Hatch Tex5",2D)="white"{}
    }

    SubShader
    {
        Tags {"Queue"="Geometry" "RenderType"="Opaque"}
        LOD 200
        Pass
        {
            Cull Front
            CGPROGRAM
            #include "UnityCG.cginc"

            float _OutLine;
            fixed4 _OutColor;

            #pragma vertex vert
            #pragma fragment frag

            struct a2f
            {
                float4 vertex:POSITION;
                float3 normal:NORMAL;
            };
            struct v2f
            {
                float4 pos:SV_POSITION;
            };

            v2f vert(a2f v)
            {
                v2f o;
                //float4 viewPos = mul(UNITY_MATRIX_MV,v.vertex);
                float4 viewPos =float4(UnityObjectToViewPos(v.vertex.xyz),1.0);
                float3 normal = mul(UNITY_MATRIX_IT_MV,v.normal);
                normal.z=-0.5;
                viewPos = viewPos+float4(normalize(normal),0)*_OutLine;
                o.pos = mul(UNITY_MATRIX_P,viewPos);
                return o;
            }

            fixed4 frag(v2f i):SV_Target
            {
                return fixed4(_OutColor.rgb,1.0);
            }
            ENDCG
        }

        Pass
        {
            Tags{"LightMode"="ForwardBase"}

            CGPROGRAM
            #include "UnityCG.cginc"
            #include "AutoLight.cginc"

#pragma multi_compile_fwdbase
            fixed4 _ColorTint;
            float _TileFactor;
            sampler2D _HatchTex0;
            sampler2D _HatchTex1;
            sampler2D _HatchTex2;
            sampler2D _HatchTex3;
            sampler2D _HatchTex4;
            sampler2D _HatchTex5;

            #pragma vertex vert
            #pragma fragment frag
            struct a2v
            {
                float4 vertex:POSITION;
                float3 normal:NORMAL;
                half2 texcoord:TEXCOORD0;
            };

            struct v2f
            {
                float4 pos:SV_POSITION;
                half2 uv:TEXCOORD0;
                float3 hatchWeight0:TEXCOORD1;
                float3 hatchWeight1:TEXCOORD2;
                SHADOW_COORDS(3)
                float3 worldPos:TEXCOORD4;
            };

            v2f vert(a2v v)
            {
                v2f o;
                o.pos=UnityObjectToClipPos(v.vertex);
                o.uv=v.texcoord*_TileFactor;

                float3 worldNormal = normalize(mul(v.normal,(float3x3)unity_WorldToObject));
                o.worldPos=mul(unity_ObjectToWorld,v.vertex).xyz;
                float3 wroldLightDir=normalize(UnityWorldSpaceLightDir(o.worldPos));

                float diff = max(0,dot(worldNormal,wroldLightDir));
                float hatchFactor = diff *7.0;
                o.hatchWeight0 = float3(0,0,0);
                o.hatchWeight1 = float3(0,0,0);
                if(hatchFactor>6.0)
                {}
                else if(hatchFactor >5.0)
                {
                    o.hatchWeight0.x=hatchFactor-5.0;
                }
                else if(hatchFactor >4.0)
                {
                    o.hatchWeight0.x=hatchFactor-4.0;
                    o.hatchWeight0.y=1.0-o.hatchWeight0.x;
                }
                else if(hatchFactor >3.0)
                {
                    o.hatchWeight0.y=hatchFactor-3.0;
                    o.hatchWeight0.z=1.0-o.hatchWeight0.y;
                }
                else if(hatchFactor >2.0)
                {
                    o.hatchWeight0.z=hatchFactor-2.0;
                    o.hatchWeight1.x=1.0-o.hatchWeight0.z;
                }
                else if(hatchFactor >1.0)
                {
                    o.hatchWeight1.x=hatchFactor-1.0;
                    o.hatchWeight1.y=1.0-o.hatchWeight1.x;
                }
                else
                {
                    o.hatchWeight1.y=hatchFactor;
                    o.hatchWeight1.z=1.0-o.hatchWeight1.y;
                }
                TRANSFER_SHADOW(o);
                return o;
            }

            fixed4 frag(v2f i):SV_Target
            {
                fixed4 hatchColor0 =tex2D(_HatchTex0,i.uv)*i.hatchWeight0.x;
                fixed4 hatchColor1 =tex2D(_HatchTex1,i.uv)*i.hatchWeight0.y;
                fixed4 hatchColor2 =tex2D(_HatchTex2,i.uv)*i.hatchWeight0.z;
                fixed4 hatchColor3 =tex2D(_HatchTex3,i.uv)*i.hatchWeight1.x;
                fixed4 hatchColor4 =tex2D(_HatchTex4,i.uv)*i.hatchWeight1.y;
                fixed4 hatchColor5 =tex2D(_HatchTex5,i.uv)*i.hatchWeight1.z;

                fixed4 whiteColor = fixed4(1,1,1,1)*(1-i.hatchWeight0.x-i.hatchWeight0.y-i.hatchWeight0.z-i.hatchWeight1.x-i.hatchWeight1.y-i.hatchWeight1.z);
                fixed4 finalColor = hatchColor0+hatchColor1+hatchColor2+hatchColor3+hatchColor4+hatchColor5+whiteColor;
                //SHADOW_ATTENUATION
                UNITY_LIGHT_ATTENUATION(atten,i,i.worldPos);
                return fixed4(finalColor.rgb*_ColorTint.rgb*atten,1.0);
            }
            ENDCG
        }
    }
}
