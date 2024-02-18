Shader "Tecnocampus/DeferredAmbientShader"
{
    Properties
    {
        _MainTex("_MainTex", 2D) = "" {}
        _RT0("_RT0", 2D) = "" {}
        _AmbientColor("_AmbientColor", Color) = (1,1,1,1)
        _AmbientIntensity("_AmbientIntensity", Range(0.0,2.0)) = 0.5
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
            sampler2D _RT0;
            float4 _AmbientColor;
            float _AmbientIntensity;

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
                float4 l_AlbedoColor = tex2D(_RT0, i.uv);
                return float4(l_AlbedoColor.xyz * _AmbientIntensity * _AmbientColor.xyz, 1.0);
            }
            ENDCG
        }
    }
}
