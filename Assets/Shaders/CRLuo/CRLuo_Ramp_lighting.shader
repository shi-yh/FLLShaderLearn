Shader "CRLuo/Ramp_lighting"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
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

                //表面法线
                half3 normal:NORMAL;
                
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                UNITY_FOG_COORDS(1)
                float4 vertex : SV_POSITION;

                //顶点片段输出数据添加世界法线
                half3 worldNormal:NORMAL;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                UNITY_TRANSFER_FOG(o,o.vertex);

                //物体空间法线转世界空间法线
                o.worldNormal = UnityObjectToWorldNormal(v.normal);
                
                return o;
            }


            fixed4 RampColorTry(float _ramp)
            {

                fixed _ramp_Max = saturate(_ramp);

                fixed _ramp_Min = saturate(-_ramp);

                //0~1作为红色输出，0~-1作为蓝色输出
                return fixed4(_ramp_Max,0,_ramp_Min,1);
                
            }
            
            fixed4 frag (v2f i) : SV_Target
            {
                // sample the texture
                fixed4 col = tex2D(_MainTex, i.uv);

                float3 lightDir = normalize(_WorldSpaceLightPos0.xyz);

                //点乘世界法线和灯光发那个像，获取物体表面光照渐变
                half Ramp_Lighting = dot(i.worldNormal,lightDir);

                
                // apply fog
                UNITY_APPLY_FOG(i.fogCoord, col);

                return RampColorTry(Ramp_Lighting) ;
            }
            ENDCG
        }
    }
}
