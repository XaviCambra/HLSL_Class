Shader "Tecnocampus / DeferredZBlurShader_2"
{
    Properties{
        _MainTex("Texture", 2D) = "white" {}
        _RT2("Depth", 2D) = "white" {}
        _SampleDistance("Sample distance", Range(1, 20.0)) = 1.0
        _ZMinFocusDistance("Z min focus distance", float) = 3.0
        _ZMaxFocusDistance("Z max focus distance", float) = 3.0
        _ZMaxUnfocusDistance("Z max unfocus distance", float) = 5.0
        _MinZBlurPct("Min ZBlur Pct", Range(0.0, 1.0)) = 0.0
        _ShowDebug("Show debug", float) = 0.0
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

            struct DeferredFragmentColors {
                float4 color0:COLOR0;
                float4 color1:COLOR1;
                float4 color2:COLOR2;
            };

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
            sampler2D _RT2; //de aqui sacaremos la depth

            float4x4 _InverseViewMatrix;
            float4x4 _InverseProjectionMatrix;

            sampler2D _DepthTex;
            float _SampleDistance;
            float _ZMinFocusDistance;
            float _ZMaxFocusDistance;
            float _ZMaxUnfocusDistance;
            float _MinZBlurPct;
            float _ShadowDebug;

            VERTEX_OUT vert(VERTEX_IN v)
            {
                VERTEX_OUT o;

                

                o.vertex = mul(unity_ObjectToWorld, float4(v.vertex.xyz, 1.0)); //Lo multiplica a matriz de mundo y lo convierte a coordenadas de mundo
                o.vertex = mul(UNITY_MATRIX_V, o.vertex); //Lo multiplica a matriz de view y lo convierte a coordenadas de view
                o.vertex = mul(UNITY_MATRIX_P, o.vertex); //Lo multiplica a matriz de proyeccion y lo convierte a coordenadas de proyeccion 

                o.uv = TRANSFORM_TEX(v.uv, _MainTex);  //TransformTex permite multiplicar el tiling y sumar en offset
                return o;

            }

            fixed4 frag(VERTEX_OUT IN) : SV_Target
            {
                float4 l_FocusedColor = tex2D(_MainTex, IN.uv);
                float l_Depth = tex2D(_RT2, IN.uv).x;
                float4 l_DebugColor;
                float l_ZBlurPct;

                if (l_Depth == 0.0)
                    return l_FocusedColor;

                
                float3 l_WorldPosition = GetPositionFromZDepthView(l_Depth.x, IN.uv, _InverseViewMatrix, _InverseProjectionMatrix);

                float3 l_UnfocusedColor = float3(0, 0, 0);

                float2 l_KernelBase[7] =
                {
                    { 0.0,  0.0 },
                    { 1.0,  0.0 },
                    { 0.5,  0.8660 },
                    { -0.5,  0.8660 },
                    { -1.0,  0.0 },
                    { -0.5, -0.8660 },
                    { 0.5, -0.8660 },
                };
                float l_KernelWeights[7] =
                {
                    0.38774,
                    0.06136,
                    0.24477 / 2.0,
                    0.24477 / 2.0,
                    0.06136,
                    0.24477 / 2.0,
                    0.24477 / 2.0,
                };

                float l_Distance = length(l_WorldPosition.xyz - _WorldSpaceCameraPos.xyz);
                if (l_Distance < _ZMinFocusDistance)
                {
                    l_DebugColor = float4(1, 0, 0, 1);
                    l_ZBlurPct = _MinZBlurPct;
                }
                else if (l_Distance < _ZMaxFocusDistance)
                {
                    l_ZBlurPct = 0.0;
                    l_DebugColor = float4(0, 1, 0, 1);
                }
                else
                {
                    l_ZBlurPct = saturate((l_Distance - _ZMaxFocusDistance) / (_ZMaxUnfocusDistance - _ZMaxFocusDistance));
                    l_DebugColor = lerp(float4(0, 1, 0, 1), float4(0, 0, 1, 1), l_ZBlurPct);
                }

                for (int i = 0; i < 7; i++)
                {
                    float2 l_UVScaled = float2(1.0 / _ScreenParams.x, 1.0 / _ScreenParams.y) * _SampleDistance;
                    l_UnfocusedColor.xyz += tex2D(_MainTex, IN.uv + l_UVScaled * l_KernelBase[i]).xyz * l_KernelWeights[i];
                }

//#if _EXECUTIONTYPE_FOCUS
//                 // return l_FocusedColor;
//#elif _EXECUTIONTYPE_UNFOCUS
//                 // return float4(l_UnfocusedColor, 1.0);
//#elif _EXECUTIONTYPE_DEBUG
//                 // return l_DebugColor;
//#endif
                //return l_DebugColor;
                return float4(l_FocusedColor.xyz * (1.0 - l_ZBlurPct) + l_UnfocusedColor.xyz * l_ZBlurPct, 1.0);
            }
                ENDCG
        }
    }
}

