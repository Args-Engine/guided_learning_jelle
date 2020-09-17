﻿using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEditor;

public class RayCircleCollider : RayCollider
{
    [SerializeField] private float m_radius;
    [SerializeField] private readonly Vector2 m_offset;
    private Sprite m_sprite;
    private List<Ray> m_rays;

    public void Start()
    {
        RayTracer.register(this);
        m_sprite = this.GetComponent<SpriteRenderer>().sprite;
    }

    public override bool collide(Ray ray, out RayHit hit)
    {
        if (ray.origin == this)
        {
            hit = null;
            return false;
        }
        Vector2 pos = center;
        Vector2 dist = pos - ray.position; // Distance between ray start and circle center

        float centerToRay = Vector2.Dot(dist, ray.normal.normalized);

        if (Mathf.Abs(centerToRay) > m_radius)
        {
            hit = null;
            return false;
        }

        Vector2 closestRayPoint = ray.position + ray.direction * Vector2.Dot(dist, ray.direction.normalized);
        float closestRayPointToPoi = Mathf.Sqrt(Mathf.Pow(m_radius, 2) - Mathf.Pow(centerToRay, 2));

        Vector2 poi = closestRayPoint - (closestRayPointToPoi * ray.direction.normalized);
        Vector2 rayToPoi = poi - ray.position;
        if (rayToPoi.normalized != ray.direction)
        {
            hit = null;
            return false;
        }
        Vector2 normal = (poi - center).normalized;
        Vector2 pixel = textureSpaceCoord(poi);
        hit = new RayHit(ray, poi, normal, this, m_sprite.texture.GetPixel((int)pixel.x, (int)pixel.y));
        return true;
    }

    public override bool pointOnSurface(Vector2 point)
    {
        return (point - center).magnitude <= m_radius;
    }

    private Vector2 textureSpaceUV(Vector2 worldPos)
    {
        Texture2D tex = m_sprite.texture;
        Vector2 texSpaceCoord = textureSpaceCoord(worldPos);

        Vector2 uvs = texSpaceCoord;
        uvs.x /= tex.width;
        uvs.y /= tex.height;

        return uvs;
    }

    private Vector2 textureSpaceCoord(Vector2 worldPos)
    {
        float ppu = m_sprite.pixelsPerUnit;

        Vector2 localPos = transform.InverseTransformPoint(worldPos) * ppu;

        Vector2 texSpacePivot = new Vector2(m_sprite.rect.x, m_sprite.rect.y) + m_sprite.pivot;
        Vector2 texSpaceCoord = texSpacePivot + localPos;

        return texSpaceCoord;
    }

    public override Ray addRay(Vector2 position)
    {
        Vector2 direction = (position - center).normalized;
        Ray ray = Ray.create(position, direction, this);
        return ray;
    }

    public Vector2 center
    {
        get
        {
            return new Vector2(this.transform.position.x, this.transform.position.y) + m_offset;
        }
    }

    public float radius
    {
        get
        {
            return m_radius;
        }
    }
}

[CustomEditor(typeof(RayCircleCollider))]
public class RayCircleColliderEditor : Editor
{
    private RayCircleCollider m_collider;

    public void OnSceneGUI()
    {
        m_collider = this.target as RayCircleCollider;
        Handles.color = Color.red;
        Handles.DrawWireDisc(m_collider.center, Vector3.forward, m_collider.radius);
    }
}