using System.Collections;
using System.Collections.Generic;
using UnityEngine;

[ExecuteInEditMode]
public class ReplacementShaderEffect : MonoBehaviour
{
    public Shader replaceShader;

    private void OnEnable()
    {
        if (replaceShader!=null)
        {
            GetComponent<Camera>().SetReplacementShader(replaceShader, "RenderType");
        }
    }

    private void OnDisable()
    {
        GetComponent<Camera>().ResetReplacementShader();
    }


}
