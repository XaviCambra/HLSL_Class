Shader "Tecnocampus/ScratchedFilmShader"
{
    Properties
    {
        _MainTex("_MainTex", 2D) = "" {}
        _Noise("_Noise", 2D) = "" {}
        _Speed("_Speed", Float) = 0.5
        _ScratchThreshold("_ScratchThreshold", Float) = 0.5
        _ScratchIntensity("_ScratchIntensity", Float) = 0.5
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
            sampler2D _Noise;
            float _Speed;
            float _ScratchThreshold;
            float _ScratchIntensity;

            VERTEX_OUT vert(VERTEX_IN v)
            {
                VERTEX_OUT o;
                o.vertex = mul(unity_ObjectToWorld, float4(v.vertex.xyz, 1.0));
                o.vertex = mul(UNITY_MATRIX_V, o.vertex);
                o.vertex = mul(UNITY_MATRIX_P, o.vertex);
                o.uv = v.uv;
                return o;
            }

            fixed4 frag(VERTEX_OUT i) : SV_Target
            {

                float4 l_Color = tex2D(_MainTex,i.uv);
                float l_Scratch = tex2D(_Noise, float2(i.uv.x, _Time.y * _Speed)).x;
                l_Scratch = l_Scratch > _ScratchThreshold ? (l_Scratch - _ScratchThreshold) / (1.0 - _ScratchThreshold) : 0;
                return l_Color - float4(l_Scratch.xxx,0) * _ScratchIntensity;
            }
                ENDCG
    }
    }
}
