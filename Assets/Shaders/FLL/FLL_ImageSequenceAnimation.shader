Shader "FLL/FLL_ImageSequenceAnimation"
{
    Properties
    {
        _Color("Color Tint",Color) = (1,1,1,1)
        _MainTex ("Texture", 2D) = "white" {}
        _HorizontalAmount("HorizontalAmount",Float) =4
        _VerticalAmount("VerticalAmount",Float) = 4
        _Speed("Speed",Range(1,100)) = 30
    }
    SubShader
    {
        Tags
        {

            "RenderType"="Transparent"
            "Queue" = "Transparent"
            "IgnorePorjector" = "True"

        }
        LOD 100

        Pass
        {
            Tags
            {
                "LightMode" = "ForwardBase"
            }
            
            ZWrite Off
            Blend SrcAlpha OneMinusSrcAlpha
            

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


            fixed4 _Color;
            float _HorizontalAmount;
            float _VerticalAmount;
            float _Speed;

            

            v2f vert(appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                UNITY_TRANSFER_FOG(o, o.vertex);
                return o;
            }

            fixed4 frag(v2f i) : SV_Target
            {
               float time = floor(_Time.y*_Speed);

                float row = floor(time/_HorizontalAmount);

                float colum  = time-row*_HorizontalAmount;


                half2 uv = float2(i.uv.x/_HorizontalAmount,i.uv.y/_VerticalAmount);

                uv.x+=colum/_HorizontalAmount;

                ///给的图是从上往下的顺序，unity 的uv坐标是从下往上
                uv.y-= row/_VerticalAmount;
                
                

                fixed4 c= tex2D(_MainTex,uv);

                c.rgb*=_Color;

                return c;
                
            }
            ENDCG
        }
    }
}