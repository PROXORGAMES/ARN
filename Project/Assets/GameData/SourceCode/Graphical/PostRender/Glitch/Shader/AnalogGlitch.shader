Shader "Proxor/Glitch"
{
    Properties
    {
        _MainTex ("-", 2D) = "" {}
		_ScanLineJitter("ScanLineJitter", Range(0,3)) = 1.0
		_VerticalJump("VerticalJump", Range(0,3)) = 1.0
		_HorizontalShake("HorizontalShake", Range(0,3)) = 1.0
		_ColorDrif("_olorDrif", Range(0,3)) = 1.0
    }
    CGINCLUDE

    #include "UnityCG.cginc"

    sampler2D _MainTex;
    float2 _MainTex_TexelSize;

    float2 _ScanLineJitter; // (displacement, threshold)
    float2 _VerticalJump;   // (amount, time)
    float _HorizontalShake;
    float2 _ColorDrift;     // (amount, time)

    float nrand(float x, float y)
    {
        return frac(sin(dot(float2(x, y), float2(12.9898, 78.233))) * 43758.5453);
    }

    half4 frag(v2f_img i) : SV_Target
    {
        float u = i.uv.x;
        float v = i.uv.y;

        // Scan line jitter
        float jitter = nrand(v, _Time.x) * 2 - 1;
        jitter *= step(_ScanLineJitter.y, abs(jitter)) * _ScanLineJitter.x;

        // Vertical jump
        float jump = lerp(v, frac(v + _VerticalJump.y), _VerticalJump.x);

        // Horizontal shake
        float shake = (nrand(_Time.x, 2) - 0.5) * _HorizontalShake;

        // Color drift
        float drift = sin(jump + _ColorDrift.y) * _ColorDrift.x;

        half4 src1 = tex2D(_MainTex, frac(float2(u + jitter + shake, jump)));
        half4 src2 = tex2D(_MainTex, frac(float2(u + jitter + shake + drift, jump)));

        return half4(src1.r, src2.g, src1.b, src1.a);
    }

    ENDCG
    SubShader
    {
        Pass
        {
            ZTest Always Cull Off ZWrite Off
            CGPROGRAM
            #pragma vertex vert_img
            #pragma fragment frag
            #pragma target 3.0
            ENDCG
        }
    }
}
