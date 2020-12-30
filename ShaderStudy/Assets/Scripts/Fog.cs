using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Fog : PostEffectBase
{
    public Shader mFogWithDepthTexture;
    private Material mMat;
    public Material GetMat
    {
        get
        {
            mMat = CheckShaderAndCreateMaterial(mFogWithDepthTexture, mMat);
            return mMat;
        }
    }

    private Camera mCamera;
    public Camera GetCamera
    {
        get
        {
            if (mCamera == null)
            {
                mCamera = this.GetComponent<Camera>();
            }
            return mCamera;
        }
    }

    [Range(0.0f,3.0f)]
    public float fogDensity = 1.0f;
    [ColorUsage(false)]
    public Color mFogColor = Color.white;

    public float mFogStart = 0.0f;
    public float mFogEnd = 2.0f;

    protected override void OnEnable()
    {
        base.OnEnable();
        GetCamera.depthTextureMode |= DepthTextureMode.Depth;
    }
    private void OnRenderImage(RenderTexture source, RenderTexture destination)
    {
        if(GetMat!=null)
        {
            float halfHeight = GetCamera.nearClipPlane * Mathf.Tan(GetCamera.fieldOfView * 0.5f * Mathf.Deg2Rad);
            Vector3 toTop = GetCamera.transform.up * halfHeight;
            Vector3 toRight = GetCamera.transform.right * halfHeight * GetCamera.aspect;
            Vector3 tlRay = GetCamera.transform.forward*GetCamera.nearClipPlane + toTop - toRight;
            float scale = tlRay.magnitude / GetCamera.nearClipPlane;
            tlRay = tlRay.normalized * scale;
            Vector3 trRay = GetCamera.transform.forward * GetCamera.nearClipPlane + toTop + toRight;
            trRay = tlRay.normalized * scale;
            Vector3 dlRay = GetCamera.transform.forward * GetCamera.nearClipPlane - toTop - toRight;
            dlRay = dlRay.normalized * scale;
            Vector3 drRay = GetCamera.transform.forward * GetCamera.nearClipPlane - toTop + toRight;
            drRay = drRay.normalized * scale;

            Matrix4x4 frustumCorners = Matrix4x4.identity;
            frustumCorners.SetRow(0, tlRay);
            frustumCorners.SetRow(1, trRay);
            frustumCorners.SetRow(2, drRay);
            frustumCorners.SetRow(3, dlRay);

            GetMat.SetFloat("_FogDensity", fogDensity);
            GetMat.SetColor("_FogColor", mFogColor);
            GetMat.SetFloat("_FogStart", mFogStart);
            GetMat.SetFloat("_FogEnd", mFogEnd);
            GetMat.SetMatrix("_FrustumCornersRay", frustumCorners);

            Graphics.Blit(source, destination, GetMat);
        }
        else
        {
            Graphics.Blit(source, destination);
        }
    }
}
