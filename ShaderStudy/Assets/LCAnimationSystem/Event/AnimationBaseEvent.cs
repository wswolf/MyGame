using UnityEngine;

namespace LCAnimationSystem
{
    public enum AnimationEventType:byte
    {
        None=1,
        PlayEffect,
        PlaySound,
        PlayTrail,
        SendMsg,
        Max,
    }



    public class AnimationBaseEvent : ScriptableObject
    {
        public float eventTime;

        public AnimationEventType eventType = AnimationEventType.None;

        public AnimationClip animationClip;

    } 
}
