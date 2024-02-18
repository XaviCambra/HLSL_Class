Shader "Tecnocampus/VignettingShader"
{
    Properties
    {
        _MainTex("_MainTex", 2D) = "" {}
        _Vignetting("_Vignetting", Range(0,1.0)) = 0.5
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
            sampler2D _MainTex;
            float _Vignetting;

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
                float l_Length = length(i.uv - float2(0.5, 0.5));
                float l_StartVignetting = _Vignetting;
                float l_EndVignetting = _Vignetting + 0.5 * _Vignetting;
                float l_VignettingPct = saturate((l_Length - l_StartVignetting) / (l_EndVignetting - l_StartVignetting));

                float4 l_Color = tex2D(_MainTex, i.uv);
                return l_Color * (1- l_VignettingPct);
            }
                ENDCG
    }
    }
}
