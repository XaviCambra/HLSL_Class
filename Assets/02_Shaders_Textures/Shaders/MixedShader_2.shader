Shader "Tecnocampus/MixedShader"
{
    Properties
    {
        _BlackTex("_BlackTex", 2D) = "" {}
        _WhiteTex("_WhiteTex", 2D) = "" {}
        _MixerBWTex("_MixerBWTex", 2D) = "" {}
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
                float2 uv : TEXCOORD0;
                float2 uvBlack : TEXCOORD1;
                float2 uvWhite : TEXCOORD2;
            };

            sampler2D _BlackTex;
            float4 _BlackTex_ST;
            sampler2D _WhiteTex;
            float4 _WhiteTex_ST;
            sampler2D _MixerBWTex;
            

            VERTEX_OUT vert(VERTEX_IN v)
            {
                VERTEX_OUT o;
                o.vertex = mul(unity_ObjectToWorld, float4(v.vertex.xyz, 1.0));
                o.vertex = mul(UNITY_MATRIX_V, o.vertex);
                o.vertex = mul(UNITY_MATRIX_P, o.vertex);
                o.uv = v.uv;
                o.uvBlack = TRANSFORM_TEX(v.uv, _BlackTex);
                o.uvWhite = TRANSFORM_TEX(v.uv, _WhiteTex);
                return o;
            }

            fixed4 frag(VERTEX_OUT i) : SV_Target
            {

                float4 l_MixerColor = tex2D(_MixerBWTex, i.uv);
                float4 l_BlackColor = tex2D(_BlackTex, i.uvBlack);
                float4 l_WhiteColor = tex2D(_WhiteTex, i.uvWhite);

                return float4(l_MixerColor.x*l_WhiteColor.xyz+(1.0-l_MixerColor.x)*l_BlackColor.xyz, 1.0);
            }
            ENDCG
        }
    }
}
