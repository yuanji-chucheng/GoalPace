import { photoAccessHelper } from '@kit.MediaLibraryKit';
import { fileIo } from '@kit.CoreFileKit';
import { util } from '@kit.ArkTS';
import { Theme } from '../common/Theme';
import { Bus } from '../common/Bus';
import { EditProfileVm } from '../viewmodel/AuthVms';
import { AppSession } from '../viewmodel/Session';
import { Http } from '../model/Http';
import { FieldLabel, NavHeader } from '../components/Widgets';

/**
 * S11 编辑资料: imagePicker 头像(base64 上传) + 昵称修改
 */
@ComponentV2
export struct EditProfilePage {
  navPathStack: NavPathStack = new NavPathStack();
  @Local vm: EditProfileVm = new EditProfileVm();
  @Local session: AppSession = AppSession.inst;

  build() {
    NavDestination() {
      Column() {
        NavHeader({ stack: this.navPathStack, headerTitle: '编辑资料' })
        Scroll() {
          Column({ space: 18 }) {
            Column({ space: 12 }) {
              if (this.vm.avatar !== '') {
                Image(Http.assetUrl(this.vm.avatar))
                  .width(84)
                  .height(84)
                  .borderRadius(42)
                  .backgroundColor(Theme.TRACK)
              } else {
                Column() {
                  Text(this.vm.nickname === '' ? '👤' : this.vm.nickname.substring(0, 1))
                    .fontSize(30)
                    .fontWeight(FontWeight.Bold)
                    .fontColor(Color.White)
                }
                .width(84)
                .height(84)
                .borderRadius(42)
                .backgroundColor(Theme.PRIMARY)
                .justifyContent(FlexAlign.Center)
              }
              Text(this.vm.uploading ? '上传中...' : '更换头像')
                .fontSize(13)
                .fontColor(Theme.PRIMARY_DEEP)
                .padding({ left: 14, right: 14, top: 7, bottom: 7 })
                .backgroundColor(Theme.PRIMARY_SOFT)
                .borderRadius(16)
                .onClick(() => {
                  this.pickAvatar();
                })
            }
            .width('100%')
            .margin({ top: 12 })

            Column({ space: 8 }) {
              FieldLabel({ label: '昵称', required: true })
              TextInput({ placeholder: '给自己起个名字', text: this.vm.nickname })
                .backgroundColor(Theme.INPUT_BG)
                .fontColor(Theme.TEXT)
                .fontSize(Theme.FONT_BODY)
                .placeholderColor(Theme.TEXT_LIGHT)
                .height(46)
                .borderRadius(Theme.RADIUS_SM)
                .border({ width: 1, color: Theme.DIVIDER })
                .padding({ left: 14, right: 14 })
                .onChange((value: string) => {
                  this.vm.nickname = value;
                })
            }
            .width('100%')
            .alignItems(HorizontalAlign.Start)

            Column({ space: 8 }) {
              FieldLabel({ label: '账号' })
              Row() {
                Text('@' + this.session.user.username)
                  .fontSize(14)
                  .fontColor(Theme.TEXT_LIGHT)
                  .layoutWeight(1)
                Text('账号不可修改')
                  .fontSize(11)
                  .fontColor(Theme.TEXT_LIGHT)
                  .opacity(0.8)
              }
              .width('100%')
              .height(46)
              .padding({ left: 14, right: 14 })
              .borderRadius(Theme.RADIUS_SM)
              .border({ width: 1, color: Theme.DIVIDER })
              .backgroundColor('rgba(255,255,255,0.4)')
              .alignItems(VerticalAlign.Center)
            }
            .width('100%')
            .alignItems(HorizontalAlign.Start)

            Button(this.vm.loading ? '保存中...' : '保存资料')
              .width('100%')
              .height(46)
              .backgroundColor(Theme.PRIMARY)
              .fontColor(Color.White)
              .fontSize(16)
              .fontWeight(FontWeight.Medium)
              .borderRadius(23)
              .margin({ top: 8 })
              .enabled(!this.vm.loading)
              .opacity(this.vm.loading ? 0.6 : 1)
              .onClick(() => {
                this.handleSave();
              })
          }
          .width('100%')
          .padding({ left: 20, right: 20, top: 16, bottom: 40 })
          .alignItems(HorizontalAlign.Start)
        }
        .scrollBar(BarState.Off)
        .layoutWeight(1)
        .width('100%')
      }
      .width('100%')
      .height('100%')
    }
    .onReady((ctx: NavDestinationContext) => {
      this.navPathStack = ctx.pathStack;
      this.vm.load(AppSession.inst.user);
    })
    .backgroundColor(Theme.BG)
  }

  private async pickAvatar(): Promise<void> {
    const prompt = this.getUIContext().getPromptAction();
    if (this.vm.uploading) {
      return;
    }
    try {
      const photoPicker = new photoAccessHelper.PhotoViewPicker();
      const options: photoAccessHelper.PhotoSelectOptions = {
        MIMEType: photoAccessHelper.PhotoViewMIMETypes.IMAGE_TYPE,
        maxSelectNumber: 1
      };
      const result: photoAccessHelper.PhotoSelectResult = await photoPicker.select(options);
      if (result.photoUris.length === 0) {
        return;
      }
      const uri = result.photoUris[0];
      const file = fileIo.openSync(uri, fileIo.OpenMode.READ_ONLY);
      let base64 = '';
      try {
        const stat = fileIo.statSync(file.fd);
        const buffer = new ArrayBuffer(stat.size);
        fileIo.readSync(file.fd, buffer);
        base64 = new util.Base64Helper().encodeToStringSync(new Uint8Array(buffer));
      } finally {
        fileIo.closeSync(file);
      }
      const filename = uri.substring(uri.lastIndexOf('/') + 1);
      const msg = await this.vm.uploadAvatar(base64, filename);
      if (msg !== '') {
        prompt.showToast({ message: msg });
      } else {
        prompt.showToast({ message: '头像已上传，记得保存资料' });
      }
    } catch (error) {
      prompt.showToast({ message: '读取图片失败，请重试' });
    }
  }

  private handleSave(): void {
    const prompt = this.getUIContext().getPromptAction();
    this.vm.save().then((msg: string) => {
      if (msg !== '') {
        prompt.showToast({ message: msg });
      } else {
        Bus.inst.bumpUser();
        prompt.showToast({ message: '资料已更新' });
        this.navPathStack.pop();
      }
    });
  }
}

@Builder
export function EditProfileBuilder() {
  EditProfilePage()
}
