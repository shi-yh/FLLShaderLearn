// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "Custom/OverDrawEffect"
{
    SubShader{
    
        Tags{
        
            "Queue" = "Transparent"

        }

        ///无论深度缓冲里面是什么，颜色都会被渲染到屏幕上
        ZTest Always

        ///不需要深度缓冲
        ZWrite Off

        ///添加性混合的意思。让帧缓冲区源颜色和目标颜色完全的通过，也就是将贴图本身和其背后背景叠加，输出叠加颜色。
        Blend One One

        Pass{
        
            CGPROGRAM

            #pragma vertex vert
            #pragma fragment frag 
            #include "UnityCG.cginc"

            struct appdata{
            
                float4 vertex:POSITION;

            };

            struct v2f{
            
                float4 vertex:SV_POSITION;

            };

            v2f vert(appdata v){
            
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                
                return o;
            }

            half4 _OverDrawColor;

            fixed4 frag(v2f i):SV_TARGET{
            
                return _OverDrawColor;
            
            }


            ENDCG
        
        
        }




    }
}
