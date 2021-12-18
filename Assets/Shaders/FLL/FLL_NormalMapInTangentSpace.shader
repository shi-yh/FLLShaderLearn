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
                ///这次输入了两组纹理
                float4 texcoord:TEXCOORD0;
            };

            struct v2f
            {
                float4 pos:SV_POSITION;

                ///每一组纹理会占用float2
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

                ///副切线，因为和切线与法线方向都垂直的方向有两个，w决定使用哪个方向
                float3 binormal = cross(normalize(v.normal),normalize(v.tangent.xyz))*v.tangent.w;
                ///使用模型空间下切线方向，副切线方向和法线方向得到从模型空间到切线空间的变换矩阵
                float3x3 rotation = float3x3(v.tangent.xyz,binormal,v.normal);
                o.lightDir = mul(rotation,ObjSpaceLightDir(v.vertex)).xyz;
                o.viewDir = mul(rotation,ObjSpaceViewDir(v.vertex));
        
                return o;
            }

            fixed4 frag(v2f i) : SV_Target
            {
                fixed3 tangentLightDir = normalize(i.lightDir);

                fixed3 tangentViewDir = normalize(i.viewDir);

                fixed4 packedNormal = tex2D(_BumpMap,i.uv.zw);

                ///法线纹理存储的是法线经过映射后的像素值，所以需要映射回来
                fixed3 tangetNormal = UnpackNormal(packedNormal);

                tangetNormal.xy *= _BumpScale;

                tangetNormal.z = sqrt(1.0-saturate(dot(tangetNormal.xy,tangetNormal.xy)));

                fixed3 albedo = tex2D(_MainTex, i.uv).rgb * _Color.rgb;

                fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz * albedo;

                fixed3 diffuse=_LightColor0.rgb*albedo*max(0,dot(tangetNormal,tangentLightDir));

                fixed3 halfDir = normalize(tangentLightDir+tangentViewDir);
                fixed3 specular = _LightColor0.rgb*_Specular.rgb*pow(max(0,dot(tangetNormal,halfDir)),_Gloss);
                
                return fixed4(ambient+diffuse+specular,1);
            }
            ENDCG
        }
    }
}