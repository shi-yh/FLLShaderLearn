Shader "FLL/FLL_WaterWave"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _Color("Color",Color) = (0,0.15,0.115,1)
        _WaveMap("Wave Map" ,2D) = "bump"{}
        _CubeMap("Cube Map",Cube) = "_Skybox"{}
        _WaveXSpeed("Wave Horizontal Speed",Range(-0.1,0.1))=0.01
        _WaveYSpeed("Wave Vertical Speed",Range(-0.1,0.1))=0.01
        _Distortion("Distortion",Range(0,100))=10
    }
    SubShader
    {
        ///巩固：Queue设置成Transparent为了保证该物体渲染时，所有的不透明物体已经被渲染
        ///Render Type则是为了在使用着色器替换时，该物体可以在需要时被正确渲染
        Tags
        {
            "RenderType"="Opaque"
            "Queue" = "Transparent"
        }

        ///抓取了当前的屏幕图像的pass，把它存在_RefractionTex中
        GrabPass
        {
            "_RefractionTex"
        }

        CGINCLUDE
        #include "UnityCG.cginc"

        fixed4 _Color;
        sampler2D _MainTex;
        float4 _MainTex_ST;
        sampler2D _WaveMap;
        float4 _WaveMap_ST;
        samplerCUBE _CubeMap;
        fixed _WaveXSpeed;
        fixed _WaveYSpeed;
        float _Distortion;
        sampler2D _RefractionTex;
        float4 _RefractionTex_TexelSize;
        ENDCG


        Pass
        {
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
                float3 normal:NORMAL;
                float4 tangent:TANGENT;
            };

            struct v2f
            {
                float4 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;
                float4 scrPos:TEXCOORD1;
                float4 TtoW0:TEXCOORD2;
                float4 TtoW1:TEXCOORD3;
                float4 TtoW2:TEXCOORD4;
            };


            v2f vert(appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                ///得到对应被抓取屏幕图像的采样坐标
                o.scrPos = ComputeGrabScreenPos(o.vertex);

                o.uv.xy = TRANSFORM_TEX(v.uv, _MainTex);
                o.uv.zw = TRANSFORM_TEX(v.uv, _WaveMap);

                ///计算从该顶点对应的从切线空间到世界空间的变换矩阵
                ///首先得到切线空间下的三个坐标轴：x代表切线，y代表副切线，z代表法线
                ///然后用w存储世界坐标，充分利用
                float3 worldPos = mul(unity_ObjectToWorld, v.vertex).xyz;

                fixed3 worldNormal = UnityObjectToWorldNormal(v.normal);
                fixed3 worldTangent = UnityObjectToWorldDir(v.tangent.xyz);

                fixed3 worldBinormal = cross(worldNormal, worldTangent) * v.tangent.w;

                o.TtoW0 = float4(worldTangent.x, worldBinormal.x, worldNormal.x, worldPos.x);
                o.TtoW1 = float4(worldTangent.y, worldBinormal.y, worldNormal.y, worldPos.y);
                o.TtoW2 = float4(worldTangent.z, worldBinormal.z, worldNormal.z, worldPos.z);

                return o;
            }

            fixed4 frag(v2f i) : SV_Target
            {
                ///首先获得世界坐标
                float3 worldPos = float3(i.TtoW0.w, i.TtoW1.w, i.TtoW2.w);
                ///得到该片源的视角返岗
                fixed3 viewDir = normalize(UnityWorldSpaceViewDir(worldPos));
                ///计算当前法线纹理的偏移量
                float2 speed = _Time.y * float2(_WaveXSpeed, _WaveYSpeed);

                ///对法线纹理进行两次采样（模拟两层交叉的水的水面波动效果）
                fixed3 bump1 = UnpackNormal(tex2D(_WaveMap, i.uv.zw + speed)).rgb;
                fixed3 bump2 = UnpackNormal(tex2D(_WaveMap, i.uv.zw - speed)).rgb;
                ///得到切线空间下的法线方向
                fixed3 bump = normalize(bump1 + bump2);

                ///使用切线空间下的法线方向进行偏移，因为改空间下的法线可以反映顶点局部空间下的法线方向
                ///乘上z分量是为了模拟深度越大，折射程度越大的效果
                float2 offset = bump.xy * _Distortion * _RefractionTex_TexelSize.xy;
                ///透视除法
                i.scrPos.xy = offset * i.scrPos.z + i.scrPos.xy;

                ///对被捕获的屏幕贴图进行采样
                fixed3 refrCol = tex2D(_RefractionTex, i.scrPos.xy / i.scrPos.w).rgb;

                ///获取世界空间下的法线
                bump = normalize(half3(dot(i.TtoW0.xyz, bump), dot(i.TtoW1.xyz, bump), dot(i.TtoW2.xyz, bump)));

                fixed4 texColor = tex2D(_MainTex, i.uv.xy + speed);
                fixed3 reflDir = reflect(-viewDir, bump);
                fixed3 reflCol = texCUBE(_CubeMap, reflDir).rgb * texColor.rgb * _Color.rgb;

                fixed fresnel = pow(1 - saturate(dot(viewDir, bump)), 4);
                fixed3 finalColor = reflCol * fresnel + refrCol * (1 - fresnel);

                return fixed4(finalColor, 1);
            }
            ENDCG
        }
    }
}