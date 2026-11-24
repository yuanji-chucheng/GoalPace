import { AuthApi, UserApi } from '../model/Api';
import { AppSession } from './Session';
import { ChangePwdReq, LoginReq, RegisterReq, UpdateProfileReq, User } from '../model/Models';
import { Errors } from '../common/Errors';

/**
 * 登录 / 注册 / 改密 ViewModel
 */
@ObservedV2
export class LoginVm {
  @Trace username: string = '';
  @Trace password: string = '';
  @Trace loading: boolean = false;

  async login(): Promise<string> {
    if (this.username.trim() === '') {
      return '请输入用户名';
    }
    if (this.password === '') {
      return '请输入密码';
    }
    this.loading = true;
    try {
      const req = new LoginReq();
      req.username = this.username.trim();
      req.password = this.password;
      const result = await AuthApi.login(req);
      await AppSession.inst.onLoginSuccess(result.token, result.user);
      return '';
    } catch (error) {
      return Errors.text(error);
    } finally {
      this.loading = false;
    }
  }
}

@ObservedV2
export class RegisterVm {
  @Trace username: string = '';
  @Trace nickname: string = '';
  @Trace password: string = '';
  @Trace confirmPassword: string = '';
  @Trace loading: boolean = false;

  async register(): Promise<string> {
    if (this.username.trim() === '') {
      return '请输入用户名';
    }
    if (this.password.length < 8 || this.password.length > 20) {
      return '密码长度需为8-20位';
    }
    if (!(/[A-Za-z]/.test(this.password) && /[0-9]/.test(this.password))) {
      return '密码需同时包含字母和数字';
    }
    if (this.password !== this.confirmPassword) {
      return '两次输入的密码不一致';
    }
    this.loading = true;
    try {
      const req = new RegisterReq();
      req.username = this.username.trim();
      req.password = this.password;
      req.nickname = this.nickname.trim();
      await AuthApi.register(req);
      return '';
    } catch (error) {
      return Errors.text(error);
    } finally {
      this.loading = false;
    }
  }
}

@ObservedV2
export class ChangePwdVm {
  @Trace oldPassword: string = '';
  @Trace newPassword: string = '';
  @Trace confirmPassword: string = '';
  @Trace loading: boolean = false;

  async submit(): Promise<string> {
    if (this.oldPassword === '') {
      return '请输入原密码';
    }
    if (this.newPassword.length < 8 || this.newPassword.length > 20) {
      return '新密码长度需为8-20位';
    }
    if (!(/[A-Za-z]/.test(this.newPassword) && /[0-9]/.test(this.newPassword))) {
      return '新密码需同时包含字母和数字';
    }
    if (this.newPassword !== this.confirmPassword) {
      return '两次输入的新密码不一致';
    }
    this.loading = true;
    try {
      const req = new ChangePwdReq();
      req.oldPassword = this.oldPassword;
      req.newPassword = this.newPassword;
      await AuthApi.changePassword(req);
      return '';
    } catch (error) {
      return Errors.text(error);
    } finally {
      this.loading = false;
    }
  }
}

@ObservedV2
export class EditProfileVm {
  @Trace nickname: string = '';
  @Trace avatar: string = '';
  @Trace loading: boolean = false;
  @Trace uploading: boolean = false;

  load(user: User): void {
    this.nickname = user.nickname;
    this.avatar = user.avatar;
  }

  async uploadAvatar(imageBase64: string, filename: string): Promise<string> {
    this.uploading = true;
    try {
      const result = await UserApi.uploadAvatar({ imageBase64: imageBase64, filename: filename });
      this.avatar = result.url;
      return '';
    } catch (error) {
      return Errors.text(error);
    } finally {
      this.uploading = false;
    }
  }

  async save(): Promise<string> {
    if (this.nickname.trim() === '') {
      return '请输入昵称';
    }
    this.loading = true;
    try {
      const req = new UpdateProfileReq();
      req.nickname = this.nickname.trim();
      req.avatar = this.avatar;
      const user = await UserApi.updateProfile(req);
      AppSession.inst.applyUser(user);
      return '';
    } catch (error) {
      return Errors.text(error);
    } finally {
      this.loading = false;
    }
  }
}
