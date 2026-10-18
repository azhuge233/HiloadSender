import { hdsMaterial, HdsNavigation,
    HdsNavigationMenuContentOptions,
    HdsNavigationTitleMode, ScrollEffectType } from "@kit.UIDesignKit";
import { common, ConfigurationConstant } from "@kit.AbilityKit";
import { PersistenceV2 } from "@kit.ArkUI";
import bundleManager from '@ohos.bundle.bundleManager';

import Logger from "../common/utils/Logger";
import PayloadSender from "../common/utils/PayloadSender";
import CommonUtils from "../common/utils/CommonUtils";
import ThemeUtils from "../common/utils/ThemeUtils";
import { AppConfig } from "../model/AppConfig";
import { ThemeConfig } from "../model/ThemeConfig";
import { HelpPage } from "./HelpPage";

@Entry
@ComponentV2
struct Index {
    private LOG_TAG = "[pages/Index]";

    @Local versionName: string = '';
    @Local versionCode: string = '';

    private config: AppConfig | undefined = PersistenceV2.connect(AppConfig, 'UserAppConfig', () => new AppConfig());
    private themeConfig: ThemeConfig | undefined = PersistenceV2.connect(ThemeConfig, 'ThemeConfig', () => new ThemeConfig());
    private pathStack: NavPathStack = new NavPathStack();

    private uiContext = this.getUIContext();
    private context = this.uiContext.getHostContext() as common.UIAbilityContext;
    private promptAction = this.uiContext.getPromptAction();

    @Local themeIcon: Resource = $r("sys.symbol.auto_sun_max_fill");

    private get menus(): HdsNavigationMenuContentOptions {
        return {
            value: [
                {
                    content: {
                        label: $r("app.string.index_navigation_menu_theme"),
                        icon: this.themeIcon,
                        action: () => {
                            this.cycleThemeMode();
                        }
                    }
                },
                {
                    content: {
                        label: $r("app.string.index_navigation_menu_help"),
                        icon: $r("sys.symbol.info_circle"),
                        action: () => {
                            this.pathStack.pushPath({ name: 'Help' });
                        }
                    }
                }
            ]
        };
    }

    aboutToAppear(): void {
        try {
            let bundleInfo = bundleManager.getBundleInfoForSelfSync(bundleManager.BundleFlag.GET_BUNDLE_INFO_DEFAULT);
            this.versionName = bundleInfo.versionName;
            this.versionCode = bundleInfo.versionCode.toString();
        } catch (error) {
            Logger.error(this.LOG_TAG, `同步获取失败: ${error.message}`);
        }
    }

    private themeIconFor(mode: number): Resource {
        if (mode === ConfigurationConstant.ColorMode.COLOR_MODE_LIGHT) return $r("sys.symbol.sun_max");
        if (mode === ConfigurationConstant.ColorMode.COLOR_MODE_DARK) return $r("sys.symbol.moon_fill");
        return $r("sys.symbol.auto_sun_max_fill");
    }

    private themeLabelFor(mode: number): Resource {
        if (mode === ConfigurationConstant.ColorMode.COLOR_MODE_LIGHT) return $r("app.string.theme_light");
        if (mode === ConfigurationConstant.ColorMode.COLOR_MODE_DARK) return $r("app.string.theme_dark");
        return $r("app.string.theme_follow_system");
    }

    private cycleThemeMode(): void {
        const current = this.themeConfig?.colorMode ?? ConfigurationConstant.ColorMode.COLOR_MODE_NOT_SET;
        let next: number = ConfigurationConstant.ColorMode.COLOR_MODE_NOT_SET;

        if (current === ConfigurationConstant.ColorMode.COLOR_MODE_NOT_SET) {
            next = ConfigurationConstant.ColorMode.COLOR_MODE_LIGHT;
        } else if (current === ConfigurationConstant.ColorMode.COLOR_MODE_LIGHT) {
            next = ConfigurationConstant.ColorMode.COLOR_MODE_DARK;
        }

        if (this.themeConfig) this.themeConfig.colorMode = next;
        PersistenceV2.save('ThemeConfig');
        this.themeIcon = this.themeIconFor(next);
        ThemeUtils.applyColorMode(this.context, next);
        CommonUtils.alert(this.themeLabelFor(next), this.promptAction);
        Logger.info(this.LOG_TAG, `切换主题: ${current} -> ${next}`);
    }

    private getFileName(path: string | undefined): string | Resource {
        if (!path) return $r("app.string.no_payload_selected");

        const index = path.lastIndexOf('/');
        if (index !== -1) return path.substring(index + 1);
        return path;
    }

    @Builder
    VersionFooter() {
        Text(`${this.versionName} (${this.versionCode})`)
            .width('100%')
            .fontColor(Color.Grey)
            .fontSize(10)
            .alignSelf(ItemAlign.End)
            .textAlign(TextAlign.Center)
    }

