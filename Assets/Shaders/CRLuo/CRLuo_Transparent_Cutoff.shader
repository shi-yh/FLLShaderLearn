///剔除透明和混合透明的光照
Shader "CRLuo/CRLuo_Transparent_Cutoff"
{
    Properties
    {
        _Color("颜色",Color)=(1,1,1,1)
        _MainTex ("Texture", 2D) = "white" {}
        _Cutoff("透明裁剪",Range(0,1)) = 0.5
        
        [Enum(UnityEngine.Rendering.BlendMode)] _SrcBlend("SrcBlend",float) = 1
        [Enum(UnityEngine.Rendering.BlendMode)] _DstBlend("DstBlend",float) = 0
        
    }
    SubShader
    {
        Tags 
        { 
            //指明是使用了透明度混合的shader
            "RenderType"="Transparent"
            //不受到投影影响
            "IgnoreProject" = "True"
            //Queue渲染队列用Transparent标明透明混合队列
            "Queue" = "Transparent"
             
        }
        
        LOD 100

        Pass
        {
            Blend [_SrcBlend][_DstBlend]
            
            ZWrite Off
            
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
                float4 screenPos:TEXCOORD1;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;
            float4 _Color;
            float _Cutoff;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                UNITY_TRANSFER_FOG(o,o.vertex);

                //物体顶点左边转屏幕坐标
                o.screenPos = ComputeScreenPos(o.vertex); 
                
                return o;
            }

            //抖动剔除相关函数
            void CullFunc(fixed4 col,v2f i)
            {
                //https://zhuanlan.zhihu.com/p/387486705 17级灰度的抖动顺序矩阵
                float4x4 thresholdMatrix={

                    1.0/17.0,9.0/17.0,3.0/17.0,11.0/17.0,
                    13.0/17.0,5.0/17.0,15.0/17.0,7.0/17.0,
                    4.0/17.0,12.0/17.0,2.0/17.0,10.0/17.0,
                    16.0/17.0,8.0/17.0,14.0/17.0,6.0/17.0
                };

                float4x4 _RowAccess={1,0,0,0,0,1,0,0,0,0,1,0,0,0,0,1};

                //获取屏幕坐标0-1，w为缩放变量
                float2 pos= i.screenPos.xy/i.screenPos.w;

                //0-1坐标*像素总数
                pos*=_ScreenParams.xy;

                clip(col.a-thresholdMatrix[fmod(pos.x,4)]*_RowAccess[fmod(pos.y,4)]);
                
            }
            
            fixed4 frag (v2f i) : SV_Target
            {
                // sample the texture
                fixed4 col = tex2D(_MainTex, i.uv);

                CullFunc(col,i);
                
                col*=_Color;
                // apply fog
                UNITY_APPLY_FOG(i.fogCoord, col);
                return col;
            }
            ENDCG
        }
    }
}
