using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class GaussianBlue : PostEffectBase
{
    public Shader mGaussianShader;
    private Material mMat;
    public Material GetMat
    {
        get
        {
            mMat = CheckShaderAndCreateMaterial(mGaussianShader, mMat);
            return mMat;
        }
    }

    [Range(0,4)]
    public int mItration = 3;
    [Range(0.0f, 100.0f)]
    public float blurSpreed=1.0f;
    [Range(1,8)]
    public int downSample=1;

    private void OnRenderImage(RenderTexture source, RenderTexture destination)
    {
        if(GetMat!=null)
        {
            int tWidth = source.width/downSample;
            int tHeight = source.height/downSample;
            RenderTexture tRT0 = RenderTexture.GetTemporary(tWidth, tHeight, 0);
            tRT0.filterMode = FilterMode.Bilinear;
            Graphics.Blit(source, tRT0);
            for (int i = 0; i < mItration; i++)
            {
                GetMat.SetFloat("_BlurSize", 1.0f + i*blurSpreed);
                RenderTexture RT1 = RenderTexture.GetTemporary(tWidth, tHeight, 0);
                Graphics.Blit(tRT0, RT1, GetMat, 0);
                RenderTexture.ReleaseTemporary(tRT0);
                tRT0 = RT1;
                RT1 = RenderTexture.GetTemporary(tWidth, tHeight, 0);
                Graphics.Blit(tRT0, RT1, GetMat, 1);
                RenderTexture.ReleaseTemporary(tRT0);
                tRT0 = RT1;
            }
            Graphics.Blit(tRT0, destination);
            RenderTexture.ReleaseTemporary(tRT0);
        }
        else
        {
            Debug.Log("Material is null");
            Graphics.Blit(source, destination);
        }
    }
}
