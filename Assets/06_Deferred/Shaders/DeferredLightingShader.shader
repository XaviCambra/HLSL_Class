    Shader "Tecnocampus / DeferredLightingShader"
{
    Properties{
        _MainTex("Texture", 2D) = "white"{}
        _RT0("Source Tex (Render Texture Albedo)", 2D) = "white"{}
        _RT1("Source Tex (Render Texture Normal)", 2D) = "white"{}
        _RT2("Source Tex (Render Texture Depth)", 2D) = "white"{}
        [Toggle] _UseShadowMap("Use Shadow Map", Integer) = 1
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


            };
            struct v2f 
            {
                float4 vertex : SV_POSITION; // A position in the screen
                float2 UVs : TEXCOORD0; 
            };

            float3 Texture2Normal(float3 Texture)
            {
                return (Texture - 0.5) * 2;
            }


            float3 GetPositionFromZDepthViewInViewCoordinates(float ZDepthView, float2 UV, float4x4 InverseProjection)
            {
                // Get the depth value for this pixel
                // Get x/w and y/w from the viewport position
                //Depending on viewport type
                float x = UV.x * 2 - 1;
                float y = UV.y * 2 - 1;
#if SHADER_API_D3D9
                float4 l_ProjectedPos = float4(x, y, ZDepthView * 2.0 - 1.0, 1.0);
#elif SHADER_API_D3D11
                float4 l_ProjectedPos = float4(x, y, (1.0 - ZDepthView) * 2.0 - 1.0, 1.0);
#else
                float4 l_ProjectedPos = float4(x, y, ZDepthView, 1.0);
#endif
                // Transform by the inverse projection matrix
                float4 l_PositionVS = mul(InverseProjection, l_ProjectedPos);
                // Divide by w to get the view-space position
                return l_PositionVS.xyz / l_PositionVS.w;
            }

            float3 GetPositionFromZDepthView(float ZDepthView, float2 UV, float4x4 InverseView, float4x4 InverseProjection)
            {
                float3 l_PositionView = GetPositionFromZDepthViewInViewCoordinates(ZDepthView, UV, InverseProjection);
                return mul(InverseView, float4(l_PositionView, 1.0)).xyz;


            }

            sampler2D _MainTex;
            float4 _MainTex_ST; //Es solo añadirle el sufijo ST a la textura en calidad de uniform

            sampler2D _RT0;
            sampler2D _RT1; //de aqui sacaremos la normal
            sampler2D _RT2; //de aqui sacaremos la depth

            //Todo esto sale del script de DeferredLightPostProcessing
            float4 _LightColor;
            float4x4 _InverseViewMatrix;
            float4x4 _InverseProjectionMatrix;
            int _LightType; //0 = Spot, 1=Directional, 2 = Point
            float4 _LightPosition;
            float4 _LightDirection;
            float4 _LightProperties; // x= Range, y=Intensity, z=Spot Angle, w=cos(Half Spot Angle)
            int _UseShadowMap;
            sampler2D _ShadowMap;
            float4x4 _ShadowMapViewMatrix;
            float4x4 _ShadowMapProjectionMatrix;
            float _ShadowMapBias;
            float _ShadowMapStrength;

            v2f vert(VERTEX_IN v) //Vertex Shader Function
            {
                v2f o;

                

                o.vertex = mul(unity_ObjectToWorld, float4(v.vertex.xyz, 1.0)); //Lo multiplica a matriz de mundo y lo convierte a coordenadas de mundo
                o.vertex = mul(UNITY_MATRIX_V, o.vertex); //Lo multiplica a matriz de view y lo convierte a coordenadas de view
                o.vertex = mul(UNITY_MATRIX_P, o.vertex); //Lo multiplica a matriz de proyeccion y lo convierte a coordenadas de proyeccion

                o.UVs = TRANSFORM_TEX(v.UVs, _MainTex);  //TransformTex permite multiplicar el tiling y sumar en offset
                return o;

            }

            fixed4 frag(v2f i) : SV_Target//Pixel Shader Function
            {
                float4 l_AlbedoColor = tex2D(_RT0, i.UVs);
                
                float l_Depth = tex2D(_RT2, i.UVs).x;
                if (l_Depth == 0) { return l_AlbedoColor; } //Si no hay geometría devuelve el color del frame buffer
                float4 l_Color = tex2D(_MainTex, i.UVs);

                float3 l_NormalTexture = tex2D(_RT1, i.UVs).xyz;
                float3 l_Normal = Texture2Normal(l_NormalTexture);
                float3 Nn = normalize(l_Normal);
                float3 l_WorldPosition = GetPositionFromZDepthView(l_Depth.x, i.UVs, _InverseViewMatrix, _InverseProjectionMatrix);
                float3 Vn = normalize(l_WorldPosition - _WorldSpaceCameraPos.xyz);

                float l_Attenuation = 1.0;
                float3 l_DifuseLighting = float3(0, 0, 0);
                float3 l_SpecularLighting = float3(0, 0, 0);
                float3 l_FullLighting = float3(0, 0, 0);

                float3 l_LightDirection = _LightDirection.xyz;
                float l_SpecularPower = 1.0 / l_AlbedoColor.w; // El specular power lo teníamos guardado del G-Buffer en el canal alpha del albedo

                float l_ShadowMap = 1.0;
                if (_UseShadowMap == 1)
                {
                    float4 l_Vertex = mul(_ShadowMapViewMatrix, float4(l_WorldPosition, 1.0));
                    l_Vertex = mul(_ShadowMapProjectionMatrix, l_Vertex);
                    float l_Depth = l_Vertex.z / l_Vertex.w;
                    float2 l_UV = float2(((l_Vertex.x / l_Vertex.w) / 2.0f) + 0.5f, ((l_Vertex.y / l_Vertex.w) / 2.0f) + 0.5f);
#if SHADER_API_D3D9
                    float l_ShadowMapDepth = ((tex2D(_ShadowMap, l_UV).x - 0.5) * 2.0) + _ShadowMapBias;
#elif SHADER_API_D3D11 
                    float l_ShadowMapDepth = (((1.0 - tex2D(_ShadowMap, l_UV).x) - 0.5) * 2.0) + _ShadowMapBias;
#else
                    float l_ShadowMapDepth = _ShadowMapBias + tex2D(_ShadowMap, l_UV).x;
#endif
                    l_ShadowMap = l_Depth > l_ShadowMapDepth ? (1.0 - _ShadowMapStrength) : 1.0;
                    if (l_UV.x <= 0.0 || l_UV.x >= 1.0 || l_UV.y <= 0.0 || l_UV.y >= 1.0)
                        l_ShadowMap = 1.0;
                }

                if (_LightType == 2 || _LightType == 0)
                {
                    float3 l_LightDirectionNotNormalized = l_WorldPosition - _LightPosition;
                    float l_DistanceToPixel = length(l_LightDirectionNotNormalized);
                    l_LightDirection = l_LightDirectionNotNormalized / l_DistanceToPixel;
                    l_Attenuation = saturate(1.0 - l_DistanceToPixel / _LightProperties.x);
                    if (_LightType == 0)
                    {
                        l_Attenuation *= saturate((dot(_LightDirection, normalize(l_WorldPosition - _LightPosition)) - _LightProperties.w) / (1.0 - _LightProperties.w));
                    }
                }

                float3 Reflected = normalize(reflect(Vn, Nn));
                float3 Kd = saturate(dot(Nn, -l_LightDirection));
                float3 Ks = pow(saturate(dot(-l_LightDirection, Reflected)), l_SpecularPower);
                l_SpecularLighting += Ks * _LightColor * l_Attenuation * _LightProperties.y * l_ShadowMap;
                l_DifuseLighting += Kd * _LightColor * l_AlbedoColor.xyz * _LightProperties.y * l_Attenuation * l_ShadowMap;
                l_FullLighting = l_DifuseLighting + l_SpecularLighting;

                return float4(l_Color.xyz+l_FullLighting, 1.0);
            }
                ENDCG
        }
    }
}

