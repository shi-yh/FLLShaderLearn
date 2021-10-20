using System.Collections;
using System.Collections.Generic;
using UnityEngine;

[ExecuteInEditMode]
public class ReplacementShaderEffect : MonoBehaviour
{
    public Shader replaceShader;

    public Color color;

    private void OnValidate()
    {
        Shader.SetGlobalColor("_OverDrawColor", color);
    }

    private void OnEnable()
    {
        if (replaceShader!=null)
        {
            ///留空会直接使用shader中找到的第一个subshader
            GetComponent<Camera>().SetReplacementShader(replaceShader, "");
        }
    }

    private void OnDisable()
    {
        GetComponent<Camera>().ResetReplacementShader();
    }


}
