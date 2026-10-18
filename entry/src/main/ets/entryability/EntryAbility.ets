import { AbilityConstant, UIAbility, Want } from "@kit.AbilityKit";
import { window, KeyboardAvoidMode } from "@kit.ArkUI";

import Logger from '../common/utils/Logger';

export default class EntryAbility extends UIAbility {
    private LOG_TAG: string = "[EntryAbility]";

    onCreate(want: Want, launchParam: AbilityConstant.LaunchParam): void {
        Logger.debug(this.LOG_TAG, `onCreate`);
    }

    onDestroy(): void {
        Logger.debug(this.LOG_TAG, `onDestroy`);
    }

    onWindowStageCreate(windowStage: window.WindowStage): void {
        // Main window is created, set main page for this ability
        Logger.debug(this.LOG_TAG, "onWindowStageCreate");

        windowStage.loadContent("pages/Index", (err) => {
            if(err.code) {
                Logger.error(this.LOG_TAG, `Failed to load the content. Cause: ${JSON.stringify(err)}`);
                return;
            }

            try {
                windowStage.getMainWindowSync().getUIContext().setKeyboardAvoidMode(KeyboardAvoidMode.RESIZE_WITH_CARET);
            } catch (err) {
                Logger.error(this.LOG_TAG, `loadContent() 设置软键盘避让失败`);
            }

            Logger.debug(this.LOG_TAG, "Succeeded in loading the content.");
        });
    }

    onWindowStageDestroy(): void {
        // Main window is destroyed, release UI related resources
        Logger.debug(this.LOG_TAG, "onWindowStageDestroy");
    }

    onForeground(): void {
        // Ability has brought to foreground
        Logger.debug(this.LOG_TAG, "onForeground");
    }

    onBackground(): void {
        // Ability has back to background
        Logger.debug(this.LOG_TAG, "onBackground");
    }
};