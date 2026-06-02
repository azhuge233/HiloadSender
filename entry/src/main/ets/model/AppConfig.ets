@ObservedV2
export class AppConfig {
    @Trace ip: string = '';
    @Trace port: number = 9021;
    @Trace filePath: string = '';

    constructor(ip?: string, port?: number, filePath?: string) {
        if(ip) this.ip = ip;
        if(port) this.port = port;
        if(filePath) this.filePath = filePath;
    }
}