using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class FLL_MotionBlur : FLL_PostEffetctBase
{
    public Shader motionBlurShader;

    private Material motionBlurMaterial = null;

    public Material material
    {
        get
        {
            motionBlurMaterial = CheckShaderAndCreateMaterial(motionBlurShader, motionBlurMaterial);
            return motionBlurMaterial;
        }
    }

    private RenderTexture accmulationTexture;

    [Range(0.0f, 0.9f)] public float blurAmount = 0.5f;


    private void OnDisable()
    {
        DestroyImmediate(accmulationTexture);
    }


    
    private void OnRenderImage(RenderTexture src, RenderTexture dest)
    {
        if (material != null)
        {
            if (accmulationTexture == null || accmulationTexture.width != src.width || accmulationTexture.height != src.height)
            {
                DestroyImmediate(accmulationTexture);

                accmulationTexture = new RenderTexture(src.width, src.height, 0);

                accmulationTexture.hideFlags = HideFlags.HideAndDontSave;

                Graphics.Blit(src, accmulationTexture);
            }
            

            material.SetFloat("_BlurAmount", 1.0f - blurAmount);
            
            ///不是特别理解，accmulationTexture好像没有用到？是因为accmulationTexture函数obsolete了？
            Graphics.Blit(src,accmulationTexture,material);
            Graphics.Blit(accmulationTexture,dest);
            
        }
        else
        {
            Graphics.Blit(src,dest);
        }
    }
}