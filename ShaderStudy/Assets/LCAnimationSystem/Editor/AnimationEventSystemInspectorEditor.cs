using UnityEditor;
using UnityEngine;

namespace LCAnimationSystem
{
    [CustomEditor(typeof(AnimationEventSystem))]
    public class AnimationEventSystemInspectorEditor:Editor
    {

        public AnimationEventSystem AnimSystem { get { return target as AnimationEventSystem; } }

        public override void OnInspectorGUI()
        {
            base.OnInspectorGUI();
            if (GUILayout.Button("Open AnimSystem",GUILayout.MaxHeight(60)))
            {
                AnimationEventSystemEditorWindow.OpenWindow(AnimSystem);
            }
        }
    }
}
