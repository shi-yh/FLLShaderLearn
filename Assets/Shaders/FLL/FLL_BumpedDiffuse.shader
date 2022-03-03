Shader "FLL/FLL_BumpedDiffuse"
{
    Properties
    {
        _Color ("Color", Color) = (1,1,1,1)
        _MainTex ("Albedo (RGB)", 2D) = "white" {}
        _BumpMap("Normal Map",2D) = "bump"{}
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 300

        CGPROGRAM

        ///指明该编译命令是用于定义表面着色器 光照函数为surf，光照模型使用lambert
        #pragma surface surf Lambert

        // Use shader model 3.0 target, to get nicer looking lighting
        #pragma target 3.0

        sampler2D _MainTex;
        sampler2D _BumpMap;
        fixed4 _Color;

        
        struct Input
        {
            float2 uv_MainTex;
            float2 uv_BumpMap;
        };

      

        // Add instancing support for this shader. You need to check 'Enable Instancing' on materials that use the shader.
        // See https://docs.unity3d.com/Manual/GPUInstancing.html for more information about instancing.
        // #pragma instancing_options assumeuniformscaling
        UNITY_INSTANCING_BUFFER_START(Props)
            // put more per-instance properties here
        UNITY_INSTANCING_BUFFER_END(Props)

        void surf (Input IN, inout SurfaceOutput o)
        {
            // Albedo comes from a texture tinted by color
            fixed4 c = tex2D (_MainTex, IN.uv_MainTex);
            
            o.Albedo = c.rgb*_Color.rgb;
            // Metallic and smoothness come from slider variables
         
            o.Alpha = c.a*_Color.a;

            o.Normal = UnpackNormal(tex2D(_BumpMap,IN.uv_BumpMap));
        }
        ENDCG
    }
    FallBack "Diffuse"
}
