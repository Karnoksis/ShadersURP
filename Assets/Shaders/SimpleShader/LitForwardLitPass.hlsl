#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"

// Textures
TEXTURE2D(_MainTex); SAMPLER(sampler_MainTex); // RGB = albedo, A = alpha

CBUFFER_START(UnityPerMaterial)
	half3 _Color;
	half4 _MainTex_ST;

CBUFFER_END



 // This is automatically set by Unity. Used in TRANSFORM_TEX to apply UV tiling



// This attributes struct receives data about the mesh we're currently rendering
// Data is automatically placed in fields according to their semantic
struct Attributes {
	half3 positionOS : POSITION; // Position in object space
	half3 normalOS : NORMAL; // Normal in object space
	half2 uv : TEXCOORD0; // Material texture UVs
};

// This struct is output by the vertex function and input to the fragment function.
// Note that fields will be transformed by the intermediary rasterization stage
struct Interpolators {
	// This value should contain the position in clip space (which is similar to a position on screen)
	// when output from the vertex function. It will be transformed into pixel position of the current
	// fragment on the screen when read from the fragment function
	half4 positionCS : SV_POSITION;

	// The following variables will retain their values from the vertex stage, except the
	// rasterizer will interpolate them between vertices
	half2 uv : TEXCOORD0; // Material texture UVs
	half3 positionWS : TEXCOORD1; // Position in world space
	half3 normalWS : TEXCOORD2; // Normal in world space
};

// The vertex function. This runs for each vertex on the mesh.
// It must output the position on the screen each vertex should appear at,
// as well as any data the fragment function will need
Interpolators Vertex(Attributes input) {
	Interpolators output;

	// These helper functions, found in URP/ShaderLib/ShaderVariablesFunctions.hlsl
	// transform object space values into world and clip space
	VertexPositionInputs posnInputs = GetVertexPositionInputs(input.positionOS);
	VertexNormalInputs normInputs = GetVertexNormalInputs(input.normalOS);

	// Pass position and orientation data to the fragment function
	output.positionCS = posnInputs.positionCS;
	output.uv = TRANSFORM_TEX(input.uv, _MainTex);
	output.normalWS = normInputs.normalWS;
	output.positionWS = posnInputs.positionWS;

	return output;
	}


// The fragment function. This runs once per fragment, which you can think of as a pixel on the screen
// It must output the final color of this pixel
half4 Fragment(Interpolators input) : SV_TARGET{
	half2 uv = input.uv;
	// Sample the color map
	half4 textureSample = SAMPLE_TEXTURE2D(_MainTex, sampler_MainTex, uv);

	// For lighting, create the InputData struct, which contains position and orientation data
	InputData InputInformation = (InputData)0; // Found in URP/ShaderLib/Input.hlsl
	InputInformation.positionWS = input.positionWS;
	InputInformation.normalWS = normalize(input.normalWS);
	InputInformation.viewDirectionWS = GetWorldSpaceNormalizeViewDir(input.positionWS); // In ShaderVariablesFunctions.hlsl
	InputInformation.shadowCoord = TransformWorldToShadowCoord(input.positionWS); // In Shadows.hlsl
	
	Light l=GetMainLight(InputInformation.shadowCoord);

	half3 viewDir = InputInformation.viewDirectionWS;
	half3 lightDirection = l.direction;
	half lightning = max(0, dot(InputInformation.normalWS, lightDirection));

	half3 Albedo;

    Albedo = _Color * textureSample.xyz * lightning * max(0.5,l.shadowAttenuation);

    return half4(Albedo,1);

}