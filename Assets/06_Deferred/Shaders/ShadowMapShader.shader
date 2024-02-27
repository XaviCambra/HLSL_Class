Shader "Tecnocampus / Shadow Map Shader"
{
    Properties{
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
            struct v2f 
            {
                float4 vertex : SV_POSITION; // A position in the screen
                float2 depth : TEXCOORD1;
            };


            float _SpecularPower;

            v2f vert(VERTEX_IN v) //Vertex Shader Function
            {
                v2f o;

                

                o.vertex = mul(unity_ObjectToWorld, float4(v.vertex.xyz, 1.0)); //Lo multiplica a matriz de mundo y lo convierte a coordenadas de mundo
                o.vertex = mul(UNITY_MATRIX_V, o.vertex); //Lo multiplica a matriz de view y lo convierte a coordenadas de view
                o.vertex = mul(UNITY_MATRIX_P, o.vertex); //Lo multiplica a matriz de proyeccion y lo convierte a coordenadas de proyeccion
                

                o.depth = o.vertex.zw;//vértice en z (profundidad) y w (una escala de las matrices) en proyección

                return o;

            }

            float4 frag(v2f i):SV_Target //Pixel Shader Function
            {
                float l_Depth = i.depth.x / i.depth.y;
                
                return l_Depth.xxxx;
            }
                ENDCG
        }
    }
}

