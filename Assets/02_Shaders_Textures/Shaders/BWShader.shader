Shader "Tecnocampus/BWShader"
{
    Properties
    {
        _MainTex("_MainTex", 2D) = "defaulttexture" {}
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

            VERTEX_OUT vert(VERTEX_IN v)
            {
                VERTEX_OUT o;
                //o.vertex = UnityObjectToClipPos(v.vertex);
                //o.vertex=mul(UNITY_MATRIX_MVP, float4(v.vertex.xyz, 1.0));
                //o.vertex = mul(float4(v.vertex.xyz, 1.0), transpose(UNITY_MATRIX_MVP));
                o.vertex = mul(unity_ObjectToWorld, float4(v.vertex.xyz, 1.0));
                o.vertex = mul(UNITY_MATRIX_V, o.vertex);
                o.vertex = mul(UNITY_MATRIX_P, o.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);

                return o;
            }

            fixed4 frag(VERTEX_OUT i) : SV_Target
            {
                float4 l_Color = tex2D(_MainTex, i.uv);

                // Invertir
                //return l_Color.zyxw;

                //return l_Color;

                float l_BW = (l_Color.x + l_Color.y + l_Color.z) / 3.0;
                //float l_BW = (l_Color.x * 0.3 + l_Color.y * 0.59 + l_Color.z * 0.11);

                return l_BW;



            }
                ENDCG
    }
    }
}
