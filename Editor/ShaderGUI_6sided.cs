using UnityEngine;
using UnityEditor;

public class ShaderGUI_6sided : ShaderGUI
{
    public override void OnGUI(MaterialEditor materialEditor, MaterialProperty[] properties)
    {
        // Get Property
        MaterialProperty _FrontTex = FindProperty("_FrontTex", properties);
        MaterialProperty _BackTex = FindProperty("_BackTex", properties);
        MaterialProperty _LeftTex = FindProperty("_LeftTex", properties);
        MaterialProperty _RightTex = FindProperty("_RightTex", properties);
        MaterialProperty _UpTex = FindProperty("_UpTex", properties);
        MaterialProperty _DownTex = FindProperty("_DownTex", properties);
        MaterialProperty _Tint = FindProperty("_Tint", properties);
        MaterialProperty _Exposure = FindProperty("_Exposure", properties);

        // 6 Sided Texture Property
        GUILayout.Label("Texture(HDR)", EditorStyles.boldLabel);
        materialEditor.TexturePropertyWithHDRColor(new GUIContent("Front [+Z]   (HDR)"), _FrontTex, _Tint, false);
        materialEditor.TexturePropertyWithHDRColor(new GUIContent("Back [-Z]   (HDR)"), _BackTex, _Tint, false);
        materialEditor.TexturePropertyWithHDRColor(new GUIContent("Left [+X]   (HDR)"), _LeftTex, _Tint, false);
        materialEditor.TexturePropertyWithHDRColor(new GUIContent("Right [-X]   (HDR)"), _RightTex, _Tint, false);
        materialEditor.TexturePropertyWithHDRColor(new GUIContent("Up [+Y]   (HDR)"), _UpTex, _Tint, false);
        materialEditor.TexturePropertyWithHDRColor(new GUIContent("Down [-Y]   (HDR)"), _DownTex, _Tint, false);

        GUILayout.Space(10.0f);

        // Exposure Property
        GUILayout.Label("Exposure", EditorStyles.boldLabel);
        materialEditor.FloatProperty(_Exposure, "Exposure");

        GUILayout.Space(30.0f);

        // Render Queue
        materialEditor.RenderQueueField();

    }
}