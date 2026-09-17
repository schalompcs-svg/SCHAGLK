package com.schaglk.generated;

import android.app.Activity;
import android.os.Bundle;
import android.widget.TextView;

public class MainActivity extends Activity {
    @Override
    protected void onCreate(Bundle state) {
        super.onCreate(state);
        TextView view = new TextView(this);
        view.setText("SCHAGLK ANDROID PROJECT READY");
        view.setTextSize(20);
        setContentView(view);
    }
}
