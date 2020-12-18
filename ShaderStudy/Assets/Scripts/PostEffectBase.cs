using System.Collections;
using System.Collections.Generic;
using UnityEngine;

[ExecuteInEditMode]
[RequireComponent(typeof(Camera))]
public class PostEffectBase : BaseBehaviour
{
    protected override void Start()
    {
        base.Start();
    }
    protected Material CheckShaderAndCreateMaterial(Shader _shader,Material _mat)
    {
        if (_shader == null || !_shader.isSupported)
            return null;
        if (_mat && _mat.shader == _shader)
            return _mat;
        _mat = new Material(_shader)
        {
            hideFlags = HideFlags.DontSave
        };
        if (_mat)
            return _mat;
        else
            return null;
    }
}
