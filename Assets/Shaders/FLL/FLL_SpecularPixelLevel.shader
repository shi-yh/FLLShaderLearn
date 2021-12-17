Shader "FLL/FLL_SpecularPixelLevel"
{
    Properties
    {
        _Diffuse("Diffuse",Color) = (1,1,1,1)
        
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
            };

            struct v2f
            {
                float4 pos:SV_POSITION;
                float3 worldNormal:TEXCOORD0;
                float3 worldPos:TEXCOORD1;

            };

            fixed4 _Diffuse;

            fixed4 _Specular;

            float _Gloss;
            

            v2f vert(appdata v)
            {
                v2f o;

                o.pos = UnityObjectToClipPos(v.vertex);

                o.worldNormal = UnityObjectToWorldNormal(v.normal);

                o.worldPos = UnityObjectToWorldDir(v.vertex);
                
                return o;
            }

            fixed4 frag(v2f i) : SV_Target
            {
                fixed3 ambient  = UNITY_LIGHTMODEL_AMBIENT.xyz;

                fixed3 worldNormal = normalize(i.worldNormal);

                fixed3 worldLightDir = normalize(_WorldSpaceLightPos0.xyz);

                fixed3 diffuse =_LightColor0.rgb*_Diffuse.rgb*saturate(dot(worldNormal,worldLightDir));

                fixed3 reflectDir = normalize(reflect(-worldLightDir,worldNormal));

                fixed3 viewDir = normalize(_WorldSpaceCameraPos.xyz-i.worldPos);

                fixed3 specular = _LightColor0.rgb*_Specular.rgb*pow(saturate(dot(reflectDir,viewDir)),_Gloss);
                
                return fixed4(ambient+diffuse+specular,1.0) ;
            }
            ENDCG
        }
    }
}