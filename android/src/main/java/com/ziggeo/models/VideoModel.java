package com.ziggeo.models;

import com.google.gson.annotations.SerializedName;

/**
 * Created by alex on 7/9/2017.
 */

public class VideoModel {
    @SerializedName("token")
    private String token;

    public String getToken() {
        return token;
    }

    public void setToken(String token) {
        this.token = token;
    }
}
