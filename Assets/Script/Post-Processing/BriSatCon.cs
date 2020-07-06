using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class BriSatCon : PostProcessBase
{
    public Shader shader;

    private Material briSatConMaterial;

    public Material material
    {
        get
        {
            this.briSatConMaterial = CheckShaderAndCreateMaterial(shader, briSatConMaterial);
            return briSatConMaterial;
        }
    }

    [Range(0.0f, 3.0f)]
    public float brightness = 1.0f;

    [Range(0.0f, 3.0f)]
    public float saturation = 1.0f;

    [Range(0.0f, 3.0f)]
    public float contrast = 1.0f;

    void OnRenderImage(RenderTexture src, RenderTexture dest)
    {
        // 如果material为null 直接退出
        if (material == null)
        {
            Graphics.Blit(src, dest);
            return;
        }

        material.SetFloat("_Brightness", brightness);
        material.SetFloat("_Saturation", saturation);
        material.SetFloat("_Contrast", contrast);
        Graphics.Blit(src, dest, material);
    }
}
