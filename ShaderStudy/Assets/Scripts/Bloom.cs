using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Bloom : PostEffectBase
{
    public Shader mBloom;
    private Material mMat;
    public Material GetMat
    {
        get
        {
            mMat = CheckShaderAndCreateMaterial(mBloom, mMat);
            return mMat;
        }
    }

    [Range(0, 4)]
    public int mIteration = 3;
    [Range(0.0f, 3.0f)]
    public float mBlurSpreed= 0.6f;
    [Range(1, 8)]
    public int downSample=2;
    [Range(0.0f, 4.0f)]
    public float mLuminanceThreshold=1.0f;

    private void OnRenderImage(RenderTexture source, RenderTexture destination)
    {
        if(GetMat !=null)
        {
            GetMat.SetFloat("_LuminanceThreshold", mLuminanceThreshold);
            int tWidth = source.width / downSample;
            int tHeight = source.height / downSample;

            RenderTexture buffer0 = RenderTexture.GetTemporary(tWidth, tHeight, 0);
            buffer0.filterMode = FilterMode.Bilinear;
            Graphics.Blit(source, buffer0, GetMat, 0);

            for(int i=0;i<mIteration;i++)
            {
                GetMat.SetFloat("_BlurSize", 1.0f + i * mBlurSpreed);
                RenderTexture buffer1 = RenderTexture.GetTemporary(tWidth, tHeight, 0);
                Graphics.Blit(buffer0, buffer1, GetMat, 1);
                RenderTexture.ReleaseTemporary(buffer0);
                buffer0 = buffer1;
                buffer1 = RenderTexture.GetTemporary(tWidth, tHeight, 0);
                Graphics.Blit(buffer0, buffer1, GetMat, 2);
                RenderTexture.ReleaseTemporary(buffer0);
                buffer0 = buffer1;
            }

            GetMat.SetTexture("_Bloom", buffer0);
            Graphics.Blit(source, destination, GetMat, 3);
            RenderTexture.ReleaseTemporary(buffer0);
        }
        else
        {
            Graphics.Blit(source, destination);
        }
    }
}
