using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class SnowDepthCamera : MonoBehaviour
{
    public Shader snowDepthShader;
    public Shader snowDepthBlit;
    public Shader blur;
    public RenderTexture snowDepthTex;
    public RenderTexture snowDepthTexFinal;

    private RenderTexture snowDepthTexTemp;
    private Material snowDepthBlitMaterial;
    private Material blurMaterial;

    void Start()
    {
        GetComponent<Camera>().SetReplacementShader(snowDepthShader, "");
        snowDepthBlitMaterial = new Material(snowDepthBlit);
        blurMaterial = new Material(blur);
    }

    private void Update()
    {
        RenderTexture blurred = RenderTexture.GetTemporary(snowDepthTex.width, snowDepthTex.height, 0, RenderTextureFormat.ARGBFloat);
        blurMaterial.SetTexture("_MainDepth", snowDepthTex);
        Graphics.Blit(snowDepthTex, blurred, blurMaterial);

        RenderTexture temp = RenderTexture.GetTemporary(snowDepthTex.width, snowDepthTex.height, 0, RenderTextureFormat.ARGBFloat);
        snowDepthBlitMaterial.SetTexture("_NewDepth", blurred);
        snowDepthBlitMaterial.SetTexture("_OldDepth", snowDepthTexFinal);
        Graphics.Blit(blurred, temp, snowDepthBlitMaterial);

        Graphics.Blit(temp, snowDepthTexFinal);

        RenderTexture.ReleaseTemporary(temp);
        RenderTexture.ReleaseTemporary(blurred);
    }

    private void OnGUI()
    {
        GUI.DrawTexture(new Rect(0, 0, 256, 256), snowDepthTexFinal, ScaleMode.ScaleToFit, false, 1);
    }

    void OnApplicationQuit()
    {
        snowDepthTexFinal.Release();
    }
}
