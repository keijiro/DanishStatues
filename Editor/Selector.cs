using UnityEditor;

namespace JP.Keijiro.DanishStatues
{
    static class Selector
    {
        [MenuItem("Packages/Danish Statues")]
        static void OpenPackageDirectory()
        {
            var path = "Packages/jp.keijiro.danish-statues/README.md";
            Selection.activeObject = AssetDatabase.LoadMainAssetAtPath(path);
            EditorGUIUtility.PingObject(Selection.activeObject);
        }
    }
}
