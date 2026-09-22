const int FOG_SHAPE_SPHERICAL = 0;
const int FOG_SHAPE_CYLINDRICAL = 1;

float linear_fog_value(float vertexDistance, float fogStart, float fogEnd) {
    if (vertexDistance <= fogStart) {
        return 0.0;
    } else if (vertexDistance >= fogEnd) {
        return 1.0;
    }

    return (vertexDistance - fogStart) / (fogEnd - fogStart);
}

float classic_fog_value(float vertexDistance, float fogStart, float fogEnd) {
        float denom = fogEnd - fogStart;
        float fogFactor = clamp((fogEnd - vertexDistance) / (denom + 0.001), 0.0, 1.0);
    return 1.0f - fogFactor; 
}

float total_fog_value(float sphericalVertexDistance, float cylindricalVertexDistance, float environmentalStart, float environmentalEnd, float renderDistanceStart, float renderDistanceEnd) {
    float classicEnd = min(environmentalEnd, renderDistanceEnd);
    float classicStart = classicEnd * 0.25;
    if(environmentalEnd == 96.0 && environmentalStart == 10.0) { // if isNether = true returns the classic nether fog
        classicEnd = renderDistanceEnd;
    }
    return mix(
        classic_fog_value(sphericalVertexDistance, classicStart, classicEnd),
        1.0,
        clamp((0.0 - environmentalStart) / (environmentalEnd - environmentalStart), 0.0, 1.0)
    );
}

vec4 _linearFog(vec4 fragColor, vec2 fragDistance, vec4 fogColor, vec2 environmentFog, vec2 renderFog, float fadeFactor) {
#ifdef USE_FOG
    //fogColor.rgb = vec3(1.0);
    //fragColor.rgb = vec3(0.0);
    float fogValue = max(1.0 - fadeFactor, total_fog_value(fragDistance.y, fragDistance.x, environmentFog.x, environmentFog.y, renderFog.x, renderFog.y));
    return vec4(mix(fragColor.rgb, fogColor.rgb, fogValue * fogColor.a), fragColor.a);
#else
    return fragColor;
#endif
}

vec2 getFragDistance(vec3 position) {
    return vec2(max(length(position.xz), abs(position.y)), length(position));
}