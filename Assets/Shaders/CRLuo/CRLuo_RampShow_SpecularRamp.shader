Shader "CRLuo/RampShow_SpecularRamp"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        
        [Toggle(_Blinn_Key)] _Blinn_Key("布林高光",Float) = 0
        
        [Toggle(_Cartoon_Key)] _Cartoon_Key("卡通效果",Float) = 0
        
        _specularRange("高光范围",Range(1,100))=1
        
        _specularIntensity("高光强度",Range(0,10))=1
        
        _specularColor("高光颜色",Color) = (1,1,1,1)
        
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

            #pragma shader_feature _Blinn_Key
            #pragma shader_feature _Cartoon_Key
            
            #include "UnityCG.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                ///物体空间的表面法线方向
                half3 normal:NORMAL;
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                UNITY_FOG_COORDS(1)
                float4 vertex : SV_POSITION;

                half3 worldNormal:TEXCOORD1;
                float3 worldPos:TEXCOORD2;
                
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;

            float _specularRange;

            float _specularIntensity;

            fixed4 _specularColor;


            fixed4 RampColor(float _ramp)
            {

                fixed _ramp_Max = saturate(_ramp);

                fixed _ramp_Min = saturate(-_ramp);

                return fixed4(_ramp_Max,0,_ramp_Min,1);
                
            }
            

            fixed NormalSpecular(float _ramp)
            {
                _ramp = saturate(_ramp);

                ///使用pow()次方函数修改渐变过程，_specularRange 数值越大，高光范围越小,这部分具体可以参考一下opengl高光部分图。
                ///结果再乘以1~10的_specularIntensity，提高高光亮度
                _ramp = pow(_ramp,_specularRange)*_specularIntensity;

                #ifdef _Cartoon_Key

                _ramp = step(0.5,saturate(_ramp));
                
                #endif
                
                
                return  _ramp;   
            }

            
            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);

                ///物体空间法线转世界空间
                ///物体空间法线是跟随自身坐标轴定旋转的，不会因物体的旋转而改变朝向
                ///但是实际用到的是世界空间下的法线位置
                o.worldNormal = UnityObjectToWorldNormal(v.normal);
                //顶点坐标 物体转世界
                o.worldPos = UnityObjectToWorldDir(v.vertex); 
                
                
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                UNITY_TRANSFER_FOG(o,o.vertex);
                return o;
            }


         
            
          
            

            fixed4 frag (v2f i) : SV_Target
            {
                fixed3 lightDir = normalize(_WorldSpaceLightPos0.xyz);

                fixed3 viewDir = normalize(_WorldSpaceCameraPos.xyz);

                fixed Ramp_Specular;

                #ifdef _Blinn_Key

                ///灯光和视角的中间值
                fixed3 reflectDir = normalize(lightDir+viewDir);
                ///中间值和物体法线求高光
                Ramp_Specular = dot(reflectDir,i.worldNormal);

                #else
                ///使用反向光源返现概念股与法线求高光反射
                fixed3 reflectDir = normalize(reflect(-lightDir,i.worldNormal));
                ///反射光纤和视角点乘
                Ramp_Specular = dot(reflectDir,viewDir);


                #endif
                
                // apply fog
                UNITY_APPLY_FOG(i.fogCoord, col);
                
                return NormalSpecular(Ramp_Specular)*_specularColor;
            }
            ENDCG
        }
    }
}
