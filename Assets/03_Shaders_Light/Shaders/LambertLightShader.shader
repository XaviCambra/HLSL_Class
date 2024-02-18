

Shader "Tecnocampus/LambertLightShader"
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

            #define MAX_LIGHTS 4

            struct VERTEX_IN
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
                float3 normal : NORMAL;
            };
            struct VERTEX_OUT
            {
                float4 vertex : SV_POSITION;
                float2 uv : TEXCOORD0;
                float3 normal : NORMAL;
                float3 WorldPosition : TEXCOORD1;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;
            int _LightsCount;
            int _LightTypes[MAX_LIGHTS]; //0=Spot, 1=Directional, 2=Point
            float4 _LightColors[MAX_LIGHTS];
            float4 _LightPositions[MAX_LIGHTS];
            float4 _LightDirections[MAX_LIGHTS];
            float4 _LightProperties[MAX_LIGHTS]; //x=Range, y=Intensity, z=Spot Angle, w=cos(Half Spot Angle)

            VERTEX_OUT vert(VERTEX_IN v)
            {
                VERTEX_OUT o;
                o.vertex = mul(unity_ObjectToWorld, float4(v.vertex.xyz, 1.0));
                o.WorldPosition = o.vertex.xyz; //copia la matriz de mundo
                o.vertex = mul(UNITY_MATRIX_V, o.vertex);
                o.vertex = mul(UNITY_MATRIX_P, o.vertex);

                o.normal = mul((float3x3)unity_ObjectToWorld, v.normal);

                o.uv = v.uv * _MainTex_ST.xy + _MainTex_ST.zw;

                return o;
            }

            fixed4 frag(VERTEX_OUT IN) : SV_Target
            {
                float3 Nn = normalize(IN.normal);
                float4 l_Color = tex2D(_MainTex, IN.uv);
                float3 l_DifuseLightning = float3(0, 0, 0);
                float l_Attenuation = 1.0;

                for (int i = 0; i < _LightsCount; i++)
                {
                    // Directional
                    float3 l_LightDirection = _LightDirections[i];

                    //Point y Spot
                    if (_LightTypes[i] == 2 || _LightTypes[i] == 0)
                    {
                        float3 l_LightDirectionNotNormalized = IN.WorldPosition - _LightPositions[i];
                        float l_DistancePixelLight = length(IN.WorldPosition - _LightPositions[i]);
                        l_LightDirection = l_LightDirectionNotNormalized / l_DistancePixelLight;
                        l_Attenuation = saturate(1 - l_DistancePixelLight / _LightProperties[i].x);

                        // Spot light
                        if (_LightTypes[i] == 0)
                        {
                            float l_SpotAngle = dot(_LightDirections[i], l_LightDirection);
                            float l_SpotAttenuation = saturate( (l_SpotAngle - _LightProperties[i].w) / (1.0 - _LightProperties[i].w));
                            
                            l_Attenuation *= l_SpotAttenuation;
                        }
                    }

                    float3 Kd = saturate(dot(Nn, -l_LightDirection));

                    l_DifuseLightning += Kd * l_Color.xyz * _LightColors[i] * _LightProperties[i].y * l_Attenuation;
                }

                return float4(l_DifuseLightning, l_Color.a);
            }
                ENDCG
    }
    }
}
