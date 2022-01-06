Shader "Custom/Ice"
{
    Properties
    {
        _DistortTex("Distort tex", 2D) = "white" {}
        _DistortStrength("Distort strength", Range(0.0, 1.0)) = 0.5
		_ColorRampTex("Color ramp", 2D) = "white" {}
        _BumpTex("Bump", 2D) = "white" {}
		_Transparency("Transparency", Range(0.0, 1.0)) = 0.5
		_EdgeThickness("Edge thickness", Range(0.0, 1.0)) = 0.5
    }

    SubShader
    {
        GrabPass
        {
            "_BackgroundTexture"
        }

        Pass
        {
            Tags { "Queue" = "Transparent" }

            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #include "UnityCG.cginc"

            sampler2D _BackgroundTexture;
            sampler2D _DistortTex;
            float _DistortStrength;

            struct appdata
            {
                float4 vertex : POSITION;
                float3 normal : NORMAL;
                float3 texCoord : TEXCOORD0;
            };

            struct v2f
            {
                float4 pos : SV_POSITION;
                float4 grabPos : TEXCOORD0;
            };

            v2f vert(appdata v)
            {
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);
                o.grabPos = ComputeGrabScreenPos(o.pos);

                const float2 bump = tex2Dlod(_DistortTex, float4(v.texCoord.xy, 0, 0)).rg * _DistortStrength;
                o.grabPos.x += bump.x;
                o.grabPos.y += bump.y;

                return o;
            }

            float4 frag(v2f i) : COLOR
            {
                return tex2Dproj(_BackgroundTexture, i.grabPos);
            }
            ENDCG
        }

        Pass
        {
            Tags { "Queue" = "Transparent" }
            Blend SrcAlpha OneMinusSrcAlpha
            LOD 100

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

            sampler2D _ColorRampTex;
            sampler2D _BumpTex;
            uniform float _Transparency;
            uniform float _EdgeThickness;

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
                const float3 rgb = tex2D(_ColorRampTex, float2(edgeFactor, 0.5)).rgb; // more white when looking directly
				const float opacityBase = min(1.0, _Transparency / edgeFactor); // more transparent when looking directly
				const float opacity = pow(opacityBase, _EdgeThickness);

                const float3 bump = tex2D(_BumpTex, i.uv.xy).r + 0.5;

				return float4(rgb * bump * 1.1, opacity);
            }
            ENDCG
        }
    }
}
