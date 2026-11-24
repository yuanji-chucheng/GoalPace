import { BusinessError } from '@kit.BasicServicesKit';
import { ApiException } from '../model/ApiResult';

/**
 * 统一错误文案
 */
export class Errors {
  static text(error: Object): string {
    if (error instanceof ApiException) {
      return error.message;
    }
    const err = error as BusinessError;
    if (typeof err.message === 'string' && err.message !== '') {
      return err.message;
    }
    return '请求失败，请检查网络后重试';
  }
}
