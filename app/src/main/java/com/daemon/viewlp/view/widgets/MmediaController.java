package com.daemon.viewlp.view.widgets;


/**
 * author: zhaoqiang
 * date:2017/10/17 / 11:54
 * zhaoqiang:zhaoq_hero@163.com
 */

import android.app.Activity;
import android.content.Context;
import android.content.pm.ActivityInfo;
import android.media.AudioManager;
import android.os.Handler;
import android.os.Message;
import android.text.Html;
import android.view.GestureDetector;
import android.view.LayoutInflater;
import android.view.MotionEvent;
import android.view.View;
import android.view.ViewGroup;
import android.widget.ImageView;
import android.widget.LinearLayout;
import android.widget.MediaController;
import android.widget.RelativeLayout;
import android.widget.SeekBar;
import android.widget.TextView;

import com.daemon.viewlp.R;
import com.daemon.viewlp.utils.DensityUtil;
import com.daemon.viewlp.utils.MTimeUtils;


/**
 * 播放器  控制器：
 */
public class MmediaController {

    private final Activity activity;

    private View titleBar;
    private VideoView player;
    private View contentView;
    private View controllerView;


    private ImageView stop$play;
    private ImageView voiceSwitch;
    private ImageView requestOrien;
    private TextView timeProcess;

    private RelativeLayout playerParent;
    private SeekBar seekBar;

    public MmediaController(Activity mainActivity) {
        this.activity = mainActivity;
        initView();
    }

    /**
     * 初始化  控件
     */
    private void initView() {
        controllerView = LayoutInflater.from(activity).inflate(R.layout.include_play_control, null, false);
        requestOrien = controllerView.findViewById(R.id.request_orien);
        stop$play = controllerView.findViewById(R.id.stop$play);
        voiceSwitch = controllerView.findViewById(R.id.voice);
        timeProcess = controllerView.findViewById(R.id.timeProcess);
        seekBar = controllerView.findViewById(R.id.timeline);
    }

    public MmediaController setTitleBar(View titleBar) {
        this.titleBar = titleBar;
        return this;
    }

    public MmediaController setPlayer(VideoView player) {
        this.player = player;
        return this;
    }

    public MmediaController setContentView(View contentView) {
        this.contentView = contentView;
        return this;
    }

    public MmediaController setPlayerParent(RelativeLayout playerParent) {
        this.playerParent = playerParent;
        return this;
    }

    public MmediaController build() {

        initListener();

        RelativeLayout.LayoutParams layoutParams = new RelativeLayout.LayoutParams(ViewGroup.LayoutParams.MATCH_PARENT,
                ViewGroup.LayoutParams.WRAP_CONTENT);
        layoutParams.addRule(RelativeLayout.ALIGN_BOTTOM, player.getId());
        controllerView.setLayoutParams(layoutParams);
        playerParent.addView(controllerView);

        controllerView.setVisibility(View.GONE);

        return this;
    }

