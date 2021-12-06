Shader "CRLuo/CRLuo_Ramp_BrokenTV"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        
        _DisplaceTex("置换贴图",2D) = "white"{}
        
        _DisplacePow("扭曲强度",Range(-1,1)) = 0.5
        
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
                float4 uv : TEXCOORD0;
                UNITY_FOG_COORDS(1)
                float4 vertex : SV_POSITION;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;

            sampler2D _DisplaceTex;

            float4 _DisplaceTex_ST;

            float _DisplacePow;
            
           
            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv.xy = TRANSFORM_TEX(v.uv, _MainTex);

                o.uv.zw = TRANSFORM_TEX(v.uv,_DisplaceTex);
                
                UNITY_TRANSFER_FOG(o,o.vertex);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                ///获取置换贴图，使用_Time实现上下位移
                fixed4 displaceTex = tex2D(_DisplaceTex,i.uv.zw+float2(0,_Time.x));

                displaceTex = displaceTex-0.5;

                displaceTex *= _DisplacePow;

                //获取红色通道的 横向扭曲图像
                fixed rrr =tex2D(_MainTex,i.uv.xy+float2(displaceTex.r,0)).r;
                fixed ggg =tex2D(_MainTex,i.uv.xy+float2(displaceTex.g,0)).g;
                fixed bbb =tex2D(_MainTex,i.uv.xy+float2(displaceTex.b,0)).b;
                
                // sample the texture
                fixed4 col = fixed4(rrr,ggg,bbb,1);
                // apply fog
                UNITY_APPLY_FOG(i.fogCoord, col);
                return col;
            }
            ENDCG
        }
    }
}
