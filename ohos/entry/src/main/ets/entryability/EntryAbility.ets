import { FlutterAbility, FlutterEngine, MethodCall, MethodChannel, MethodResult } from '@ohos/flutter_ohos';
import { GeneratedPluginRegistrant } from '../plugins/GeneratedPluginRegistrant';
import { init, invoke } from 'librust.so'
import { hilog } from '@kit.PerformanceAnalysisKit';
import { fileIo as fs, ReadOptions } from '@kit.CoreFileKit'
import { notificationManager } from '@kit.NotificationKit';

const DOWNLOAD_NOTIFICATION_ID = 1001;

export default class EntryAbility extends FlutterAbility {
  configureFlutterEngine(flutterEngine: FlutterEngine) {

    this.printDir();

    init(this.context.filesDir)

    new MethodChannel(flutterEngine.dartExecutor.getBinaryMessenger(), "methods")
      .setMethodCallHandler(this)

    super.configureFlutterEngine(flutterEngine)
    GeneratedPluginRegistrant.registerWith(flutterEngine)
  }

  async printDir(){
    hilog.warn(0, 'configureFlutterEngine', '%{public}s', "===============");
    hilog.warn(0, 'configureFlutterEngine', '%{public}s', "dir : " + this.context.filesDir);
    let files = await fs.listFile(this.context.filesDir)
    for (let filesElement of files) {
      hilog.warn(0, 'configureFlutterEngine', '%{public}s', "file : " + filesElement);
    }
  }

  onMethodCall(call: MethodCall, result: MethodResult): void {
    hilog.warn(0, 'onMethodCall', '%{public}s', call.method);
    hilog.warn(0, 'onMethodCall', '%{public}s', call.args);
    switch (call.method) {
      case 'invoke':
        invoke(call.args).then((invokeResult) => {
          result.success(invokeResult)
        })
        break;
      case 'showDownloadNotification':
        this.showDownloadNotification(call, result)
        break;
      case 'cancelDownloadNotification':
        this.cancelDownloadNotification(result)
        break;
    }
  }

  private showDownloadNotification(call: MethodCall, result: MethodResult): void {
    try {
      const args = call.args as Record<string, string | number | boolean>;
      const titleValue = args['title'];
      const textValue = args['text'];
      const title = typeof titleValue === 'string' && titleValue.length > 0 ? titleValue : '正在下载';
      const text = typeof textValue === 'string' ? textValue : '';
      const request: notificationManager.NotificationRequest = {
        id: DOWNLOAD_NOTIFICATION_ID,
        isOngoing: true,
        content: {
          notificationContentType: notificationManager.ContentType.NOTIFICATION_CONTENT_BASIC_TEXT,
          normal: {
            title: title,
            text: text,
          },
        },
      };
      notificationManager.publish(request).then(() => {
        result.success(true);
      }).catch(() => {
        result.success(false);
      });
    } catch (err) {
      hilog.error(0, 'downloadNotification', '%{public}s', `${err as Error}`);
      result.success(false);
    }
  }

  private cancelDownloadNotification(result: MethodResult): void {
    notificationManager.cancel(DOWNLOAD_NOTIFICATION_ID).then(() => {
      result.success(true);
    }).catch(() => {
      result.success(false);
    });
  }
}
