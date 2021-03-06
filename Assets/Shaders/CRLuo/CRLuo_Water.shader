Shader "CRLuo/CRLuo_Water"
{
    Properties
    {
        _Color("颜色",Color) = (1,1,1,1)
        
        _MainTex ("Texture", 2D) = "white" {}
        
        _UVAmin("xy水贴图动画速度，zw扭曲贴图动画速度",Vector)=(0,0,0,0)
        
        _DisplacePow("扭曲强度",Range(-1,1))=0.5
        
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

            float4 _Color;
            float4 _UVAmin;
            float _DisplacePow;
            

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
                //获取置换贴图，添加UV动画，并且只输出蓝绿扭曲噪波通道
                fixed2 displaceTex = tex2D(_MainTex,i.uv+_UVAmin.zw*_Time.x).gb;

                displaceTex-=0.5;

                displaceTex*=_DisplacePow;
                
                
                // 用置换贴图的红绿通道啦影响UV坐标，只输出红色水面通道
                fixed4 col = tex2D(_MainTex, i.uv+_UVAmin.xy*_Time.x+displaceTex).r;

                col*=_Color*2;
                
                // apply fog
                UNITY_APPLY_FOG(i.fogCoord, col);
                return col;
            }
            ENDCG
        }
    }
}
