using UnityEngine;

namespace LCAnimationSystem
{
    public class AnimationPlayTrailEvent : AnimationBaseEvent
    {
        public float trailEndTime;

        public TrailRenderer trailRenderer;

        public Transform trailParent;

        public Vector3 trailOffestPos = Vector3.zero;

        public Vector3 trailRot = Vector3.zero;
    }
}
