Shader "CRLuo/CRLuo_UVPolar"
{
    Properties
    {
        _Color("颜色",Color) = (1,1,1,1)
        
        _MainTex ("Texture", 2D) = "white" {}
        
        _MoveSpeed_U("U向移动速度",Range(-10,10)) =0.3
        
        _MoveSpeed_V("V向移动速度",Range(-10,10))=2
        
        _UVRampTex("渐变贴图",2D) = "white"{}
        
    }
    SubShader
    {
        Tags { 
            
            "Queue" = "Transparent"
            
            "RenderType"="Transparent"
            
             }
        LOD 100

        Pass
        {
            Blend One One
            
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

            sampler2D _UVRampTex;

            float4 _UVRampTex_ST;


            //直角坐标系转极坐标
            float2 Polar(float2 UV)
            {
                //0-1限定改成-0.5~0.5限定
                float2 uv = UV-0.5;

                //d为各个象限坐标到0点的距离，数值为0~0.5
                float distance = length(uv);

                //将距离放大到0~1
                distance*=2;

                //弧度范围为【-pi，pi】
                float angle = atan2(uv.x,uv.y);
                //把 [-pi,+pi]转换为0~1
                float angle01 = angle/3.14159/2+0.5;
                //输出角度与距离
                return float2(angle01,distance);
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
                //获取极坐标UV
                float2 polar_UV  = Polar(i.uv);
                //获取UV动画偏移
                float2 uvAmin = float2(_MoveSpeed_U,_MoveSpeed_V)*_Time.y;
                //获取主贴图（ 极坐标UV*重复UV+偏移UV+UV动画）
                fixed4 col = tex2D(_MainTex,polar_UV*_MainTex_ST.xy+_MainTex_ST.zw+uvAmin);
                //获取渐变贴图（极坐标UV*渐变重复UV+渐变偏移UV）
                fixed4 ramp = tex2D(_UVRampTex,polar_UV*_UVRampTex_ST.xy+_UVRampTex_ST.zw);

                //混合渐变
                col+=ramp.b;
                col*=ramp.r;
                //混合颜色  
                col*=_Color;

                UNITY_APPLY_FOG(i.fogCoord, col);
                
                 return col;
            }
            ENDCG
        }
    }
}
