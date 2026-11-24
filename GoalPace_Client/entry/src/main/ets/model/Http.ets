import { http } from '@kit.NetworkKit';
import { ApiResult, ApiException } from './ApiResult';
import { Prefs } from './Prefs';

/**
 * 服务端地址: 模拟器使用 10.0.2.2 映射宿主机 8080;
 * 真机联调时改为局域网内服务端地址
 */
export class HttpConfig {
  static readonly BASE_URL: string = 'http://10.0.2.2:8080';
}

/**
 * 统一 HTTP 工具: @ohos.net.http, 统一解析 Result 与错误
 */
export class Http {
  /** 头像等静态资源相对路径 → 完整 URL */
  static assetUrl(path: string): string {
    if (path === '' || path.startsWith('http://') || path.startsWith('https://')) {
      return path;
    }
    return HttpConfig.BASE_URL + path;
  }

  static async get<T>(path: string): Promise<T> {
    return Http.request<T>(http.RequestMethod.GET, path, null, false) as Promise<T>;
  }

  static async post<T>(path: string, body: object): Promise<T> {
    return Http.request<T>(http.RequestMethod.POST, path, body, false) as Promise<T>;
  }

  static async put<T>(path: string, body: object | null): Promise<T> {
    return Http.request<T>(http.RequestMethod.PUT, path, body, false) as Promise<T>;
  }

  static async putVoid(path: string, body: object): Promise<void> {
    await Http.request<void>(http.RequestMethod.PUT, path, body, true);
  }

  static async postVoid(path: string, body: object): Promise<void> {
    await Http.request<void>(http.RequestMethod.POST, path, body, true);
  }

  static async delVoid(path: string): Promise<void> {
    await Http.request<void>(http.RequestMethod.DELETE, path, null, true);
  }

  private static async request<T>(method: http.RequestMethod, path: string,
    body: object | null, allowEmpty: boolean): Promise<T | null> {
    const token = await Prefs.getToken();
    const headers: Record<string, string> = {
      'Content-Type': 'application/json',
      'Accept': 'application/json'
    };
    if (token !== '') {
      headers['Authorization'] = 'Bearer ' + token;
    }
    const options: http.HttpRequestOptions = {
      method: method,
      header: headers,
      expectDataType: http.HttpDataType.STRING,
      connectTimeout: 10000,
      readTimeout: 15000
    };
    if (body !== null) {
      options.extraData = JSON.stringify(body);
    }
    const client = http.createHttp();
    try {
      const resp = await client.request(HttpConfig.BASE_URL + path, options);
      return Http.parse<T>(resp.responseCode, resp.result, allowEmpty);
    } finally {
      client.destroy();
    }
  }

  private static parse<T>(responseCode: number, result: string | Object | ArrayBuffer,
    allowEmpty: boolean): T | null {
    if (typeof result !== 'string') {
      throw new ApiException(-1, '服务器响应异常');
    }
    let body: ApiResult<T>;
    try {
      body = JSON.parse(result) as ApiResult<T>;
    } catch (error) {
      throw new ApiException(-1, '服务器响应解析失败');
    }
    if (body.code !== 0) {
      const msg = body.message === undefined || body.message === null || body.message === ''
        ? '请求失败(' + body.code.toString() + ')' : body.message;
      throw new ApiException(body.code, msg);
    }
    if (body.data === null || body.data === undefined) {
      if (allowEmpty) {
        return null;
      }
      throw new ApiException(-1, '服务器未返回数据');
    }
    if (responseCode < 200 || responseCode >= 300) {
      throw new ApiException(responseCode, '请求失败');
    }
    return body.data;
  }
}
