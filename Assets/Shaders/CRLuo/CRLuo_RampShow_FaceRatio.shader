Shader "CRLuo/CRLuo_RampShow_FaceRatio"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        
        _ColorFront("正面颜色",Color) = (1,0,0,1)
        
        _ColorSide("侧面颜色",Color) = (0,0,1,1)
        
        _FaceRatioRange("面比例范围",Range(1,100))=1
        
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
                half3 normal:NORMAL;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                UNITY_FOG_COORDS(1)
                float4 vertex : SV_POSITION;

                half3 worldNormal:TEXCOORD1;

                float3 WorldPos:TEXCOPRD2;
                
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;

            float4 _ColorFront;
            float4 _ColorSide;
            float _FaceRatioRange;

            fixed4 RampColorTry(float _ramp)
            {

                ///面比率范围调节，获得中心颜色渐变
                fixed Ranp_Center =pow(_ramp,_FaceRatioRange);
                
                return lerp(_ColorSide,_ColorFront,abs(Ranp_Center));
                
            }
            
            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);

                o.worldNormal = UnityObjectToWorldNormal(v.normal);

                o.WorldPos = mul(unity_ObjectToWorld,v.vertex).xyz;
                
                UNITY_TRANSFER_FOG(o,o.vertex);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                fixed3 viewDir = normalize(_WorldSpaceCameraPos.xyz-i.WorldPos);

                ///面比率 = dot(世界法线，世界视角)
                fixed3 Ramp_FaceRatio = dot(i.worldNormal,viewDir);
              
                // apply fog
                UNITY_APPLY_FOG(i.fogCoord, col);
                return RampColorTry(Ramp_FaceRatio);
            }
            ENDCG
        }
    }
}
