



##1，先上效果图：
![这里写图片描述](http://img.blog.csdn.net/20171018143725146?watermark/2/text/aHR0cDovL2Jsb2cuY3Nkbi5uZXQvdTAxMzIzMzA5Nw==/font/5a6L5L2T/fontsize/400/fill/I0JBQkFCMA==/dissolve/70/gravity/SouthEast)



##2，介绍：
播放控件使用Android自带的  VideoView 控件。控制器为自定义View以及控制器：  主要代码：

主界面  分为 三个部分：  头部   底部     播放器部分：

```
<?xml version="1.0" encoding="utf-8"?>
<LinearLayout xmlns:android="http://schemas.android.com/apk/res/android"
    xmlns:app="http://schemas.android.com/apk/res-auto"
    xmlns:tools="http://schemas.android.com/tools"
    android:layout_width="match_parent"
    android:layout_height="match_parent"
    android:orientation="vertical"
    tools:context="com.daemon.viewlp.MainActivity">

    <include
        android:id="@+id/title_view"
        layout="@layout/include_title_bar" />

    <RelativeLayout
        android:id="@+id/player_parent"
        android:layout_width="wrap_content"
        android:layout_height="wrap_content"
        android:background="#000000"
        android:gravity="center_vertical"
        android:paddingBottom="2dp"
        android:paddingTop="2dp">

        <com.daemon.viewlp.view.widgets.VideoView
            android:id="@+id/paly_video"
            android:layout_width="fill_parent"
            android:layout_height="200dp"
            />
    </RelativeLayout>

    <LinearLayout
        android:id="@+id/contentView"
        android:layout_width="match_parent"
        android:layout_height="0dp"
        android:layout_weight="1"
        android:background="#ddf"
        >

        <TextView
            android:layout_width="match_parent"
            android:layout_height="match_parent"
            android:gravity="center"
            android:text="otherContent" />
    </LinearLayout>

</LinearLayout>

```

博主的横竖屏适配   通过点击事件  请求横竖屏，横屏时隐藏掉头部底部，设置播放器布局参数为填充整个屏幕，竖屏时恢复原状。

自己封装了个    player 器 管理类  MmediaController：

```
package com.daemon.viewlp.view.widgets;


/**
 * author: zhaoqiang
 * date:2017/10/17 / 11:54
 * zhaoqiang:zhaoq_hero@163.com
 */

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

```


主界面   初始化  播放器控制器：

```
mmediaController = new MmediaController(this)
                .setTitleBar(titleView)
                .setPlayerParent(playerParent)
                .setPlayer(player)
                .setContentView(contentView)
                .build();

//下面是   横竖屏  切换
 @SuppressLint("NewApi")
    @Override
    public void onConfigurationChanged(Configuration newConfig) {
        super.onConfigurationChanged(newConfig);
        boolean tag = getRequestedOrientation() == ActivityInfo.SCREEN_ORIENTATION_LANDSCAPE ? false : true;
        mmediaController.switchOrientation(tag);
        fullScreen(!tag ? true : false);
    }

```

####  横竖屏切换再配置文件添加代码：

```
android:configChanges="orientation|keyboardHidden|screenSize"
            android:label="@string/app_name">
```

以及  添加权限：

```
<uses-permission android:name="android.permission.WRITE_EXTERNAL_STORAGE" />
    <uses-permission android:name="android.permission.READ_PHONE_STATE" />
    <uses-permission android:name="android.permission.READ_EXTERNAL_STORAGE" />
```



简单实现播放器播放，不过博主的  进度条在拖动时    有些卡顿，有解决的朋友希望可以说下。


需要源码的  同学请移步github    或者csdn ：

github:https://github.com/229457269/videoPlayDemo

csdn:http://blog.csdn.net/u013233097/article/details/78272831


#欢迎   fork 和 star.











#-----------华丽的分割线-----------------下面是VideoView 源码：-------------------------------------------

package com.daemon.viewlp.view.widgets;

import java.io.IOException;

import android.annotation.SuppressLint;
import android.content.Context;
import android.content.Intent;
import android.graphics.SurfaceTexture;
import android.media.AudioManager;
import android.media.MediaPlayer;
import android.media.MediaPlayer.OnCompletionListener;
import android.media.MediaPlayer.OnErrorListener;
import android.media.MediaPlayer.OnInfoListener;
import android.net.Uri;
import android.util.AttributeSet;
import android.util.Log;
import android.view.KeyEvent;
import android.view.MotionEvent;
import android.view.Surface;
import android.view.TextureView;
import android.view.View;
import android.widget.MediaController;
import android.widget.MediaController.MediaPlayerControl;


/**
 * VideoView1 is used to play video, just like
 * {@link android.widget.VideoView VideoView1}. We define a custom view, because
 * we could not use {@link android.widget.VideoView VideoView1} in ListView. <br/>
 * VideoViews inside ScrollViews do not scroll properly. Even if you use the
 * workaround to set the background color, the MediaController2 does not scroll
 * along with the VideoView1. Also, the scrolling video looks horrendous with the
 * workaround, lots of flickering.
 */
@SuppressLint("NewApi")
public class VideoView extends TextureView implements MediaPlayerControl {

    private static final String TAG = "info";

    // all possible internal states
    private static final int STATE_ERROR = -1;
    private static final int STATE_IDLE = 0;
    private static final int STATE_PREPARING = 1;
    private static final int STATE_PREPARED = 2;
    private static final int STATE_PLAYING = 3;
    private static final int STATE_PAUSED = 4;
    private static final int STATE_PLAYBACK_COMPLETED = 5;

    // currentState is a VideoView1 object's current state.
    // targetState is the state that a method caller intends to reach.
    // For instance, regardless the VideoView1 object's current state,
    // calling pause() intends to bring the object to a target state
    // of STATE_PAUSED.
    private int mCurrentState = STATE_IDLE;
    private int mTargetState = STATE_IDLE;

    // Stuff we need for playing and showing a video
    private MediaPlayer mMediaPlayer;
    private int mVideoWidth;
    private int mVideoHeight;
    private int mSurfaceWidth;
    private int mSurfaceHeight;
    private SurfaceTexture mSurfaceTexture;
    private Surface mSurface;
    private MediaController mMediaController;
    private MediaPlayer.OnCompletionListener mOnCompletionListener;
    private MediaPlayer.OnPreparedListener mOnPreparedListener;

    private MediaPlayer.OnErrorListener mOnErrorListener;
    private MediaPlayer.OnInfoListener mOnInfoListener;

    private int mSeekWhenPrepared; // recording the seek position while
    // preparing
    private int mCurrentBufferPercentage;
    private int mAudioSession;
    private Uri mUri;

    private Context mContext;

    public VideoView(final Context context) {
        super(context);
        mContext = context;
        initVideoView();
    }

    public VideoView(final Context context, final AttributeSet attrs) {
        super(context, attrs);
        mContext = context;
        initVideoView();
    }

    public VideoView(Context context, AttributeSet attrs, int defStyle) {
        super(context, attrs, defStyle);
        mContext = context;
        initVideoView();
    }

    public void initVideoView() {
        mVideoHeight = 0;
        mVideoWidth = 0;
//        setBackgroundColor(getResources().getColor(android.R.color.transparent));
        setFocusable(false);
        setSurfaceTextureListener(mSurfaceTextureListener);
    }

    public int resolveAdjustedSize(int desiredSize, int measureSpec) {
        int result = desiredSize;
        int specMode = MeasureSpec.getMode(measureSpec);
        int specSize = MeasureSpec.getSize(measureSpec);

        switch (specMode) {
            case MeasureSpec.UNSPECIFIED:
            /*
             * Parent says we can be as big as we want. Just don't be larger
			 * than max size imposed on ourselves.
			 */
                result = desiredSize;
                break;

            case MeasureSpec.AT_MOST:
            /*
			 * Parent says we can be as big as we want, up to specSize. Don't be
			 * larger than specSize, and don't be larger than the max size
			 * imposed on ourselves.
			 */
                result = Math.min(desiredSize, specSize);
                break;

            case MeasureSpec.EXACTLY:
                // No choice. Do what we are told.
                result = specSize;
                break;
        }
        return result;
    }

    public void setVideoPath(String path) {
        Log.d(TAG, "Setting video path to: " + path);
        setVideoURI(Uri.parse(path));
    }

    public void setVideoURI(Uri _videoURI) {
        mUri = _videoURI;
        mSeekWhenPrepared = 0;
        requestLayout();
        invalidate();
        openVideo();
    }

    public Uri getUri() {
        return mUri;
    }

    public void setSurfaceTexture(SurfaceTexture _surfaceTexture) {
        mSurfaceTexture = _surfaceTexture;
    }

    public void openVideo() {
        if ((mUri == null) || (mSurfaceTexture == null)) {
            Log.d(TAG, "Cannot open video, uri or surface texture is null.");
            return;
        }
        // Tell the music playback service to pause
        // TODO: these constants need to be published somewhere in the
        // framework.
        Intent i = new Intent("com.android.music.musicservicecommand");
        i.putExtra("command", "pause");
        mContext.sendBroadcast(i);
        release(false);
        try {
            mSurface = new Surface(mSurfaceTexture);
            mMediaPlayer = new MediaPlayer();
            if (mAudioSession != 0) {
                mMediaPlayer.setAudioSessionId(mAudioSession);
            } else {
                mAudioSession = mMediaPlayer.getAudioSessionId();
            }

            mMediaPlayer.setOnBufferingUpdateListener(mBufferingUpdateListener);
            mMediaPlayer.setOnCompletionListener(mCompleteListener);
            mMediaPlayer.setOnPreparedListener(mPreparedListener);
            mMediaPlayer.setOnErrorListener(mErrorListener);
            mMediaPlayer.setOnInfoListener(mOnInfoListener);
            mMediaPlayer.setOnVideoSizeChangedListener(mVideoSizeChangedListener);

            mMediaPlayer.setSurface(mSurface);
            mCurrentBufferPercentage = 0;
            mMediaPlayer.setDataSource(mContext, mUri);

            mMediaPlayer.setAudioStreamType(AudioManager.STREAM_MUSIC);
            mMediaPlayer.setScreenOnWhilePlaying(true);

            mMediaPlayer.prepareAsync();
            mCurrentState = STATE_PREPARING;
        } catch (IllegalStateException e) {
            mCurrentState = STATE_ERROR;
            mTargetState = STATE_ERROR;
            Log.d(TAG, e.getMessage()); // TODO auto-generated catch block
        } catch (IOException e) {
            mCurrentState = STATE_ERROR;
            mTargetState = STATE_ERROR;
            Log.d(TAG, e.getMessage()); // TODO auto-generated catch block
        }
    }

    public void stopPlayback() {
        if (mMediaPlayer != null) {
            mMediaPlayer.stop();
            mMediaPlayer.release();
            mMediaPlayer = null;
            if (null != mMediaControllListener) {
                mMediaControllListener.onStop();
            }
        }
    }

    public void setMediaController(MediaController controller) {
        if (mMediaController != null) {
            mMediaController.hide();
        }
        mMediaController = controller;
        attachMediaController();
    }

    private void attachMediaController() {
        if (mMediaPlayer != null && mMediaController != null) {
            mMediaController.setMediaPlayer(this);
            View anchorView = this.getParent() instanceof View ? (View) this.getParent() : this;
            mMediaController.setAnchorView(anchorView);
            mMediaController.setEnabled(isInPlaybackState());
        }
    }

    private void release(boolean cleartargetstate) {
        Log.d(TAG, "Releasing media player.");
        if (mMediaPlayer != null) {
            mMediaPlayer.reset();
            mMediaPlayer.release();
            mMediaPlayer = null;
            mCurrentState = STATE_IDLE;
            if (cleartargetstate) {
                mTargetState = STATE_IDLE;
            }
        } else {
            Log.d(TAG, "Media player was null, did not release.");
        }
    }

    @Override
    protected void onMeasure(final int widthMeasureSpec, final int heightMeasureSpec) {
        // Will resize the view if the video dimensions have been found.
        // video dimensions are found after onPrepared has been called by
        // MediaPlayer
        int width = getDefaultSize(mVideoWidth, widthMeasureSpec);
        int height = getDefaultSize(mVideoHeight, heightMeasureSpec);
		/*if ((mVideoWidth > 0) && (mVideoHeight > 0)) {
			if ((mVideoWidth * height) > (width * mVideoHeight)) {
				Log.d(TAG, "Video too tall, change size.");
				height = (width * mVideoHeight) / mVideoWidth;
			} else if ((mVideoWidth * height) < (width * mVideoHeight)) {
				Log.d(TAG, "Video too wide, change size.");
				width = (height * mVideoWidth) / mVideoHeight;
			} else {
				Log.d(TAG, "Aspect ratio is correct.");
			}
		}*/
        setMeasuredDimension(width, height);
    }

    @Override
    public boolean onTouchEvent(MotionEvent ev) {
        if (isInPlaybackState() && mMediaController != null) {
            toggleMediaControlsVisiblity();
        }
        return false;
    }

    @Override
    public boolean onTrackballEvent(MotionEvent ev) {
        if (isInPlaybackState() && mMediaController != null) {
            toggleMediaControlsVisiblity();
        }
        return false;
    }

    @Override
    public boolean onKeyDown(int keyCode, KeyEvent event) {
        boolean isKeyCodeSupported = keyCode != KeyEvent.KEYCODE_BACK && keyCode != KeyEvent.KEYCODE_VOLUME_UP && keyCode != KeyEvent.KEYCODE_VOLUME_DOWN
                && keyCode != KeyEvent.KEYCODE_VOLUME_MUTE && keyCode != KeyEvent.KEYCODE_MENU && keyCode != KeyEvent.KEYCODE_CALL
                && keyCode != KeyEvent.KEYCODE_ENDCALL;
        if (isInPlaybackState() && isKeyCodeSupported && mMediaController != null) {
            if (keyCode == KeyEvent.KEYCODE_HEADSETHOOK || keyCode == KeyEvent.KEYCODE_MEDIA_PLAY_PAUSE) {
                if (mMediaPlayer.isPlaying()) {
                    pause();
                    mMediaController.show();
                } else {
                    start();
                    mMediaController.hide();
                }
                return true;
            } else if (keyCode == KeyEvent.KEYCODE_MEDIA_PLAY) {
                if (!mMediaPlayer.isPlaying()) {
                    start();
                    mMediaController.hide();
                }
                return true;
            } else if (keyCode == KeyEvent.KEYCODE_MEDIA_STOP || keyCode == KeyEvent.KEYCODE_MEDIA_PAUSE) {
                if (mMediaPlayer.isPlaying()) {
                    pause();
                    mMediaController.show();
                }
                return true;
            } else {
                toggleMediaControlsVisiblity();
            }
        }

        return super.onKeyDown(keyCode, event);
    }

    private void toggleMediaControlsVisiblity() {
        if (mMediaController.isShowing()) {
            mMediaController.hide();
        } else {
            mMediaController.show();
        }
    }

    public void start() {
        // This can potentially be called at several points, it will go through
        // when all conditions are ready
        // 1. When setting the video URI
        // 2. When the surface becomes available
        // 3. From the activity
        if (isInPlaybackState()) {
            mMediaPlayer.start();
            mCurrentState = STATE_PLAYING;
            if (null != mMediaControllListener) {
                mMediaControllListener.onStart();
            }
        } else {
            Log.d(TAG, "Could not start. Current state " + mCurrentState);
        }
        mTargetState = STATE_PLAYING;
    }

    public void pause() {
        if (isInPlaybackState()) {
            if (mMediaPlayer.isPlaying()) {
                mMediaPlayer.pause();
                mCurrentState = STATE_PAUSED;
                if (null != mMediaControllListener) {
                    mMediaControllListener.onPause();
                }
            }
        }
        mTargetState = STATE_PAUSED;
    }

    public void suspend() {
        release(false);
    }

    public void resume() {
        openVideo();
    }

    @Override
    public int getDuration() {
        if (isInPlaybackState()) {
            return mMediaPlayer.getDuration();
        }
        return -1;
    }

    @Override
    public int getCurrentPosition() {
        if (isInPlaybackState()) {
            return mMediaPlayer.getCurrentPosition();
        }
        return 0;
    }

    @Override
    public void seekTo(int msec) {
        if (isInPlaybackState()) {
            mMediaPlayer.seekTo(msec);
            mSeekWhenPrepared = 0;
        } else {
            mSeekWhenPrepared = msec;
        }
    }

    @Override
    public boolean isPlaying() {
        return isInPlaybackState() && mMediaPlayer.isPlaying();
    }

    @Override
    public int getBufferPercentage() {
        if (mMediaPlayer != null) {
            return mCurrentBufferPercentage;
        }
        return 0;
    }

    private boolean isInPlaybackState() {
        return ((mMediaPlayer != null) && (mCurrentState != STATE_ERROR) && (mCurrentState != STATE_IDLE) && (mCurrentState != STATE_PREPARING));
    }

    @Override
    public boolean canPause() {
        return false;
    }

    @Override
    public boolean canSeekBackward() {
        return false;
    }

    @Override
    public boolean canSeekForward() {
        return false;
    }

    @Override
    public int getAudioSessionId() {
        if (mAudioSession == 0) {
            MediaPlayer foo = new MediaPlayer();
            mAudioSession = foo.getAudioSessionId();
            foo.release();
        }
        return mAudioSession;
    }

    // Listeners
    private MediaPlayer.OnBufferingUpdateListener mBufferingUpdateListener = new MediaPlayer.OnBufferingUpdateListener() {
        @Override
        public void onBufferingUpdate(final MediaPlayer mp, final int percent) {
            mCurrentBufferPercentage = percent;

            Log.d("info", "----------" + percent);
        }
    };

    private MediaPlayer.OnCompletionListener mCompleteListener = new MediaPlayer.OnCompletionListener() {
        @Override
        public void onCompletion(final MediaPlayer mp) {
            mCurrentState = STATE_PLAYBACK_COMPLETED;
            mTargetState = STATE_PLAYBACK_COMPLETED;
            mSurface.release();

            if (mMediaController != null) {
                mMediaController.hide();
            }

            if (mOnCompletionListener != null) {
                mOnCompletionListener.onCompletion(mp);
            }

            if (mMediaControllListener != null) {
                mMediaControllListener.onComplete();
            }
        }
    };

    private MediaPlayer.OnPreparedListener mPreparedListener = new MediaPlayer.OnPreparedListener() {
        @Override
        public void onPrepared(final MediaPlayer mp) {
            mCurrentState = STATE_PREPARED;

            if (mOnPreparedListener != null) {
                mOnPreparedListener.onPrepared(mMediaPlayer);
            }
            if (mMediaController != null) {
                mMediaController.setEnabled(true);
            }

            mVideoWidth = mp.getVideoWidth();
            mVideoHeight = mp.getVideoHeight();

            int seekToPosition = mSeekWhenPrepared; // mSeekWhenPrepared may be
            // changed after seekTo()
            // call
            if (seekToPosition != 0) {
                seekTo(seekToPosition);
            }

            requestLayout();
            invalidate();
            if ((mVideoWidth != 0) && (mVideoHeight != 0)) {
                if (mTargetState == STATE_PLAYING) {
                    mMediaPlayer.start();
                    if (null != mMediaControllListener) {
                        mMediaControllListener.onStart();
                    }
                }
            } else {
                if (mTargetState == STATE_PLAYING) {
                    mMediaPlayer.start();
                    if (null != mMediaControllListener) {
                        mMediaControllListener.onStart();
                    }
                }
            }
        }
    };

    private MediaPlayer.OnVideoSizeChangedListener mVideoSizeChangedListener = new MediaPlayer.OnVideoSizeChangedListener() {
        @Override
        public void onVideoSizeChanged(final MediaPlayer mp, final int width, final int height) {
            mVideoWidth = mp.getVideoWidth();
            mVideoHeight = mp.getVideoHeight();
            if (mVideoWidth != 0 && mVideoHeight != 0) {
                requestLayout();
            }

        }
    };

    private MediaPlayer.OnErrorListener mErrorListener = new MediaPlayer.OnErrorListener() {
        @Override
        public boolean onError(final MediaPlayer mp, final int what, final int extra) {
            Log.d(TAG, "Error: " + what + "," + extra);
            mCurrentState = STATE_ERROR;
            mTargetState = STATE_ERROR;

            if (mMediaController != null) {
                mMediaController.hide();
            }

			/* If an error handler has been supplied, use it and finish. */
            if (mOnErrorListener != null) {
                if (mOnErrorListener.onError(mMediaPlayer, what, extra)) {
                    return true;
                }
            }

			/*
			 * Otherwise, pop up an error dialog so the user knows that
			 * something bad has happened. Only try and pop up the dialog if
			 * we're attached to a window. When we're going away and no longer
			 * have a window, don't bother showing the user an error.
			 */
            if (getWindowToken() != null) {
            }
            return true;
        }
    };

    SurfaceTextureListener mSurfaceTextureListener = new SurfaceTextureListener() {
        @Override
        public void onSurfaceTextureAvailable(final SurfaceTexture surface, final int width, final int height) {
            Log.d(TAG, "onSurfaceTextureAvailable.");
            mSurfaceTexture = surface;
            openVideo();
        }

        @Override
        public void onSurfaceTextureSizeChanged(final SurfaceTexture surface, final int width, final int height) {
            Log.d(TAG, "onSurfaceTextureSizeChanged: " + width + '/' + height);
            mSurfaceWidth = width;
            mSurfaceHeight = height;
            boolean isValidState = (mTargetState == STATE_PLAYING);
            boolean hasValidSize = (mVideoWidth == width && mVideoHeight == height);
            if (mMediaPlayer != null && isValidState && hasValidSize) {
                if (mSeekWhenPrepared != 0) {
                    seekTo(mSeekWhenPrepared);
                }
                start();
            }
        }

        @Override
        public boolean onSurfaceTextureDestroyed(final SurfaceTexture surface) {

            mSurface = null;
            if (mMediaController != null)
                mMediaController.hide();
            release(true);
            return true;
        }

        @Override
        public void onSurfaceTextureUpdated(final SurfaceTexture surface) {
            if (playingListener != null) playingListener.onPlaying();
        }
    };

    /**
     * Register a callback to be invoked when the media file is loaded and ready
     * to go.
     *
     * @param l The callback that will be run
     */
    public void setOnPreparedListener(MediaPlayer.OnPreparedListener l) {
        mOnPreparedListener = l;
    }

    /**
     * Register a callback to be invoked when the end of a media file has been
     * reached during playback.
     *
     * @param l The callback that will be run
     */
    public void setOnCompletionListener(OnCompletionListener l) {
        mOnCompletionListener = l;
    }

    /**
     * Register a callback to be invoked when an error occurs during playback or
     * setup. If no listener is specified, or if the listener returned false,
     * VideoView1 will inform the user of any errors.
     *
     * @param l The callback that will be run
     */
    public void setOnErrorListener(OnErrorListener l) {
        mOnErrorListener = l;
    }

    /**
     * Register a callback to be invoked when an informational event occurs
     * during playback or setup.
     *
     * @param l The callback that will be run
     */
    public void setOnInfoListener(OnInfoListener l) {
        mOnInfoListener = l;
    }

    public void setOnPlayingListener(OnPlayingListener onPlayingListener) {
        this.playingListener = onPlayingListener;
    }

    public static interface MediaControllListener {
        public void onStart();

        public void onPause();

        public void onStop();

        public void onComplete();
    }

    MediaControllListener mMediaControllListener;

    public void setMediaControllListener(MediaControllListener mediaControllListener) {
        mMediaControllListener = mediaControllListener;
    }

    @Override
    public void setVisibility(int visibility) {
        System.out.println("setVisibility: " + visibility);
        super.setVisibility(visibility);
    }

    OnPlayingListener playingListener;

    public interface OnPlayingListener {
        void onPlaying();
    }
}
