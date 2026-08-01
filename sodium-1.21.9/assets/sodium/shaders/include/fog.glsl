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
    float fogValue = sqrt(1.0f - pow(linear_fog_value(vertexDistance, 0, fogEnd), 2.0));
    float normalized = (vertexDistance - fogStart) / (fogEnd - fogStart);
    normalized = clamp(normalized, 0.0, 1.0);
    // Apply logarithmic scaling
    float fogFactor = log(1.0 + normalized * fogStart) / log(1.0 + fogStart);
    float realistic_fog = pow(pow(fogFactor, 2) / 2, fogValue);

    return pow(realistic_fog, sqrt(1.0f - pow(linear_fog_value(vertexDistance, fogEnd * 0.75, fogEnd), 2.0)));
}

float total_fog_value(float sphericalVertexDistance, float cylindricalVertexDistance, float environmentalStart, float environmentalEnd, float renderDistanceStart, float renderDistanceEnd) {
    float classicEnd = min(environmentalEnd, renderDistanceEnd) * (32.0 + sqrt(2.0) / 3.0) / 32.0;
    float classicStart = classicEnd * 0.25;
    return mix(
        classic_fog_value(sphericalVertexDistance, classicStart, classicEnd),
        1.0,
        clamp((0.0 - environmentalStart) / (environmentalEnd - environmentalStart), 0.0, 1.0)
    );
};

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