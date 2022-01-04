Shader "Custom/Ice"
{
    Properties
    {
		_RampTex("Ramp", 2D) = "white" {}
        _BumpTex("Bump", 2D) = "white" {}
        _BumpRamp("Bump Ramp", 2D) = "white" {}
		_Color("Color", Color) = (1, 1, 1, 1)
		_EdgeThickness("Edge thickness", Range(0.0, 1.0)) = 0.5
    }
    SubShader
    {
        Tags { "Queue" = "Transparent" }
        Cull Off
        Blend SrcAlpha OneMinusSrcAlpha
        LOD 100

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
                float3 normal : NORMAL;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;
                float3 normal : NORMAL;
                float3 viewDir : TEXCOORD1;
            };

            sampler2D _RampTex;
            sampler2D _BumpTex;
            sampler2D _BumpRamp;
            uniform float4 _Color;
            uniform float _EdgeThickness;
            float4 _MainTex_ST;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = v.uv;

                const float4 normal4 = float4(v.normal, 0.0);
                o.normal = normalize(mul(normal4, unity_WorldToObject).xyz);
                o.viewDir = normalize(_WorldSpaceCameraPos - mul(unity_ObjectToWorld, v.vertex).xyz);

                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {                
				const float edgeFactor = abs(dot(i.viewDir, i.normal));				
                const float3 rgb = tex2D(_RampTex, float2(edgeFactor, 0.5)).rgb; // more white when looking directly
				const float opacityBase = min(1.0, _Color.a / edgeFactor); // more transparent when looking directly
				const float opacity = pow(opacityBase, _EdgeThickness);

                const float3 bump = tex2D(_BumpTex, i.uv.xy).rgb + i.normal.xyz ;
                const float3 lightDir = normalize(_WorldSpaceLightPos0.xyz);
                const float bumpRampX = clamp(dot(bump, lightDir), 0.001, 1.0);
				const float4 lighting = float4(tex2D(_BumpRamp, float2(bumpRampX, 0.5)).rgb, 1.0);

				return float4(rgb, opacity) * lighting;
            }
            ENDCG
        }
    }
}
