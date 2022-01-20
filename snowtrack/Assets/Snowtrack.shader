Shader "Custom/Snowtrack"
{
    Properties
    {
        _Tess ("Tessellation", Range(1,32)) = 4
        _SnowColor ("Snow Color", Color) = (1,1,1,1)
        _SnowTex ("Snow (RGB)", 2D) = "white" {}
        _GroundColor ("Ground Color", Color) = (1,1,1,1)
        _GroundTex ("Ground (RGB)", 2D) = "white" {}
        _SnowDepthTex ("Snow Depth Texture", 2D) = "gray" {}
        _Displacement ("Displacement", Range(0, 1.0)) = 0.3
        _Glossiness ("Smoothness", Range(0,1)) = 0.5
        _Metallic ("Metallic", Range(0,1)) = 0.0
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 200

        CGPROGRAM
        #pragma surface surf Standard fullforwardshadows vertex:disp tessellate:tessDistance

        #pragma target 4.6

        #include "Tessellation.cginc"

        struct appdata {
            float4 vertex : POSITION;
            float4 tangent : TANGENT;
            float3 normal : NORMAL;
            float2 texcoord : TEXCOORD0;
        };

        float _Tess;

        float4 tessDistance (appdata v0, appdata v1, appdata v2) {
            float minDist = 10.0;
            float maxDist = 25.0;
            return UnityDistanceBasedTess(v0.vertex, v1.vertex, v2.vertex, minDist, maxDist, _Tess);
        }

        sampler2D _SnowDepthTex;
        float _Displacement;

        void disp (inout appdata v)
        {
            v.vertex.xyz += v.normal * _Displacement;
            float d = tex2Dlod(_SnowDepthTex, float4(v.texcoord.xy,0,0)).r * _Displacement;
            v.vertex.xyz -= v.normal * d;
        }

        sampler2D _SnowTex;
        fixed4 _SnowColor;
        sampler2D _GroundTex;
        fixed4 _GroundColor;

        struct Input
        {
            float2 uv_SnowTex;
            float2 uv_GroundTex;
            float2 uv_SnowDepthTex;
        };

        half _Glossiness;
        half _Metallic;

        // Add instancing support for this shader. You need to check 'Enable Instancing' on materials that use the shader.
        // See https://docs.unity3d.com/Manual/GPUInstancing.html for more information about instancing.
        // #pragma instancing_options assumeuniformscaling
        UNITY_INSTANCING_BUFFER_START(Props)
        UNITY_INSTANCING_BUFFER_END(Props)

        void surf (Input IN, inout SurfaceOutputStandard o)
        {
            const fixed4 snow = tex2D (_SnowTex, IN.uv_SnowTex) * _SnowColor;
            const fixed4 ground = tex2D (_GroundTex, IN.uv_GroundTex) * _GroundColor;
            const fixed4 amount =  tex2Dlod(_SnowDepthTex, float4(IN.uv_SnowDepthTex,0,0)).r;
            const fixed4 c = lerp(snow, ground, pow(amount,20));
            o.Albedo = c.rgb;
            o.Metallic = _Metallic;
            o.Smoothness = _Glossiness;
            o.Alpha = c.a;
        }
        ENDCG
    }
    FallBack "Diffuse"
}
