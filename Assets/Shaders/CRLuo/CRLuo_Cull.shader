Shader "CRLuo/Cull"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        
        _ColorH("正面亮部颜色",Color)=(0,0,0,0)
        
        _ColorM("正面灰部颜色",Color)=(0,0,0,0)
        
        _ColorL("正面暗部颜色",Color)=(0,0,0,0)
        
        _ColorH_B("背面亮部颜色",Color)=(0,0,0,0)
        
        _ColorM_B("背面灰部颜色",Color)=(0,0,0,0)
        
        _ColorL_B("背面暗部颜色",Color)=(0,0,0,0)
        
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 100
        
        
        Pass
        {
            Cull Back
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


            fixed4 ColorType_RamColor(fixed4 col)
            {
                float gray=dot(col.rgb,float3(0.299,0.587,0.114));

                fixed3 colorLow=lerp(_ColorL,_ColorM,saturate(gray*2));

                fixed3 colorHigh = lerp(_ColorM,_ColorH,saturate((gray-0.5)*2));

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

                col = ColorType_RamColor(col);

                ///剔除透明区域
                clip(col.a-0.5);
                // apply fog
                
                UNITY_APPLY_FOG(i.fogCoord, col);
                return col;
            }


            
            ENDCG
        }
        
        Pass
        {
            Cull Front
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
            fixed4 _ColorH_B;
            fixed4 _ColorL_B;
            fixed4 _ColorM_B;


            fixed4 ColorType_RamColor(fixed4 col)
            {
                float gray=dot(col.rgb,float3(0.299,0.587,0.114));

                fixed3 colorLow=lerp(_ColorL_B,_ColorM_B,saturate(gray*2));

                fixed3 colorHigh = lerp(_ColorM_B,_ColorH_B,saturate((gray-0.5)*2));

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

                col = ColorType_RamColor(col);

                ///剔除透明区域
                clip(col.a-0.5);
                // apply fog
                
                UNITY_APPLY_FOG(i.fogCoord, col);
                return col;
            }


            
            ENDCG
            
            
            
        }
        
        
        
    }
}
