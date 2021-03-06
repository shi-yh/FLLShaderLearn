Shader "FLL/FLL_Dissolve"
{
    Properties
    {
        _BurnAmount("Burn Amount",Range(0.0,1.0)) = 0.0
        ///控制模拟烧焦效果时的线宽
        _LineWidth ("Burn Line Width",Range(0.0,0.2)) =0.1
        _MainTex ("Texture", 2D) = "white" {}
        _BumpMap("Normal Map",2D) = "bump"{}
        _BurnFirstColor("Burn First Color",Color) = (1,0,0,1)
        _BurnSecondColor("Burn Second Color",Color) = (1,0,0,1)
        _BurnMap("Burn Map",2D) = "white"{}
    }
    SubShader
    {


        Tags
        {
            "RenderType"="Opaque"
        }
        LOD 100

        CGINCLUDE
        #include "UnityCG.cginc"
        #include "Lighting.cginc"
        #include "AutoLight.cginc"

        sampler2D _MainTex;
        float4 _MainTex_ST;
        fixed _BurnAmount;
        fixed _LineWidth;
        sampler2D _BumpMap;
        float4 _BumpMap_ST;
        fixed4 _BurnFirstColor;
        fixed4 _BurnSecondColor;
        sampler2D _BurnMap;
        float4 _BurnMap_ST;
        ENDCG


        Pass
        {
            Tags
            {
                "LightMode" = "ForwardBase"

            }

            Cull Off


            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            // make fog work
            #pragma multi_compile_fwdbase


            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
                float3 normal:NORMAL;
                float4 tangent:TANGENT;
            };

            struct v2f
            {
                float4 pos : SV_POSITION;
                float2 uvMainTex : TEXCOORD0;
                float2 uvBumpMap:TEXCOORD1;
                float2 uvBurnMap:TEXCOORD2;
                float3 lightDir:TEXCOORD3;
                float3 worldPos:TEXCOORD4;
                SHADOW_COORDS(5)
            };


            v2f vert(appdata v)
            {
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);
                o.uvMainTex = TRANSFORM_TEX(v.uv, _MainTex);
                o.uvBumpMap = TRANSFORM_TEX(v.uv, _BumpMap);
                o.uvBurnMap = TRANSFORM_TEX(v.uv, _BurnMap);

                TANGENT_SPACE_ROTATION;

                o.lightDir = mul(rotation, ObjSpaceLightDir(v.vertex)).xyz;
                o.worldPos = mul(unity_ObjectToWorld, v.vertex).xyz;

                TRANSFER_SHADOW(o);
                return o;
            }

            fixed4 frag(v2f i) : SV_Target
            {
                ///先对噪声纹理进行采样
                fixed3 burn = tex2D(_BurnMap, i.uvBurnMap).rgb;
                ///剔除结果小于0的像素
                clip(burn.r - _BurnAmount);

                float3 tangentLightDir = normalize(i.lightDir);

                fixed3 tangentNormal = UnpackNormal(tex2D(_BumpMap, i.uvBumpMap));

                fixed3 albedo = tex2D(_MainTex, i.uvMainTex).rgb;

                fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz * albedo;

                fixed3 diffuse = _LightColor0.rgb * albedo * max(0, dot(tangentNormal, tangentLightDir));

                ///t为1时，表明该像素处于消融边界处
                fixed t = 1 - smoothstep(0.0, _LineWidth, burn.r - _BurnAmount);

                fixed3 burnColor = lerp(_BurnFirstColor, _BurnSecondColor, t);

                burnColor = pow(burnColor, 5);

                UNITY_LIGHT_ATTENUATION(atten, i, i.worldPos);

                fixed3 finalColor = lerp(ambient + diffuse * atten, burnColor, t * step(0.0001, _BurnAmount));

                return fixed4(finalColor, 1);
            }
            ENDCG
        }

//        Pass
//        {
//            Tags
//            {
//                "LightMode" = "ShadowCaster"
//            }
//
//
//            CGPROGRAM
//            #pragma vertex vert
//            #pragma fragment frag
//            #pragma multi_compile_shadowcaster
//
//            struct v2f
//            {
//                V2F_SHADOW_CASTER;
//                float2 uvBurnMap:TEXCOORD1;
//            };
//
//            v2f vert(appdata_base v)
//            {
//                v2f o;
//
//                TRANSFER_SHADOW_CASTER_NORMALOFFSET(o);
//
//                o.uvBurnMap = TRANSFORM_TEX(v.texcoord, _BurnMap);
//
//                return o;
//            }
//
//            fixed4 frag(v2f i):SV_Target
//            {
//                fixed3 burn = tex2D(_BurnMap, i.uvBurnMap).rgb;
//                clip(burn.r - _BurnAmount);
//
//                SHADOW_CASTER_FRAGMENT(i)
//            }
//            ENDCG
//
//        }

    }
}