using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Moving : MonoBehaviour
{

    // Start is called before the first frame update
    void Start()
    {

    }

    // Update is called once per frame
    void Update()
    {
        gameObject.transform.position += new Vector3 (0, Mathf.Sin(Time.time*3 + gameObject.transform.position.x + gameObject.transform.position.z)*0.05f, 0);
    }
}
