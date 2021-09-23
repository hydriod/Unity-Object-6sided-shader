// Unity built-in shader source. Copyright (c) 2016 Unity Technologies. MIT license (see license.txt)
// Copyright (c) 2021 hydriod MIT license (see license.txt)
Shader "Unlit/Obj 6sided"
{
    Properties
    {
        _Tint ("Tint Color", Color) = (.5, .5, .5, .5)
        [Gamma] _Exposure ("Exposure", Range(0, 8)) = 1.0
        [NoScaleOffset] _FrontTex ("Front [+Z]   (HDR)", 2D) = "grey" {}
        [NoScaleOffset] _BackTex ("Back [-Z]   (HDR)", 2D) = "grey" {}
        [NoScaleOffset] _LeftTex ("Left [+X]   (HDR)", 2D) = "grey" {}
        [NoScaleOffset] _RightTex ("Right [-X]   (HDR)", 2D) = "grey" {}
        [NoScaleOffset] _UpTex ("Up [+Y]   (HDR)", 2D) = "grey" {}
        [NoScaleOffset] _DownTex ("Down [-Y]   (HDR)", 2D) = "grey" {}
    }
    SubShader
    {
        Tags { "Queue"="Transparent-1" "RenderType"="Transparent" }
        LOD 100
        Cull Front
        ZWrite off

        // additive
        //Blend One One 
        // alpha
        Blend SrcAlpha OneMinusSrcAlpha
        //multiply
        //Blend DstColor Zero

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
                o.cubePosition.w = 1.0;

                return o;
            }

            uniform sampler2D _FrontTex;
            uniform sampler2D _BackTex;
            uniform sampler2D _LeftTex;
            uniform sampler2D _RightTex;
            uniform sampler2D _UpTex;
            uniform sampler2D _DownTex;
            float4 _FrontTex_HDR;
            float4 _BackTex_HDR;
            float4 _LeftTex_HDR;
            float4 _RightTex_HDR;
            float4 _UpTex_HDR;
            float4 _DownTex_HDR;
            float4 _Tint;
            float _Exposure;
            fixed4 frag (v2f i) : SV_Target
            {
                //error
                float eps = 0.1e-5;

                // move origin point and normalize
                i.cubePosition = (i.cubePosition + float4(1.0,1.0,1.0,1.0)) / 2.0;

                // sample the texture
                // up +Y
                half4 pix = tex2D(_UpTex, i.cubePosition.xz * float4(1,-1,1,1) +float4(0,1,0,0));
                fixed3 col = DecodeHDR(pix, _UpTex_HDR);
                // down -Y
                pix = tex2D(_DownTex, i.cubePosition.xz);
                col = (i.cubePosition.y < eps)? DecodeHDR(pix, _DownTex_HDR) : col;
                // front +Z
                pix = tex2D(_FrontTex, i.cubePosition.xy);
                col = (i.cubePosition.z > 1.0 -eps)? DecodeHDR(pix, _FrontTex_HDR) : col;
                // back -Z
                pix = tex2D(_BackTex, i.cubePosition.xy * float4(-1,1,1,1) +float4(1,0,0,0));
                col = (i.cubePosition.z < eps)? DecodeHDR(pix, _BackTex_HDR) :col;
                // left +X
                pix = tex2D(_LeftTex, i.cubePosition.zy * float4(-1,1,1,1) +float4(1,0,0,0));
                col = (i.cubePosition.x > 1.0 - eps)? DecodeHDR(pix, _LeftTex_HDR) :col;
                // right -X
                pix = tex2D(_RightTex, i.cubePosition.zy);
                col = (i.cubePosition.x < eps)? DecodeHDR(pix,_RightTex_HDR) :col;

                col *= _Tint.rgb * unity_ColorSpaceDouble.rgb;
                col *= _Exposure;

                return fixed4(col,_Tint.a);
            }
            ENDCG
        }
    }
}
