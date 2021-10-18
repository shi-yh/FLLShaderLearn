using System.Collections;
using System.Collections.Generic;
using UnityEngine;


[ExecuteInEditMode]
public class PostEffects : MonoBehaviour
{

    public Material materia;

    private void OnRenderImage(RenderTexture source, RenderTexture destination)
    {
        ///Blit方法会把source中传入的纹理赋值给material的主纹理
        ///source即为原本摄像机会绘制的图像
        Graphics.Blit(source, destination, materia); 
    }

}
