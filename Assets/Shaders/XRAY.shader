Shader "Unity/XRay"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _Diffuse("Color",Color) =(1,1,1,1)
        _XRayColor("XRayColor",Color)=(1,1,1,1)
        _XRayPower("XRayPower",float) =0 
        
    }
    SubShader
    {
        Tags {"Queue"= "Geometry+1000" "RenderType"="Opaque" }
        LOD 100

        //Xray效果
        Pass
        {
            Name "Xray"
            //忽略阴影，半透明物体不需要阴影，可开启此功能
            Tags{ "ForceNoShadowCasting" = "true" }
            //开启混合
            Blend SrcAlpha One 
            //不进行任何颜色信息写入
            ZWrite Off 
            //大于深度缓冲池中的颜色深度的片元才进行处理 其他的全部舍弃
            ZTest Greater

            CGPROGRAM
            #pragma vertex vert 
            #pragma fragment frag 
            #include "UnityCG.cginc"
            #include "Lighting.cginc"

            float4 _XRayColor;
            float _XRayPower;

            struct v2f
            {
                float4 vertex:SV_POSITION;
                float3 normal:TEXCOORD0;
                float3 viewDir:TEXCOORD1;

            };

            v2f vert(appdata_base v)
            {
                v2f o;
                o.vertex=UnityObjectToClipPos(v.vertex);
                o.normal = normalize(mul(v.normal,(float3x3)unity_WorldToObject));
				o.viewDir = normalize(_WorldSpaceCameraPos.xyz - mul(unity_ObjectToWorld, v.vertex).xyz);
                return o;
            };

            fixed4 frag(v2f i):SV_TARGET
            {
                //float3 NormalDir=normalize(i.normal);
                //float3 ViewDir=normalize(i.viewDir);
                    
                float rim=1-saturate(dot(i.normal,i.viewDir));
                float4 rimColor=_XRayColor*pow(rim,1/_XRayPower);
                return rimColor;
            };
            ENDCG
        }

        //正常的漫反射渲染
        Pass
        {
        
            CGPROGRAM 
            #pragma vertex vert
            #pragma fragment frag 
            #include "UnityCG.cginc"
            #include "Lighting.cginc"

            sampler2D _MainTex;
            float4 _MainTex_ST;
            float3 _Diffuse;
            struct v2f
            {
                float4 vertex:SV_POSITION;
                float2 uv:TEXCOORD0;
                float3 worldPos:TEXCOORD1;
                float3 worldNormal:TEXCOORD2;
            };

            v2f vert(appdata_base v)
            {
                v2f o;
                o.vertex=UnityObjectToClipPos(v.vertex);
                o.uv=TRANSFORM_TEX(v.texcoord,_MainTex);
                o.worldPos=mul(unity_ObjectToWorld,v.vertex);
                o.worldNormal=UnityObjectToWorldNormal(v.normal);
                return o;
            };

            fixed4 frag(v2f i):SV_TARGET
            {
                float3 worldNormalDir=normalize(i.worldNormal);
                float3 WorldLightDir=normalize(UnityWorldSpaceLightDir(i.worldNormal));

                float3 texColor=tex2D(_MainTex,i.uv);

                float3 ambient=UNITY_LIGHTMODEL_AMBIENT.rgb*texColor.rgb;

                float3 diffuse=_LightColor0.rgb*_Diffuse.rgb*texColor.rgb*(dot(worldNormalDir,WorldLightDir)*0.5+0.5);
                
                float3 color=diffuse+ambient;
                return fixed4(color,1);
            };
            ENDCG
       }

    }
    Fallback "Diffuse"
}