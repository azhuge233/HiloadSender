import { hdsMaterial, HdsNavDestination, HdsNavDestinationTitleMode, ScrollEffectType } from "@kit.UIDesignKit";

@ComponentV2
export struct HelpPage {
    @Builder
    SectionTitle(text: Resource) {
        Text(text)
            .fontSize(18)
            .fontWeight(FontWeight.Bold)
            .width('100%')
            .margin({ top: 20, bottom: 8 })
    }

    @Builder
    Bullet(text: Resource) {
        Row() {
            Text('•')
                .fontSize(16)
                .margin({ right: 8 })
            Text(text)
                .fontSize(15)
                .layoutWeight(1)
        }
        .width('100%')
        .alignItems(VerticalAlign.Top)
        .margin({ bottom: 8 })
    }

    build() {
        HdsNavDestination() {
            Scroll() {
                Column() {
                    Text($r('app.string.help_intro'))
                        .fontSize(14)
                        .fontColor(Color.Gray)
                        .width('100%')

                    this.SectionTitle($r('app.string.help_steps_title'))
                    this.Bullet($r('app.string.help_step_1'))
                    this.Bullet($r('app.string.help_step_2'))
                    this.Bullet($r('app.string.help_step_3'))
                    this.Bullet($r('app.string.help_step_4'))
                    this.Bullet($r('app.string.help_step_5'))

                    this.SectionTitle($r('app.string.help_faq_title'))
                    this.Bullet($r('app.string.help_faq_1'))
                    this.Bullet($r('app.string.help_faq_2'))

                    Text($r('app.string.help_note'))
                        .fontSize(12)
                        .fontColor(Color.Gray)
                        .width('100%')
                        .margin({ top: 20 })
                }
                .width('100%')
                .alignItems(HorizontalAlign.Start)
                .constraintSize({ minHeight: '100%' })
                .justifyContent(FlexAlign.Start)
                .padding({ left: '10%', right: '10%', top: 8, bottom: 24 })
            }
            .width('100%')
            .height('100%')
        }
        .titleBar({
            content: {
                title: {
                    mainTitle: $r("app.string.help_title"),
                    subTitle: $r("app.string.help_subtitle")
                }
            },
            style: {
                scrollEffectOpts: {
                    enableScrollEffect: true,
                    scrollEffectType: ScrollEffectType.GRADIENT_BLUR
                },
                systemMaterialEffect: {
                    materialType: hdsMaterial.MaterialType.ADAPTIVE,
                    materialLevel: hdsMaterial.MaterialLevel.ADAPTIVE
                }
            },
            enableComponentSafeArea: true
        })
        .titleMode(HdsNavDestinationTitleMode.MODAL)
        .hideBackButton(false)
        .width('100%')
        .height('100%')
    }
}
