package tr.com.aliok.flashcards;

import android.os.Bundle;
import com.phonegap.DroidGap;

public class MainActivity extends DroidGap {

    @Override
    public void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);

        super.setStringProperty("loadingDialog", "Loading,Please wait"); // show loading dialog

        super.init();

        //super.appView.clearCache(true);

        super.setIntegerProperty("splashscreen", R.drawable.splash); // load splash.jpg image from the resource drawable directory
        super.loadUrl("file:///android_asset/www/pages/index.html", 2000);
    }
}
