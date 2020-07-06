Shader "Custom/EdgeDetect"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _EdgeOnly ("Edge Only", Float) = 1.0
        _EdgeColor ("Edge Color", Color) = (0, 0, 0, 1)
        _BackgroundColor ("Background Color", Color) = (1, 1, 1, 1)
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
            fixed4 _MainTex_TexelSize;
            fixed _EdgeOnly;
            fixed4 _EdgeColor;
            fixed4 _BackgroundColor;

            struct v2f
            {
                half2 uv : TEXCOORD0;
                half2 offset[9] : TEXCOORD1;
                float4 pos : SV_POSITION;
            };

            v2f vert (appdata_img v)
            {
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);
                o.uv = v.texcoord;

                o.offset[0] = _MainTex_TexelSize.xy * half2(-1,-1);
                o.offset[1] = _MainTex_TexelSize.xy * half2(0,-1);
                o.offset[2] = _MainTex_TexelSize.xy * half2(1,-1);
                o.offset[3] = _MainTex_TexelSize.xy * half2(-1,0);
                o.offset[4] = _MainTex_TexelSize.xy * half2(0,0);
                o.offset[5] = _MainTex_TexelSize.xy * half2(1,0);
                o.offset[6] = _MainTex_TexelSize.xy * half2(-1,1);
                o.offset[7] = _MainTex_TexelSize.xy * half2(0,1);
                o.offset[8] = _MainTex_TexelSize.xy * half2(1,1);

                return o;
            }

            fixed luminance(fixed4 color){
                return 0.2125 * color.r + 0.7154 * color.g + 0.0721 * color.b;
            }

            half Sobel(v2f i){
                const half Gx[9] = {
                    -1,-2,-1,
                    0,0,0,
                    1,2,1
                };
                const half Gy[9] = {
                    -1,0,1,
                    -2,0,2,
                    -1,0,1
                };

                half texColor;
                half edgeX = 0;
                half edgeY = 0;
                for(int it = 0; it < 9; ++it){
                    texColor = luminance(tex2D(_MainTex, i.uv + i.offset[it]));
                    edgeX += texColor * Gx[it];
                    edgeY += texColor * Gy[it];
                }
                half edge = 1 - abs(edgeX) - abs(edgeY);

                return edge;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                half edge = Sobel(i);

                // withEdegeColor = _EdgeColor + edge * (texColor - _EdgeColor)
                // onlyEdgeColor = _EdgeColor + edge * (_BackgrounColor - _EdgeColor);
                fixed4 withEdgeColor = lerp(_EdgeColor, tex2D(_MainTex, i.uv), edge);
                fixed4 onlyEdgeColor = lerp(_EdgeColor, _BackgroundColor, edge);
                // withEdegeColor + _EdgeOnly * (onlyEdgeColor - withEdegeColor)
                // _EdgeColor + edge * (texColor - _EdgeColor) + _EdgeOnly * ( edge * (_BackgrounColor - _EdgeColor) + edge * (texColor - _EdgeColor))
                // _EdgeColor + edge*texColor - edge*_EdgeColor + _EdgeOnly * edge * (_BkColor + texColor - 2*_EdgeColor)
                // texColor * edge * (1 + _EdgeOnly )
                return lerp(withEdgeColor, onlyEdgeColor, _EdgeOnly);
            }
            ENDCG
        }
    }
    Fallback Off
}