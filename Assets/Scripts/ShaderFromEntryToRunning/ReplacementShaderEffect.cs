using System.Collections;
using System.Collections.Generic;
using UnityEngine;

[ExecuteInEditMode]
public class ReplacementShaderEffect : MonoBehaviour
{
    public Shader replaceShader;

    public Color color;

    public Texture _MainTex;

    public Texture _SecondTex;


    private void OnValidate()
    {
        Shader.SetGlobalColor("_OverDrawColor", color);
        Shader.SetGlobalTexture("_MainTex2", _MainTex);
        Shader.SetGlobalTexture("_SecondTex2", _SecondTex);
    }

    private void OnEnable()
    {
        if (replaceShader!=null)
        {
            ///留空会直接使用shader中找到的第一个subshader
            GetComponent<Camera>().SetReplacementShader(replaceShader, "RenderType");
        }
    }

    private void OnDisable()
    {
        GetComponent<Camera>().ResetReplacementShader();
    }


}
