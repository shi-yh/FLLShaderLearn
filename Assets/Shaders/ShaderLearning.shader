// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "Custom/ShaderLearning"
{
		
	Properties{
		
			_MainTex("Main Texture",2D) = "white"{}
			_DisplacementTex("Displacement Texture",2D) = "white"{}
			_Magnitude("Magnitude",Range(0,1))=0
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
			sampler2D _DisplacementTex;
			float _Magnitude;


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
				float2 distuv = float2(i.uv.x*_Time.x*2,i.uv.y+_Time.x*2);

				///定义了一个float2的disp来对位移图进行采样
				float2 disp = tex2D(_DisplacementTex, distuv).xy;				
				///因为从uv中获取的值是介于0到1之间的，
				///这样的数值算出来的扭曲效果会不明显，
				///所以要让值定位到-1到1之间，
				///让界面有飘来飘去的感觉，
				///并乘上magnitude让我们可以控制强度
				disp = ((disp * 2) - 1) * _Magnitude;
				///uv偏移
				float4 color = tex2D(_MainTex, i.uv + disp);

				return color;
			}


			ENDCG
		
		}
	
	
	}



}
