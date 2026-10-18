import { ConfigurationConstant } from '@kit.AbilityKit';

@ObservedV2
export class ThemeConfig {
    @Trace colorMode: number = ConfigurationConstant.ColorMode.COLOR_MODE_NOT_SET;
}
