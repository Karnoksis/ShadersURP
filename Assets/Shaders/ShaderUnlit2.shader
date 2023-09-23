Shader "Unlit/ShaderUnlit2"
{
    Properties
    {
        _ColorA("Color A", Color) = (1,0,0,0)
        _ColorB("Color B", Color) = (0,1,0,0)
        _Radius("Radius", Float) = 0
        _Moving("Moving", Vector) = (0,0,0,0)
        _Anchor("Anchor", Vector) = (0,0,0,0)
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 100

        Pass
        {
            CGPROGRAM
            #pragma vertex vert //Сам минимальный вертексный шейдер в UnityCG.cginc
            #pragma fragment frag


            #include "UnityCG.cginc"

            fixed4 _ColorA;
             fixed4 _ColorB;
             float _Radius;
             float4 _Moving;
             float4 _Anchor;

            struct v2f 
            {
                float4 vertex: SV_POSITION;
                float4 position: TEXCOORD1;
                half2 uv: TEXCOORD0;
            };
            /*
            struct appdata_base
            {
                float4 vertex : POSITION;
                float3 normal : NORMAL;
                float4 texcoord : TEXCOORD0;
                UNITY_VERTEX_INPUT_INSTANCE_ID
            };
            */
            v2f vert(appdata_base v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex); //Тут преобразование из POSITION в SV_POSITION на выход
                o.position = v.vertex; //Тут преборазование из POSITION в TEXCOORD1
                o.uv = v.texcoord; //тут обычная передача данных
                return o;
            }

            fixed3 InRect(float Radius, fixed2 Pos)
            {
                return (1-step(Radius+_Moving.z, abs(Pos.y+_Anchor.y+_Moving.y))) * (1-step(Radius+_Moving.w, abs(Pos.x+_Anchor.x+_Moving.x)));
            }

            float2x2 RotationMatrix(float Angle)
            {
                float s = sin(Angle);
                float c = cos(Angle);
                return float2x2 (c,-s,s,c); 
            }

            fixed4 frag (v2f i) : SV_Target //тут v2f_img - это просто структура, которая определена заранее в UnityCG.cginc
            {
               // float delta = i.uv.x;
                //fixed3 color = i.position*2;
                fixed3 color = fixed3(1,1,0);
                float2 pos = i.position;
                half2 newPos = mul(RotationMatrix(_Time.y), pos);

               // color = color * (1-(step(0.1,length(i.position.xy))));
               color = color * InRect(_Radius, newPos);
                //color = step(length(i.position.xy*1),color);
                //color.b = 0;

                return fixed4(color,1);
            }
            ENDCG
        }
    }
}
