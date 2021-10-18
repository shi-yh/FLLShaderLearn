// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "Custom/ShaderLearning"
{
		
	Properties{
		
			_MainTex("Main Texture",2D) = "white"{}
		
		}

	SubShader{
		
		Tags{
		
			"PreviewType" = "Plane"
		
		}

		Pass{
			
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
				float2 uv:TEXCOORD0;
			};

			v2f vert(appdata v){
			
				v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);
				o.uv = v.uv;
				return o;
			
			}


			float4 frag(v2f i):SV_TARGET{
			
				float4 color=float4(i.uv.r,i.uv.g,1,1);
				return color;
				
			}


			ENDCG
		
		}
	
	
	}



}
