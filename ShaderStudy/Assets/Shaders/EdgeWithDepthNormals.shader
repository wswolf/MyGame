Shader "YuriStudy/EdgeWithDepthNormals"
{
    Properties
    {
        _MainTex("Main Texture",2D)="white" {}
        _EdgeOnly("Edge Only",Float)=1.0
        _EdgeColor("Edge Color",Color)=(1.0,1.0,1.0,1.0)
        _BackgroundColor("Bg Color",Color)=(1.0,1.0,1.0,1.0)
        _SampleDistance("Sample Distance",Float)=1.0
        _Sensitivity("Sensitivity",Vector)=(1.0,1.0,1.0,1.0)
    }
    SubShader
    {
        //Tags {"Queue"="Geometry","RenderType"="Opaque"}
        CGINCLUDE
        #include "UnityCG.cginc"

        sampler2D _MainTex;
        float4 _MainTex_TexelSize;
        float _EdgeOnly;
        fixed4 _EdgeColor;
        fixed4 _BackgroundColor;
        float _SampleDistance;
        half4 _Sensitivity;
        sampler2D _CameraDepthNormalsTexture;

        struct appdata_vert
        {
            float4 vertex:POSITION;
            half2 texcoord:TEXCOORD0;
        };
        struct v2f
        {
            float4 pos:SV_POSITION;
            half2 uv[5]:TEXCOORD0;

        };
        v2f vert(appdata_vert v)
        {
            v2f o;
            o.pos = UnityObjectToClipPos(v.vertex);
            half2 uv0;
            uv0=v.texcoord;
            #if UNITY_UV_STARTS_AT_TOP
                if(_MainTex_TexelSize.y<0)
                    uv0.y=1-uv0.y;
            #endif
            o.uv[0]=uv0;
            o.uv[1]=uv0+_MainTex_TexelSize.xy*half2(1,1)*_SampleDistance;
            o.uv[2]=uv0+_MainTex_TexelSize.xy*half2(-1,-1)*_SampleDistance;
            o.uv[3]=uv0+_MainTex_TexelSize.xy*half2(-1,1)*_SampleDistance;
            o.uv[4]=uv0+_MainTex_TexelSize.xy*half2(1,-1)*_SampleDistance;
            return o;
        }
        half checksame(float4 center,float4 sample)
        {
            half2 centerNormal=center.xy;
            float centerDepth=DecodeFloatRG(center.zw);
            half2 sampleNormal=sample.xy;
            float sampleDepth=DecodeFloatRG(sample.zw);

            half2 diffNormal=abs(centerNormal-sampleNormal)*_Sensitivity.x;
            int isSameNormal = (diffNormal.x+diffNormal.y)<0.1;
            half diffDepth=abs(centerDepth-sampleDepth)*_Sensitivity.y;
            int isSameDepth = diffDepth<0.1*centerDepth;

            return isSameNormal*isSameDepth?1.0:0.0;

        }
        fixed4 frag(v2f i):SV_Target
        {
            float4 sampler1=tex2D(_CameraDepthNormalsTexture,i.uv[1]);
            float4 sampler2=tex2D(_CameraDepthNormalsTexture,i.uv[2]);
            float4 sampler3=tex2D(_CameraDepthNormalsTexture,i.uv[3]);
            float4 sampler4=tex2D(_CameraDepthNormalsTexture,i.uv[4]);

            half edge=1.0;
            edge*=checksame(sampler1,sampler2);
            edge*=checksame(sampler3,sampler4);

            fixed4 finalcolor=tex2D(_MainTex,i.uv[0]);
            finalcolor = lerp(_EdgeColor,finalcolor,edge);
            fixed4 onlyEdgeColor=lerp(_EdgeColor,_BackgroundColor,edge);
            return lerp(finalcolor,onlyEdgeColor,_EdgeOnly);

        }
        ENDCG

        Pass
        {
            ZWrite Off
            ZTest Always
            Cull Off
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag 
            ENDCG
        }
    }
}
