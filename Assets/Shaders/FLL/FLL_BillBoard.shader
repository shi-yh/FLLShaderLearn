Shader "FLL/FLL_BillBoard"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}

        _Color("Color",Color) = (1,1,1,1)

        ///用于调整是固定法线还是固定指向上的方向
        _VerticalBillboarding("Vertical Restraints",Range(0,1)) =1

    }
    SubShader
    {
        Tags
        {
            "RenderType"="Transparent"
            "Queue" = "Transparent"
            "IgnoreProjector" = "True"
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

            float _VerticalBillboarding;

            v2f vert(appdata v)
            {
                v2f o;

                ///选择模型空间的原点作为广告牌的锚点
                float3 center = float3(0, 0, 0);
                ///获得模型空间下的视角位置
                float3 viewer = mul(unity_WorldToObject, float4(_WorldSpaceCameraPos, 1));

                float3 normalDir = viewer - center;

                ///当约束为1时，意味法线固定为视角方向，当约束为0时，意味向上防线固定为（0,1,0）
                normalDir.y = normalDir.y * _VerticalBillboarding;

                normalDir = normalize(normalDir);

                float3 upDir = abs(normalDir.y) > 0.999 ? float3(0, 0, 1) : float3(0, 1, 0);

                float3 rightDir = normalize(cross(upDir, normalDir));

                upDir = normalize(cross(normalDir, rightDir));

                float3 centerOffs = v.vertex.xyz - center;
                float3 localPos = center + rightDir * centerOffs.x + upDir * centerOffs.y + normalDir * centerOffs.z;


                o.vertex = UnityObjectToClipPos(float4(localPos,1));
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                UNITY_TRANSFER_FOG(o, o.vertex);
                return o;
            }

            fixed4 frag(v2f i) : SV_Target
            {
                // sample the texture
                fixed4 col = tex2D(_MainTex, i.uv);
                col.rgb*=_Color.rgb;
                // apply fog
                UNITY_APPLY_FOG(i.fogCoord, col);
                return col;
            }
            ENDCG
        }
    }
}