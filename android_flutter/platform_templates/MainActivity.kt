package org.minsithu.nayyet

import android.content.ContentValues
import android.content.Intent
import android.os.Build
import android.provider.MediaStore
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    override fun configureFlutterEngine(engine: FlutterEngine) {
        super.configureFlutterEngine(engine)
        MethodChannel(engine.dartExecutor.binaryMessenger, "org.minsithu.nayyet/export")
            .setMethodCallHandler { call, result ->
                if (call.method != "saveQuote") { result.notImplemented(); return@setMethodCallHandler }
                if (Build.VERSION.SDK_INT < 29) { result.error("VERSION", "Android 10 or newer required", null); return@setMethodCallHandler }
                val bytes = call.argument<ByteArray>("bytes")
                if (bytes == null) { result.error("DATA", "PNG data missing", null); return@setMethodCallHandler }
                val values = ContentValues().apply {
                    put(MediaStore.Images.Media.DISPLAY_NAME, "nayyet-${System.currentTimeMillis()}.png")
                    put(MediaStore.Images.Media.MIME_TYPE, "image/png")
                    put(MediaStore.Images.Media.RELATIVE_PATH, "Pictures/NayYet")
                    put(MediaStore.Images.Media.IS_PENDING, 1)
                }
                val uri = contentResolver.insert(MediaStore.Images.Media.EXTERNAL_CONTENT_URI, values)
                if (uri == null) { result.error("SAVE", "Unable to create image", null); return@setMethodCallHandler }
                try {
                    val stream = contentResolver.openOutputStream(uri) ?: error("No output stream")
                    stream.use { it.write(bytes) }
                    contentResolver.update(uri, ContentValues().apply { put(MediaStore.Images.Media.IS_PENDING, 0) }, null, null)
                    if (call.argument<Boolean>("share") == true) {
                        val intent = Intent(Intent.ACTION_SEND).apply {
                            type = "image/png"
                            putExtra(Intent.EXTRA_STREAM, uri)
                            addFlags(Intent.FLAG_GRANT_READ_URI_PERMISSION)
                        }
                        startActivity(Intent.createChooser(intent, "NayYet"))
                    }
                    result.success(uri.toString())
                } catch (error: Exception) {
                    contentResolver.delete(uri, null, null)
                    result.error("SAVE", error.message, null)
                }
            }
    }
}
