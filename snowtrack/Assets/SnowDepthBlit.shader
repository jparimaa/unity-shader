Shader "Unlit/SnowDepthBlit"
{
	Properties
	{
		_NewDepth("New depth", 2D) = "black" {}
		_OldDepth("Old depth", 2D) = "black" {}
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

			sampler2D _NewDepth;
			float4 _NewDepth_ST;

			v2f vert(appdata v)
			{
				v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);
				o.uv = TRANSFORM_TEX(v.uv, _NewDepth);
				return o;
			}

			sampler2D _OldDepth;

			fixed4 frag(v2f i) : SV_Target
			{
				float newDepth = tex2D(_NewDepth, float2(1.0 - i.uv.x, i.uv.y)).r;
				float oldDepth = tex2D(_OldDepth, i.uv).r;

				return fixed4(max(oldDepth, newDepth), 0.0, 0.0, 1.0);
			}
			ENDCG
		}
	}
}
