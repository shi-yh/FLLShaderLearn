Shader "FLL/FLL_BrightnessSaturationAndContrast"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _Brightness("Brightness",Float) = 1
        _Saturation("Saturation",Float) =1
        _Contrast("Contrast",Float)=1
    }
    SubShader
    {
        Tags
        {
            "RenderType"="Opaque"
        }
        LOD 100

        Pass
        {
            ///屏幕后处理实际上是在场景中绘制了一个与屏幕同宽同高的四边形面片
            ///为了防止它对其他物体产生影响，我们需要设置相关的渲染状态。

            ZTest Always
            Cull Off

            ///关闭深度写入。防止它挡住后面被渲染的物体
            ZWrite Off

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
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                UNITY_FOG_COORDS(1)
                float4 vertex : SV_POSITION;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;

            half _Brightness;
            half _Saturation;
            half _Contrast;


            v2f vert(appdata_img v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = v.texcoord;
                UNITY_TRANSFER_FOG(o, o.vertex);
                return o;
            }

            fixed4 frag(v2f i) : SV_Target
            {
                // sample the texture
                fixed4 col = tex2D(_MainTex, i.uv);

                ///亮度调整：原颜色*亮度系数
                fixed3 finalColor = col.rgb * _Brightness;

                ///饱和度调整，先全灰，再插值
                fixed luminance = 0.2125 * col.r + 0.7154 * col.g + 0.0721 * col.b;

                fixed3 luminaceColor = fixed3(luminance, luminance, luminance);

                finalColor = lerp(luminaceColor, finalColor, _Saturation);

                ///对比度调整
                fixed3 avgColor = fixed3(0.5, 0.5, 0.5);
                finalColor = lerp(avgColor, finalColor, _Contrast);


                return fixed4(finalColor, col.a);
            }
            ENDCG
        }
    }
}