    private void initListener() {

        //暂停 和播放：
        stop$play.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View view) {
                //暂停 和播放：
                boolean tag = stop$play.getTag() == null ? false : (boolean) view.getTag();
                if (player.isPlaying()) {
                    player.pause();
                    stop$play.setImageResource(R.mipmap.play_small);
                } else {
                    player.start();
                    stop$play.setImageResource(R.mipmap.stop_small);
                }
                stop$play.setTag(!tag);
            }
        });

        //声音开关
        voiceSwitch.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View view) {
                boolean tag = voiceSwitch.getTag() == null ? false : (boolean) voiceSwitch.getTag();
                voiceSwitch.setImageResource(!tag ? R.mipmap.slience : R.mipmap.icon_voice_val);
                voiceSwitch.setTag(!tag);

                AudioManager audioManager = (AudioManager) activity.getSystemService(Context.AUDIO_SERVICE);
                audioManager.setStreamVolume(AudioManager.STREAM_MUSIC, !tag ? 0 : 5, 0);
            }
        });

        //横竖屏    切换：
        requestOrien.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View view) {
                boolean tag = requestOrien.getTag() == null ? false : (boolean) requestOrien.getTag();
                activity.setRequestedOrientation(!tag ? ActivityInfo.SCREEN_ORIENTATION_LANDSCAPE : ActivityInfo.SCREEN_ORIENTATION_PORTRAIT);
                requestOrien.setTag(!tag);
            }
        });

        seekBar.setOnSeekBarChangeListener(new SeekBar.OnSeekBarChangeListener() {

            boolean isTouch = false;

            @Override
            public void onProgressChanged(SeekBar seekBar, int precent, boolean b) {
                if (isTouch){
                    //计算  拖拉后的  时间长度：
                    int positionLong = player.getDuration() * seekBar.getProgress() / 100;
                    player.seekTo(positionLong);
                }
            }

            @Override
            public void onStartTrackingTouch(SeekBar seekBar) {
                mHandler.removeMessages(0);
                isTouch = true;
                player.pause();
                stop$play.setImageResource(R.mipmap.play_small);
            }

            @Override
            public void onStopTrackingTouch(SeekBar seekBar) {
                if (controllerView.getVisibility() == View.VISIBLE) {
                    if (mHandler != null) {
                        mHandler.sendEmptyMessageDelayed(0, 4000);
                    }
                }
                isTouch = false;
                player.start();
                stop$play.setImageResource(R.mipmap.stop_small);
            }
        });

        player.setOnPlayingListener(new VideoView.OnPlayingListener() {
            @Override
            public void onPlaying() {
                int current = player.getCurrentPosition();
                int duration = player.getDuration();
                timeProcess.setText(Html.fromHtml(MTimeUtils.formatTime(current) +
                        "<font color = '#ddf'>" + "/" + MTimeUtils.formatTime(duration) + "</font>"));
                seekBar.setProgress(current * 100 / duration);
            }
        });

        //添加  控制器的显示和隐藏:
        player.setOnTouchListener(new View.OnTouchListener() {
            @Override
            public boolean onTouch(View view, MotionEvent motionEvent) {
                mGesde.onTouchEvent(motionEvent);
                return true;
            }
        });
    }

    public void switchOrientation(boolean tag) {
        int width = DensityUtil.getWh(activity)[0];

        int height = tag ? DensityUtil.dip2px(activity, 200) : DensityUtil.getWh(activity)[1];
        RelativeLayout.LayoutParams params1 = new RelativeLayout.LayoutParams(width, height);
        LinearLayout.LayoutParams params2 = new LinearLayout.LayoutParams(width, height);
        player.setLayoutParams(params1);
        playerParent.setLayoutParams(params2);

        titleBar.setVisibility(tag ? View.VISIBLE : View.GONE);
        contentView.setVisibility(tag ? View.VISIBLE : View.GONE);

        requestOrien.setImageResource(tag ? R.mipmap.full_screen : R.mipmap.no_full_screen);
    }

    private GestureDetector mGesde = new GestureDetector(new MSimpleGestureDectListener());

    Handler mHandler = new Handler() {
        @Override
        public void handleMessage(Message msg) {
            super.handleMessage(msg);
            controllerView.setVisibility(View.GONE);
        }
    };

    //手势处理
    private class MSimpleGestureDectListener extends GestureDetector.SimpleOnGestureListener {

        @Override
        public boolean onSingleTapConfirmed(MotionEvent e) {
            //判断
            if (controllerView.getVisibility() == View.VISIBLE) {
                controllerView.setVisibility(View.GONE);
            } else {
                controllerView.setVisibility(View.VISIBLE);
            }

            //定时   关闭控制器
            if (controllerView.getVisibility() == View.VISIBLE) {
                if (mHandler != null) {
                    mHandler.removeMessages(0);
                    mHandler.sendEmptyMessageDelayed(0, 4000);
                }
            }
            return true;
        }

    }
}
