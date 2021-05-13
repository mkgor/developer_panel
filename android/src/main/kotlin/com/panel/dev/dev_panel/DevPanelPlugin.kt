package com.panel.dev.dev_panel

import android.os.Debug
import android.os.Environment
import android.os.StatFs
import androidx.annotation.NonNull
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import java.io.*


/** DevPanelPlugin */
class DevPanelPlugin: FlutterPlugin, MethodCallHandler {
  /// The MethodChannel that will the communication between Flutter and native Android
  ///
  /// This local reference serves to register the plugin with the Flutter Engine and unregister it
  /// when the Flutter Engine is detached from the Activity
  private lateinit var channel : MethodChannel

  override fun onAttachedToEngine(@NonNull flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
    channel = MethodChannel(flutterPluginBinding.binaryMessenger, "dev_panel")
    channel.setMethodCallHandler(this)
  }

  override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
     if (call.method == "getPerformance") {
      try {
        val p = Runtime.getRuntime().exec("top -n 1")
        val returnString: String = p.inputStream.bufferedReader().use(BufferedReader::readText)

        val pidRegex = Regex("${android.os.Process.myPid()}.*");
        val memoryRegex = Regex("Mem:\\s+(\\d+)");

        val myPidLine = pidRegex.find(returnString)?.value?.replace(Regex("""\s+"""), " ");
        val memoryLine = memoryRegex.find(returnString)?.groups?.get(1)?.value

//
//        tempString = tempString!!.replace(",".toRegex(), "")
//        tempString = tempString.replace("User".toRegex(), "")
//        tempString = tempString.replace("System".toRegex(), "")
//        tempString = tempString.replace("IOW".toRegex(), "")
//        tempString = tempString.replace("IRQ".toRegex(), "")
//        tempString = tempString.replace("%".toRegex(), "")
//        for (i in 0..9) {
//          tempString = tempString!!.replace("  ".toRegex(), " ")
//        }
//        tempString = tempString!!.trim { it <= ' ' }
//        val myString = tempString.split(" ").toTypedArray()
//        val cpuUsageAsInt = IntArray(myString.size)
//        for (i in myString.indices) {
//          myString[i] = myString[i].trim { it <= ' ' }
//          cpuUsageAsInt[i] = myString[i].toInt()
//        }

        result.success("${memoryLine};${myPidLine}")
      } catch (e: FileNotFoundException) {
        println("Can't read proc/stat")
      } catch (e: IOException) {
        println("Ran into problems reading /proc/stat...")
      }
    } else if (call.method == "getDiskUsage") {
      val stat = StatFs(Environment.getExternalStorageDirectory().path)
      val bytesAvailable = stat.availableBlocks.toLong()
      val totalBytes = stat.blockCount.toLong()

      val usedDiskSpaceInPercentage = bytesAvailable * 100 / totalBytes

      result.success(usedDiskSpaceInPercentage.toInt())
    } else {
      result.notImplemented()
    }
  }

  override fun onDetachedFromEngine(@NonNull binding: FlutterPlugin.FlutterPluginBinding) {
    channel.setMethodCallHandler(null)
  }
}
