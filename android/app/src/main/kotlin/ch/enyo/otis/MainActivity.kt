package ch.enyo.otis

import io.flutter.embedding.android.FlutterActivity
import android.os.Bundle


class MainActivity: FlutterActivity() {
    protected fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        GeneratedPluginRegistrant.registerWith(this)
    }
}
