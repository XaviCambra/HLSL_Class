Shader "Tecnocampus/SkyboxShader"
{
    Properties
    {
        _SkyboxTex("_SkyboxTex", CUBE) = "defaulttexture" {}
    }
        SubShader
    {
        Tags { "RenderType" = "Opaque" }
        LOD 100
        Cull Front

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
                float3 normal : NORMAL;
            };

            samplerCUBE _SkyboxTex;

            VERTEX_OUT vert(VERTEX_IN v)
            {
                VERTEX_OUT o;
                float3 l_Normal = normalize(v.vertex.xyz);
                o.vertex = float4(_WorldSpaceCameraPos + l_Normal * _ProjectionParams.z * 0.5, 1.0);
                o.vertex = mul(UNITY_MATRIX_V, o.vertex);
                o.vertex = mul(UNITY_MATRIX_P, o.vertex);
                o.normal = l_Normal;

                return o;
            }

            fixed4 frag(VERTEX_OUT i) : SV_Target
            {
                float3 Nn = normalize(i.normal);
                return texCUBE(_SkyboxTex, Nn);
            }
                ENDCG
    }
    }
}
