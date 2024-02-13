Shader "Tecnocampus/HeightMapShader"
{
    Properties
    {
        _MainTex("_MainTex", 2D) = "" {}
        _MaxHeight("_MaxHeight", Float) = 0.5
        _GradientTex("_GradientTex", 2D) = "" {}
        _FogColor("_FogColor", Color) = (1,1,1,1)
        _FogStartLinearDistance("_FogStartLinearDistance", Float) = 20.0
        _FogEndLinearDistance("_FogEndLinearDistance", Float) = 30.0
        _FogDensity("_FogDensity", Range(0.0, 1.0)) = 1.0
        [KeywordEnum(Linear, Exp, Exp2)] _FogType("Fog Type", Float) = 0
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

            #pragma multi_compile _FOGTYPE_LINEAR _FOGTYPE_EXP _FOGTYPE_EXP2

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
                float3 WorldPosition : TEXCOORD1;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;
            float _MaxHeight;
            sampler2D _GradientTex;
            float4 _FogColor;
            float _FogStartLinearDistance;
            float _FogEndLinearDistance;
            float _FogDensity;

            VERTEX_OUT vert(VERTEX_IN v)
            {
                VERTEX_OUT o;
                o.vertex = mul(unity_ObjectToWorld, float4(v.vertex.xyz, 1.0));
                float l_Height = tex2Dlod(_MainTex, float4(v.uv, 0, 0)).x * _MaxHeight;
                o.vertex.y += l_Height;
                o.WorldPosition = o.vertex.xyz;
                o.vertex = mul(UNITY_MATRIX_V, o.vertex);
                o.vertex = mul(UNITY_MATRIX_P, o.vertex);
                o.uv = v.uv;

                return o;
            }

            fixed4 frag(VERTEX_OUT i) : SV_Target
            {
                float4 l_Color = tex2D(_MainTex, i.uv);

                float l_BW = (l_Color.x + l_Color.y + l_Color.z) / 3.0;

                float2 l_UVGradient = float2(0.5, l_BW);

                l_Color = tex2D(_GradientTex, l_UVGradient);

                float l_Depth = length(i.WorldPosition - _WorldSpaceCameraPos.xyz);
#ifdef _FOGTYPE_LINEAR
                float l_FogIntensity = saturate((l_Depth - _FogStartLinearDistance) / (_FogEndLinearDistance - _FogStartLinearDistance)); //Linear
#elif _FOGTYPE_EXP
                float l_FogIntensity = 1.0 - (1.0 / exp(l_Depth * _FogDensity)); //Exp
#else
                float l_FogIntensity = 1.0 - (1.0 / exp(l_Depth * _FogDensity * l_Depth * _FogDensity)); //Exp2
#endif
                return float4(l_Color.xyz * (1.0 - l_FogIntensity) + l_FogIntensity * _FogColor.xyz, l_Color.w);

            }
                ENDCG
    }
    }
}
