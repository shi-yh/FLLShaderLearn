Shader "CRLuo/CRLuo_Gray"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _GrayEffect("GrayPower",Range(0,1))=0.5
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
            fixed _GrayEffect;

            
             /**
             * \brief 最简单的灰化，但是由于RGB不同通道颜色的亮度权重不同，会略暗于ps的去色
             * \param col 灰化前颜色 
             * \return 灰化后颜色
             */
            fixed4 SimpleGray(fixed4 col)
            {
                col.rgb=((col.r+col.g+col.b)/3);
                return col;
            }

            fixed4 Gray(fixed4 col)
            {
                float gray=dot(col.rgb,float3(0.299,0.587,0.114));
                col.rgb=gray;
                return col;
            }
            

            
            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                UNITY_TRANSFER_FOG(o,o.vertex);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                // sample the texture
                fixed4 col = tex2D(_MainTex, i.uv);

                fixed4 gray=Gray(col);

                col=lerp(col,gray,_GrayEffect);
                
                // apply fog
                UNITY_APPLY_FOG(i.fogCoord, col);
                return col;
            }

            
           

            
            ENDCG
        }
    }
}
