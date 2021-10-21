// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "Custom/DoubleTransparent"
{
	Properties{
	
		_MainTex("Main Tex",2D)="white"{}
		_SecondTex("Second Text",2D)="white"{}

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
				float4 color=tex2D(_MainTex,i.uv);

				return color;
		
			}



			ENDCG

		
		}

		
		Pass{
		
			Blend SrcAlpha OneMinusSrcAlpha

			Cull Front 

			ZWrite Off

			CGPROGRAM

			#pragma vertex vert
			#pragma fragment frag 
			#include "UnityCG.cginc"
		
			float4 frag(v2f i) : SV_Target
			{
				float4 color = tex2D(_SecondTex, i.uv);
				return color;
			}



			ENDCG

		
		
		}


   }

   CGINCLUDE

   sampler2D _MainTex;
   sampler2D _SecondTex;

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
