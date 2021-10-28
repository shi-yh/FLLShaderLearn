Shader "CRLuo/RamColor"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        
        _ColorH("亮部颜色",Color)=(0,0,0,0)
        
        _ColorM("灰部颜色",Color)=(0,0,0,0)
        
        _ColorL("暗部颜色",Color)=(0,0,0,0)
        
        _RampTex("渐变贴图",2D) = "white"{}
        
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
            fixed4 _ColorH;
            fixed4 _ColorL;
            fixed4 _ColorM;
            sampler2D _RampTex;


            fixed4 ColorType_RamColor(fixed4 col)
            {
                float gray=dot(col.rgb,float3(0.299,0.587,0.114));

                fixed3 colorLow=lerp(_ColorL,_ColorM,saturate(gray*2));

                fixed3 colorHigh = lerp(_ColorM,_ColorH,saturate((gray-0.5)*2));

                col.rgb=lerp(colorLow,colorHigh,gray);
                return col;
            }

                
            fixed4 Tex_RamColor(fixed4 tex)
            {
                float gray=dot(tex.rgb,float3(0.299,0.587,0.114));

                fixed4 ramCol = tex2D(_RampTex,float2(gray,0.5));

                ramCol.a=tex.a;

                return ramCol;
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

                col = Tex_RamColor(col);
                // apply fog
                UNITY_APPLY_FOG(i.fogCoord, col);
                return col;
            }


            
            ENDCG
        }
    }
}
