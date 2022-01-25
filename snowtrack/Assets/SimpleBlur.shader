Shader "Unlit/SimpleBlur"
{
	Properties
	{
		_MainTex("Texture", 2D) = "black" {}
	}
		SubShader
	{
		Tags { "RenderType" = "Opaque" }
		LOD 100

		Pass
		{
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			// make fog work
			#pragma multi_compile_fog

			#include "UnityCG.cginc"

			struct appdata
			{
				float4 vertex : POSITION;
				float2 uv : TEXCOORD0;
			};

			struct v2f
			{
				float2 uv : TEXCOORD0;
				float4 vertex : SV_POSITION;
			};

			sampler2D _MainTex;
			float4 _MainTex_ST;

			v2f vert(appdata v)
			{
				v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);
				o.uv = TRANSFORM_TEX(v.uv, _MainTex);
				return o;
			}

			fixed4 frag(v2f i) : SV_Target
			{
				float4 col = 0;
				const float2 uv = float2(i.uv.x, i.uv.y);
				const float xStep = (1.0 / 256.0);
				const float yStep = (1.0 / 256.0);
				int sampleCount = 0;
				int from = -2;
				int to = 3;
				// Inefficient but for the sake of demo
				for (int i = from; i < to; ++i) {
					for (int j = from; j < to; ++j) {
						float2 offset = float2(i * xStep, j * yStep);
						float4 s = tex2D(_MainTex, uv + offset);
						col += s;
						++sampleCount;
					}
				}

				return col / (sampleCount * 0.7);
			}
			ENDCG
		}
	}
}
