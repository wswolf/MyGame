using System;
using UnityEditor;
using UnityEngine;

namespace LCAnimationSystem
{
    public class AnimationEventSystemEditorWindow:EditorWindow
    {
        public AnimationEventSystem animSystem;

        private bool init = false;
        private Vector2 animClipsListViewScroll = Vector2.zero;
        private Vector2 animEventListViewScroll = Vector2.zero;
        private AnimationTrack selectTrack = null;
        private Editor gameObjectEditor;

        public float _animTime { get; set; }

        public static void OpenWindow(AnimationEventSystem animEventSystem)
        {
            AnimationEventSystemEditorWindow window = GetWindow<AnimationEventSystemEditorWindow>(true, "LC动画事件编辑器", true);
            window.minSize = new Vector2(1000f, 600f);
            window.animSystem = animEventSystem;
            window.animSystem.animator = animEventSystem.GetComponent<Animator>();
        }

        private void InitSystem()
        {
            if (animSystem == null)
                return;
            if (init)
                return;
            if (animSystem.animator.runtimeAnimatorController.animationClips.Length > animSystem.tracklist.Count)
                animSystem.AddTrack();
            else if (animSystem.animator.runtimeAnimatorController.animationClips.Length < animSystem.tracklist.Count)
                animSystem.RemoveTrack();

            gameObjectEditor = Editor.CreateEditor(animSystem.gameObject);
            init = true;
        }

        private void Update()
        {
            if (selectTrack != null && selectTrack.animationClip != null)
                selectTrack.animationClip.SampleAnimation((GameObject)gameObjectEditor.target, _animTime);
        }

        private void OnGUI()
        {
            InitSystem();
            if (animSystem == null)
                return;
            EditorGUILayout.BeginHorizontal(GUILayout.Width(position.width), GUILayout.Height(position.height));
            {
                GUILayout.Space(2f);

                //动画片段
                EditorGUILayout.BeginVertical(GUILayout.Width(position.width * 0.25f));
                {
                    GUILayout.Space(5f);
                    EditorGUILayout.LabelField(string.Format("动画片段列表"), EditorStyles.boldLabel);
                    EditorGUILayout.BeginHorizontal("box", GUILayout.Height(position.height - 52f));
                    {
                        DrawAnimationClips();
                    }
                    EditorGUILayout.EndHorizontal();

                }
                EditorGUILayout.EndVertical();

                //动画事件
                EditorGUILayout.BeginVertical(GUILayout.Width(position.width * 0.3f));
                {
                    GUILayout.Space(5f);
                    EditorGUILayout.LabelField(string.Format("动画名 （{0}）",selectTrack==null?"":selectTrack.animationClip.name), EditorStyles.boldLabel);
                    EditorGUILayout.BeginHorizontal("box", GUILayout.Height(position.height - 52f));
                    {
                        DrawAnimationEvent();
                    }
                    EditorGUILayout.EndHorizontal();

                }
                EditorGUILayout.EndVertical();

                //模型
                EditorGUILayout.BeginVertical(GUILayout.Width(position.width * 0.5f-16f));
                {
                    GUILayout.Space(5f);
                    EditorGUILayout.LabelField(string.Format("模型预览"), EditorStyles.boldLabel);
                    EditorGUILayout.BeginHorizontal("box", GUILayout.Height(position.height - 52f));
                    {
                        DrawGameObjectAnim();
                    }
                    EditorGUILayout.EndHorizontal();

                }
                EditorGUILayout.EndVertical();
                GUILayout.Space(5f);

            }
            EditorGUILayout.EndHorizontal();
        }

        private void DrawGameObjectAnim()
        {
            if (animSystem == null)
                return;
            if (gameObjectEditor != null)
                gameObjectEditor.DrawPreview(GUILayoutUtility.GetRect(500, 500));
        }

        private void DrawAnimationEvent()
        {
            if (selectTrack == null)
                return;
            animEventListViewScroll = EditorGUILayout.BeginScrollView(animEventListViewScroll);
            {
                EditorGUILayout.ObjectField("AnimationClip: ", selectTrack.animationClip, typeof(AnimationClip), true);
                _animTime = EditorGUILayout.Slider("播放动画", _animTime, 0, selectTrack.animationClip.length);
                Editor edt = Editor.CreateEditor(selectTrack);
                //AnimationTrackInspectorEditor animationTrack=(AnimationTrackInspectorEditor)edt;
                edt.OnInspectorGUI();
            }
            EditorGUILayout.EndScrollView();
        }

        private void DrawAnimationClips()
        {
            animClipsListViewScroll = EditorGUILayout.BeginScrollView(animClipsListViewScroll);
            {
                foreach (AnimationTrack item in animSystem.tracklist)
                {
                    EditorGUILayout.BeginHorizontal();
                    {
                        if (GUILayout.Button(item.animationClip.name))
                        {
                            selectTrack = item;
                        }
                    }
                    EditorGUILayout.EndHorizontal();
                }
            }
            EditorGUILayout.EndScrollView();
        }
    }
}
