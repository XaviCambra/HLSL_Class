Shader "Tecnocampus/ColorShader"
{
    Properties
    {
        _MainColor("MainColor", Color) = (1.0,0.0,0.0,1.0)
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
            };
            struct VERTEX_OUT
            {
                float4 vertex : SV_POSITION;
            };

            float4 _MainColor;

            VERTEX_OUT vert(VERTEX_IN v)
            {
                VERTEX_OUT o;
                //o.vertex = UnityObjectToClipPos(v.vertex);
                //o.vertex=mul(UNITY_MATRIX_MVP, float4(v.vertex.xyz, 1.0));
                //o.vertex = mul(float4(v.vertex.xyz, 1.0), transpose(UNITY_MATRIX_MVP));
                o.vertex = mul(unity_ObjectToWorld, float4(v.vertex.xyz, 1.0));
                o.vertex = mul(UNITY_MATRIX_V, o.vertex);
                o.vertex = mul(UNITY_MATRIX_P, o.vertex);
                return o;
            }

            fixed4 frag(VERTEX_OUT i) : SV_Target
            {
                return _MainColor;
            }
                ENDCG
    }
    }
}
