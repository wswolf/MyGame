using UnityEngine;

namespace LCAnimationSystem
{
    public enum AnimationSendMsgType:byte
    {
        MakeDamage,
    }

    public class AnimationSendMsgEvent : AnimationBaseEvent
    {
        public AnimationSendMsgType msgType;
    }
}
