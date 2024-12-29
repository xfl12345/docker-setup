// mirrorlist.js

function generateMirrorlist(r) {
    // 获取查询参数
    const releaseVer = r.args.releasever || "7";
    const repo = r.args.repo || "os";
    const baseArch = r.args.basearch || "x86_64";

    // 定义镜像列表
    // http://mirrorlist.centos.org/?release=7&arch=x86_64&repo=os&infra=container
    // https://mirrors.aliyun.com/centos/7/os/x86_64/
    let mirrors = [
        `https://mirrors.cloud.tencent.com/centos/${releaseVer}/${repo}/${baseArch}/`,
        `https://mirrors.aliyun.com/centos/${releaseVer}/${repo}/${baseArch}/`,
        // `https://mirrors.aliyuncs.com/centos/${releaseVer}/${repo}/${baseArch}/`,
        // `https://mirrors.cloud.aliyuncs.com/centos/${releaseVer}/${repo}/${baseArch}/`,
        `https://mirrors.huaweicloud.com/centos/${releaseVer}/${repo}/${baseArch}/`
    ];

    if ((releaseVer.length === 1 || releaseVer.charAt(1) === ".") && parseInt(releaseVer.charAt(0)) <= 7) {
        let centosVaultVer = "7.9.2009";
        switch(releaseVer.charAt(0)) {
            case "6":
                centosVaultVer = "6.10";
                break;
            case "5":
                centosVaultVer = "5.11";
                break;
            case "4":
                centosVaultVer = "4.9";
                break;
            case "3":
                centosVaultVer = "3.9";
                break;
            case "2":
                centosVaultVer = "2.1";
                break;
            default:
                break;
        }

        mirrors = mirrors.concat([
            `https://mirrors.cloud.tencent.com/centos-vault/${centosVaultVer}/${repo}/${baseArch}/`,
            `https://mirrors.aliyun.com/centos-vault/${centosVaultVer}/${repo}/${baseArch}/`,
            `https://mirrors.163.com/centos-vault/${centosVaultVer}/${repo}/${baseArch}/`,
            `https://mirrors.huaweicloud.com/centos-vault/${centosVaultVer}/${repo}/${baseArch}/`,
            `https://mirrors.ustc.edu.cn/centos-vault/${centosVaultVer}/${repo}/${baseArch}/`
        ]);
    }

    r.status = 200;
    // 设置响应头
    r.headersOut['Content-Type'] = 'text/plain';
    r.headersOut['Content-Disposition'] = 'inline; filename="mirrorlist"';

    // 发送响应体
    r.sendHeader();
    mirrors.forEach(mirror => r.send(mirror + '\n'));
    r.finish();
}

export default {
    generateMirrorlist
}
