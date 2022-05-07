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
            // o.Albedo = lerp(c.rgb, d.rgb, IN.color.r); // 위의 IN.color.r 값을 이용해서, 빨간색 영역이 강한 부분, 즉 IN.color.r 이 1에 가까운 부분은 d텍스쳐가 나오고, 나머지 부분은 c텍스쳐가 나오도록 lerp 로 텍셀값을 섞어줌! -> 이러면 d텍스쳐가 c텍스쳐에 스며드는 듯한 효과를 줄 수 있음!
            // o.Albedo = lerp(o.Albedo, e.rgb, IN.color.g); // 이제 c, d 텍스쳐가 섞인 현재의 o.Albedo 를 가져와서 e텍스쳐와 섞어줌. 이때, IN.color.g 값을 이용함. 즉, 초록색이 강한 부분은 e텍스쳐가 나오고, 나머지는 현재의 o.Albedo 가 그대로 나오도록 lerp로 텍셀값 섞어줌!
            // o.Albedo = lerp(o.Albedo, f.rgb, IN.color.b); // 위와 마찬가지로 이번에는 c, d, e 텍스쳐가 섞인 현재의 o.Albedo 를 가져외서 f텍스쳐와 섞어줌. 이때, IN.color.b 값을 이용함. 즉, 파란색이 강한 부분은 f텍스쳐가, 나머지는 현재의 o.Albedo 가 그대로 나오도록 lerp로 텍셀값 섞어줌! 
            
            o.Albedo = d.rgb * IN.color.r + e.rgb * IN.color.g + f.rgb * IN.color.b + c.rgb * (1 - (IN.color.r + IN.color.g + IN.color.b)); // 이렇게 해도 위에 lerp 를 사용한 것과 동일한 결과를 확인할 수 있음.
            
            // 왜 이런 공식이 위에 lerp 와 동일한 결과를 내는 걸까?
            
            // o.Albedo = c.rgb * (1 - (IN.color.r + IN.color.g + IN.color.b)); 
            // 일단 얘만 실행해보면, IN.color.r, g, b 영역이 각각 1에 가까운 부분들, 즉 빨강, 초록, 파랑색 영역만 0에 가까운 텍셀이 찍혀서 어둡게 보이고, 나머지 영역만 c텍스쳐로 보임.
            // 왜냐? 현재 버텍스가 r, g, b 셋 중 하나만 강한 영역에 해당된다면, 즉, 빨강, 초록, 파랑 영역 중 하나에만 해당되는 픽셀이어도 1 - (IN.color.r + IN.color.g + IN.color.b) 값이 0에 가까워지므로,
            // 그것을 c텍스쳐와 스칼라곱을 해주면 float3(0, 0, 0) 에 가까운 텍셀값이 나올테니, 빨강, 초록, 파랑영역에 해당하는 부분들은 전부 float3(0, 0, 0)에 가까운 텍셀값, 즉 검정색에 가까운 색들이 찍힐거임.

            // o.Albedo = d.rgb * IN.color.r + c.rgb * (1 - (IN.color.r + IN.color.g + IN.color.b));
            // 위에 처럼 빨, 초, 파 영역만 검정색으로 텅 비고, 나머지는 c텍스쳐로 찍힌 상태에서, d.rgb * IN.color.r 값만 더해준 걸 실행해보면, 빨강색 영역에 해당하는 검정 부분이 d텍스쳐로 바뀐걸 볼 수 있음.
            // 왜냐? 이거는 lerp 함수에서 IN.color.r 값이 1에 가까운 영역일수록, 즉 빨간색 영역일수록 d 텍스쳐가 더 강하게 섞이도록 하는 것과 동일한 공식이라고 보면 됨.
            // 그니까 현재 픽셀의 IN.color.r 값이 강한 영역일수록, d텍스쳐의 텍셀값인 d.rgb 가 더 강하게 나오게 될 것이고, 이거를 현재 c텍스쳐만 나오고 나머지는 어둡게 비어버린 o.Albedo 에 더해주면,
            // 어둡게 비어버린 세 군데 중, 빨간색 영역에 해당하는 부분, 즉 IN.color.r값이 강한 부분에만 d텍스쳐의 텍셀값이 할당되어 d텍스쳐가 추가로 보이게 되는 것이지

            // 위와 동일한 원리로 'e.rgb * IN.color.g' 와 'f.rgb * IN.color.b' 도 더해주면, 각각 초록색이 강한 영역에는 e텍스쳐, 파란색이 강한 영역에는 f텍스쳐가 찍히게 되는 것! 
            
            o.Alpha = c.a;
        }
        ENDCG
    }
    FallBack "Diffuse"
}
