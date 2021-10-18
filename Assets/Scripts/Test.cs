using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Test : MonoBehaviour
{
    // Start is called before the first frame update
    void Start()
    {
        Mesh mf = GetComponent<MeshFilter>().mesh;

        for (int i = 0; i < mf.uv.Length; i++)
        {
            Debug.Log("uv:" + i + " " + mf.uv[i]);
        }

        for (int i = 0; i < mf.vertexCount; i++)
        {
            Debug.Log("vertex:" + i + " " + mf.vertices[i]);
        }

      
    }

    // Update is called once per frame
    void Update()
    {
        
    }
}
