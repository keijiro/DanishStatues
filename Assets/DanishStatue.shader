Shader "DanishStatue"
{
    Properties
    {
        _Color("Color", Color) = (1,1,1,1)
        _Color2("Color 2", Color) = (1,1,1,1)

        _Smoothness("Smoothness", Range(0, 1)) = 0.5
        [Gamma] _Metallic("Metallic", Range(0, 1)) = 0.0

        _BumpMap("Normal Map", 2D) = "bump" {}

        _OcclusionMap("Occlusion Map", 2D) = "white" {}
        _OcclusionStrength("Occlusion Strength", Range(0, 1)) = 1.0

        _CurvatureMap("Curvature Map", 2D) = "white" {}

        _DetailAlbedoMap("Detail Albedo", 2D) = "white" {}
        _DetailNormalMap("Detail Normal Map", 2D) = "bump" {}
        _DetailNormalMapScale("Detail Normal Scale", Float) = 1.0
        _DetailMapScale("Details Scale", Float) = 1.0
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }

        CGPROGRAM

        #pragma surface Surface Standard vertex:Vertex addshadow fullforwardshadows
        #pragma target 3.5

        struct Input
        {
            float2 baseCoord;
            float3 localCoord;
            float3 localNormal;
        };

        half4 _Color;
        half4 _Color2;

        half _Smoothness;
        half _Metallic;

        sampler2D _BumpMap;

        sampler2D _OcclusionMap;
        half _OcclusionStrength;

        sampler2D _CurvatureMap;

        sampler2D _DetailAlbedoMap;
        sampler2D _DetailNormalMap;
        half _DetailNormalMapScale;
        half _DetailMapScale;

        void Vertex(inout appdata_full v, out Input data)
        {
            UNITY_INITIALIZE_OUTPUT(Input, data);
            data.baseCoord = v.texcoord.xy;
            data.localCoord = v.vertex.xyz;
            data.localNormal = v.normal.xyz;
        }

        void Surface(Input IN, inout SurfaceOutputStandard o)
        {
            // Curvature map
            half cv = tex2D(_CurvatureMap, IN.baseCoord).r;
            cv = max(cv, 1 - tex2D(_CurvatureMap, IN.baseCoord).g);

            // Blend factor of triplanar mapping
            float3 bf = abs(IN.localNormal);
            bf /= dot(bf, 1);

            // Triplanar mapping
            float2 tx = IN.localCoord.yz * _DetailMapScale;
            float2 ty = IN.localCoord.zx * _DetailMapScale;
            float2 tz = IN.localCoord.xy * _DetailMapScale;

            // Base color
            half3 cx = tex2D(_DetailAlbedoMap, tx).rgb * bf.x;
            half3 cy = tex2D(_DetailAlbedoMap, ty).rgb * bf.y;
            half3 cz = tex2D(_DetailAlbedoMap, tz).rgb * bf.z;
            o.Albedo = (cx + cy + cz) * lerp(_Color.rgb, _Color.rgb, cv);

            // Normal map
            half3 nb = UnpackNormal(tex2D(_BumpMap, IN.baseCoord));
            half4 nx = tex2D(_DetailNormalMap, tx) * bf.x;
            half4 ny = tex2D(_DetailNormalMap, ty) * bf.y;
            half4 nz = tex2D(_DetailNormalMap, tz) * bf.z;
            half3 nt = UnpackScaleNormal(nx + ny + nz, _DetailNormalMapScale);
            o.Normal = BlendNormals(nb, nt);

            // Occlusion map
            half occ = tex2D(_OcclusionMap, IN.baseCoord).g;
            o.Occlusion = LerpOneTo(occ, _OcclusionStrength);

            // Other parameters
            o.Metallic = _Metallic;
            o.Smoothness = _Smoothness;
        }

        ENDCG
    }
    FallBack "Diffuse"
}
