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
    float fogRange = linear_fog_value(vertexDistance, fogStart / 4, fogEnd * 1.25);
    float fogRangePass = 1.0f - sqrt(1.0f - pow(linear_fog_value(vertexDistance, 0, fogEnd), 2));
    float fogRangePass2 = pow(linear_fog_value(vertexDistance, 0, fogEnd), 3.29);
    return max(max(fogRange, fogRangePass), fogRangePass2);
}

float total_fog_value(float sphericalVertexDistance, float cylindricalVertexDistance, float environmentalStart, float environmentalEnd, float renderDistanceStart, float renderDistanceEnd) {
    if (renderDistanceEnd <= environmentalEnd) {
        return mix(
        classic_fog_value(sphericalVertexDistance, renderDistanceStart, renderDistanceEnd),
        1.0,
        clamp((0.0 - environmentalStart) / (environmentalEnd - environmentalStart), 0.0, 1.0)
        );
    } else {
        return linear_fog_value(sphericalVertexDistance, environmentalStart, environmentalEnd);
    }
};

vec4 _linearFog(vec4 fragColor, vec2 fragDistance, vec4 fogColor, vec2 environmentFog, vec2 renderFog, float fadeFactor) {
#ifdef USE_FOG
    // fogColor.rgb = vec3(1.0);
    // fragColor.rgb = vec3(0.0);
    float fogValue = max(1.0 - fadeFactor, total_fog_value(fragDistance.y, fragDistance.x, environmentFog.x, environmentFog.y, renderFog.x, renderFog.y));
    return vec4(mix(fragColor.rgb, fogColor.rgb, fogValue * fogColor.a), fragColor.a);
#else
    return fragColor;
#endif
}

vec2 getFragDistance(vec3 position) {
    return vec2(max(length(position.xz), abs(position.y)), length(position));
}