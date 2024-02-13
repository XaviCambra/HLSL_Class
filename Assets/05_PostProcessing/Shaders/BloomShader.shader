Shader "Tecnocampus/BloomShader"
{
    Properties
    {
        _MainTex("_MainTex", 2D) = "" {}
        _SampleDistance("_SampleDistance", Float) = 0.5
        _BloomIntensity("_BloomIntensity", Float) = 0.5
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
            sampler2D _SourceTexture;
            float _SampleDistance;
            float _BloomIntensity;

            VERTEX_OUT vert(VERTEX_IN v)
            {
                VERTEX_OUT o;
                o.vertex = mul(unity_ObjectToWorld, float4(v.vertex.xyz, 1.0));
                o.vertex = mul(UNITY_MATRIX_V, o.vertex);
                o.vertex = mul(UNITY_MATRIX_P, o.vertex);
                o.uv = v.uv;
                return o;
            }

            fixed4 frag(VERTEX_OUT IN) : SV_Target
            {
                float2 l_KernelBase[7] =
                {
                    { 0.0,  0.0 },
                    { 1.0,  0.0 },
                    { 0.5,  0.8660 },
                    { -0.5,  0.8660 },
                    { -1.0,  0.0 },
                    { -0.5, -0.8660 },
                    { 0.5, -0.8660 },
                };
                float l_KernelWeights[7] =
                {
                    0.38774,
                    0.06136,
                    0.24477 / 2.0,
                    0.24477 / 2.0,
                    0.06136,
                    0.24477 / 2.0,
                    0.24477 / 2.0,
                };
                float3 l_Color = (0,0,0);
                for (int i = 0; i < 7; i++)
                {
                    float2 l_UVScaled = float2(1.0 / _ScreenParams.x, 1.0 / _ScreenParams.y) * _SampleDistance;
                    l_Color.xyz += tex2D(_MainTex, IN.uv + l_UVScaled * l_KernelBase[i]).xyz * l_KernelWeights[i];
                }
                return float4(tex2D(_SourceTexture, IN.uv).xyz+l_Color * _BloomIntensity, 1.0);
            }
                ENDCG
    }
    }
}
