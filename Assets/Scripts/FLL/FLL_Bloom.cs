using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class FLL_Bloom : FLL_PostEffetctBase
{
   public Shader bloomShader;
   private Material bloomMaterial;

   public Material material
   {
      get
      {
         bloomMaterial = CheckShaderAndCreateMaterial(bloomShader, bloomMaterial);
         return bloomMaterial;
      }
   }
   
   /// <summary>
   /// 模糊循环次数
   /// </summary>
   [Range(0, 4)] public int interations = 3;

   /// <summary>
   /// 采样偏差，和每个纹素附近多少的纹素进行混合
   /// </summary>
   [Range(0.2f, 3.0f)] public float blueSpread = 0.6f;

   /// <summary>
   /// 缩放后的图片进行模糊处理
   /// </summary>
   [Range(1, 8)] public int downSample = 2;

   [Range(0.0f,4.0f)]
   public float luminanceThreshold = 0.6f;


   private void OnRenderImage(RenderTexture src, RenderTexture dest)
   {
      if (material != null)
      {
         material.SetFloat("_LuminanceThreshold",luminanceThreshold);
         
         ///缩放图像进行采样
         int rtW = src.width/downSample;

         int rtH = src.height/downSample;

         RenderTexture buffer = RenderTexture.GetTemporary(rtW, rtH, 0);

         buffer.filterMode = FilterMode.Bilinear;

         ///提亮区域
         Graphics.Blit(src,buffer,material,0);

         for (int i = 0; i < interations; i++)
         {
            material.SetFloat("_BlurSize",1.0f+i*blueSpread);

            RenderTexture buffer1 = RenderTexture.GetTemporary(rtW, rtH, 0);
                
            Graphics.Blit(buffer,buffer1,material,1);
                
            RenderTexture.ReleaseTemporary(buffer);

            buffer = buffer1;
                
            buffer1 = RenderTexture.GetTemporary(rtW, rtH, 0);

            Graphics.Blit(buffer,buffer1,material,2);
                
            RenderTexture.ReleaseTemporary(buffer);

            buffer = buffer1;
         }
            
         material.SetTexture("_Bloom",buffer);
         
         Graphics.Blit(src,dest,material,3);
            
         RenderTexture.ReleaseTemporary(buffer);
      }
      else
      {
         Graphics.Blit(src,dest);
      }
   }
}
