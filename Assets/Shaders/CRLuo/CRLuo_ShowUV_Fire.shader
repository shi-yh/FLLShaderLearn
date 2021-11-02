Shader "CRLuo/CRLuo_ShowUV_Fire"
{
    Properties
    {
	    _Color("颜色",Color)=(1,1,1,1)
        _MainTex ("Texture", 2D) = "white" {}

		_MoveSpeed_U("U向移动速度", Range(-10,10))=0
		_MoveSpeed_V("V向移动速度", Range(-10,10))=0
		
				//次方范围控制
		_AddPow("顶端火焰范围", Range(1,50))=40
		_MultiplyPow("低端消失范围", Range(0,1))=0.3
		_UPow("左右消失范围", Range(0,10))=1
    }
    SubShader
    {
		//Tags { "Queue" = "Transparent"  "RenderType"="Transparent" }
        LOD 100

        Pass
        {
			//Blend One One
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
			float4 _Color;
            sampler2D _MainTex;
            float4 _MainTex_ST;
			float _MoveSpeed_U;
            float _MoveSpeed_V;
			//次方变量
			float _AddPow;
			float _MultiplyPow;
			
			float _UPow;
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



				float2 uvAnim  = float2(_MoveSpeed_U,_MoveSpeed_V)*_Time.y;
                // sample the texture
                fixed4 col = tex2D(_MainTex, i.uv+uvAnim );
				//col*=col.a;
				//顶端相加影响，过度白色少
				col +=pow( i.uv.y,_AddPow)*_AddPow;

				//底端相乘影响，过度白色多
				col *=pow( i.uv.y,_MultiplyPow);

				//U0~1变为 -0.5~0.5;
				float Ramp_U= i.uv.x-0.5;
				//渐变求绝对值 -0.5~0~0.5 变为 0.5~0~0.5
				Ramp_U =abs(Ramp_U);
				//渐变0.5~0~0.5 变为 1~0~1;
				Ramp_U *=2;
				//翻转为0~1~0
				Ramp_U =1-Ramp_U;
				//次方改变过度过程
				Ramp_U = pow(Ramp_U,_UPow);
				col *= Ramp_U;


				clip(col.r-0.5);

				col *=_Color;


                // apply fog
                UNITY_APPLY_FOG(i.fogCoord, col);
                return col;
            }
            ENDCG
        }
    }
}
