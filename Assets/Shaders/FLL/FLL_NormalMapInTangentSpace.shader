Shader "FLL/FLL_NormalMapInTangentSpace"
{
    Properties
    {
        _Color("Color Tint",Color) = (1,1,1,1)

        _MainTex("MainTex",2D) = "white"{}

        _BumpMap("Normal Map",2D) = "bump"{}

        _BumpScale("Bump Scale",Float) = 1.0

        _Specular("Specular",Color) = (1,1,1,1)

        _Gloss("Gloss",Range(8.0,256)) = 20

    }
    SubShader
    {
        Tags
        {
            "LightMode"="ForwardBase"
            "RenderType"="Opaque"
        }
        LOD 100

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"
            #include "Lighting.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float3 normal:NORMAL;
                ///切线方向
                float4 tangent:TANGENT;
                ///Unity会将模型的第一组纹理存储到该变量中
                float4 texcoord:TEXCOORD0;
            };

            struct v2f
            {
                float4 pos:SV_POSITION;
                float4 uv:TEXCOORD0;
                float3 lightDir:TEXCOORD1;
                float3 viewDir:TEXCOORD2;
            };

            fixed4 _Color;

            sampler2D _MainTex;

            float4 _MainTex_ST;

            sampler2D _BumpMap;

            float4 _BumpMap_ST;

            float _BumpScale;

            fixed4 _Specular;

            float _Gloss;


            v2f vert(appdata v)
            {
                v2f o;

                o.pos = UnityObjectToClipPos(v.vertex);

                o.uv.xy = v.texcoord.xy * _MainTex_ST.xy + _MainTex_ST.zw;

                o.uv.zw = v.texcoord.xy * _BumpMap_ST.xy + _BumpMap_ST.zw;


                
                // o.lightDir = mul(TANGENT_SPACE_ROTATION,ObjSpaceLightDir(v.vertex)).xyz;
                //
                //
                // o.worldNormal = UnityObjectToWorldNormal(v.normal);
                //
                // o.worldPos = UnityObjectToWorldDir(v.vertex);
                //
                // o.uv = TRANSFORM_TEX(v.texcoord, _MainTex);

                return o;
            }

            fixed4 frag(v2f i) : SV_Target
            {
                fixed3 albedo = tex2D(_MainTex, i.uv).rgb * _Color.rgb;

                fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz * albedo;
                //
                // fixed3 worldNormal = normalize(i.worldNormal);
                //
                // fixed3 worldLightDir = normalize(UnityWorldSpaceLightDir(i.worldPos));
                //
                // fixed3 diffuse = _LightColor0.rgb * albedo.rgb * saturate(dot(worldNormal, worldLightDir));
                //
                // fixed3 viewDir = normalize(UnityWorldSpaceViewDir(i.worldPos));

                // fixed3 halfDir = normalize(worldLightDir + viewDir);
                //
                // fixed3 specular = _LightColor0.rgb * _Specular.rgb * pow(max(0, (dot(worldNormal, halfDir))), _Gloss);
                //
                // return fixed4(ambient + diffuse + specular, 1.0);

                return fixed4(1,1,1,1);
            }
            ENDCG
        }
    }
}