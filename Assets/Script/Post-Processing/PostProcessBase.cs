using System.Collections;
using System.Collections.Generic;
using UnityEngine;

[ExecuteInEditMode]
public class PostProcessBase : MonoBehaviour {
    protected Material CheckShaderAndCreateMaterial (Shader shader, Material material) {
        if (shader == null || !shader.isSupported) {
            return null;
        }
        if (material != null && material.shader == shader) {
            return material;
        }
        material = new Material (shader);
        material.hideFlags = HideFlags.DontSave;
        return material;
    }
}