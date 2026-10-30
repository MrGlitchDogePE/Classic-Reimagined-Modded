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

float exponential_fog_value(float vertexDistance, float density) {
    return 1.0f - exp(-density * vertexDistance);
}

float total_fog_value(float sphericalVertexDistance, float cylindricalVertexDistance, float environmentalStart, float environmentalEnd, float renderDistanceStart, float renderDistanceEnd) {
    float classicEnd = min(environmentalEnd, renderDistanceEnd);
    float classicStart = classicEnd * 0.25f;
    float waterDensity = 0.1f;
    float lavaDensity = 2.0f;
    if (environmentalStart == -8.0) { // thick fog in spectator (lava, powdered snow) and water fog at 96 blocks
        float thickFogDensity = 0.4 - (classicEnd / 320);
        return exponential_fog_value(sphericalVertexDistance, thickFogDensity);
    }
    if (environmentalStart == 0.25 && environmentalEnd == 1.0) { // lava fog in classic exponential fog mode
        return exponential_fog_value(sphericalVertexDistance, lavaDensity);
    }
    if (environmentalStart == 0.0 && environmentalEnd == 5.0) { // lava with fire resistance fog in classic exponential fog mode
        lavaDensity /= 5.0f;
        return exponential_fog_value(sphericalVertexDistance, lavaDensity);
    }
    if (environmentalStart == 0.0 && environmentalEnd == 2.0) { // powder snow fog in classic exponential fog mode
        float powderSnowDensity = 1.0f;
        return exponential_fog_value(sphericalVertexDistance, powderSnowDensity);
    }
    // ####################################################################################################################
    if (environmentalStart == 10.0 && environmentalEnd == 96.0) { // nether fog in classic linear fog mode
        float dimDistance = 1.0 / renderDistanceEnd;
        float dimFog = clamp(exponential_fog_value(sphericalVertexDistance, dimDistance) / (1.0f - exp(-1.0f)), 0.0f, 1.0f);
        return dimFog;
    } else { // overworld fog in classic linear fog mode -------------------------
        return linear_fog_value(sphericalVertexDistance, classicStart, classicEnd);
    }
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