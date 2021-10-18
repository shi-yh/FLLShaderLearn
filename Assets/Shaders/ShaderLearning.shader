// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "Custom/ShaderLearning"
{
		
	Properties{
		
			_MainTex("Main Texture",2D) = "white"{}
		
		}

	SubShader{
		
		Tags{
		
			"PreviewType" = "Plane"
			"Queue" = "Transparent"
		}

		Pass{
			
			///将源颜色乘上源颜色的透明度，与目标颜色乘（1 - 原颜色的透明度）的结果相加
			///OutColor = SrcColor * ScrAlpha + DstColor * (1 - SrcAlpha)
			Blend SrcAlpha OneMinusSrcAlpha

			CGPROGRAM

			#pragma vertex vert
			#pragma fragment frag

			#include "UnityCG.cginc"

			sampler2D _MainTex;



			struct appdata{
				
				float4 vertex:POSITION;
				float2 uv:TEXCOORD0;
			};

			struct v2f{
			
				float4 vertex:SV_POSITION;
				float2 uv:TEXCOORD1;
			};

			v2f vert(appdata v){
			
				v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);
				o.uv = v.uv;
				return o;
			
			}


			float4 frag(v2f i):SV_TARGET
			{
			
				//float4 color = tex2D(_MainTex, i.uv);
				//color *= float4(i.uv.r, i.uv.g, 0, 1);
				//return color;
				float4 color = float4(i.uv.r,i.uv.g, 0, 1);
				return color;
			}


			ENDCG
		
		}
	
	
	}



}
