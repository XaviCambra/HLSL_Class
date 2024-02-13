Shader "Tecnocampus/RGBAMixedShader"
{
    Properties
    {
        _MixerTex("_MixerTex", 2D) = "" {}
        _RedTex("_RedTex", 2D) = "" {}
        _GreenTex("_GreenTex", 2D) = "" {}
        _BlueTex("_BlueTex", 2D) = "" {}
        _AlphaTex("_AlphaTex", 2D) = "" {}
    }
    SubShader
    {
        Tags { "RenderType" = "Opaque"}
        LOD 100

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"

            struct VERTEX_IN
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };
            struct VERTEX_OUT
            {
                float4 vertex : SV_POSITION;
                float2 uvMixer : TEXCOORD0;
                float2 uvRed : TEXCOORD1;
                float2 uvGreen : TEXCOORD2;
                float2 uvBlue : TEXCOORD3;
                float2 uvAlpha : TEXCOORD4;
            };

            sampler2D _MixerTex;
            sampler2D _RedTex;
            float4 _RedTex_ST;
            sampler2D _GreenTex;
            float4 _GreenTex_ST;
            sampler2D _BlueTex;
            float4 _BlueTex_ST;
            sampler2D _AlphaTex;
            float4 _AlphaTex_ST;
            

            VERTEX_OUT vert(VERTEX_IN v)
            {
                VERTEX_OUT o;
                o.vertex = mul(unity_ObjectToWorld, float4(v.vertex.xyz, 1.0));
                o.vertex = mul(UNITY_MATRIX_V, o.vertex);
                o.vertex = mul(UNITY_MATRIX_P, o.vertex);
                o.uvMixer = v.uv;
                o.uvRed = TRANSFORM_TEX(v.uv, _RedTex);
                o.uvGreen = TRANSFORM_TEX(v.uv, _GreenTex);
                o.uvBlue = TRANSFORM_TEX(v.uv, _BlueTex);
                o.uvAlpha = TRANSFORM_TEX(v.uv, _AlphaTex);

                return o;
            }

            fixed4 frag(VERTEX_OUT i) : SV_Target
            {
                float4 l_MixerColor = tex2D(_MixerTex, i.uvMixer);
                float4 l_RedColor = tex2D(_RedTex, i.uvRed);
                float4 l_GreenColor = tex2D(_GreenTex, i.uvGreen);
                float4 l_BlueColor = tex2D(_BlueTex, i.uvBlue);
                float4 l_AlphaColor = tex2D(_AlphaTex, i.uvAlpha);

                return float4(l_MixerColor.x * l_RedColor.xyz + l_MixerColor.y * l_GreenColor.xyz + l_MixerColor.z * l_BlueColor.xyz + l_MixerColor.w * l_AlphaColor.xyz, 1.0);

            }
            ENDCG
        }
    }
}
