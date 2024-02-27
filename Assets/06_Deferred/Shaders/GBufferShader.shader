Shader "Tecnocampus / GBuffer Shader"
{
    Properties{
        _MainTex("Texture", 2D) = "white"{}
        _SpecularPower("Specular Power", Float) = 20
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
                float2 UVs : TEXCOORD0; 
                float3 normal:NORMAL;


            };
            struct v2f 
            {
                float4 vertex : SV_POSITION; // A position in the screen
                float2 UVs : TEXCOORD0; 
                float3 normal:NORMAL;
                float2 depth : TEXCOORD1;
            };

            float3 Normal2Texture(float3 Normal){
                return (Normal + 1.0) * 0.5;
            }
            struct DeferredFragmentColors {
                float4 color0:COLOR0;
                float4 color1:COLOR1;
                float4 color2:COLOR2;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST; //Es solo añadirle el sufijo ST a la textura en calidad de uniform
            float _SpecularPower;

            v2f vert(VERTEX_IN v) //Vertex Shader Function
            {
                v2f o;

                

                o.vertex = mul(unity_ObjectToWorld, float4(v.vertex.xyz, 1.0)); //Lo multiplica a matriz de mundo y lo convierte a coordenadas de mundo
                o.vertex = mul(UNITY_MATRIX_V, o.vertex); //Lo multiplica a matriz de view y lo convierte a coordenadas de view
                o.vertex = mul(UNITY_MATRIX_P, o.vertex); //Lo multiplica a matriz de proyeccion y lo convierte a coordenadas de proyeccion
                
                o.depth = o.vertex.zw;//vértice en z (profundidad) y w (una escala de las matrices) en proyección

                o.normal = normalize(mul((float3x3)unity_ObjectToWorld, v.normal));

                o.UVs = TRANSFORM_TEX(v.UVs, _MainTex);  //TransformTex permite multiplicar el tiling y sumar en offset
                return o;

            }

            DeferredFragmentColors frag(v2f i) //Pixel Shader Function
            {
                float3 Nn = normalize(i.normal);
                float4 l_Color = tex2D(_MainTex, i.UVs);
                float l_Depth = i.depth.x / i.depth.y;

                DeferredFragmentColors l_Out = (DeferredFragmentColors)0;

                l_Out.color0 = float4(l_Color.xyz, (1.0/_SpecularPower));
                l_Out.color1 = float4(Normal2Texture(Nn), 0);
                l_Out.color2 = l_Depth.xxxx;
                
                return l_Out;
            }
                ENDCG
        }
    }
}

