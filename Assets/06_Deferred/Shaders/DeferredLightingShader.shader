Shader "Tecnocampus/DeferredLightingShader"
{
    Properties
    {
        _MainTex("_MainTex", 2D) = "defaulttexture" {}
        _RT0("_RT0", 2D) = "defaulttexture" {}
        _RT1("_RT1", 2D) = "defaulttexture" {}
        _RT2("_RT2", 2D) = "defaulttexture" {}
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
                float3 WorldPosition : TEXCOORD1;
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
            sampler2D _RT0;
            sampler2D _RT1;
            sampler2D _RT2;

            float4 _LightColor;
            float4x4 _InverseViewMatrix;
            float4x4 _InverseProjectionMatrix;
            int _LightType;
            float4 _LightPosition;
            float4 _LightDirection;
            float4 _LightProperties;
            int _UseShadowMap;
            sampler2D _ShadowMap;
            float4x4 _ShadowMapViewMatrix;
            float4x4 _ShadowMapProjectionMatrix;
            float _ShadowMapBias;
            float _ShadowMapStrength;

            VERTEX_OUT vert(VERTEX_IN v)
            {
                VERTEX_OUT o;
                o.vertex = mul(unity_ObjectToWorld, float4(v.vertex.xyz, 1.0));
                o.WorldPosition = o.vertex.xyz;
                o.vertex = mul(UNITY_MATRIX_V, o.vertex);
                o.vertex = mul(UNITY_MATRIX_P, o.vertex);
                o.uv = v.uv;
                return o;
            }

            fixed4 frag(VERTEX_OUT i) : SV_Target
            {
                float4 l_Color = tex2D(_MainTex, i.uv);
                float l_Depth = tex2D(_RT2, i.uv).x;
                if (l_Depth == 0.0)
                    return l_Color;

                float3 l_WorldPosition = GetPositionFromZDepthView(l_Depth, i.uv, _InverseViewMatrix, _InverseProjectionMatrix);
                float4 l_AlbedoColor = tex2D(_RT0, i.uv);
                float3 Nn = normalize(Texture2Normal(tex2D(_RT1, i.uv).xyz));

                float3 l_LightDirection = _LightDirection.xyz;
                float3 Kd = saturate(dot(-l_LightDirection, Nn));
                float l_Attenuation = 1.0;
                float3 l_DifuseLightning = Kd * _LightProperties.y * l_Attenuation * _LightColor.xyz * l_AlbedoColor.xyz;

                float3 Vn = normalize(_WorldSpaceCameraPos.xyz - i.WorldPosition);
                float3 Hn = normalize(Vn - l_LightDirection);
                float l_SpecularPower = 1.0 / l_AlbedoColor;
                float Ks = pow(saturate(dot(Hn, Nn)), l_SpecularPower);

                float3 l_SpecularLightning = Ks * l_Color.xyz * _LightColor.xyz * _LightProperties.y * l_Attenuation;

                return float4(l_AlbedoColor.xyz + l_DifuseLightning + l_SpecularLightning, 1.0);
            }
            ENDCG
        }
    }
}
