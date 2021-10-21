// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "Custom/OverDrawEffect"
{
    SubShader{
    
        Tags{
        
            "RenderType" = "Opaque" 

        }

        ///无论深度缓冲里面是什么，颜色都会被渲染到屏幕上
        //ZTest Always

        ///不需要深度缓冲
        //ZWrite Off

        ///添加性混合的意思。让帧缓冲区源颜色和目标颜色完全的通过，也就是将贴图本身和其背后背景叠加，输出叠加颜色。
        //Blend One One

        Pass{
        
            CGPROGRAM

            #pragma vertex vert
            #pragma fragment frag 
            #include "UnityCG.cginc"



           

            half4 _OverDrawColor;
            
            sampler2D _MainTex2;

            fixed4 frag(v2f i):SV_TARGET{
            
                fixed4 color = tex2D(_MainTex2,i.uv);


                return color;
            
            }


            ENDCG
        
        
        }
    }

    SubShader{
    
        Tags{
        
			"RenderType" = "Transparent"

        }

        ///无论深度缓冲里面是什么，颜色都会被渲染到屏幕上
        //ZTest Always

        ///不需要深度缓冲
        //ZWrite Off

        ///添加性混合的意思。让帧缓冲区源颜色和目标颜色完全的通过，也就是将贴图本身和其背后背景叠加，输出叠加颜色。
        Blend One One

        Pass{
        
            CGPROGRAM

            #pragma vertex vert
            #pragma fragment frag 
            #include "UnityCG.cginc"

            half4 _OverDrawColor;

            sampler2D _SecondTex2;


            fixed4 frag(v2f i):SV_TARGET{
            
                float4 color = tex2D(_SecondTex2,i.uv);
                return color;            
            }


            ENDCG
        
        
        }
    }


    CGINCLUDE

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
                o.uv=v.uv;

                return o;
            }

    ENDCG



}