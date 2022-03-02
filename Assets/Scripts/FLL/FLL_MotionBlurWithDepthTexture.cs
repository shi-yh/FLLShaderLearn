using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.Experimental.Playables;
using UnityEngine.UI;

public class FLL_MotionBlurWithDepthTexture : FLL_PostEffetctBase
{
    public Shader motionBlurShader;

    private Material motionBlurMaterial;

    public Material material
    {
        get
        {
            motionBlurMaterial = CheckShaderAndCreateMaterial(motionBlurShader, motionBlurMaterial);
            return motionBlurMaterial;
        }
    }

    [Range(0.0f,1.0f)]
    public float blurSize = 0.5f;

    private Camera myCamera;

    public Camera camera
    {
        get
        {
            if (myCamera==null)
            {
                myCamera = GetComponent<Camera>();
            }

            return myCamera;
        }
    }
        
    /// <summary>
    /// 上一帧摄像机的视角*投影矩阵
    /// </summary>
    private Matrix4x4 previousViewProjectMatrix;

    void OnEnable()
    {
        camera.depthTextureMode |= DepthTextureMode.Depth;
        
        previousViewProjectMatrix = camera.projectionMatrix * camera.worldToCameraMatrix;
        
    }

    private void OnRenderImage(RenderTexture src, RenderTexture dest)
    {
        if (material!=null)
        {
            material.SetFloat("_BlurSize",blurSize);
            
            material.SetMatrix("_PreviousViewProjectionMatrix",previousViewProjectMatrix);

            ///计算当前帧的视角*投影矩阵
            Matrix4x4 currentViewProjectMatrix = camera.projectionMatrix * camera.worldToCameraMatrix;
            ///当前帧的视角*投影矩阵的逆矩阵
            Matrix4x4 currentViewProjectionInverseMatrix = currentViewProjectMatrix.inverse;
            
            material.SetMatrix("_CurrentViewProjectionInverseMatrix",currentViewProjectionInverseMatrix);

            previousViewProjectMatrix = currentViewProjectMatrix;
            
            Graphics.Blit(src,dest,material);

        }
        else
        {
            Graphics.Blit(src,dest);
        }
    }
}
