public class Ray
{
  public Ray(PVector start, PVector dir, int maxBounces)
  {
    this.m_start = start;
    this.m_direction = dir.normalize();

    m_normal = new PVector(-dir.y, dir.x);
    m_normal.normalize();

    m_hit = null;
    m_lineSegments = new ArrayList<LineSegment>();
    m_maxBounces = maxBounces;

    m_color = new Color(1, 1, 1);
  }

  public void set(PVector start, PVector dir)
  {
    this.m_start = start;
    this.m_direction = dir;

    m_normal = new PVector(-dir.y, dir.x);
    m_normal.normalize();
  }

  public void setMaxBounces(int bounces)
  {
    m_maxBounces = bounces;
  }

  public void setColor(Color cl)
  {
    m_color = cl;
  }
  
  public Color getColor()
  {
    return m_color;
  }

  public void render()
  {
    render(1000);
  }

  public void renderBounces(int renderLength)
  {
    if(m_hit != null)
    {
      m_hit.reflect.render(renderLength);
    }
  }
  
  public ArrayList<RayHit> getLastHit()
  {
    if(m_lastHit == null) return null;
    ArrayList<RayHit> hits = new ArrayList<RayHit>();
    hits.add(m_lastHit);
    ArrayList<RayHit> reflectHits = m_lastHit.reflect.getLastHit();
    if(reflectHits != null)
    {
      for(int i = 0; i < reflectHits.size(); ++i)
      {
        hits.add(reflectHits.get(i));
      }
    }
    return hits;
  }

  public void render(int renderLength)
  {
    if(m_hit != null) m_hit.reflect.render(renderLength);

    stroke(m_color.get());

    if (m_hasEnd) line(m_start.x, m_start.y, m_end.x, m_end.y);
    else line(m_start.x, m_start.y, m_start.x+m_direction.x*renderLength, m_start.y+m_direction.y*renderLength);
    m_hasEnd = false;
  }

  public void renderNormal()
  {
    line(m_start.x, m_start.y, m_start.x + vscale(m_normal, 10).x, m_start.y + vscale(m_normal, 10).y);
  }

  public void addLineSegmentCollider(LineSegment line)
  {
    m_lineSegments.add(line);
  }

  public PVector collideWith(LineSegment other)
  {    
    PVector startToStart = vsub(other.start(), m_start);

    PVector lineOther = other.getLine();
    float cross = vcross(m_direction, lineOther);

    // Time of impact on this
    // Should be higher than 0
    float u = vcross(startToStart, lineOther) / cross;
    // Time of impact on 'other'
    // Should be between 0-1
    float t = vcross(startToStart, m_direction) / cross;

    if (t > 0 && t < 1 && u > 0)
    {
      PVector poi = vadd(m_start, vscale(m_direction, u));
      return poi;
    }
    return null;
  }

  public void update()
  {
    m_hit = null;
    m_hasEnd = false;

    LineSegment closest = null;
    PVector closestPoi = null;
    for (int i = 0; i < m_lineSegments.size(); ++i)
    {
      PVector poi = collideWith(m_lineSegments.get(i));
      if (poi == null) continue;
      if (m_hasEnd && vlength(vsub(poi, m_start)) >= vlength(vsub(m_end, m_start))) continue;

      m_hasEnd = true;
      m_end = poi;
      closest = m_lineSegments.get(i);
      closestPoi = poi;
    }
    
    if(closest == null)
    {
      m_lastHit = null;
      return;
    }
    
    if(m_hasEnd)
    {
      Color mixColor = m_color.clone().mult(closest.getColor());
      fill(mixColor.get());
      noStroke();
      //ellipse(closestPoi.x, closestPoi.y, 10, 10);
      if (m_maxBounces > 0)
      {
        PVector bounceDir = vreflect( m_direction, closest.getNormal() );
        Ray bounce = new Ray( vadd(closestPoi, vscale(bounceDir, 5)), bounceDir, m_maxBounces-1);
        bounce.setColor(mixColor);
        RayHit hit = new RayHit(bounce, closestPoi, closest.getNormal(), m_color);
        m_hit = hit;
        m_lastHit = m_hit;

        for (int i = 0; i < m_lineSegments.size(); ++i)
        {
          bounce.addLineSegmentCollider(m_lineSegments.get(i));
        }
        bounce.update();
      }
    }
  }

  public PVector start()
  {
    return new PVector(m_start.x, m_start.y);
  }

  public PVector dir()
  {
    return new PVector(m_direction.x, m_direction.y);
  }

  public PVector normal()
  {
    return new PVector(m_normal.x, m_normal.y);
  }

  private PVector m_start;
  private PVector m_direction;
  private PVector m_end;
  private boolean m_hasEnd = false;
  private PVector m_normal;
  private int m_maxBounces;
  private Color m_color;

  private RayHit m_hit;
  private RayHit m_lastHit;
  private ArrayList<LineSegment> m_lineSegments;
}
