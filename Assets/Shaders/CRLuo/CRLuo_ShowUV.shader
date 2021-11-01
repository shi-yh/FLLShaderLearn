Shader "CRLuo/CRLuo_ShowUV"
{
    Properties
    {
        _Color("颜色",Color) = (1,1,1,1)
        
        _MainTex ("Texture", 2D) = "white" {}
        
        _MoveSpeed_U("U向移动速度",Range(-10,10)) = 0
        _MoveSpeed_V("V向移动速度",Range(-10,10)) = 0
        
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
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

            float _MoveSpeed_U;
            float _MoveSpeed_V;
            
            
            

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);

                //把模型的UV添加 属性中的UV调节 如果UV不变化可以写o.uv = v.uv 
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                UNITY_TRANSFER_FOG(o,o.vertex);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                //组织二维的UV偏移坐标*时间变量
                //_Time是Shader内置的时间变量
                float uvOffset = float2(_MoveSpeed_U,_MoveSpeed_V)*_Time.y ;
                // sample the texture
                fixed4 col = tex2D(_MainTex, i.uv+uvOffset);

                clip(col.r-0.1);

                col*=_Color;
                // apply fog
                UNITY_APPLY_FOG(i.fogCoord, col);
                
                return col;
            }
            ENDCG
        }
    }
}
