Shader "FLL/FLL_DiffuseVertexLevel"
{
    Properties
    {
        _Diffuse("Diffuse",Color) = (1,1,1,1)
    }
    SubShader
    {
        Tags { "LightMode"="ForwardBase"
                "RenderType"="Opaque" }
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
                fixed3 color:COLOR;
            };

           fixed4 _Diffuse;

            v2f vert (appdata v)
            {
                v2f o;

                o.pos = UnityObjectToClipPos(v.vertex);
                
                fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz;
                
                fixed3 worldNormal = UnityObjectToWorldNormal(v.normal);
                
                fixed3 worldLight = normalize(_WorldSpaceLightPos0.xyz);
                
                fixed3 diffuse = _LightColor0.rgb*_Diffuse.rgb*saturate(dot(worldNormal,worldLight));
                
                o.color = ambient+diffuse;
                
                return o;
            }

          fixed4 frag (v2f i) : SV_Target
            {
                
                return fixed4(i.color,1.0);
            }
            ENDCG
        }
    }
}
