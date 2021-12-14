Shader "CRLuo/CRLuo_CarPaintLeaser"
{
    Properties
    {
        _PhongSpeColor("釉面光颜色",Color) = (1,1,1,1)
        
        [PowerSlider(3.0)]
        _PhongSpeRange("釉面高光范围",Range(1,50))=1
        
        _PhongSpeIntensity("釉面高光强度",Range(0,10)) = 1
        
        [Space(30)]
        _EdgeLightColor("釉面轮廓光颜色",Color) = (1,1,1,1)
        
        [PowerSlider(3.0)]
        _EdgeLightRange("釉面轮廓光范围",Range(1,100))=1
        
        _EdgeLightIntensity("釉面轮廓光强度",Range(0,50))=1
        
        [Space(30)]
        [Header(_________________)]
        [Space(30)]
        
        _MainTex("二维镭射渐变贴图",2D) = "white"{}
        
        [Space(30)]
        _BlinnSpeColor("油漆高光颜色",Color) = (1,1,1,1)
        
        [PowerSlider(3.0)]
        _BlinnSpeRange("油漆高光范围",Range(1,50)) =1
        _BlinnSpeIntensity("油漆高光强度",Range(0,10))=1
        
        [Space(30)]
        _FresnelMin("菲涅尔最小值",Range(0,1)) =0
        _FresnelMax("菲尼尔最大值",Range(0,1)) =0
        
        
        
        
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
                float2 uv:TEXCOORD0;
                float4 vertex : POSITION;
                half3 normal:NORMAL;
            };

            struct v2f
            {
                half3 worldNormal:TEXCOORD1;
                UNITY_FOG_COORDS(1)
                float4 vertex : SV_POSITION;
                float3 worldPos:TEXCOORD2;
                float2 uv:TEXCOORD0;   
            };

            sampler2D _MainTex;
            
            fixed4 _PhongSpeColor;
            float _PhongSpeRange;
            float _PhongSpeIntensity;

            fixed4 _BlinnSpeColor;
            float _BlinnSpeRange;
            float _BlinnSpeIntensity;

            float _FresnelMin;
            float _FresnelMax;

            fixed4 _EdgeLightColor;
            float _EdgeLightRange;
            float _EdgeLightIntensity;
            
            // fixed4 RampSet3Color(float _ramp)
         

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.worldNormal = UnityObjectToWorldNormal(v.normal);
                o.worldPos = mul(unity_ObjectToWorld,v.vertex);
                o.uv=v.uv;
                UNITY_TRANSFER_FOG(o,o.vertex);
                return o;
            }


          
            
            fixed4 frag (v2f i) : SV_Target
            {
                ///摄像机坐标 = 摄像机坐标 - 顶点坐标
                fixed3 viewDir = normalize(_WorldSpaceCameraPos.xyz - i.worldPos);

                fixed3 lightDir = normalize(_WorldSpaceLightPos0.xyz);

                ///光照渐变是根据是物体法线在光上的投影
                fixed Ramp_Light = dot(i.worldNormal,lightDir);
                ///面比率渐变是物体发现在视线方向上的投影
                fixed Ramp_FaceRatio = dot(i.worldNormal,viewDir);
                ///菲涅尔渐变是1-面比率渐变
                fixed Ramp_Fresnel = 1- saturate(Ramp_FaceRatio);
                ///轮廓光渐变
                fixed Ramp_EdgeLight = Ramp_Fresnel;
                ///Phong高光反射
                fixed Ramp_PhongSpecular = dot(normalize(reflect(-lightDir,i.worldNormal)) ,viewDir);

                fixed Ramp_BlinnSpecular = dot(normalize(viewDir+lightDir),i.worldNormal);

                ///横轴描面比率渐变过程
                float _u = abs(Ramp_FaceRatio);

                ///纵轴光照方向渐变过程
                float _v = Ramp_Light*0.5+0.5;

               
                fixed4 col = tex2D(_MainTex,float2(_u,_v));
               
                ///微调菲涅尔渐变（本来是0~1，调整后可以缩小区间）
                Ramp_Fresnel = lerp(_FresnelMin,_FresnelMax,Ramp_Fresnel);
                
                ///控制浅层高光形状
                Ramp_PhongSpecular = pow(saturate(Ramp_PhongSpecular),_PhongSpeRange)*_PhongSpeIntensity ;
                ///菲尼尔影响浅层高光
                Ramp_PhongSpecular*=Ramp_Fresnel;
                ///浅层高光着色，与颜色叠加
                col+=_PhongSpeColor*Ramp_PhongSpecular;
                
                ///控制深层高光形状
                Ramp_BlinnSpecular = pow(saturate(Ramp_BlinnSpecular),_BlinnSpeRange)*_BlinnSpeIntensity;
                ///菲尼尔影响浅层高光
                Ramp_BlinnSpecular*=Ramp_Fresnel;
                ///深层高光着色，与颜色叠加
                col += _BlinnSpeColor*Ramp_BlinnSpecular;
                
                Ramp_EdgeLight = pow(saturate(Ramp_EdgeLight),_EdgeLightRange)*_EdgeLightIntensity;
                ///轮廓光受灯光影响
                Ramp_EdgeLight*=abs(Ramp_Light);
                ///轮廓光着色，与颜色叠加
                col+=Ramp_EdgeLight*_EdgeLightColor;
                
              
                // apply fog
                UNITY_APPLY_FOG(i.fogCoord, col);
                return col;
            }
            ENDCG
        }
    }
}