    @Builder
    MainContent() {
        Scroll() {
            Column() {
                Blank().layoutWeight(1)

                Row() {
                    Text($r("app.string.index_ip_address_label"))
                        .width('20%')
                    TextInput({
                        placeholder: $r("app.string.index_ip_address_placeholder"),
                        text: this.config?.ip
                    })
                        .width('80%')
                        .maxLines(1)
                        .maxLength(15)
                        .border({
                            width: 1,
                            color: $r("sys.color.font_secondary")
                        })
                        .onChange((value: string) => {
                            if(this.config) this.config.ip = value;
                        })
                }
                .margin({
                    top: 5,
                    bottom: 5
                })

                Row() {
                    Text($r("app.string.index_port_label"))
                        .width('20%')
                    TextInput({
                        placeholder: $r("app.string.index_port_placeholder"),
                        text: this.config?.port.toString()
                    })
                        .width('80%')
                        .type(InputType.Number)
                        .maxLines(1)
                        .maxLength(5)
                        .border({
                            width: 1,
                            color: $r("sys.color.font_secondary")
                        })
                        .onChange((value: string) => {
                            if(this.config) this.config.port = Number(value);
                        })
                }
                .margin({
                    top: 5,
                    bottom: 5
                })

                Column() {
                    Row() {
                        Text($r("app.string.index_file_pick_label"))

                        Blank()

                        Button($r("app.string.index_file_pick_button_label"))
                            .buttonStyle(ButtonStyleMode.TEXTUAL)
                            .onClick(async () => {
                                let pickedPath = await CommonUtils.pickFile(this.context);

                                if(pickedPath.length === 0 || pickedPath[0] === '') {
                                    Logger.warn(this.LOG_TAG, `未选择载荷`);
                                    CommonUtils.alert($r("app.string.no_payload_selected"), this.promptAction);
                                    return;
                                }

                                if(this.config) this.config.filePath = pickedPath[0];
                            })
                    }
                    .width('100%')

                    Row() {
                        Text('📄')
                            .fontSize(28)
                            .margin({ right: 10 })

                        Column() {
                            Text(this.getFileName(this.config?.filePath))
                                .fontWeight(FontWeight.Bold)
                                .maxLines(1)
                                .textOverflow({
                                    overflow: TextOverflow.MARQUEE
                                })

                            if(this.config) {
                                Text(this.config.filePath)
                                    .fontSize(12)
                                    .fontColor(Color.Gray)
                                    .margin({ top: 4 })
                            }
                        }
                        .alignItems(HorizontalAlign.Start)
                        .layoutWeight(1)
                    }
                    .width('100%')
                }
                .width('100%')
                .backgroundColor($r("sys.color.background_tertiary"))
                .padding(12)
                .borderRadius(8)
                .margin({ top: 8 })

                Button($r("app.string.index_send_button_label"))
                    .width('80%')
                    .margin({
                        top: 20
                    })
                    .onClick(async () => {
                        if (!this.config) {
                            Logger.warn(this.LOG_TAG, `空 config`);
                            CommonUtils.alert($r("app.string.undefined_config"), this.promptAction);
                            return;
                        }

                        const host = this.config.ip.trim();
                        if (!CommonUtils.isValidIPv4(host)) {
                            Logger.warn(this.LOG_TAG, `无效 IP: ${this.config.ip}`);
                            CommonUtils.alert($r("app.string.invalid_ip_address"), this.promptAction);
                            return;
                        }

                        if (!CommonUtils.isValidPort(this.config.port)) {
                            Logger.warn(this.LOG_TAG, `无效端口: ${this.config.port}`);
                            CommonUtils.alert($r("app.string.invalid_port"), this.promptAction);
                            return;
                        }

                        if (!this.config.filePath) {
                            Logger.warn(this.LOG_TAG, `未选择 payload`);
                            CommonUtils.alert($r("app.string.no_payload_selected"), this.promptAction);
                            return;
                        }

                        CommonUtils.vibrate("haptic.effect.hard");
                        CommonUtils.alert($r("app.string.sending"), this.promptAction, 6000);

                        Logger.info(this.LOG_TAG, `向 IP = ${host} 端口 = ${this.config.port} 发送 payload: ${this.config.filePath}`);

                        const result = await PayloadSender.sendPayload(this.config.filePath, host, this.config.port);

                        if (typeof result === "boolean") CommonUtils.alert($r("app.string.send_success"), this.promptAction);
                        else CommonUtils.alert($r("app.string.send_failed", result), this.promptAction);
                    });

                Blank().layoutWeight(1)
            }
            .padding({
                left: '10%',
                right: '10%'
            })
        }
    }

    @Builder
    PageMap(name: string, param: Object) {
        if (name === 'Help') {
            HelpPage();
        }
    }

    build() {
        HdsNavigation(this.pathStack) {
            this.MainContent();

            this.VersionFooter();
        }
        .navDestination(this.PageMap)
        .titleBar({
            content: {
                title: {
                    mainTitle: $r("app.string.index_navigation_title"),
                    subTitle: $r("app.string.index_navigation_subtitle")
                },
                menu: this.menus,
            },
            style: {
                scrollEffectOpts: {
                    // 设置滚动特效
                    enableScrollEffect: true,
                    scrollEffectType: ScrollEffectType.GRADIENT_BLUR,
                },
                systemMaterialEffect: {
                    // 设置沉浸光感
                    materialType: hdsMaterial.MaterialType.ADAPTIVE,
                    materialLevel: hdsMaterial.MaterialLevel.ADAPTIVE
                },
            },
            //avoidLayoutSafeArea: false,
            enableComponentSafeArea: true // 启用标题栏占位
        })
        .titleMode(HdsNavigationTitleMode.MODAL)
        .height('100%')
        .width('100%')
        .onAppear(() => {
            Logger.info(this.LOG_TAG, "Loaded!");
            const colorMode = this.themeConfig?.colorMode ?? ConfigurationConstant.ColorMode.COLOR_MODE_NOT_SET;
            ThemeUtils.applyColorMode(this.context, colorMode);
            this.themeIcon = this.themeIconFor(colorMode);
        })
    }
}