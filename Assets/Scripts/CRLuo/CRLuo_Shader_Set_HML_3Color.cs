using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using Random = UnityEngine.Random;

public class CRLuo_Shader_Set_HML_3Color : MonoBehaviour
{
    private List<Material> _objAllMaterials;

    private void Start()
    {
        GetALlMaterias();
    }

    void GetALlMaterias()
    {
        if (_objAllMaterials == null)
        {
            _objAllMaterials = new List<Material>();
        }

        _objAllMaterials.Clear();

        MeshRenderer[] myMeshRenderers = this.gameObject.GetComponentsInChildren<MeshRenderer>();

        foreach (MeshRenderer myMeshRenderer in myMeshRenderers)
        {
            foreach (var material in myMeshRenderer.materials)
            {
                _objAllMaterials.Add(material);
            }
        }

        SkinnedMeshRenderer[] mySkinnedMeshRenderers = this.gameObject.GetComponentsInChildren<SkinnedMeshRenderer>();

        foreach (SkinnedMeshRenderer skinnedMeshRenderer in mySkinnedMeshRenderers)
        {
            foreach (var material in skinnedMeshRenderer.materials)
            {
                _objAllMaterials.Add(material);
            }
        }
    }


    private Color ColorRandom()
    {
        float Rr = Random.Range(0f, 1f);
        float Gg = Random.Range(0f, 1f);
        float Bb = Random.Range(0f, 1f);
        float Aa = Random.Range(0f, 1f);
        return new Color(Rr, Gg, Bb, Aa);
    }

    Color[] ColorHML(Color InColor, float Offset)
    {
        Color[] OutColor = new Color[3];

        OutColor[0] = Color.Lerp(InColor, InColor + InColor + InColor, Offset);

        OutColor[1] = InColor;

        OutColor[2] = Color.Lerp(InColor, InColor * InColor * InColor, Offset);

        return OutColor;
    }

    private void SetMateriaColor()
    {
        Color[] Channel_R = ColorHML(ColorRandom(), Random.Range(0.5f, 1f));
        Color[] Channel_G= ColorHML(ColorRandom(), Random.Range(0.5f, 1f));
        Color[] Channel_B = ColorHML(ColorRandom(), Random.Range(0.5f, 1f));
        Color[] Channel_A = ColorHML(ColorRandom(), Random.Range(0.5f, 1f));

        for (int i = 0; i < _objAllMaterials.Count; i++)
        {
            _objAllMaterials[i].SetColor("_Color_R_H",Channel_R[0]);
            _objAllMaterials[i].SetColor("_Color_R_M",Channel_R[1]);
            _objAllMaterials[i].SetColor("_Color_R_L",Channel_R[2]);
            
            _objAllMaterials[i].SetColor("_Color_G_H",Channel_G[0]);
            _objAllMaterials[i].SetColor("_Color_G_M",Channel_G[1]);
            _objAllMaterials[i].SetColor("_Color_G_L",Channel_G[2]);
            
            
            _objAllMaterials[i].SetColor("_Color_B_H",Channel_B[0]);
            _objAllMaterials[i].SetColor("_Color_B_M",Channel_B[1]);
            _objAllMaterials[i].SetColor("_Color_B_L",Channel_B[2]);
            
            _objAllMaterials[i].SetColor("_Color_A_H",Channel_A[0]);
            _objAllMaterials[i].SetColor("_Color_A_M",Channel_A[1]);
            _objAllMaterials[i].SetColor("_Color_A_L",Channel_A[2]);
            
        }


    }

    public void BtnSetMateria()
    {
        SetMateriaColor();
    }
    
}