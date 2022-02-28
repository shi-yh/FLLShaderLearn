Shader "FLL/FLL_Water"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}

        _Color ("Color Tint",Color) = (1,1,1,1)

        _Magnitude("Distortion Magnitude",Float) =1

        _Frequency ("Distortion Frequency",FLoat) =1

        _InvWaveLength ("Distortion INverse Wave Length",Float) = 10

        _Speed ("Speed",Float) = 0.5

    }
    SubShader
    {
        Tags
        {
            "Queue" = "Transparent"
            "RenderType"="Transparent"
            "IgnoreProjector" = "True"
            ///批处理会合并所有相关的模型，导致这些模型格子的模型空间丢失
            "DisableBatching" ="True"

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

            fixed4 _Color;

            float _Magnitude;

            float _Frequency;

            float _InvWaveLength;

            float _Speed;


            v2f vert(appdata v)
            {
                v2f o;

                float4 offset;
                offset.yzw = float3(0.0, 0.0, 0.0);
                ///首先计算顶点位移量。
                ///只对顶点的x方向进行位移
                offset.x = sin(_Frequency * _Time.y + v.vertex.x * _InvWaveLength + v.vertex.y * _InvWaveLength + v.vertex.z * _InvWaveLength) * _Magnitude;

                


                o.vertex = UnityObjectToClipPos(v.vertex+offset);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                o.uv+=float2(0.0,_Time.y*_Speed);
                
                UNITY_TRANSFER_FOG(o, o.vertex);
                return o;
            }

            fixed4 frag(v2f i) : SV_Target
            {
                // sample the texture
                fixed4 col = tex2D(_MainTex, i.uv);

                col.rgb*= _Color.rgb;
                // apply fog
                UNITY_APPLY_FOG(i.fogCoord, col);
                return col;
            }
            ENDCG
        }
    }
}