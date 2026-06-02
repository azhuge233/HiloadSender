import { socket } from '@kit.NetworkKit';
import { fileIo as fs } from '@kit.CoreFileKit';

import Logger from "./Logger";

export default class PayloadSender {
    private static LOG_TAG: string = "[PayloadSender]";

    static async sendPayload(filePath: string, host: string, port: number = 9021): Promise<boolean | string> {
        let tcpSocket = socket.constructTCPSocketInstance();
        let file: fs.File | null = null;

        try {
            file = fs.openSync(filePath, fs.OpenMode.READ_ONLY);
            let stat = fs.statSync(file.fd);
            let buffer = new ArrayBuffer(stat.size);
            fs.readSync(file.fd, buffer);

            Logger.info(PayloadSender.LOG_TAG, `成功读取文件，大小: ${stat.size} 字节`);

            let connectAddress: socket.NetAddress = {
                address: host,
                port: port,
                family: 1
            };

            Logger.info(PayloadSender.LOG_TAG, `正在连接到 ${host}:${port}...`);
            await tcpSocket.connect({ address: connectAddress });
            Logger.info(PayloadSender.LOG_TAG, `连接成功！开始发送数据...`);

            await tcpSocket.send({ data: buffer });
            Logger.info(PayloadSender.LOG_TAG, `数据发送完毕！`);

            return true;
        } catch (error) {
            const err = error as BusinessError;
            Logger.error(PayloadSender.LOG_TAG, `发生错误: Code: ${err.code}, Message: ${err.message}`);
            return err.message;
        } finally {
            if (file) fs.closeSync(file);

            try {
                await tcpSocket.close();
                Logger.info(PayloadSender.LOG_TAG, `Socket 连接已关闭`);
            } catch (err) {
                Logger.error(PayloadSender.LOG_TAG, `Socket 关闭异常, ${JSON.stringify(err)}`);
            }
        }
    }
}