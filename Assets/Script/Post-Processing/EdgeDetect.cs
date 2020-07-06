using System.Collections;
using UnityEngine;

public class EdgeDetect : PostProcessBase
{
    public Shader shader;

    private Material edgeDetectMat;

    public Material material{
        get {
            this.edgeDetectMat = CheckShaderAndCreateMaterial(shader,edgeDetectMat);
            return this.edgeDetectMat;
        }
    }
    [Range(0.0f, 1.0f)]
    public float edgesOnly = 0.0f;

    public Color edgeColor = Color.black;

    public Color backgroundColor = Color.white;
    void OnRenderImage(RenderTexture src, RenderTexture dest)
    {
        if (material != null)
        {
            material.SetFloat("_EdgeOnly", edgesOnly);
            material.SetColor("_EdgeColor", edgeColor);
            material.SetColor("_BackgroundColor", backgroundColor);
            Graphics.Blit(src, dest, material);
        }
        else
        {
            Graphics.Blit(src, dest);
        }
    }
}
