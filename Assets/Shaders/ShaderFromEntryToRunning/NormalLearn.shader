// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "Custom/NormalLearn"
{

	SubShader
	{
	
		Tags
		{
		
			"LightMode" = "ForwardBase"

		}


		Pass
		{
			ZTest Always
			Blend One One

			CGPROGRAM
			#pragma vertex vert 
			#pragma fragment frag
			#include "UnityCG.cginc"
			#include "Lighting.cginc"

			struct appdata{
				
				float4 vertex:POSITION;
				float3 normal:NORMAL;
			
			};

			struct v2f{
			
				float4 vertex:SV_POSITION;
				float3 normal:NORMAL;
				float3 viewDir:TEXCOORD0;

			};

			v2f vert(appdata v){
			
				v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);
				o.normal = normalize(mul(v.normal,(float3x3)unity_WorldToObject));
				o.viewDir = normalize(_WorldSpaceCameraPos.xyz - mul(unity_ObjectToWorld, v.vertex).xyz);
				return o;
			}

			float4 frag(v2f i):SV_Target
			{
				float ndotV= 1- dot(i.normal,i.viewDir)*2;
				return float4(ndotV,ndotV,ndotV,1);
			}


			ENDCG
			
		}
	}
}