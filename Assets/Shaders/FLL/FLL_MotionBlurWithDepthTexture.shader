Shader "FLL/FLL_MotionBlurWithDepthTexture"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _BlurSize("Blur Size",Float) = 1.0
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


        sampler2D _MainTex;
        float4 _MainTex_ST;
        half4 _MainTex_TexelSize;
        ///Unity传递给我们的深度纹理
        sampler2D _CameraDepthTexture;
        float4x4 _CurrentViewProjectionInverseMatrix;
        float4x4 _PreviousViewProjectionMatrix;
        half _BlurSize;


        struct v2f
        {
            half2 uv : TEXCOORD0;
            float4 vertex : SV_POSITION;
            half2 uv_depth:TEXCOORD1;
        };

        v2f vert(appdata_img v)
        {
            v2f o;

            o.vertex = UnityObjectToClipPos(v.vertex);

            o.uv = v.texcoord;

            o.uv_depth = v.texcoord;

            #if  UNITY_UV_STARTS_AT_TOP

            if (_MainTex_TexelSize.y < 0)
            {
                o.uv_depth.y = 1 - o.uv_depth.y;
            }

            #endif

            return o;
        }

        fixed4 frag(v2f i):SV_Target
        {
            ///对深度纹理进行采样
            float d = SAMPLE_DEPTH_TEXTURE(_CameraDepthTexture, i.uv_depth);
            ///把深度值重新映射回NDC,得到NDC下的坐标H(因为原坐标到NDC坐标的方法是(x+1)/2[把范围从-1~1变成0-1])
            float4 H = float4(i.uv.x * 2 - 1, i.uv.y * 2 - 1, d * 2 - 1, 1);
            
            float4 D = mul(_CurrentViewProjectionInverseMatrix, H);

            ///使用深度纹理和当前帧的视角*投影矩阵的逆矩阵来求得该像素在世界空间下的坐标
            float4 worldPos = D / D.w;

            float4 currentPos = H;
            ///得到前一帧在NDC中的坐标
            float4 previousPos = mul(_PreviousViewProjectionMatrix, worldPos);

            previousPos /= previousPos.w;

            ///得到速度方向
            float2 velocity = (currentPos.xy - previousPos.xy) / 2.0f;

            float2 uv = i.uv;

            float4 c = tex2D(_MainTex, uv);


            uv += velocity * _BlurSize;

            ///对方向上的领域像素进行采样
            for (int it = 1; it < 3; it++, uv += velocity * _BlurSize)
            {
                float4 currentColor = tex2D(_MainTex, uv);
                c += currentColor;
            }

            c /= 3;

            return fixed4(c.rgb, 1.0);
        }
        ENDCG

        ZTest Always Cull Off ZWrite Off


        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            
            ENDCG
        }
    }
}