Shader "CRLuo/LightModel"
{
    Properties
    {
        _Color_H("向光色",Color)=(1,1,1,1)
        _Color_M("中间色",Color)=(0,0,0,1)
        _Color_L("背光色",Color)=(0.5,0.5,0.5,1)

        _LightLevel("色级",Range(1,10))=3

        _specularColor("高光颜色",Color)=(1,1,1,1)
        _specularRange("高光范围", Range(1,100))=1
        _specularIntensity("高光强度", Range(0,10))=1


        [Toggle(_Blinn_Key)] _Blinn_Key("布林高光",Float)=0
        [Toggle(_Cartoon_Key)] _Cartoon_Key("卡通效果",Float)=0

    }
    SubShader
    {
        Tags
        {
            "RenderType"="Opaque"
        }
        LOD 100
        Cull Off
        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            // make fog work
            #pragma multi_compile_fog
            #pragma shader_feature _Blinn_Key
            #pragma shader_feature _Cartoon_Key


            #include "UnityCG.cginc"

            struct appdata
            {
                float4 vertex : POSITION;

                //获取模型法线
                half3 normal:NORMAL;
            };

            struct v2f
            {
                float4 vertex : SV_POSITION;
                UNITY_FOG_COORDS(3)

                //定义世界法线变量
                half3 worldNormal:TEXCOORD1;
                //定义顶点世界变量
                float3 WordPos : TEXCOORD2;
            };

            fixed4 _Color_H;
            fixed4 _Color_M;
            fixed4 _Color_L;
            int _LightLevel;

            fixed4 _specularColor;
            float _specularRange;
            float _specularIntensity;


            //自定义卡通渐变着色函数  CartoonRampSetColor (渐变过程,颜色级数,向光色,中间色,背光色)
            fixed4 CartoonRampSetColor(float _ramp, int _level,fixed4 _Color_H,fixed4 _Color_M,fixed4 _Color_L)
            {
                #ifdef _Cartoon_Key
                //向下取整
                _level = floor(_level);

                //线性过程转阶梯
                _ramp = ceil(_ramp * _level) / _level;

                #endif
                //获取0~1，得到中间色 到向光色过度。
                fixed4 _ramp_Max_Color = lerp(_Color_M, _Color_H, saturate(_ramp));
                //获取-1~0，得到背光色 到 中间色过度。
                fixed4 _ramp_Min_Color = lerp(_Color_L, _Color_M, saturate(_ramp + 1));

                //输出两个颜色的和,添加saturate（）显示A大于1
                return saturate(_ramp_Max_Color + _ramp_Min_Color);
            }


            v2f vert(appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                UNITY_TRANSFER_FOG(o, o.vertex);

                //物体法线转世界空间
                o.worldNormal = UnityObjectToWorldNormal(v.normal);
                //顶点坐标 物体转世界
                o.WordPos = mul(unity_ObjectToWorld, v.vertex).xyz;

                return o;
            }


            fixed4 frag(v2f i) : SV_Target
            {
                //--------------基础数据-----------------------
                //世界坐标灯光方向
                fixed3 lightDir = normalize(_WorldSpaceLightPos0.xyz);


                //摄像机方向
                fixed3 viewDir = normalize(_WorldSpaceCameraPos.xyz - i.WordPos);


                //--------------表面照明-------------------
                //对世界法线与灯光方向 点乘 获取物体表面光照渐变
                half Ramp_Lighting = dot(i.worldNormal, lightDir);


                fixed4 Color_LightingRamp = CartoonRampSetColor(Ramp_Lighting, _LightLevel, _Color_H, _Color_M,
                                                                _Color_L);


                //-----------------高光---------------------------

                fixed Ramp_Specular;

                #ifdef _Blinn_Key
                //*******Blinn高光算法**********

                //求灯光与视角的中间值
                fixed3 reflectDir = normalize(lightDir + viewDir);

                //中间值与物体法线求高光
                Ramp_Specular = dot(normalize(lightDir + viewDir), i.worldNormal);

                #else
					//*******Phong高光算法**********

					//使用反向光源方向与法线求高光反射
					fixed3 reflectDir = normalize(reflect(-lightDir, i.worldNormal));
			
					//反射光线与视角点乘
					Ramp_Specular =dot(reflectDir,viewDir);

                #endif

                //高光渐变范围约束到0~1
                Ramp_Specular = saturate(Ramp_Specular);

                //控制高光形状
                Ramp_Specular = pow(Ramp_Specular, _specularRange) * _specularIntensity;


                #ifdef _Cartoon_Key

                //卡通硬边
                Ramp_Specular = step(0.5, saturate(Ramp_Specular));

                #endif

                //高光着色
                fixed3 _specular = _specularColor * Ramp_Specular;


                //高光与光照混色
                Color_LightingRamp.rgb += _specular;

                // apply fog
                UNITY_APPLY_FOG(i.fogCoord, col);

                return Color_LightingRamp;
            }
            ENDCG
        }
    }
}