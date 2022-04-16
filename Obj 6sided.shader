// Unity built-in shader source. Copyright (c) 2016 Unity Technologies. MIT license (see license.txt)
// Copyright (c) 2021 hydriod MIT license (see license.txt)
Shader "Obj 6sided/Obj 6sided"
{
    Properties
    {
        _Tint ("Tint Color", Color) = (.5, .5, .5, .5)
        [Gamma] _Exposure ("Exposure", Range(0, 8)) = 1.0
        [HDR] _FrontTex ("Front [+Z]   (HDR)", 2D) = "grey" {}
        [HDR] _BackTex ("Back [-Z]   (HDR)", 2D) = "grey" {}
        [HDR] _LeftTex ("Left [+X]   (HDR)", 2D) = "grey" {}
        [HDR] _RightTex ("Right [-X]   (HDR)", 2D) = "grey" {}
        [HDR] _UpTex ("Up [+Y]   (HDR)", 2D) = "grey" {}
        [HDR] _DownTex ("Down [-Y]   (HDR)", 2D) = "grey" {}
        [NoScaleOffset] _Alpha_FrontTex ("Front [+Z]   (Alpha)", 2D) = "white" {}
        [NoScaleOffset] _Alpha_BackTex ("Back [-Z]   (Alpha)", 2D) = "white" {}
        [NoScaleOffset] _Alpha_LeftTex ("Left [+X]   (Alpha)", 2D) = "white" {}
        [NoScaleOffset] _Alpha_RightTex ("Right [-X]   (Alpha)", 2D) = "white" {}
        [NoScaleOffset] _Alpha_UpTex ("Up [+Y]   (Alpha)", 2D) = "white" {}
        [NoScaleOffset] _Alpha_DownTex ("Down [-Y]   (Alpha)", 2D) = "white" {}

        _BlendSrc("Blend Src", int) = 1
        _BlendDst("Blend Dst", int) = 0
    }

    CustomEditor "ShaderGUI_6sided"
    
    SubShader
    {
        Tags { "Queue"="Transparent-1" "RenderType"="Transparent" }
        LOD 100
        Cull Front
        ZWrite off

        //multiply
        Blend [_BlendSrc] [_BlendDst]

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
            };

            struct v2f
            {
                float4 vertex : SV_POSITION;
                float4 cubePosition : TEXCOORD0;
            };

            v2f vert (appdata v)
            {
                v2f o;

                o.vertex = UnityObjectToClipPos(v.vertex);

                // convert cube position
                float4 absPosi = abs(v.vertex);
                float maxLength = max(max(absPosi.x, absPosi.y), absPosi.z);
                o.cubePosition = v.vertex / maxLength;
                // normalize from -1.0~1.0 to 0.0~1.0
                o.cubePosition = (o.cubePosition + float4(1.0,1.0,1.0,1.0)) / 2.0;
                
                o.cubePosition.w = 1.0;

                return o;
            }

            uniform sampler2D _FrontTex;
            uniform sampler2D _BackTex;
            uniform sampler2D _LeftTex;
            uniform sampler2D _RightTex;
            uniform sampler2D _UpTex;
            uniform sampler2D _DownTex;
            uniform sampler2D _Alpha_FrontTex;
            uniform sampler2D _Alpha_BackTex;
            uniform sampler2D _Alpha_LeftTex;
            uniform sampler2D _Alpha_RightTex;
            uniform sampler2D _Alpha_UpTex;
            uniform sampler2D _Alpha_DownTex;
            uniform float4 _FrontTex_HDR;
            uniform float4 _BackTex_HDR;
            uniform float4 _LeftTex_HDR;
            uniform float4 _RightTex_HDR;
            uniform float4 _UpTex_HDR;
            uniform float4 _DownTex_HDR;
            uniform float4 _Tint;
            uniform float _Exposure;
            fixed4 frag (v2f i) : SV_Target
            {
                //error
                float eps = 0.1e-5; 

                
                // sample the texture
                // up +Y
                float2 uv = i.cubePosition.xz * float4(1,-1,1,1) + float4(0,1,0,0);
                half4 pix = tex2D(_UpTex, uv);
                half4 alpha_col = tex2D(_Alpha_UpTex, uv);
                fixed3 col = DecodeHDR(pix, _UpTex_HDR);
                // down -Y
                uv = i.cubePosition.xz;
                pix = tex2D(_DownTex, uv);
                alpha_col = (i.cubePosition.y < 0.0 + eps)? tex2D(_Alpha_DownTex, uv) : alpha_col;
                col = (i.cubePosition.y < 0.0 + eps)? DecodeHDR(pix, _DownTex_HDR) : col;
                // front +Z
                uv = i.cubePosition.xy;
                pix = tex2D(_FrontTex, uv);
                alpha_col = (i.cubePosition.z > 1.0 - eps)? tex2D(_Alpha_FrontTex, uv) : alpha_col;
                col = (i.cubePosition.z > 1.0 - eps)? DecodeHDR(pix, _FrontTex_HDR) : col;
                // back -Z
                uv = i.cubePosition.xy * float4(-1,1,1,1) +float4(1,0,0,0);
                pix = tex2D(_BackTex, uv);
                alpha_col = (i.cubePosition.z < 0.0 + eps)? tex2D(_Alpha_BackTex, uv) : alpha_col;
                col = (i.cubePosition.z < 0.0 + eps)? DecodeHDR(pix, _BackTex_HDR) : col;
                // left +X
                uv = i.cubePosition.zy * float4(-1,1,1,1) +float4(1,0,0,0);
                pix = tex2D(_LeftTex, uv);
                alpha_col = (i.cubePosition.x > 1.0 - eps)? tex2D(_Alpha_LeftTex, uv) : alpha_col;
                col = (i.cubePosition.x > 1.0 - eps)? DecodeHDR(pix, _LeftTex_HDR) : col;
                // right -X
                uv = i.cubePosition.zy;
                pix = tex2D(_RightTex, uv);
                alpha_col = (i.cubePosition.x < 0.0 + eps)? tex2D(_Alpha_RightTex, uv) : alpha_col;
                col = (i.cubePosition.x < 0.0 + eps)? DecodeHDR(pix, _RightTex_HDR) : col;

                // mix Tint color
                col *= _Tint.rgb * unity_ColorSpaceDouble.rgb;
                col *= _Exposure;
                // 
                float alpha = saturate(alpha_col.rgb * unity_ColorSpaceDouble.rgb);

                return fixed4(col, alpha);
            }
            ENDCG
        }
    }
}
