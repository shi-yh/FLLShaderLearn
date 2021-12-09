Shader "CRLuo/CRLuo_Ramp_FaceRatioPhong"
{
    Properties
    {
        _ColorCenter("中心颜色",Color) = (1,0,0,1)
        
        _ColorEdge("边缘颜色",Color) = (0,0,1,1)
        
        _CenterRange("中心渐变范围",Range(1,100)) = 1
        
        _SpecularColor("高光颜色",Color) = (1,1,1,1)
        
        _SpecularRange("高光范围",Range(1,50))=1
        
        _SpecularIntensity("高光强度",Range(0,10))=1
        
        _FresnelMin("菲涅尔最小值",Range(0,1)) = 0
        
        _FresnelMax("菲涅尔最大值",Range(0,1)) = 1
        
        _EdgeLightColor("轮廓光颜色",Color) = (1,1,1,1)
        
        _EdgeLightRange("轮廓光范围",Range(0,3)) =1
        
        _EdgeLightIntensity("轮廓光强度",Range(0,3)) = 1
        
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 100

        Pass
        {
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
                half3 normal:NORMAL;
            };

            struct v2f
            {
                UNITY_FOG_COORDS(1)
                float4 vertex : SV_POSITION;

                half3 worldNormal:TEXCOORD1;

                float3 WorldPos:TEXCOORD2;
                
            };


            fixed4 _ColorCenter;

            fixed4 _ColorEdge;

            float _CenterRange;

            float _SpecularRange;

            fixed4 _SpecularColor;

            float _SpecularIntensity;

            float _FresnelMin;

            float _FresnelMax;

            fixed4 _EdgeLightColor;

            float _EdgeLightRange;

            float _EdgeLightIntensity;


            

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);

                o.worldNormal = UnityObjectToWorldNormal(v.normal);

                o.WorldPos = mul(unity_ObjectToWorld,v.vertex).xyz;
                
                UNITY_TRANSFER_FOG(o,o.vertex);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {

                fixed3 viewDir = normalize(_WorldSpaceCameraPos.xyz-i.WorldPos);

                fixed3 lightDir=  normalize(_WorldSpaceLightPos0.xyz);

                ///光照渐变
                fixed Ramp_Lighting = dot(i.worldNormal,lightDir);
                ///面比例渐变
                fixed Ramp_FaceRatio=dot(i.worldNormal,viewDir);
                ///菲涅尔渐变 = 反向面比率
                fixed Ramp_Fresnel = 1-saturate(Ramp_FaceRatio);
                ///轮廓光渐变
                fixed Ramp_EdgeLight = Ramp_Fresnel;

                fixed3 reflectDir= normalize((reflect(-lightDir,i.worldNormal)));
                ///高光渐变
                fixed Ramp_Specular = dot(reflectDir,viewDir);

                ///中心发光调节
                fixed Ramp_Center = pow(Ramp_FaceRatio,_CenterRange);
                ///中心发光着色
                fixed4 col =lerp(_ColorEdge,_ColorCenter,abs(Ramp_Center));

                

                ///微调菲涅尔渐变
                Ramp_Fresnel = lerp(_FresnelMin,_FresnelMax,Ramp_Fresnel);
                
                Ramp_Specular = saturate(Ramp_Specular);
                Ramp_Specular= pow(Ramp_Specular,_SpecularRange)*_SpecularIntensity;
                ///菲涅尔效应影响高光
                Ramp_Specular *= Ramp_Fresnel;
                fixed3 _specular = _SpecularColor*Ramp_Specular;

                ///轮廓光调节
                Ramp_EdgeLight = pow(Ramp_EdgeLight,_EdgeLightRange)*_EdgeLightIntensity;

                ///使轮廓光受灯光影响
                Ramp_EdgeLight*= abs(Ramp_Lighting);

                fixed3 _edgeLight = Ramp_EdgeLight*_EdgeLightColor;

                col.rgb+=_specular;

                col.rgb+=_edgeLight;
                
               
                UNITY_APPLY_FOG(i.fogCoord, col);

                return col;
            }
            ENDCG
        }
    }
}
