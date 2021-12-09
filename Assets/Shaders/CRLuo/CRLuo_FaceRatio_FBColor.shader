///表面剔除和双面显示
Shader "CRLuo/CRLuo_FaceRatio_FBColor"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}

        _ColorH_F("正面亮部颜色",Color)=(0,0,0,0)

        _ColorM_F("正面灰部颜色",Color)=(0,0,0,0)

        _ColorL_F("正面暗部颜色",Color)=(0,0,0,0)

        _ColorH_B("背面亮部颜色",Color)=(0,0,0,0)

        _ColorM_B("背面灰部颜色",Color)=(0,0,0,0)

        _ColorL_B("背面暗部颜色",Color)=(0,0,0,0)

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
                float2 uv : TEXCOORD0;
                half3 normal:NORMAL;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                UNITY_FOG_COORDS(1)
                float4 vertex : SV_POSITION;

                half3 worldNormal:TEXCOORD1;

                float3 WorldPos:TEXCOORD2;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;
            fixed4 _ColorH_F;
            fixed4 _ColorL_F;
            fixed4 _ColorM_F;

            fixed4 _ColorH_B;
            fixed4 _ColorL_B;
            fixed4 _ColorM_B;


            fixed4 ColorType_RamColor(fixed4 col,half key)
            {
                float gray = dot(col.rgb, float3(0.299, 0.587, 0.114));

                fixed3 colorLow = lerp(_ColorL_F, _ColorM_F, saturate(gray * 2));

                fixed3 colorHigh = lerp(_ColorM_F, _ColorH_F, saturate((gray - 0.5) * 2));

                fixed3 F_Col = lerp(colorLow, colorHigh, gray);
                
                fixed3 BColorLow = lerp(_ColorL_B,_ColorM_B,saturate(gray*2));

                fixed3 BColorHigh = lerp(_ColorM_B,_ColorH_B,saturate((gray-0.5)*2));

                fixed3 B_Col = lerp(BColorLow,BColorHigh,gray);
                
                col.rgb = lerp(B_Col,F_Col,key);

                return col;
            }


            v2f vert(appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);

                o.worldNormal = UnityObjectToWorldNormal(v.normal);

                o.WorldPos = mul(unity_ObjectToWorld, v.vertex);

                UNITY_TRANSFER_FOG(o, o.vertex);
                return o;
            }

            fixed4 frag(v2f i) : SV_Target
            {
                // sample the texture
                fixed4 col = tex2D(_MainTex, i.uv);

                fixed3 viewDir = normalize(_WorldSpaceCameraPos.xyz - i.WorldPos);

                fixed Ramp_FaceRatio = dot(i.worldNormal,viewDir);

                half key = step(0,Ramp_FaceRatio);

                
                
                
                col = ColorType_RamColor(col,key);

                ///剔除透明区域
                clip(col.a - 0.5);
                // apply fog

                UNITY_APPLY_FOG(i.fogCoord, col);
                return col;
            }
            ENDCG
        }
    }
}