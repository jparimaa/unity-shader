using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class ComputeLauncher : MonoBehaviour
{
    public int SphereAmount = 64;
    public ComputeShader Shader;
    public Transform spawnObject;

    ComputeBuffer resultBuffer;
    int kernel;
    uint threadGroupSize;
    Vector3[] output;
    Transform[] instances;

    void Start()
    {
        kernel = Shader.FindKernel("SphereCS");
        Shader.GetKernelThreadGroupSizes(kernel, out threadGroupSize, out _, out _);
        resultBuffer = new ComputeBuffer(SphereAmount, sizeof(float) * 3);
        output = new Vector3[SphereAmount];

        instances = new Transform[SphereAmount];
        for (int i = 0; i < SphereAmount; ++i)
        {
            var obj = Instantiate(spawnObject);
            instances[i] = obj.transform;
        }
    }

    void Update()
    {
        Shader.SetBuffer(kernel, "Result", resultBuffer);
        Shader.SetFloat("Time", Time.time);
        int threadGroups = 1 + (int)(SphereAmount / (threadGroupSize + 1));
        Shader.Dispatch(kernel, threadGroups, 1, 1);
        resultBuffer.GetData(output);

        for (int i = 0; i < SphereAmount; ++i)
        {
            instances[i].localPosition = output[i];
        }
    }

    void OnDestroy()
    {
        resultBuffer.Release();
    }
}
