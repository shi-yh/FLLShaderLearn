// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "Unity Shader Book/Chapter 5/Simple Shader"{

	
	Properties{
	
		_Color("Color Tint",Color)=(1.0,1.0,1.0,1.0)
	
	}


	SubShader{
	
		Pass{
			
			CGPROGRAM

			#include "UnityCG.cginc"

			///告诉编译器顶点着色器用这个代码
			#pragma vertex vert
			///告诉编译器片源着色器用这个代码
			#pragma fragment frag

			///在CG代码中，我们要定义一个属性名称和类型都匹配的变量
			fixed4 _Color;

			//Application2vertex
			struct a2v{
				
				///告诉Unity,用模型空间的顶点坐标填充vertex变量
				float4 vertex:POSITION;
				///告诉Unity,用模型空间的发现向量填充normal
				float3 normal:NORMAL;
				///告诉Unity，用模型的第一套纹理填充texcoord
				float4 texcoord: TEXCOORD0;
			
			};


			//vertex2frag
			struct v2f{
				
				//告诉Unity，pos中包含了顶点在裁剪空间中的信息
				float4 pos:SV_POSITION;
				///告诉Unity，color用于存储颜色信息
				fixed3 color:COLOR0;
			
			};



			v2f vert(a2v v){
				
				v2f o;

				o.pos = UnityObjectToClipPos(v.vertex);
				
				///normal的值在-1~1之间，通过这个计算，将颜色映射到了0~1
				o.color=v.normal*0.5+fixed3(0.5,0.5,0.5);

				return o;
			}

			fixed4 frag(v2f i):SV_Target{
			
				fixed3 c = i.color;

				c *= _Color.rgb;
				
				return fixed4(c,1.0);
			}

			ENDCG
		
		
		
		}
	
	}
}