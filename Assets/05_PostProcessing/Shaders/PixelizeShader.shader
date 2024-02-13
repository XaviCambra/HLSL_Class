Shader "Tecnocampus/PixelizeShader"
{
    Properties
    {
        _MainTex("_MainTex", 2D) = "" {}
        _Pixels("_Pixels", Integer) = 10
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

            //#define PIXEL_SIZE

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
            sampler2D _MainTex;
            int _Pixels;
            int _PixelsWidth;
            int _PixelsHeigh;

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
#ifdef PIXEL_SIZE
                float2 N = float2(_ScreenParams.x / _Pixels, _ScreenParams.y / _Pixels);
                float2 l_UV = floor(i.uv * N) / N;
#else
                float l_PixelsWidth = _ScreenParams.x / _Pixels;
                float l_PixelsHeight = l_PixelsWidth * (_ScreenParams.y / _ScreenParams.x);
                float2 N = float2(_ScreenParams.x / l_PixelsWidth, _ScreenParams.y / l_PixelsHeight);
                float2 l_UV = floor(i.uv * N) / N;
#endif
                float4 l_Color = tex2D(_MainTex, l_UV);
                return l_Color;
            }
                ENDCG
    }
    }
}
