using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class EdgeDetection : PostEffectBase
{

    public Shader edgeDetectShader;
    private Material edgeDetectMat;

    public Material GetMat
    {
        get
        {
            edgeDetectMat = CheckShaderAndCreateMaterial(edgeDetectShader, edgeDetectMat);
            return edgeDetectMat;
        }
    }

    [Range(0.0f,1.0f)]
    public float edgeOnly = 1.0f;
    [ColorUsage(true)]
    public Color edgeColor = Color.black;
    public Color bgColor = Color.white;
    private void OnRenderImage(RenderTexture source, RenderTexture destination)
    {
        if(GetMat!=null)
        {
            GetMat.SetFloat("_EdgeOnly", edgeOnly);
            GetMat.SetColor("_EdgeColor", edgeColor);
            GetMat.SetColor("_bgColor", bgColor);

            Graphics.Blit(source, destination, GetMat);
        }
        else
        {
            Graphics.Blit(source, destination);
        }
    }
}
