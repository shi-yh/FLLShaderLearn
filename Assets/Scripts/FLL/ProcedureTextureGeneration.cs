using System;
using System.Collections;
using System.Collections.Generic;
using System.ComponentModel;
using UnityEngine;
using UnityEngine.Experimental.Playables;

[ExecuteInEditMode]
public class ProcedureTextureGeneration : MonoBehaviour
{
    public Material material = null;

    private Texture2D _genearteTexture;
    
    
    #region Material properties

    [SerializeField] private int _textureWidth = 512;

    public int textureWidth
    {
        get { return _textureWidth; }
        set
        {
            _textureWidth = value;

            UpdateMaterial();
        }
    }

    [SerializeField]
    private Color _backgroundColor = Color.white;

    public Color backGroundColor
    {
        get { return _backgroundColor; }
        set
        {
            _backgroundColor = value;
            UpdateMaterial();
        }
    }


    [SerializeField] private Color _circleColor = Color.yellow;

    public Color circleColor
    {
        get { return _circleColor; }
        set
        {
            _circleColor = value;

            UpdateMaterial();
        }
    }

    /// <summary>
    /// 模糊因子
    /// </summary>
    [SerializeField] private float _blurFactor;

    private static readonly int MainTex = Shader.PropertyToID("_MainTex");

    public float blurFactor
    {
        get { return _blurFactor; }
        set
        {
            _blurFactor = value;
            UpdateMaterial();
            ;
        }
    }

    #endregion

    private void Start()
    {
        if (material==null)
        {
            Renderer renderer = gameObject.GetComponent<Renderer>();

            if (renderer==null)
            {
                Debug.LogWarning("Cannot find renderer");
                return;
            }

            material = renderer.sharedMaterial;
        }
        
        UpdateMaterial();
    }


    private void UpdateMaterial()
    {
        if (material!=null)
        {
            _genearteTexture = GenerateProceduralTexture();
            material.SetTexture("_MainTex",_genearteTexture);
            // material.SetTexture(MainTex,new Texture2D(textureWidth, textureWidth));
        }
    }

    private Texture2D GenerateProceduralTexture()
    {
        Texture2D proceduralTexture = new Texture2D(textureWidth, textureWidth);

        float circleInterval = textureWidth / 4;

        float radius = textureWidth / 10.0f;

        float edgeBlur = 1.0f / blurFactor;

        for (int w = 0; w < textureWidth; w++)
        {
            for (int h = 0; h < textureWidth; h++)
            {
                Color pixel = backGroundColor;

                ///依次画9个圆
                for (int i = 0; i < 3; i++)
                {
                    for (int j = 0; j < 3; j++)
                    {
                        ///圆心位置
                        Vector2 circleCenter = new Vector2(circleInterval * (i + 1), circleInterval * (j + 1));
                        ///当前pixel距离圆心的距离
                        float dist = Vector2.Distance(new Vector2(w, h), circleCenter) - radius;
                        
                        ///距离圆心越近，颜色用圆的颜色，越远用背景色
                        Color color = MixColor(circleColor, new Color(pixel.r, pixel.g, pixel.b, 0.0f), Mathf.SmoothStep(0, 1, dist * edgeBlur));

                        pixel = MixColor(pixel, color, color.a);
                    }
                }
                
                proceduralTexture.SetPixel(w,h,pixel);
            }
        }

        proceduralTexture.Apply();

        return proceduralTexture;
    }

    private Color MixColor(Color color0, Color color1, float mixFactor)
    {
        Color mixColor = Color.white;
        mixColor.r = Mathf.Lerp(color0.r, color1.r, mixFactor);
        mixColor.g = Mathf.Lerp(color0.g, color1.g, mixFactor);
        mixColor.b = Mathf.Lerp(color0.b, color1.b, mixFactor);
        mixColor.a = Mathf.Lerp(color0.a, color1.a, mixFactor);
        return mixColor;
    }
}