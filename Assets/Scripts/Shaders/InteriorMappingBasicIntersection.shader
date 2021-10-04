Shader "Custom/InteriorMappingBasicIntersection"
{
    Properties
    {
        _Color ("Color", Color) = (1,1,1,1)
        _MainTex ("Albedo (RGB)", 2D) = "white" {}
        _Glossiness ("Smoothness", Range(0,1)) = 0.5
        _Metallic ("Metallic", Range(0,1)) = 0.0
		_WidthDivision("Width Division", Float) = 4
		_HeightDivision("Height Division", Float) = 4
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 200

        CGPROGRAM
        // Physically based Standard lighting model, and enable shadows on all light types
        #pragma surface surf Standard vertex:vert fullforwardshadows

        // Use shader model 3.0 target, to get nicer looking lighting
        #pragma target 5.0

		#include "InteriorMappingUtility.cginc"

        sampler2D _MainTex;

		float _WidthDivision;
		float _HeightDivision;

		struct Input
		{
			//What you have to calculate yourself
			//Faster to calculate these in the vertex function than in the surface function
			//The object view direction from the camera
			float3 objectViewDir;
			float2 uv_WindowAlbedo;
			//The local position of the fragment
			float3 objectPos;
		};

		void vert(inout appdata_full i, out Input o)
		{
			UNITY_INITIALIZE_OUTPUT(Input, o);

			//The local position of the camera
			float3 objectCameraPos = mul(unity_WorldToObject, float4(_WorldSpaceCameraPos, 1.0)).xyz;

			//The camera's view direction in object space						
			o.objectViewDir = i.vertex - objectCameraPos;

			//Save the position of the fragment in object space
			o.objectPos = i.vertex;
		}


        half _Glossiness;
        half _Metallic;
        fixed4 _Color;

        // Add instancing support for this shader. You need to check 'Enable Instancing' on materials that use the shader.
        // See https://docs.unity3d.com/Manual/GPUInstancing.html for more information about instancing.
        // #pragma instancing_options assumeuniformscaling
        UNITY_INSTANCING_BUFFER_START(Props)
            // put more per-instance properties here
        UNITY_INSTANCING_BUFFER_END(Props)

        void surf (Input IN, inout SurfaceOutputStandard o)
        {
			float distanceBetweenFloors = 1 / _HeightDivision;
			float distanceBetweenWalls = 1 / _WidthDivision;

			//The view direction of the camera to this fragment in local space
			float3 rayDir = normalize(IN.objectViewDir);

			//The local position of this fragment
			float3 rayStartPos = IN.objectPos;

			//Important to start inside the house or we will display one of the outer walls
			rayStartPos += rayDir * 0.0001;


			//Init the loop with a float4 to make it easier to return from a function
			//colorAndDist.rgb is the color that will be displayed
			//colorAndDist.w is the shortest distance to a wall so far so we can find which wall is the closest
			float4 intersectPosAndDist = float4(float3(1, 1, 1), 100000000.0);

			float3 cellID = getCellID(rayStartPos, float3(distanceBetweenWalls, distanceBetweenFloors, distanceBetweenWalls));

			//Intersection 1: Wall / roof (y)
			//Camera is looking up if the dot product is > 0 = Roof
			if (dot(upVec, rayDir) > 0)
			{
				//The local position of the roof
				float3 wallPos = (cellID.y * distanceBetweenFloors) * upVec;

				//Check if the roof is intersecting with the ray, if so set the color and the distance to the roof and return it
				intersectPosAndDist = checkIfCloser(rayDir, rayStartPos, wallPos, upVec, intersectPosAndDist);

			}
			//Floor
			else
			{
				float3 wallPos = ((cellID.y - 1.0) * distanceBetweenFloors) * upVec;

				intersectPosAndDist = checkIfCloser(rayDir, rayStartPos, wallPos, upVec * -1, intersectPosAndDist);
			}


			//Intersection 2: Right wall (x)
			if (dot(rightVec, rayDir) > 0)
			{
				float3 wallPos = (cellID.x * distanceBetweenWalls) * rightVec;

				intersectPosAndDist = checkIfCloser(rayDir, rayStartPos, wallPos, rightVec, intersectPosAndDist);
			}
			else
			{
				float3 wallPos = ((cellID.x - 1.0) * distanceBetweenWalls) * rightVec;

				intersectPosAndDist = checkIfCloser(rayDir, rayStartPos, wallPos, rightVec * -1, intersectPosAndDist);
			}


			//Intersection 3: Forward wall (z)
			if (dot(forwardVec, rayDir) > 0)
			{
				float3 wallPos = (cellID.z * distanceBetweenWalls) * forwardVec;

				intersectPosAndDist = checkIfCloser(rayDir, rayStartPos, wallPos, forwardVec, intersectPosAndDist);
			}
			else
			{
				float3 wallPos = ((cellID.z - 1.0) * distanceBetweenWalls) * forwardVec;

				intersectPosAndDist = checkIfCloser(rayDir, rayStartPos, wallPos, forwardVec * -1, intersectPosAndDist);
			}

			//Output

			o.Albedo = intersectPosAndDist.rgb;
        }
        ENDCG
    }
    FallBack "Diffuse"
}
