Shader "Tecnocampus/DeferredShader"
{
    Properties
    {
        _MainTex("_MainTex", 2D) = "" {}
        _SpecularPower("_SpecularPower", Float) = 20
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
                float3 normal : NORMAL;
                float2 uv : TEXCOORD0;
            };
            struct VERTEX_OUT
            {
                float4 vertex : SV_POSITION;
                float3 normal : NORMAL;
                float2 uv : TEXCOORD0;
                float2 depth : TEXCOORD1;
            };
            struct DeferredFragmentColors
            {
                float4 color0: COLOR0;
                float4 color1: COLOR1;
                float4 color2: COLOR2;
            };
            float3 Normal2Texture(float3 Normal)
            {
                return (Normal + 1.0) * 0.5;
            }

            sampler2D _MainTex;
            float4 _MainTex_ST;
            float _SpecularPower;

            VERTEX_OUT vert(VERTEX_IN v)
            {
                VERTEX_OUT o;
                o.vertex = mul(unity_ObjectToWorld, float4(v.vertex.xyz, 1.0));
                o.vertex = mul(UNITY_MATRIX_V, o.vertex);
                o.vertex = mul(UNITY_MATRIX_P, o.vertex);
                o.normal = normalize(mul((float3x3)unity_ObjectToWorld, v.normal));
                o.uv = v.uv * _MainTex_ST.xy + _MainTex_ST.zw;
                o.depth = o.vertex.zw;
                return o;
            }

            DeferredFragmentColors frag(VERTEX_OUT i)
            {
                DeferredFragmentColors l_OUT = (DeferredFragmentColors)0;
                float3 Nn = Normal2Texture(normalize(i.normal));
                float4 l_Color = tex2D(_MainTex, i.uv);
                float l_Depth = i.depth.x / i.depth.y;
                l_OUT.color0 = float4(l_Color.xyz, 1.0 / _SpecularPower);
                l_OUT.color1 = float4(Nn, 1);
                l_OUT.color2 = l_Depth.xxxx;
                return l_OUT;
            }
            ENDCG
        }
    }
}
