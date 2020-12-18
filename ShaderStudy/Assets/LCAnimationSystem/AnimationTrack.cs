using System.Collections.Generic;
using UnityEngine;

namespace LCAnimationSystem
{
    public class AnimationTrack : ScriptableObject
    {

        public AnimationClip animationClip;

        public List<AnimationBaseEvent> animationEventlist=new List<AnimationBaseEvent>();

    } 
}
