using UnityEngine;
using System.Collections.Generic;

namespace LCAnimationSystem
{
    public class AnimationEventSystem : MonoBehaviour
    {
        [SerializeField,Header("播放声音组件")]
        private AudioSource audioSource;

        [HideInInspector]
        public Animator animator;

        public List<AnimationTrack> tracklist = new List<AnimationTrack>();

        public void AddTrack()
        {
            for (int i = 0; i < animator.runtimeAnimatorController.animationClips.Length; i++)
            {
                var animationClip = animator.runtimeAnimatorController.animationClips[i];
                if(!IsContainAnimationClip(animationClip))
                {
                    var animationTrack = ScriptableObject.CreateInstance<AnimationTrack>();
                    animationTrack.animationClip = animationClip;
                    tracklist.Add(animationTrack);
                }
            }
        }

        public bool IsContainAnimationClip(AnimationClip clip)
        {
            for (int i = 0; i < tracklist.Count; i++)
            {
                if (tracklist[i].animationClip == clip)
                    return true;
            }
            return false;
        }

        public void RemoveTrack()
        {
            for (int i = 0; i < tracklist.Count; i++)
            {
                var animationClip = tracklist[i].animationClip;
                bool isContain = false;
                for (int j = 0; j < animator.runtimeAnimatorController.animationClips.Length; j++)
                {
                    if (animator.runtimeAnimatorController.animationClips[i]==animationClip)
                    {
                        isContain = true;
                        break;
                    }
                }
                if (!isContain)
                {
                    tracklist.RemoveAt(i);
                }
            }
        }


        #region ReceiveEvent

        public void ReceiveAnimationEvent(Object eventObj)
        {
            AnimationBaseEvent animEvent = eventObj as AnimationBaseEvent;
            switch (animEvent.eventType)
            {
                case AnimationEventType.PlayEffect:
                    OnPlayEffect((AnimationPlayEffectEvent)animEvent);
                    break;
                case AnimationEventType.PlaySound:
                    OnPlaySound((AnimationPlaySoundEvent)animEvent);
                    break;
                case AnimationEventType.PlayTrail:
                    OnPlayTrail((AnimationPlayTrailEvent)animEvent);
                    break;
                case AnimationEventType.SendMsg:
                    OnSendMsg((AnimationSendMsgEvent)animEvent);
                    break;
            }
        }

        private void OnPlayEffect(AnimationPlayEffectEvent effectEvent)
        {
            GameObject effectObject = GameObject.Instantiate(effectEvent.effectPrefab, effectEvent.effectParent);
            effectObject.transform.localPosition = effectEvent.effectPos;
            effectObject.transform.localRotation = Quaternion.Euler(effectEvent.effectRot);
        }

        private void OnPlaySound(AnimationPlaySoundEvent soundEvent)
        {
            if (audioSource == null)
                audioSource = GetComponent<AudioSource>();
            if (audioSource == null)
                return;
            audioSource.PlayOneShot(soundEvent.audioClip);
        }

        private void OnPlayTrail(AnimationPlayTrailEvent trailEvent)
        {
            TrailRenderer trailRenderer = GameObject.Instantiate<TrailRenderer>(trailEvent.trailRenderer, trailEvent.trailParent);
            trailRenderer.transform.localPosition = trailEvent.trailOffestPos;
            trailRenderer.transform.localRotation = Quaternion.Euler(trailEvent.trailRot);
            trailRenderer.time = Mathf.Abs(trailEvent.eventTime - trailEvent.trailEndTime);
        }

        private void OnSendMsg(AnimationSendMsgEvent msgEvent)
        {
            switch (msgEvent.msgType)
            {
                case AnimationSendMsgType.MakeDamage:
                    Debug.Log("伤害");
                    break;
            }
        }

        #endregion
    } 
}
