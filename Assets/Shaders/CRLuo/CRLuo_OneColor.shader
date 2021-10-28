Shader "CRLuo/CRLuo_OneColor"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        
        _Color("Color",Color)=(0,0,0,0)
        
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
            fixed4 _Color;


            fixed4 SimpleOneColor(fixed4 col)
            {
                ///如果是白色(1,1,1)，点乘结果为1
                float gray = dot(col.rgb,float3(0.299,0.587,0.114));

                ///颜色用乘法来影响灰度颜色白色
                fixed3 colorLow = gray*_Color.rgb;

                ///颜色用加法来影响灰度颜色的黑色
                fixed3 colorHigh=gray+_Color.rgb;

                ///其实这段不是很明白，涉及到美术了....
                col.rgb = lerp(colorLow,colorHigh,gray);
                
                return col;
            }

            fixed4 OneColor(fixed4 col)
            {
                float gray = dot(col.rgb,float3(0.299,0.587,0.114));

                ///暗部计算：saturate(gray*2)的方法，把“黑”“灰”“白” 变为“黑”“白”“白”的过度(gray的取值是0-1，处理后落在0-2)
                ///         结果乘以颜色，获得 “黑”“颜色”“颜色”的过度结果。
                fixed3 colorLow = saturate(gray*2)*_Color.rgb;

                
                ///亮部计算：saturate((gray-0.5)*2)的方法，把“黑”“灰”“白” 变为“黑”“黑”“白”的过度
                ///再次约束防止获得的值超过1
                fixed3 colorHigh = saturate(saturate((gray-0.5f)*2)+_Color.rgb);

                col.rgb=lerp(colorLow,colorHigh,gray);

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

                col=OneColor((col));
                
                // apply fog
                UNITY_APPLY_FOG(i.fogCoord, col);
                return col;
            }


            
            ENDCG
        }
    }
}
