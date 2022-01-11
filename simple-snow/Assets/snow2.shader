Shader "Custom/snow2"
{
    Properties
    {
        _MainTex ("Albedo (RGB)", 2D) = "white" {}
        _Glossiness ("Smoothness", Range(0,1)) = 0.5
        _Metallic ("Metallic", Range(0,1)) = 0.0
        _SnowAngle("Snow angle", Vector) = (.25, .5, .5, 1)
        _SnowColor("Snow color", Color) = (0.6678787, 0.8620635, 0.9622642, 1)
        _SnowSpread("Snow spread", Range(0.0, 1.0)) = 0.5
        _SnowHeight("Snow height", Range(0.0, 0.05)) = 0.01
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 200

        CGPROGRAM
        // Physically based Standard lighting model, and enable shadows on all light types
        #pragma surface surf Standard fullforwardshadows vertex:vert

        // Use shader model 3.0 target, to get nicer looking lighting
        #pragma target 3.0

        sampler2D _MainTex;

        struct Input
        {
            float2 uv_MainTex;
            float3 worldNormal;
        };

        half _Glossiness;
        half _Metallic;
        uniform float4 _SnowAngle;
        uniform float4 _SnowColor;
        uniform float _SnowSpread;
        uniform float _SnowHeight;

        // Add instancing support for this shader. You need to check 'Enable Instancing' on materials that use the shader.
        // See https://docs.unity3d.com/Manual/GPUInstancing.html for more information about instancing.
        // #pragma instancing_options assumeuniformscaling
        UNITY_INSTANCING_BUFFER_START(Props)
            // put more per-instance properties here
        UNITY_INSTANCING_BUFFER_END(Props)

        void vert (inout appdata_full v) {
            float3 normalWorld = UnityObjectToWorldNormal(v.normal);
            if (dot(normalWorld, _SnowAngle.xyz) > (1.0 - _SnowSpread * 0.2)) {
                v.vertex.xyz += v.normal * _SnowHeight;
            } 
        }

        void surf (Input IN, inout SurfaceOutputStandard o)
        {
            if (dot(IN.worldNormal, _SnowAngle) > (1.0 - _SnowSpread) && _SnowHeight > 0.0) {
                o.Albedo = _SnowColor.rgb;
                o.Metallic = 0.8;
                o.Smoothness = 0.2;
            } else {
                fixed4 c = tex2D (_MainTex, IN.uv_MainTex);
                o.Albedo = c.rgb;
                o.Metallic = _Metallic;
                o.Smoothness = _Glossiness;
            }
            o.Alpha = 1.0;
        }
        ENDCG
    }
    FallBack "Diffuse"
}
