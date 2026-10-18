import { socket } from '@kit.NetworkKit';
import { fileIo as fs } from '@kit.CoreFileKit';
import { BusinessError } from '@kit.BasicServicesKit';

import Logger from "./Logger";

export default class PayloadSender {
    private static LOG_TAG: string = "[PayloadSender]";
    private static CONNECT_TIMEOUT_MS: number = 5000;
    private static CONNECT_ATTEMPTS: number = 2;
    private static SEND_TIMEOUT_MS: number = 10000;

    static async sendPayload(filePath: string, host: string, port: number = 9021): Promise<boolean | string> {
        if (!filePath) {
            Logger.warn(PayloadSender.LOG_TAG, `未选择 payload 文件`);
            return 'No payload file selected';
        }

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

            let connected = false;
            for (let attempt = 1; attempt <= PayloadSender.CONNECT_ATTEMPTS && !connected; attempt++) {
                try {
                    Logger.info(PayloadSender.LOG_TAG, `正在连接到 ${host}:${port}（第 ${attempt} 次）...`);
                    await PayloadSender.withTimeout(
                        tcpSocket.connect({
                            address: connectAddress,
                            timeout: PayloadSender.CONNECT_TIMEOUT_MS
                        }),
                        PayloadSender.CONNECT_TIMEOUT_MS + 1000,
                        'Connection timed out'
                    );
                    connected = true;
                } catch (error) {
                    const err = error as BusinessError;
                    Logger.warn(PayloadSender.LOG_TAG,
                        `连接失败（第 ${attempt} 次）: Code: ${err.code}, Message: ${err.message}`);
                    if (attempt < PayloadSender.CONNECT_ATTEMPTS) {
                        try {
                            await tcpSocket.close();
                        } catch (closeError) {
                            Logger.warn(PayloadSender.LOG_TAG, `重试前关闭 Socket 异常, ${JSON.stringify(closeError)}`);
                        }
                        tcpSocket = socket.constructTCPSocketInstance();
                    } else {
                        throw error as Error;
                    }
                }
            }

            Logger.info(PayloadSender.LOG_TAG, `连接成功！开始发送数据...`);
            await PayloadSender.withTimeout(
                tcpSocket.send({ data: buffer }),
                PayloadSender.SEND_TIMEOUT_MS,
                'Send timed out'
            );
            Logger.info(PayloadSender.LOG_TAG, `数据发送完毕！`);

            return true;
        } catch (error) {
            const err = error as BusinessError;
            Logger.error(PayloadSender.LOG_TAG, `发生错误: Code: ${err.code}, Message: ${err.message}`);
            return err.message;
        } finally {
            if (file) {
                try {
                    fs.closeSync(file);
                } catch (error) {
                    const err = error as BusinessError;
                    Logger.error(PayloadSender.LOG_TAG, `关闭文件异常: Code: ${err.code}, Message: ${err.message}`);
                }
            }

            try {
                await tcpSocket.close();
                Logger.info(PayloadSender.LOG_TAG, `Socket 连接已关闭`);
            } catch (err) {
                Logger.error(PayloadSender.LOG_TAG, `Socket 关闭异常, ${JSON.stringify(err)}`);
            }
        }
    }

    private static withTimeout<T>(promise: Promise<T>, timeoutMs: number, message: string): Promise<T> {
        return new Promise<T>((resolve, reject) => {
            let timer = setTimeout(() => {
                reject(new Error(message));
            }, timeoutMs);

            promise.then((value: T) => {
                clearTimeout(timer);
                resolve(value);
            }).catch((error: BusinessError) => {
                clearTimeout(timer);
                reject(error);
            });
        });
    }
}
