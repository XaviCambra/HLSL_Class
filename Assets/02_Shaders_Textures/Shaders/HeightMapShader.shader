Shader "Tecnocampus/HeightMapShader"
{
    Properties
    {
        _MainTex("_MainTex", 2D) = "" {}
        _MaxHeight("_MaxHeight", float) = 0.5
        _GradientTex("_GradientTex", 2D) = "" {}
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
            float4 _MainTex_ST;
            float _MaxHeight;
            sampler2D _GradientTex;

            VERTEX_OUT vert(VERTEX_IN v)
            {
                VERTEX_OUT o;
                o.vertex = mul(unity_ObjectToWorld, float4(v.vertex.xyz, 1.0));
                float l_Height = tex2Dlod(_MainTex, float4(v.uv, 0, 0)).x * _MaxHeight;
                o.vertex.y += l_Height;
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

                return tex2D(_GradientTex, l_UVGradient);
            }
                ENDCG
    }
    }
}
