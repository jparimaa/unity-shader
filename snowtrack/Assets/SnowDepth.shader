Shader "Unlit/SnowDepth"
{
	Properties
	{
		_SnowDepthTex("Texture", 2D) = "black" {}
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

			sampler2D _SnowDepthTex;
			float4 _SnowDepthTex_ST;

			v2f vert(appdata v)
			{
				v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);
				o.uv = TRANSFORM_TEX(v.uv, _SnowDepthTex);
				return o;
			}

			fixed4 frag(v2f i) : SV_Target
			{
				return fixed4(i.vertex.z, 0.0, 0.0, 1.0);
			}
			ENDCG
		}
	}
}
