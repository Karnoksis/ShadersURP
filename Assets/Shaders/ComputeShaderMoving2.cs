using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class ComputeShaderMoving2 : MonoBehaviour
{
    public ComputeShader computeShader;
    public struct Pos
    {
        public Vector3 Position;
    }

    public Pos[] data;
    Transform[] gameObjects;
    public GameObject Parent;
    ComputeBuffer positionBuffer;

    // Start is called before the first frame update
    void Start()
    {
        data = new Pos[Parent.transform.childCount];

        gameObjects = Parent.GetComponentsInChildren<Transform>();

        for (int i = 0; i < Parent.transform.childCount; i++)
        {
            data[i].Position = gameObjects[i].transform.position;
        }

         positionBuffer = new ComputeBuffer(data.Length, sizeof(float) * 3);

    }

    // Update is called once per frame
    void Update()
    {

        positionBuffer.SetData(data);

        computeShader.SetBuffer(0, "pos", positionBuffer);

        computeShader.Dispatch(0, data.Length/32, data.Length / 32,1);

        positionBuffer.GetData(data);

        for (int i = 0; i < Parent.transform.childCount; i++)
        {
            gameObjects[i].transform.position = data[i].Position;
        }

      //  positionBuffer.Dispose();

    }
}
