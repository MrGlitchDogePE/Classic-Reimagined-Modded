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
    float fogValue = sqrt(1.0f - pow(linear_fog_value(vertexDistance, fogStart, fogEnd), 2.0));
    float smoothFogValue = clamp(smoothstep(0, fogEnd / 1.5, vertexDistance), 0.0, 1.0);
    float ultraSmoothFogValue = pow(pow(smoothFogValue, 1.0f - smoothFogValue), 2.0f);
    float RealisticFogValue = linear_fog_value(vertexDistance, 0, fogEnd * 1.25);
    float ultraRealisticFogValue = mix(0, RealisticFogValue, ultraSmoothFogValue);
    return pow(max(ultraRealisticFogValue, 1.0f - sqrt(1.0f - pow(linear_fog_value(vertexDistance, 0, fogEnd), 2.0f))), sqrt(1.0f - pow(linear_fog_value(vertexDistance, fogStart, fogEnd), 2.0f)));
}

float total_fog_value(float sphericalVertexDistance, float cylindricalVertexDistance, float environmentalStart, float environmentalEnd, float renderDistanceStart, float renderDistanceEnd) {
    return mix(
        max(classic_fog_value(sphericalVertexDistance, environmentalStart, environmentalEnd), classic_fog_value(sphericalVertexDistance, renderDistanceStart, renderDistanceEnd)),
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