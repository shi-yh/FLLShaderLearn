Shader "FLL/FLL_EdgeDetection"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}

        _EdgeOnly("Edge Only",Float) = 1.0

        _EdgeColor("Edge Color",Color) = (0.0,0.0,0.0,1.0)

        _BackgroundColor("Background Color",Color) = (1.0,1.0,1.0,1.0)

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
            ZTest Always
            ZWrite Off
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
                half2 uv : TEXCOORD0;
            };

            struct v2f
            {
                float2 uv[9] : TEXCOORD0;
                UNITY_FOG_COORDS(1)
                float4 vertex : SV_POSITION;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;

            ///xxx_TexelSize是UNity听的访问xxx纹理对应的每个纹素的大小
            ///卷积需要对相邻区域的纹理进行采样
            half4 _MainTex_TexelSize;

            fixed _EdgeOnly;

            fixed4 _EdgeColor;

            fixed4 _BackgroundColor;


            v2f vert(appdata_img v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);

                half2 uv = v.texcoord;

                o.uv[0] = uv + _MainTex_TexelSize.xy * half2(-1, -1);
                o.uv[1] = uv + _MainTex_TexelSize.xy * half2(0, -1);
                o.uv[2] = uv + _MainTex_TexelSize.xy * half2(1, -1);
                o.uv[3] = uv + _MainTex_TexelSize.xy * half2(-1, 0);
                o.uv[4] = uv + _MainTex_TexelSize.xy * half2(0, 0);
                o.uv[5] = uv + _MainTex_TexelSize.xy * half2(1, 0);
                o.uv[6] = uv + _MainTex_TexelSize.xy * half2(-1, 1);
                o.uv[7] = uv + _MainTex_TexelSize.xy * half2(0, 1);
                o.uv[8] = uv + _MainTex_TexelSize.xy * half2(1, 1);


                return o;
            }

            fixed luminance(fixed4 color)
            {
                return 0.2125*color.r+0.7154*color.g+0.0721*color.b;
            }


            ///计算当前像素的梯度值edge
            

            half Sobel(v2f i)
            {
                ///首先定义了水平方向和竖直方向使用的卷积核
                const half Gx[9] = {
                    -1, -2, -1,
                    0, 0, 0,
                    1, 2, 1
                };

                const half Gy[9] = {
                    -1, 0, 1,
                    -2, 0, 2,
                    - 1, 0, 1
                };

                half texColor;
                half edgeX = 0;
                half edgeY = 0;


                for (int it = 0; it < 9; it++)
                {
                    ///依次对九个像素进行采样，计算他们的亮度值
                    texColor = luminance(tex2D(_MainTex, i.uv[it]));

                    ///叠乘权重
                    edgeX += texColor * Gx[it];
                    edgeY += texColor * Gy[it];
                }

                half edge = 1 - abs(edgeX) - abs(edgeY);

                return edge;
            }


            fixed4 frag(v2f i) : SV_Target
            {
                half edge = Sobel(i);

                fixed4 withEdgeColor = lerp(_EdgeColor, tex2D(_MainTex, i.uv[4]), edge);

                fixed4 onlyEdgeColor = lerp(_EdgeColor, _BackgroundColor, edge);

                return lerp(withEdgeColor, onlyEdgeColor, _EdgeOnly);
            }
            ENDCG
        }
    }
}