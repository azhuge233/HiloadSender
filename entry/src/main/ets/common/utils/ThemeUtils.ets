import { common, ConfigurationConstant } from '@kit.AbilityKit';
import { BusinessError } from '@kit.BasicServicesKit';

import Logger from './Logger';

export default class ThemeUtils {
    private static LOG_TAG: string = "[ThemeUtils]";

    public static applyColorMode(context: common.UIAbilityContext, colorMode: number): void {
        let mode: ConfigurationConstant.ColorMode = ConfigurationConstant.ColorMode.COLOR_MODE_NOT_SET;
        if (colorMode === ConfigurationConstant.ColorMode.COLOR_MODE_DARK) {
            mode = ConfigurationConstant.ColorMode.COLOR_MODE_DARK;
        } else if (colorMode === ConfigurationConstant.ColorMode.COLOR_MODE_LIGHT) {
            mode = ConfigurationConstant.ColorMode.COLOR_MODE_LIGHT;
        }

        try {
            context.setColorMode(mode);
            Logger.info(ThemeUtils.LOG_TAG, `设置配色模式: ${mode}`);
        } catch (error) {
            const err = error as BusinessError;
            Logger.error(ThemeUtils.LOG_TAG, `设置配色模式失败: Code: ${err.code}, Message: ${err.message}`);
        }
    }
}
