using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class MotionBlurWithDepth : PostEffectBase
{
    public Shader mMotionBlurWithDepthShader;
    private Material mMat;
    public Material GetMat { get
        {
            mMat = CheckShaderAndCreateMaterial(mMotionBlurWithDepthShader, mMat);
            return mMat;
        } }
    private Camera GetCamera { get
        {
            return this.GetComponent<Camera>();
        } }
    [Range(0.0f,3.0f)]
    public float mBlurSize;

    private Matrix4x4 preVPMarix;

    protected override void OnEnable()
    {
        base.OnEnable();
        GetCamera.depthTextureMode |= DepthTextureMode.Depth;
        preVPMarix = GetCamera.projectionMatrix * GetCamera.worldToCameraMatrix;
    }

    private void OnRenderImage(RenderTexture source, RenderTexture destination)
    {
        if(GetMat!=null)
        {
            GetMat.SetFloat("_BlurSize", mBlurSize);
            GetMat.SetMatrix("_PreVPMarix", preVPMarix);
            Matrix4x4 currentVPMarix = GetCamera.projectionMatrix * GetCamera.worldToCameraMatrix;
            Matrix4x4 currentVPMarixInverse = currentVPMarix.inverse;
            GetMat.SetMatrix("_CurVPMarixInverse", currentVPMarixInverse);
            preVPMarix = currentVPMarix;

            Graphics.Blit(source, destination, GetMat);
        }
        else
        {
            Graphics.Blit(source, destination);
        }
    }
}
