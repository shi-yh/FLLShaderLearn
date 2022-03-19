Shader "FLL/FLL_FogWithNoise"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _FogDensity("Fog Density",Float) = 1.0
        _FogColor("Fog Color",Color) =(1,1,1,1)
        _FogStart("Fog Start",Float) = 0.0
        _FogEnd("Fog End",Float)=1.0
        _NoiseTex("Noise Texture",2D) = "white"{}
        _FogXSpeed("Fog Horizontal Speed",Float) =0.1
        _FogYSpeed("Fog Vertical Speed",Float)=0.1
        _NoiseAmount("Noise Amount",Float) =1

    }
    SubShader
    {
        Tags
        {
            "RenderType"="Opaque"
        }
        LOD 100

        CGINCLUDE
        #include "UnityCG.cginc"

        float4x4 _FrustumCornersRay;

        sampler2D _MainTex;
        float4 _MainTex_ST;

        half4 _MainTex_TexelSize;
        sampler2D _CameraDepthTexture;
        half _FogDensity;
        fixed4 _FogColor;
        float _FogStart;
        float _FogEnd;
        sampler2D _NoiseTex;
        half _FogXSpeed;
        half _FogYSpeed;
        half _NoiseAmount;

        struct v2f
        {
            float4 vertex : SV_POSITION;
            float2 uv : TEXCOORD0;

            half2 uv_depth:TEXCOORD1;
            float4 interpolatedRay:TEXCOORD2;
        };

        v2f vert(appdata_img v)
        {
            v2f o;
            o.vertex = UnityObjectToClipPos(v.vertex);

            o.uv = v.texcoord;
            o.uv_depth = v.texcoord;

            #if UNITY_UV_STARTS_AT_TOP
            if (_MainTex_TexelSize.y < 0)
            {
                o.uv_depth.y = 1 - o.uv_depth.y;
            }
            #endif

            int index = 0;
            ///虽然包含了判断语句，但是屏幕后处理的模型是一个四边形网格，只有四个顶点
            if (v.texcoord.x < 0.5 && v.texcoord.y < 0.5)
            {
                index = 0;
            }
            else if (v.texcoord.x > 0.5 && v.texcoord.y < 0.5)
            {
                index = 1;
            }
            else if (v.texcoord.x > 0.5 && v.texcoord.y > 0.5)
            {
                index = 2;
            }
            else
            {
                index = 3;
            }

            #if UNITY_UV_STARTS_AT_TOP
            if (_MainTex_TexelSize.y < 0)
            {
                index = 3 - index;
            }
            #endif

            o.interpolatedRay = _FrustumCornersRay[index];

            return o;
        }

        fixed4 frag(v2f i):SV_Target
        {
            ///根据深度纹理重建该图像在世界空间中的位置
            float linearDepth = LinearEyeDepth(SAMPLE_DEPTH_TEXTURE(_CameraDepthTexture,i.uv_depth));
            float3 worldPos = _WorldSpaceCameraPos+linearDepth*i.interpolatedRay.xyz;

            ///计算噪声纹理偏移量，-0.5后值范围在-0.5~0.5之间
            float2 speed = _Time.y*float2(_FogXSpeed,_FogYSpeed);
            float noise  = (tex2D(_NoiseTex,i.uv+speed).r-0.5)*_NoiseAmount;

            float fogDensity = (_FogEnd - worldPos.y)/(_FogEnd-_FogStart);

            fogDensity = saturate(fogDensity*_FogDensity*(1+noise));

            fixed4 finalColor = tex2D(_MainTex,i.uv);

            finalColor.rgb = lerp(finalColor.rgb,_FogColor.rgb,fogDensity);

            return finalColor;
            
        }
        ENDCG




        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag 
            ENDCG
        }
    }
}