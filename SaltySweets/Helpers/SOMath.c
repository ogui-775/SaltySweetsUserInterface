// Created by Salty on 3/15/26.

#include "SOMath.h"

float CLAMP(float min, float actual, float max){
    if (actual < min)
        return min;
    else if (actual > max)
        return max;
    else
        return actual;
}

double ROUND_DP(double value, int decimal_places) {
    double factor = pow(10, decimal_places);
    return round(value * factor) / factor;
}
