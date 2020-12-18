//------------------------
//调整屏幕亮度，饱和度，对比度
//饱和度 l=r*0.2125 + g*0.7154+b*0.0721
//      col = Color(l,l,l)
//------------------------
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class BrightnessSaturationAndContrast : PostEffectBase
{
    [SerializeField]
    private Shader briSatConShader;
    private Material briSatConMat;
    public Material GetMat
    {
        get
        {
            briSatConMat = CheckShaderAndCreateMaterial(briSatConShader, briSatConMat);
            return briSatConMat;
        }
    }

    [Range(0.0f,3.0f)]
    public float mBrightness;
    [Range(0.0f, 3.0f)]
    public float mSaturation;
    [Range(0.0f, 3.0f)]
    public float mContrats;

    private void OnRenderImage(RenderTexture source, RenderTexture destination)
    {
        if(GetMat!=null)
        {
            GetMat.SetFloat("_Brightness", mBrightness);
            GetMat.SetFloat("_Saturation", mSaturation);
            GetMat.SetFloat("_Contrast", mContrats);
            Graphics.Blit(source, destination, GetMat);
        }
        else
        {
            Graphics.Blit(source, destination);
        }
    }
}
