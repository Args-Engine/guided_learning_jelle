﻿using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class RayVisualizer : MonoBehaviour
{
    private List<Ray> m_rays;
    public static RayVisualizer instance;
    [SerializeField] int m_rayCount;


    // Start is called before the first frame update
    void Awake()
    {
        m_rays = new List<Ray>();
        if (instance == null) instance = this;
        else Destroy(this.gameObject);
    }

    public void FixedUpdate()
    {
        for (int i = 0; i < m_rays.Count; ++i)
        {
            if (m_rays[i].color.a >= 0)
            {
                Vector2 direction;
                if (m_rays[i].hasBounce())
                {
                    direction = m_rays[i].getBounce().position - m_rays[i].position;
                }
                else direction = m_rays[i].direction * 4;
                Debug.DrawRay(m_rays[i].position, direction, m_rays[i].color);
            }
        }
        m_rayCount = m_rays.Count;
    }

    public void register(Ray ray)
    {
        m_rays.Add(ray);
    }

    public void unRegister(Ray ray)
    {
        m_rays.Remove(ray);
    }

    public void clear()
    {
        m_rays.Clear();
    }
}
