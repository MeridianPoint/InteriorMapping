#ifndef _INTERIOR_MAPPING_UTILITY_CGINC_
#define _INTERIOR_MAPPING_UTILITY_CGINC_

//Direction vectors in local space
static float3 upVec = float3(0, 1, 0);
static float3 rightVec = float3(1, 0, 0);
static float3 forwardVec = float3(0, 0, 1);

float3 getCellID(float3 position, float3 division) {
	float3 id = ceil(position / division);
	return id;
}

//Calculate the distance between the ray start position and where it's intersecting with the plane
		//If this distance is shorter than the previous best distance, the save it and the color belonging to the wall and return it
float4 checkIfCloser(float3 rayDir, float3 rayStartPos, float3 planePos, float3 planeNormal, float4 intersectPosAndDist)
{
	//Get the distance to the plane with ray-plane intersection
	//http://www.scratchapixel.com/lessons/3d-basic-rendering/minimal-ray-tracer-rendering-simple-shapes/ray-plane-and-ray-disk-intersection
	//We are always intersecting with the plane so we dont need to spend time checking that			
	float t = dot(planePos - rayStartPos, planeNormal) / dot(planeNormal, rayDir);

	//At what position is the ray intersecting with the plane - use this if you need uv coordinates


	//If the distance is closer to the camera than the previous best distance
	if (t < intersectPosAndDist.w)
	{
		//This distance is now the best distance
		intersectPosAndDist.w = t;

		intersectPosAndDist.rgb = rayStartPos + rayDir * t;
	}

	return intersectPosAndDist;
}



#endif