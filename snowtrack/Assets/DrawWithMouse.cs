using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class DrawWithMouse : MonoBehaviour
{
    public Camera camera;
    public Shader snowDepthShader;
    [Range(1, 500)]
    public float brushSize = 250.0f;
    [Range(0, 1)]
    public float brushStrength = 0.5f;

    private RenderTexture snowDepthTex;
    private Material snowDepthMaterial;
    private RaycastHit hit;

    void Start()
    {
        snowDepthMaterial = new Material(snowDepthShader);

        Material snowMaterial = GetComponent<MeshRenderer>().material;
        snowDepthTex = new RenderTexture(1024, 1024, 0, RenderTextureFormat.ARGBFloat);
        snowMaterial.SetTexture("_SnowDepthTex", snowDepthTex);
    }

    void Update()
    {
        if (Input.GetKey(KeyCode.Mouse0) && Physics.Raycast(camera.ScreenPointToRay(Input.mousePosition), out hit))
        {
            snowDepthMaterial.SetVector("_Coordinate", new Vector4(hit.textureCoord.x, hit.textureCoord.y, 0, 0));
            snowDepthMaterial.SetFloat("_Strength", brushStrength);
            snowDepthMaterial.SetFloat("_Size", brushSize);
            RenderTexture temp = RenderTexture.GetTemporary(snowDepthTex.width, snowDepthTex.height, 0, RenderTextureFormat.ARGBFloat);
            Graphics.Blit(snowDepthTex, temp);
            Graphics.Blit(temp, snowDepthTex, snowDepthMaterial);
            RenderTexture.ReleaseTemporary(temp);
        }
    }

    private void OnGUI()
    {

        GUI.DrawTexture(new Rect(0, 0, 256, 256), snowDepthTex, ScaleMode.ScaleToFit, false, 1);
    }
}
