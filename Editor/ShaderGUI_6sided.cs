using UnityEngine;
using UnityEngine.Rendering;
using UnityEditor;

public class ShaderGUI_6sided : ShaderGUI
{
    public enum BlendType
    {
        None = 0,
        Alpha = 1,
        Add = 2,
        Multiply = 3,
        Custom = 4

    }
    BlendType blendType;
    BlendMode srcBlendMode;
    BlendMode dstBlendMode;
    bool blendTypeChanged = false;
    bool customBlendModeChanged = false;
    public override void OnGUI(MaterialEditor materialEditor, MaterialProperty[] properties)
    {
        // =================== Get Property =====================
        // HDR Texture
        MaterialProperty _FrontTex = FindProperty("_FrontTex", properties);
        MaterialProperty _BackTex = FindProperty("_BackTex", properties);
        MaterialProperty _LeftTex = FindProperty("_LeftTex", properties);
        MaterialProperty _RightTex = FindProperty("_RightTex", properties);
        MaterialProperty _UpTex = FindProperty("_UpTex", properties);
        MaterialProperty _DownTex = FindProperty("_DownTex", properties);
        // Alpha Texture
        MaterialProperty _Alpha_FrontTex = FindProperty("_Alpha_FrontTex", properties);
        MaterialProperty _Alpha_BackTex = FindProperty("_Alpha_BackTex", properties);
        MaterialProperty _Alpha_LeftTex = FindProperty("_Alpha_LeftTex", properties);
        MaterialProperty _Alpha_RightTex = FindProperty("_Alpha_RightTex", properties);
        MaterialProperty _Alpha_UpTex = FindProperty("_Alpha_UpTex", properties);
        MaterialProperty _Alpha_DownTex = FindProperty("_Alpha_DownTex", properties);
        // Tint
        MaterialProperty _Tint = FindProperty("_Tint", properties);
        // Exposure
        MaterialProperty _Exposure = FindProperty("_Exposure", properties);

        // Blend Mode
        MaterialProperty _BlendSrc = FindProperty("_BlendSrc", properties);
        MaterialProperty _BlendDst = FindProperty("_BlendDst", properties);

        // ===============================================================

        float blockSpace = 10.0f;
        float sideTextureSpace = 5.0f;
        // ========================== GUI ================================
        // Blend Mode
        using (EditorGUI.ChangeCheckScope scopeChanged = new EditorGUI.ChangeCheckScope())
        {
            blendType = (BlendType)EditorGUILayout.EnumPopup("Blend Mode", blendType);
            blendTypeChanged = scopeChanged.changed;
        }
        // Custom Blend (hidden)
        using (EditorGUI.ChangeCheckScope scopeChanged = new EditorGUI.ChangeCheckScope())
        {
            if (blendType == BlendType.Custom)
            {
                EditorGUI.indentLevel = 1;
                srcBlendMode = (BlendMode)EditorGUILayout.EnumPopup("Blend Source", srcBlendMode);
                dstBlendMode = (BlendMode)EditorGUILayout.EnumPopup("Blend Destination", dstBlendMode);
            }
            customBlendModeChanged = scopeChanged.changed;
        }

        GUILayout.Space(blockSpace);

        // 6 Sided Texture Property
        EditorGUI.indentLevel = 0;
        GUILayout.Label("Texture", EditorStyles.boldLabel);

        // Front
        EditorGUI.indentLevel = 1;
        GUILayout.Label("Front [+Z] Texture", EditorStyles.boldLabel);
        materialEditor.TexturePropertyWithHDRColor(new GUIContent("Front [+Z]   (HDR)"), _FrontTex, _Tint, false);
        materialEditor.TexturePropertySingleLine(new GUIContent("Front [+Z]   (Alpha)"), _Alpha_FrontTex);
        GUILayout.Space(sideTextureSpace);
        // Back
        GUILayout.Label("Back [-Z] Texture", EditorStyles.boldLabel);
        materialEditor.TexturePropertyWithHDRColor(new GUIContent("Back [-Z]   (HDR)"), _BackTex, _Tint, false);
        materialEditor.TexturePropertySingleLine(new GUIContent("Back [-Z]   (Alpha)"), _Alpha_BackTex);
        GUILayout.Space(sideTextureSpace);
        // Left
        GUILayout.Label("Left [+X] Texture", EditorStyles.boldLabel);
        materialEditor.TexturePropertyWithHDRColor(new GUIContent("Left [+X]   (HDR)"), _LeftTex, _Tint, false);
        materialEditor.TexturePropertySingleLine(new GUIContent("Left [+X]   (Alpha)"), _Alpha_LeftTex);
        GUILayout.Space(sideTextureSpace);
        // Right
        GUILayout.Label("Right [-X] Texture", EditorStyles.boldLabel);
        materialEditor.TexturePropertyWithHDRColor(new GUIContent("Right [-X]   (HDR)"), _RightTex, _Tint, false);
        materialEditor.TexturePropertySingleLine(new GUIContent("Right [-X]   (Alpha)"), _Alpha_RightTex);
        GUILayout.Space(sideTextureSpace);
        // Up
        GUILayout.Label("UP [+Y] Texture", EditorStyles.boldLabel);
        materialEditor.TexturePropertyWithHDRColor(new GUIContent("Up [+Y]   (HDR)"), _UpTex, _Tint, false);
        materialEditor.TexturePropertySingleLine(new GUIContent("Up [+Y]   (Alpha)"), _Alpha_UpTex);
        GUILayout.Space(sideTextureSpace);
        // Down
        GUILayout.Label("Down [-Y] Texture", EditorStyles.boldLabel);
        materialEditor.TexturePropertyWithHDRColor(new GUIContent("Down [-Y]   (HDR)"), _DownTex, _Tint, false);
        materialEditor.TexturePropertySingleLine(new GUIContent("Down [-Y]   (Alpha)"), _Alpha_DownTex);
        GUILayout.Space(sideTextureSpace);

        GUILayout.Space(blockSpace);

        // Exposure Property
        GUILayout.Label("Exposure", EditorStyles.boldLabel);
        materialEditor.FloatProperty(_Exposure, "Exposure");

        GUILayout.Space(blockSpace);

        // Render Queue
        materialEditor.RenderQueueField();

        // ============================================================

        if (blendTypeChanged)
        {
            applyBlendType(_BlendSrc, _BlendDst);
        }
        if (customBlendModeChanged)
        {
            applyCustomBlendMode(_BlendSrc, _BlendDst);
        }
    }
    void applyBlendType(MaterialProperty blendSource, MaterialProperty blendDestination)
    {
        switch (blendType)
        {
            case BlendType.None:
                blendSource.floatValue = (int)BlendMode.One;
                blendDestination.floatValue = (int)BlendMode.Zero;
                break;
            case BlendType.Alpha:
                blendSource.floatValue = (int)BlendMode.SrcAlpha;
                blendDestination.floatValue = (int)BlendMode.DstAlpha;
                break;
            case BlendType.Add:
                blendSource.floatValue = (int)BlendMode.One;
                blendDestination.floatValue = (int)BlendMode.One;
                break;
            case BlendType.Multiply:
                blendSource.floatValue = (int)BlendMode.DstColor;
                blendDestination.floatValue = (int)BlendMode.Zero;
                break;
            case BlendType.Custom:
                applyCustomBlendMode(blendSource, blendDestination);
                break;
            default:
                break;
        }
    }
    void applyCustomBlendMode(MaterialProperty blendSource, MaterialProperty blendDestination)
    {
        blendSource.floatValue = (int)srcBlendMode;
        blendDestination.floatValue = (int)dstBlendMode;
    }
}