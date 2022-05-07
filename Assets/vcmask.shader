Shader "Custom/vcmask"
{
    Properties
    {
        // 텍스쳐를 4장 받을 수 있도록 인터페이스 추가
        _MainTex ("Albedo (RGB)", 2D) = "white" {}
        _MainTex2 ("Albedo (RGB)", 2D) = "white" {}
        _MainTex3 ("Albedo (RGB)", 2D) = "white" {}
        _MainTex4 ("Albedo (RGB)", 2D) = "white" {}
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }

        CGPROGRAM
        // Physically based Standard lighting model, and enable shadows on all light types
        #pragma surface surf Standard noambient

        sampler2D _MainTex;
        sampler2D _MainTex2;
        sampler2D _MainTex3;
        sampler2D _MainTex4;

        struct Input
        {
            float2 uv_MainTex;
            float2 uv_MainTex2;
            float2 uv_MainTex3;
            float2 uv_MainTex4;
            float4 color:COLOR;
        };

        void surf (Input IN, inout SurfaceOutputStandard o)
        {
            // 텍스쳐를 4장 받아서 vertex color 를 이용해서 masking 기능을 구현할거임
            fixed4 c = tex2D (_MainTex, IN.uv_MainTex);
            fixed4 d = tex2D (_MainTex2, IN.uv_MainTex2);
            fixed4 e = tex2D (_MainTex3, IN.uv_MainTex3);
            fixed4 f = tex2D (_MainTex4, IN.uv_MainTex4);

            // o.Albedo = IN.color.r; // 이렇게 하면 r영역이 강한 부분, 즉 빨간색 영역만 흰색으로 나오고, 나머지 영역은 어둡게 나오는 일종의 '노이즈 텍스쳐' 같은 게 나올거임.
            o.Albedo = lerp(c.rgb, d.rgb, IN.color.r); // 위의 IN.color.r 값을 이용해서, 빨간색 영역이 강한 부분, 즉 IN.color.r 이 1에 가까운 부분은 d텍스쳐가 나오고, 나머지 부분은 c텍스쳐가 나오도록 lerp 로 텍셀값을 섞어줌! -> 이러면 d텍스쳐가 c텍스쳐에 스며드는 듯한 효과를 줄 수 있음!
            o.Albedo = lerp(o.Albedo, e.rgb, IN.color.g); // 이제 c, d 텍스쳐가 섞인 현재의 o.Albedo 를 가져와서 e텍스쳐와 섞어줌. 이때, IN.color.g 값을 이용함. 즉, 초록색이 강한 부분은 e텍스쳐가 나오고, 나머지는 현재의 o.Albedo 가 그대로 나오도록 lerp로 텍셀값 섞어줌!
            o.Albedo = lerp(o.Albedo, f.rgb, IN.color.b); // 위와 마찬가지로 이번에는 c, d, e 텍스쳐가 섞인 현재의 o.Albedo 를 가져외서 f텍스쳐와 섞어줌. 이때, IN.color.b 값을 이용함. 즉, 파란색이 강한 부분은 f텍스쳐가, 나머지는 현재의 o.Albedo 가 그대로 나오도록 lerp로 텍셀값 섞어줌! 
            o.Alpha = c.a;
        }
        ENDCG
    }
    FallBack "Diffuse"
}
