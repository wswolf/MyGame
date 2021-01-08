using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class EdgeWithDepthNormals : PostEffectBase
{
    public Shader mEdgeWithDepthNormalsShader;
    private Material mMat;
    public Material GetMat
    {
        get
        {
            mMat = CheckShaderAndCreateMaterial(mEdgeWithDepthNormalsShader, mMat);
            return mMat;
        }
    }
    private Camera mCamera;
    protected override void Start()
    {
        base.Start();
        mCamera = this.GetComponent<Camera>();
        if(mCamera !=null)
        {
            mCamera.depthTextureMode |= DepthTextureMode.DepthNormals;
        }
    }
    [Range(0.0f,1.0f)]
    public float mEdgeOnly = 0.0f;
    public Color mEdgeColor = Color.black;
    public Color mBgColor = Color.white;
    public float mSampleDistance = 1.0f;
    public float mSensitivityDepth = 1.0f;
    public float mSensitivityNormals = 1.0f;
    private void OnRenderImage(RenderTexture source, RenderTexture destination)
    {
        if(GetMat!=null)
        {
            GetMat.SetFloat("_EdgeOnly", mEdgeOnly);
            GetMat.SetColor("_EdgeColor", mEdgeColor);
            GetMat.SetColor("_BackgroundColor", mBgColor);
            GetMat.SetFloat("_SampleDistance", mSampleDistance);
            GetMat.SetVector("_Sensitivity", new Vector4(mSensitivityNormals, mSensitivityDepth, 0.0f, 0.0f));
            Graphics.Blit(source, destination, GetMat);
        }
        else
        {
            Graphics.Blit(source, destination);
        }
    }
}
