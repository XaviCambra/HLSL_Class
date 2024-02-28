    Shader "Tecnocampus / MotionBlurShader"
{
    Properties{
        _MainTex("Texture", 2D) = "white" {}
        _RT2("Depth", 2D) = "white" {}
        _NumSamples("_NumSamples", Integer) = 1
        [Toggle] _ShowDebug("Show Debug", Float) = 0
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
            sampler2D _RT2; //de aqui sacaremos la depth

            int _NumSamples;

            float4x4 _InverseViewMatrix;
            float4x4 _InverseProjectionMatrix;

            float4x4 _PreviousViewMatrix;
            float4x4 _PreviousProjectionMatrix;

            sampler2D _DepthTex;
            float _ShowDebug;

            v2f vert(VERTEX_IN v) //Vertex Shader Function
            {
                v2f o;
                o.vertex = mul(unity_ObjectToWorld, float4(v.vertex.xyz, 1.0));
                o.vertex = mul(UNITY_MATRIX_V, o.vertex);
                o.vertex = mul(UNITY_MATRIX_P, o.vertex);

                o.UVs = TRANSFORM_TEX(v.UVs, _MainTex);
                return o;

            }

            fixed4 frag(v2f IN) : SV_Target//Pixel Shader Function
            {
                float l_Depth = tex2D(_DepthTex, IN.UVs).x;
                if (l_Depth == 0.0)
                    return tex2D(_MainTex, IN.UVs);

                float4 l_WorldPosition = float4(GetPositionFromZDepthView(l_Depth, IN.UVs, _InverseViewMatrix, _InverseProjectionMatrix), 1.0);

                l_WorldPosition = mul(_PreviousViewMatrix, l_WorldPosition);
                l_WorldPosition = mul(_PreviousProjectionMatrix, l_WorldPosition);
                l_WorldPosition.xyz /= l_WorldPosition.w;
                l_WorldPosition.xy = l_WorldPosition.xy * 0.5 + 0.5;

                float2 l_VelocityVector = l_WorldPosition.xy- IN.UVs.xy;

                if (_ShowDebug == 1.0)
                    return float4(l_VelocityVector.xy, 0, 1);

                float4 l_BlurredColor= tex2D(_MainTex, IN.UVs);
                float l_TotalWeight = 1.0f;
                float l_BlurScale = unity_DeltaTime.y/ 30.0;
                // for (float i = 1; i < _NumSamples; i++)
                // {
                //     float2 l_Offset= l_BlurScale*l_VelocityVector*(float(i) / float(_NumSamples -1.0)- 0.5);
                //     l_BlurredColor+= tex2D(_MainTex, IN.UVs + l_Offset);
                //     ++l_TotalWeight;
                // }
                l_BlurredColor /= l_TotalWeight;
                return l_BlurredColor;
            }
                ENDCG
        }
    }
}

