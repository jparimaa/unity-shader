using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Glitcher : MonoBehaviour
{
    public float glitchChance = 0.1f;
    private Renderer rendererComp;
    private WaitForSeconds glitchLoopWait = new WaitForSeconds(0.1f);
    private WaitForSeconds glitchDuration = new WaitForSeconds(0.1f);
    private void Awake()
    {
        rendererComp = GetComponent<Renderer>();
    }

    IEnumerator Start()
    {
        while (true)
        {
            float glitchValue = Random.Range(0.0f, 1.0f);
            if (glitchValue < glitchChance)
            {
                StartCoroutine(Glitch());
            }
            yield return glitchLoopWait;
        }
    }

    IEnumerator Glitch()
    {
        glitchDuration = new WaitForSeconds(Random.Range(0.05f, 0.25f));
        rendererComp.material.SetFloat("_Amount", 1.0f);
        rendererComp.material.SetFloat("_CutoutThresh", 0.6f);
        rendererComp.material.SetFloat("_Amplitude", Random.Range(100, 250));
        rendererComp.material.SetFloat("_Speed", Random.Range(1, 10));
        yield return glitchDuration;
        rendererComp.material.SetFloat("_Amount", 0.0f);
        rendererComp.material.SetFloat("_CutoutThresh", 0.0f);
    }
}
