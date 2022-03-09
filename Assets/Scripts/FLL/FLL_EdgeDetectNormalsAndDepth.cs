using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class FLL_EdgeDetectNormalsAndDepth : FLL_PostEffetctBase
{

    public Shader edgeDetectShader;

    private Material edgeDetectMaterial;

    public Material material
    {
        get
        {
            edgeDetectMaterial = CheckShaderAndCreateMaterial(edgeDetectShader, edgeDetectMaterial);
            return edgeDetectMaterial;
        }
    }

    [Range(0.0f,1.0f)]
    public float edgesOnly = 0.0f;

    public Color edgeColor = Color.black;
    
    public Color backgroundColor = Color.white;
    
    /// <summary>
    /// 控制对深度+法线采样时，使用的采样距离，从视觉上来看，采样距离越大，描边越宽
    /// </summary>
    public float sampleDistance = 1.0f;

    /// <summary>
    /// 深度检测差值【达到时认为有一条边缘】
    /// </summary>
    public float sensitivityDepth = 1.0f;
    /// <summary>
    /// 法线检测差值
    /// </summary>
    public float sensitivityNormals = 1.0f;

    private void OnEnable()
    {
        GetComponent<Camera>().depthTextureMode |= DepthTextureMode.DepthNormals;
    }


    /// <summary>
    /// 在默认情况下，OnRenderImage函数会在所有的不透明和透明的pass执行完毕后调用，以便对场景中所有的游戏对象都产生影响
    /// </summary>
    /// <param name="src"></param>
    /// <param name="dest"></param>
    [ImageEffectOpaque]
    private void OnRenderImage(RenderTexture src, RenderTexture dest)
    {
        if (material!=null)
        {
            material.SetFloat("_EdgeOnly", edgesOnly);
            material.SetColor("_EdgeColor",edgeColor);
            material.SetColor("_BackgroundColor",backgroundColor);
            material.SetFloat("_SampleDistance",sampleDistance);
            material.SetVector("_Sensitivity",new Vector4(sensitivityNormals,sensitivityDepth,0,0));
            
            Graphics.Blit(src,dest,material);
            
        }
        else
        {
            Graphics.Blit(src,dest);
        }
    }
}
