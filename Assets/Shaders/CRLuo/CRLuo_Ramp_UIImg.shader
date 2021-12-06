Shader "CRLuo/Ramp_UIImg"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        
        _DisplaceTex("置换贴图",2D) = "white"{}
        
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

				//输出主帖图调整后的结果
                o.uv.xy = TRANSFORM_TEX(v.uv, _MainTex);

				//输出置换图调整后的结果
				o.uv.zw = TRANSFORM_TEX(v.uv, _DisplaceTex);

                UNITY_TRANSFER_FOG(o,o.vertex);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {

			    //获取置换贴图
			    fixed4 displaceTex = tex2D(_DisplaceTex, i.uv.zw);

				//0~1数据转换为-0.5~0.5
				 displaceTex =  (displaceTex-0.5);

				 //扭曲强弱可控
				displaceTex*= _DisplacePow;

                //用置换贴图的红(x) 绿(y)通道来影响UV坐标
				fixed4 col = tex2D(_MainTex, i.uv.xy+displaceTex.rg);
  
            	//用透明剔除表面
				clip(col.a-0.5);

                UNITY_APPLY_FOG(i.fogCoord, col);
                return col;
            }
            ENDCG
        }
    }
}
