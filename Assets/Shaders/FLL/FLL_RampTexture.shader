Shader "FLL/FLL_RampTexture"
{
    Properties
    {
        _Color("Color Tint",Color) = (1,1,1,1)
        _RampTex("RampTex",2D) = "white"{}
        _Specular("Specular",Color) = (1,1,1,1)
        _Gloss("Gloss",Range(8.0,256))=20
    }
    SubShader
    {
        Tags { 
            "LightMode" = "ForwardBase"
            "RenderType"="Opaque"
             }
        LOD 100

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            // make fog work
            #pragma multi_compile_fog

            #include "UnityCG.cginc"
            #include "Lighting.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float2 texcoord : TEXCOORD0;
                float3 normal:NORMAL;
            };

            struct v2f
            {
                UNITY_FOG_COORDS(1)
                float4 vertex : SV_POSITION;
                float3 worldPos:TEXCOORD0;
                float3 worldNormal:TEXCOORD1;
                float2 uv : TEXCOORD2;

            };

            float4 _Color;

            sampler2D _RampTex;
            float4 _RampTex_ST;
            fixed4 _Specular;
            float _Gloss;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.texcoord, _RampTex);
                o.worldNormal = UnityObjectToWorldNormal(v.normal);
                o.worldPos = UnityObjectToWorldDir(v.vertex);
                UNITY_TRANSFER_FOG(o,o.vertex);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                fixed3 worldNormal = normalize(i.worldNormal);
                fixed3 worldLightDir = normalize(UnityWorldSpaceLightDir(i.worldPos));

                fixed3 ambient =UNITY_LIGHTMODEL_AMBIENT.xyz;

                fixed halfLambert = 0.5*dot(worldNormal,worldLightDir)+0.5;
                fixed3 diffuseColor = tex2D(_RampTex,fixed2(halfLambert,halfLambert)).rgb*_Color;

                fixed3 diffuse = _LightColor0.rgb*diffuseColor;

                fixed3 viewDir = normalize(UnityWorldToViewPos(i.worldPos));
                fixed3 halfDir = normalize(worldLightDir+viewDir);

                fixed3 specular = _LightColor0.rgb*_Specular.rgb*pow(max(0,dot(worldNormal,halfDir)),_Gloss);
                

                // apply fog
                UNITY_APPLY_FOG(i.fogCoord, col);
                return fixed4(ambient+diffuse+specular,1.0);
            }
            ENDCG
        }
    }
}
