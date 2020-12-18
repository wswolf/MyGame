using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class MotionBlur : PostEffectBase
{
    public Shader mMotionShader;
    private Material mMat;
    public Material GetMat
    {
        get
        {
            mMat = CheckShaderAndCreateMaterial(mMotionShader, mMat);
            return mMat;
        }
    }

    [Range(0.0f, 1.0f)]
    public float mBlurAmount;

    private RenderTexture accumulationTexture;

    private void OnRenderImage(RenderTexture source, RenderTexture destination)
    {
        if(GetMat!=null)
        {
            if(accumulationTexture==null 
                || accumulationTexture.width != source.width 
                || accumulationTexture.height != source.height)
            {
                DestroyImmediate(accumulationTexture);
                accumulationTexture = new RenderTexture(source.width, source.height, 0)
                {
                    hideFlags = HideFlags.HideAndDontSave
                };
                Graphics.Blit(source, accumulationTexture);
            }

            accumulationTexture.MarkRestoreExpected();
            GetMat.SetFloat("_BlurAmount", mBlurAmount);
            Graphics.Blit(source, accumulationTexture, GetMat);
            Graphics.Blit(accumulationTexture, destination);
        }
        else
        {
            Graphics.Blit(source, destination);
        }
    }

    protected override void OnDisable()
    {
        base.OnDisable();
        if (accumulationTexture != null)
        {
            DestroyImmediate(accumulationTexture);
        }
    }
}
