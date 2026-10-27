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

float classic_fog_value(float vertexDistance, float density) {
    return 1.0f - exp(-density * vertexDistance);
}

float total_fog_value(float sphericalVertexDistance, float cylindricalVertexDistance, float environmentalStart, float environmentalEnd, float renderDistanceStart, float renderDistanceEnd) {
    float classicEnd = min(renderDistanceEnd, environmentalEnd);
    float classicStart = classicEnd * 0.25; // linear_fog_value(0.0, environmentalStart, environmentalEnd);
    // water fog
    float water_mixel = clamp((classicEnd - 24.0) / 72.0, 0.0, 1.0);
    float WaterFogDensity = mix(0.4, 0.1, water_mixel);
    float WaterEnvironmentalFogValue = classic_fog_value(sphericalVertexDistance, WaterFogDensity);
    // lava fog
    float lavaDensity = 2.0;
    float LavaEnvironmentalFogValue = 1.0f - exp(-lavaDensity * sphericalVertexDistance);
    // nether fog
    float NetherEnvironmentalFogValue = linear_fog_value(sphericalVertexDistance, 0.0, renderDistanceEnd);
    // the fog behaves like in Minecraft beta 1.6.6 and console editions, aside from Pocket Edtion 0.6.1 and below.
    // fog environmental overrides that are used for water, lava and nether fog and re-add the classic fog for all other cases
    if (environmentalStart == -8.0 && environmentalEnd <= 96.0) {
        // water fog
        return WaterEnvironmentalFogValue;
    }
    if (environmentalStart == 0.25 && environmentalEnd <= 1.0) {
        // lava fog
        return LavaEnvironmentalFogValue;
    }
    if (environmentalStart == 10.0 && environmentalEnd == 96.0) {
        // nether fog
        return NetherEnvironmentalFogValue;
    } else {
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