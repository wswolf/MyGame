using UnityEngine;

namespace LCAnimationSystem
{
    public class AnimationPlayEffectEvent:AnimationBaseEvent
    {
        public GameObject effectPrefab;

        public Transform effectParent;

        public Vector3 effectPos = Vector3.zero;

        public Vector3 effectRot = Vector3.zero;
    }
}
