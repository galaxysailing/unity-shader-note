// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "Custom/BriSatCon"
{
    Properties
    {
        _MainTex ("Base (RGB)", 2D) = "white" {}
        // _Brightness ("Brightness", Float) = 1
        // _Saturation ("Saturation", Float) = 1
        // _Contrast ("Contrast", Float) = 1
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 100

        Pass
        {
            ZTest Always Cull Off ZWrite Off
            
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"

            sampler2D _MainTex;
			half _Brightness;
			half _Saturation;
			half _Contrast;

            struct v2f
            {
                float4 pos : SV_POSITION;
                half2 uv : TEXCOORD0;
            };

            v2f vert (appdata_img v)
            {
                v2f o;

                o.pos = UnityObjectToClipPos(v.vertex);

                o.uv = v.texcoord;

                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                fixed4 renderTex = tex2D(_MainTex, i.uv);

                // apply brightness
                fixed3 finalColor = renderTex.rgb * _Brightness;

                // apply saturation
                fixed luminance = 0.2125 * renderTex.r + 0.7154 * renderTex.g + 0.0721 * renderTex.b;
                fixed3 luminanceColor = fixed3(luminance,luminance,luminance);

                // luminanceColor + _Saturation * (finalColor - luminanceColor)
                finalColor = lerp(luminanceColor, finalColor, _Saturation);

                // apply contrast
                // fixed avg = (renderTex.r + renderTex.g + renderTex.b)/3.0;
                // fixed3 avgColor = fixed3(avg,avg,avg);
                fixed3 avgColor = fixed3(0.5,0.5,0.5);
                // avgColor + _Contrast * (finalColor - avgColor);
                finalColor = lerp(avgColor, finalColor, _Contrast);
                // finalColor = _Contrast * (finalColor - avgColor);

                return fixed4(finalColor, renderTex.a);
            }
            ENDCG
        }
    }
    Fallback Off
}
