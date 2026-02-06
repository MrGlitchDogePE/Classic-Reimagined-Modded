const int FOG_SHAPE_SPHERICAL = 0;
const int FOG_SHAPE_CYLINDRICAL = 1;

float linear_fog_value(float vertexDistance, float fogStart, float fogEnd) {
    fogEnd *= 30.5 / 30.0; // Adjust for better visual match to original beta fog
    if (vertexDistance <= fogStart) {
        return 0.0;
    } else if (vertexDistance >= fogEnd) {
        return 1.0;
    }

    return (vertexDistance - fogStart) / (fogEnd - fogStart);
}

float total_fog_value(float sphericalVertexDistance, float cylindricalVertexDistance, float environmentalStart, float environmentalEnd, float renderDistanceStart, float renderDistanceEnd) {
    return max(max(max(max(max(max(
        linear_fog_value(sphericalVertexDistance, max(12, renderDistanceEnd * 0.375), renderDistanceEnd * (61 / 30.0)),
        linear_fog_value(sphericalVertexDistance, max(32, renderDistanceEnd * 0.125), renderDistanceEnd * (45.75 / 30.0))),
        linear_fog_value(sphericalVertexDistance, max(64, renderDistanceEnd * 0.25), renderDistanceEnd * (30.5 / 30.0))),
        linear_fog_value(sphericalVertexDistance, renderDistanceEnd / 4, renderDistanceEnd * (30.1875 / 30.0))),
        linear_fog_value(sphericalVertexDistance, renderDistanceStart, renderDistanceEnd)),
        linear_fog_value(sphericalVertexDistance, environmentalEnd / 4, environmentalEnd)),
        linear_fog_value(sphericalVertexDistance, environmentalStart, environmentalEnd))
    ;
}

vec4 _linearFog(vec4 fragColor, vec2 fragDistance, vec4 fogColor, vec2 environmentFog, vec2 renderFog, float fadeFactor) {
#ifdef USE_FOG
    float fogValue = max(1.0 - fadeFactor, total_fog_value(fragDistance.y, fragDistance.x, environmentFog.x, environmentFog.y, renderFog.x, renderFog.y));
    return vec4(mix(fragColor.rgb, fogColor.rgb, fogValue * fogColor.a), fragColor.a);
#else
    return fragColor;
#endif
}

vec2 getFragDistance(vec3 position) {
    return vec2(max(length(position.xz), abs(position.y)), length(position));
}