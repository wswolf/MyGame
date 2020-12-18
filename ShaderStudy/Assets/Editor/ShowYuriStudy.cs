using System.Collections;
using System.Collections.Generic;
using UnityEditor;
using UnityEngine;

public class ShowYuriStudy : EditorWindow
{
    private void OnWizardCreate()
    {
        Debug.Log("Create");
    }
    private void OnWizardUpdate()
    {
        Debug.Log("Update");
    }
    private void OnWizardOtherButton()
    {
        Debug.Log("Btn");
    }
    [MenuItem("Help/yuriStudy")]
    private static void ShowPanel()
    {
        EditorWindow ew = EditorWindow.GetWindow<ShowYuriStudy>("Yuri");
        //s.helpString = "yuri 13718897941";
        //s.errorString = "Error 11";
    }
    private void OnGUI()
    {
        GUILayout.BeginHorizontal(GUILayout.Width(position.width), GUILayout.Height(position.height));
        {
            GUILayout.Space(2f);
            GUILayout.BeginVertical(GUILayout.Width(position.width * 0.25f));
            {
                GUILayout.Button("OK", GUILayout.ExpandWidth(true));
                GUILayout.Button("cancel", GUILayout.ExpandWidth(true));
            }
            GUILayout.EndVertical();
        }
        GUILayout.EndHorizontal();
    }
}
