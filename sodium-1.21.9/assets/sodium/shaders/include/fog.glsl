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
    return mix(1.0, 0.0, fogFactor); 
}

float total_fog_value(float sphericalVertexDistance, float cylindricalVertexDistance, float environmentalStart, float environmentalEnd, float renderDistanceStart, float renderDistanceEnd) {
    float classicEnd = min(renderDistanceEnd, environmentalEnd);
    float classicStart = classicEnd * 0.25;
    if (environmentalStart == 10.0 && environmentalEnd == 96.0) { // classic nether fog, use render distance fog properties
        classicEnd = renderDistanceStart;
        classicStart = 0.0;
    }
    if (environmentalStart == -8.0 && environmentalEnd <= 96.0) { // water fog, use render distance fog properties
        classicStart = min(classicEnd * 0.25, (environmentalStart / environmentalEnd) * classicEnd);
    }
    return classic_fog_value(sphericalVertexDistance, classicStart, classicEnd);
}

vec4 _linearFog(vec4 fragColor, vec2 fragDistance, vec4 fogColor, vec2 environmentFog, vec2 renderFog) {
#ifdef USE_FOG
    float fogValue = total_fog_value(fragDistance.y, fragDistance.x, environmentFog.x, environmentFog.y, renderFog.x, renderFog.y);
    return vec4(mix(fragColor.rgb, fogColor.rgb, fogValue * fogColor.a), fragColor.a);
#else
    return fragColor;
#endif
}

vec2 getFragDistance(vec3 position) {
    return vec2(max(max(abs(position.y), abs(position.z)), abs(position.x)), length(position));
}