Shader "CRLuo/CRLuo_MaskColor"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        
        _MaskTex("Mask Texture",2D) = "white" {}
        [Space]
        _Color_R_H("R通道替换",Color)= (1,0,0,1)
        _Color_R_M("R通道替换",Color)= (1,0,0,1)
        _Color_R_L("R通道替换",Color)= (1,0,0,1)
        [Space]
        _Color_G_H("G通道替换",Color)= (0,1,0,1)
        _Color_G_M("G通道替换",Color)= (0,1,0,1)
        _Color_G_L("G通道替换",Color)= (0,1,0,1)
        [Space]
        _Color_B_H("B通道替换",Color)= (0,0,1,1)
        _Color_B_M("B通道替换",Color)= (0,0,1,1)
        _Color_B_L("B通道替换",Color)= (0,0,1,1)
        [Space]
        _Color_A_H("A通道替换",Color)= (0,0,0,1)
        _Color_A_M("A通道替换",Color)= (0,0,0,1)
        _Color_A_L("A通道替换",Color)= (0,0,0,1)
        
    }
    
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 100

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
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                UNITY_FOG_COORDS(1)
                float4 vertex : SV_POSITION;
            };

            sampler2D _MainTex;
            sampler2D _MaskTex;
            
            float4 _MainTex_ST;

            fixed4 _Color_R_H;
			fixed4 _Color_G_H;
			fixed4 _Color_B_H;
			fixed4 _Color_A_H;

			fixed4 _Color_R_M;
			fixed4 _Color_G_M;
			fixed4 _Color_B_M;
			fixed4 _Color_A_M;

			fixed4 _Color_R_L;
			fixed4 _Color_G_L;
			fixed4 _Color_B_L;
			fixed4 _Color_A_L;



            
            /**
             * \brief 
             * \param _color_H  亮色变量
             * \param _color_M 暗色变量
             * \param _color_l 过渡变量
             * \param _ramp 过渡过程
             * \return 颜色结果
             */
            fixed4 Three_Color_Ramp(fixed4 _color_H,fixed4 _color_M, fixed4 _color_l,float _ramp)
            {

                fixed _ramp_BG = saturate(_ramp*2);
                //获取黑灰色彩
                fixed4 _color_BG = lerp(_color_l,_color_M,_ramp_BG);
                
                fixed _ramp_GW = saturate((_ramp-0.5)*2);
                //获取灰白色彩
                fixed4 _color_GW = lerp(_color_M,_color_H,_ramp_GW);

                fixed4 _OutColor = lerp(_color_BG,_color_GW,_ramp);

                return _OutColor;
                
            }

            
            
            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                UNITY_TRANSFER_FOG(o,o.vertex);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                // sample the texture
                fixed4 col = tex2D(_MainTex, i.uv);

                fixed4 mask = tex2D(_MaskTex,i.uv);

                float gray = dot(col.rgb,float3(0.299,0.587,0.114));
                
                fixed3 rrr=Three_Color_Ramp(_Color_R_H,_Color_R_M,_Color_R_L,gray);
                fixed3 ggg=Three_Color_Ramp(_Color_G_H,_Color_G_M,_Color_G_L,gray);
                fixed3 bbb=Three_Color_Ramp(_Color_B_H,_Color_B_M,_Color_B_L,gray);
                // fixed3 aaa=Three_Color_Ramp(_Color_A_H,_Color_A_M,_Color_A_L,gray);

                col.rgb = lerp(col.rgb,rrr,mask.r);
                col.rgb = lerp(col.rgb,ggg,mask.g);
                col.rgb = lerp(col.rgb,bbb,mask.b);
                // col.rgb = lerp(col.rgb,aaa,mask.a);

                clip(col.a-0.5);
                // apply fog
                UNITY_APPLY_FOG(i.fogCoord, col);
                return col;
            }
            ENDCG
        }
    }
}
