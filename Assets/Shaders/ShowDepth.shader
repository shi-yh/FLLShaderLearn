// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "Custom/ShowDepth"
{
	
	Properties{
	
		_Color("Color",Color)=(1,1,1,1)
	
	}

    SubShader
	{
		Tags { "RenderType" = "Opaque" }
		Pass{

		        CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag

			#include "UnityCG.cginc"

			half4 _Color;

			struct appdata
			{
				float4 vertex : POSITION;
			};

			struct v2f
			{
				float4 vertex : SV_POSITION;
				float depth : DEPTH;
			};

			v2f vert(appdata v)
			{
				v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);
				o.depth = -mul(UNITY_MATRIX_MV, v.vertex).z * _ProjectionParams.w;

				return o;
			}

			float4 frag(v2f i) : SV_Target
			{
				float invert = 1 - i.depth;
				return float4(invert, invert, invert, 1)*_Color;
			}
			ENDCG
		}
	}

	SubShader
	{
		///关闭深度写入
		ZWrite Off
		///开启混合模式
		Blend SrcAlpha OneMinusSrcAlpha

		Tags { "RenderType" = "Transparent" }
		
		Pass{

		    CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag

			#include "UnityCG.cginc"

			half4 _Color;

			struct appdata
			{
				float4 vertex : POSITION;
			};

			struct v2f
			{
				float4 vertex : SV_POSITION;
			};

			v2f vert(appdata v)
			{
				v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);

				return o;
			}

			float4 frag(v2f i) : SV_Target
			{
				return _Color;
			}
			ENDCG
		}
	}


}