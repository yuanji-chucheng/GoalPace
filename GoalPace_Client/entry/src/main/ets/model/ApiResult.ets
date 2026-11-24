/**
 * 服务端统一返回结构与业务异常
 */
export class ApiResult<T> {
  code: number = -1;
  message: string = '';
  data: T | null = null;
}

export class ApiException extends Error {
  readonly code: number;

  constructor(code: number, message: string) {
    super(message);
    this.code = code;
    this.name = 'ApiException';
  }
}
