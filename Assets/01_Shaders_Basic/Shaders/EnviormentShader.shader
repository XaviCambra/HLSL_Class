Shader "Tecnocampus/EnviormentShader"
{
    Properties
    {
        _MainTex("_MainTex", 2D) = "defaulttexture" {}
        _EnvironmentTex("_EnvironmentTex", CUBE) = "" {}
        _EnvironmentPct("_EnvironmentPct", Range(0,1)) = 0.5
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

            sampler2D _MainTex;
            float4 _MainTex_ST;
            samplerCUBE _EnvironmentTex;
            float4 _EnvironmentTex_ST;
            float _EnvironmentPct;

            VERTEX_OUT vert(VERTEX_IN v)
            {
                VERTEX_OUT o;
                //o.vertex = UnityObjectToClipPos(v.vertex);
                //o.vertex=mul(UNITY_MATRIX_MVP, float4(v.vertex.xyz, 1.0));
                //o.vertex = mul(float4(v.vertex.xyz, 1.0), transpose(UNITY_MATRIX_MVP));
                o.vertex = mul(unity_ObjectToWorld, float4(v.vertex.xyz, 1.0));
                o.WorldPosition = o.vertex;
                o.vertex = mul(UNITY_MATRIX_V, o.vertex);
                o.vertex = mul(UNITY_MATRIX_P, o.vertex);

                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                o.normal = mul((float3x3)unity_ObjectToWorld, v.normal);

                return o;
            }

            fixed4 frag(VERTEX_OUT i) : SV_Target
            {
                float4 l_Color = tex2D(_MainTex, i.uv);
                float3 Vn = normalize(i.WorldPosition - _WorldSpaceCameraPos);
                float3 Nn = normalize(i.normal);
                float3 l_ReflectedVector = reflect(Vn, Nn);
                float4 l_EnvironmentColor = texCUBE(_EnvironmentTex, l_ReflectedVector);
                //return l_Color + l_EnvironmentColor * _EnvironmentPct;
                return l_Color * (1.0 - _EnvironmentPct) + l_EnvironmentColor * _EnvironmentPct;
            }
                ENDCG
    }
    }
}
