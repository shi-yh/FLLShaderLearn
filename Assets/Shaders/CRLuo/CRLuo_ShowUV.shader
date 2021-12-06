///UV动画
Shader "CRLuo/CRLuo_ShowUV"
{
    Properties
    {
        _Color("颜色",Color) = (1,1,1,1)
        
        _MainTex ("Texture", 2D) = "white" {}
        
        _MoveSpeed_U("U向移动速度",Range(-10,10)) = 0
        _MoveSpeed_V("V向移动速度",Range(-10,10)) = 0
        
        _UVRampTex("渐变贴图",2D) = "white"{}
        
        _AddPow("顶端火焰范围",Range(1,50)) = 40
        _MultiplyPow("底端消失范围",Range(0,1))=0.3
    }
    SubShader
    {
        Tags { "RenderType"="Transparent" 
                "Queue" = "Transparent"
            }
        LOD 100

        Pass
        {
            Blend One One
            Cull Off
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            // make fog work
            #pragma multi_compile_fog

            #include "UnityCG.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                UNITY_FOG_COORDS(1)
                float4 vertex : SV_POSITION;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;

            float4 _Color;

            float _MoveSpeed_U;
            float _MoveSpeed_V;
            
            sampler2D _UVRampTex;

            float _AddPow;
            float _MultiplyPow;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);

                //把模型的UV添加 属性中的UV调节 如果UV不变化可以写o.uv = v.uv 
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                UNITY_TRANSFER_FOG(o,o.vertex);
                return o;
            }

            
            /**
             * \brief 使用贴图的方式完成喷射渐变
             * \param col 原始颜色 
             * \param i 片源着色器元数据
             * \return RETURN 最终颜色
             */
            fixed4 AnamorphismByMask(fixed4 col,v2f i)
            {
                 fixed4 ramp=tex2D(_UVRampTex,i.uv);

                //颜色叠加透明，让拉丝效果更加明显
                col.rgb*=col.a;
                //用白色渐变少的贴图，提亮贴图的上半部分
                col.rgb+=ramp.b;
                //用白色渐变多的贴图，压暗贴图的上半部分
                col.rgb*=ramp.g;

                return col;
            }

            
            /**
             * \brief 使用数学方法完成喷射渐变
             * \param col 原始颜色
             * \param i 着色器数据
             * \return col
             */
            fixed4 AnamorphismByMath(fixed4 col,v2f i)
            {
                /// 越靠下，y越小，pow总值越小，黑色越多，越不影响
                col += pow(i.uv.y,_AddPow)*_AddPow;

                ///越靠下，y越小，pow总值越大，影响越大
                col *= pow(i.uv.y,_MultiplyPow);

                return col;
            }
            

            fixed4 frag (v2f i) : SV_Target
            {
                //组织二维的UV偏移坐标*时间变量
                //_Time是Shader内置的时间变量
                float uvOffset = float2(_MoveSpeed_U,_MoveSpeed_V)*_Time.y ;
                // sample the texture
                fixed4 col = tex2D(_MainTex, i.uv+uvOffset);


               col=AnamorphismByMath(col,i);

                
                clip(col.r-0.5);

                col*=_Color;
                // apply fog
                UNITY_APPLY_FOG(i.fogCoord, col);
                
                return col;
            }
            ENDCG
        }
    }
}
