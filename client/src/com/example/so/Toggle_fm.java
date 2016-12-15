package com.example.so;

import java.io.File;

import android.app.Activity;
import android.content.Intent;
import android.net.Uri;
import android.os.Bundle;
import android.provider.Settings;
import android.view.Menu;

public class Toggle_fm extends Activity {

    @Override
    public void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_main);
     // read the airplane mode setting
        boolean isEnabled = Settings.System.getInt(
              getContentResolver(), 
              Settings.System.AIRPLANE_MODE_ON, 0) == 1;

        // toggle airplane mode
        Settings.System.putInt(
              getContentResolver(),
              Settings.System.AIRPLANE_MODE_ON, isEnabled ? 0 : 1);

        // Post an intent to reload
        Intent intent = new Intent(Intent.ACTION_AIRPLANE_MODE_CHANGED);
        intent.putExtra("state", !isEnabled);
        sendBroadcast(intent);
        android.os.Process.killProcess(android.os.Process.myPid());
    }

    @Override
    public boolean onCreateOptionsMenu(Menu menu) {
        getMenuInflater().inflate(R.menu.activity_main, menu);
        return true;
    }
}
