import { BusinessError } from '@kit.BasicServicesKit';
import { PromptAction } from '@ohos.arkui.UIContext';
import { picker, fileIo as fs } from '@kit.CoreFileKit';
import { common } from '@kit.AbilityKit';
import { vibrator } from '@kit.SensorServiceKit';

import Logger from './Logger';

export default class CommonUtils {
    private static LOG_TAG: string = "[CommonUtils]";

    public static alert(message: string | Resource, promptAction: PromptAction, duration: number = 1500) {
        promptAction.openToast({
            message: message,
            duration: duration
        }).catch((err: BusinessError) => {
            Logger.error(CommonUtils.LOG_TAG, `toast 提示错误, ${err}`);
        });
    }

    public static vibrate(effectId: string) {
        try {
            vibrator.isSupportEffect(effectId, (err: BusinessError, state: boolean) => {
                if (err) {
                    Logger.error(CommonUtils.LOG_TAG, `查询振动效果失败, 代码: ${err.code}, 错误信息: ${err.message}`);
                    return;
                }

                Logger.info(CommonUtils.LOG_TAG, `设置支持 ${effectId} 振动`);

                if (state) {
                    try {
                        // 触发马达振动
                        vibrator.startVibration({
                            type: 'preset',
                            effectId: effectId,
                            count: 1,
                            intensity: 100,
                        }, {
                            usage: 'unknown'
                        }, (error: BusinessError) => {
                            if (error) Logger.error(CommonUtils.LOG_TAG, `振动触发失败, 代码: ${error.code}, 错误信息: ${error.message}`);
                            else Logger.info(CommonUtils.LOG_TAG, '成功触发振动');
                        });
                    } catch (error) {
                        Logger.error(CommonUtils.LOG_TAG, `振动发生未知错误, ${error}`);
                    }
                }
            });
        } catch (error) {
            Logger.error(CommonUtils.LOG_TAG, `振动发生未知错误, ${error}`);
        }
    }

    public static async pickFile(context: common.UIAbilityContext): Promise<string[]> {
        const documentSelectOptions = new picker.DocumentSelectOptions();
        documentSelectOptions.maxSelectNumber = 1;
        documentSelectOptions.fileSuffixFilters = [".elf", ".bin", ".py", ".js"];

        const documentViewPicker = new picker.DocumentViewPicker(context);
        const uris = await documentViewPicker.select(documentSelectOptions);

        Logger.info(CommonUtils.LOG_TAG, `选取文件: ${uris}`);
        return uris;
    }

    public static closeApplication(from: string, context: common.UIAbilityContext) {
        Logger.info(from, `关闭应用`);
        context.terminateSelf().catch((err: BusinessError) => {
            Logger.error(from, `关闭应用失败, ${err}`);
        });
    }
}