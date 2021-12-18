Shader "FLL/FLL_NormalMapWorldSpace"
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
                ///这次输入了两组纹理
                float4 texcoord:TEXCOORD0;
            };

            struct v2f
            {
                float4 pos:SV_POSITION;

                ///每一组纹理会占用float2
                float4 uv:TEXCOORD0;

                float4 TtoW0:TEXCOORD1;

                float4 TtoW1:TEXCOORD2;

                float4 TtoW2:TEXCOORD3;
                
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

                float3 worldPos = mul(unity_ObjectToWorld,v.vertex).xyz;

                fixed3 worldNormal = UnityObjectToWorldNormal(v.normal);

                fixed3 worldTangent = UnityObjectToWorldDir(v.tangent.xyz);

                fixed3 worldBinormal = cross(worldNormal,worldTangent)*v.tangent.w;

                o.TtoW0 = float4(worldTangent.x,worldBinormal.x,worldNormal.x,worldPos.x);
                o.TtoW1 = float4(worldTangent.y,worldBinormal.y,worldNormal.y,worldPos.y);
                o.TtoW2 = float4(worldTangent.z,worldBinormal.z,worldNormal.z,worldPos.z);
        
                return o;
            }

            fixed4 frag(v2f i) : SV_Target
            {
                float3 worldPos = float3(i.TtoW0.w,i.TtoW1.w,i.TtoW2.w);

                fixed3 lightDir = normalize(UnityWorldSpaceLightDir(worldPos));

                fixed3 viewDir = normalize(UnityWorldSpaceViewDir(worldPos));

                ///法线纹理存储的是法线经过映射后的像素值，所以需要映射回来
                fixed3 bump = UnpackNormal(tex2D(_BumpMap,i.uv.zw));

                bump.xy *= _BumpScale;

                bump.z = sqrt(1.0-saturate(dot(bump.xy,bump.xy)));

                bump = normalize(half3(dot(i.TtoW0.xyz,bump),dot(i.TtoW1.xyz,bump),dot(i.TtoW2.xyz,bump)));

                fixed3 albedo = tex2D(_MainTex, i.uv).rgb * _Color.rgb;

                fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz * albedo;

                fixed3 diffuse=_LightColor0.rgb*albedo*max(0,dot(bump,lightDir));

                fixed3 halfDir = normalize(lightDir+viewDir);
                
                fixed3 specular = _LightColor0.rgb*_Specular.rgb*pow(max(0,dot(bump,halfDir)),_Gloss);
                
                return fixed4(ambient+diffuse+specular,1);
            }
            ENDCG
        }
    }
}