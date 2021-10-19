// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "Custom/ShaderLearning"
{
		
	Properties{
		
			_MainTex("Main Texture",2D) = "white"{}
			_SubTex("Main Texture",2D) = "white"{}
			_DisplacementTex("Displacement Texture",2D) = "white"{}
			_Magnitude("Magnitude",Range(0,1))=0
			_Color("Color Tint",Color)=(0,0,0,0)
			_Tween("Tween",Range(0,1))=0


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
			sampler2D _SubTex;
			sampler2D _DisplacementTex;
			float _Magnitude;
			fixed4 _Color;
			float _Tween;



			float4 _MainTex_ST;
			float4 _SubTex_ST;

			struct appdata{
				
				float4 vertex:POSITION;
				float2 uv:TEXCOORD0;
			};

			struct v2f{
			
				float4 vertex:SV_POSITION;
				float2 uv[2]:TEXCOORD0;
			};


			///扭曲效果
			float4 distortion(v2f i){
				
				float2 distuv = float2(i.uv[0].x*_Time.x*2,i.uv[0].y+_Time.x*2);

				///定义了一个float2的disp来对位移图进行采样
				float2 disp = tex2D(_DisplacementTex, distuv).xy;				
				///因为从uv中获取的值是介于0到1之间的，
				///这样的数值算出来的扭曲效果会不明显，
				///所以要让值定位到-1到1之间，
				///让界面有飘来飘去的感觉，
				///并乘上magnitude让我们可以控制强度
				disp = ((disp * 2) - 1) * _Magnitude;
				///uv偏移
				float4 color = tex2D(_MainTex, i.uv[0] + disp);
				
				return color;
			}


			///颜色叠加
			float4 mulColor(v2f i){
			
				float4 color=tex2D(_MainTex,i.uv[0]);

				color *= _Color;

				return color;
			}

			///根据uv叠加
			float4 mulUVColor(v2f i){
			
				float4 color=tex2D(_MainTex,i.uv[0]);
				color *= float4(i.uv[0].r,i.uv[0].g,0,1);
				return color;
			}

			///混合图像
			float4 tweenTex2d(v2f i){
			
				float4 color = tex2D(_MainTex,i.uv[0]);

				float4 subColor=tex2D(_SubTex,i.uv[1]);
				

				return lerp(color,subColor,_Tween);
			}

			
			///重复图像
			float4 repeatTex(v2f i){
				
			
				float4 color = tex2D(_MainTex,i.uv[0]*2);

				return color;
			}

			///灰化
			float4 Gray(v2f i){
			
				float4 color = tex2D(_MainTex,i.uv[0]);

				float grayValue=0.2125*color.r+0.07154*color.g+0.0721*color.b;
			
				return float4(grayValue,grayValue,grayValue,color.a);
			}

			///灰化再乘
			float4 GrayMul(v2f i){
			
				float4 color = tex2D(_MainTex,i.uv[0]);

				float grayValue=0.2125*color.r+0.07154*color.g+0.0721*color.b;
			
				return float4(grayValue,grayValue,grayValue,color.a)*_Color;
			}


			v2f vert(appdata v){
			
				v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);
				o.uv[0] = TRANSFORM_TEX(v.uv,_MainTex);
				o.uv[1] = TRANSFORM_TEX(v.uv,_SubTex);
				return o;
			
			}



			float4 frag(v2f i):SV_TARGET
			{
				
				float4 color = GrayMul(i);

				return color;
			}


			


			ENDCG
		
		}
	
	
	}



}
