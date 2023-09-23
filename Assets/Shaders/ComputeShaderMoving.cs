using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class ComputeShaderMoving : MonoBehaviour
{
    public ComputeShader computeShader;
    public struct Pos
    {
        public Vector3 Position;

    }

    public Pos[] data;

    // Start is called before the first frame update
    void Start()
    {

    }

    // Update is called once per frame
    void Update()
    {
        data = new Pos[1];
        data[0].Position = gameObject.transform.position;
        print(data.Length);
        ComputeBuffer positionBuffer = new ComputeBuffer(data.Length, sizeof(float) * 3);
        positionBuffer.SetData(data);

        computeShader.SetBuffer(0, "pos", positionBuffer);

        computeShader.Dispatch(0, 1,1, 1);

        positionBuffer.GetData(data);

        gameObject.transform.position = data[0].Position;

        positionBuffer.Dispose();

    }
}
