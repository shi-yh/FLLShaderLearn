using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class FLL_FogWithNoise : FLL_PostEffetctBase
{
    public Shader fogShader;
    private Material fogMateria = null;

    public Material materia
    {
        get
        {
            fogMateria = CheckShaderAndCreateMaterial(fogShader, fogMateria);
            return fogMateria;;
        }
    }

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

    private Transform myCameraTransform;

    public Transform cameraTransform
    {
        get
        {
            if (myCameraTransform==null)
            {
                myCameraTransform = myCamera.transform;
            }

            return myCameraTransform;
        }
    }

    /// <summary>
    /// 雾的浓度
    /// </summary>
    [Range(0.1f,3.0f)]
    public float fogDensity = 1.0f;
    
    /// <summary>
    /// 雾的颜色
    /// </summary>
    public Color fogColor = Color.white;

    public float fogStart = 0.0f;

    public float fogEnd = 2.0f;

    public Texture noiseTexture;

    [Range(-0.5f,0.5f)]
    public float fogXSpeed = 0.1f;

    [Range(-0.5f,0.5f)]
    public float fogYSpeed = 0.1f;

    /// <summary>
    /// 噪声强度
    /// </summary>
    [Range(0.0f,3.0f)]
    public float noiseAmount = 1.0f;

    private void OnEnable()
    {
        camera.depthTextureMode |= DepthTextureMode.Depth;
    }


    private void OnRenderImage(RenderTexture src, RenderTexture dest)
    {
        if (materia!=null)
        {
            Matrix4x4 frustumCorners = Matrix4x4.identity;

            float fov = camera.fieldOfView;
            float near = camera.nearClipPlane;
            float far = camera.farClipPlane;
            float aspect = camera.aspect;

            float halfHeight = near * Mathf.Tan(fov * 0.5f * Mathf.Deg2Rad);

            Vector3 toRight = cameraTransform.right * halfHeight * aspect;
            Vector3 toTop = cameraTransform.up * halfHeight;
           
            ///首先计算了近裁剪平面的四个角对应的向量
            Vector3 topLeft = cameraTransform.forward * near + toTop - toRight;
            float scale = topLeft.magnitude / near;
            topLeft.Normalize();
            topLeft *= scale;

            Vector3 topRight = cameraTransform.forward * near + toRight + toTop;
            topRight.Normalize();
            topRight *= scale;

            Vector3 bottomLeft = cameraTransform.forward * near - toTop - toRight;
            bottomLeft.Normalize();
            bottomLeft *= scale;

            Vector3 bottomRight = cameraTransform.forward * near + toRight - toTop;
            bottomRight.Normalize();
            bottomRight *= scale;

            
            frustumCorners.SetRow(0,bottomLeft);
            frustumCorners.SetRow(1,bottomRight);
            frustumCorners.SetRow(2,topRight);
            frustumCorners.SetRow(3, topLeft);

            materia.SetMatrix("_FrustumCornersRay",frustumCorners);
            materia.SetFloat("_FogDensity",fogDensity);
            materia.SetColor("_FogColor",fogColor);
            materia.SetFloat("_FogStart",fogStart);
            materia.SetFloat("_FogEnd",fogEnd);
            
            materia.SetTexture("_NoiseTex",noiseTexture);
            materia.SetFloat("_FogXSpeed",fogXSpeed);
            materia.SetFloat("_FogYSpeed",fogYSpeed);
            
            materia.SetFloat("NoiseAmount",noiseAmount);
            Graphics.Blit(src,dest,materia);
        }
        else
        {
            Graphics.Blit(src,dest);
        }
        
        
        
    }
}
