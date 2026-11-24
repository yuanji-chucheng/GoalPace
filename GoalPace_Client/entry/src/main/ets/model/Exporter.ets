import { picker, fileIo } from '@kit.CoreFileKit';
import { SyncApi } from './Api';
import { SyncPayload } from './Models';

/**
 * 数据备份与导出: GET /api/export 由服务端生成备份,
 * 客户端保存到用户选择的路径
 */
export class Exporter {
  static async exportBackup(): Promise<string> {
    const payload: SyncPayload = await SyncApi.exportAll();
    const jsonText = JSON.stringify(payload);
    const docPicker = new picker.DocumentViewPicker();
    const options: picker.DocumentSaveOptions = {
      newFileNames: ['goalpace-backup.json']
    };
    const uris: Array<string> = await docPicker.save(options);
    if (uris.length === 0) {
      return '';
    }
    const file = fileIo.openSync(uris[0], fileIo.OpenMode.READ_WRITE);
    try {
      fileIo.writeSync(file.fd, jsonText);
    } finally {
      fileIo.closeSync(file);
    }
    return '备份已保存';
  }
}
