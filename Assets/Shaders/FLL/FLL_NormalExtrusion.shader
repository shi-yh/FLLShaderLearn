Shader "FLL/FLL_NormalExtrusion"
{
    Properties
    {
        _Color ("Color", Color) = (1,1,1,1)
        _MainTex ("Albedo (RGB)", 2D) = "white" {}
        _BumpMap("NormalMap",2D) = "bump"{}
        _Amount("Extrusion Amount",Range(-0.5,0.5))=0.1
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 300

        CGPROGRAM

        ///使用surf作为表面着色器函数
        ///使用CustomLambert光照模式
        ///使用myvert作为顶点修改函数
        ///使用mycolor作为颜色修改函数
        ///因为改动了顶点位置，所以需要addshadow生成阴影
        ///exclude_path:deferred 不要为延迟渲染路径生成相应的pass
        ///exclude_path:prepass nometa 取消对提取元数据的pass的生成
        #pragma surface surf CustomLambert vertex:myvert finalcolor:mycolor addshadow exclude_path:deferred exclude_path:prepass nometa

        // Use shader model 3.0 target, to get nicer looking lighting
        #pragma target 3.0

        sampler2D _MainTex;

        struct Input
        {
            float2 uv_MainTex;
            float2 uv_BumpMap;
        };


        fixed4 _Color;
        sampler2D _BumpMap;
        half _Amount;
       

        void myvert(inout appdata_full v)
        {
            ///使顶点朝着法线位置膨胀
            v.vertex.xyz+=v.normal*_Amount;
        }

        
        void surf (Input IN, inout SurfaceOutput o)
        {
            // Albedo comes from a texture tinted by color
            fixed4 c = tex2D (_MainTex, IN.uv_MainTex) * _Color;
            o.Albedo = c.rgb;
            o.Alpha = c.a;
            o.Normal = UnpackNormal(tex2D(_BumpMap,IN.uv_BumpMap));
        }


        half4 LightingCustomLambert(SurfaceOutput s,half3 lightDir,half atten)
        {
            half NdotL = dot(s.Normal,lightDir);
            half4 c;
            c.rgb=s.Albedo*_LightColor0.rgb*(NdotL*atten);
            c.a = s.Alpha;
            return c;
        }


        void mycolor(Input IN,SurfaceOutput o,inout fixed4 color)
        {
            color*= _Color;
        }
        
        ENDCG
    }
    FallBack "Diffuse"
}
