package com.ziggeo_rn.models;

import com.google.gson.annotations.SerializedName;

/**
 * Created by alex on 7/8/2017.
 */

public class ResponseModel {
    @SerializedName("video")
    private VideoModel video;

    public VideoModel getVideo() {
        return video;
    }

    public void setVideo(VideoModel video) {
        this.video = video;
    }
}
