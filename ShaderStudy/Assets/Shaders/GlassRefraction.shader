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
		Tags{"Queue"="Transparent" "RenderType"="Opaque"}
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
                float4 tangent:TANGENT;
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
                float3 worldPos=float3(i.TtoW0.w,i.TtoW1.w,i.TtoW2.w);
                float3 wroldViewDir=normalize(UnityWorldSpaceViewDir(worldPos));

                float3 bump=UnpackNormal(tex2D(_BumpMap,i.uv.zw));

                float2 offset=bump.xy*_Distortion*_RefractionTex_TexelSize.xy;
                i.srcPos.xy=offset+i.srcPos.xy;
                fixed3 refractCol=tex2D(_RefractionTex,i.srcPos.xy/i.srcPos.w).rgb;

                bump=normalize(half3(dot(i.TtoW0.xyz,bump),dot(i.TtoW1.xyz,bump),dot(i.TtoW2.xyz,bump)));
                float3 refDir=reflect(-wroldViewDir,bump);
                fixed3 texCol=tex2D(_MainTex,i.uv.xy);
                fixed3 reflectCol=texCUBE(_CubeMap,refDir).rgb*texCol.rgb;
                fixed3 finalcolor=reflectCol*(1-_RefractionAmount)+refractCol*_RefractionAmount;
                return fixed4(finalcolor,1.0);
            }
            ENDCG
        }
    }
}
