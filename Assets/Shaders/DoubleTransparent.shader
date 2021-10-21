// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "Custom/DoubleTransparent"
{
	Properties{
	
		_MainTex("Main Tex",2D)="white"{}
		_SecondTex("Second Text",2D)="white"{}
		_DisplacementTex("Displacement Text",2D)="white"{}
		_Magnitude("Magnitude",Range(0,1))=0
	}
   
   SubShader{
   
		Tags{
		
			"Queue" = "Transparent"

		}

		Pass
		{
		
			Blend SrcAlpha OneMinusSrcAlpha

			Cull Back

			ZWrite Off

			CGPROGRAM


			#pragma vertex vert
			#pragma fragment frag
			#include "UnityCG.cginc"

			float4 frag(v2f i) : SV_TARGET
			{
				float2 distuv=float2(i.uv.x+_Time.x*2,i.uv.y+_Time.x*2)	;

				float2 disp=tex2D(_DisplacementTex,distuv);

				disp=((disp*2)-1)*_Magnitude;

				float4 color=tex2D(_MainTex,i.uv+disp);

				return color;
		
			}



			ENDCG

		
		}

		
		Pass{
		
			Blend SrcAlpha OneMinusSrcAlpha

			Cull Back 

			ZWrite Off

			CGPROGRAM

			#pragma vertex vert
			#pragma fragment frag 
			#include "UnityCG.cginc"
		



			float4 frag(v2f i) : SV_Target
			{
				
				float4 color = tex2D(_SecondTex, i.uv);

				//if(color.a > 0){
				
				//	color=float4(1,1,1,1);
				
				//}

				


				return color;
			}



			ENDCG

		
		
		}


   }

   CGINCLUDE

	sampler2D _MainTex;
	sampler2D _SecondTex;
	sampler2D _DisplacementTex;
	float _Magnitude;

   struct appdata
   {
			
		float4 vertex:POSITION;
		float2 uv:TEXCOORD1;
			
	};

	struct v2f{
			
		float4 vertex :SV_POSITION;

		float2 uv:TEXCOORD1;

	};

	v2f vert(appdata v)
	{
		v2f o;
		o.vertex = UnityObjectToClipPos(v.vertex);
		o.uv = v.uv;
		return o;
	}
			
	ENDCG

}
