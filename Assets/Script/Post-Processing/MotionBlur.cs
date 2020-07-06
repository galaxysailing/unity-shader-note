using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class MotionBlur : PostProcessBase {
    public Shader motionBlurShader;

    private Material motionBlurMat;

    public Material material {
        get {
            motionBlurMat = CheckShaderAndCreateMaterial (motionBlurShader, motionBlurMat);
            return motionBlurMat;
        }
    }

    // 模糊参数，拖尾效果
    [Range (0.0f, 0.9f)]
    public float blurAmount = 0.5f;

    // 保存之前图像叠加的结果
    private RenderTexture accumulationTexture;

    void OnDisable () {
        DestroyImmediate (accumulationTexture);
    }

    void OnRenderImage (RenderTexture src, RenderTexture dest) {
        if (material == null) {
            Graphics.Blit (src, dest);
            return;
        }

        if (accumulationTexture == null || accumulationTexture.width != src.width ||
            accumulationTexture.height != src.height) {
            DestroyImmediate (accumulationTexture);
            accumulationTexture = new RenderTexture(src.width, src.height, 0);
            // 不回保存到场景中
            accumulationTexture.hideFlags = HideFlags.HideAndDontSave;
            Graphics.Blit (src, accumulationTexture);
        }

        accumulationTexture.MarkRestoreExpected ();

        material.SetFloat ("_BlurAmount", 1.0f - blurAmount);

        Graphics.Blit (src, accumulationTexture, material);
        Graphics.Blit (accumulationTexture, dest);
    }
}