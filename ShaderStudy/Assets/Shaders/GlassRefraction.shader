Shader "YuriStudy/GlassRefraction"
{
    Properties
    {
		_MainTex("Main Texture",2D)="white"{}
		_BumpMap("Bump Map",2D)="bump"{}
		_CubeMap("Cube Map",Cube)="_SkyBox"{}
		_Distortion("Distortion",Range(0,100))=10
        _RefractionAmount("Refraction Amount",Range(0.0,1.0))=1.0 
    }
    SubShader
    {
		Tags{"Queue"="Transparents" "RenderType"="Opaque"}
        GrabPass {"_RefractionTex"}
        Pass
        {
            CGPROGRAM
            #include "UnityCG.cginc"
            #pragma vertex vert
            #pragma fragment frag
            struct appdata
            {
                float4 vertex:POSITION;
                float3 normal:NORMAL;
                float3 tangent:TANGENT;
                float2 texcoord:TEXCOORD0;
            }; 
            struct v2f
            {
                float4 pos:SV_POSITION;
                float4 srcPos:TEXCOORD0;
                float4 uv:TEXCOORD1;
                float4 TtoW0:TEXCOORD2;
                float4 TtoW1:TEXCOORD3;
                float4 TtoW2:TEXCOORD4;  
            };
            sampler2D _MainTex;
            float4 _MainTex_ST;
            sampler2D _BumpMap;
            float4 _BumpMap_ST;
            samplerCUBE _CubeMap;
            float _Distortion;
            fixed _RefractionAmount;
            sampler2D _RefractionTex;
            float4 _RefractionTex_TexelSize;

            v2f vert(appdata v)
            {
                v2f o;
                //mul(UNITY_MATRIX_MVP,float4(v.vertex.xyz,1.0))
                o.pos=UnityObjectToClipPos(v.vertex);
                o.srcPos=ComputeGrabScreenPos(o.pos);
                o.uv.xy=TRANSFORM_TEX(v.texcoord,_MainTex);
                o.uv.zw=TRANSFORM_TEX(v.texcoord,_BumpMap);
                float3 worldPos=mul(unity_ObjectToWorld,v.vertex);
                //mul(transpose(unity_ObjectToWorld),v.normal) = mul(v.normal,unity_worldToObject)
                float3 worldnormal=UnityObjectToWorldNormal(v.normal);
                float3 worldTangent = UnityObjectToWorldDir(v.tangent.xyz);
                //v.tangent.w 决定富切线的方向
                float3 worldBiNormal=cross(worldnormal,worldTangent)*v.tangent.w;

                o.TtoW0=float4(worldTangent.x,worldBiNormal.x,worldnormal.x,worldPos.x);
                o.TtoW1=float4(worldTangent.y,worldBiNormal.y,worldnormal.y,worldPos.y);
                o.TtoW2=float4(worldTangent.z,worldBiNormal.z,worldnormal.z,worldPos.z);
                return o;
            }

            fixed4 frag(v2f i):SV_Target
            {
                
            }
            ENDCG
        }
    }
}
