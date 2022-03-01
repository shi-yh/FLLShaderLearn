using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

[ExecuteInEditMode]
[RequireComponent(typeof(Camera))]
public class FLL_PostEffetctBase : MonoBehaviour
{
    protected bool enable;

    protected void CheckResource()
    {
        bool supported = CheckSupport();
        if (!supported)
        {
            NotSupported();
        }
    }

    private void NotSupported()
    {
        enable = false;
    }

    /// <summary>
    /// 教程中这里需要做一些检测，但是在新版unity中则不需要
    /// </summary>
    /// <returns></returns>
    protected bool CheckSupport()
    {
        return true;
    }

    // Start is called before the first frame update
    void Start()
    {
        CheckResource();
    }

    private void OnEnable()
    {
       
    }

    protected Material CheckShaderAndCreateMaterial(Shader shader, Material material)
    {
        if (shader == null)
        {
            return null;
        }

        if (shader.isSupported && material && material.shader == shader)
        {
            return material;
        }


        if (!shader.isSupported)
        {
            return null;
        }
        else
        {
            material = new Material(shader);
            material.hideFlags = HideFlags.DontSave;

            if (material)
            {
                return material;
            }
            else
            {
                return null;
            }
        }
    }

    // Update is called once per frame
    void Update()
    {
    }
}