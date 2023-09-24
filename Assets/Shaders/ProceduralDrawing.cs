using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class ProceduralDrawing : MonoBehaviour
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

    [SerializeField]
    public Material material;

    [SerializeField]
    public Mesh mesh;
    RenderParams rp;

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


        positionBuffer.SetData(data);

        computeShader.SetBuffer(0, "pos", positionBuffer);

        var bounds = new Bounds(Vector3.zero, Vector3.one * 2000f);
        rp = new RenderParams(material);
        rp.worldBounds = bounds;
        rp.matProps = new MaterialPropertyBlock();
        rp.matProps.SetBuffer("_Positions", positionBuffer);
        // computeShader.Dispatch(0, data.Length / 32, data.Length / 32, 1);
    }


    // Update is called once per frame
    private void OnDisable()
    {
        positionBuffer.Dispose();
    }
    void Update()
    {


        computeShader.Dispatch(0, data.Length / 32, data.Length / 32, 1);
        Graphics.RenderMeshPrimitives(rp, mesh, 0, positionBuffer.count);



        
       
        //positionBuffer.GetData(data);
       // print(data[0].Position);
        
        
        
        /*
        positionBuffer.SetData(data);

        computeShader.SetBuffer(0, "pos", positionBuffer);

        computeShader.Dispatch(0, data.Length/32, data.Length / 32,1);

        positionBuffer.GetData(data);

        for (int i = 0; i < Parent.transform.childCount; i++)
        {
            gameObjects[i].transform.position = data[i].Position;
        }

      //  positionBuffer.Dispose();
        */
    }
}
