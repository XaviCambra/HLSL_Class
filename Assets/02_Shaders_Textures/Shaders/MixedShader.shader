Shader "Tecnocampus/MixedShader"
{
    Properties
    {
        _BlackTex("_BlackTex", 2D) = "" {}
        _WhiteTex("_WhiteTex", 2D) = "" {}
        _MixerTex("_MixerBWMainTex", 2D) = "" {}
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
            };

            sampler2D _BlackTex;
            float4 _BlackTex_ST;
            sampler2D _WhiteTex;
            float4 _WhiteTex_ST;
            sampler2D _MixerTex;
            

            VERTEX_OUT vert(VERTEX_IN v)
            {
                VERTEX_OUT o;
                o.vertex = mul(unity_ObjectToWorld, float4(v.vertex.xyz, 1.0));
                o.vertex = mul(UNITY_MATRIX_V, o.vertex);
                o.vertex = mul(UNITY_MATRIX_P, o.vertex);
                o.uv = v.uv;

                return o;
            }

            fixed4 frag(VERTEX_OUT i) : SV_Target
            {
                float4 l_Color = tex2D(_MixerTex, i.uv);
                float l_BW = (l_Color.x + l_Color.y + l_Color.z) / 3.0;

                float2 l_UVBlack = i.uv * _BlackTex_ST.xy + _BlackTex_ST.zw;
                float2 l_UVWhite = i.uv * _WhiteTex_ST.xy + _WhiteTex_ST.zw;

                float3 l_BlackColor = tex2D(_BlackTex, l_UVBlack);
                float3 l_WhiteColor = tex2D(_WhiteTex, l_UVWhite);

                return float4(l_BlackColor.xyz * (1.0 - l_BW) + l_WhiteColor.xyz * l_BW, 1.0);
            }
            ENDCG
        }
    }
}
