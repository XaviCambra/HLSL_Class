Shader "Tecnocampus/BillboardShader"
{
    Properties
    {
        _MainTex("_MainTex", 2D) = "defaulttexture" {}
        [Toggle] _UseUpVector("_UseUpVector", Float) = 1.0
        _Size("_Size", Float) = 1.0
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
            float _UseUpVector;
            float4 _RightDirection;
            float4 _UpDirection;
            float _Size;

            VERTEX_OUT vert(VERTEX_IN v)
            {
                VERTEX_OUT o;
                float3 l_PivotWorldPosition = float3(unity_ObjectToWorld[0].w, unity_ObjectToWorld[1].w, unity_ObjectToWorld[2].w);
                float2 l_Direction = v.uv - float2(0.5, 0.5);
                float3 l_WorldPosition = l_PivotWorldPosition + l_Direction.x * _RightDirection.xyz * _Size + l_Direction.y * (_UseUpVector == 0.0 ? float3(0.0, 1.0, 0.0) : _UpDirection.xyz) * _Size;

                o.vertex = mul(UNITY_MATRIX_V, float4(l_WorldPosition, 1.0));
                o.vertex = mul(UNITY_MATRIX_P, o.vertex);

                o.uv = v.uv * _MainTex_ST.xy + _MainTex_ST.zw;

                return o;
            }

            fixed4 frag(VERTEX_OUT i) : SV_Target
            {
                float4 l_Color = tex2D(_MainTex, i.uv);
                return l_Color;
            }
                ENDCG
    }
    }
}
