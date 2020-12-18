
using UnityEditor;
using UnityEngine;
using UnityScript.Lang;

namespace LCAnimationSystem
{
    [CustomEditor(typeof(AnimationTrack))]
    public class AnimationTrackInspectorEditor : Editor
    {
        private AnimationTrack _AnimationTrack { get { return target as AnimationTrack; } }

        public override void OnInspectorGUI()
        {
            EditorGUILayout.LabelField("EventCount: " + _AnimationTrack.animationEventlist.Count);

            for (int i = 0; i < _AnimationTrack.animationEventlist.Count; i++)
            {
                var animEvent = _AnimationTrack.animationEventlist[i];
                GUILayout.Space(2);
                animEvent.eventTime = EditorGUILayout.FloatField("事件触发时间", animEvent.eventTime);
                switch (animEvent.eventType)
                {
                    case AnimationEventType.PlayEffect:
                        DrawPlayEffectEvent((AnimationPlayEffectEvent)animEvent);
                        break;
                    case AnimationEventType.PlaySound:
                        DrawPlaySoundEvent((AnimationPlaySoundEvent)animEvent);
                        break;
                    case AnimationEventType.PlayTrail:
                        DrawPlayTrailEvent((AnimationPlayTrailEvent)animEvent);
                        break;
                    case AnimationEventType.SendMsg:
                        DrawSendMsgEvent((AnimationSendMsgEvent)animEvent);
                        break;
                }
                DrawRemoveBtn(animEvent);
            }

            DrawAddEventBtn();
            DrawUpdateAllEventBtn();
        }

        #region Event
        private void DrawSendMsgEvent(AnimationSendMsgEvent animEvent)
        {
            animEvent.msgType = (AnimationSendMsgType)EditorGUILayout.EnumPopup("SendMsg", animEvent.msgType);

        }

        private void DrawPlayTrailEvent(AnimationPlayTrailEvent animEvent)
        {
            animEvent.trailRenderer = (TrailRenderer)EditorGUILayout.ObjectField("拖尾特效：", animEvent.trailRenderer, typeof(GameObject), true);
            animEvent.trailParent = (Transform)EditorGUILayout.ObjectField("父物体：", animEvent.trailParent, typeof(Transform), true);
            animEvent.trailEndTime = EditorGUILayout.FloatField("拖尾结束时间：", animEvent.trailEndTime);
            animEvent.trailOffestPos = EditorGUILayout.Vector3Field("拖尾生成点：", animEvent.trailOffestPos);
            animEvent.trailRot = EditorGUILayout.Vector3Field("拖尾旋转：", animEvent.trailRot);
        }

        private void DrawPlaySoundEvent(AnimationPlaySoundEvent animEvent)
        {
            animEvent.audioClip = (AudioClip)EditorGUILayout.ObjectField("AudioClip", animEvent.audioClip, typeof(AudioClip), true);

        }

        private void DrawPlayEffectEvent(AnimationPlayEffectEvent animEvent)
        {
            animEvent.effectPrefab = (GameObject)EditorGUILayout.ObjectField("Effect Prefab", animEvent.effectPrefab, typeof(GameObject), true);
            animEvent.effectParent = (Transform)EditorGUILayout.ObjectField("Effect Parent(父节点)", animEvent.effectParent, typeof(Transform), true);
            animEvent.effectPos = EditorGUILayout.Vector3Field("Effect Pos", animEvent.effectPos);
            animEvent.effectRot = EditorGUILayout.Vector3Field("Effect Rot", animEvent.effectRot);
        }
        #endregion

        private void DrawRemoveBtn(AnimationBaseEvent baseEvent)
        {
            if (GUILayout.Button("Remove"))
                _AnimationTrack.animationEventlist.Remove(baseEvent);
        }

        private void DrawUpdateAllEventBtn()
        {
            if (GUILayout.Button("Update All Event", GUILayout.MinHeight(50)))
            {
                AnimationEvent[] animationEvents = new AnimationEvent[_AnimationTrack.animationEventlist.Count];
                for (int i = 0; i < animationEvents.Length; i++)
                {
                    animationEvents[i] = new AnimationEvent();
                    var effect = _AnimationTrack.animationEventlist[i];
                    animationEvents[i].time = effect.eventTime;
                    animationEvents[i].functionName = "ReceiveAnimationEvent";
                    animationEvents[i].objectReferenceParameter = effect;
                }
                AnimationUtility.SetAnimationEvents(_AnimationTrack.animationClip, animationEvents);
            }
        }

        private void DrawAddEventBtn()
        {
            if (GUILayout.Button("Add Event",GUILayout.MinHeight(50)))
            {
                int selectId = 0;
                string[] showString = new string[(int)AnimationEventType.Max-2];
                Array array = System.Enum.GetValues(typeof(AnimationEventType));
                for (int i = 1; i < array.length-1; i++)
                {
                    showString[i - 1] = array[i].ToString();
                }

                GUIContent[] contents = new GUIContent[showString.Length];
                for (int i = 0; i < contents.Length; i++)
                {
                    contents[i] = new GUIContent(showString[i]);
                }

                Rect rect = new Rect(Event.current.mousePosition.x, Event.current.mousePosition.y, 0, 0);
                EditorUtility.DisplayCustomMenu(rect, contents, selectId, AddEventButtonCallBack, null);
            }
        }

        private void AddEventButtonCallBack(object userData, string[] options, int selected)
        {
            selected += 2;
            AnimationEventType eventType = (AnimationEventType)selected;
            AnimationBaseEvent baseEvent = null;
            switch (eventType)
            {
                case AnimationEventType.PlayEffect:
                    baseEvent = CreateInstance<AnimationPlayEffectEvent>();
                    baseEvent.eventType = AnimationEventType.PlayEffect;
                    break;
                case AnimationEventType.PlaySound:
                    baseEvent = CreateInstance<AnimationPlaySoundEvent>();
                    baseEvent.eventType = AnimationEventType.PlaySound;
                    break;
                case AnimationEventType.PlayTrail:
                    baseEvent = CreateInstance<AnimationPlayTrailEvent>();
                    baseEvent.eventType = AnimationEventType.PlayTrail;
                    break;
                case AnimationEventType.SendMsg:
                    baseEvent = CreateInstance<AnimationSendMsgEvent>();
                    baseEvent.eventType = AnimationEventType.SendMsg;
                    break;
            }
            if (baseEvent == null)
                return;
            baseEvent.animationClip = _AnimationTrack.animationClip;
            _AnimationTrack.animationEventlist.Add(baseEvent);
        }
    }
}
