Shader "Custom/vcmask"
{
    Properties
    {
        // �ؽ��ĸ� 4�� ���� �� �ֵ��� �������̽� �߰�
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
            // �ؽ��ĸ� 4�� �޾Ƽ� vertex color �� �̿��ؼ� masking ����� �����Ұ���
            fixed4 c = tex2D (_MainTex, IN.uv_MainTex);
            fixed4 d = tex2D (_MainTex2, IN.uv_MainTex2);
            fixed4 e = tex2D (_MainTex3, IN.uv_MainTex3);
            fixed4 f = tex2D (_MainTex4, IN.uv_MainTex4);

            // o.Albedo = IN.color.r; // �̷��� �ϸ� r������ ���� �κ�, �� ������ ������ ������� ������, ������ ������ ��Ӱ� ������ ������ '������ �ؽ���' ���� �� ���ð���.
            o.Albedo = lerp(c.rgb, d.rgb, IN.color.r); // ���� IN.color.r ���� �̿��ؼ�, ������ ������ ���� �κ�, �� IN.color.r �� 1�� ����� �κ��� d�ؽ��İ� ������, ������ �κ��� c�ؽ��İ� �������� lerp �� �ؼ����� ������! -> �̷��� d�ؽ��İ� c�ؽ��Ŀ� ������ ���� ȿ���� �� �� ����!
            o.Albedo = lerp(o.Albedo, e.rgb, IN.color.g); // ���� c, d �ؽ��İ� ���� ������ o.Albedo �� �����ͼ� e�ؽ��Ŀ� ������. �̶�, IN.color.g ���� �̿���. ��, �ʷϻ��� ���� �κ��� e�ؽ��İ� ������, �������� ������ o.Albedo �� �״�� �������� lerp�� �ؼ��� ������!
            o.Albedo = lerp(o.Albedo, f.rgb, IN.color.b); // ���� ���������� �̹����� c, d, e �ؽ��İ� ���� ������ o.Albedo �� �����ܼ� f�ؽ��Ŀ� ������. �̶�, IN.color.b ���� �̿���. ��, �Ķ����� ���� �κ��� f�ؽ��İ�, �������� ������ o.Albedo �� �״�� �������� lerp�� �ؼ��� ������! 
            o.Alpha = c.a;
        }
        ENDCG
    }
    FallBack "Diffuse"
}
