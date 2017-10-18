package com.daemon.viewlp;

import android.annotation.SuppressLint;
import android.content.pm.ActivityInfo;
import android.content.res.Configuration;
import android.graphics.SurfaceTexture;
import android.media.MediaPlayer;
import android.os.Bundle;
import android.os.Handler;
import android.util.Log;
import android.view.Display;
import android.view.TextureView;
import android.view.View;
import android.view.ViewGroup;
import android.view.WindowManager;
import android.widget.FrameLayout;
import android.widget.MediaController;
import android.widget.RelativeLayout;
import android.widget.Toast;

import com.daemon.viewlp.utils.DensityUtil;
import com.daemon.viewlp.view.activitys.BaseActivity;
import com.daemon.viewlp.view.widgets.MmediaController;
import com.daemon.viewlp.view.widgets.VideoView;

public class MainActivity extends BaseActivity {

    private VideoView player;

    private View contentView;
    private View titleView;
    private RelativeLayout playerParent;

    private MmediaController mmediaController;

    @Override
    protected int getRecrouse() {
        return R.layout.activity_main;
    }

    @Override
    protected void initView() {
        player = (VideoView) findViewById(R.id.paly_video);
        contentView = findViewById(R.id.contentView);
        titleView = findViewById(R.id.title_view);
        playerParent = (RelativeLayout) findViewById(R.id.player_parent);

        player.setVideoPath("android.resource://" + getPackageName() + "/" + R.raw.land);
        player.start();

        mmediaController = new MmediaController(this)
                .setTitleBar(titleView)
                .setPlayerParent(playerParent)
                .setPlayer(player)
                .setContentView(contentView)
                .build();
    }

    @SuppressLint("NewApi")
    @Override
    public void onConfigurationChanged(Configuration newConfig) {
        super.onConfigurationChanged(newConfig);
        boolean tag = getRequestedOrientation() == ActivityInfo.SCREEN_ORIENTATION_LANDSCAPE ? false : true;
        mmediaController.switchOrientation(tag);
        fullScreen(!tag ? true : false);
    }

    @Override
    public void onBackPressed() {
        if (getRequestedOrientation() == ActivityInfo.SCREEN_ORIENTATION_LANDSCAPE) {
            setRequestedOrientation(ActivityInfo.SCREEN_ORIENTATION_PORTRAIT);
            return;
        } else {
            super.onBackPressed();
        }
    }
}
