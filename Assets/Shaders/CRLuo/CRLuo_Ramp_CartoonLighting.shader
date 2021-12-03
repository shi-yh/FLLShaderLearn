Shader "CRLuo/Ramp_Cartoonlighting"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        
        
        _Color_H("向光色",Color) = (1,1,1,1)
        
        _Color_M("中间色",Color) = (0,0,0,1)
        
        _Color_L("背光色",Color) = (0.5,0.5,0.5,1)
        
        _LightLevel("色级",Range(1,10))=3
        
        _RampTex("渐变贴图",2D) = "white"{}
        
        
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 100

        Pass
        {
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

                //表面法线
                half3 normal:NORMAL;
                
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                UNITY_FOG_COORDS(1)
                float4 vertex : SV_POSITION;

                //顶点片段输出数据添加世界法线
                half3 worldNormal:NORMAL;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                UNITY_TRANSFER_FOG(o,o.vertex);

                //物体空间法线转世界空间法线
                o.worldNormal = UnityObjectToWorldNormal(v.normal);
                
                return o;
            }


            fixed4 _Color_H;
            fixed4 _Color_M;
            fixed4 _Color_L;
            int _LightLevel;
            
            sampler2D _RampTex;

            
            /**
             * \brief 数学方法自定义卡通渐变色函数
             * \param _ramp 渐变过程
             * \param _level 颜色级数
             * \param _Color_H 向光色
             * \param _Color_M 中间色
             * \param _Color_L 背光色
             * \return RETURN
             */
            fixed4 CartoonRampSetColor(float _ramp,int _level,fixed4 _Color_H,fixed4 _Color_M,fixed4 _Color_L)
            {
                _level = floor(_level);

                _ramp =ceil(_ramp*_level)/_level;

                fixed4 _ramp_Max_Color = lerp(_Color_M,_Color_H,saturate(_ramp));

                fixed4 _ramp_Min_Color = lerp(_Color_L,_Color_M,saturate(_ramp+1));

                return saturate(_ramp_Max_Color+_ramp_Min_Color);
                          
            }

            fixed4 RampColorTry(float _ramp)
            {

                fixed _ramp_Max = saturate(_ramp);

                fixed _ramp_Min = saturate(-_ramp);

                //0~1作为红色输出，0~-1作为蓝色输出
                return fixed4(_ramp_Max,0,_ramp_Min,1);
                
            }

            fixed4 ColorByRampTex(fixed4 col,half ramp)
            {
                
                //约束范围到0~1
                ramp=ramp*0.5+0.5;
                
                ///使用光照作为u，0.5作为v，读取渐变贴图
                fixed4 ramTex = tex2D(_RampTex,float2(ramp,0.5));

                //与颜色混合，大于0.5增量，小于0.5压缩
                col.rgb*=ramTex.rgb*2;

                return col;
            }

            
            fixed4 frag (v2f i) : SV_Target
            {
                // sample the texture
                fixed4 col = tex2D(_MainTex, i.uv);

                float3 lightDir = normalize(_WorldSpaceLightPos0.xyz);

                //点乘世界法线和灯光发那个像，获取物体表面光照渐变
                half Ramp_Lighting = dot(i.worldNormal,lightDir);


                col=ColorByRampTex(col,Ramp_Lighting);

                
                // apply fog
                UNITY_APPLY_FOG(i.fogCoord, col);

                // fixed4 rampColor = CartoonRampSetColor(Ramp_Lighting,_LightLevel,_Color_H,_Color_M,_Color_L);
                //
                // col*=rampColor;
                
                return  col;
            }
            ENDCG
        }
    }
}
